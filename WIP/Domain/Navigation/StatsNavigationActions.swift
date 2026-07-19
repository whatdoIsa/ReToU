import Foundation

// MARK: - Stats v2 Navigation Actions (딥링크 및 화면 전환)
// Contract 고정: 이후 티켓에서 변경 금지, 확장만 허용

// MARK: - Stats 탭 내 네비게이션 액션
enum StatsNavigationAction {
    // 기본 뷰 액션
    case showMonthlyView(year: Int, month: Int)
    case showYearlyView(year: Int)
    case showAllTime
    
    // 상세 드릴다운 액션
    case drillDownEmotion(emotion: EmotionType, timeframe: StatTimeframe)
    case drillDownWeekday(weekday: Int, year: Int, month: Int)
    case drillDownDate(dateKey: String) // "yyyy-MM-dd"
    
    // 비교 및 분석 액션
    case compareMonths(current: (Int, Int), previous: (Int, Int))
    case showTrendAnalysis(emotion: EmotionType?, timeframe: StatTimeframe)
    case showCorrelationAnalysis
    
    // 설정 및 필터 액션
    case filterByEmotion(emotions: [EmotionType])
    case filterByDateRange(start: Date, end: Date)
    case resetFilters
    
    // 공유 및 내보내기 액션
    case shareStats(format: StatsShareFormat)
    case exportData(format: StatsExportFormat)
    
    var actionId: String {
        switch self {
        case .showMonthlyView(let year, let month):
            return "stats.monthly.\(year).\(month)"
        case .showYearlyView(let year):
            return "stats.yearly.\(year)"
        case .showAllTime:
            return "stats.alltime"
        case .drillDownEmotion(let emotion, let timeframe):
            return "stats.drill.emotion.\(emotion.rawValue).\(timeframe.rawValue)"
        case .drillDownWeekday(let weekday, let year, let month):
            return "stats.drill.weekday.\(weekday).\(year).\(month)"
        case .drillDownDate(let dateKey):
            return "stats.drill.date.\(dateKey)"
        case .compareMonths(let current, let previous):
            return "stats.compare.\(current.0).\(current.1).\(previous.0).\(previous.1)"
        case .showTrendAnalysis(let emotion, let timeframe):
            let emotionId = emotion?.rawValue ?? "all"
            return "stats.trend.\(emotionId).\(timeframe.rawValue)"
        case .showCorrelationAnalysis:
            return "stats.correlation"
        case .filterByEmotion(let emotions):
            let emotionIds = emotions.map { $0.rawValue }.joined(separator: ",")
            return "stats.filter.emotion.\(emotionIds)"
        case .filterByDateRange(let start, let end):
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return "stats.filter.daterange.\(formatter.string(from: start)).\(formatter.string(from: end))"
        case .resetFilters:
            return "stats.filter.reset"
        case .shareStats(let format):
            return "stats.share.\(format.rawValue)"
        case .exportData(let format):
            return "stats.export.\(format.rawValue)"
        }
    }
}

// MARK: - AI Insights 탭 내 네비게이션 액션
enum AIInsightsNavigationAction {
    // 기본 뷰 액션
    case showLatestInsights
    case showInsightHistory
    case regenerateInsights
    
    // 상세 뷰 액션
    case showPatternDetail(patternId: String)
    case showActionDetail(actionId: String)
    case showInsightReport(reportId: String)
    
    // 액션 실행 및 추적
    case markActionAsCompleted(actionId: String)
    case markActionAsSkipped(actionId: String)
    case scheduleActionReminder(actionId: String, reminderDate: Date)
    
    // 설정 및 커스터마이징
    case configureInsightSettings
    case selectPreferredInsightTypes([PatternType])
    case setInsightFrequency(frequency: InsightFrequency)
    
    // 공유 및 저장 액션
    case shareInsight(reportId: String, format: InsightShareFormat)
    case saveInsightAsFavorite(reportId: String)
    case exportInsightData(format: InsightExportFormat)
    
    var actionId: String {
        switch self {
        case .showLatestInsights:
            return "insights.latest"
        case .showInsightHistory:
            return "insights.history"
        case .regenerateInsights:
            return "insights.regenerate"
        case .showPatternDetail(let patternId):
            return "insights.pattern.\(patternId)"
        case .showActionDetail(let actionId):
            return "insights.action.\(actionId)"
        case .showInsightReport(let reportId):
            return "insights.report.\(reportId)"
        case .markActionAsCompleted(let actionId):
            return "insights.action.complete.\(actionId)"
        case .markActionAsSkipped(let actionId):
            return "insights.action.skip.\(actionId)"
        case .scheduleActionReminder(let actionId, let reminderDate):
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd-HH-mm"
            return "insights.action.reminder.\(actionId).\(formatter.string(from: reminderDate))"
        case .configureInsightSettings:
            return "insights.settings"
        case .selectPreferredInsightTypes(let types):
            let typeIds = types.map { $0.rawValue }.joined(separator: ",")
            return "insights.settings.types.\(typeIds)"
        case .setInsightFrequency(let frequency):
            return "insights.settings.frequency.\(frequency.rawValue)"
        case .shareInsight(let reportId, let format):
            return "insights.share.\(reportId).\(format.rawValue)"
        case .saveInsightAsFavorite(let reportId):
            return "insights.favorite.\(reportId)"
        case .exportInsightData(let format):
            return "insights.export.\(format.rawValue)"
        }
    }
}

// MARK: - 지원되는 시간 범위 (확장 가능하지만 기존 케이스 변경/삭제 금지)
enum StatTimeframe: String, CaseIterable {
    case day = "day"
    case week = "week"
    case month = "month"
    case quarter = "quarter"
    case year = "year"
    case allTime = "all_time"
    
    var displayName: String {
        switch self {
        case .day: return "일간"
        case .week: return "주간"
        case .month: return "월간"
        case .quarter: return "분기"
        case .year: return "연간"
        case .allTime: return "전체"
        }
    }
}

// MARK: - Stats 공유 형식 (확장 가능하지만 기존 케이스 변경/삭제 금지)
enum StatsShareFormat: String, CaseIterable {
    case image = "image"
    case text = "text"
    case link = "link"
    case pdf = "pdf"
    
    var displayName: String {
        switch self {
        case .image: return "이미지"
        case .text: return "텍스트"
        case .link: return "링크"
        case .pdf: return "PDF"
        }
    }
}

// MARK: - Stats 내보내기 형식 (확장 가능하지만 기존 케이스 변경/삭제 금지)
enum StatsExportFormat: String, CaseIterable {
    case csv = "csv"
    case json = "json"
    case excel = "excel"
    
    var displayName: String {
        switch self {
        case .csv: return "CSV"
        case .json: return "JSON"
        case .excel: return "Excel"
        }
    }
}

// MARK: - Insights 공유 형식 (확장 가능하지만 기존 케이스 변경/삭제 금지)
enum InsightShareFormat: String, CaseIterable {
    case text = "text"
    case image = "image"
    case summary = "summary"
    case full = "full"
    
    var displayName: String {
        switch self {
        case .text: return "텍스트"
        case .image: return "이미지"
        case .summary: return "요약"
        case .full: return "전체"
        }
    }
}

// MARK: - Insights 내보내기 형식 (확장 가능하지만 기존 케이스 변경/삭제 금지)
enum InsightExportFormat: String, CaseIterable {
    case markdown = "markdown"
    case pdf = "pdf"
    case json = "json"
    
    var displayName: String {
        switch self {
        case .markdown: return "Markdown"
        case .pdf: return "PDF"
        case .json: return "JSON"
        }
    }
}

// MARK: - Insights 생성 빈도 (확장 가능하지만 기존 케이스 변경/삭제 금지)
enum InsightFrequency: String, CaseIterable {
    case daily = "daily"
    case weekly = "weekly"
    case monthly = "monthly"
    case manual = "manual"
    
    var displayName: String {
        switch self {
        case .daily: return "매일"
        case .weekly: return "매주"
        case .monthly: return "매월"
        case .manual: return "수동"
        }
    }
}