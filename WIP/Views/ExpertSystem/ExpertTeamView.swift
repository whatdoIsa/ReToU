import SwiftUI

struct ExpertTeamView: View {
    @StateObject private var expertManager = ExpertTeamManager()
    @EnvironmentObject private var reflectionStorage: ReflectionStorage
    @State private var selectedExpert: ExpertProtocol? = nil
    @State private var showingExpertDetail = false
    @State private var currentInsights: [ExpertInsight] = []
    @State private var isAnalyzing = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    headerSection
                    
                    // Expert Cards
                    expertCardsSection
                    
                    // Daily Insights
                    if !currentInsights.isEmpty {
                        insightsSection
                    }
                    
                    // Engagement Score
                    engagementSection
                }
                .padding(.horizontal)
            }
            .navigationTitle("전문가 팀")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("분석") {
                        analyzeCurrentData()
                    }
                    .disabled(isAnalyzing)
                }
            }
        }
        .sheet(isPresented: $showingExpertDetail) {
            if let expert = selectedExpert {
                ExpertDetailView(expert: expert, insights: currentInsights.filter { $0.expertId == expert.id })
            }
        }
        .onAppear {
            loadInitialData()
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                Text("AI 전문가 팀")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
            }
            
            Text("5명의 10년+ 경력 전문가가 당신의 감정 데이터를 분석하고 맞춤형 조언을 제공합니다.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(nil)
        }
        .padding(.vertical)
    }
    
    private var expertCardsSection: some View {
        VStack(spacing: 16) {
            ForEach(expertManager.experts, id: \.id) { expert in
                ExpertCard(
                    expert: expert,
                    insight: currentInsights.first { $0.expertId == expert.id }
                ) {
                    selectedExpert = expert
                    showingExpertDetail = true
                }
            }
        }
    }
    
    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("오늘의 인사이트")
                    .font(.headline)
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(currentInsights.prefix(4), id: \.expertId) { insight in
                    InsightCard(insight: insight)
                }
            }
        }
    }
    
    private var engagementSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.green)
                Text("참여도 점수")
                    .font(.headline)
                Spacer()
            }
            
            ProgressView(value: expertManager.userEngagementScore) {
                Text("\(Int(expertManager.userEngagementScore * 100))%")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            .progressViewStyle(LinearProgressViewStyle(tint: .green))
            .scaleEffect(y: 4)
            
            Text(engagementMessage)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.top, 8)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var engagementMessage: String {
        let score = expertManager.userEngagementScore
        switch score {
        case 0.8...1.0:
            return "훌륭합니다! 전문가 조언을 적극적으로 활용하고 있어요."
        case 0.6..<0.8:
            return "좋은 참여도를 보이고 있습니다. 조금 더 활용해보세요!"
        case 0.4..<0.6:
            return "전문가 조언을 더 자주 확인해보시는 것은 어떨까요?"
        default:
            return "전문가 팀과의 상호작용을 시작해보세요!"
        }
    }
    
    private func loadInitialData() {
        // 초기 데이터 로드
        let sampleInteractions: [UserInteraction] = []
        expertManager.updateEngagementScore(based: sampleInteractions)
    }
    
    private func analyzeCurrentData() {
        isAnalyzing = true
        
        // 현재 월의 감정 데이터 분석
        Task {
            // 실제 구현에서는 ReflectionStorage에서 데이터를 가져와야 함
            let sampleData = EmotionStatisticsDTO(
                month: Calendar.current.component(.month, from: Date()),
                year: Calendar.current.component(.year, from: Date()),
                totalEntries: 25,
                averageScore: 0.6,
                emotionCounts: [
                    .happy: 8,
                    .neutral: 10,
                    .tired: 4,
                    .sad: 2,
                    .angry: 1
                ],
                previousPeriodAverage: 0.5
            )
            
            let insights = expertManager.generateTeamAnalysis(for: sampleData)
            
            await MainActor.run {
                currentInsights = insights
                isAnalyzing = false
            }
        }
    }
}

struct ExpertCard: View {
    let expert: ExpertProtocol
    let insight: ExpertInsight?
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Avatar
                Text(expert.avatar)
                    .font(.system(size: 40))
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(expert.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(expert.specialty)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("\(expert.experienceYears)년 경력")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Status Indicator
                if let insight = insight {
                    priorityBadge(insight.priority)
                } else {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    @ViewBuilder
    private func priorityBadge(_ priority: InsightPriority) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(priority.color)
                .frame(width: 8, height: 8)
            
            Text(priority.rawValue)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(priority.color)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(priority.color.opacity(0.1))
        .cornerRadius(8)
    }
}

struct InsightCard: View {
    let insight: ExpertInsight
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(insight.priority.color)
                    .frame(width: 6, height: 6)
                
                Text(insight.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(2)
                
                Spacer()
            }
            
            Text(insight.analysis)
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            HStack {
                ForEach(insight.tags.prefix(2), id: \.self) { tag in
                    Text(tag)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(.systemGray5))
                        .cornerRadius(4)
                }
                Spacer()
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }
}

#Preview {
    ExpertTeamView()
        .environmentObject(ReflectionStorage())
}