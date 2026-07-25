import SwiftUI

struct MonthlySummarySection: View {
    let summary: MonthlySummaryDTO
    let monthComparison: MonthComparisonDTO?
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("월별 요약")
                    .font(.custom("BMYEONSUNG-OTF", size: 18))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Spacer()
                
                if let comparison = monthComparison {
                    ComparisonIndicator(hasImprovement: comparison.hasImprovement)
                }
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                SummaryCard(
                    title: "기록 일수",
                    value: "\(summary.reflectionDays)일",
                    icon: "calendar",
                    color: "#4ECFD8",
                    deltaValue: monthComparison?.reflectionCountChange != nil ? Double(monthComparison!.reflectionCountChange!) : nil,
                    deltaType: .count
                )
                
                SummaryCard(
                    title: "평균 감정",
                    value: summary.dominantEmotion?.rawValue ?? "😐",
                    icon: "heart.fill",
                    color: "#87CEEB",
                    deltaValue: monthComparison?.scoreChange,
                    deltaType: .score
                )
                
                SummaryCard(
                    title: "안정성 점수",
                    value: String(format: "%.1f", summary.stabilityScore),
                    icon: "chart.line.uptrend.xyaxis",
                    color: stabilityColor,
                    deltaValue: nil, // stabilityScoreDelta not available in current DTO
                    deltaType: .score
                )
                
                SummaryCard(
                    title: "주요 감정",
                    value: summary.dominantEmotion?.rawValue ?? "😐",
                    icon: "star.fill",
                    color: "#87CEEB",
                    deltaValue: nil,
                    deltaType: .count
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .gray.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
    
    private var stabilityColor: String {
        switch summary.stabilityScore {
        case 0..<1.0: return "#FF6B35"
        case 1.0..<2.0: return "#FFD700" 
        case 2.0..<3.0: return "#87CEEB"
        case 3.0..<4.0: return "#32CD32"
        default: return "#228B22"
        }
    }
}

struct SummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: String
    let deltaValue: Double?
    let deltaType: DeltaType
    
    enum DeltaType {
        case count
        case score
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: color))
                
                Text(title)
                    .font(.custom("BMYEONSUNG-OTF", size: 14))
                    .foregroundColor(.gray)
                
                Spacer()
                
                if let delta = deltaValue {
                    DeltaIndicator(value: delta)
                }
            }
            
            HStack {
                Text(value)
                    .font(.custom("BMYEONSUNG-OTF", size: 24))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Spacer()
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(hex: color).opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// 중복 정의 제거 - DeltaIndicator는 다른 파일에서 정의됨

struct ComparisonIndicator: View {
    let hasImprovement: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: hasImprovement ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                .font(.system(size: 14))
                .foregroundColor(hasImprovement ? .green : .orange)
            
            Text(hasImprovement ? "개선됨" : "변화")
                .font(.custom("BMYEONSUNG-OTF", size: 12))
                .foregroundColor(hasImprovement ? .green : .orange)
        }
    }
}

#Preview {
    let sampleSummary = MonthlySummaryDTO(
        year: 2024,
        month: 12,
        totalReflections: 15,
        averageScore: 0.5,
        dominantEmotion: .happy,
        improvementFromPreviousMonth: 0.3,
        streakDays: 7,
        reflectionDays: 15,
        totalDaysInMonth: 31,
        stabilityScore: 2.8
    )
    
    let sampleComparison = MonthComparisonDTO(
        currentMonth: sampleSummary,
        previousMonth: nil,
        scoreChange: 0.3,
        reflectionCountChange: 2,
        completionRateChange: 0.1,
        streakChange: 1
    )
    
    MonthlySummarySection(
        summary: sampleSummary,
        monthComparison: sampleComparison
    )
    .padding()
    .background(Color(hex: "#FFF9EC"))
}