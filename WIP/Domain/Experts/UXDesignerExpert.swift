import Foundation
import SwiftUI

// Import shared types from ExpertSystem

// MARK: - UX Designer Expert (UX/UI 디자이너)
struct UXDesignerExpert: ExpertProtocol {
    let id = "ux_designer_expert"
    let name = "Designer 최유진"
    let specialty = "사용자 경험 · 인터페이스 디자인"
    let experienceYears = 11
    let avatar = "🎨"
    let description = "사용자 중심 디자인으로 직관적이고 매력적인 감정 기록 경험을 만드는 UX 디자인 전문가"
    
    func analyzeEmotion(data: EmotionStatisticsDTO) -> ExpertInsight {
        let usabilityScore = assessUsabilityPattern(data: data)
        let engagementLevel = calculateEngagementLevel(data: data)
        let interfaceOpportunity = identifyInterfaceOpportunity(data: data)
        
        var priority: InsightPriority
        var analysis: String
        var recommendations: [String] = []
        
        if engagementLevel < 0.3 {
            priority = .important
            analysis = "사용자 참여도가 낮습니다. 인터페이스 개선과 사용성 향상이 필요한 상황입니다."
            recommendations = [
                "감정 입력 방식을 더 간편하게 만들어보세요",
                "시각적 피드백을 활용한 기록 동기부여",
                "개인화된 알림과 리마인더 설정",
                "성취감을 주는 진행률 표시 추가"
            ]
        } else if usabilityScore < 0.5 {
            priority = .moderate
            analysis = "사용 패턴을 보면 \(interfaceOpportunity) 영역에서 사용자 경험을 개선할 여지가 있습니다."
            recommendations = [
                "자주 사용하는 기능의 접근성 향상",
                "사용자 여정 단계별 최적화",
                "색상과 타이포그래피로 감정 구분 강화",
                "터치 제스처를 활용한 빠른 입력 방식"
            ]
        } else {
            priority = .informational
            analysis = "훌륭한 사용 패턴을 보이고 있습니다! 현재의 사용성을 더욱 발전시킬 수 있는 방법들을 제안합니다."
            recommendations = [
                "고급 기능 탐색으로 더 깊은 인사이트 얻기",
                "개인화 설정으로 나만의 경험 만들기",
                "소셜 기능으로 동기부여 강화하기",
                "새로운 시각화 옵션 활용하기"
            ]
        }
        
        return ExpertInsight(
            expertId: id,
            title: "사용자 경험 최적화 분석",
            analysis: analysis,
            confidence: 0.8,
            tags: ["사용성", "인터페이스", "사용자경험", "접근성"],
            recommendations: recommendations,
            priority: priority
        )
    }
    
    func provideRecommendation(context: EmotionContext) -> ExpertRecommendation {
        let timeBasedUX = generateTimeBasedUXAdvice(context: context)
        
        return ExpertRecommendation(
            title: "개인화된 UX 최적화",
            description: "현재 상황과 사용 패턴에 맞는 인터페이스 활용법을 제안합니다.",
            actionItems: timeBasedUX.actionItems,
            timeframe: timeBasedUX.timeframe,
            difficulty: .easy
        )
    }
    
    func generateDailyTip() -> String {
        let tips = [
            "감정 버튼을 길게 눌러보세요. 더 세분화된 옵션을 확인할 수 있어요.",
            "다크모드로 전환하면 눈이 피로할 때 더 편안하게 사용할 수 있습니다.",
            "위젯을 추가하면 홈화면에서 바로 감정을 기록할 수 있어요.",
            "스와이프 제스처를 활용하면 더 빠르게 이전 기록을 탐색할 수 있습니다.",
            "알림 시간을 개인 패턴에 맞게 조정하면 기록률이 향상됩니다.",
            "색상 테마를 변경해서 기분에 맞는 인터페이스를 만들어보세요.",
            "통계 화면에서 차트를 탭하면 상세 정보를 볼 수 있어요."
        ]
        return tips.randomElement() ?? tips[0]
    }
    
    // MARK: - Private Methods
    private func assessUsabilityPattern(data: EmotionStatisticsDTO) -> Double {
        // 기록의 일관성과 패턴으로 사용성 점수 계산
        let totalDays = max(data.totalEntries, 1)
        let consistency = min(Double(data.totalEntries) / 30.0, 1.0) // 30일 기준
        
        // 감정 타입의 다양성 (사용자가 다양한 기능을 활용하는지)
        let emotionVariety = Double(data.emotionCounts.keys.count) / Double(EmotionType.allCases.count)
        
        return (consistency + emotionVariety) / 2.0
    }
    
    private func calculateEngagementLevel(data: EmotionStatisticsDTO) -> Double {
        // 최근 활동성 기반 참여도 계산
        let recentEntries = data.totalEntries // 실제로는 최근 7일 기준으로 계산
        let targetWeeklyEntries = 7.0
        
        return min(Double(recentEntries) / targetWeeklyEntries, 1.0)
    }
    
    private func identifyInterfaceOpportunity(data: EmotionStatisticsDTO) -> String {
        // 가장 많이 사용되는 감정과 적게 사용되는 감정 분석
        let sortedEmotions = data.emotionCounts.sorted { $0.value > $1.value }
        
        if let mostUsed = sortedEmotions.first,
           let leastUsed = sortedEmotions.last,
           mostUsed.value > leastUsed.value * 3 {
            return "감정 입력 밸런싱"
        } else {
            return "전반적 인터페이스"
        }
    }
    
    private func generateTimeBasedUXAdvice(context: EmotionContext) -> (actionItems: [ActionItem], timeframe: String) {
        var actionItems: [ActionItem] = []
        
        // 시간대별 UX 최적화 제안
        if context.timeOfDay.contains("오전") {
            actionItems.append(ActionItem(
                id: "morning_ux",
                title: "모닝 루틴 최적화",
                description: "위젯이나 빠른 기록 기능을 활용해 바쁜 아침에도 쉽게 기록하세요"
            ))
        } else if context.timeOfDay.contains("저녁") {
            actionItems.append(ActionItem(
                id: "evening_ux",
                title: "저녁 성찰 모드",
                description: "다크모드와 차분한 색상으로 하루를 정리하는 시간을 만들어보세요"
            ))
        }
        
        // 스트레스 레벨에 따른 UX 조정
        if context.stressLevel > 6 {
            actionItems.append(ActionItem(
                id: "stress_ux",
                title: "스트레스 완화 인터페이스",
                description: "진정 효과가 있는 색상과 간단한 입력 방식으로 설정을 변경해보세요"
            ))
        }
        
        // 감정 상태에 따른 시각적 조정
        switch context.currentMood {
        case .sad:
            actionItems.append(ActionItem(
                id: "sad_ux",
                title: "부드러운 인터페이스 설정",
                description: "따뜻한 색조와 부드러운 애니메이션으로 위로받는 경험을 만들어보세요"
            ))
        case .angry:
            actionItems.append(ActionItem(
                id: "angry_ux",
                title: "간결한 인터페이스 모드",
                description: "복잡한 요소를 줄이고 핵심 기능에만 집중할 수 있는 모드를 활용하세요"
            ))
        case .happy:
            actionItems.append(ActionItem(
                id: "happy_ux",
                title: "활동적 인터페이스 탐색",
                description: "밝은 색상과 다양한 기능을 탐색하며 긍정적 경험을 확장해보세요"
            ))
        default:
            actionItems.append(ActionItem(
                id: "neutral_ux",
                title: "균형잡힌 인터페이스",
                description: "중성적이고 안정적인 디자인으로 편안한 사용 환경을 유지하세요"
            ))
        }
        
        return (actionItems: actionItems, timeframe: "즉시 적용")
    }
}