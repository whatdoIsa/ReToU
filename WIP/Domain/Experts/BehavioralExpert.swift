import Foundation
import SwiftUI

// Import shared types from ExpertSystem

// MARK: - Behavioral Expert (행동경제학 전문가)
struct BehavioralExpert: ExpertProtocol {
    let id = "behavioral_expert"
    let name = "Dr. 정태윤"
    let specialty = "행동경제학 · 습관형성 · 동기과학"
    let experienceYears = 13
    let avatar = "🧠"
    let description = "인간의 행동 패턴과 동기를 분석해 지속가능한 감정 관리 습관을 만드는 행동과학 전문가"
    
    func analyzeEmotion(data: EmotionStatisticsDTO) -> ExpertInsight {
        let habitStrength = calculateHabitStrength(data: data)
        let motivationLevel = assessMotivationLevel(data: data)
        let behavioralOpportunity = identifyBehavioralOpportunity(data: data)
        
        var priority: InsightPriority
        var analysis: String
        var recommendations: [String] = []
        
        if habitStrength < 0.3 {
            priority = .important
            analysis = "감정 기록 습관이 아직 형성되지 않았습니다. 행동 과학 원리를 활용해 지속 가능한 습관을 만들어야 합니다."
            recommendations = [
                "매일 같은 시간, 같은 장소에서 기록하기 (큐-루틴-보상)",
                "작은 성공을 축하하고 보상하기 (도파민 루프 활용)",
                "기록 후 즉시 긍정적 피드백 확인하기",
                "습관 스태킹: 기존 습관에 감정 기록 연결하기"
            ]
        } else if motivationLevel < 0.5 {
            priority = .moderate
            analysis = "초기 동기가 약해지고 있는 단계입니다. \(behavioralOpportunity) 전략으로 다시 동기를 불러일으킬 수 있습니다."
            recommendations = [
                "목표를 더 구체적이고 달성 가능하게 재설정하기",
                "진전 사항을 시각적으로 확인할 수 있는 방법 활용",
                "사회적 지지체계 활용하기 (가족, 친구들과 공유)",
                "내재적 동기 강화하기 (왜 시작했는지 되돌아보기)"
            ]
        } else {
            priority = .informational
            analysis = "훌륭한 행동 습관을 형성했습니다! 이제 더 고차원적인 행동 변화로 나아갈 시점입니다."
            recommendations = [
                "현재 습관을 다른 영역으로 확장해보기",
                "더 도전적인 목표 설정으로 성장 지속하기",
                "다른 사람들에게 경험과 노하우 공유하기",
                "장기적 관점에서 라이프스타일 통합하기"
            ]
        }
        
        return ExpertInsight(
            expertId: id,
            title: "행동 패턴 및 습관 분석",
            analysis: analysis,
            confidence: 0.88,
            tags: ["습관형성", "동기부여", "행동변화", "지속가능성"],
            recommendations: recommendations,
            priority: priority
        )
    }
    
    func provideRecommendation(context: EmotionContext) -> ExpertRecommendation {
        let behavioralStrategy = generateBehavioralStrategy(context: context)
        
        return ExpertRecommendation(
            title: "행동 과학 기반 습관 전략",
            description: "과학적으로 검증된 행동 변화 기법으로 지속 가능한 감정 관리 시스템을 구축합니다.",
            actionItems: behavioralStrategy.actionItems,
            timeframe: behavioralStrategy.timeframe,
            difficulty: behavioralStrategy.difficulty
        )
    }
    
    func generateDailyTip() -> String {
        let tips = [
            "2분 룰: 2분 안에 할 수 있는 일이라면 지금 당장 하세요. 미루는 습관을 방지합니다.",
            "습관 스태킹: 양치 후 → 감정 기록하기처럼 기존 습관에 연결하면 정착률이 3배 높아집니다.",
            "1% 개선 원리: 매일 1%씩만 개선해도 1년 후엔 37배 더 나은 결과를 얻을 수 있어요.",
            "보상의 타이밍: 행동 직후 받는 보상이 습관 형성에 가장 효과적입니다.",
            "환경 디자인: 감정 기록을 쉽게 만들고, 방해 요소를 제거하면 의지력 없이도 지속할 수 있어요.",
            "사회적 책임: 다른 사람에게 목표를 선언하면 달성률이 65% 향상됩니다.",
            "구현 의도: '만약 X가 일어나면, Y를 하겠다'라는 if-then 계획으로 성공률을 높이세요."
        ]
        return tips.randomElement() ?? tips[0]
    }
    
    // MARK: - Private Methods
    private func calculateHabitStrength(data: EmotionStatisticsDTO) -> Double {
        // 습관 강도 = 일관성 × 빈도 × 지속기간
        let totalDays = max(data.totalEntries, 1)
        let consistency = min(Double(data.totalEntries) / 30.0, 1.0) // 30일 기준 일관성
        
        // 최근 7일 활동성 (습관은 최근 패턴이 중요)
        let recentActivity = min(Double(totalDays) / 7.0, 1.0)
        
        return (consistency + recentActivity) / 2.0
    }
    
    private func assessMotivationLevel(data: EmotionStatisticsDTO) -> Double {
        // 동기 레벨 = 긍정적 감정 비율 + 기록 다양성
        let totalEntries = max(data.totalEntries, 1)
        let positiveEmotions = data.emotionCounts[.happy] ?? 0
        let neutralEmotions = data.emotionCounts[.neutral] ?? 0
        
        let positiveRatio = Double(positiveEmotions + neutralEmotions) / Double(totalEntries)
        let varietyScore = Double(data.emotionCounts.keys.count) / Double(EmotionType.allCases.count)
        
        return (positiveRatio + varietyScore) / 2.0
    }
    
    private func identifyBehavioralOpportunity(data: EmotionStatisticsDTO) -> String {
        let habitStrength = calculateHabitStrength(data: data)
        let motivationLevel = assessMotivationLevel(data: data)
        
        if habitStrength < motivationLevel {
            return "습관 형성"
        } else if motivationLevel < habitStrength {
            return "동기 부여"
        } else {
            return "행동 최적화"
        }
    }
    
    private func generateBehavioralStrategy(context: EmotionContext) -> (actionItems: [ActionItem], timeframe: String, difficulty: Difficulty) {
        var actionItems: [ActionItem] = []
        var timeframe = "2-4주"
        var difficulty: Difficulty = .medium
        
        // 현재 감정 상태에 따른 행동 전략
        switch context.currentMood {
        case .happy:
            actionItems = [
                ActionItem(id: "positive_momentum", title: "긍정 모멘텀 활용", 
                          description: "현재 좋은 기분을 활용해 새로운 습관을 시작하기 좋은 타이밍입니다"),
                ActionItem(id: "success_celebration", title: "성공 경험 강화", 
                          description: "오늘의 긍정적 감정을 만든 활동들을 내일도 반복해보세요"),
                ActionItem(id: "habit_stacking", title: "습관 스태킹 적용", 
                          description: "기분 좋은 순간에 감정 기록하는 습관을 연결해보세요")
            ]
            difficulty = .easy
            
        case .sad, .angry:
            actionItems = [
                ActionItem(id: "small_wins", title: "작은 성공 만들기", 
                          description: "감정이 어려울 때일수록 달성 가능한 작은 목표를 설정하세요"),
                ActionItem(id: "compassionate_mindset", title: "자기 친화적 접근", 
                          description: "완벽하지 않아도 괜찮다는 마음가짐으로 천천히 시작하세요"),
                ActionItem(id: "support_system", title: "지지 체계 활용", 
                          description: "어려운 감정을 함께 나눌 수 있는 사람들과 연결하세요")
            ]
            timeframe = "1-2주"
            
        case .tired:
            actionItems = [
                ActionItem(id: "energy_optimization", title: "에너지 최적화", 
                          description: "가장 에너지가 높은 시간대에 중요한 습관을 배치하세요"),
                ActionItem(id: "minimal_effort", title: "최소 노력 전략", 
                          description: "피로할 때는 가장 간단한 형태로라도 기록을 유지하세요"),
                ActionItem(id: "recovery_routine", title: "회복 루틴 구축", 
                          description: "휴식과 회복을 위한 의도적인 시간을 만드세요")
            ]
            difficulty = .easy
            
        default:
            actionItems = [
                ActionItem(id: "habit_design", title: "습관 환경 디자인", 
                          description: "감정 기록을 더 쉽게 만드는 환경을 조성하세요"),
                ActionItem(id: "implementation_intention", title: "구현 의도 설정", 
                          description: "언제, 어디서, 어떻게 기록할지 구체적으로 계획하세요"),
                ActionItem(id: "feedback_loop", title: "피드백 루프 강화", 
                          description: "기록 후 즉시 확인할 수 있는 긍정적 피드백을 설정하세요")
            ]
        }
        
        // 스트레스 레벨에 따른 추가 전략
        if context.stressLevel > 7 {
            actionItems.append(ActionItem(
                id: "stress_habit",
                title: "스트레스 대응 습관",
                description: "스트레스가 높을 때도 유지할 수 있는 최소한의 루틴을 만드세요"
            ))
        }
        
        return (actionItems: actionItems, timeframe: timeframe, difficulty: difficulty)
    }
}