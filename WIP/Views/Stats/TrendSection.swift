import SwiftUI

struct TrendSection: View {
    let trendData: [DailyMoodPointDTO]
    let onPointTap: ((Date) -> Void)?
    @State private var selectedPoint: Date?
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("감정 추세")
                    .font(.custom("BMYEONSUNG-OTF", size: 18))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Spacer()
                
                if !trendData.isEmpty {
                    TrendSummaryIndicator(trendData: trendData)
                }
            }
            
            if trendData.isEmpty {
                EmptyTrendView()
            } else {
                TrendLineChart(
                    data: trendData,
                    selectedPoint: $selectedPoint,
                    onPointTap: onPointTap
                )
                
                if let selectedPoint = selectedPoint,
                   let pointData = trendData.first(where: { Calendar.current.isDate($0.date ?? Date(), inSameDayAs: selectedPoint) }) {
                    SelectedPointInfo(pointData: pointData)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .gray.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}

struct TrendLineChart: View {
    let data: [DailyMoodPointDTO]
    @Binding var selectedPoint: Date?
    let onPointTap: ((Date) -> Void)?
    
    private var sortedData: [DailyMoodPointDTO] {
        data.compactMap { point in
            guard point.date != nil else { return nil }
            return point
        }.sorted { ($0.date ?? Date()) < ($1.date ?? Date()) }
    }
    
    private var minScore: Double {
        sortedData.map(\.score).min() ?? -2.0
    }
    
    private var maxScore: Double {
        sortedData.map(\.score).max() ?? 2.0
    }
    
    private var scoreRange: Double {
        max(maxScore - minScore, 0.1)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            GeometryReader { geometry in
                ZStack {
                    // Grid lines
                    TrendGridLines(geometry: geometry)
                    
                    // Trend line
                    TrendLine(
                        data: sortedData,
                        geometry: geometry,
                        minScore: minScore,
                        scoreRange: scoreRange
                    )
                    
                    // Data points
                    ForEach(Array(sortedData.enumerated()), id: \.offset) { index, point in
                        if let date = point.date {
                            TrendPoint(
                                point: point,
                                position: pointPosition(for: index, in: geometry),
                                isSelected: selectedPoint != nil && Calendar.current.isDate(date, inSameDayAs: selectedPoint!),
                                onTap: {
                                    selectedPoint = date
                                    onPointTap?(date)
                                }
                            )
                        }
                    }
                }
            }
            .frame(height: 200)
            
            // X-axis labels
            HStack {
                ForEach(Array(sortedData.enumerated()), id: \.offset) { index, point in
                    if index % max(1, sortedData.count / 5) == 0, let date = point.date {
                        Text(formatDateLabel(date))
                            .font(.custom("BMYEONSUNG-OTF", size: 10))
                            .foregroundColor(.gray)
                        
                        if index < sortedData.count - 1 {
                            Spacer()
                        }
                    }
                }
            }
        }
    }
    
    private func pointPosition(for index: Int, in geometry: GeometryProxy) -> CGPoint {
        let xStep = geometry.size.width / max(1, CGFloat(sortedData.count - 1))
        let x = CGFloat(index) * xStep
        
        let point = sortedData[index]
        let normalizedY = (point.score - minScore) / scoreRange
        let y = geometry.size.height * (1 - normalizedY)
        
        return CGPoint(x: x, y: y)
    }
    
    private func formatDateLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: date)
    }
}

struct TrendGridLines: View {
    let geometry: GeometryProxy
    
    var body: some View {
        Path { path in
            let stepY = geometry.size.height / 4
            
            // Horizontal grid lines
            for i in 0...4 {
                let y = CGFloat(i) * stepY
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: geometry.size.width, y: y))
            }
        }
        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
    }
}

struct TrendLine: View {
    let data: [DailyMoodPointDTO]
    let geometry: GeometryProxy
    let minScore: Double
    let scoreRange: Double
    
    var body: some View {
        Path { path in
            guard data.count > 1 else { return }
            
            let xStep = geometry.size.width / max(1, CGFloat(data.count - 1))
            
            for (index, point) in data.enumerated() {
                let x = CGFloat(index) * xStep
                let normalizedY = (point.score - minScore) / scoreRange
                let y = geometry.size.height * (1 - normalizedY)
                
                if index == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
        }
        .stroke(
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#4ECFD8"), Color(hex: "#87CEEB")]),
                startPoint: .leading,
                endPoint: .trailing
            ),
            style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
        )
    }
}

struct TrendPoint: View {
    let point: DailyMoodPointDTO
    let position: CGPoint
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: isSelected ? 16 : 12, height: isSelected ? 16 : 12)
                    .shadow(color: .gray.opacity(0.3), radius: 2)
                
                Circle()
                    .fill(Color(hex: point.emotion.chartColor))
                    .frame(width: isSelected ? 12 : 8, height: isSelected ? 12 : 8)
                
                if isSelected {
                    Circle()
                        .stroke(Color(hex: "#4ECFD8"), lineWidth: 2)
                        .frame(width: 20, height: 20)
                }
            }
        }
        .position(position)
        .buttonStyle(PlainButtonStyle())
    }
}

struct TrendSummaryIndicator: View {
    let trendData: [DailyMoodPointDTO]
    
    private var trendDirection: TrendDirection {
        guard trendData.count >= 2 else { return .stable }
        
        let sortedData = trendData.compactMap { $0.date != nil ? $0 : nil }
            .sorted { ($0.date ?? Date()) < ($1.date ?? Date()) }
        
        guard sortedData.count >= 2 else { return .stable }
        
        let recentData = Array(sortedData.suffix(min(7, sortedData.count)))
        let firstHalf = Array(recentData.prefix(recentData.count / 2))
        let secondHalf = Array(recentData.suffix(recentData.count / 2))
        
        let firstAvg = firstHalf.reduce(0.0) { $0 + $1.score } / Double(firstHalf.count)
        let secondAvg = secondHalf.reduce(0.0) { $0 + $1.score } / Double(secondHalf.count)
        
        let difference = secondAvg - firstAvg
        
        if difference > 0.3 {
            return .improving
        } else if difference < -0.3 {
            return .declining
        } else {
            return .stable
        }
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: trendDirection.icon)
                .font(.system(size: 12))
                .foregroundColor(trendDirection.color)
            
            Text(trendDirection.label)
                .font(.custom("BMYEONSUNG-OTF", size: 12))
                .foregroundColor(trendDirection.color)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(trendDirection.color.opacity(0.1))
        )
    }
}

struct SelectedPointInfo: View {
    let pointData: DailyMoodPointDTO
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                if let date = pointData.date {
                    Text(formatSelectedDate(date))
                        .font(.custom("BMYEONSUNG-OTF", size: 14))
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                }
                
                HStack(spacing: 6) {
                    Text(pointData.emotion.rawValue)
                        .font(.system(size: 16))
                    
                    Text(pointData.emotion.displayName)
                        .font(.custom("BMYEONSUNG-OTF", size: 14))
                        .foregroundColor(.gray)
                    
                    Text("(\(String(format: "%.1f", pointData.score)))")
                        .font(.custom("BMYEONSUNG-OTF", size: 12))
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Circle()
                .fill(Color(hex: pointData.emotion.chartColor))
                .frame(width: 12, height: 12)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(hex: pointData.emotion.chartColor).opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(hex: pointData.emotion.chartColor).opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private func formatSelectedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "M월 d일 (E)"
        return formatter.string(from: date)
    }
}

struct EmptyTrendView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 40))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("표시할 추세 데이터가 없습니다")
                .font(.custom("BMYEONSUNG-OTF", size: 14))
                .foregroundColor(.gray)
            
            Text("감정을 기록하면 시간에 따른 변화를 확인할 수 있어요")
                .font(.custom("BMYEONSUNG-OTF", size: 12))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(height: 150)
    }
}

enum TrendDirection {
    case improving
    case declining
    case stable
    
    var icon: String {
        switch self {
        case .improving: return "arrow.up.circle.fill"
        case .declining: return "arrow.down.circle.fill"
        case .stable: return "minus.circle.fill"
        }
    }
    
    var label: String {
        switch self {
        case .improving: return "개선 중"
        case .declining: return "주의 필요"
        case .stable: return "안정적"
        }
    }
    
    var color: Color {
        switch self {
        case .improving: return .green
        case .declining: return .orange
        case .stable: return .blue
        }
    }
}

#Preview {
    let sampleTrend = [
        DailyMoodPointDTO(dateKey: Calendar.current.date(byAdding: .day, value: -6, to: Date())!.dayKey, score: 0.0, emotion: .neutral, hasReflection: true),
        DailyMoodPointDTO(dateKey: Calendar.current.date(byAdding: .day, value: -5, to: Date())!.dayKey, score: 1.5, emotion: .happy, hasReflection: true),
        DailyMoodPointDTO(dateKey: Calendar.current.date(byAdding: .day, value: -4, to: Date())!.dayKey, score: -1.0, emotion: .tired, hasReflection: true),
        DailyMoodPointDTO(dateKey: Calendar.current.date(byAdding: .day, value: -3, to: Date())!.dayKey, score: 0.5, emotion: .neutral, hasReflection: true),
        DailyMoodPointDTO(dateKey: Calendar.current.date(byAdding: .day, value: -2, to: Date())!.dayKey, score: 2.0, emotion: .happy, hasReflection: true),
        DailyMoodPointDTO(dateKey: Calendar.current.date(byAdding: .day, value: -1, to: Date())!.dayKey, score: -1.5, emotion: .sad, hasReflection: true),
        DailyMoodPointDTO(dateKey: Date().dayKey, score: 1.0, emotion: .happy, hasReflection: true)
    ]
    
    TrendSection(
        trendData: sampleTrend,
        onPointTap: { date in
            print("Tapped: \(date)")
        }
    )
    .padding()
    .background(Color(hex: "#FFF9EC"))
}