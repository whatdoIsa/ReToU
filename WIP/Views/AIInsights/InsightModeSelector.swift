import SwiftUI

/// 인사이트 모드 선택기
struct InsightModeSelector: View {
    let currentMode: AIInsightsViewModel.InsightMode
    let onModeChange: (AIInsightsViewModel.InsightMode) -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("분석 방식")
                    .font(.custom("BMYEONSUNG-OTF", size: 16))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Spacer()
            }
            
            HStack(spacing: 12) {
                ModeButton(
                    title: "Foundation Models",
                    subtitle: "Apple Intelligence",
                    icon: "brain.head.profile.fill",
                    isSelected: currentMode == .foundationModels,
                    action: { onModeChange(.foundationModels) }
                )
                
                ModeButton(
                    title: "ChatGPT (예정)",
                    subtitle: "향후 지원 예정",
                    icon: "ellipsis",
                    isSelected: currentMode == .chatGPT,
                    action: { onModeChange(.chatGPT) }
                )
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

struct ModeButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .white : Color(hex: "#4ECFD8"))
                
                VStack(spacing: 2) {
                    Text(title)
                        .font(.custom("BMYEONSUNG-OTF", size: 12))
                        .fontWeight(.bold)
                        .foregroundColor(isSelected ? .white : .black)
                    
                    Text(subtitle)
                        .font(.custom("BMYEONSUNG-OTF", size: 10))
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .gray)
                }
                .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color(hex: "#4ECFD8") : Color.gray.opacity(0.1))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}