import Foundation

// MARK: - Stats v2 Analytics Functions
// 실제 Reflection 데이터를 기반으로 DTO 생성하는 함수들

extension Date {
    var dayKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
    
    var weekday: Int {
        return Calendar.current.component(.weekday, from: self)
    }
}

extension EmotionType {
    var displayName: String {
        switch self {
        case .happy: return "기쁨"
        case .tired: return "피곤"
        case .neutral: return "보통"
        case .sad: return "슬픔"
        case .angry: return "분노"
        }
    }
}

struct StatsAnalytics {
    
    // MARK: - 월별 요약 생성
    static func makeMonthlySummary(_ entries: [Reflection], monthKey: String) -> MonthlySummaryDTO {
        let components = monthKey.split(separator: "-")
        guard components.count == 2,
              let year = Int(components[0]),
              let month = Int(components[1]) else {
            return MonthlySummaryDTO(
                year: Calendar.current.component(.year, from: Date()),
                month: Calendar.current.component(.month, from: Date()),
                totalReflections: 0,
                averageScore: 0.0,
                dominantEmotion: nil,
                improvementFromPreviousMonth: nil,
                streakDays: 0,
                reflectionDays: 0,
                totalDaysInMonth: 0,
                stabilityScore: 0.0
            )
        }
        
        let totalReflections = entries.count
        let averageScore = totalReflections > 0 
            ? entries.compactMap { EmotionType(rawValue: $0.emotion)?.numericScore }
                     .map(Double.init)
                     .reduce(0, +) / Double(totalReflections)
            : 0.0
        
        let emotionCounts = Dictionary(
            grouping: entries.compactMap { EmotionType(rawValue: $0.emotion) }
        ) { $0 }
        .mapValues { $0.count }
        
        let dominantEmotion = emotionCounts.max(by: { $0.value < $1.value })?.key
        
        let reflectionDays = Set(entries.map { $0.date.dayKey }).count
        
        let calendar = Calendar.current
        let date = calendar.date(from: DateComponents(year: year, month: month))!
        let range = calendar.range(of: .day, in: .month, for: date)!
        let totalDaysInMonth = range.count
        
        let streakDays = calculateStreakDays(entries)
        
        let stabilityScore = calculateStabilityScore(entries)
        
        return MonthlySummaryDTO(
            year: year,
            month: month,
            totalReflections: totalReflections,
            averageScore: averageScore,
            dominantEmotion: dominantEmotion,
            improvementFromPreviousMonth: nil, // 별도 계산 필요
            streakDays: streakDays,
            reflectionDays: reflectionDays,
            totalDaysInMonth: totalDaysInMonth,
            stabilityScore: stabilityScore
        )
    }
    
    // MARK: - 감정 분포 생성 (5단계 고정, 0 포함)
    static func makeDistribution(_ entries: [Reflection]) -> [EmotionDistributionItemDTO] {
        let totalCount = entries.count
        let emotionCounts = Dictionary(
            grouping: entries.compactMap { EmotionType(rawValue: $0.emotion) }
        ) { $0 }
        .mapValues { $0.count }
        
        return EmotionDistributionItemDTO.supportedEmotions.map { emotion in
            let count = emotionCounts[emotion, default: 0]
            let percentage = totalCount > 0 ? Double(count) / Double(totalCount) * 100 : 0.0
            
            let emotionEntries = entries.filter { EmotionType(rawValue: $0.emotion) == emotion }
            let averageScore = emotionEntries.isEmpty 
                ? Double(emotion.numericScore)
                : emotionEntries.map { Double(EmotionType(rawValue: $0.emotion)?.numericScore ?? 0) }
                               .reduce(0, +) / Double(emotionEntries.count)
            
            return EmotionDistributionItemDTO(
                emotion: emotion,
                count: count,
                percentage: percentage,
                averageScore: averageScore
            )
        }
    }
    
    // MARK: - 일별 기분 점수 데이터 생성
    static func makeTrend(_ entries: [Reflection]) -> [DailyMoodPointDTO] {
        let groupedByDate = Dictionary(grouping: entries) { $0.date.dayKey }
        
        return groupedByDate.compactMap { (dateKey, reflections) in
            guard let firstReflection = reflections.first,
                  let emotion = EmotionType(rawValue: firstReflection.emotion) else {
                return nil
            }
            
            // 하루에 여러 기록이 있으면 평균 계산
            let scores = reflections.compactMap { EmotionType(rawValue: $0.emotion)?.numericScore }
                                   .map(Double.init)
            let averageScore = scores.isEmpty ? 0.0 : scores.reduce(0, +) / Double(scores.count)
            
            return DailyMoodPointDTO(
                dateKey: dateKey,
                score: averageScore,
                emotion: emotion,
                hasReflection: true
            )
        }.sorted { $0.dateKey < $1.dateKey }
    }
    
    // MARK: - 히트맵 데이터 생성
    static func makeHeatmap(_ entries: [Reflection], monthKey: String) -> [HeatmapDayDTO] {
        let components = monthKey.split(separator: "-")
        guard components.count == 2,
              let year = Int(components[0]),
              let month = Int(components[1]) else {
            return []
        }
        
        let calendar = Calendar.current
        let date = calendar.date(from: DateComponents(year: year, month: month))!
        let range = calendar.range(of: .day, in: .month, for: date)!
        
        let groupedByDate = Dictionary(grouping: entries) { $0.date.dayKey }
        
        var heatmapData: [HeatmapDayDTO] = []
        
        for day in 1...range.count {
            let dayDate = calendar.date(from: DateComponents(year: year, month: month, day: day))!
            let dateKey = dayDate.dayKey
            
            if let reflections = groupedByDate[dateKey] {
                let scores = reflections.compactMap { EmotionType(rawValue: $0.emotion)?.numericScore }
                                       .map(Double.init)
                let averageScore = scores.isEmpty ? 0.0 : scores.reduce(0, +) / Double(scores.count)
                let emotion = reflections.first.flatMap { EmotionType(rawValue: $0.emotion) }
                
                heatmapData.append(HeatmapDayDTO(
                    dateKey: dateKey,
                    emotion: emotion,
                    hasReflection: true,
                    score: averageScore
                ))
            } else {
                heatmapData.append(HeatmapDayDTO(
                    dateKey: dateKey,
                    emotion: nil,
                    hasReflection: false,
                    score: nil
                ))
            }
        }
        
        return heatmapData
    }
    
    // MARK: - 요일별 통계 생성
    static func makeWeekdayStats(_ entries: [Reflection]) -> [WeekdayStatDTO] {
        let groupedByWeekday = Dictionary(grouping: entries) { $0.date.weekday }
        
        return (1...7).map { weekday in
            let weekdayEntries = groupedByWeekday[weekday, default: []]
            let reflectionCount = weekdayEntries.count
            
            if reflectionCount > 0 {
                let scores = weekdayEntries.compactMap { EmotionType(rawValue: $0.emotion)?.numericScore }
                                          .map(Double.init)
                let averageScore = scores.isEmpty ? 0.0 : scores.reduce(0, +) / Double(scores.count)
                
                let emotionCounts = Dictionary(
                    grouping: weekdayEntries.compactMap { EmotionType(rawValue: $0.emotion) }
                ) { $0 }
                .mapValues { $0.count }
                
                let dominantEmotion = emotionCounts.max(by: { $0.value < $1.value })?.key
                
                return WeekdayStatDTO(
                    weekday: weekday,
                    averageScore: averageScore,
                    reflectionCount: reflectionCount,
                    dominantEmotion: dominantEmotion
                )
            } else {
                return WeekdayStatDTO(
                    weekday: weekday,
                    averageScore: 0.0,
                    reflectionCount: 0,
                    dominantEmotion: nil
                )
            }
        }
    }
    
    // MARK: - 월별 비교 데이터 생성
    static func makeMonthComparison(currentEntries: [Reflection], prevEntries: [Reflection]?) -> MonthComparisonDTO {
        let currentMonthKey = MonthKeyUtils.generateMonthKey(year: Calendar.current.component(.year, from: Date()), month: Calendar.current.component(.month, from: Date()))
        let currentSummary = makeMonthlySummary(currentEntries, monthKey: currentMonthKey)
        let previousSummary = prevEntries.map { makeMonthlySummary($0, monthKey: currentMonthKey) }
        
        let scoreChange = previousSummary.map { currentSummary.averageScore - $0.averageScore }
        let reflectionCountChange = previousSummary.map { currentSummary.totalReflections - $0.totalReflections }
        let completionRateChange = previousSummary.map { currentSummary.completionRate - $0.completionRate }
        let streakChange = previousSummary.map { currentSummary.streakDays - $0.streakDays }
        
        return MonthComparisonDTO(
            currentMonth: currentSummary,
            previousMonth: previousSummary,
            scoreChange: scoreChange,
            reflectionCountChange: reflectionCountChange,
            completionRateChange: completionRateChange,
            streakChange: streakChange
        )
    }
    
    // MARK: - 연속 기록 일수 계산 (안정도/변동성)
    static func calculateStreakDays(_ entries: [Reflection]) -> Int {
        let sortedDates = entries.map { $0.date.dayKey }
                                .sorted()
                                .reversed()
        
        guard !sortedDates.isEmpty else { return 0 }
        
        var streakCount = 0
        var currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        for dateKey in sortedDates {
            guard let entryDate = dateFormatter.date(from: dateKey) else { break }
            
            let daysDifference = Calendar.current.dateComponents([.day], from: entryDate, to: currentDate).day ?? 0
            
            if streakCount == 0 && daysDifference <= 1 {
                streakCount = 1
                currentDate = entryDate
            } else if daysDifference == 1 {
                streakCount += 1
                currentDate = entryDate
            } else if daysDifference > 1 {
                break
            }
        }
        
        return streakCount
    }
    
    // MARK: - 표준편차 계산 (안정도 변동성)
    static func calculateStandardDeviation(_ scores: [Double]) -> Double {
        guard scores.count > 1 else { return 0.0 }
        
        let mean = scores.reduce(0, +) / Double(scores.count)
        let squaredDifferences = scores.map { pow($0 - mean, 2) }
        let variance = squaredDifferences.reduce(0, +) / Double(scores.count - 1)
        
        return sqrt(variance)
    }
    
    // MARK: - 변동성 점수 계산 (표준편차 기반, 0-100 스케일)
    static func calculateStabilityScore(_ entries: [Reflection]) -> Double {
        let scores = entries.compactMap { EmotionType(rawValue: $0.emotion)?.numericScore }
                            .map(Double.init)
        
        guard scores.count > 1 else { return 100.0 } // 데이터가 부족하면 완전히 안정적
        
        let standardDeviation = calculateStandardDeviation(scores)
        
        // 점수 범위가 -2~2이므로 최대 표준편차는 약 2.0
        // 0-100 스케일로 변환 (낮은 표준편차 = 높은 안정도)
        let maxStandardDeviation = 2.0
        let stabilityRatio = max(0, 1 - (standardDeviation / maxStandardDeviation))
        
        return stabilityRatio * 100
    }
}

// MARK: - StatTimeframe enum은 StatsNavigationActions.swift에서 정의됨