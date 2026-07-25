import Foundation
import SwiftUI

// Import shared types from ExpertSystem

// MARK: - Wellness Coach Expert (웰빙 코치)
struct WellnessCoachExpert: ExpertProtocol {
    let id = "wellness_coach_expert"
    let name = "Coach 박소영"
    let specialty = "웰빙 · 라이프스타일 · 습관형성"
    let experienceYears = 10
    let avatar = "🧘‍♀️"
    let description = "건강한 생활습관과 웰빙 라이프스타일을 통해 감정 균형을 찾도록 돕는 웰빙 전문 코치"
    
    func analyzeEmotion(data: EmotionStatisticsDTO) -> ExpertInsight {
        let energyLevel = assessEnergyLevel(data: data)
        let balanceScore = calculateLifeBalance(data: data)
        let wellnessOpportunity = identifyWellnessOpportunity(data: data)
        
        var priority: InsightPriority
        var analysis: String
        var recommendations: [String] = []
        
        if energyLevel < 0.3 {
            priority = .important
            analysis = "에너지 레벨이 낮습니다. 피로감이나 번아웃 상태일 가능성이 있어 즉시 회복에 집중해야 합니다."
            recommendations = [
                "충분한 수면(7-9시간) 확보하기",
                "규칙적인 식사와 영양 균형 맞추기",
                "가벼운 산책이나 스트레칭으로 몸 깨우기",
                "디지털 디톡스 시간 만들기"
            ]
        } else if balanceScore < 0.4 {
            priority = .moderate
            analysis = "생활의 균형이 다소 흔들려 있는 상태입니다. \(wellnessOpportunity) 영역에서 개선이 필요합니다."
            recommendations = [
                "일과 휴식의 경계선 만들기",
                "나만의 셀프케어 루틴 개발하기",
                "자연과 함께하는 시간 늘리기",
                "마음챙김 호흡법 연습하기"
            ]
        } else {
            priority = .informational
            analysis = "전반적으로 건강한 웰빙 상태를 유지하고 있습니다. 현재의 좋은 습관들을 더욱 발전시켜보세요."
            recommendations = [
                "현재의 건강한 루틴을 지속하세요",
                "새로운 웰빙 활동을 시도해보세요",
                "주변 사람들과 웰빙 경험을 나누세요",
                "장기적인 웰빙 목표를 설정해보세요"
            ]
        }
        
        return ExpertInsight(
            expertId: id,
            title: "웰빙 라이프스타일 분석",
            analysis: analysis,
            confidence: 0.85,
            tags: ["웰빙", "라이프스타일", "습관형성", "에너지관리"],
            recommendations: recommendations,
            priority: priority
        )
    }
    
    func provideRecommendation(context: EmotionContext) -> ExpertRecommendation {
        switch context.currentMood {
        case .tired:
            return ExpertRecommendation(
                title: "에너지 회복 프로그램",
                description: "피로감을 해소하고 활력을 되찾는 종합 웰빙 솔루션",
                actionItems: [
                    ActionItem(id: "energy_1", title: "수면 패턴 최적화", 
                              description: "같은 시간에 잠들고 일어나는 규칙적인 수면 리듬 만들기"),
                    ActionItem(id: "energy_2", title: "영양 에너지 부스터", 
                              description: "비타민 B, D와 오메가3가 풍부한 음식 섭취하기"),
                    ActionItem(id: "energy_3", title: "활동적 휴식", 
                              description: "10분 산책이나 가벼운 요가로 몸과 마음 재충전"),
                    ActionItem(id: "energy_4", title: "디지털 휴식", 
                              description: "스마트폰을 멀리하고 자연이나 취미 활동 즐기기")
                ],
                timeframe: "1-2주",
                difficulty: .medium
            )
            
        case .neutral:
            return ExpertRecommendation(
                title: "웰빙 라이프 업그레이드",
                description: "현재 상태를 기반으로 더 풍성한 웰빙 라이프를 만들어보세요",
                actionItems: [
                    ActionItem(id: "upgrade_1", title: "새로운 운동 도전", 
                              description: "요가, 필라테스, 댄스 등 즐거운 운동 시도하기"),
                    ActionItem(id: "upgrade_2", title: "마음챙김 습관", 
                              description: "하루 5분 명상이나 감사 일기 쓰기"),
                    ActionItem(id: "upgrade_3", title: "소셜 웰빙", 
                              description: "가족, 친구들과 함께하는 건강한 활동 늘리기")
                ],
                timeframe: "지속적",
                difficulty: .easy
            )
            
        default:
            return ExpertRecommendation(
                title: "감정 기반 웰빙 케어",
                description: "현재 감정 상태에 맞는 맞춤형 웰빙 솔루션",
                actionItems: [
                    ActionItem(id: "emotion_wellness_1", title: "감정 친화적 활동", 
                              description: "현재 감정에 도움이 되는 활동 선택하기"),
                    ActionItem(id: "emotion_wellness_2", title: "바디 체크인", 
                              description: "몸의 긴장 부위를 확인하고 이완하기"),
                    ActionItem(id: "emotion_wellness_3", title: "환경 최적화", 
                              description: "감정에 좋은 영향을 주는 환경 조성하기")
                ],
                timeframe: "즉시 적용",
                difficulty: .easy
            )
        }
    }
    
    func generateDailyTip() -> String {
        let tips = [
            "물 한 잔으로 하루를 시작하세요. 수분 공급이 기분과 에너지에 큰 영향을 줍니다.",
            "하루 10분 햇빛 쬐기만으로도 비타민 D와 세로토닌이 증가합니다.",
            "깊고 천천히 3번 숨쉬는 것만으로도 스트레스 호르몬을 줄일 수 있어요.",
            "감사한 일 3가지를 떠올리며 하루를 마무리해보세요.",
            "핸드폰을 멀리하고 자연의 소리에 집중하는 시간을 만드세요.",
            "좋아하는 향을 맡거나 좋아하는 음악을 들으며 감각을 깨워보세요.",
            "몸을 쭉 펴고 어깨를 뒤로 젖히세요. 자세가 기분에 영향을 줍니다."
        ]
        return tips.randomElement() ?? tips[0]
    }
    
    // MARK: - Private Methods
    private func assessEnergyLevel(data: EmotionStatisticsDTO) -> Double {
        let tiredCount = data.emotionCounts[.tired] ?? 0
        let happyCount = data.emotionCounts[.happy] ?? 0
        let totalCount = max(data.totalEntries, 1)
        
        let tiredRatio = Double(tiredCount) / Double(totalCount)
        let happyRatio = Double(happyCount) / Double(totalCount)
        
        // 에너지 레벨 = 긍정 감정 비율 - 피로 감정 비율
        return max(0, happyRatio - tiredRatio)
    }
    
    private func calculateLifeBalance(data: EmotionStatisticsDTO) -> Double {
        // 감정의 다양성과 균형을 측정
        let emotionVariety = data.emotionCounts.keys.count
        let maxVariety = EmotionType.allCases.count
        
        // 감정 분포의 균등성 측정 (엔트로피 기반)
        let totalEntries = max(data.totalEntries, 1)
        let entropy = data.emotionCounts.values.map { count in
            let probability = Double(count) / Double(totalEntries)
            return probability > 0 ? -probability * log2(probability) : 0
        }.reduce(0.0) { $0 + $1 }
        
        let maxEntropy = log2(Double(maxVariety))
        let varietyScore = Double(emotionVariety) / Double(maxVariety)
        let balanceScore = entropy / maxEntropy
        
        return (varietyScore + balanceScore) / 2.0
    }
    
    private func identifyWellnessOpportunity(data: EmotionStatisticsDTO) -> String {
        let tiredCount = data.emotionCounts[.tired] ?? 0
        let sadCount = data.emotionCounts[.sad] ?? 0
        let angryCount = data.emotionCounts[.angry] ?? 0
        
        if tiredCount > sadCount && tiredCount > angryCount {
            return "에너지 관리"
        } else if sadCount > 0 || angryCount > 0 {
            return "정서적 균형"
        } else {
            return "전반적 웰빙"
        }
    }
}