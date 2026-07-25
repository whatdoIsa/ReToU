import SwiftUI

/// 모든 조언 보기 뷰 - 우선순위/카테고리 기준 랭킹 순 노출
struct AllAdvicesView: View {
    let advice: [AdviceDTO]
    @Environment(\.dismiss) private var dismiss
    @State private var sortBy: AdviceSortOption = .priority
    @State private var showFilterSheet = false
    @State private var selectedCategoryFilter: Set<AdviceCategory> = []
    @State private var selectedPriorityFilter: Set<ActionPriority> = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 필터 및 정렬 헤더
                filterAndSortHeader
                
                // 조언 목록
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(Array(filteredAndSortedAdvice.enumerated()), id: \.element.id) { index, adviceItem in
                            RankedAdviceCard(
                                advice: adviceItem,
                                rank: index + 1,
                                showRank: sortBy == .priority
                            )
                        }
                        
                        if filteredAndSortedAdvice.isEmpty {
                            EmptyAdviceView()
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("모든 조언")
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
            AdviceFilterSheet(
                sortBy: $sortBy,
                selectedCategoryFilter: $selectedCategoryFilter,
                selectedPriorityFilter: $selectedPriorityFilter,
                allCategories: Array(Set(advice.map(\.category))),
                allPriorities: ActionPriority.allCases
            )
        }
    }
    
    // MARK: - Filter and Sort Header
    
    private var filterAndSortHeader: some View {
        VStack(spacing: 8) {
            HStack {
                Text("\(filteredAndSortedAdvice.count)개 조언")
                    .font(.custom("BMYEONSUNG-OTF", size: 14))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                HStack(spacing: 12) {
                    // 정렬 버튼들
                    ForEach(AdviceSortOption.allCases, id: \.self) { option in
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
    
    private var filteredAndSortedAdvice: [AdviceDTO] {
        var result = advice
        
        // 카테고리 필터 적용
        if !selectedCategoryFilter.isEmpty {
            result = result.filter { selectedCategoryFilter.contains($0.category) }
        }
        
        // 우선순위 필터 적용 (추정된 우선순위 기준)
        if !selectedPriorityFilter.isEmpty {
            result = result.filter { advice in
                let estimatedPriority = estimatePriority(for: advice)
                return selectedPriorityFilter.contains(estimatedPriority)
            }
        }
        
        // 정렬 적용
        switch sortBy {
        case .priority:
            result = result.sorted { first, second in
                let firstScore = priorityScore(estimatePriority(for: first))
                let secondScore = priorityScore(estimatePriority(for: second))
                return firstScore > secondScore
            }
        case .category:
            result = result.sorted { $0.category.displayName < $1.category.displayName }
        case .actionable:
            result = result.sorted { first, second in
                if first.actionable == second.actionable {
                    // 둘 다 actionable이 같으면 우선순위로 정렬
                    let firstScore = priorityScore(estimatePriority(for: first))
                    let secondScore = priorityScore(estimatePriority(for: second))
                    return firstScore > secondScore
                }
                return first.actionable && !second.actionable
            }
        }
        
        return result
    }
    
    private func estimatePriority(for advice: AdviceDTO) -> ActionPriority {
        // AdviceDTO에 우선순위가 없으므로 카테고리와 내용을 기반으로 추정
        let lowercaseTitle = advice.title.lowercased()
        let lowercaseDescription = advice.description.lowercased()
        
        // 긴급성을 나타내는 키워드들
        let urgentKeywords = ["즉시", "urgent", "critical", "위험", "문제", "개선 필요"]
        let moderateKeywords = ["권장", "추천", "consider", "향상", "개선"]
        
        let hasUrgentKeywords = urgentKeywords.contains { keyword in
            lowercaseTitle.contains(keyword) || lowercaseDescription.contains(keyword)
        }
        
        let hasModerateKeywords = moderateKeywords.contains { keyword in
            lowercaseTitle.contains(keyword) || lowercaseDescription.contains(keyword)
        }
        
        if hasUrgentKeywords {
            return .high
        } else if hasModerateKeywords {
            return .medium
        } else {
            // 카테고리에 따른 기본 우선순위
            switch advice.category {
            case .emotional:
                return .high  // 감정적 건강은 높은 우선순위
            case .wellness:
                return .medium  // 웰니스는 중간 우선순위
            case .lifestyle:
                return .medium  // 라이프스타일은 중간 우선순위
            case .relationship:
                return .low  // 관계는 낮은 우선순위 (장기적)
            }
        }
    }
    
    private func priorityScore(_ priority: ActionPriority) -> Int {
        switch priority {
        case .urgent: return 4
        case .high: return 3
        case .medium: return 2
        case .low: return 1
        }
    }
}

// MARK: - Ranked Advice Card

/// 순위가 표시되는 조언 카드
struct RankedAdviceCard: View {
    let advice: AdviceDTO
    let rank: Int
    let showRank: Bool
    @State private var isExpanded = false
    
    private var estimatedPriority: ActionPriority {
        let lowercaseTitle = advice.title.lowercased()
        let lowercaseDescription = advice.description.lowercased()
        
        let urgentKeywords = ["즉시", "urgent", "critical", "위험", "문제", "개선 필요"]
        let moderateKeywords = ["권장", "추천", "consider", "향상", "개선"]
        
        let hasUrgentKeywords = urgentKeywords.contains { keyword in
            lowercaseTitle.contains(keyword) || lowercaseDescription.contains(keyword)
        }
        
        let hasModerateKeywords = moderateKeywords.contains { keyword in
            lowercaseTitle.contains(keyword) || lowercaseDescription.contains(keyword)
        }
        
        if hasUrgentKeywords {
            return .high
        } else if hasModerateKeywords {
            return .medium
        } else {
            switch advice.category {
            case .emotional: return .high
            case .wellness, .lifestyle: return .medium
            case .relationship: return .low
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 헤더: 순위 + 조언 정보
            HStack(spacing: 12) {
                // 순위 배지
                if showRank {
                    AdviceRankBadge(rank: rank)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    // 카테고리와 우선순위
                    HStack(spacing: 8) {
                        CategoryChip(category: advice.category)
                        
                        // 우선순위 칩
                        Text(estimatedPriority.displayName)
                            .font(.custom("BMYEONSUNG-OTF", size: 9))
                            .foregroundColor(estimatedPriority.color)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(estimatedPriority.color.opacity(0.1))
                            )
                        
                        Spacer()
                        
                        if advice.actionable {
                            Text("실행 가능")
                                .font(.custom("BMYEONSUNG-OTF", size: 10))
                                .foregroundColor(.green)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.green.opacity(0.1))
                                )
                        }
                    }
                    
                    // 조언 제목
                    Text(advice.title)
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
                    Text(advice.description)
                        .font(.custom("BMYEONSUNG-OTF", size: 14))
                        .foregroundColor(.primary)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    
                    // 추가 메타데이터
                    HStack {
                        Label("카테고리: \(advice.category.displayName)", systemImage: "tag")
                        Spacer()
                        Label("우선순위: \(estimatedPriority.displayName)", systemImage: "exclamationmark.triangle")
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
                .fill(advice.category.color.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(advice.category.color.opacity(0.2), lineWidth: 1.5)
                )
        )
        .onTapGesture {
            isExpanded.toggle()
        }
    }
}

// MARK: - Advice Rank Badge

/// 조언 순위 배지 컴포넌트
struct AdviceRankBadge: View {
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
        case 1: return Color(hex: "#FFD700") // 금색
        case 2: return Color(hex: "#C0C0C0") // 은색
        case 3: return Color(hex: "#CD7F32") // 동색
        default: return .blue
        }
    }
    
    private var rankBackgroundColor: Color {
        switch rank {
        case 1: return Color(hex: "#FFD700").opacity(0.1)
        case 2: return Color(hex: "#C0C0C0").opacity(0.1)
        case 3: return Color(hex: "#CD7F32").opacity(0.1)
        default: return Color.blue.opacity(0.1)
        }
    }
}

// MARK: - Category Chip

/// 카테고리 칩 컴포넌트
struct CategoryChip: View {
    let category: AdviceCategory
    
    var body: some View {
        Text(category.displayName)
            .font(.custom("BMYEONSUNG-OTF", size: 10))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(category.color)
            )
    }
}

// MARK: - Sort Options

/// 조언 정렬 옵션
enum AdviceSortOption: String, CaseIterable {
    case priority = "priority"
    case category = "category"
    case actionable = "actionable"
    
    var displayName: String {
        switch self {
        case .priority: return "우선순위순"
        case .category: return "카테고리별"
        case .actionable: return "실행가능순"
        }
    }
}

// MARK: - Filter Sheet

/// 조언 필터링 및 정렬 시트
struct AdviceFilterSheet: View {
    @Binding var sortBy: AdviceSortOption
    @Binding var selectedCategoryFilter: Set<AdviceCategory>
    @Binding var selectedPriorityFilter: Set<ActionPriority>
    let allCategories: [AdviceCategory]
    let allPriorities: [ActionPriority]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 24) {
                // 정렬 옵션
                VStack(alignment: .leading, spacing: 12) {
                    Text("정렬 기준")
                        .font(.custom("BMYEONSUNG-OTF", size: 18))
                        .fontWeight(.bold)
                    
                    ForEach(AdviceSortOption.allCases, id: \.self) { option in
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
                
                // 카테고리 필터
                VStack(alignment: .leading, spacing: 12) {
                    Text("카테고리")
                        .font(.custom("BMYEONSUNG-OTF", size: 18))
                        .fontWeight(.bold)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 8) {
                        ForEach(allCategories, id: \.self) { category in
                            FilterToggleButton(
                                title: category.displayName,
                                isSelected: selectedCategoryFilter.contains(category)
                            ) {
                                if selectedCategoryFilter.contains(category) {
                                    selectedCategoryFilter.remove(category)
                                } else {
                                    selectedCategoryFilter.insert(category)
                                }
                            }
                        }
                    }
                }
                
                Divider()
                
                // 우선순위 필터
                VStack(alignment: .leading, spacing: 12) {
                    Text("우선순위")
                        .font(.custom("BMYEONSUNG-OTF", size: 18))
                        .fontWeight(.bold)
                    
                    HStack(spacing: 12) {
                        ForEach(allPriorities, id: \.self) { priority in
                            FilterToggleButton(
                                title: priority.rawValue,
                                isSelected: selectedPriorityFilter.contains(priority)
                            ) {
                                if selectedPriorityFilter.contains(priority) {
                                    selectedPriorityFilter.remove(priority)
                                } else {
                                    selectedPriorityFilter.insert(priority)
                                }
                            }
                        }
                    }
                }
                
                Spacer()
                
                // 필터 초기화 버튼
                Button("필터 초기화") {
                    selectedCategoryFilter.removeAll()
                    selectedPriorityFilter.removeAll()
                    sortBy = .priority
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

// MARK: - Empty State

/// 빈 조언 상태 뷰
struct EmptyAdviceView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "lightbulb.circle")
                .font(.system(size: 50))
                .foregroundColor(.gray.opacity(0.5))
            
            VStack(spacing: 8) {
                Text("조언을 찾을 수 없어요")
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
    let sampleAdvice = [
        AdviceDTO(
            id: UUID(),
            category: .emotional,
            title: "감정 인식 시간 늘리기",
            description: "하루 중 감정을 의식적으로 관찰하는 시간을 5분 더 늘려보세요. 감정의 변화를 더 세밀하게 파악할 수 있습니다.",
            actionable: true
        ),
        AdviceDTO(
            id: UUID(),
            category: .wellness,
            title: "명상 시간 추가",
            description: "매일 10분씩 명상하여 마음의 평정을 찾아보세요. 스트레스 감소와 감정 조절에 도움이 됩니다.",
            actionable: true
        ),
        AdviceDTO(
            id: UUID(),
            category: .lifestyle,
            title: "주말 루틴 개선",
            description: "주말의 긍정적 패턴을 평일에도 적용해보세요. 휴식과 활동의 균형을 맞추는 것이 중요합니다.",
            actionable: true
        ),
        AdviceDTO(
            id: UUID(),
            category: .relationship,
            title: "사회적 연결 강화",
            description: "친구나 가족과 더 많은 시간을 보내보세요. 사회적 지지는 정서적 안정에 큰 도움이 됩니다.",
            actionable: false
        )
    ]
    
    AllAdvicesView(advice: sampleAdvice)
}