import SwiftUI

/// 통일된 조언 카드 - Top 액션 노출용
struct UnifiedAdviceCard: View {
    let title: String
    let category: AdviceCategory
    let description: String
    let priority: ActionPriority
    let isActionable: Bool
    let onAction: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // 카테고리 아이콘
            Image(systemName: category.icon)
                .font(.system(size: 18))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(category.color)
                )
            
            // 내용
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(title)
                        .font(.custom("BMYEONSUNG-OTF", size: 16))
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    // 우선순위 배지
                    Text(priority.displayName)
                        .font(.custom("BMYEONSUNG-OTF", size: 9))
                        .foregroundColor(priority.color)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(priority.color.opacity(0.1))
                        )
                }
                
                Text(description)
                    .font(.custom("BMYEONSUNG-OTF", size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            // 실행 버튼
            if isActionable {
                Button(action: onAction) {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(category.color)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(category.color.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(category.color.opacity(0.2), lineWidth: 1.5)
                )
        )
    }
}



// MARK: - Helper Extensions

extension AdviceCategory {
    var color: Color {
        switch self {
        case .emotional: return Color(hex: "#FF6B6B")
        case .lifestyle: return Color(hex: "#4ECDC4")
        case .relationship: return Color(hex: "#45B7D1")
        case .wellness: return Color(hex: "#96CEB4")
        }
    }
    
    var icon: String {
        switch self {
        case .emotional: return "heart.fill"
        case .lifestyle: return "house.fill"
        case .relationship: return "person.2.fill"
        case .wellness: return "leaf.fill"
        }
    }
}

extension AdviceDTO {
    /// AdviceDTO를 UnifiedAdviceCard로 변환
    func toUnifiedCard(onAction: @escaping () -> Void) -> UnifiedAdviceCard {
        return UnifiedAdviceCard(
            title: self.title,
            category: self.category,
            description: self.description,
            priority: .medium, // AdviceDTO에는 priority가 없으므로 기본값
            isActionable: self.actionable,
            onAction: onAction
        )
    }
}

extension RuleBasedActionDTO {
    /// RuleBasedActionDTO를 UnifiedAdviceCard로 변환
    func toUnifiedCard(onAction: @escaping () -> Void) -> UnifiedAdviceCard {
        // RuleBasedActionDTO의 카테고리를 AdviceCategory로 변환
        let adviceCategory: AdviceCategory
        switch self.category {
        case .mindfulness: adviceCategory = .emotional
        case .lifestyle: adviceCategory = .lifestyle
        }
        
        // 우선순위 변환
        let actionPriority: ActionPriority
        switch self.priority {
        case .high: actionPriority = .high
        case .medium: actionPriority = .medium
        case .low: actionPriority = .low
        }
        
        return UnifiedAdviceCard(
            title: self.title,
            category: adviceCategory,
            description: self.description,
            priority: actionPriority,
            isActionable: true, // RuleBasedActionDTO는 기본적으로 actionable
            onAction: onAction
        )
    }
}

/// 조언 목록을 위한 컨테이너 컴포넌트
struct UnifiedAdviceList: View {
    let advice: [AdviceDTO]
    let onAction: (String) -> Void
    let showAll: Bool
    let onShowAll: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("추천 액션")
                    .font(.custom("BMYEONSUNG-OTF", size: 18))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Spacer()
                
                if let onShowAll = onShowAll, advice.count > 2 {
                    Button(action: onShowAll) {
                        Text("모두 보기")
                            .font(.custom("BMYEONSUNG-OTF", size: 12))
                            .foregroundColor(.blue)
                    }
                }
            }
            
            let displayAdvice = showAll ? advice : Array(advice.prefix(2))
            
            if displayAdvice.isEmpty {
                Text("추천할 액션이 없습니다")
                    .font(.custom("BMYEONSUNG-OTF", size: 14))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                ForEach(displayAdvice, id: \.id) { adviceItem in
                    adviceItem.toUnifiedCard {
                        onAction(adviceItem.id.uuidString)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .gray.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        // 단일 조언 카드
        UnifiedAdviceCard(
            title: "감정 인식 시간 늘리기",
            category: .emotional,
            description: "하루 중 감정을 의식적으로 관찰하는 시간을 5분 더 늘려보세요. 감정의 변화를 더 세밀하게 파악할 수 있습니다.",
            priority: .high,
            isActionable: true,
            onAction: { print("감정 인식 액션 실행") }
        )
        
        // 다른 우선순위
        UnifiedAdviceCard(
            title: "주말 루틴 개선",
            category: .lifestyle,
            description: "주말의 긍정적 패턴을 평일에도 적용해보세요.",
            priority: .medium,
            isActionable: true,
            onAction: { print("루틴 개선 액션 실행") }
        )
        
        // 리스트형 컴포넌트
        let sampleAdvice = [
            AdviceDTO(
                id: UUID(),
                category: .wellness,
                title: "명상 시간 추가",
                description: "매일 10분씩 명상하여 마음의 평정을 찾아보세요.",
                actionable: true
            ),
            AdviceDTO(
                id: UUID(),
                category: .relationship,
                title: "사회적 연결 강화",
                description: "친구나 가족과 더 많은 시간을 보내보세요.",
                actionable: true
            )
        ]
        
        UnifiedAdviceList(
            advice: sampleAdvice,
            onAction: { actionId in print("액션 실행: \(actionId)") },
            showAll: false,
            onShowAll: { print("모두 보기 클릭") }
        )
    }
    .padding()
    .background(Color(hex: "#FFF9EC"))
}