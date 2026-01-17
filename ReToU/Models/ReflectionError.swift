import Foundation

/// Domain 레벨에서 사용하는 회고 관련 에러
/// UI 레벨이 아닌 비즈니스 로직에서 검증 규칙을 강제
enum ReflectionError: LocalizedError {
    case emotionRequired
    case contentRequired
    case invalidContent(String)
    case duplicateEntry(String)
    case entryNotFound
    case saveFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .emotionRequired:
            return "감정을 선택해주세요"
        case .contentRequired:
            return "회고 내용을 입력해주세요"
        case .invalidContent(let message):
            return "잘못된 내용입니다: \(message)"
        case .duplicateEntry(let dateKey):
            return "해당 날짜(\(dateKey))에 이미 회고가 존재합니다"
        case .entryNotFound:
            return "회고를 찾을 수 없습니다"
        case .saveFailed(let error):
            return "저장에 실패했습니다: \(error.localizedDescription)"
        }
    }
    
    /// 사용자에게 보여줄 친화적인 메시지
    var userFriendlyMessage: String {
        switch self {
        case .emotionRequired:
            return "감정을 선택해주세요 😊"
        case .contentRequired:
            return "회고 내용을 입력해주세요 ✍️"
        case .invalidContent:
            return "올바른 내용을 입력해주세요"
        case .duplicateEntry:
            return "오늘 회고는 이미 작성되었습니다"
        case .entryNotFound:
            return "회고를 찾을 수 없습니다"
        case .saveFailed:
            return "저장 중 오류가 발생했습니다"
        }
    }
    
    /// 에러의 심각도
    var severity: ErrorSeverity {
        switch self {
        case .emotionRequired, .contentRequired:
            return .validation
        case .invalidContent:
            return .warning
        case .duplicateEntry, .entryNotFound:
            return .info
        case .saveFailed:
            return .error
        }
    }
}

enum ErrorSeverity {
    case validation  // 사용자 입력 검증
    case warning     // 주의 필요
    case info        // 정보성
    case error       // 시스템 오류
}