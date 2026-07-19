import Foundation
import SwiftUI

// MARK: - Expert System Protocol
protocol ExpertProtocol {
    var id: String { get }
    var name: String { get }
    var specialty: String { get }
    var experienceYears: Int { get }
    var avatar: String { get }
    var description: String { get }
    
    func analyzeEmotion(data: EmotionStatisticsDTO) -> ExpertInsight
    func provideRecommendation(context: EmotionContext) -> ExpertRecommendation
    func generateDailyTip() -> String
}

// MARK: - Expert Insights
struct ExpertInsight {
    let expertId: String
    let title: String
    let analysis: String
    let confidence: Double
    let tags: [String]
    let recommendations: [String]
    let priority: InsightPriority
}

enum InsightPriority: String, CaseIterable {
    case critical = "긴급"
    case important = "중요"
    case moderate = "보통"
    case informational = "정보"
    
    var color: Color {
        switch self {
        case .critical: return .red
        case .important: return .orange
        case .moderate: return .blue
        case .informational: return .gray
        }
    }
}

struct ExpertRecommendation {
    let title: String
    let description: String
    let actionItems: [ActionItem]
    let timeframe: String
    let difficulty: Difficulty
}

struct ActionItem {
    let id: String
    let title: String
    let description: String
    let isCompleted: Bool = false
}

enum Difficulty: String, CaseIterable {
    case easy = "쉬움"
    case medium = "보통"
    case hard = "어려움"
    
    var color: Color {
        switch self {
        case .easy: return .green
        case .medium: return .yellow
        case .hard: return .red
        }
    }
}

struct EmotionContext {
    let currentMood: EmotionType
    let recentPattern: [EmotionType]
    let timeOfDay: String
    let weekday: String
    let stressLevel: Int
}

// MARK: - Using existing DTO models 
// EmotionType from Models/EmotionType.swift
// EmotionStatisticsDTO from Domain/DTO/EmotionStatisticsDTO.swift

// MARK: - User Interaction Models
struct UserInteraction {
    let id: String
    let expertId: String
    let interactionType: InteractionType
    let isPositive: Bool
    let timestamp: Date
}

enum InteractionType: String, CaseIterable {
    case tipRead = "팁_읽기"
    case recommendationFollowed = "추천_실행"
    case insightLiked = "인사이트_좋아요"
    case questionAsked = "질문"
    case feedbackGiven = "피드백"
}

// Color extension moved to EmotionType.swift to avoid duplication