import Foundation
import SwiftUI

// MARK: - Expert Team Manager
class ExpertTeamManager: ObservableObject {
    @Published var experts: [ExpertProtocol] = []
    @Published var currentAnalysis: [String: ExpertInsight] = [:]
    
    init() {
        loadExperts()
    }
    
    private func loadExperts() {
        experts = [
            BehavioralExpert(),
            PsychologyExpert(),
            DataScienceExpert(),
            UXDesignerExpert(),
            WellnessCoachExpert()
        ]
    }
    
    func analyzeEmotionData(_ data: EmotionStatisticsDTO) {
        currentAnalysis.removeAll()
        
        for expert in experts {
            let insight = expert.analyzeEmotion(data: data)
            currentAnalysis[expert.id] = insight
        }
    }
    
    func getRecommendation(for expert: ExpertProtocol, context: EmotionContext) -> ExpertRecommendation {
        return expert.provideRecommendation(context: context)
    }
    
    func getDailyTip(from expert: ExpertProtocol) -> String {
        return expert.generateDailyTip()
    }
}