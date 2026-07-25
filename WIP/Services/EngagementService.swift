import Foundation
import SwiftUI

// MARK: - Engagement Service
@MainActor
class EngagementService: ObservableObject {
    @Published var engagementStreak: Int = 0
    @Published var totalPoints: Int = 0
    @Published var currentLevel: UserLevel = .beginner
    @Published var achievements: [Achievement] = []
    @Published var dailyGoals: [DailyGoal] = []
    @Published var weeklyChallenge: WeeklyChallenge?
    @Published var motivationalMessage: String = ""
    
    private let userDefaults = UserDefaults.standard
    private let expertTeamManager = ExpertTeamManager()
    
    // MARK: - User Levels
    enum UserLevel: String, CaseIterable {
        case beginner = "감정 탐험가"
        case intermediate = "감정 분석가" 
        case advanced = "감정 전문가"
        case expert = "감정 마스터"
        case master = "감정 현자"
        
        var pointsRequired: Int {
            switch self {
            case .beginner: return 0
            case .intermediate: return 100
            case .advanced: return 300
            case .expert: return 600
            case .master: return 1000
            }
        }
        
        var color: Color {
            switch self {
            case .beginner: return .green
            case .intermediate: return .blue
            case .advanced: return .purple
            case .expert: return .orange
            case .master: return .gold
            }
        }
        
        var icon: String {
            switch self {
            case .beginner: return "seedling"
            case .intermediate: return "leaf"
            case .advanced: return "tree"
            case .expert: return "crown"
            case .master: return "star.circle"
            }
        }
    }
    
    init() {
        loadEngagementData()
        setupDailyGoals()
        generateWeeklyChallenge()
    }
    
    // MARK: - Points System
    func awardPoints(for action: UserAction) {
        let points = action.pointValue
        totalPoints += points
        
        checkLevelUp()
        updateAchievements(for: action)
        saveEngagementData()
        
        generateMotivationalMessage(for: action)
    }
    
    private func checkLevelUp() {
        let newLevel = UserLevel.allCases.last { level in
            totalPoints >= level.pointsRequired
        } ?? .beginner
        
        if newLevel != currentLevel {
            currentLevel = newLevel
            triggerLevelUpCelebration()
        }
    }
    
    // MARK: - Streak Management
    func updateStreak(didCompleteToday: Bool) {
        if didCompleteToday {
            engagementStreak += 1
            awardPoints(for: .dailyStreak)
        } else {
            if engagementStreak > 0 {
                // 스트릭 깨짐 알림
                generateStreakBrokenMessage()
            }
            engagementStreak = 0
        }
        
        saveEngagementData()
    }
    
    // MARK: - Daily Goals
    private func setupDailyGoals() {
        let today = Date()
        let calendar = Calendar.current
        
        dailyGoals = [
            DailyGoal(
                id: "emotion_record",
                title: "감정 기록하기",
                description: "하루에 최소 1번 감정을 기록하세요",
                targetCount: 1,
                currentCount: 0,
                points: 10,
                isCompleted: false
            ),
            DailyGoal(
                id: "expert_insight",
                title: "전문가 인사이트 확인",
                description: "전문가 팀의 조언을 확인하세요",
                targetCount: 1,
                currentCount: 0,
                points: 15,
                isCompleted: false
            ),
            DailyGoal(
                id: "reflection_time",
                title: "성찰 시간 갖기",
                description: "과거 감정 데이터를 돌아보며 패턴을 파악하세요",
                targetCount: 1,
                currentCount: 0,
                points: 20,
                isCompleted: false
            )
        ]
    }
    
    func updateDailyGoal(id: String) {
        guard let index = dailyGoals.firstIndex(where: { $0.id == id }) else { return }
        
        dailyGoals[index].currentCount += 1
        
        if dailyGoals[index].currentCount >= dailyGoals[index].targetCount && !dailyGoals[index].isCompleted {
            dailyGoals[index].isCompleted = true
            awardPoints(for: .dailyGoalCompleted)
            generateGoalCompletionMessage(goal: dailyGoals[index])
        }
        
        saveEngagementData()
    }
    
    // MARK: - Weekly Challenge
    private func generateWeeklyChallenge() {
        let challenges = [
            WeeklyChallenge(
                id: "emotion_variety",
                title: "감정 스펙트럼 탐험",
                description: "이번 주에 5가지 이상의 다양한 감정을 기록해보세요",
                targetCount: 5,
                currentCount: 0,
                points: 50,
                startDate: Date(),
                endDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
            ),
            WeeklyChallenge(
                id: "consistent_recording",
                title: "꾸준한 기록 챌린지",
                description: "7일 연속 매일 감정을 기록해보세요",
                targetCount: 7,
                currentCount: 0,
                points: 75,
                startDate: Date(),
                endDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
            ),
            WeeklyChallenge(
                id: "expert_engagement",
                title: "전문가와 소통하기",
                description: "전문가 팀의 추천사항을 3번 이상 실행해보세요",
                targetCount: 3,
                currentCount: 0,
                points: 60,
                startDate: Date(),
                endDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
            )
        ]
        
        weeklyChallenge = challenges.randomElement()
    }
    
    func updateWeeklyChallenge(type: WeeklyChallengeType) {
        guard let challenge = weeklyChallenge else { return }
        
        weeklyChallenge?.currentCount += 1
        
        if weeklyChallenge?.currentCount ?? 0 >= challenge.targetCount {
            completeWeeklyChallenge()
        }
    }
    
    private func completeWeeklyChallenge() {
        guard let challenge = weeklyChallenge else { return }
        
        awardPoints(for: .weeklyChallengeCompleted)
        generateChallengeCompletionMessage(challenge: challenge)
        
        // 새로운 주간 챌린지 생성
        generateWeeklyChallenge()
    }
    
    // MARK: - Achievements
    private func updateAchievements(for action: UserAction) {
        let newAchievements = checkForNewAchievements(basedOn: action)
        achievements.append(contentsOf: newAchievements)
        
        for achievement in newAchievements {
            generateAchievementMessage(achievement: achievement)
        }
    }
    
    private func checkForNewAchievements(basedOn action: UserAction) -> [Achievement] {
        var newAchievements: [Achievement] = []
        
        // 스트릭 기반 업적
        if action == .dailyStreak {
            let streakAchievements = [
                (7, "일주일 연속", "7일 연속으로 감정을 기록했습니다!"),
                (30, "한달 마스터", "30일 연속 기록의 대업적을 달성했습니다!"),
                (100, "백일장", "100일 연속! 당신은 진정한 감정 전문가입니다!")
            ]
            
            for (days, title, description) in streakAchievements {
                if engagementStreak == days && !achievements.contains(where: { $0.id == "streak_\(days)" }) {
                    newAchievements.append(Achievement(
                        id: "streak_\(days)",
                        title: title,
                        description: description,
                        icon: "flame.fill",
                        rarity: days >= 100 ? .legendary : days >= 30 ? .epic : .rare,
                        unlockedDate: Date()
                    ))
                }
            }
        }
        
        // 포인트 기반 업적
        let pointAchievements = [
            (100, "첫 걸음", "첫 100포인트를 달성했습니다!"),
            (500, "중급자", "500포인트 달성! 꾸준한 노력이 빛납니다!"),
            (1000, "전문가", "1000포인트 달성! 감정 관리의 달인입니다!")
        ]
        
        for (points, title, description) in pointAchievements {
            if totalPoints >= points && !achievements.contains(where: { $0.id == "points_\(points)" }) {
                newAchievements.append(Achievement(
                    id: "points_\(points)",
                    title: title,
                    description: description,
                    icon: "star.fill",
                    rarity: points >= 1000 ? .legendary : points >= 500 ? .epic : .common,
                    unlockedDate: Date()
                ))
            }
        }
        
        return newAchievements
    }
    
    // MARK: - Motivational Messages
    private func generateMotivationalMessage(for action: UserAction) {
        let messages = action.motivationalMessages
        motivationalMessage = messages.randomElement() ?? "훌륭한 진전입니다!"
    }
    
    private func generateGoalCompletionMessage(goal: DailyGoal) {
        motivationalMessage = "🎉 '\(goal.title)' 목표를 달성했습니다! \(goal.points)포인트를 획득했어요!"
    }
    
    private func generateChallengeCompletionMessage(challenge: WeeklyChallenge) {
        motivationalMessage = "🏆 주간 챌린지 '\(challenge.title)'를 완료했습니다! \(challenge.points)포인트 획득!"
    }
    
    private func generateAchievementMessage(achievement: Achievement) {
        motivationalMessage = "🌟 새로운 업적 달성: '\(achievement.title)'! \(achievement.description)"
    }
    
    private func generateStreakBrokenMessage() {
        motivationalMessage = "💔 \(engagementStreak)일 스트릭이 끊어졌지만 괜찮아요! 다시 시작해보세요."
    }
    
    private func triggerLevelUpCelebration() {
        motivationalMessage = "🎊 레벨업! 이제 '\(currentLevel.rawValue)'가 되었습니다!"
    }
    
    // MARK: - Data Persistence
    private func saveEngagementData() {
        userDefaults.set(engagementStreak, forKey: "engagementStreak")
        userDefaults.set(totalPoints, forKey: "totalPoints")
        userDefaults.set(currentLevel.rawValue, forKey: "currentLevel")
        
        // 업적과 목표 저장은 더 복잡한 로직 필요 (Core Data 또는 JSON 인코딩)
    }
    
    private func loadEngagementData() {
        engagementStreak = userDefaults.integer(forKey: "engagementStreak")
        totalPoints = userDefaults.integer(forKey: "totalPoints")
        
        if let levelString = userDefaults.string(forKey: "currentLevel"),
           let level = UserLevel(rawValue: levelString) {
            currentLevel = level
        }
    }
    
    // MARK: - Analytics
    func getEngagementAnalytics() -> EngagementAnalytics {
        let completedGoals = dailyGoals.filter { $0.isCompleted }.count
        let goalCompletionRate = dailyGoals.isEmpty ? 0.0 : Double(completedGoals) / Double(dailyGoals.count)
        
        return EngagementAnalytics(
            totalPoints: totalPoints,
            currentStreak: engagementStreak,
            level: currentLevel,
            goalCompletionRate: goalCompletionRate,
            totalAchievements: achievements.count,
            weeklyProgress: weeklyChallenge?.progressPercentage ?? 0
        )
    }
}

// MARK: - Supporting Models
struct DailyGoal: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let targetCount: Int
    var currentCount: Int
    let points: Int
    var isCompleted: Bool
}

struct WeeklyChallenge: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let targetCount: Int
    var currentCount: Int
    let points: Int
    let startDate: Date
    let endDate: Date
    
    var progressPercentage: Double {
        return min(Double(currentCount) / Double(targetCount), 1.0)
    }
}

enum WeeklyChallengeType {
    case emotionVariety
    case consistentRecording
    case expertEngagement
}

struct Achievement: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let rarity: AchievementRarity
    let unlockedDate: Date
}

enum AchievementRarity: String, Codable, CaseIterable {
    case common = "일반"
    case rare = "희귀"
    case epic = "에픽"
    case legendary = "전설"
    
    var color: Color {
        switch self {
        case .common: return .gray
        case .rare: return .blue
        case .epic: return .purple
        case .legendary: return .gold
        }
    }
}

enum UserAction {
    case emotionRecorded
    case expertInsightViewed
    case recommendationFollowed
    case dailyGoalCompleted
    case weeklyChallengeCompleted
    case achievementUnlocked
    case dailyStreak
    
    var pointValue: Int {
        switch self {
        case .emotionRecorded: return 5
        case .expertInsightViewed: return 10
        case .recommendationFollowed: return 15
        case .dailyGoalCompleted: return 20
        case .weeklyChallengeCompleted: return 50
        case .achievementUnlocked: return 25
        case .dailyStreak: return 5
        }
    }
    
    var motivationalMessages: [String] {
        switch self {
        case .emotionRecorded:
            return [
                "감정을 기록하는 것은 자기 이해의 첫 걸음입니다! 💭",
                "오늘도 감정과 마주한 용기에 박수를! 👏",
                "꾸준한 기록이 변화의 시작이에요! ⭐"
            ]
        case .expertInsightViewed:
            return [
                "전문가의 조언을 확인하셨군요! 지혜로운 선택입니다! 🧠",
                "새로운 관점으로 자신을 바라보는 시간이었기를! 🔍",
                "전문가와 함께하는 성장의 여정! 👨‍⚕️"
            ]
        case .recommendationFollowed:
            return [
                "추천사항을 실행하는 행동력이 멋집니다! 🚀",
                "실천하는 용기가 변화를 만들어냅니다! 💪",
                "한 걸음씩 나아가는 모습이 아름다워요! 🌟"
            ]
        default:
            return ["훌륭한 진전입니다! 계속해서 화이팅! 🎉"]
        }
    }
}

struct EngagementAnalytics {
    let totalPoints: Int
    let currentStreak: Int
    let level: EngagementService.UserLevel
    let goalCompletionRate: Double
    let totalAchievements: Int
    let weeklyProgress: Double
}

extension Color {
    static let gold = Color(red: 1.0, green: 0.84, blue: 0.0)
}