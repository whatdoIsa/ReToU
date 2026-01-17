import Foundation
import SwiftData

/// SwiftData를 사용한 Reflection Repository 구현
/// CRUD 작업을 모두 수행하며, UI/ViewModel에서 직접 저장소에 접근
@MainActor
final class SwiftDataReflectionRepository: ObservableObject {
    private let modelContext: ModelContext
    private let dateManager = SafeDateManager.shared
    
    init(context: ModelContext? = nil) {
        if let context = context {
            self.modelContext = context
        } else {
            self.modelContext = DataContainer.shared.newContext()
        }
    }
    
    // MARK: - CRUD Operations
    
    /// Create or Update: 하루에 1개 기록 규칙 보장
    func createOrUpdate(content: String, emotion: String, date: Date) -> Result<Reflection, ReflectionError> {
        // 1. 도메인 규칙: 감정 선택 필수
        let trimmedEmotion = emotion.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedEmotion.isEmpty else {
            return .failure(.emotionRequired)
        }
        
        // 2. 도메인 규칙: 내용 입력 필수
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedContent.isEmpty else {
            return .failure(.contentRequired)
        }
        
        let dateKey = dateManager.generateDateKey(for: date)
        
        do {
            let resultReflection: Reflection
            
            // 같은 dateKey를 가진 기존 회고 검색 (전체 조회 후 필터링)
            let targetDateKey = dateManager.generateDateKey(for: date)
            
            let fetchRequest = FetchDescriptor<Reflection>()
            
            let allReflections = try modelContext.fetch(fetchRequest)
            let existingReflection = allReflections.first { reflection in
                dateManager.generateDateKey(for: reflection.date) == targetDateKey
            }
            
            if let existingReflection = existingReflection {
                // 업데이트 경로: 기존 회고 수정
                existingReflection.emotion = trimmedEmotion
                existingReflection.content = trimmedContent
                existingReflection.updatedAt = Date()
                resultReflection = existingReflection
                print("✅ Updated existing reflection for \(dateKey)")
            } else {
                // 생성 경로: 새로운 회고 추가
                let newOrder = getNextOrder()
                let newReflection = Reflection(
                    date: date, 
                    emotion: trimmedEmotion, 
                    content: trimmedContent, 
                    order: newOrder
                )
                modelContext.insert(newReflection)
                resultReflection = newReflection
                print("✅ Created new reflection for \(dateKey) with order \(newOrder)")
            }
            
            try modelContext.save()
            return .success(resultReflection)
            
        } catch {
            return .failure(.saveFailed(error))
        }
    }
    
    /// 회고 삭제
    func delete(reflection: Reflection) -> Result<Void, ReflectionError> {
        do {
            modelContext.delete(reflection)
            try modelContext.save()
            
            // 삭제 후 순서 재정렬
            try reorderReflections()
            print("✅ Deleted reflection and reordered remaining reflections")
            
            return .success(())
        } catch {
            return .failure(.saveFailed(error))
        }
    }
    
    /// 회고 업데이트
    func update(reflection: Reflection, content: String, emotion: String) -> Result<Reflection, ReflectionError> {
        // 1. 도메인 규칙: 감정 선택 필수
        let trimmedEmotion = emotion.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedEmotion.isEmpty else {
            return .failure(.emotionRequired)
        }
        
        // 2. 도메인 규칙: 내용 입력 필수
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedContent.isEmpty else {
            return .failure(.contentRequired)
        }
        
        do {
            reflection.emotion = trimmedEmotion
            reflection.content = trimmedContent
            reflection.updatedAt = Date()
            
            try modelContext.save()
            
            let dateKey = dateManager.generateDateKey(for: reflection.date)
            print("✅ Updated reflection for \(dateKey)")
            
            return .success(reflection)
        } catch {
            return .failure(.saveFailed(error))
        }
    }
    
    // MARK: - Fetch Operations
    
    /// 특정 년월의 회고 조회
    func fetchReflections(forYear year: Int, month: Int) -> Result<[Reflection], ReflectionError> {
        guard let dateRange = dateManager.dateRange(for: year, month: month) else {
            print("❌ Invalid date range for \(year)-\(month)")
            return .success([])
        }
        
        do {
            let fetchRequest = FetchDescriptor<Reflection>(
                sortBy: [SortDescriptor(\.order, order: .forward)]
            )
            
            let allReflections = try modelContext.fetch(fetchRequest)
            
            // 날짜 범위 필터링
            let filteredReflections = allReflections.filter { reflection in
                reflection.date >= dateRange.start && reflection.date <= dateRange.end
            }
            
            print("📚 Fetched \(filteredReflections.count) reflections for \(year)-\(month)")
            
            return .success(filteredReflections)
        } catch {
            return .failure(.saveFailed(error))
        }
    }
    
    /// 모든 회고 조회 (order 기준 정렬)
    func fetchAllReflections() -> Result<[Reflection], ReflectionError> {
        do {
            let fetchRequest = FetchDescriptor<Reflection>(
                sortBy: [SortDescriptor(\.order, order: .forward)]
            )
            
            let reflections = try modelContext.fetch(fetchRequest)
            return .success(reflections)
        } catch {
            return .failure(.saveFailed(error))
        }
    }
    
    /// 오늘 회고 존재 여부 확인
    func hasReflectionForToday() -> Bool {
        let todayDateKey = dateManager.todayDateKey()
        
        do {
            let fetchRequest = FetchDescriptor<Reflection>()
            let allReflections = try modelContext.fetch(fetchRequest)
            
            return allReflections.contains { reflection in
                dateManager.generateDateKey(for: reflection.date) == todayDateKey
            }
        } catch {
            print("❌ Error checking today's reflection: \(error)")
            return false
        }
    }
    
    // MARK: - Statistics
    
    /// 선택된 연/월에 해당하는 감정별 빈도수 계산
    func emotionSummary(forYear year: Int, month: Int) -> [EmotionType: Int] {
        var summary: [EmotionType: Int] = [:]
        
        switch fetchReflections(forYear: year, month: month) {
        case .success(let reflections):
            for reflection in reflections {
                if let emotion = EmotionType(rawValue: reflection.emotion) {
                    summary[emotion, default: 0] += 1
                }
            }
        case .failure:
            break
        }
        
        return summary
    }
    
    
    // MARK: - Private Helpers
    
    /// 다음 order 값 가져오기
    private func getNextOrder() -> Int {
        do {
            var fetchRequest = FetchDescriptor<Reflection>(
                sortBy: [SortDescriptor(\.order, order: .reverse)]
            )
            fetchRequest.fetchLimit = 1
            
            let lastReflection = try modelContext.fetch(fetchRequest).first
            return (lastReflection?.order ?? -1) + 1
        } catch {
            print("❌ Error getting next order: \(error)")
            return 0
        }
    }
    
    /// order 재정렬 (삭제 후 순서 정리)
    private func reorderReflections() throws {
        let fetchRequest = FetchDescriptor<Reflection>(
            sortBy: [SortDescriptor(\.order, order: .forward)]
        )
        
        let reflections = try modelContext.fetch(fetchRequest)
        for (index, reflection) in reflections.enumerated() {
            reflection.order = index
        }
        
        try modelContext.save()
    }
}