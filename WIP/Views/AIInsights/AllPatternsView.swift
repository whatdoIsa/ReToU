import SwiftUI

/// 모든 패턴 보기 뷰 - 신뢰도/평점 기준 랭킹 순 노출
struct AllPatternsView: View {
    let patterns: [PatternInsightDTO]
    @Environment(\.dismiss) private var dismiss
    @State private var sortBy: PatternSortOption = .confidence
    @State private var showFilterSheet = false
    @State private var selectedTypeFilter: Set<PatternType> = []
    @State private var selectedConfidenceFilter: Set<PatternConfidence> = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 필터 및 정렬 헤더
                filterAndSortHeader
                
                // 패턴 목록
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(Array(filteredAndSortedPatterns.enumerated()), id: \.element.id) { index, pattern in
                            RankedPatternCard(
                                pattern: pattern,
                                rank: index + 1,
                                showRank: sortBy == .confidence
                            )
                        }
                        
                        if filteredAndSortedPatterns.isEmpty {
                            EmptyPatternsView()
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("모든 패턴")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("완료") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showFilterSheet = true }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(.system(size: 18))
                    }
                }
            }
        }
        .sheet(isPresented: $showFilterSheet) {
            FilterSheet(
                sortBy: $sortBy,
                selectedTypeFilter: $selectedTypeFilter,
                selectedConfidenceFilter: $selectedConfidenceFilter,
                allTypes: Array(Set(patterns.map(\.type))),
                allConfidences: Array(Set(patterns.map(\.confidence)))
            )
        }
    }
    
    // MARK: - Filter and Sort Header
    
    private var filterAndSortHeader: some View {
        VStack(spacing: 8) {
            HStack {
                Text("\(filteredAndSortedPatterns.count)개 패턴")
                    .font(.custom("BMYEONSUNG-OTF", size: 14))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                HStack(spacing: 12) {
                    // 정렬 버튼들
                    ForEach(PatternSortOption.allCases, id: \.self) { option in
                        Button(action: { sortBy = option }) {
                            Text(option.displayName)
                                .font(.custom("BMYEONSUNG-OTF", size: 12))
                                .foregroundColor(sortBy == option ? .white : .primary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(sortBy == option ? Color.blue : Color.gray.opacity(0.2))
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding(.horizontal)
            
            Divider()
        }
        .padding(.top)
        .background(Color(UIColor.systemBackground))
    }
    
    // MARK: - Computed Properties
    
    private var filteredAndSortedPatterns: [PatternInsightDTO] {
        var result = patterns
        
        // 타입 필터 적용
        if !selectedTypeFilter.isEmpty {
            result = result.filter { selectedTypeFilter.contains($0.type) }
        }
        
        // 신뢰도 필터 적용
        if !selectedConfidenceFilter.isEmpty {
            result = result.filter { selectedConfidenceFilter.contains($0.confidence) }
        }
        
        // 정렬 적용
        switch sortBy {
        case .confidence:
            result = result.sorted { first, second in
                let firstScore = confidenceScore(first.confidence)
                let secondScore = confidenceScore(second.confidence)
                return firstScore > secondScore
            }
        case .type:
            result = result.sorted { $0.type.displayName < $1.type.displayName }
        case .timeframe:
            result = result.sorted { $0.timeframe < $1.timeframe }
        }
        
        return result
    }
    
    private func confidenceScore(_ confidence: PatternConfidence) -> Int {
        switch confidence {
        case .high: return 3
        case .medium: return 2
        case .low: return 1
        }
    }
}

// MARK: - Ranked Pattern Card

/// 순위가 표시되는 패턴 카드
struct RankedPatternCard: View {
    let pattern: PatternInsightDTO
    let rank: Int
    let showRank: Bool
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 헤더: 순위 + 패턴 정보
            HStack(spacing: 12) {
                // 순위 배지
                if showRank {
                    RankBadge(rank: rank)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    // 타입과 신뢰도
                    HStack(spacing: 8) {
                        PatternTypeChip(type: pattern.type)
                        ConfidenceChip(confidence: pattern.confidence)
                        
                        Spacer()
                        
                        Text(pattern.timeframe)
                            .font(.custom("BMYEONSUNG-OTF", size: 10))
                            .foregroundColor(.gray)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.gray.opacity(0.1))
                            )
                    }
                    
                    // 패턴 제목
                    Text(pattern.title)
                        .font(.custom("BMYEONSUNG-OTF", size: 16))
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                }
                
                // 확장 버튼
                Button(action: { isExpanded.toggle() }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14))
                        .foregroundColor(.blue)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .animation(.easeInOut(duration: 0.3), value: isExpanded)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // 확장 가능한 설명
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    Text(pattern.description)
                        .font(.custom("BMYEONSUNG-OTF", size: 14))
                        .foregroundColor(.primary)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    
                    // 추가 메타데이터 (있는 경우)
                    HStack {
                        Label("신뢰도: \(pattern.confidence.rawValue)", systemImage: "checkmark.seal")
                        Spacer()
                        Label("범위: \(pattern.timeframe)", systemImage: "clock")
                    }
                    .font(.custom("BMYEONSUNG-OTF", size: 12))
                    .foregroundColor(.secondary)
                }
                .animation(.easeInOut(duration: 0.3), value: isExpanded)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .gray.opacity(0.1), radius: 4, x: 0, y: 2)
        )
        .onTapGesture {
            isExpanded.toggle()
        }
    }
}

// MARK: - Rank Badge

/// 순위 배지 컴포넌트
struct RankBadge: View {
    let rank: Int
    
    var body: some View {
        VStack(spacing: 2) {
            Text("\(rank)")
                .font(.custom("BMYEONSUNG-OTF", size: 16))
                .fontWeight(.bold)
                .foregroundColor(rankColor)
            
            Text("위")
                .font(.custom("BMYEONSUNG-OTF", size: 8))
                .foregroundColor(rankColor)
        }
        .frame(width: 40, height: 40)
        .background(
            Circle()
                .fill(rankBackgroundColor)
                .overlay(
                    Circle()
                        .stroke(rankColor, lineWidth: 2)
                )
        )
    }
    
    private var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return Color(red: 0.8, green: 0.8, blue: 0.8) // 은색
        case 3: return Color(red: 0.8, green: 0.5, blue: 0.2) // 동색
        default: return .blue
        }
    }
    
    private var rankBackgroundColor: Color {
        switch rank {
        case 1: return Color.yellow.opacity(0.1)
        case 2: return Color.gray.opacity(0.1)
        case 3: return Color.orange.opacity(0.1)
        default: return Color.blue.opacity(0.1)
        }
    }
}

// MARK: - Sort Options

/// 패턴 정렬 옵션
enum PatternSortOption: String, CaseIterable {
    case confidence = "confidence"
    case type = "type"
    case timeframe = "timeframe"
    
    var displayName: String {
        switch self {
        case .confidence: return "신뢰도순"
        case .type: return "타입별"
        case .timeframe: return "기간별"
        }
    }
}

// MARK: - Filter Sheet

/// 필터링 및 정렬 시트
struct FilterSheet: View {
    @Binding var sortBy: PatternSortOption
    @Binding var selectedTypeFilter: Set<PatternType>
    @Binding var selectedConfidenceFilter: Set<PatternConfidence>
    let allTypes: [PatternType]
    let allConfidences: [PatternConfidence]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 24) {
                // 정렬 옵션
                VStack(alignment: .leading, spacing: 12) {
                    Text("정렬 기준")
                        .font(.custom("BMYEONSUNG-OTF", size: 18))
                        .fontWeight(.bold)
                    
                    ForEach(PatternSortOption.allCases, id: \.self) { option in
                        Button(action: { sortBy = option }) {
                            HStack {
                                Text(option.displayName)
                                    .font(.custom("BMYEONSUNG-OTF", size: 16))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                if sortBy == option {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                Divider()
                
                // 타입 필터
                VStack(alignment: .leading, spacing: 12) {
                    Text("패턴 타입")
                        .font(.custom("BMYEONSUNG-OTF", size: 18))
                        .fontWeight(.bold)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 8) {
                        ForEach(allTypes, id: \.self) { type in
                            FilterToggleButton(
                                title: type.displayName,
                                isSelected: selectedTypeFilter.contains(type)
                            ) {
                                if selectedTypeFilter.contains(type) {
                                    selectedTypeFilter.remove(type)
                                } else {
                                    selectedTypeFilter.insert(type)
                                }
                            }
                        }
                    }
                }
                
                Divider()
                
                // 신뢰도 필터
                VStack(alignment: .leading, spacing: 12) {
                    Text("신뢰도")
                        .font(.custom("BMYEONSUNG-OTF", size: 18))
                        .fontWeight(.bold)
                    
                    HStack(spacing: 12) {
                        ForEach(allConfidences, id: \.self) { confidence in
                            FilterToggleButton(
                                title: confidence.rawValue,
                                isSelected: selectedConfidenceFilter.contains(confidence)
                            ) {
                                if selectedConfidenceFilter.contains(confidence) {
                                    selectedConfidenceFilter.remove(confidence)
                                } else {
                                    selectedConfidenceFilter.insert(confidence)
                                }
                            }
                        }
                    }
                }
                
                Spacer()
                
                // 필터 초기화 버튼
                Button("필터 초기화") {
                    selectedTypeFilter.removeAll()
                    selectedConfidenceFilter.removeAll()
                    sortBy = .confidence
                }
                .font(.custom("BMYEONSUNG-OTF", size: 16))
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.blue, lineWidth: 1)
                )
            }
            .padding()
            .navigationTitle("정렬 및 필터")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("완료") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

// MARK: - Filter Toggle Button

struct FilterToggleButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("BMYEONSUNG-OTF", size: 14))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color.blue : Color.gray.opacity(0.2))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Empty State

/// 빈 패턴 상태 뷰
struct EmptyPatternsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass.circle")
                .font(.system(size: 50))
                .foregroundColor(.gray.opacity(0.5))
            
            VStack(spacing: 8) {
                Text("패턴을 찾을 수 없어요")
                    .font(.custom("BMYEONSUNG-OTF", size: 18))
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text("필터 조건을 조정해보세요")
                    .font(.custom("BMYEONSUNG-OTF", size: 14))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

#Preview {
    let samplePatterns = [
        PatternInsightDTO(
            id: UUID(),
            title: "주말 긍정 패턴",
            description: "토요일과 일요일에 평균적으로 더 긍정적인 감정을 경험하고 있습니다. 휴식과 여가 활동이 감정에 긍정적 영향을 미치는 것으로 보입니다.",
            type: .temporal,
            confidence: .high,
            timeframe: "주말"
        ),
        PatternInsightDTO(
            id: UUID(),
            title: "감정 회복 패턴",
            description: "부정적인 감정 이후 평균 1-2일 안에 중립 또는 긍정적인 상태로 돌아오는 회복력을 보이고 있습니다.",
            type: .emotional,
            confidence: .medium,
            timeframe: "1-2일"
        ),
        PatternInsightDTO(
            id: UUID(),
            title: "저녁 시간 스트레스",
            description: "저녁 시간대(6-8시)에 스트레스 관련 감정이 증가하는 패턴이 관찰됩니다.",
            type: .temporal,
            confidence: .low,
            timeframe: "저녁"
        )
    ]
    
    AllPatternsView(patterns: samplePatterns)
}