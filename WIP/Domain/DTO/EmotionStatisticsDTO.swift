import Foundation

// MARK: - EmotionStatisticsDTO
// Expert System에서 사용하는 통계 데이터 전용 DTO
// StatsDataDTO와 호환되도록 설계된 어댑터 역할

struct EmotionStatisticsDTO {
    let totalEntries: Int
    let emotionCounts: [EmotionType: Int]
    let averageScore: Double
    let previousPeriodAverage: Double?
    
    // MARK: - StatsDataDTO 변환 생성자
    init(from statsData: StatsDataDTO) {
        self.totalEntries = statsData.summary.totalReflections
        self.averageScore = statsData.summary.averageScore
        self.previousPeriodAverage = statsData.monthComparison?.previousMonth?.averageScore
        
        // 감정별 카운트 변환
        var counts: [EmotionType: Int] = [:]
        for item in statsData.emotionDistribution {
            counts[item.emotion] = item.count
        }
        self.emotionCounts = counts
    }
    
    // MARK: - 직접 생성자 (테스트 및 레거시 호환용)
    init(totalEntries: Int, emotionCounts: [EmotionType: Int], averageScore: Double, previousPeriodAverage: Double? = nil) {
        self.totalEntries = totalEntries
        self.emotionCounts = emotionCounts
        self.averageScore = averageScore
        self.previousPeriodAverage = previousPeriodAverage
    }
    
    // MARK: - 편의 프로퍼티
    var isEmpty: Bool {
        return totalEntries == 0
    }
    
    var hasValidData: Bool {
        return totalEntries > 0 && !emotionCounts.isEmpty
    }
    
    // MARK: - 감정별 접근자
    func count(for emotion: EmotionType) -> Int {
        return emotionCounts[emotion] ?? 0
    }
    
    func percentage(for emotion: EmotionType) -> Double {
        guard totalEntries > 0 else { return 0.0 }
        return Double(count(for: emotion)) / Double(totalEntries) * 100.0
    }
    
    // MARK: - 통계 계산
    var dominantEmotion: EmotionType? {
        return emotionCounts.max { $0.value < $1.value }?.key
    }
    
    var emotionVariety: Int {
        return emotionCounts.filter { $0.value > 0 }.count
    }
    
    var hasPositiveTrend: Bool {
        guard let previous = previousPeriodAverage else { return averageScore > 3.0 }
        return averageScore > previous
    }
}

// MARK: - EmotionStatisticsDTO Factory
// StatsDataDTO를 EmotionStatisticsDTO로 변환하는 팩토리
struct EmotionStatisticsDTOFactory {
    
    static func create(from statsData: StatsDataDTO) -> EmotionStatisticsDTO {
        return EmotionStatisticsDTO(from: statsData)
    }
    
    static func createEmpty() -> EmotionStatisticsDTO {
        return EmotionStatisticsDTO(
            totalEntries: 0,
            emotionCounts: [:],
            averageScore: 0.0,
            previousPeriodAverage: nil
        )
    }
    
    static func createSample() -> EmotionStatisticsDTO {
        let emotionCounts: [EmotionType: Int] = [
            .happy: 8,
            .neutral: 12,
            .tired: 6,
            .sad: 3,
            .angry: 1
        ]
        
        return EmotionStatisticsDTO(
            totalEntries: 30,
            emotionCounts: emotionCounts,
            averageScore: 3.2,
            previousPeriodAverage: 2.8
        )
    }
}

// MARK: - Extension for Validation
extension EmotionStatisticsDTO {
    
    func validate() -> [String] {
        var issues: [String] = []
        
        if totalEntries < 0 {
            issues.append("총 기록 수는 0 이상이어야 합니다")
        }
        
        if averageScore < 0 || averageScore > 5 {
            issues.append("평균 점수는 0-5 범위여야 합니다")
        }
        
        let emotionSum = emotionCounts.values.reduce(0, +)
        if emotionSum != totalEntries {
            issues.append("감정별 카운트 합계가 총 기록 수와 일치하지 않습니다")
        }
        
        return issues
    }
    
    var isValid: Bool {
        return validate().isEmpty
    }
}