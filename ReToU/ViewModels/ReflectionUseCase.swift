import Foundation
import SwiftData

/// Domain UseCase: Presentation ↔ Domain ↔ Data (Repository + SwiftData Models) 레이어 조정
/// 뷰모델의 SwiftData ModelContext를 직접 만지지 않고 UseCase 경유 보장
/// 감정 필수 입력, 하루 1회 작성 등의 비즈니스 규칙을 여기서 강제
@MainActor
final class ReflectionUseCase: ObservableObject {
    private let repository: SwiftDataReflectionRepository
    private let dateManager = SafeDateManager.shared
    
    init(repository: SwiftDataReflectionRepository? = nil) {
        if let repository = repository {
            self.repository = repository
        } else {
            self.repository = SwiftDataReflectionRepository()
        }
    }
    
    // MARK: - Core Use Cases
    
    /// 회고 생성/수정 UseCase
    /// 비즈니스 규칙: 감정 필수, 내용 필수, 하루 1개 제한
    func createOrUpdateReflection(content: String, emotion: String, date: Date) -> Result<Reflection, ReflectionError> {
        return repository.createOrUpdate(content: content, emotion: emotion, date: date)
    }
    
    /// 회고 삭제 UseCase
    func deleteReflection(_ reflection: Reflection) -> Result<Void, ReflectionError> {
        return repository.delete(reflection: reflection)
    }
    
    /// 회고 수정 UseCase
    func updateReflection(_ reflection: Reflection, content: String, emotion: String) -> Result<Reflection, ReflectionError> {
        return repository.update(reflection: reflection, content: content, emotion: emotion)
    }
    
    // MARK: - Query Use Cases
    
    /// 특정 년월 회고 조회 UseCase
    func getReflections(forYear year: Int, month: Int) -> Result<[Reflection], ReflectionError> {
        return repository.fetchReflections(forYear: year, month: month)
    }
    
    /// 모든 회고 조회 UseCase
    func getAllReflections() -> Result<[Reflection], ReflectionError> {
        return repository.fetchAllReflections()
    }
    
    /// 오늘 회고 작성 여부 확인 UseCase
    func hasTodayReflection() -> Bool {
        return repository.hasReflectionForToday()
    }
    
    // MARK: - Analytics Use Cases
    
    /// 감정 통계 UseCase
    func getEmotionSummary(forYear year: Int, month: Int) -> [EmotionType: Int] {
        return repository.emotionSummary(forYear: year, month: month)
    }
    
    /// 지배적 감정과 메시지 UseCase
    func getDominantEmotionMessage(forYear year: Int, month: Int) -> (EmotionType?, String) {
        let summary = getEmotionSummary(forYear: year, month: month)
        guard let dominant = summary.max(by: { $0.value < $1.value })?.key else {
            return (nil, "이번 달에는 회고 데이터가 부족해요.")
        }

        let message: String
        switch dominant {
        case .happy:
            message = "기쁜 감정이 많았어요. \n 행복한 순간을 자주 기록해보세요!"
        case .tired:
            message = "피곤한 날이 많았네요. \n 충분한 휴식을 취해보는 건 어떨까요?"
        case .neutral:
            message = "담담한 하루들이 있었네요. \n 감정의 변화를 기록해보는 것도 좋아요."
        case .sad:
            message = "슬픈 날이 많았네요. \n 마음을 나눌 누군가와 대화를 해보세요."
        case .angry:
            message = "화가 났던 날이 많네요. \n 스트레스 해소 방법을 찾아보면 도움이 될 거예요."
        }

        return (dominant, message)
    }
    
    // MARK: - Migration Use Cases
    
    /// UserDefaults → SwiftData 마이그레이션 UseCase
    func migrateFromLegacyStorage() -> Result<Void, ReflectionError> {
        // UserDefaults에서 기존 데이터 불러오기
        guard let data = UserDefaults.standard.data(forKey: "reflections_key"),
              let legacyReflections = try? JSONDecoder().decode([LegacyReflection].self, from: data) else {
            print("📦 No legacy data to migrate")
            return .success(())
        }
        
        do {
            // Repository를 통해 직접 마이그레이션 실행
            for legacy in legacyReflections {
                let result = repository.createOrUpdate(
                    content: legacy.content, 
                    emotion: legacy.emotion, 
                    date: legacy.date
                )
                
                // 각 항목 마이그레이션 실패 시 전체 실패
                if case .failure(let error) = result {
                    print("❌ Migration failed for item: \(error)")
                    return .failure(error)
                }
            }
            
            // 마이그레이션 성공시 UserDefaults 정리
            markMigrationDone()
            print("✅ Migration completed successfully for \(legacyReflections.count) items")
            return .success(())
            
        } catch {
            return .failure(.saveFailed(error))
        }
    }
    
    /// 마이그레이션 완료 표시
    private func markMigrationDone() {
        UserDefaults.standard.set(true, forKey: "swiftdata_migration_done")
        UserDefaults.standard.set(Date(), forKey: "swiftdata_migration_date")
        // 기존 데이터는 백업 목적으로 즉시 삭제하지 않음
        // 사용자가 앱을 안정적으로 사용한 후 별도의 정리 기능으로 제거
    }
    
    /// 마이그레이션 완료 여부 확인
    func isMigrationDone() -> Bool {
        return UserDefaults.standard.bool(forKey: "swiftdata_migration_done")
    }
    
    /// 레거시 데이터 정리 (마이그레이션 완료 후 안정화 기간 경과 시 사용)
    func cleanupLegacyData() {
        UserDefaults.standard.removeObject(forKey: "reflections_key")
        print("🧹 Legacy data cleaned up")
    }
    
    /// 앱 안정화 확인 (마이그레이션 후 7일 경과 확인)
    func canCleanupLegacyData() -> Bool {
        guard isMigrationDone() else { return false }
        
        let migrationKey = "swiftdata_migration_date"
        let now = Date()
        
        if let migrationDate = UserDefaults.standard.object(forKey: migrationKey) as? Date {
            let daysPassed = Calendar.current.dateComponents([.day], from: migrationDate, to: now).day ?? 0
            return daysPassed >= 7  // 7일 경과 후 안전한 정리
        } else {
            // 마이그레이션 날짜 기록이 없는 경우 현재 날짜로 설정
            UserDefaults.standard.set(now, forKey: migrationKey)
            return false
        }
    }
    
    /// 자동 레거시 데이터 정리 (조건부)
    func autoCleanupIfSafe() {
        if canCleanupLegacyData() {
            cleanupLegacyData()
            UserDefaults.standard.removeObject(forKey: "swiftdata_migration_date")
            print("✅ Automatic legacy cleanup completed")
        }
    }
}

// MARK: - Legacy Data Models

/// 마이그레이션용 레거시 Reflection 모델
private struct LegacyReflection: Codable {
    let id: UUID
    let date: Date
    let emotion: String
    let content: String
    let order: Int
}