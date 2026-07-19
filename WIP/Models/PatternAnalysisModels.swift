import Foundation

// MARK: - Pattern Analysis Result Models

/// 감정 패턴 분석 결과
struct PatternAnalysisResult {
    let temporalPatterns: [TemporalPattern]
    let emotionalPatterns: [EmotionalPattern]
    let trendAnalysis: TrendAnalysis
    let personalBaseline: PersonalBaseline
    let insights: [PersonalizedInsight]
}

/// 시간 기반 패턴
struct TemporalPattern {
    let type: TemporalType
    let title: String
    let description: String
    let confidence: Double
    let timeframe: String
    let statistics: PatternStatistics
    
    enum TemporalType {
        case weekdayWeekend
        case timeOfDay
        case dayOfWeek
        case monthlyTrend
    }
}

/// 감정 기반 패턴
struct EmotionalPattern {
    let type: EmotionalType
    let title: String
    let description: String
    let confidence: Double
    let impact: String
    let recoveryTime: TimeInterval
    let triggerFactors: [String]
    
    enum EmotionalType {
        case recoveryPattern
        case stabilityPattern
        case volatilityPattern
        case dominantMood
    }
}

/// 트렌드 분석
struct TrendAnalysis {
    let overallTrend: TrendDirection
    let changeRate: Double
    let trendStrength: Double
    let prediction: String
    let seasonalEffects: [SeasonalEffect]
    
    enum TrendDirection {
        case improving
        case stable
        case declining
        
        var description: String {
            switch self {
            case .improving: return "개선되는 추세"
            case .stable: return "안정적인 상태"
            case .declining: return "주의가 필요한 상태"
            }
        }
    }
}

/// 개인 기준선
struct PersonalBaseline {
    let averageEmotion: Double
    let stabilityIndex: Double
    let recoveryRate: Double
    let lastUpdated: Date
}

/// 개인화된 인사이트
struct PersonalizedInsight {
    let category: String
    let title: String
    let message: String
    let actionable: Bool
    let priority: InsightPriority
    let evidence: [String]
    
    enum InsightPriority {
        case high
        case medium
        case low
    }
}

/// 패턴 통계
struct PatternStatistics {
    let frequency: Double
    let strength: Double
    let consistency: Double
    let sampleSize: Int
}

/// 계절적 효과
struct SeasonalEffect {
    let period: String
    let impact: Double
    let description: String
}

/// 감정 예측 (기존 EmotionPrediction과 구분)
struct EmotionPredictionResult {
    let nextWeek: Double
    let confidence: Double
    let factors: [String]
}