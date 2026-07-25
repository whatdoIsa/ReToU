import SwiftUI
import UIKit

struct EngagementDashboard: View {
    @StateObject private var engagementService = EngagementService()
    @State private var showingAchievements = false
    @State private var showingLevelDetails = false
    @State private var animatingMessage = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Motivational Message Banner
                    if !engagementService.motivationalMessage.isEmpty {
                        motivationalBanner
                    }
                    
                    // User Level & Progress
                    userLevelSection
                    
                    // Daily Goals
                    dailyGoalsSection
                    
                    // Weekly Challenge
                    if let challenge = engagementService.weeklyChallenge {
                        weeklyChallengeSection(challenge)
                    }
                    
                    // Quick Stats
                    quickStatsSection
                    
                    // Recent Achievements Preview
                    achievementsPreviewSection
                }
                .padding(.horizontal)
            }
            .navigationTitle("나의 여정")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("업적") {
                        showingAchievements = true
                    }
                }
            }
        }
        .sheet(isPresented: $showingAchievements) {
            AchievementsView(achievements: engagementService.achievements)
        }
        .sheet(isPresented: $showingLevelDetails) {
            LevelDetailsView(
                currentLevel: engagementService.currentLevel,
                totalPoints: engagementService.totalPoints
            )
        }
        .onAppear {
            // 예시 액션으로 테스트
            engagementService.awardPoints(for: .emotionRecorded)
        }
    }
    
    private var motivationalBanner: some View {
        HStack {
            Image(systemName: "sparkles")
                .foregroundColor(.yellow)
                .scaleEffect(animatingMessage ? 1.2 : 1.0)
            
            Text(engagementService.motivationalMessage)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .lineLimit(2)
            
            Spacer()
            
            Button("×") {
                engagementService.motivationalMessage = ""
            }
            .foregroundColor(.gray)
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(12)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                animatingMessage = true
            }
        }
    }
    
    private var userLevelSection: some View {
        VStack(spacing: 16) {
            // Level Badge
            Button(action: { showingLevelDetails = true }) {
                HStack(spacing: 16) {
                    // Level Icon
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        engagementService.currentLevel.color,
                                        engagementService.currentLevel.color.opacity(0.6)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: engagementService.currentLevel.icon)
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    
                    // Level Info
                    VStack(alignment: .leading, spacing: 4) {
                        Text(engagementService.currentLevel.rawValue)
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Text("\(engagementService.totalPoints) 포인트")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        // Progress to next level
                        if let nextLevel = nextLevel {
                            let progress = Double(engagementService.totalPoints - engagementService.currentLevel.pointsRequired) /
                                         Double(nextLevel.pointsRequired - engagementService.currentLevel.pointsRequired)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("다음 레벨까지 \(nextLevel.pointsRequired - engagementService.totalPoints)P")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                ProgressView(value: progress)
                                    .progressViewStyle(LinearProgressViewStyle(tint: engagementService.currentLevel.color))
                                    .frame(height: 4)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(engagementService.currentLevel.color.opacity(0.3), lineWidth: 2)
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            // Streak Display
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(engagementService.engagementStreak)일 연속")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text("꾸준한 감정 기록")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding()
            .background(Color(UIColor.systemGray6))
            .cornerRadius(12)
        }
    }
    
    private var dailyGoalsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "target")
                    .foregroundColor(.blue)
                Text("오늘의 목표")
                    .font(.headline)
                Spacer()
            }
            
            VStack(spacing: 12) {
                ForEach(engagementService.dailyGoals) { goal in
                    DailyGoalCard(
                        goal: goal,
                        onComplete: {
                            engagementService.updateDailyGoal(id: goal.id)
                        }
                    )
                }
            }
        }
    }
    
    private func weeklyChallengeSection(_ challenge: WeeklyChallenge) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "trophy.fill")
                    .foregroundColor(Color.gold)
                Text("이번 주 챌린지")
                    .font(.headline)
                Spacer()
                
                Text("\(challenge.points)P")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Color.gold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gold.opacity(0.1))
                    .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text(challenge.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(challenge.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Progress
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("\(challenge.currentCount)/\(challenge.targetCount)")
                            .font(.caption)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Text("\(Int(challenge.progressPercentage * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    ProgressView(value: challenge.progressPercentage)
                        .progressViewStyle(LinearProgressViewStyle(tint: Color.gold))
                        .frame(height: 8)
                }
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gold.opacity(0.3), lineWidth: 2)
            )
        }
    }
    
    private var quickStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.purple)
                Text("빠른 통계")
                    .font(.headline)
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                StatCard(
                    title: "총 포인트",
                    value: "\(engagementService.totalPoints)",
                    icon: "star.fill",
                    color: .blue
                )
                
                StatCard(
                    title: "업적 개수",
                    value: "\(engagementService.achievements.count)",
                    icon: "award.fill",
                    color: .purple
                )
                
                StatCard(
                    title: "최대 스트릭",
                    value: "\(engagementService.engagementStreak)일",
                    icon: "flame.fill",
                    color: .orange
                )
                
                StatCard(
                    title: "완료한 목표",
                    value: "\(engagementService.dailyGoals.filter { $0.isCompleted }.count)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
            }
        }
    }
    
    private var achievementsPreviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "rosette")
                    .foregroundColor(.purple)
                Text("최근 업적")
                    .font(.headline)
                
                Spacer()
                
                Button("모두 보기") {
                    showingAchievements = true
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            if engagementService.achievements.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "trophy")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    
                    Text("첫 업적을 달성해보세요!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity)
            } else {
                VStack(spacing: 8) {
                    ForEach(engagementService.achievements.suffix(3), id: \.id) { achievement in
                        AchievementRow(achievement: achievement)
                    }
                }
            }
        }
    }
    
    private var nextLevel: EngagementService.UserLevel? {
        let allLevels = EngagementService.UserLevel.allCases
        guard let currentIndex = allLevels.firstIndex(of: engagementService.currentLevel),
              currentIndex < allLevels.count - 1 else {
            return nil
        }
        return allLevels[currentIndex + 1]
    }
}

struct DailyGoalCard: View {
    let goal: DailyGoal
    let onComplete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: {
                if !goal.isCompleted {
                    onComplete()
                }
            }) {
                Image(systemName: goal.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(goal.isCompleted ? .green : .gray)
                    .font(.title3)
            }
            .disabled(goal.isCompleted)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(goal.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .strikethrough(goal.isCompleted, color: .secondary)
                    .foregroundColor(goal.isCompleted ? .secondary : .primary)
                
                Text(goal.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(goal.points)P")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                Text("\(goal.currentCount)/\(goal.targetCount)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(goal.isCompleted ? Color(UIColor.systemGray6) : Color(UIColor.systemBackground))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(goal.isCompleted ? Color.green.opacity(0.3) : Color(UIColor.systemGray5), lineWidth: 1)
        )
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct AchievementRow: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: achievement.icon)
                .foregroundColor(achievement.rarity.color)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(achievement.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(achievement.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Text(achievement.rarity.rawValue)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(achievement.rarity.color)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(achievement.rarity.color.opacity(0.1))
                .cornerRadius(6)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    EngagementDashboard()
}