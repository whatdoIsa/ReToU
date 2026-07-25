//
//  LevelDetailsView.swift
//  ReToU
//
//  Created by Emma Lee (UX Designer Agent) on 1/25/25.
//

import SwiftUI

struct LevelDetailsView: View {
    let currentLevel: EngagementService.UserLevel
    let totalPoints: Int
    let nextLevel: EngagementService.UserLevel?
    
    @Environment(\.dismiss) private var dismiss
    @State private var animateProgress = false
    
    init(currentLevel: EngagementService.UserLevel, totalPoints: Int, nextLevel: EngagementService.UserLevel? = nil) {
        self.currentLevel = currentLevel
        self.totalPoints = totalPoints
        
        // Calculate next level if not provided
        if let nextLevel = nextLevel {
            self.nextLevel = nextLevel
        } else {
            let allLevels = EngagementService.UserLevel.allCases
            if let currentIndex = allLevels.firstIndex(of: currentLevel),
               currentIndex < allLevels.count - 1 {
                self.nextLevel = allLevels[currentIndex + 1]
            } else {
                self.nextLevel = nil
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    headerSection
                    
                    // Progress Section
                    progressSection
                    
                    // Benefits Section
                    benefitsSection
                    
                    // All Levels Overview
                    allLevelsSection
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .navigationTitle("레벨 정보")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("완료") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.blue)
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).delay(0.3)) {
                animateProgress = true
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 20) {
            // Level Badge
            ZStack {
                // Background Circle with gradient
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                currentLevel.color,
                                currentLevel.color.opacity(0.6)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .shadow(color: currentLevel.color.opacity(0.3), radius: 20, x: 0, y: 10)
                
                // Level Icon
                Image(systemName: currentLevel.icon)
                    .font(.system(size: 40, weight: .medium))
                    .foregroundColor(.white)
            }
            .scaleEffect(animateProgress ? 1.0 : 0.8)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: animateProgress)
            
            // Level Title
            VStack(spacing: 8) {
                Text(currentLevel.rawValue)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("\(totalPoints) 포인트")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .opacity(animateProgress ? 1.0 : 0.0)
            .animation(.easeInOut(duration: 0.8).delay(0.5), value: animateProgress)
        }
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
    
    // MARK: - Progress Section
    private var progressSection: some View {
        VStack(spacing: 20) {
            if let nextLevel = nextLevel {
                VStack(alignment: .leading, spacing: 16) {
                    // Section Header
                    HStack {
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundColor(currentLevel.color)
                            .font(.title2)
                        
                        Text("다음 레벨까지")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    
                    // Next Level Preview
                    HStack(spacing: 16) {
                        // Next Level Icon
                        ZStack {
                            Circle()
                                .fill(nextLevel.color.opacity(0.2))
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: nextLevel.icon)
                                .font(.title2)
                                .foregroundColor(nextLevel.color)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(nextLevel.rawValue)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Text("\(nextLevel.pointsRequired) 포인트 필요")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text("\(nextLevel.pointsRequired - totalPoints)P 남음")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(nextLevel.color)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(nextLevel.color.opacity(0.1))
                            .cornerRadius(12)
                    }
                    
                    // Progress Bar
                    let currentLevelPoints = totalPoints - currentLevel.pointsRequired
                    let pointsNeeded = nextLevel.pointsRequired - currentLevel.pointsRequired
                    let progress = Double(currentLevelPoints) / Double(pointsNeeded)
                    
                    VStack(spacing: 8) {
                        HStack {
                            Text("\(currentLevelPoints)/\(pointsNeeded)")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text("\(Int(progress * 100))%")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.systemGray5))
                                    .frame(height: 12)
                                
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                currentLevel.color,
                                                nextLevel.color
                                            ]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(
                                        width: animateProgress ? geometry.size.width * progress : 0,
                                        height: 12
                                    )
                                    .animation(.easeInOut(duration: 1.5).delay(0.8), value: animateProgress)
                            }
                        }
                        .frame(height: 12)
                    }
                }
            } else {
                // Max Level Reached
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "crown.fill")
                            .foregroundColor(.gold)
                            .font(.title2)
                        
                        Text("최고 레벨 달성!")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    
                    Text("축하합니다! 모든 레벨을 달성하여 감정 여정의 마스터가 되었습니다.")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
    
    // MARK: - Benefits Section
    private var benefitsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "gift.fill")
                    .foregroundColor(currentLevel.color)
                    .font(.title2)
                
                Text("레벨 혜택")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(getBenefitsForLevel(currentLevel), id: \.title) { benefit in
                    BenefitCard(benefit: benefit)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
    
    // MARK: - All Levels Section
    private var allLevelsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "list.bullet.circle.fill")
                    .foregroundColor(.blue)
                    .font(.title2)
                
                Text("모든 레벨")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            LazyVStack(spacing: 12) {
                ForEach(EngagementService.UserLevel.allCases, id: \.self) { level in
                    LevelRow(
                        level: level,
                        isCurrentLevel: level == currentLevel,
                        isUnlocked: totalPoints >= level.pointsRequired
                    )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
    
    // MARK: - Helper Functions
    private func getBenefitsForLevel(_ level: EngagementService.UserLevel) -> [LevelBenefit] {
        switch level {
        case .beginner:
            return [
                LevelBenefit(icon: "heart.fill", title: "감정 탐험 시작", description: "기본 감정 기록", color: .green),
                LevelBenefit(icon: "book.fill", title: "일일 목표", description: "기초 목표 설정", color: .blue)
            ]
        case .intermediate:
            return [
                LevelBenefit(icon: "chart.line.uptrend.xyaxis", title: "통계 분석", description: "기본 통계 확인", color: .blue),
                LevelBenefit(icon: "lightbulb.fill", title: "개인 인사이트", description: "패턴 분석 제공", color: .orange)
            ]
        case .advanced:
            return [
                LevelBenefit(icon: "brain.head.profile", title: "AI 인사이트", description: "고급 AI 분석", color: .purple),
                LevelBenefit(icon: "target", title: "맞춤 목표", description: "개인화된 목표", color: .red)
            ]
        case .expert:
            return [
                LevelBenefit(icon: "person.3.fill", title: "전문가 팀", description: "전문가 조언 접근", color: .orange),
                LevelBenefit(icon: "trophy.fill", title: "주간 챌린지", description: "고급 챌린지 참여", color: .gold)
            ]
        case .master:
            return [
                LevelBenefit(icon: "star.circle.fill", title: "모든 기능", description: "전체 기능 접근", color: .gold),
                LevelBenefit(icon: "crown.fill", title: "마스터 배지", description: "특별 인정 배지", color: .gold)
            ]
        }
    }
}

// MARK: - Supporting Views

struct BenefitCard: View {
    let benefit: LevelBenefit
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: benefit.icon)
                .font(.title2)
                .foregroundColor(benefit.color)
            
            VStack(spacing: 4) {
                Text(benefit.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(benefit.description)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(benefit.color.opacity(0.1))
        )
    }
}

struct LevelRow: View {
    let level: EngagementService.UserLevel
    let isCurrentLevel: Bool
    let isUnlocked: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Level Icon
            ZStack {
                Circle()
                    .fill(isUnlocked ? level.color : Color(.systemGray5))
                    .frame(width: 44, height: 44)
                
                Image(systemName: level.icon)
                    .font(.title3)
                    .foregroundColor(isUnlocked ? .white : .gray)
            }
            
            // Level Info
            VStack(alignment: .leading, spacing: 4) {
                Text(level.rawValue)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isUnlocked ? .primary : .secondary)
                
                Text("\(level.pointsRequired) 포인트 필요")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Current Level Badge
            if isCurrentLevel {
                Text("현재")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(level.color)
                    .cornerRadius(12)
            } else if !isUnlocked {
                Image(systemName: "lock.fill")
                    .foregroundColor(.gray)
                    .font(.title3)
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title3)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isCurrentLevel ? level.color.opacity(0.1) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isCurrentLevel ? level.color.opacity(0.3) : Color.clear, lineWidth: 2)
        )
    }
}

// MARK: - Supporting Models

struct LevelBenefit {
    let icon: String
    let title: String
    let description: String
    let color: Color
}

// MARK: - Preview

#Preview {
    LevelDetailsView(
        currentLevel: .intermediate,
        totalPoints: 150
    )
}