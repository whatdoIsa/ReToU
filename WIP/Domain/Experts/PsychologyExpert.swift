import Foundation
import SwiftUI

// Import shared types from ExpertSystem

// MARK: - Psychology Expert (심리학 전문가)
struct PsychologyExpert: ExpertProtocol {
    let id = "psychology_expert"
    let name = "Dr. 김지혜"
    let specialty = "임상심리학 · 감정조절"
    let experienceYears = 15
    let avatar = "👩‍⚕️"
    let description = "감정의 근본 원인을 파악하고 건강한 감정 관리법을 제시하는 임상심리 전문가"
    
    func analyzeEmotion(data: EmotionStatisticsDTO) -> ExpertInsight {
        let negativeEmotionRatio = calculateNegativeRatio(data: data)
        let emotionVolatility = calculateVolatility(data: data)
        
        var priority: InsightPriority
        var analysis: String
        var recommendations: [String] = []
        
        if negativeEmotionRatio > 0.7 {
            priority = .critical
            analysis = "지속적인 부정 감정 패턴이 관찰됩니다. 스트레스나 우울감이 일상에 큰 영향을 미치고 있을 가능성이 있습니다."
            recommendations = [
                "전문 상담사와의 상담을 권합니다",
                "일일 감정 체크인 시간을 정해보세요",
                "감정 일기를 통해 트리거를 파악해보세요"
            ]
        } else if emotionVolatility > 0.6 {
            priority = .important
            analysis = "감정 기복이 큰 상태입니다. 감정 조절 기술을 학습하면 더 안정적인 일상을 보낼 수 있을 것입니다."
            recommendations = [
                "호흡법을 통한 감정 안정화 연습",
                "감정 인식과 명명 연습하기",
                "스트레스 상황 대처 전략 개발"
            ]
        } else {
            priority = .moderate
            analysis = "전반적으로 균형잡힌 감정 상태를 보이고 있습니다. 현재의 좋은 패턴을 유지하는 것이 중요합니다."
            recommendations = [
                "현재의 감정 관리 방법을 지속하세요",
                "감정 표현 방법을 다양화해보세요",
                "주변 지지체계와의 관계를 강화하세요"
            ]
        }
        
        return ExpertInsight(
            expertId: id,
            title: "심리학적 감정 패턴 분석",
            analysis: analysis,
            confidence: 0.9,
            tags: ["감정조절", "정신건강", "스트레스관리"],
            recommendations: recommendations,
            priority: priority
        )
    }
    
    func provideRecommendation(context: EmotionContext) -> ExpertRecommendation {
        switch context.currentMood {
        case .sad:
            return ExpertRecommendation(
                title: "우울감 관리 전략",
                description: "현재 경험하고 있는 슬픔을 건강하게 처리하는 방법을 안내합니다.",
                actionItems: [
                    ActionItem(id: "sadness_1", title: "감정 수용하기", description: "슬픔을 억누르지 말고 자연스럽게 느껴보세요"),
                    ActionItem(id: "sadness_2", title: "지지체계 활용", description: "신뢰할 수 있는 사람과 감정을 나누세요"),
                    ActionItem(id: "sadness_3", title: "자기돌봄 실천", description: "충분한 휴식과 영양섭취를 챙기세요")
                ],
                timeframe: "1-3일",
                difficulty: .medium
            )
            
        case .angry:
            return ExpertRecommendation(
                title: "분노 조절 기법",
                description: "건강한 방식으로 분노를 표현하고 관리하는 방법을 제시합니다.",
                actionItems: [
                    ActionItem(id: "anger_1", title: "6초 룰 적용", description: "화가 날 때 6초간 깊게 숨쉬며 진정하기"),
                    ActionItem(id: "anger_2", title: "원인 분석", description: "무엇이 화나게 했는지 구체적으로 파악하기"),
                    ActionItem(id: "anger_3", title: "건설적 표현", description: "'나' 메시지로 감정을 표현하기")
                ],
                timeframe: "즉시 적용",
                difficulty: .medium
            )
            
        default:
            return ExpertRecommendation(
                title: "감정 웰빙 유지",
                description: "현재의 안정적인 감정 상태를 유지하고 더욱 발전시키는 방법입니다.",
                actionItems: [
                    ActionItem(id: "general_1", title: "감정 어휘 확장", description: "더 정확한 감정 표현을 위한 어휘 늘리기"),
                    ActionItem(id: "general_2", title: "마음챙김 연습", description: "현재 순간에 집중하는 명상 실천"),
                    ActionItem(id: "general_3", title: "감사 일기", description: "매일 감사한 일 3가지 적어보기")
                ],
                timeframe: "지속적",
                difficulty: .easy
            )
        }
    }
    
    func generateDailyTip() -> String {
        let tips = [
            "감정은 일시적입니다. 지금 이 순간도 지나갈 것임을 기억하세요.",
            "감정에 이름을 붙이는 것만으로도 그 강도를 줄일 수 있습니다.",
            "완벽하지 않아도 괜찮습니다. 자신에게 따뜻한 말을 건네보세요.",
            "깊고 느린 호흡은 신경계를 진정시키는 가장 간단한 방법입니다.",
            "감정을 판단하지 말고 그저 관찰해보세요. 모든 감정은 메시지입니다."
        ]
        return tips.randomElement() ?? tips[0]
    }
    
    // MARK: - Private Methods
    private func calculateNegativeRatio(data: EmotionStatisticsDTO) -> Double {
        let totalEntries = data.totalEntries
        guard totalEntries > 0 else { return 0 }
        
        let negativeEntries = data.emotionCounts[.sad, default: 0] + 
                             data.emotionCounts[.angry, default: 0]
        
        return Double(negativeEntries) / Double(totalEntries)
    }
    
    private func calculateVolatility(data: EmotionStatisticsDTO) -> Double {
        // 감정 점수의 표준편차를 계산하여 변동성 측정
        let scores = data.emotionCounts.map { emotion, count in
            Array(repeating: emotion.numericScore, count: count)
        }.flatMap { $0 }
        
        guard scores.count > 1 else { return 0 }
        
        let mean = scores.reduce(0, +) / scores.count
        let variance = scores.map { pow(Double($0 - mean), 2) }.reduce(0, +) / Double(scores.count - 1)
        
        return sqrt(variance) / 4.0 // 정규화 (최대 점수 차이가 4이므로)
    }
}