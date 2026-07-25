import Foundation

// MARK: - Ticket 3 Analysis Helper Functions
// Provides utility functions for enhanced pattern analysis

/// Ticket 3용 분석 헬퍼 클래스
struct EmotionAnalysisHelper {
    
    // MARK: - Data Reliability Scoring
    
    /// 데이터 신뢰도 계산
    static func calculateDataReliability(recordDays: Int, totalDays: Int) -> DataReliabilityScore {
        return DataReliabilityScore(recordDays: recordDays, totalDays: totalDays)
    }
    
    /// 패턴 순위 생성
    static func generateTopPatterns(from patterns: [MockPattern], limit: Int = 2) -> [RankedPatternInfo] {
        return patterns
            .sorted { $0.confidence > $1.confidence }
            .prefix(limit)
            .enumerated()
            .map { index, pattern in
                RankedPatternInfo(
                    rank: index + 1,
                    title: "Top\(index + 1). \(pattern.title)",
                    confidence: pattern.confidence,
                    description: pattern.description,
                    type: pattern.type
                )
            }
    }
    
    /// 빈도 순위 생성 (감정 분포 기반)
    static func generateTopOccurrences(
        emotionCounts: [(emotion: String, count: Int, averageScore: Double)],
        limit: Int = 1
    ) -> [RankedPatternInfo] {
        return emotionCounts
            .sorted { $0.count > $1.count }
            .prefix(limit)
            .enumerated()
            .map { index, data in
                RankedPatternInfo(
                    rank: index + 1,
                    title: "Top\(index + 1). \(data.emotion) 감정 우세",
                    confidence: Double(data.count) / 31.0, // 31일 기준
                    description: "총 \(data.count)회 기록된 감정입니다 (평균 점수: \(String(format: "%.1f", data.averageScore)))",
                    type: "감정 빈도"
                )
            }
    }
    
    /// 기분 알림 생성
    static func generateMoodAlerts(
        recentMoodScores: [Double],
        monthlyScoreChange: Double?
    ) -> [EmotionAlertInfo] {
        var alerts: [EmotionAlertInfo] = []
        
        // 1. 연속 저조한 기분 체크
        let lowMoodCount = recentMoodScores.filter { $0 < -1.0 }.count
        let totalDays = recentMoodScores.count
        
        if totalDays > 0 && lowMoodCount >= totalDays / 2 {
            alerts.append(EmotionAlertInfo(
                type: "긴급",
                title: "기분 회복이 필요해요",
                message: "최근 \(totalDays)일 중 \(lowMoodCount)일이 저조한 기분이었습니다.",
                actionSuggestion: "전문가와 상담하거나 스트레스 관리가 필요할 수 있습니다.",
                icon: "exclamationmark.triangle.fill",
                color: "#FF3B30"
            ))
        }
        
        // 2. 월별 평균 하락 체크
        if let scoreChange = monthlyScoreChange, scoreChange < -1.0 {
            alerts.append(EmotionAlertInfo(
                type: "경고",
                title: "전월 대비 기분 하락 주의",
                message: "이번 달 평균 기분이 전월보다 \(String(format: "%.1f", abs(scoreChange)))점 낮습니다.",
                actionSuggestion: "규칙적인 운동이나 취미 활동을 늘려보세요.",
                icon: "exclamationmark.circle.fill",
                color: "#FF8C00"
            ))
        }
        
        return alerts
    }
    
    /// 데이터 품질 알림 생성
    static func generateDataQualityAlerts(completionRate: Double) -> [EmotionAlertInfo] {
        var alerts: [EmotionAlertInfo] = []
        
        if completionRate < 0.4 {
            alerts.append(EmotionAlertInfo(
                type: "정보",
                title: "기록 데이터 부족",
                message: "더 정확한 분석을 위해 꾸준한 기록이 필요합니다.",
                actionSuggestion: "매일 짧은 회고라도 기록해보세요.",
                icon: "info.circle",
                color: "#007AFF"
            ))
        }
        
        return alerts
    }
    
    /// 관찰 텍스트 생성
    static func generateObservationText(
        completionRate: Double,
        dominantEmotion: String?
    ) -> String {
        let qualifier: String
        switch completionRate {
        case 0.8...: qualifier = "확신"
        case 0.6..<0.8: qualifier = "추정"
        default: qualifier = "불확실"
        }
        
        let emotionText = dominantEmotion ?? "다양한"
        return "(\(qualifier)) \"\(emotionText)한 기분을 보입니다\""
    }
    
    /// 추정 텍스트 생성
    static func generateEstimationText(
        completionRate: Double,
        recordDays: Int,
        improvement: Double?
    ) -> String {
        let qualifier: String
        switch completionRate {
        case 0.8...: qualifier = "확신"
        case 0.6..<0.8: qualifier = "추정"
        default: qualifier = "불확실"
        }
        
        if let improvement = improvement, improvement > 0 {
            return "(\(qualifier)) \"현재 기록(\(recordDays)일) 기준으로 안정 상태가 올라가고 있습니다. 기록이 늘면 정확도가 올라가요.\""
        } else {
            return "(\(qualifier)) \"현재 기록으로는 안정적인 패턴을 파악하기 어렵습니다. 꾸준한 기록이 필요합니다.\""
        }
    }
}

// MARK: - Supporting Types

/// Mock 패턴 (임시 데모용)
struct MockPattern {
    let title: String
    let description: String
    let confidence: Double
    let type: String
}

/// 순위가 매겨진 패턴 정보
struct RankedPatternInfo: Identifiable {
    let id = UUID()
    let rank: Int
    let title: String
    let confidence: Double
    let description: String
    let type: String
    
    var formattedScore: String {
        if confidence < 1.0 {
            return String(format: "신뢰도: %.0f%%", confidence * 100)
        } else {
            return "빈도: \(Int(confidence))회"
        }
    }
}

/// 감정 알림 정보
struct EmotionAlertInfo: Identifiable {
    let id = UUID()
    let type: String
    let title: String
    let message: String
    let actionSuggestion: String
    let icon: String
    let color: String
}

/// 데이터 신뢰도 점수
struct DataReliabilityScore {
    let recordDays: Int
    let totalDays: Int
    let completionRate: Double
    let qualityLevel: String
    let confidenceScore: Double
    
    init(recordDays: Int, totalDays: Int) {
        self.recordDays = recordDays
        self.totalDays = totalDays
        self.completionRate = Double(recordDays) / Double(totalDays)
        
        switch completionRate {
        case 0.8...:
            self.qualityLevel = "우수"
            self.confidenceScore = 0.9
        case 0.6..<0.8:
            self.qualityLevel = "양호"
            self.confidenceScore = 0.7
        case 0.4..<0.6:
            self.qualityLevel = "보통"
            self.confidenceScore = 0.5
        default:
            self.qualityLevel = "제한적"
            self.confidenceScore = 0.3
        }
    }
    
    var description: String {
        switch qualityLevel {
        case "우수": return "충분한 데이터로 신뢰도 높은 분석"
        case "양호": return "양호한 데이터로 의미있는 분석"
        case "보통": return "기본적인 데이터로 제한적 분석"
        default: return "데이터 부족으로 참고용 분석"
        }
    }
    
    var color: String {
        switch qualityLevel {
        case "우수": return "#32CD32"
        case "양호": return "#FFD700"
        case "보통": return "#FF8C00"
        default: return "#FF6B35"
        }
    }
}

/// 통합된 향상된 분석 결과 (Ticket 3 최종)
struct EnhancedAnalysisResult {
    let dataReliability: DataReliabilityScore
    let topPatterns: [RankedPatternInfo]
    let topOccurrences: [RankedPatternInfo]
    let alerts: [EmotionAlertInfo]
    let observationText: String
    let estimationText: String
    
    /// 전체적인 신뢰도 요약
    var overallConfidence: String {
        return "\(dataReliability.qualityLevel) (\(String(format: "%.0f%%", dataReliability.confidenceScore * 100)))"
    }
    
    /// 중요한 알림만 필터링
    var importantAlerts: [EmotionAlertInfo] {
        return alerts.filter { $0.type == "긴급" || $0.type == "경고" }
    }
}