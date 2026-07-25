import SwiftUI

struct ExpertDetailView: View {
    let expert: ExpertProtocol
    let insights: [ExpertInsight]
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTab = 0
    @State private var dailyTip = ""
    @State private var recommendation: ExpertRecommendation?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Expert Profile
                    expertProfileSection
                    
                    // Tabs
                    tabSelection
                    
                    // Content based on selected tab
                    switch selectedTab {
                    case 0:
                        insightsContent
                    case 1:
                        recommendationsContent
                    case 2:
                        dailyTipsContent
                    default:
                        insightsContent
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle(expert.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("닫기") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .onAppear {
            loadExpertContent()
        }
    }
    
    private var expertProfileSection: some View {
        VStack(spacing: 16) {
            // Avatar and basic info
            HStack(spacing: 16) {
                Text(expert.avatar)
                    .font(.system(size: 60))
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(30)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(expert.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(expert.specialty)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        Text("\(expert.experienceYears)년 경력")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            
            // Description
            Text(expert.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(nil)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
        }
    }
    
    private var tabSelection: some View {
        HStack {
            TabButton(title: "인사이트", isSelected: selectedTab == 0) {
                selectedTab = 0
            }
            TabButton(title: "추천사항", isSelected: selectedTab == 1) {
                selectedTab = 1
            }
            TabButton(title: "데일리 팁", isSelected: selectedTab == 2) {
                selectedTab = 2
            }
        }
        .padding(.horizontal)
    }
    
    private var insightsContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            if insights.isEmpty {
                EmptyStateView(
                    icon: "brain",
                    title: "아직 분석 결과가 없습니다",
                    message: "감정 데이터를 분석하여 전문가 인사이트를 생성하세요."
                )
            } else {
                ForEach(insights, id: \.expertId) { insight in
                    InsightDetailCard(insight: insight)
                }
            }
        }
    }
    
    private var recommendationsContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let recommendation = recommendation {
                RecommendationCard(recommendation: recommendation)
            } else {
                EmptyStateView(
                    icon: "lightbulb",
                    title: "개인화된 추천사항",
                    message: "현재 감정 상태에 맞는 맞춤형 추천을 생성하고 있습니다."
                )
            }
        }
    }
    
    private var dailyTipsContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            DailyTipCard(tip: dailyTip, expertName: expert.name)
            
            // Previous tips (mock data)
            VStack(alignment: .leading, spacing: 8) {
                Text("이전 팁들")
                    .font(.headline)
                
                ForEach(0..<3, id: \.self) { _ in
                    Text(expert.generateDailyTip())
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
            }
        }
    }
    
    private func loadExpertContent() {
        dailyTip = expert.generateDailyTip()
        
        // Generate recommendation with mock context
        let mockContext = EmotionContext(
            currentMood: .neutral,
            recentPattern: [.neutral, .happy, .tired],
            timeOfDay: "오후",
            weekday: "월요일",
            stressLevel: 5
        )
        
        recommendation = expert.provideRecommendation(context: mockContext)
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .cornerRadius(20)
        }
    }
}

struct InsightDetailCard: View {
    let insight: ExpertInsight
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with priority
            HStack {
                Text(insight.title)
                    .font(.headline)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(insight.priority.color)
                        .frame(width: 8, height: 8)
                    
                    Text(insight.priority.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(insight.priority.color)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(insight.priority.color.opacity(0.1))
                .cornerRadius(8)
            }
            
            // Analysis
            Text(insight.analysis)
                .font(.subheadline)
                .foregroundColor(.primary)
                .lineLimit(nil)
            
            // Confidence
            HStack {
                Text("신뢰도")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                ProgressView(value: insight.confidence)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .frame(maxWidth: 100)
                
                Text("\(Int(insight.confidence * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Recommendations
            if !insight.recommendations.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("추천 행동")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    ForEach(insight.recommendations, id: \.self) { recommendation in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "checkmark.circle")
                                .foregroundColor(.green)
                                .font(.caption)
                                .padding(.top, 2)
                            
                            Text(recommendation)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            // Tags
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(insight.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(.systemGray5))
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(insight.priority.color.opacity(0.3), lineWidth: 2)
        )
    }
}

struct RecommendationCard: View {
    let recommendation: ExpertRecommendation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text(recommendation.title)
                    .font(.headline)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: difficultyIcon)
                        .foregroundColor(recommendation.difficulty.color)
                        .font(.caption)
                    
                    Text(recommendation.difficulty.rawValue)
                        .font(.caption)
                        .foregroundColor(recommendation.difficulty.color)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(recommendation.difficulty.color.opacity(0.1))
                .cornerRadius(8)
            }
            
            // Description
            Text(recommendation.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Timeframe
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.blue)
                Text("예상 기간: \(recommendation.timeframe)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Action Items
            VStack(alignment: .leading, spacing: 12) {
                Text("실행 계획")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                ForEach(recommendation.actionItems, id: \.id) { item in
                    ActionItemRow(item: item)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
    }
    
    private var difficultyIcon: String {
        switch recommendation.difficulty {
        case .easy: return "leaf"
        case .medium: return "flame"
        case .hard: return "mountain.2"
        }
    }
}

struct ActionItemRow: View {
    let item: ActionItem
    @State private var isCompleted = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button(action: { isCompleted.toggle() }) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isCompleted ? .green : .gray)
                    .font(.title3)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .strikethrough(isCompleted, color: .secondary)
                    .foregroundColor(isCompleted ? .secondary : .primary)
                
                Text(item.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(nil)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct DailyTipCard: View {
    let tip: String
    let expertName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "quote.bubble")
                    .foregroundColor(.blue)
                    .font(.title2)
                
                Text("오늘의 조언")
                    .font(.headline)
                
                Spacer()
            }
            
            Text(tip)
                .font(.subheadline)
                .foregroundColor(.primary)
                .italic()
                .lineLimit(nil)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            
            HStack {
                Spacer()
                Text("- \(expertName)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.blue.opacity(0.3), lineWidth: 2)
        )
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(.gray)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ExpertDetailView(
        expert: PsychologyExpert(),
        insights: []
    )
}