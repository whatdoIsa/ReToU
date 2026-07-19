import Foundation
import SwiftData

@MainActor
class ReflectionStorage: ObservableObject {
    @Published var reflections: [Reflection] = []

    private let useCase: ReflectionUseCase
    private let useDummy: Bool
    private let dateManager = SafeDateManager.shared

    init(useDummy: Bool = false, useCase: ReflectionUseCase? = nil) {
        self.useDummy = useDummy
        if let useCase = useCase {
            self.useCase = useCase
        } else {
            self.useCase = ReflectionUseCase()
        }
        load()
    }

    func hasReflectionForToday() -> Bool {
        return useCase.hasTodayReflection()
    }

    /// ⭐ 핵심: CreateOrUpdate 패턴으로 "하루에 1개 기록" 규칙 보장
    /// Domain 레벨에서 감정 선택 필수 검증
    func add(content: String, emotion: String, date: Date) -> Result<Reflection, ReflectionError> {
        let result = useCase.createOrUpdateReflection(content: content, emotion: emotion, date: date)

        if case .success = result {
            refreshCurrentReflections()
        }

        return result
    }

    /// 회고 삭제 — 실패 시 호출자가 사용자에게 알릴 수 있도록 Result 반환
    @discardableResult
    func delete(reflection: Reflection) -> Result<Void, ReflectionError> {
        let result = useCase.deleteReflection(reflection)

        if case .success = result {
            refreshCurrentReflections()
        }

        return result
    }

    func update(reflection: Reflection, content: String, emotion: String) -> Result<Reflection, ReflectionError> {
        let result = useCase.updateReflection(reflection, content: content, emotion: emotion)

        if case .success = result {
            refreshCurrentReflections()
        }

        return result
    }

    func fetchReflections(forYear year: Int, month: Int) {
        switch useCase.getReflections(forYear: year, month: month) {
        case .success(let userReflections):
            let allFilteredReflections = dummyReflections(forYear: year, month: month) + userReflections

            // ⭐ 중복 제거: 같은 dateKey를 가진 항목은 하나만 유지 (order 기준 정렬)
            let uniqueReflections = Array(Dictionary(grouping: allFilteredReflections, by: \.dateKey).compactMapValues { reflections in
                reflections.sorted(by: { $0.date > $1.date }).first
            }.values).sorted(by: { $0.order < $1.order })

            self.reflections = uniqueReflections

        case .failure(let error):
            print("❌ Failed to fetch reflections: \(error)")
            self.reflections = []
        }
    }

    /// 현재 화면에 표시된 데이터 새로고침 (SwiftData 기반)
    private func refreshCurrentReflections() {
        switch useCase.getAllReflections() {
        case .success(let userReflections):
            self.reflections = (allDummyReflections() + userReflections).sorted(by: { $0.order < $1.order })
        case .failure(let error):
            print("❌ Failed to refresh reflections: \(error)")
        }
    }

    // 선택된 연/월에 해당하는 감정별 빈도수 계산
    func emotionSummary(forYear year: Int, month: Int) -> [EmotionType: Int] {
        var summary = useCase.getEmotionSummary(forYear: year, month: month)

        for reflection in dummyReflections(forYear: year, month: month) {
            if let emotion = EmotionType(rawValue: reflection.emotion) {
                summary[emotion, default: 0] += 1
            }
        }

        return summary
    }

    // 가장 많이 등장한 감정과 그에 맞는 메시지 반환
    func dominantEmotionMessage(forYear year: Int, month: Int) -> (EmotionType?, String) {
        return useCase.getDominantEmotionMessage(forYear: year, month: month)
    }

    /// SwiftData 기반 초기화 및 마이그레이션 처리
    private func load() {
        // 마이그레이션 확인 및 실행
        if !useCase.isMigrationDone() {
            switch useCase.migrateFromLegacyStorage() {
            case .success:
                print("✅ Migration completed successfully")
            case .failure(let error):
                print("❌ Migration failed: \(error)")
            }
        }

        // 초기 데이터 로드
        refreshCurrentReflections()

        // 안전한 레거시 데이터 정리 (조건부)
        useCase.autoCleanupIfSafe()
    }

    // MARK: - Dummy Data (프리뷰/개발 전용)

    private func allDummyReflections() -> [Reflection] {
        #if DEBUG
        return useDummy ? DummyData.reflections : []
        #else
        return []
        #endif
    }

    private func dummyReflections(forYear year: Int, month: Int) -> [Reflection] {
        #if DEBUG
        guard useDummy, let dateRange = dateManager.dateRange(for: year, month: month) else {
            return []
        }
        // end는 exclusive — 다음 달 1일이 포함되지 않도록 `<` 비교
        return DummyData.reflections.filter {
            $0.date >= dateRange.start && $0.date < dateRange.end
        }
        #else
        return []
        #endif
    }
}
