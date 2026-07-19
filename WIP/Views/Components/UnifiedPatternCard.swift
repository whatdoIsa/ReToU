import SwiftUI

/// 통일된 패턴 카드 - accordion 지원
struct UnifiedPatternCard: View {
    let title: String
    let categoryTag: String
    let categoryColor: Color
    let severity: PatternConfidence // high, medium, low
    let timeScope: String // 주간, 일간, 월간 등
    let summaryText: String
    let detailText: String?
    
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 헤더 - 항상 표시
            Button(action: {
                if detailText != nil {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isExpanded.toggle()
                    }
                }
            }) {
                HStack(spacing: 12) {
                    // 카테고리 칩
                    Text(categoryTag)
                        .font(.custom("BMYEONSUNG-OTF", size: 10))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(categoryColor)
                        )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.custom("BMYEONSUNG-OTF", size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                        
                        HStack(spacing: 8) {
                            // 신뢰도 표시
                            ConfidenceIndicator(confidence: severity)
                            
                            Text(timeScope)
                                .font(.custom("BMYEONSUNG-OTF", size: 11))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    // 확장 버튼 (detailText가 있을 때만)
                    if detailText != nil {
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // 요약 텍스트 - 항상 표시
            Text(summaryText)
                .font(.custom("BMYEONSUNG-OTF", size: 14))
                .foregroundColor(.primary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
            
            // 상세 텍스트 - 펼쳤을 때만 표시
            if isExpanded, let detailText = detailText {
                VStack(alignment: .leading, spacing: 8) {
                    Divider()
                        .padding(.vertical, 4)
                    
                    Text("상세 분석")
                        .font(.custom("BMYEONSUNG-OTF", size: 13))
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    Text(detailText)
                        .font(.custom("BMYEONSUNG-OTF", size: 14))
                        .foregroundColor(.primary)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .transition(.opacity.combined(with: .slide))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(categoryColor.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(categoryColor.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

/// 신뢰도 표시기
struct ConfidenceIndicator: View {
    let confidence: PatternConfidence
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(index < confidenceLevel ? confidenceColor : Color.gray.opacity(0.3))
                    .frame(width: 6, height: 6)
            }
        }
    }
    
    private var confidenceLevel: Int {
        switch confidence {
        case .high: return 3
        case .medium: return 2  
        case .low: return 1
        }
    }
    
    private var confidenceColor: Color {
        switch confidence {
        case .high: return .green
        case .medium: return .orange
        case .low: return .red
        }
    }
}

// MARK: - Helper Extensions

extension PatternInsightDTO {
    /// PatternInsightDTO를 UnifiedPatternCard로 변환
    func toUnifiedCard() -> (title: String, categoryTag: String, categoryColor: Color, severity: PatternConfidence, timeScope: String, summaryText: String, detailText: String?) {
        return (
            title: self.title,
            categoryTag: self.type.displayName,
            categoryColor: self.type.color,
            severity: self.confidence,
            timeScope: self.timeframe,
            summaryText: self.description,
            detailText: nil // 기본적으로 PatternInsightDTO는 description만 가짐
        )
    }
}


extension PatternType {
    var color: Color {
        switch self {
        case .temporal: return Color(hex: "#4ECFD8")
        case .emotional: return Color(hex: "#FF6B6B")
        case .behavioral: return Color(hex: "#4ECDC4")
        case .environmental: return Color(hex: "#45B7D1")
        case .social: return Color(hex: "#96CEB4")
        case .physical: return Color(hex: "#FECA57")
        case .cognitive: return Color(hex: "#A29BFE")
        }
    }
}

extension RuleBasedPatternType {
    var displayName: String {
        switch self {
        case .emotional: return "감정"
        case .lifestyle: return "라이프스타일"
        }
    }
    
    var color: Color {
        switch self {
        case .emotional: return Color(hex: "#4ECFD8")
        case .lifestyle: return Color(hex: "#32CD32")
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        // 간단한 패턴 (상세 없음)
        UnifiedPatternCard(
            title: "주말 긍정 패턴",
            categoryTag: "시간",
            categoryColor: Color(hex: "#4ECFD8"),
            severity: .high,
            timeScope: "주간",
            summaryText: "토요일과 일요일에 평균적으로 더 긍정적인 감정을 경험하고 있습니다.",
            detailText: nil
        )
        
        // 상세 텍스트가 있는 패턴
        UnifiedPatternCard(
            title: "감정 회복 패턴", 
            categoryTag: "감정",
            categoryColor: Color(hex: "#FF6B6B"),
            severity: .medium,
            timeScope: "1-2일",
            summaryText: "부정적인 감정 이후 평균 1-2일 안에 중립 또는 긍정적인 상태로 돌아오는 회복력을 보입니다.",
            detailText: "근거:\n• 지난 30일간 부정적 감정 후 평균 1.3일 내 회복\n• 회복 속도가 점진적으로 개선되는 추세\n• 사회적 활동 후 회복 속도 증가"
        )
    }
    .padding()
    .background(Color(hex: "#FFF9EC"))
}