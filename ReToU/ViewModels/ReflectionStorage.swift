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
        
        switch result {
        case .success:
            // 성공시 현재 화면에 표시된 데이터 새로고침
            refreshCurrentReflections()
        case .failure:
            break
        }
        
        return result
    }

    func delete(reflection: Reflection) {
        let result = useCase.deleteReflection(reflection)
        
        switch result {
        case .success:
            // 성공시 현재 화면에 표시된 데이터 새로고침
            refreshCurrentReflections()
            print("✅ Deleted reflection and reordered remaining reflections")
        case .failure(let error):
            print("❌ Failed to delete reflection: \(error)")
        }
    }

    func update(reflection: Reflection, content: String, emotion: String) -> Result<Reflection, ReflectionError> {
        let result = useCase.updateReflection(reflection, content: content, emotion: emotion)
        
        switch result {
        case .success:
            // 성공시 현재 화면에 표시된 데이터 새로고침
            refreshCurrentReflections()
        case .failure:
            break
        }
        
        return result
    }
    
    func fetchReflections(forYear year: Int, month: Int) {
        switch useCase.getReflections(forYear: year, month: month) {
        case .success(let userReflections):
            // 🔥 더미 데이터도 동일한 년/월 필터 적용
            let filteredDummyReflections: [Reflection]
            if useDummy {
                guard let dateRange = dateManager.dateRange(for: year, month: month) else {
                    self.reflections = userReflections
                    return
                }
                let startKey = dateManager.generateDateKey(for: dateRange.start)
                let endKey = dateManager.generateDateKey(for: dateRange.end)
                
                filteredDummyReflections = DummyData.reflections.filter {
                    let reflectionKey = $0.dateKey
                    return reflectionKey >= startKey && reflectionKey <= endKey
                }
            } else {
                filteredDummyReflections = []
            }
            
            // 🔥 필터링된 데이터들을 합친 후 중복 제거
            let allFilteredReflections = filteredDummyReflections + userReflections
            
            // ⭐ 중복 제거: 같은 dateKey를 가진 항목은 하나만 유지 (order 기준 정렬)
            let uniqueReflections = Array(Dictionary(grouping: allFilteredReflections, by: \.dateKey).compactMapValues { reflections in
                reflections.sorted(by: { $0.date > $1.date }).first
            }.values).sorted(by: { $0.order < $1.order })
            
            self.reflections = uniqueReflections
            print("📚 Fetched \(uniqueReflections.count) unique reflections for \(year)-\(month) (user: \(userReflections.count), dummy: \(filteredDummyReflections.count))")
            
        case .failure(let error):
            print("❌ Failed to fetch reflections: \(error)")
            self.reflections = []
        }
    }

    /// 현재 화면에 표시된 데이터 새로고침 (SwiftData 기반)
    private func refreshCurrentReflections() {
        switch useCase.getAllReflections() {
        case .success(let userReflections):
            let allReflections = useDummy ? (DummyData.reflections + userReflections).sorted(by: { $0.order < $1.order }) : userReflections
            self.reflections = allReflections
        case .failure(let error):
            print("❌ Failed to refresh reflections: \(error)")
        }
    }
    
    // 선택된 연/월에 해당하는 감정별 빈도수 계산
    func emotionSummary(forYear year: Int, month: Int) -> [EmotionType: Int] {
        let userSummary = useCase.getEmotionSummary(forYear: year, month: month)
        
        // 더미 데이터 처리 (필요시)
        if useDummy {
            var summary = userSummary
            guard let dateRange = dateManager.dateRange(for: year, month: month) else {
                return summary
            }
            
            let startKey = dateManager.generateDateKey(for: dateRange.start)
            let endKey = dateManager.generateDateKey(for: dateRange.end)
            
            let filteredDummyReflections = DummyData.reflections.filter {
                let reflectionKey = $0.dateKey
                return reflectionKey >= startKey && reflectionKey <= endKey
            }
            
            for reflection in filteredDummyReflections {
                if let emotion = EmotionType(rawValue: reflection.emotion) {
                    summary[emotion, default: 0] += 1
                }
            }
            return summary
        }
        
        return userSummary
    }
    
    // 가장 많이 등장한 감정과 그에 맞는 메시지 반환
    func dominantEmotionMessage(forYear year: Int, month: Int) -> (EmotionType?, String) {
        return useCase.getDominantEmotionMessage(forYear: year, month: month)
    }
    
    /// SwiftData 기반 초기화 및 마이그레이션 처리
    private func load() {
        // 마이그레이션 확인 및 실행
        if !useCase.isMigrationDone() {
            print("🔄 Starting migration from UserDefaults to SwiftData...")
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

}
