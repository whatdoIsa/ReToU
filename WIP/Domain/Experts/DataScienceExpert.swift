import Foundation
import SwiftUI

// Import shared types from ExpertSystem

// MARK: - Data Science Expert (데이터 과학자)
struct DataScienceExpert: ExpertProtocol {
    let id = "datascience_expert"
    let name = "Dr. 이민수"
    let specialty = "감정 데이터 분석 · AI 모델링"
    let experienceYears = 12
    let avatar = "👨‍💻"
    let description = "빅데이터와 머신러닝을 활용해 개인화된 감정 패턴을 분석하고 예측하는 데이터 과학자"
    
    func analyzeEmotion(data: EmotionStatisticsDTO) -> ExpertInsight {
        let trendAnalysis = analyzeTrend(data: data)
        let patternStrength = calculatePatternStrength(data: data)
        let predictability = calculatePredictability(data: data)
        
        var priority: InsightPriority
        var analysis: String
        var recommendations: [String] = []
        
        if patternStrength > 0.8 {
            priority = .important
            analysis = "강한 감정 패턴이 감지되었습니다. \(trendAnalysis) 이 패턴을 활용하면 감정 관리를 더욱 체계적으로 할 수 있습니다."
            recommendations = [
                "패턴 기반 개인화 알림 설정을 활용하세요",
                "예측된 감정 변화에 미리 대비하세요",
                "데이터 기반 목표를 설정해보세요"
            ]
        } else if predictability < 0.3 {
            priority = .moderate
            analysis = "감정 패턴의 예측 가능성이 낮습니다. 더 일관된 기록을 통해 개인화된 인사이트를 제공할 수 있습니다."
            recommendations = [
                "더 정기적인 감정 기록을 시도해보세요",
                "기록 시간을 일정하게 맞춰보세요",
                "상황 정보도 함께 기록해보세요"
            ]
        } else {
            priority = .informational
            analysis = "데이터 품질이 우수합니다. \(trendAnalysis) 지속적인 기록을 통해 더 정확한 예측이 가능해집니다."
            recommendations = [
                "현재의 기록 패턴을 유지하세요",
                "주간/월간 리포트를 활용하세요",
                "장기 트렌드를 주시하세요"
            ]
        }
        
        return ExpertInsight(
            expertId: id,
            title: "데이터 기반 감정 패턴 분석",
            analysis: analysis,
            confidence: min(patternStrength, 1.0),
            tags: ["데이터분석", "패턴인식", "예측모델"],
            recommendations: recommendations,
            priority: priority
        )
    }
    
    func provideRecommendation(context: EmotionContext) -> ExpertRecommendation {
        let patternBasedAdvice = generatePatternBasedAdvice(context: context)
        
        return ExpertRecommendation(
            title: "데이터 기반 개인화 전략",
            description: "귀하의 감정 데이터 패턴을 바탕으로 한 맞춤형 제안입니다.",
            actionItems: patternBasedAdvice,
            timeframe: "1-2주",
            difficulty: .easy
        )
    }
    
    func generateDailyTip() -> String {
        let tips = [
            "일관된 기록이 더 정확한 패턴 분석으로 이어집니다.",
            "주간 트렌드를 확인하면 장기적인 감정 변화를 파악할 수 있습니다.",
            "같은 시간대 기록이 더 의미 있는 비교 분석을 가능하게 합니다.",
            "감정과 함께 상황을 기록하면 트리거 패턴을 발견할 수 있습니다.",
            "데이터가 많아질수록 개인화 정확도가 높아집니다."
        ]
        return tips.randomElement() ?? tips[0]
    }
    
    // MARK: - Private Methods
    private func analyzeTrend(data: EmotionStatisticsDTO) -> String {
        let currentAverage = data.averageScore
        let previousAverage = data.previousPeriodAverage ?? currentAverage
        
        if currentAverage > previousAverage + 0.5 {
            return "상승 트렌드"
        } else if currentAverage < previousAverage - 0.5 {
            return "하락 트렌드"
        } else {
            return "안정적 트렌드"
        }
    }
    
    private func calculatePatternStrength(data: EmotionStatisticsDTO) -> Double {
        // 요일별, 시간대별 패턴의 일관성을 측정
        guard data.totalEntries > 10 else { return 0.1 }
        
        // 간단한 패턴 강도 계산 (실제로는 더 복잡한 통계 분석 필요)
        let emotionTypes = data.emotionCounts.keys.count
        let dominantEmotionRatio = data.emotionCounts.values.max() ?? 0
        
        return min(Double(dominantEmotionRatio) / Double(data.totalEntries) * Double(emotionTypes), 1.0)
    }
    
    private func calculatePredictability(data: EmotionStatisticsDTO) -> Double {
        // 시계열 데이터의 예측 가능성을 측정
        // 실제로는 ARIMA, LSTM 등의 모델을 사용
        guard data.totalEntries > 7 else { return 0.2 }
        
        // 간단한 예측 가능성 지표
        let variance = calculateVariance(data: data)
        return max(0.0, 1.0 - variance / 2.0)
    }
    
    private func calculateVariance(data: EmotionStatisticsDTO) -> Double {
        let scores = data.emotionCounts.map { emotion, count in
            Array(repeating: emotion.numericScore, count: count)
        }.flatMap { $0 }
        
        guard scores.count > 1 else { return 0 }
        
        let mean = Double(scores.reduce(0, +)) / Double(scores.count)
        let variance = scores.map { pow(Double($0) - mean, 2) }.reduce(0, +) / Double(scores.count - 1)
        
        return variance
    }
    
    private func generatePatternBasedAdvice(context: EmotionContext) -> [ActionItem] {
        var actionItems: [ActionItem] = []
        
        // 시간대 기반 추천
        if context.timeOfDay.contains("오전") {
            actionItems.append(ActionItem(
                id: "morning_pattern",
                title: "아침 감정 체크인",
                description: "하루를 시작하기 전 감정 상태를 확인하고 목표를 설정하세요"
            ))
        }
        
        // 요일 기반 추천
        if context.weekday.contains("월") || context.weekday.contains("화") {
            actionItems.append(ActionItem(
                id: "weekday_prep",
                title: "주중 감정 준비",
                description: "주중 스트레스 패턴을 고려한 미리 대비 전략을 세우세요"
            ))
        }
        
        // 스트레스 레벨 기반 추천
        if context.stressLevel > 7 {
            actionItems.append(ActionItem(
                id: "stress_data",
                title: "스트레스 패턴 분석",
                description: "고스트레스 상황의 공통점을 찾아 예방 전략을 개발하세요"
            ))
        }
        
        return actionItems
    }
}