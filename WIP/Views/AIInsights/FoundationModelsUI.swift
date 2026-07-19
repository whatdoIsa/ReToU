import SwiftUI

// 중복 정의 제거 - InsightModeSelector와 ModeButton은 RuleBasedInsightCards.swift에서 정의됨

/// 캐시 상태 카드
struct CacheStatusCard: View {
    @ObservedObject var viewModel: AIInsightsViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 16))
                    .foregroundColor(.blue)
                
                Text("분석 캐시 상태")
                    .font(.custom("BMYEONSUNG-OTF", size: 16))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Spacer()
            }
            
            if let cacheStatus = viewModel.cacheStatus {
                VStack(spacing: 8) {
                    HStack {
                        Text("상태:")
                            .font(.custom("BMYEONSUNG-OTF", size: 12))
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        if cacheStatus.hasCachedReport {
                            HStack(spacing: 4) {
                                Image(systemName: cacheStatus.isValid ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                    .foregroundColor(cacheStatus.isValid ? .green : .orange)
                                    .font(.system(size: 12))
                                
                                Text(cacheStatus.isValid ? "캐시됨" : "만료됨")
                                    .font(.custom("BMYEONSUNG-OTF", size: 12))
                                    .foregroundColor(cacheStatus.isValid ? .green : .orange)
                            }
                        } else {
                            Text("캐시 없음")
                                .font(.custom("BMYEONSUNG-OTF", size: 12))
                                .foregroundColor(.gray)
                        }
                    }
                    
                    if cacheStatus.hasCachedReport {
                        HStack {
                            Text("업데이트:")
                                .font(.custom("BMYEONSUNG-OTF", size: 12))
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            Text(cacheStatus.formattedLastUpdated)
                                .font(.custom("BMYEONSUNG-OTF", size: 12))
                                .foregroundColor(.primary)
                        }
                    }
                }
            } else {
                Text("캐시 정보를 불러오는 중...")
                    .font(.custom("BMYEONSUNG-OTF", size: 12))
                    .foregroundColor(.gray)
            }
            
            // 새로 분석 버튼
            Button(action: {
                Task {
                    await viewModel.forceRefreshInsights()
                }
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 12))
                    
                    Text("새로 분석")
                        .font(.custom("BMYEONSUNG-OTF", size: 13))
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue)
                )
            }
            .disabled(viewModel.isLoading)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
        )
    }
}

/// 인사이트 소스 표시 카드
struct InsightSourceCard: View {
    let source: InsightSource
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: sourceIcon)
                .font(.system(size: 16))
                .foregroundColor(sourceColor)
                .frame(width: 24, height: 24)
                .background(
                    Circle()
                        .fill(sourceColor.opacity(0.15))
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(sourceTitle)
                    .font(.custom("BMYEONSUNG-OTF", size: 14))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Text(sourceDescription)
                    .font(.custom("BMYEONSUNG-OTF", size: 11))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text(source.rawValue)
                .font(.custom("BMYEONSUNG-OTF", size: 10))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(sourceColor)
                )
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(sourceColor.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(sourceColor.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private var sourceIcon: String {
        switch source {
        case .ai: return "brain.head.profile"
        case .ruleBased: return "list.bullet.clipboard"
        case .hybrid: return "gearshape.2"
        }
    }
    
    private var sourceColor: Color {
        switch source {
        case .ai: return .blue
        case .ruleBased: return .green
        case .hybrid: return .purple
        }
    }
    
    private var sourceTitle: String {
        switch source {
        case .ai: return "Apple Intelligence"
        case .ruleBased: return "규칙 기반 분석"
        case .hybrid: return "하이브리드 분석"
        }
    }
    
    private var sourceDescription: String {
        switch source {
        case .ai: return "Foundation Models로 생성된 인사이트"
        case .ruleBased: return "통계적 패턴 분석 결과"
        case .hybrid: return "AI와 규칙 기반 결합"
        }
    }
}

/// Foundation Models 요약 카드
struct FoundationModelsSummaryCard: View {
    let summary: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.blue)
                
                Text("AI 요약")
                    .font(.custom("BMYEONSUNG-OTF", size: 18))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(summary.indices, id: \.self) { index in
                    HStack(alignment: .top, spacing: 8) {
                        Text("\(index + 1).")
                            .font(.custom("BMYEONSUNG-OTF", size: 14))
                            .foregroundColor(.blue)
                            .fontWeight(.semibold)
                        
                        Text(summary[index])
                            .font(.custom("BMYEONSUNG-OTF", size: 14))
                            .lineSpacing(2)
                            .foregroundColor(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
        )
    }
}

/// Foundation Models 패턴 카드
struct FoundationModelsPatternCard: View {
    let patterns: [PatternDTO]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 16))
                    .foregroundColor(.purple)
                
                Text("발견된 패턴")
                    .font(.custom("BMYEONSUNG-OTF", size: 18))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Spacer()
                
                Text("\(patterns.count)개")
                    .font(.custom("BMYEONSUNG-OTF", size: 12))
                    .foregroundColor(.gray)
            }
            
            LazyVStack(spacing: 12) {
                ForEach(patterns.indices, id: \.self) { index in
                    FoundationModelsPatternItem(pattern: patterns[index])
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
        )
    }
}

/// 개별 패턴 항목
struct FoundationModelsPatternItem: View {
    let pattern: PatternDTO
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(pattern.title)
                        .font(.custom("BMYEONSUNG-OTF", size: 15))
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    HStack(spacing: 8) {
                        Text(pattern.type.displayName)
                            .font(.custom("BMYEONSUNG-OTF", size: 10))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(patternTypeColor)
                            )
                        
                        Text(pattern.timeframe.displayName)
                            .font(.custom("BMYEONSUNG-OTF", size: 10))
                            .foregroundColor(.gray)
                        
                        AIConfidenceIndicator(confidence: pattern.confidence)
                    }
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    Text(pattern.description)
                        .font(.custom("BMYEONSUNG-OTF", size: 13))
                        .lineSpacing(2)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    if !pattern.evidence.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("근거:")
                                .font(.custom("BMYEONSUNG-OTF", size: 11))
                                .foregroundColor(.gray)
                            
                            ForEach(pattern.evidence.indices, id: \.self) { index in
                                HStack(alignment: .top, spacing: 4) {
                                    Text("•")
                                        .font(.custom("BMYEONSUNG-OTF", size: 11))
                                        .foregroundColor(.gray)
                                    
                                    Text(pattern.evidence[index])
                                        .font(.custom("BMYEONSUNG-OTF", size: 11))
                                        .foregroundColor(.gray)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                    }
                }
                .transition(.opacity.combined(with: .slide))
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(patternTypeColor.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(patternTypeColor.opacity(0.2), lineWidth: 1)
                )
        )
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.3)) {
                isExpanded.toggle()
            }
        }
    }
    
    private var patternTypeColor: Color {
        switch pattern.type {
        case .emotional: return .red
        case .temporal: return .blue
        case .behavioral: return .green
        case .environmental: return .orange
        case .social: return .purple
        case .physical: return .pink
        case .cognitive: return .indigo
        }
    }
}

/// Foundation Models 액션 카드
struct FoundationModelsActionCard: View {
    let actions: [ActionDTO]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.orange)
                
                Text("추천 액션")
                    .font(.custom("BMYEONSUNG-OTF", size: 18))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Spacer()
                
                Text("\(actions.count)개")
                    .font(.custom("BMYEONSUNG-OTF", size: 12))
                    .foregroundColor(.gray)
            }
            
            LazyVStack(spacing: 12) {
                ForEach(actions.indices, id: \.self) { index in
                    FoundationModelsActionItem(action: actions[index])
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
        )
    }
}

/// 개별 액션 항목
struct FoundationModelsActionItem: View {
    let action: ActionDTO
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: action.category.icon)
                    .font(.system(size: 14))
                    .foregroundColor(categoryColor)
                    .frame(width: 20, height: 20)
                    .background(
                        Circle()
                            .fill(categoryColor.opacity(0.15))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(action.title)
                        .font(.custom("BMYEONSUNG-OTF", size: 15))
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    HStack(spacing: 8) {
                        ActionPriorityBadge(priority: action.priority)
                        
                        Text(action.timeToImplement.displayName)
                            .font(.custom("BMYEONSUNG-OTF", size: 10))
                            .foregroundColor(.gray)
                        
                        AIConfidenceIndicator(confidence: action.estimatedImpact)
                    }
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    Text(action.description)
                        .font(.custom("BMYEONSUNG-OTF", size: 13))
                        .lineSpacing(2)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    if !action.prerequisites.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("준비사항:")
                                .font(.custom("BMYEONSUNG-OTF", size: 11))
                                .foregroundColor(.gray)
                            
                            ForEach(action.prerequisites.indices, id: \.self) { index in
                                HStack(alignment: .top, spacing: 4) {
                                    Text("•")
                                        .font(.custom("BMYEONSUNG-OTF", size: 11))
                                        .foregroundColor(.gray)
                                    
                                    Text(action.prerequisites[index])
                                        .font(.custom("BMYEONSUNG-OTF", size: 11))
                                        .foregroundColor(.gray)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                    }
                }
                .transition(.opacity.combined(with: .slide))
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(categoryColor.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(categoryColor.opacity(0.2), lineWidth: 1)
                )
        )
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.3)) {
                isExpanded.toggle()
            }
        }
    }
    
    private var categoryColor: Color {
        switch action.category {
        case .mindfulness: return .purple
        case .lifestyle: return .green
        case .social: return .blue
        case .professional: return .orange
        case .health: return .red
        case .creative: return .pink
        case .learning: return .indigo
        }
    }
}

/// Foundation Models 메타데이터 카드
struct FoundationModelsMetadataCard: View {
    let report: InsightReportDTO
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                
                Text("분석 정보")
                    .font(.custom("BMYEONSUNG-OTF", size: 16))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Spacer()
            }
            
            VStack(spacing: 8) {
                MetadataRow(title: "분석 ID", value: String(report.analysisId.prefix(8)))
                MetadataRow(title: "생성 시간", value: formatDate(report.generatedAt))
                MetadataRow(title: "신뢰도", value: String(format: "%.1f%%", report.confidence * 100))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale.current
        return formatter.string(from: date)
    }
}

/// 메타데이터 행
struct MetadataRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.custom("BMYEONSUNG-OTF", size: 12))
                .foregroundColor(.gray)
            
            Spacer()
            
            Text(value)
                .font(.custom("BMYEONSUNG-OTF", size: 12))
                .foregroundColor(.primary)
        }
    }
}

/// 신뢰도 표시기
struct AIConfidenceIndicator: View {
    let confidence: Double
    
    var body: some View {
        HStack(spacing: 2) {
            Text(String(format: "%.0f%%", confidence * 100))
                .font(.custom("BMYEONSUNG-OTF", size: 9))
                .foregroundColor(confidenceColor)
            
            Circle()
                .fill(confidenceColor)
                .frame(width: 6, height: 6)
        }
    }
    
    private var confidenceColor: Color {
        switch confidence {
        case 0.8...: return .green
        case 0.6..<0.8: return .orange
        default: return .red
        }
    }
}

/// 액션 우선순위 배지
struct ActionPriorityBadge: View {
    let priority: ActionPriority
    
    var body: some View {
        Text(priority.displayName)
            .font(.custom("BMYEONSUNG-OTF", size: 9))
            .foregroundColor(.white)
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: 3)
                    .fill(priorityColor)
            )
    }
    
    private var priorityColor: Color {
        switch priority {
        case .urgent: return .red
        case .high: return .orange
        case .medium: return .blue
        case .low: return .gray
        }
    }
}

// MARK: - Extensions for ActionCategory icons (not in original contracts)

extension ActionCategory {
    var icon: String {
        switch self {
        case .mindfulness: return "leaf.fill"
        case .lifestyle: return "house.fill"
        case .social: return "person.2.fill"
        case .professional: return "briefcase.fill"
        case .health: return "heart.fill"
        case .creative: return "paintbrush.fill"
        case .learning: return "book.fill"
        }
    }
}