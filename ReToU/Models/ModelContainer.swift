import Foundation
import SwiftData

/// SwiftData 모델 컨테이너 관리
/// 앱 전체에서 단일 컨테이너 인스턴스를 공유하여 데이터 일관성 보장
final class DataContainer {
    static let shared = DataContainer()
    
    let container: ModelContainer
    
    private init() {
        let schema = Schema([Reflection.self])
        
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true,
            cloudKitDatabase: .none // CloudKit 연동 필요시 변경
        )
        
        do {
            container = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
    
    /// Preview용 private initializer
    private init(container: ModelContainer) {
        self.container = container
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