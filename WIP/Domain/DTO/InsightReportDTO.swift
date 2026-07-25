import Foundation

// MARK: - Rule-Based Insight Data Contracts
// 이 파일은 룰 기반 인사이트용 간단한 타입들을 정의
// AI Insights용 완전한 타입은 AIInsightsDataContracts.swift 참조

// 룰 기반 인사이트용 간단한 패턴 타입 (AI용과는 별개)
enum RuleBasedPatternType: String, CaseIterable {
    case emotional = "감정"
    case lifestyle = "라이프스타일"
}

// 룰 기반 인사이트용 신뢰도 (AI용과는 별개)
enum RuleBasedPatternConfidence: String, CaseIterable {
    case high = "높음"
    case medium = "보통"
    case low = "낮음"
}

// 룰 기반 인사이트용 액션 타입 (AI용과는 별개)
enum RuleBasedActionType: String, CaseIterable {
    case habit = "습관"
    case wellness = "웰빙"
    case lifestyle = "라이프스타일"
}

// 룰 기반 인사이트용 우선순위 (AI용과는 별개)
enum RuleBasedActionPriority: String, CaseIterable {
    case high = "높음"
    case medium = "보통"
    case low = "낮음"
}

// 룰 기반 패턴 시간 범위
enum RuleBasedPatternTimeframe: String, CaseIterable {
    case daily = "일간"
    case weekly = "주간" 
    case monthly = "월간"
}

// 룰 기반 패턴 영향도
enum RuleBasedPatternImpact: String, CaseIterable {
    case positive = "긍정적"
    case negative = "부정적"
    case mixed = "혼합"
}

// 룰 기반 액션 카테고리
enum RuleBasedActionCategory: String, CaseIterable {
    case mindfulness = "마음챙김"
    case lifestyle = "라이프스타일"
}

// 룰 기반 액션 실행 기간
enum RuleBasedActionTimeframe: String, CaseIterable {
    case immediate = "즉시"
    case shortTerm = "단기"
    case mediumTerm = "중기"
}

// DataQuality는 AIInsightsDTO.swift와 공유
// (이미 정의되어 있으므로 여기서는 제거)

// 룰 기반 인사이트용 패턴 DTO
struct RuleBasedPatternDTO {
    let id: UUID
    let title: String
    let description: String
    let type: RuleBasedPatternType
    let confidence: RuleBasedPatternConfidence
    let evidence: [String]
    let timeframe: RuleBasedPatternTimeframe
    let impact: RuleBasedPatternImpact
}

// 룰 기반 인사이트용 액션 DTO
struct RuleBasedActionDTO {
    let id: String
    let title: String
    let description: String
    let category: RuleBasedActionCategory
    let priority: RuleBasedActionPriority
    let estimatedImpact: Double
    let timeToImplement: RuleBasedActionTimeframe
    let prerequisites: [String]
}

// 룰 기반 인사이트 리포트 DTO
struct RuleBasedInsightReportDTO {
    let summary: [String]
    let patterns: [RuleBasedPatternDTO]
    let actions: [RuleBasedActionDTO]
    let generatedAt: Date
    let dataQuality: DataQuality  // AIInsightsDTO.swift에서 가져옴
}