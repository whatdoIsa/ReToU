import Foundation

/// 룰 기반 인사이트 엔진 - Stats DTO 데이터를 분석하여 인사이트 생성
struct RuleBasedInsightEngine {
    
    /// Stats DTO를 기반으로 인사이트 리포트 생성
    static func generateInsightReport(from statsData: StatsDataDTO) -> RuleBasedInsightReportDTO {
        let summary = generateSummary(from: statsData)
        let patterns = identifyPatterns(from: statsData)
        let actions = generateActions(from: statsData, patterns: patterns)
        
        return RuleBasedInsightReportDTO(
            summary: summary,
            patterns: patterns,
            actions: actions,
            generatedAt: Date(),
            dataQuality: assessDataQuality(from: statsData)
        )
    }
    
    // MARK: - Summary Generation
    
    private static func generateSummary(from statsData: StatsDataDTO) -> [String] {
        var summaryPoints: [String] = []
        
        // 1. 기본 활동 요약
        let reflectionDays = statsData.summary.reflectionDays
        let daysInMonth = 30 // 임시로 30일 기준
        let recordingRate = Double(reflectionDays) / Double(daysInMonth) * 100
        
        if recordingRate >= 80 {
            summaryPoints.append("이번 달 \(reflectionDays)일 동안 꾸준히 감정을 기록했습니다. 높은 기록률(\(String(format: "%.1f", recordingRate))%)을 보이고 있어요.")
        } else if recordingRate >= 50 {
            summaryPoints.append("이번 달 \(reflectionDays)일 동안 감정을 기록했습니다. 기록률(\(String(format: "%.1f", recordingRate))%)을 더 높여보세요.")
        } else {
            summaryPoints.append("이번 달 \(reflectionDays)일간 기록했습니다. 더 일관된 기록으로 패턴을 파악해보세요.")
        }
        
        // 2. 감정 상태 요약 (평균 점수 기반)
        let averageScore = statsData.summary.averageScore
        switch averageScore {
        case 1.5...:
            summaryPoints.append("전반적으로 매우 긍정적인 감정 상태를 유지하고 있습니다.")
        case 0.5..<1.5:
            summaryPoints.append("대체로 긍정적인 감정 상태를 보이고 있습니다.")
        case -0.5..<0.5:
            summaryPoints.append("안정적이고 평온한 감정 상태를 유지하고 있습니다.")
        case -1.5..<(-0.5):
            summaryPoints.append("다소 피로하거나 스트레스를 받고 있는 것 같습니다.")
        case ...(-1.5):
            summaryPoints.append("힘든 시기를 보내고 있는 것 같습니다. 자신을 돌보는 시간이 필요해 보입니다.")
        default:
            summaryPoints.append("다양한 감정을 경험하고 있습니다.")
        }
        
        return summaryPoints
    }
    
    // MARK: - Pattern Identification
    
    private static func identifyPatterns(from statsData: StatsDataDTO) -> [RuleBasedPatternDTO] {
        var patterns: [RuleBasedPatternDTO] = []
        
        // 1. 안정성 패턴
        patterns.append(contentsOf: analyzeStabilityPattern(from: statsData))
        
        // 2. 요일별 패턴
        patterns.append(contentsOf: analyzeWeekdayPattern(from: statsData))
        
        // 3. 감정 분포 패턴
        patterns.append(contentsOf: analyzeEmotionDistributionPattern(from: statsData))
        
        // 4. 추세 패턴
        patterns.append(contentsOf: analyzeTrendPattern(from: statsData))
        
        return patterns.sorted { $0.confidence.rawValue > $1.confidence.rawValue }
    }
    
    private static func analyzeStabilityPattern(from statsData: StatsDataDTO) -> [RuleBasedPatternDTO] {
        let stabilityScore = statsData.summary.stabilityScore
        
        switch stabilityScore {
        case 4.0...:
            return [RuleBasedPatternDTO(
                id: UUID(),
                title: "매우 안정적인 감정 상태",
                description: "감정 기복이 거의 없이 일정한 상태를 유지하고 있습니다. 이는 정서적 안정감의 좋은 신호입니다.",
                type: .emotional,
                confidence: .high,
                evidence: ["안정성 점수: \(String(format: "%.1f", stabilityScore))", "낮은 감정 변동성"],
                timeframe: .monthly,
                impact: .positive
            )]
            
        case 3.0..<4.0:
            return [RuleBasedPatternDTO(
                id: UUID(),
                title: "안정적인 감정 관리",
                description: "전반적으로 안정적인 감정 상태를 보이고 있으며, 스트레스 관리가 잘 되고 있는 것 같습니다.",
                type: .emotional,
                confidence: .high,
                evidence: ["안정성 점수: \(String(format: "%.1f", stabilityScore))", "적절한 감정 조절"],
                timeframe: .monthly,
                impact: .positive
            )]
            
        case 2.0..<3.0:
            return [RuleBasedPatternDTO(
                id: UUID(),
                title: "보통 수준의 감정 변화",
                description: "평균적인 수준의 감정 변화를 보이고 있습니다. 스트레스 요인을 파악해보세요.",
                type: .emotional,
                confidence: .medium,
                evidence: ["안정성 점수: \(String(format: "%.1f", stabilityScore))", "보통 수준의 변동"],
                timeframe: .monthly,
                impact: .mixed
            )]
            
        case 1.0..<2.0:
            return [RuleBasedPatternDTO(
                id: UUID(),
                title: "감정 기복이 있는 상태",
                description: "감정 변화가 크게 나타나고 있습니다. 감정 조절 방법을 찾아보는 것이 도움이 될 것 같습니다.",
                type: .emotional,
                confidence: .medium,
                evidence: ["안정성 점수: \(String(format: "%.1f", stabilityScore))", "높은 감정 변동성"],
                timeframe: .monthly,
                impact: .negative
            )]
            
        default:
            return [RuleBasedPatternDTO(
                id: UUID(),
                title: "높은 감정 변동성",
                description: "감정 기복이 매우 크게 나타나고 있습니다. 스트레스 관리와 감정 조절에 특별한 주의가 필요합니다.",
                type: .emotional,
                confidence: .high,
                evidence: ["안정성 점수: \(String(format: "%.1f", stabilityScore))", "매우 높은 변동성"],
                timeframe: .monthly,
                impact: .mixed
            )]
        }
    }
    
    private static func analyzeWeekdayPattern(from statsData: StatsDataDTO) -> [RuleBasedPatternDTO] {
        let weekdayStats = statsData.weekdayStats
        guard !weekdayStats.isEmpty else { return [] }
        
        let weekendStats = weekdayStats.filter { $0.weekday == 1 || $0.weekday == 7 }
        let weekdayOnlyStats = weekdayStats.filter { $0.weekday >= 2 && $0.weekday <= 6 }
        
        guard !weekendStats.isEmpty && !weekdayOnlyStats.isEmpty else { return [] }
        
        let weekendAvg = weekendStats.reduce(0.0) { $0 + $1.averageScore } / Double(weekendStats.count)
        let weekdayAvg = weekdayOnlyStats.reduce(0.0) { $0 + $1.averageScore } / Double(weekdayOnlyStats.count)
        
        let difference = weekendAvg - weekdayAvg
        
        if abs(difference) > 0.5 {
            let title = difference > 0 ? "주말에 더 좋은 감정" : "평일에 더 안정적인 감정"
            let description = difference > 0 
                ? "주말에 감정이 더 긍정적으로 나타나고 있습니다. 주말의 좋은 요소들을 평일에도 적용해보세요."
                : "평일에 더 안정적인 감정을 보이고 있습니다. 규칙적인 루틴이 도움이 되고 있는 것 같습니다."
            
            return [RuleBasedPatternDTO(
                id: UUID(),
                title: title,
                description: description,
                type: .lifestyle,
                confidence: .medium,
                evidence: [
                    "주말 평균: \(String(format: "%.1f", weekendAvg))",
                    "평일 평균: \(String(format: "%.1f", weekdayAvg))",
                    "차이: \(String(format: "%.1f", abs(difference)))"
                ],
                timeframe: .monthly,
                impact: .mixed
            )]
        }
        
        return []
    }
    
    private static func analyzeEmotionDistributionPattern(from statsData: StatsDataDTO) -> [RuleBasedPatternDTO] {
        let distribution = statsData.emotionDistribution
        guard !distribution.isEmpty else { return [] }
        
        var patterns: [RuleBasedPatternDTO] = []
        
        // 가장 자주 나타나는 감정
        if let dominantEmotion = distribution.max(by: { $0.percentage < $1.percentage }) {
            if dominantEmotion.percentage > 40 {
                let title = "\(dominantEmotion.emotion.displayName) 감정이 주를 이룸"
                let description = "이번 달 \(String(format: "%.1f", dominantEmotion.percentage))%의 시간을 \(dominantEmotion.emotion.displayName) 감정으로 보냈습니다."
                
                patterns.append(RuleBasedPatternDTO(
                    id: UUID(),
                    title: title,
                    description: description,
                    type: .emotional,
                    confidence: .high,
                    evidence: [
                        "\(dominantEmotion.emotion.displayName): \(String(format: "%.1f", dominantEmotion.percentage))%",
                        "총 \(dominantEmotion.count)회 기록"
                    ],
                    timeframe: .monthly,
                impact: .mixed
                ))
            }
        }
        
        // 감정 다양성 분석
        let nonZeroEmotions = distribution.filter { $0.count > 0 }
        if nonZeroEmotions.count >= 4 {
            patterns.append(RuleBasedPatternDTO(
                id: UUID(),
                title: "다양한 감정 경험",
                description: "\(nonZeroEmotions.count)가지 서로 다른 감정을 경험하며 풍부한 감정 생활을 하고 있습니다.",
                type: .emotional,
                confidence: .medium,
                evidence: [
                    "경험한 감정 종류: \(nonZeroEmotions.count)가지",
                    "감정 다양성이 높음"
                ],
                timeframe: .monthly,
                impact: .mixed
            ))
        }
        
        return patterns
    }
    
    private static func analyzeTrendPattern(from statsData: StatsDataDTO) -> [RuleBasedPatternDTO] {
        let trendData = statsData.dailyMoodPoints
        guard trendData.count >= 7 else { return [] }
        
        // 최근 7일과 이전 기간 비교
        let recentData = Array(trendData.suffix(7))
        let earlierData = Array(trendData.prefix(max(1, trendData.count - 7)))
        
        let recentAvg = recentData.reduce(0.0) { $0 + $1.score } / Double(recentData.count)
        let earlierAvg = earlierData.reduce(0.0) { $0 + $1.score } / Double(earlierData.count)
        
        let trendDifference = recentAvg - earlierAvg
        
        if abs(trendDifference) > 0.3 {
            let title = trendDifference > 0 ? "최근 감정이 개선되는 추세" : "최근 감정이 하락하는 추세"
            let description = trendDifference > 0
                ? "최근 일주일간 감정 상태가 개선되고 있습니다. 현재의 좋은 습관을 계속 유지해보세요."
                : "최근 일주일간 감정이 다소 하락하고 있습니다. 스트레스 요인을 점검해보는 것이 좋겠습니다."
            
            return [RuleBasedPatternDTO(
                id: UUID(),
                title: title,
                description: description,
                type: .emotional,
                confidence: .medium,
                evidence: [
                    "최근 7일 평균: \(String(format: "%.1f", recentAvg))",
                    "이전 기간 평균: \(String(format: "%.1f", earlierAvg))",
                    "변화량: \(String(format: "%.1f", abs(trendDifference)))"
                ],
                timeframe: .weekly,
                impact: trendDifference > 0 ? .positive : .negative
            )]
        }
        
        return []
    }
    
    // MARK: - Action Generation
    
    private static func generateActions(from statsData: StatsDataDTO, patterns: [RuleBasedPatternDTO]) -> [RuleBasedActionDTO] {
        var actions: [RuleBasedActionDTO] = []
        
        // 기록률 기반 액션
        actions.append(contentsOf: generateRecordingActions(from: statsData))
        
        // 패턴 기반 액션
        for pattern in patterns {
            actions.append(contentsOf: generatePatternBasedActions(for: pattern, statsData: statsData))
        }
        
        // 안정성 기반 액션
        actions.append(contentsOf: generateStabilityActions(from: statsData))
        
        return Array(actions.prefix(3)) // 최대 3개의 액션만 반환
    }
    
    private static func generateRecordingActions(from statsData: StatsDataDTO) -> [RuleBasedActionDTO] {
        let reflectionDays = statsData.summary.reflectionDays
        let recordingRate = Double(reflectionDays) / 30.0 * 100
        
        if recordingRate < 50 {
            return [RuleBasedActionDTO(
                id: "increaseRecording",
                title: "꾸준한 감정 기록하기",
                description: "더 정확한 패턴 분석을 위해 매일 감정을 기록해보세요. 작은 변화도 놓치지 않을 수 있습니다.",
                category: .mindfulness,
                priority: .high,
                estimatedImpact: 0.8,
                timeToImplement: .mediumTerm,
                prerequisites: []
            )]
        }
        
        return []
    }
    
    private static func generatePatternBasedActions(for pattern: RuleBasedPatternDTO, statsData: StatsDataDTO) -> [RuleBasedActionDTO] {
        switch pattern.type {
        case .emotional:
            if pattern.title.contains("감정 기복") || pattern.title.contains("높은 감정 변동성") {
                return [RuleBasedActionDTO(
                    id: "emotionRegulation",
                    title: "감정 조절 기법 익히기",
                    description: "깊은 호흡, 명상, 또는 간단한 스트레칭으로 감정을 조절해보세요.",
                    category: .mindfulness,
                    priority: .medium,
                    estimatedImpact: 0.7,
                    timeToImplement: .shortTerm,
                    prerequisites: []
                )]
            }
            
        case .lifestyle:
            if pattern.title.contains("주말에 더 좋은") {
                return [RuleBasedActionDTO(
                    id: "applyWeekendRoutine",
                    title: "주말 루틴을 평일에 적용",
                    description: "주말의 긍정적인 요소들을 평일에도 조금씩 적용해보세요.",
                    category: .lifestyle,
                    priority: .medium,
                    estimatedImpact: 0.6,
                    timeToImplement: .mediumTerm,
                    prerequisites: []
                )]
            }
        }
        
        return []
    }
    
    private static func generateStabilityActions(from statsData: StatsDataDTO) -> [RuleBasedActionDTO] {
        let stabilityScore = statsData.summary.stabilityScore
        
        if stabilityScore < 2.0 {
            return [RuleBasedActionDTO(
                id: "stressManagement",
                title: "스트레스 관리 방법 찾기",
                description: "규칙적인 수면, 운동, 또는 취미 활동으로 감정 안정성을 높여보세요.",
                category: .lifestyle,
                priority: .high,
                estimatedImpact: 0.8,
                timeToImplement: .mediumTerm,
                prerequisites: []
            )]
        } else if stabilityScore > 4.0 {
            return [RuleBasedActionDTO(
                id: "tryNewExperience",
                title: "새로운 경험 시도해보기",
                description: "안정된 상태를 바탕으로 새로운 도전이나 경험을 시도해보는 것은 어떨까요?",
                category: .lifestyle,
                priority: .low,
                estimatedImpact: 0.5,
                timeToImplement: .mediumTerm,
                prerequisites: []
            )]
        }
        
        return []
    }
    
    // MARK: - Data Quality Assessment
    
    private static func assessDataQuality(from statsData: StatsDataDTO) -> DataQuality {
        let reflectionDays = statsData.summary.reflectionDays
        let totalDaysInMonth = 30
        
        let recordingRate = Double(reflectionDays) / Double(totalDaysInMonth)
        let emotionVariety = statsData.emotionDistribution.filter { $0.count > 0 }.count
        
        if recordingRate >= 0.8 && emotionVariety >= 3 {
            return .excellent
        } else if recordingRate >= 0.6 && emotionVariety >= 2 {
            return .good
        } else if recordingRate >= 0.3 {
            return .fair
        } else {
            return .limited
        }
    }
}

// Supporting Types는 별도 파일에서 관리