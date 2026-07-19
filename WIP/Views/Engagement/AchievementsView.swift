import SwiftUI

struct AchievementsView: View {
    let achievements: [Achievement]
    @Environment(\.dismiss) private var dismiss
    @State private var selectedRarity: AchievementRarity? = nil
    @State private var searchText = ""
    
    var filteredAchievements: [Achievement] {
        let rarityFiltered = selectedRarity == nil ? achievements : achievements.filter { $0.rarity == selectedRarity }
        
        if searchText.isEmpty {
            return rarityFiltered.sorted { $0.unlockedDate > $1.unlockedDate }
        } else {
            return rarityFiltered.filter { achievement in
                achievement.title.localizedCaseInsensitiveContains(searchText) ||
                achievement.description.localizedCaseInsensitiveContains(searchText)
            }.sorted { $0.unlockedDate > $1.unlockedDate }
        }
    }
    
    var achievementsByRarity: [AchievementRarity: [Achievement]] {
        Dictionary(grouping: achievements) { $0.rarity }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 헤더 통계
                achievementStatsHeader
                
                // 검색 및 필터
                searchAndFilterSection
                
                // 업적 목록
                if filteredAchievements.isEmpty {
                    emptyStateView
                } else {
                    achievementsList
                }
            }
            .navigationTitle("업적")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("완료") {
                        dismiss()
                    }
                    .fontWeight(.medium)
                }
            }
        }
    }
    
    private var achievementStatsHeader: some View {
        VStack(spacing: 16) {
            // 총 업적 카운트
            VStack(spacing: 8) {
                Text("\(achievements.count)")
                    .font(.custom("BMYEONSUNG-OTF", size: 48))
                    .fontWeight(.bold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text("달성한 업적")
                    .font(.custom("BMYEONSUNG-OTF", size: 16))
                    .foregroundColor(.secondary)
            }
            
            // 등급별 통계
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(AchievementRarity.allCases, id: \.self) { rarity in
                    rarityStatsCard(rarity: rarity)
                }
            }
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(.systemBackground), Color(.systemGray6)]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    private func rarityStatsCard(rarity: AchievementRarity) -> some View {
        let count = achievementsByRarity[rarity]?.count ?? 0
        
        return VStack(spacing: 4) {
            Text("\(count)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(rarity.color)
            
            Text(rarity.rawValue)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity)
        .background(rarity.color.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(rarity.color.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var searchAndFilterSection: some View {
        VStack(spacing: 12) {
            // 검색바
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("업적 검색...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            // 등급 필터
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    FilterChip(
                        title: "전체",
                        isSelected: selectedRarity == nil,
                        color: .gray
                    ) {
                        selectedRarity = nil
                    }
                    
                    ForEach(AchievementRarity.allCases, id: \.self) { rarity in
                        FilterChip(
                            title: rarity.rawValue,
                            isSelected: selectedRarity == rarity,
                            color: rarity.color
                        ) {
                            selectedRarity = selectedRarity == rarity ? nil : rarity
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }
    
    private var achievementsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredAchievements, id: \.id) { achievement in
                    AchievementDetailCard(achievement: achievement)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "trophy")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            VStack(spacing: 8) {
                Text(searchText.isEmpty ? "업적이 없습니다" : "검색 결과가 없습니다")
                    .font(.custom("BMYEONSUNG-OTF", size: 18))
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(searchText.isEmpty ? "더 많은 활동으로 첫 업적을 달성해보세요!" : "다른 검색어를 시도해보세요")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .padding()
    }
}

struct AchievementDetailCard: View {
    let achievement: Achievement
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 16) {
            // 업적 아이콘
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                achievement.rarity.color.opacity(0.8),
                                achievement.rarity.color
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                    .overlay(
                        Circle()
                            .stroke(achievement.rarity.color.opacity(0.3), lineWidth: 2)
                    )
                
                Image(systemName: achievement.icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
            }
            
            // 업적 정보
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(achievement.title)
                        .font(.custom("BMYEONSUNG-OTF", size: 16))
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    // 등급 배지
                    Text(achievement.rarity.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(achievement.rarity.color)
                        .cornerRadius(8)
                }
                
                Text(achievement.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.gray)
                        .font(.caption)
                    
                    Text(achievement.unlockedDate, style: .date)
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    if achievement.rarity == .legendary {
                        Image(systemName: "crown.fill")
                            .foregroundColor(.gold)
                            .font(.caption)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(achievement.rarity.color.opacity(0.2), lineWidth: 2)
        )
        .shadow(color: achievement.rarity.color.opacity(0.15), radius: 8, x: 0, y: 4)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6).repeatCount(3, autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : color)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? color : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(color, lineWidth: 1)
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    AchievementsView(achievements: [
        Achievement(
            id: "streak_7",
            title: "일주일 연속",
            description: "7일 연속으로 감정을 기록했습니다! 꾸준함의 힘을 보여주셨네요.",
            icon: "flame.fill",
            rarity: .rare,
            unlockedDate: Date()
        ),
        Achievement(
            id: "points_100",
            title: "첫 걸음",
            description: "첫 100포인트를 달성했습니다! 감정 관리 여정의 시작입니다.",
            icon: "star.fill",
            rarity: .common,
            unlockedDate: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date()
        ),
        Achievement(
            id: "points_1000",
            title: "전문가",
            description: "1000포인트 달성! 감정 관리의 달인이 되셨습니다!",
            icon: "crown.fill",
            rarity: .legendary,
            unlockedDate: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        )
    ])
}