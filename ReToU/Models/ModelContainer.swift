import Foundation
import SwiftData

/// SwiftData 모델 컨테이너 관리
/// 앱 전체에서 단일 컨테이너 인스턴스를 공유하여 데이터 일관성 보장
/// iCloud(CloudKit) 동기화를 우선 시도하고, 불가하면 로컬 저장으로 폴백
final class DataContainer {
    static let shared = DataContainer()

    let container: ModelContainer
    /// 현재 iCloud 동기화가 활성화됐는지 (설정 화면 표시용)
    let isCloudSyncEnabled: Bool

    private init() {
        let schema = Schema([Reflection.self])

        // 1차: CloudKit 자동 동기화 (Apple ID 암묵 사용 — 로그인 UI 불필요)
        let cloudConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true,
            cloudKitDatabase: .automatic
        )

        if let cloudContainer = try? ModelContainer(for: schema, configurations: [cloudConfiguration]) {
            container = cloudContainer
            isCloudSyncEnabled = true
            return
        }

        // 2차: 로컬 전용 폴백 (iCloud 미로그인·엔타이틀먼트 문제 등에도 앱은 항상 동작)
        print("⚠️ CloudKit container unavailable — falling back to local-only storage")
        let localConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true,
            cloudKitDatabase: .none
        )

        do {
            container = try ModelContainer(for: schema, configurations: [localConfiguration])
            isCloudSyncEnabled = false
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    /// Preview용 private initializer
    private init(container: ModelContainer) {
        self.container = container
        self.isCloudSyncEnabled = false
    }

    /// 새로운 ModelContext 생성
    @MainActor
    func newContext() -> ModelContext {
        return ModelContext(container)
    }
}

/// Preview에서 사용할 인메모리 컨테이너
extension DataContainer {
    static let preview: DataContainer = {
        let schema = Schema([Reflection.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

        let container: ModelContainer
        do {
            container = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create preview ModelContainer: \(error)")
        }

        return DataContainer(container: container)
    }()
}
