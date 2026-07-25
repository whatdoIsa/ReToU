import SwiftUI

/// Apple Intelligence 미지원 환경 안내 카드
struct AIUnsupportedCard: View {
    let reason: UnsupportedReason
    let onFallbackAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // 아이콘과 제목
            HStack(spacing: 12) {
                Image(systemName: reasonIcon)
                    .font(.system(size: 24))
                    .foregroundColor(reasonColor)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Apple Intelligence 제한")
                        .font(.custom("BMYEONSUNG-OTF", size: 16))
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    Text(reasonTitle)
                        .font(.custom("BMYEONSUNG-OTF", size: 14))
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            
            // 설명
            VStack(alignment: .leading, spacing: 8) {
                Text(reasonDescription)
                    .font(.custom("BMYEONSUNG-OTF", size: 13))
                    .lineSpacing(2)
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                
                if !reasonSolution.isEmpty {
                    Text("해결 방법:")
                        .font(.custom("BMYEONSUNG-OTF", size: 12))
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                        .padding(.top, 4)
                    
                    ForEach(reasonSolution.indices, id: \.self) { index in
                        HStack(alignment: .top, spacing: 6) {
                            Text("•")
                                .font(.custom("BMYEONSUNG-OTF", size: 12))
                                .foregroundColor(.gray)
                            
                            Text(reasonSolution[index])
                                .font(.custom("BMYEONSUNG-OTF", size: 12))
                                .foregroundColor(.gray)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
            
            Divider()
                .foregroundColor(.gray.opacity(0.3))
            
            // 대안 제시
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "list.bullet.clipboard")
                        .font(.system(size: 16))
                        .foregroundColor(.green)
                    
                    Text("대신 규칙 기반 분석을 사용할 수 있습니다")
                        .font(.custom("BMYEONSUNG-OTF", size: 13))
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                
                HStack(spacing: 8) {
                    // 규칙 기반 분석 전환 버튼
                    Button(action: onFallbackAction) {
                        HStack {
                            Image(systemName: "arrow.right.circle")
                                .font(.system(size: 12))
                            
                            Text("규칙 기반으로 전환")
                                .font(.custom("BMYEONSUNG-OTF", size: 12))
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.green)
                        )
                    }
                    
                    Spacer()
                    
                    // 정보 버튼
                    Button(action: {
                        // 정보 표시 로직
                        print("AI 지원 정보 표시")
                    }) {
                        HStack {
                            Image(systemName: "info.circle")
                                .font(.system(size: 12))
                            
                            Text("자세히")
                                .font(.custom("BMYEONSUNG-OTF", size: 12))
                        }
                        .foregroundColor(.blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.blue.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(reasonColor.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(reasonColor.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private var reasonIcon: String {
        switch reason {
        case .deviceNotSupported: return "iphone.slash"
        case .osVersionTooOld: return "arrow.up.circle"
        case .featureDisabled: return "gear.badge.xmark"
        case .networkIssue: return "wifi.slash"
        case .unknown: return "questionmark.circle"
        }
    }
    
    private var reasonColor: Color {
        switch reason {
        case .deviceNotSupported: return .red
        case .osVersionTooOld: return .orange
        case .featureDisabled: return .purple
        case .networkIssue: return .blue
        case .unknown: return .gray
        }
    }
    
    private var reasonTitle: String {
        switch reason {
        case .deviceNotSupported: return "지원되지 않는 기기"
        case .osVersionTooOld: return "iOS 버전 업데이트 필요"
        case .featureDisabled: return "기능이 비활성화됨"
        case .networkIssue: return "네트워크 연결 문제"
        case .unknown: return "일시적 오류"
        }
    }
    
    private var reasonDescription: String {
        switch reason {
        case .deviceNotSupported:
            return "현재 기기에서는 Apple Intelligence를 지원하지 않습니다. Apple Intelligence는 A17 Pro 이상의 칩셋을 탑재한 기기에서만 사용할 수 있습니다."
            
        case .osVersionTooOld:
            return "Apple Intelligence를 사용하려면 iOS 18.1 이상이 필요합니다. 현재 iOS 버전을 확인하고 최신 버전으로 업데이트해주세요."
            
        case .featureDisabled:
            return "Apple Intelligence 기능이 설정에서 비활성화되어 있습니다. 시스템 설정에서 기능을 활성화하신 후 다시 시도해주세요."
            
        case .networkIssue:
            return "Apple Intelligence 서비스에 연결할 수 없습니다. 인터넷 연결을 확인하고 다시 시도해주세요."
            
        case .unknown:
            return "Apple Intelligence 서비스에 일시적인 문제가 발생했습니다. 잠시 후 다시 시도해주세요."
        }
    }
    
    private var reasonSolution: [String] {
        switch reason {
        case .deviceNotSupported:
            return [
                "iPhone 15 Pro/Pro Max 이상의 기기 사용",
                "iPad에서는 M1 이상 칩셋 탑재 모델 사용",
                "Mac에서는 M1 이상 칩셋 탑재 모델 사용"
            ]
            
        case .osVersionTooOld:
            return [
                "설정 > 일반 > 소프트웨어 업데이트에서 iOS 18.1 이상으로 업데이트",
                "충분한 저장 공간 확보 후 업데이트 진행"
            ]
            
        case .featureDisabled:
            return [
                "설정 > Apple Intelligence & Siri에서 기능 활성화",
                "언어 설정을 영어(미국) 또는 지원 언어로 변경"
            ]
            
        case .networkIssue:
            return [
                "Wi-Fi 또는 셀룰러 데이터 연결 확인",
                "다른 네트워크로 전환 후 재시도"
            ]
            
        case .unknown:
            return [
                "앱 재시작 후 다시 시도",
                "기기 재부팅 후 다시 시도",
                "잠시 후 다시 시도"
            ]
        }
    }
}

/// AI 미지원 이유 열거형
enum UnsupportedReason {
    case deviceNotSupported    // 지원되지 않는 기기
    case osVersionTooOld      // iOS 버전이 낮음
    case featureDisabled      // 기능이 비활성화됨
    case networkIssue         // 네트워크 문제
    case unknown              // 알 수 없는 오류
}

/// AI 기능 상태 표시 카드
struct AICapabilityStatusCard: View {
    @State private var isCheckingCapability = false
    @State private var capabilityStatus: AICapabilityStatus = .unknown
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 16))
                    .foregroundColor(.blue)
                
                Text("AI 기능 상태")
                    .font(.custom("BMYEONSUNG-OTF", size: 16))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Spacer()
                
                if isCheckingCapability {
                    ProgressView()
                        .scaleEffect(0.7)
                } else {
                    Button(action: checkCapability) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 14))
                            .foregroundColor(.blue)
                    }
                }
            }
            
            VStack(spacing: 8) {
                StatusRow(
                    title: "기기 지원",
                    status: capabilityStatus.deviceSupport,
                    icon: "iphone"
                )
                
                StatusRow(
                    title: "iOS 버전",
                    status: capabilityStatus.osVersion,
                    icon: "gear"
                )
                
                StatusRow(
                    title: "기능 활성화",
                    status: capabilityStatus.featureEnabled,
                    icon: "switch.2"
                )
                
                StatusRow(
                    title: "네트워크 연결",
                    status: capabilityStatus.networkConnection,
                    icon: "network"
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
        )
        .onAppear {
            checkCapability()
        }
    }
    
    private func checkCapability() {
        isCheckingCapability = true
        
        // 실제 환경에서는 각 항목을 실제로 체크
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            capabilityStatus = AICapabilityStatus(
                deviceSupport: checkDeviceSupport(),
                osVersion: checkOSVersion(),
                featureEnabled: checkFeatureEnabled(),
                networkConnection: checkNetworkConnection()
            )
            isCheckingCapability = false
        }
    }
    
    private func checkDeviceSupport() -> CapabilityItemStatus {
        // 실제로는 기기 모델을 체크
        if ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"] != nil {
            return .unsupported("시뮬레이터")
        }
        return .supported
    }
    
    private func checkOSVersion() -> CapabilityItemStatus {
        let version = ProcessInfo.processInfo.operatingSystemVersion
        if version.majorVersion >= 18 && version.minorVersion >= 1 {
            return .supported
        } else {
            return .unsupported("iOS 18.1+ 필요")
        }
    }
    
    private func checkFeatureEnabled() -> CapabilityItemStatus {
        // 실제로는 Apple Intelligence 설정 체크
        return .unknown
    }
    
    private func checkNetworkConnection() -> CapabilityItemStatus {
        // 실제로는 네트워크 연결 체크
        return .supported
    }
}

/// 상태 행
struct StatusRow: View {
    let title: String
    let status: CapabilityItemStatus
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .frame(width: 16)
            
            Text(title)
                .font(.custom("BMYEONSUNG-OTF", size: 12))
                .foregroundColor(.primary)
            
            Spacer()
            
            HStack(spacing: 4) {
                Image(systemName: status.iconName)
                    .font(.system(size: 10))
                    .foregroundColor(status.color)
                
                Text(status.displayText)
                    .font(.custom("BMYEONSUNG-OTF", size: 11))
                    .foregroundColor(status.color)
            }
        }
    }
}

// MARK: - Supporting Types

/// AI 기능 전체 상태
struct AICapabilityStatus {
    let deviceSupport: CapabilityItemStatus
    let osVersion: CapabilityItemStatus
    let featureEnabled: CapabilityItemStatus
    let networkConnection: CapabilityItemStatus
    
    static let unknown = AICapabilityStatus(
        deviceSupport: .unknown,
        osVersion: .unknown,
        featureEnabled: .unknown,
        networkConnection: .unknown
    )
    
    var overallStatus: CapabilityItemStatus {
        let statuses = [deviceSupport, osVersion, featureEnabled, networkConnection]
        
        if statuses.allSatisfy({ $0 == .supported }) {
            return .supported
        } else if statuses.contains(where: { 
            if case .unsupported(_) = $0 { return true }
            return false
        }) {
            return .unsupported("일부 요구사항 미충족")
        } else {
            return .unknown
        }
    }
}

/// 개별 기능 상태
enum CapabilityItemStatus: Equatable {
    case supported
    case unsupported(String)
    case unknown
    
    var iconName: String {
        switch self {
        case .supported: return "checkmark.circle.fill"
        case .unsupported(_): return "xmark.circle.fill"
        case .unknown: return "questionmark.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .supported: return .green
        case .unsupported(_): return .red
        case .unknown: return .gray
        }
    }
    
    var displayText: String {
        switch self {
        case .supported: return "지원됨"
        case .unsupported(let reason): return reason
        case .unknown: return "확인 중"
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        AIUnsupportedCard(reason: .deviceNotSupported) {
            print("규칙 기반으로 전환")
        }
        
        AICapabilityStatusCard()
    }
    .padding()
    .background(Color(hex: "#FFF9EC"))
}