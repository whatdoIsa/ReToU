import Foundation
import SwiftUI

// MARK: - AI Insights v2 Data Transfer Objects
// Contract 고정: 이후 티켓에서 변경 금지, 확장만 허용

// MARK: - AI용과 룰기반용 타입 구분을 위한 별칭
typealias AIInsightReportDTO = InsightReportDTO
typealias AIPatternDTO = PatternDTO
typealias AIActionDTO = ActionDTO

// MARK: - 인사이트 리포트 (구조화 출력용)
struct InsightReportDTO: Codable {
    let summary: [String] // 2문장으로 고정
    let patterns: [PatternDTO] // 최소 3개 이상
    let actions: [ActionDTO] // 최소 2개 이상
    let generatedAt: Date
    let analysisId: String // 유니크 식별자
    let confidence: Double // 0.0-1.0
    
    var isValid: Bool {
        return summary.count == 2 && 
               patterns.count >= 3 && 
               actions.count >= 2 &&
               confidence >= 0.0 && confidence <= 1.0
    }
}

// MARK: - 패턴 분석 데이터
struct PatternDTO: Codable {
    let type: PatternType
    let title: String
    let description: String
    let confidence: Double // 0.0-1.0
    let evidence: [String] // 근거 데이터
    let timeframe: PatternTimeframe
    let impact: PatternImpact
    
    var isSignificant: Bool {
        return confidence >= 0.7
    }
}

// MARK: - 액션 제안 데이터
struct ActionDTO: Codable {
    let id: String
    let category: ActionCategory
    let title: String
    let description: String
    let priority: ActionPriority
    let estimatedImpact: Double // 0.0-1.0
    let timeToImplement: ActionTimeframe
    let prerequisites: [String]
    
    var isHighPriority: Bool {
        return priority == .high || priority == .urgent
    }
}

// MARK: - 패턴 유형 (확장 가능하지만 기존 케이스 변경/삭제 금지)
enum PatternType: String, CaseIterable, Codable {
    case emotional = "emotional"
    case temporal = "temporal"
    case behavioral = "behavioral"
    case environmental = "environmental"
    case social = "social"
    case physical = "physical"
    case cognitive = "cognitive"
    
    var displayName: String {
        switch self {
        case .emotional: return "감정 패턴"
        case .temporal: return "시간 패턴"
        case .behavioral: return "행동 패턴"
        case .environmental: return "환경 패턴"
        case .social: return "사회적 패턴"
        case .physical: return "신체적 패턴"
        case .cognitive: return "인지 패턴"
        }
    }
}

// MARK: - 패턴 시간 범위 (확장 가능하지만 기존 케이스 변경/삭제 금지)
enum PatternTimeframe: String, CaseIterable, Codable {
    case daily = "daily"
    case weekly = "weekly"
    case monthly = "monthly"
    case seasonal = "seasonal"
    
    var displayName: String {
        switch self {
        case .daily: return "일간"
        case .weekly: return "주간"
        case .monthly: return "월간"
        case .seasonal: return "계절"
        }
    }
}

// MARK: - 패턴 영향도 (확장 가능하지만 기존 케이스 변경/삭제 금지)
enum PatternImpact: String, CaseIterable, Codable {
    case positive = "positive"
    case negative = "negative"
    case neutral = "neutral"
    case mixed = "mixed"
    
    var displayName: String {
        switch self {
        case .positive: return "긍정적"
        case .negative: return "부정적"
        case .neutral: return "중립적"
        case .mixed: return "혼합"
        }
    }
}

// MARK: - 액션 카테고리 (확장 가능하지만 기존 케이스 변경/삭제 금지)
enum ActionCategory: String, CaseIterable, Codable {
    case mindfulness = "mindfulness"
    case lifestyle = "lifestyle"
    case social = "social"
    case professional = "professional"
    case health = "health"
    case creative = "creative"
    case learning = "learning"
    
    var displayName: String {
        switch self {
        case .mindfulness: return "마음챙김"
        case .lifestyle: return "라이프스타일"
        case .social: return "사회적 관계"
        case .professional: return "업무"
        case .health: return "건강"
        case .creative: return "창의적 활동"
        case .learning: return "학습"
        }
    }
    
    var color: Color {
        switch self {
        case .mindfulness: return .purple
        case .lifestyle: return .green
        case .social: return .blue
        case .professional: return .orange
        case .health: return .red
        case .creative: return .pink
        case .learning: return .indigo
        }
    }
    
    var iconName: String {
        switch self {
        case .mindfulness: return "leaf.fill"
        case .lifestyle: return "house.fill"
        case .social: return "person.2.fill"
        case .professional: return "briefcase.fill"
        case .health: return "heart.fill"
        case .creative: return "paintbrush.fill"
        case .learning: return "book.fill"
        }
    }
}

// MARK: - 액션 우선순위 (확장 가능하지만 기존 케이스 변경/삭제 금지)
enum ActionPriority: String, CaseIterable, Codable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case urgent = "urgent"
    
    var displayName: String {
        switch self {
        case .low: return "낮음"
        case .medium: return "보통"
        case .high: return "높음"
        case .urgent: return "긴급"
        }
    }
    
    var sortOrder: Int {
        switch self {
        case .urgent: return 4
        case .high: return 3
        case .medium: return 2
        case .low: return 1
        }
    }
    
    var icon: String {
        switch self {
        case .urgent: return "exclamationmark.triangle.fill"
        case .high: return "exclamationmark.3"
        case .medium: return "exclamationmark.2"
        case .low: return "exclamationmark"
        }
    }
    
    var color: Color {
        switch self {
        case .urgent: return .red
        case .high: return .orange
        case .medium: return .yellow
        case .low: return .blue
        }
    }
}

// MARK: - 액션 실행 기간 (확장 가능하지만 기존 케이스 변경/삭제 금지)
enum ActionTimeframe: String, CaseIterable, Codable {
    case immediate = "immediate" // 즉시
    case shortTerm = "short_term" // 1주 이내
    case mediumTerm = "medium_term" // 1개월 이내
    case longTerm = "long_term" // 3개월 이내
    
    var displayName: String {
        switch self {
        case .immediate: return "즉시"
        case .shortTerm: return "1주 이내"
        case .mediumTerm: return "1개월 이내"
        case .longTerm: return "3개월 이내"
        }
    }
}

// MARK: - AI 분석 메타데이터
struct AIAnalysisMetadataDTO: Codable {
    let analysisId: String
    let version: String
    let model: String
    let generatedAt: Date
    let processingTimeSeconds: Double
    let dataPointsAnalyzed: Int
    let confidenceScore: Double
    
    var isHighQuality: Bool {
        return confidenceScore >= 0.8 && dataPointsAnalyzed >= 10
    }
}

// MARK: - 인사이트 생성 소스
enum InsightSource: String, Codable {
    case ai = "AI"
    case ruleBased = "RuleBased"
    case hybrid = "Hybrid"
}