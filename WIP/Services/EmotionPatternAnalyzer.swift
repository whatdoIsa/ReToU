import Foundation
import SwiftData

/// 실제 사용자 데이터 기반 감정 패턴 분석기
@MainActor
final class EmotionPatternAnalyzer: ObservableObject {
    
    private let dateManager = SafeDateManager.shared
    
    /// 실제 사용자 데이터 기반 패턴 분석
    func analyzePatterns(reflections: [Reflection], year: Int, month: Int) async -> PatternAnalysisResult {
        let filteredReflections = filterReflections(reflections, year: year, month: month)
        
        guard !filteredReflections.isEmpty else {
            return createMinimalAnalysis()
        }
        
        let temporalPatterns = analyzeTemporalPatterns(filteredReflections)
        let emotionalPatterns = analyzeEmotionalPatterns(filteredReflections)
        let trendAnalysis = analyzeTrends(filteredReflections)
        let personalBaseline = calculatePersonalBaseline(filteredReflections)
        let insights = generatePersonalizedInsights(
            temporalPatterns: temporalPatterns,
            emotionalPatterns: emotionalPatterns,
            trendAnalysis: trendAnalysis,
            baseline: personalBaseline
        )
        
        return PatternAnalysisResult(
            temporalPatterns: temporalPatterns,
            emotionalPatterns: emotionalPatterns,
            trendAnalysis: trendAnalysis,
            personalBaseline: personalBaseline,
            insights: insights
        )
    }
    
    /// 향상된 패턴 분석 (순위/알림/품질 시스템 통합) - Ticket 3
    func analyzeEnhancedPatterns(from stats: StatsDataDTO) async -> EnhancedAnalysisResult {
        // 1. 데이터 신뢰도 평가
        let dataReliability = EmotionAnalysisHelper.calculateDataReliability(
            recordDays: stats.summary.reflectionDays,
            totalDays: stats.summary.totalDaysInMonth
        )
        
        // 2. Mock 패턴 생성 및 순위 매기기
        let mockPatterns = generateMockPatternsForDemo(from: stats, reliability: dataReliability)
        let topPatterns = EmotionAnalysisHelper.generateTopPatterns(from: mockPatterns, limit: 2)
        
        // 3. 감정 분포 기반 빈도 순위 생성
        let emotionCounts = stats.emotionDistribution.map { distribution in
            (emotion: distribution.emotion.rawValue, count: distribution.count, averageScore: distribution.averageScore)
        }
        let topOccurrences = EmotionAnalysisHelper.generateTopOccurrences(emotionCounts: emotionCounts, limit: 1)
        
        // 4. 알림 생성
        let recentMoodScores = Array(stats.dailyMoodPoints.prefix(6).map { $0.score })
        let moodAlerts = EmotionAnalysisHelper.generateMoodAlerts(
            recentMoodScores: recentMoodScores,
            monthlyScoreChange: stats.monthComparison?.scoreChange
        )
        let dataQualityAlerts = EmotionAnalysisHelper.generateDataQualityAlerts(
            completionRate: dataReliability.completionRate
        )
        let allAlerts = moodAlerts + dataQualityAlerts
        
        // 5. 문서 템플릿 생성
        let observationText = EmotionAnalysisHelper.generateObservationText(
            completionRate: dataReliability.completionRate,
            dominantEmotion: stats.summary.dominantEmotion?.rawValue
        )
        let estimationText = EmotionAnalysisHelper.generateEstimationText(
            completionRate: dataReliability.completionRate,
            recordDays: stats.summary.reflectionDays,
            improvement: stats.summary.improvementFromPreviousMonth
        )
        
        return EnhancedAnalysisResult(
            dataReliability: dataReliability,
            topPatterns: topPatterns,
            topOccurrences: topOccurrences,
            alerts: allAlerts,
            observationText: observationText,
            estimationText: estimationText
        )
    }
    
    /// Mock 패턴 생성 (데모 용도)
    private func generateMockPatternsForDemo(from stats: StatsDataDTO, reliability: DataReliabilityScore) -> [MockPattern] {
        var patterns: [MockPattern] = []
        
        // 감정 안정성 패턴
        patterns.append(MockPattern(
            title: "감정 안정성",
            description: "이번 달 전체적으로 \(reliability.qualityLevel) 수준의 감정 안정성을 보입니다",
            confidence: reliability.confidenceScore,
            type: "감정 패턴"
        ))
        
        // 시간 패턴
        if !stats.weekdayStats.isEmpty {
            patterns.append(MockPattern(
                title: "주중 기분 패턴",
                description: "특정 요일에 더 나은/낮은 기분을 보이는 패턴이 있습니다",
                confidence: 0.7,
                type: "시간 패턴"
            ))
        }
        
        // 개선 추세 패턴
        if let improvement = stats.summary.improvementFromPreviousMonth, improvement > 0 {
            patterns.append(MockPattern(
                title: "개선 추세",
                description: "전월 대비 평균 \(String(format: "%.1f", improvement))점 향상되었습니다",
                confidence: 0.8,
                type: "행동 패턴"
            ))
        }
        
        return patterns
    }
    
    private func filterReflections(_ reflections: [Reflection], year: Int, month: Int) -> [Reflection] {
        guard let dateRange = dateManager.dateRange(for: year, month: month) else {
            return []
        }
        
        return reflections.filter { reflection in
            reflection.date >= dateRange.start && reflection.date <= dateRange.end
        }.sorted { $0.date < $1.date }
    }
    
    private func analyzeTemporalPatterns(_ reflections: [Reflection]) -> [TemporalPattern] {
        var patterns: [TemporalPattern] = []
        
        // 주중 vs 주말 패턴
        let weekdayWeekendPattern = analyzeWeekdayWeekendPattern(reflections)
        if weekdayWeekendPattern.confidence > 0.6 {
            patterns.append(weekdayWeekendPattern)
        }
        
        // 요일별 패턴
        let dayOfWeekPattern = analyzeDayOfWeekPattern(reflections)
        if dayOfWeekPattern.confidence > 0.6 {
            patterns.append(dayOfWeekPattern)
        }
        
        return patterns
    }
    
    private func analyzeWeekdayWeekendPattern(_ reflections: [Reflection]) -> TemporalPattern {
        let calendar = Calendar.current
        var weekdayEmotions: [Double] = []
        var weekendEmotions: [Double] = []
        
        for reflection in reflections {
            let emotionScore = emotionToScore(reflection.emotion)
            let dayOfWeek = calendar.component(.weekday, from: reflection.date)
            
            if dayOfWeek == 1 || dayOfWeek == 7 { // 주말 (일요일=1, 토요일=7)
                weekendEmotions.append(emotionScore)
            } else { // 평일
                weekdayEmotions.append(emotionScore)
            }
        }
        
        let weekdayAvg = weekdayEmotions.isEmpty ? 0 : weekdayEmotions.reduce(0, +) / Double(weekdayEmotions.count)
        let weekendAvg = weekendEmotions.isEmpty ? 0 : weekendEmotions.reduce(0, +) / Double(weekendEmotions.count)
        let difference = abs(weekendAvg - weekdayAvg)
        
        let confidence = min(difference / 2.0, 1.0) // 차이가 클수록 높은 신뢰도
        
        let description: String
        if weekendAvg > weekdayAvg {
            description = "주말에 평일보다 평균 \(String(format: "%.1f", difference))점 더 긍정적인 감정을 경험합니다. 휴식과 여가가 감정에 긍정적 영향을 미치고 있습니다."
        } else if weekdayAvg > weekendAvg {
            description = "평일에 주말보다 평균 \(String(format: "%.1f", difference))점 더 긍정적인 감정을 보입니다. 규칙적인 일상이 안정감을 제공하는 것으로 보입니다."
        } else {
            description = "주중과 주말의 감정 상태가 비슷하여 일관된 감정 패턴을 유지하고 있습니다."
        }
        
        return TemporalPattern(
            type: .weekdayWeekend,
            title: "주중 vs 주말 패턴",
            description: description,
            confidence: confidence,
            timeframe: "주간",
            statistics: PatternStatistics(
                frequency: 1.0,
                strength: difference,
                consistency: confidence,
                sampleSize: weekdayEmotions.count + weekendEmotions.count
            )
        )
    }
    
    private func analyzeDayOfWeekPattern(_ reflections: [Reflection]) -> TemporalPattern {
        let calendar = Calendar.current
        var dayAverages: [Int: Double] = [:]
        var dayCounts: [Int: Int] = [:]
        
        for reflection in reflections {
            let emotionScore = emotionToScore(reflection.emotion)
            let dayOfWeek = calendar.component(.weekday, from: reflection.date)
            
            dayAverages[dayOfWeek] = (dayAverages[dayOfWeek] ?? 0) + emotionScore
            dayCounts[dayOfWeek] = (dayCounts[dayOfWeek] ?? 0) + 1
        }
        
        // 평균 계산
        for day in dayAverages.keys {
            if let count = dayCounts[day], count > 0 {
                dayAverages[day] = dayAverages[day]! / Double(count)
            }
        }
        
        let dayNames = ["", "일요일", "월요일", "화요일", "수요일", "목요일", "금요일", "토요일"]
        let sortedDays = dayAverages.sorted { $0.value < $1.value }
        
        guard let lowest = sortedDays.first,
              let highest = sortedDays.last,
              sortedDays.count >= 3 else {
            return TemporalPattern(
                type: .dayOfWeek,
                title: "요일별 패턴",
                description: "요일별 패턴을 분석하기에 데이터가 부족합니다.",
                confidence: 0.3,
                timeframe: "주간",
                statistics: PatternStatistics(frequency: 0, strength: 0, consistency: 0, sampleSize: reflections.count)
            )
        }
        
        let difference = highest.value - lowest.value
        let confidence = min(difference / 2.0, 1.0)
        
        let description = "\(dayNames[highest.key])에 가장 긍정적(\(String(format: "%.1f", highest.value))점)이고, \(dayNames[lowest.key])에 가장 낮은(\(String(format: "%.1f", lowest.value))점) 감정 상태를 보입니다."
        
        return TemporalPattern(
            type: .dayOfWeek,
            title: "요일별 감정 패턴",
            description: description,
            confidence: confidence,
            timeframe: "주간",
            statistics: PatternStatistics(
                frequency: 1.0,
                strength: difference,
                consistency: confidence,
                sampleSize: reflections.count
            )
        )
    }
    
    private func analyzeEmotionalPatterns(_ reflections: [Reflection]) -> [EmotionalPattern] {
        var patterns: [EmotionalPattern] = []
        
        // 감정 회복 패턴 분석
        let recoveryPattern = analyzeRecoveryPattern(reflections)
        patterns.append(recoveryPattern)
        
        // 감정 안정성 패턴 분석
        let stabilityPattern = analyzeStabilityPattern(reflections)
        patterns.append(stabilityPattern)
        
        return patterns
    }
    
    private func analyzeRecoveryPattern(_ reflections: [Reflection]) -> EmotionalPattern {
        var recoveryTimes: [TimeInterval] = []
        
        for i in 0..<reflections.count - 1 {
            let current = reflections[i]
            let currentScore = emotionToScore(current.emotion)
            
            if currentScore < 0 { // 부정적 감정
                // 다음 긍정적/중립 감정까지의 시간 계산
                for j in (i+1)..<reflections.count {
                    let next = reflections[j]
                    let nextScore = emotionToScore(next.emotion)
                    
                    if nextScore >= 0 { // 중립/긍정적 감정
                        let recoveryTime = next.date.timeIntervalSince(current.date)
                        recoveryTimes.append(recoveryTime)
                        break
                    }
                }
            }
        }
        
        let avgRecoveryTime = recoveryTimes.isEmpty ? 0 : recoveryTimes.reduce(0, +) / Double(recoveryTimes.count)
        let avgRecoveryDays = avgRecoveryTime / (24 * 60 * 60)
        
        let confidence = recoveryTimes.count >= 3 ? 0.8 : Double(recoveryTimes.count) / 3.0
        
        let description: String
        let impact: String
        if avgRecoveryDays <= 1 {
            description = "부정적 감정에서 평균 \(String(format: "%.1f", avgRecoveryDays))일 만에 회복하는 빠른 회복력을 보입니다."
            impact = "높음"
        } else if avgRecoveryDays <= 3 {
            description = "부정적 감정에서 평균 \(String(format: "%.1f", avgRecoveryDays))일 만에 회복하는 적절한 회복력을 보입니다."
            impact = "보통"
        } else {
            description = "부정적 감정에서 평균 \(String(format: "%.1f", avgRecoveryDays))일이 걸려 회복하므로 감정 관리 전략이 도움이 될 수 있습니다."
            impact = "낮음"
        }
        
        return EmotionalPattern(
            type: .recoveryPattern,
            title: "감정 회복 패턴",
            description: description,
            confidence: confidence,
            impact: impact,
            recoveryTime: avgRecoveryTime,
            triggerFactors: ["시간 경과", "자연 회복"]
        )
    }
    
    private func analyzeStabilityPattern(_ reflections: [Reflection]) -> EmotionalPattern {
        let emotionScores = reflections.map { emotionToScore($0.emotion) }
        let average = emotionScores.reduce(0, +) / Double(emotionScores.count)
        
        // 표준편차 계산
        let variance = emotionScores.map { pow($0 - average, 2) }.reduce(0, +) / Double(emotionScores.count)
        let standardDeviation = sqrt(variance)
        
        // 안정성 지수 (낮은 표준편차 = 높은 안정성)
        let stabilityIndex = max(0, 1 - (standardDeviation / 3.0)) // 3.0은 최대 가능 편차
        
        let description: String
        let impact: String
        if stabilityIndex > 0.7 {
            description = "감정 변화가 적고 안정적인 상태를 유지합니다. 감정 조절 능력이 우수합니다."
            impact = "긍정적"
        } else if stabilityIndex > 0.4 {
            description = "감정 변화가 보통 수준으로, 때때로 기복이 있지만 전반적으로 관리 가능한 범위입니다."
            impact = "보통"
        } else {
            description = "감정 변화가 크고 기복이 심합니다. 감정 안정성을 높이는 방법을 고려해보세요."
            impact = "주의필요"
        }
        
        return EmotionalPattern(
            type: .stabilityPattern,
            title: "감정 안정성 패턴",
            description: description,
            confidence: 0.8,
            impact: impact,
            recoveryTime: 0,
            triggerFactors: ["개인적 성향", "환경적 요인"]
        )
    }
    
    private func analyzeTrends(_ reflections: [Reflection]) -> TrendAnalysis {
        let emotionScores = reflections.map { emotionToScore($0.emotion) }
        
        // 선형 회귀를 통한 트렌드 분석
        let (slope, _) = calculateLinearRegression(emotionScores)
        
        let trendDirection: TrendAnalysis.TrendDirection
        let trendStrength = abs(slope)
        let changeRate = slope * 100 // 백분율 변화율
        
        if slope > 0.1 {
            trendDirection = .improving
        } else if slope < -0.1 {
            trendDirection = .declining
        } else {
            trendDirection = .stable
        }
        
        // 예측 생성
        let prediction = generatePredictionString(scores: emotionScores, trend: slope)
        
        return TrendAnalysis(
            overallTrend: trendDirection,
            changeRate: changeRate,
            trendStrength: trendStrength,
            prediction: prediction,
            seasonalEffects: []
        )
    }
    
    private func calculatePersonalBaseline(_ reflections: [Reflection]) -> PersonalBaseline {
        let emotionScores = reflections.map { emotionToScore($0.emotion) }
        let average = emotionScores.reduce(0, +) / Double(emotionScores.count)
        
        // 안정성 지수 계산
        let variance = emotionScores.map { pow($0 - average, 2) }.reduce(0, +) / Double(emotionScores.count)
        let stabilityIndex = max(0, 1 - (sqrt(variance) / 3.0))
        
        // 회복률 계산 (임시)
        let recoveryRate = 0.7 // 추후 실제 회복 패턴 분석으로 대체
        
        return PersonalBaseline(
            averageEmotion: average,
            stabilityIndex: stabilityIndex,
            recoveryRate: recoveryRate,
            lastUpdated: Date()
        )
    }
    
    private func generatePersonalizedInsights(
        temporalPatterns: [TemporalPattern],
        emotionalPatterns: [EmotionalPattern],
        trendAnalysis: TrendAnalysis,
        baseline: PersonalBaseline
    ) -> [PersonalizedInsight] {
        var insights: [PersonalizedInsight] = []
        
        // 시간 패턴 기반 인사이트
        for pattern in temporalPatterns {
            if pattern.confidence > 0.7 {
                let insight = PersonalizedInsight(
                    category: "시간패턴",
                    title: "시간 패턴 활용하기",
                    message: "\(pattern.title)을 활용하여 감정 관리를 최적화할 수 있습니다. \(pattern.description)",
                    actionable: true,
                    priority: .high,
                    evidence: ["패턴 신뢰도: \(String(format: "%.1f", pattern.confidence * 100))%"]
                )
                insights.append(insight)
            }
        }
        
        // 감정 패턴 기반 인사이트
        for pattern in emotionalPatterns {
            if pattern.confidence > 0.6 {
                let insight = PersonalizedInsight(
                    category: "감정패턴",
                    title: "감정 관리 개선점",
                    message: pattern.description,
                    actionable: true,
                    priority: pattern.type == .recoveryPattern ? .high : .medium,
                    evidence: ["분석 데이터: \(pattern.description)"]
                )
                insights.append(insight)
            }
        }
        
        // 트렌드 기반 인사이트
        if trendAnalysis.trendStrength > 0.3 {
            let trendInsight = PersonalizedInsight(
                category: "트렌드",
                title: "전체적인 변화 추세",
                message: generateTrendInsightDescription(trendAnalysis),
                actionable: true,
                priority: .medium,
                evidence: ["트렌드 강도: \(String(format: "%.1f", trendAnalysis.trendStrength))"]
            )
            insights.append(trendInsight)
        }
        
        return insights
    }
    
    // MARK: - Helper Methods
    
    private func emotionToScore(_ emotion: String) -> Double {
        // 감정을 -2 ~ 2 점수로 변환 (EmotionType enum과 일치)
        switch emotion {
        case "😢": return -2.0  // .sad
        case "😠": return -1.0  // .angry
        case "😐": return 0.0   // .neutral
        case "🥱": return -0.5  // .tired (EmotionType enum 값과 일치)
        case "😊": return 2.0   // .happy
        default: return 0.0
        }
    }
    
    private func calculateLinearRegression(_ values: [Double]) -> (slope: Double, intercept: Double) {
        let n = Double(values.count)
        let x = Array(0..<values.count).map { Double($0) }
        let y = values
        
        let sumX = x.reduce(0, +)
        let sumY = y.reduce(0, +)
        let sumXY = zip(x, y).map(*).reduce(0, +)
        let sumX2 = x.map { $0 * $0 }.reduce(0, +)
        
        let slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX)
        let intercept = (sumY - slope * sumX) / n
        
        return (slope, intercept)
    }
    
    private func generatePredictionString(scores: [Double], trend: Double) -> String {
        if trend > 0.3 {
            return "향후 감정 상태가 더욱 개선될 것으로 예상됩니다"
        } else if trend < -0.3 {
            return "감정 상태 관리에 더 주의를 기울일 필요가 있습니다"
        } else {
            return "현재의 안정적인 상태가 지속될 것으로 보입니다"
        }
    }
    
    private func generateTrendInsightDescription(_ analysis: TrendAnalysis) -> String {
        switch analysis.overallTrend {
        case .improving:
            return "최근 감정 상태가 점진적으로 개선되고 있습니다. 현재의 긍정적인 변화를 유지하기 위한 방법들을 지속해보세요."
        case .declining:
            return "최근 감정 상태에 하락 추세가 보입니다. 스트레스 요인을 파악하고 관리 방법을 모색해보세요."
        case .stable:
            return "감정 상태가 안정적으로 유지되고 있습니다. 현재의 균형잡힌 상태를 지속하기 위한 루틴을 유지하세요."
        }
    }
    
    private func createMinimalAnalysis() -> PatternAnalysisResult {
        return PatternAnalysisResult(
            temporalPatterns: [],
            emotionalPatterns: [],
            trendAnalysis: TrendAnalysis(
                overallTrend: .stable,
                changeRate: 0,
                trendStrength: 0,
                prediction: "더 많은 데이터가 축적되면 개인화된 분석을 제공할 수 있습니다",
                seasonalEffects: []
            ),
            personalBaseline: PersonalBaseline(
                averageEmotion: 0,
                stabilityIndex: 0,
                recoveryRate: 0,
                lastUpdated: Date()
            ),
            insights: [
                PersonalizedInsight(
                    category: "데이터수집",
                    title: "데이터 수집 초기 단계",
                    message: "지속적인 기록을 통해 개인화된 패턴 분석을 제공할 예정입니다.",
                    actionable: true,
                    priority: .medium,
                    evidence: ["분석을 위한 충분한 데이터 필요"]
                )
            ]
        )
    }
}