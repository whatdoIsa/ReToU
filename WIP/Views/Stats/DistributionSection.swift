import SwiftUI

struct DistributionSection: View {
    let distribution: [EmotionDistributionItemDTO]
    let onEmotionTap: ((EmotionType) -> Void)?
    @State private var showChart: Bool = true
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("감정 분포")
                    .font(.custom("BMYEONSUNG-OTF", size: 18))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Spacer()
                
                HStack(spacing: 8) {
                    Button(action: { showChart = true }) {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 14))
                            .foregroundColor(showChart ? .white : .gray)
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(showChart ? Color(hex: "#4ECFD8") : Color.clear)
                            )
                    }
                    
                    Button(action: { showChart = false }) {
                        Image(systemName: "chart.pie.fill")
                            .font(.system(size: 14))
                            .foregroundColor(!showChart ? .white : .gray)
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(!showChart ? Color(hex: "#4ECFD8") : Color.clear)
                            )
                    }
                }
            }
            
            if showChart {
                DistributionBarChart(distribution: distribution, onEmotionTap: onEmotionTap)
            } else {
                DistributionDonutChart(distribution: distribution, onEmotionTap: onEmotionTap)
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

struct DistributionBarChart: View {
    let distribution: [EmotionDistributionItemDTO]
    let onEmotionTap: ((EmotionType) -> Void)?
    
    private var maxCount: Int {
        distribution.map(\.count).max() ?? 1
    }
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(distribution, id: \.emotion) { item in
                DistributionBarRow(
                    item: item,
                    maxCount: maxCount,
                    onTap: { onEmotionTap?(item.emotion) }
                )
            }
        }
    }
}

struct DistributionBarRow: View {
    let item: EmotionDistributionItemDTO
    let maxCount: Int
    let onTap: (() -> Void)?
    
    private var barWidth: CGFloat {
        maxCount > 0 ? CGFloat(item.count) / CGFloat(maxCount) : 0
    }
    
    var body: some View {
        Button(action: { onTap?() }) {
            VStack(spacing: 8) {
                HStack {
                    HStack(spacing: 8) {
                        Text(item.emotion.rawValue)
                            .font(.system(size: 20))
                        
                        Text(item.emotion.displayName)
                            .font(.custom("BMYEONSUNG-OTF", size: 14))
                            .foregroundColor(.black)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Text("\(item.count)회")
                            .font(.custom("BMYEONSUNG-OTF", size: 12))
                            .foregroundColor(.gray)
                        
                        Text("(\(String(format: "%.1f", item.percentage))%)")
                            .font(.custom("BMYEONSUNG-OTF", size: 12))
                            .foregroundColor(.gray)
                    }
                }
                
                GeometryReader { geometry in
                    HStack(spacing: 0) {
                        Rectangle()
                            .fill(Color(hex: item.emotion.chartColor))
                            .frame(width: geometry.size.width * barWidth)
                        
                        Spacer(minLength: 0)
                    }
                    .frame(height: 8)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                .frame(height: 8)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(hex: item.emotion.chartColor).opacity(0.2), lineWidth: 1)
                )
        )
        .buttonStyle(PlainButtonStyle())
    }
}

struct DistributionDonutChart: View {
    let distribution: [EmotionDistributionItemDTO]
    let onEmotionTap: ((EmotionType) -> Void)?
    
    private var totalCount: Int {
        distribution.reduce(0) { $0 + $1.count }
    }
    
    private var angleRanges: [(emotion: EmotionType, startAngle: Angle, endAngle: Angle)] {
        var ranges: [(EmotionType, Angle, Angle)] = []
        var currentAngle: Double = 0
        
        for item in distribution {
            let percentage = totalCount > 0 ? Double(item.count) / Double(totalCount) : 0
            let angleSpan = percentage * 360
            let startAngle = Angle(degrees: currentAngle)
            let endAngle = Angle(degrees: currentAngle + angleSpan)
            
            ranges.append((item.emotion, startAngle, endAngle))
            currentAngle += angleSpan
        }
        
        return ranges
    }
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                ForEach(Array(angleRanges.enumerated()), id: \.offset) { index, range in
                    DonutSlice(
                        startAngle: range.startAngle,
                        endAngle: range.endAngle,
                        emotion: range.emotion,
                        onTap: { onEmotionTap?(range.emotion) }
                    )
                }
                
                VStack(spacing: 4) {
                    Text("총 기록")
                        .font(.custom("BMYEONSUNG-OTF", size: 12))
                        .foregroundColor(.gray)
                    
                    Text("\(totalCount)회")
                        .font(.custom("BMYEONSUNG-OTF", size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                }
            }
            .frame(width: 180, height: 180)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(distribution, id: \.emotion) { item in
                    DistributionLegendItem(
                        item: item,
                        onTap: { onEmotionTap?(item.emotion) }
                    )
                }
            }
        }
    }
}

struct DonutSlice: View {
    let startAngle: Angle
    let endAngle: Angle
    let emotion: EmotionType
    let onTap: (() -> Void)?
    
    var body: some View {
        Button(action: { onTap?() }) {
            Path { path in
                let center = CGPoint(x: 90, y: 90)
                let outerRadius: CGFloat = 80
                let innerRadius: CGFloat = 50
                
                path.addArc(center: center, radius: outerRadius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
                path.addArc(center: center, radius: innerRadius, startAngle: endAngle, endAngle: startAngle, clockwise: true)
                path.closeSubpath()
            }
            .fill(Color(hex: emotion.chartColor))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct DistributionLegendItem: View {
    let item: EmotionDistributionItemDTO
    let onTap: (() -> Void)?
    
    var body: some View {
        Button(action: { onTap?() }) {
            HStack(spacing: 6) {
                Circle()
                    .fill(Color(hex: item.emotion.chartColor))
                    .frame(width: 8, height: 8)
                
                Text(item.emotion.rawValue)
                    .font(.system(size: 14))
                
                Text("\(item.count)")
                    .font(.custom("BMYEONSUNG-OTF", size: 12))
                    .foregroundColor(.gray)
                
                Spacer()
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    let sampleDistribution = [
        EmotionDistributionItemDTO(emotion: .happy, count: 8, percentage: 35.0, averageScore: 2.0),
        EmotionDistributionItemDTO(emotion: .neutral, count: 6, percentage: 26.0, averageScore: 0.0),
        EmotionDistributionItemDTO(emotion: .tired, count: 5, percentage: 22.0, averageScore: -1.0),
        EmotionDistributionItemDTO(emotion: .sad, count: 3, percentage: 13.0, averageScore: -2.0),
        EmotionDistributionItemDTO(emotion: .angry, count: 1, percentage: 4.0, averageScore: -1.0)
    ]
    
    DistributionSection(
        distribution: sampleDistribution,
        onEmotionTap: { emotion in
            print("Tapped: \(emotion)")
        }
    )
    .padding()
    .background(Color(hex: "#FFF9EC"))
}