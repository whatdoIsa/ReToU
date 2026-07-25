import SwiftUI

// MARK: - Loading & Error Components

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("AI가 패턴을 분석하고 있어요...")
                .font(.custom("BMYEONSUNG-OTF", size: 16))
                .foregroundColor(.gray)
        }
        .frame(height: 200)
    }
}

struct ErrorMessageCard: View {
    let message: String
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle")
                .foregroundColor(.orange)
            
            Text(message)
                .font(.custom("BMYEONSUNG-OTF", size: 14))
                .foregroundColor(.secondary)
                .lineLimit(nil)
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.orange.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Metadata Sheet

struct MetadataSheet: View {
    @ObservedObject var viewModel: AIInsightsViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // AI 제공자 정보
                    AIProviderInfoCard(viewModel: viewModel)
                    
                    // 캐시 정보
                    if let cacheStatus = viewModel.cacheStatus {
                        CacheInfoCard(cacheStatus: cacheStatus, onClearCache: {
                            Task {
                                await viewModel.clearCacheForCurrentMonth()
                            }
                        })
                    }
                }
                .padding()
            }
            .navigationTitle("분석 정보")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("닫기") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct AIProviderInfoCard: View {
    @ObservedObject var viewModel: AIInsightsViewModel
    
    var body: some View {
        let providerInfo = viewModel.getCurrentProviderInfo()
        
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: providerInfo.icon)
                    .font(.system(size: 24))
                    .foregroundColor(Color(hex: "#4ECFD8"))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(providerInfo.name)
                        .font(.custom("BMYEONSUNG-OTF", size: 16))
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    Text(providerInfo.description)
                        .font(.custom("BMYEONSUNG-OTF", size: 12))
                        .foregroundColor(.gray)
                }
                
                Spacer()
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

struct CacheInfoCard: View {
    let cacheStatus: CacheStatus
    let onClearCache: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("캐시 정보")
                .font(.custom("BMYEONSUNG-OTF", size: 16))
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            if cacheStatus.hasCachedReport {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("마지막 업데이트:")
                        Text(cacheStatus.formattedLastUpdated)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    
                    HStack {
                        Text("파일 크기:")
                        Text(cacheStatus.formattedFileSize)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
                
                Button(action: onClearCache) {
                    Text("캐시 삭제")
                        .font(.custom("BMYEONSUNG-OTF", size: 14))
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                }
            } else {
                Text("캐시된 데이터 없음")
                    .font(.custom("BMYEONSUNG-OTF", size: 14))
                    .foregroundColor(.secondary)
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