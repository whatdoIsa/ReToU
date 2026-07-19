import Foundation

// MARK: - Stats v2 Data Transfer Objects
// Contract 고정: 이후 티켓에서 변경 금지, 확장만 허용

// MARK: - 월별 요약 데이터
struct MonthlySummaryDTO {
    let year: Int
    let month: Int
    let totalReflections: Int
    let averageScore: Double
    let dominantEmotion: EmotionType?
    let improvementFromPreviousMonth: Double?
    let streakDays: Int
    let reflectionDays: Int
    let totalDaysInMonth: Int
    let stabilityScore: Double  // 감정 안정성 점수 (0.0-5.0)
    
    var completionRate: Double {
        return totalDaysInMonth > 0 ? Double(reflectionDays) / Double(totalDaysInMonth) : 0.0
    }
}

// MARK: - 감정 분포 데이터 (5단계 고정, 0 포함)
struct EmotionDistributionItemDTO {
    let emotion: EmotionType
    let count: Int
    let percentage: Double
    let averageScore: Double
    
    // 0 포함 5단계로 고정
    static let supportedEmotions: [EmotionType] = [.happy, .tired, .neutral, .sad, .angry]
}

// MARK: - 일별 기분 점수 데이터
struct DailyMoodPointDTO {
    let dateKey: String // "yyyy-MM-dd" format
    let score: Double
    let emotion: EmotionType
    let hasReflection: Bool
    
    var date: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateKey)
    }
}

// MARK: - 히트맵 일별 데이터
struct HeatmapDayDTO {
    let dateKey: String // "yyyy-MM-dd" format
    let emotion: EmotionType?
    let hasReflection: Bool
    let score: Double?
    
    var date: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateKey)
    }
}

// MARK: - 요일별 통계 데이터
struct WeekdayStatDTO {
    let weekday: Int // 1=일요일, 7=토요일
    let averageScore: Double
    let reflectionCount: Int
    let dominantEmotion: EmotionType?
    
    var weekdayName: String {
        let weekdayNames = ["", "일", "월", "화", "수", "목", "금", "토"]
        return weekdayNames[weekday]
    }
}

// MARK: - 월별 비교 데이터
struct MonthComparisonDTO {
    let currentMonth: MonthlySummaryDTO
    let previousMonth: MonthlySummaryDTO?
    
    // 전월 대비 변화량들
    let scoreChange: Double?
    let reflectionCountChange: Int?
    let completionRateChange: Double?
    let streakChange: Int?
    
    var hasImprovement: Bool {
        return (scoreChange ?? 0) > 0
    }
    
    var improvementPercentage: Double? {
        guard let change = scoreChange,
              let previous = previousMonth,
              previous.averageScore != 0 else { return nil }
        return (change / previous.averageScore) * 100
    }
}

// MARK: - 전체 통계 컨테이너
struct StatsDataDTO {
    let summary: MonthlySummaryDTO
    let emotionDistribution: [EmotionDistributionItemDTO]
    let dailyMoodPoints: [DailyMoodPointDTO]
    let heatmapDays: [HeatmapDayDTO]
    let weekdayStats: [WeekdayStatDTO]
    let monthComparison: MonthComparisonDTO?
    
    // 데이터 유효성 검증
    var isValid: Bool {
        return !dailyMoodPoints.isEmpty && !emotionDistribution.isEmpty
    }
}