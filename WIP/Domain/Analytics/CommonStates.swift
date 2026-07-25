import Foundation

// MARK: - Stats v2 & AI Insights 공통 상태 정의
// Contract 고정: 이후 티켓에서 변경 금지, 확장만 허용

// MARK: - 데이터 로딩 상태 (StatsState & InsightsState 공통)
enum DataLoadingState: String, CaseIterable {
    case loading = "loading"
    case empty = "empty"
    case loaded = "loaded"
    case error = "error"
    case unsupported = "unsupported"
    
    var displayName: String {
        switch self {
        case .loading: return "로딩 중"
        case .empty: return "데이터 없음"
        case .loaded: return "로딩 완료"
        case .error: return "오류 발생"
        case .unsupported: return "지원되지 않음"
        }
    }
    
    var isActionable: Bool {
        switch self {
        case .loaded, .empty: return true
        case .loading, .error, .unsupported: return false
        }
    }
}

// MARK: - Stats 전용 상태
enum StatsViewState {
    case initial
    case loadingData(timeframe: StatTimeframe)
    case dataReady(data: StatsDataDTO, timeframe: StatTimeframe)
    case filterApplied(data: StatsDataDTO, filters: StatsFilters)
    case drillDownActive(context: DrillDownContext, data: StatsDataDTO)
    case error(error: StatsError, recoverable: Bool)
    case empty(reason: StatsEmptyReason)
    
    var loadingState: DataLoadingState {
        switch self {
        case .initial, .loadingData:
            return .loading
        case .dataReady, .filterApplied, .drillDownActive:
            return .loaded
        case .error:
            return .error
        case .empty:
            return .empty
        }
    }
    
    var isInteractive: Bool {
        return loadingState.isActionable
    }
}

// MARK: - AI Insights 전용 상태
enum AIInsightsViewState {
    case initial
    case generating(progress: Double)
    case insightsReady(report: InsightReportDTO, metadata: AIAnalysisMetadataDTO)  // AI용 InsightReportDTO (AIInsightsDataContracts.swift)
    case regenerating(currentReport: InsightReportDTO?)
    case actionTracking(reportId: String, completedActions: Set<String>)
    case error(error: AIInsightsError, canRetry: Bool)
    case insufficientData(minimumRequired: Int, current: Int)
    
    var loadingState: DataLoadingState {
        switch self {
        case .initial, .generating, .regenerating:
            return .loading
        case .insightsReady, .actionTracking:
            return .loaded
        case .error:
            return .error
        case .insufficientData:
            return .empty
        }
    }
    
    var canGenerate: Bool {
        switch self {
        case .initial, .insightsReady, .actionTracking, .error:
            return true
        case .generating, .regenerating, .insufficientData:
            return false
        }
    }
}

// MARK: - Stats 필터 상태
struct StatsFilters {
    let emotions: Set<EmotionType>
    let dateRange: DateRange?
    let weekdays: Set<Int>? // 1=일요일, 7=토요일
    let scoreRange: ClosedRange<Double>?
    
    var isActive: Bool {
        return !emotions.isEmpty || 
               dateRange != nil || 
               weekdays != nil || 
               scoreRange != nil
    }
    
    var isEmpty: Bool {
        return !isActive
    }
    
    static let empty = StatsFilters(
        emotions: [],
        dateRange: nil,
        weekdays: nil,
        scoreRange: nil
    )
}

// MARK: - 드릴다운 컨텍스트
struct DrillDownContext {
    let type: DrillDownType
    let target: DrillDownTarget
    let timeframe: StatTimeframe
    let parentData: StatsDataDTO
    
    var navigationTitle: String {
        switch target {
        case .emotion(let emotion):
            return "\(emotion.displayName) 상세"
        case .weekday(let weekday):
            let weekdayNames = ["", "일요일", "월요일", "화요일", "수요일", "목요일", "금요일", "토요일"]
            return "\(weekdayNames[weekday]) 상세"
        case .date(let dateKey):
            return "\(dateKey) 상세"
        case .timeRange(let start, let end):
            return "\(start) ~ \(end) 상세"
        }
    }
}

// MARK: - 드릴다운 유형 (확장 가능하지만 기존 케이스 변경/삭제 금지)
enum DrillDownType: String, CaseIterable {
    case emotion = "emotion"
    case weekday = "weekday"
    case date = "date"
    case trend = "trend"
    case comparison = "comparison"
    
    var displayName: String {
        switch self {
        case .emotion: return "감정별"
        case .weekday: return "요일별"
        case .date: return "날짜별"
        case .trend: return "트렌드"
        case .comparison: return "비교"
        }
    }
}

// MARK: - 드릴다운 대상 (확장 가능하지만 기존 케이스 변경/삭제 금지)
enum DrillDownTarget {
    case emotion(EmotionType)
    case weekday(Int) // 1=일요일, 7=토요일
    case date(String) // "yyyy-MM-dd"
    case timeRange(start: String, end: String) // "yyyy-MM-dd"
}

// MARK: - 날짜 범위
struct DateRange {
    let start: Date
    let end: Date
    
    var isValid: Bool {
        return start <= end
    }
    
    var description: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일"
        return "\(formatter.string(from: start)) ~ \(formatter.string(from: end))"
    }
}

// MARK: - Stats 오류 유형 (확장 가능하지만 기존 케이스 변경/삭제 금지)
enum StatsError: Error, LocalizedError {
    case dataLoadFailed(reason: String)
    case calculationError(operation: String)
    case invalidTimeframe(timeframe: StatTimeframe)
    case insufficientData(required: Int, available: Int)
    case filterError(filter: String)
    
    var errorDescription: String? {
        switch self {
        case .dataLoadFailed(let reason):
            return "데이터 로딩 실패: \(reason)"
        case .calculationError(let operation):
            return "계산 오류: \(operation)"
        case .invalidTimeframe(let timeframe):
            return "잘못된 시간 범위: \(timeframe.displayName)"
        case .insufficientData(let required, let available):
            return "데이터 부족: \(required)개 필요, \(available)개 사용 가능"
        case .filterError(let filter):
            return "필터 오류: \(filter)"
        }
    }
    
    var isRecoverable: Bool {
        switch self {
        case .dataLoadFailed, .filterError:
            return true
        case .calculationError, .invalidTimeframe, .insufficientData:
            return false
        }
    }
}

// MARK: - AI Insights 오류 유형 (확장 가능하지만 기존 케이스 변경/삭제 금지)
enum AIInsightsError: Error, LocalizedError {
    case generationFailed(reason: String)
    case apiUnavailable
    case rateLimitExceeded(retryAfter: TimeInterval?)
    case insufficientPermissions
    case modelError(model: String, error: String)
    case dataProcessingFailed(stage: String)
    
    var errorDescription: String? {
        switch self {
        case .generationFailed(let reason):
            return "인사이트 생성 실패: \(reason)"
        case .apiUnavailable:
            return "AI 서비스를 사용할 수 없습니다"
        case .rateLimitExceeded(let retryAfter):
            if let retry = retryAfter {
                return "요청 한도 초과. \(Int(retry))초 후 재시도하세요"
            } else {
                return "요청 한도 초과"
            }
        case .insufficientPermissions:
            return "AI 분석 권한이 필요합니다"
        case .modelError(let model, let error):
            return "\(model) 모델 오류: \(error)"
        case .dataProcessingFailed(let stage):
            return "데이터 처리 실패: \(stage)"
        }
    }
    
    var canRetry: Bool {
        switch self {
        case .generationFailed, .apiUnavailable, .rateLimitExceeded:
            return true
        case .insufficientPermissions, .modelError, .dataProcessingFailed:
            return false
        }
    }
}

// MARK: - Stats 빈 데이터 이유 (확장 가능하지만 기존 케이스 변경/삭제 금지)
enum StatsEmptyReason: String, CaseIterable {
    case noReflections = "no_reflections"
    case noDataForTimeframe = "no_data_for_timeframe"
    case allFiltered = "all_filtered"
    case timeframeTooShort = "timeframe_too_short"
    
    var displayMessage: String {
        switch self {
        case .noReflections:
            return "아직 작성된 감정 기록이 없습니다"
        case .noDataForTimeframe:
            return "선택한 기간에 데이터가 없습니다"
        case .allFiltered:
            return "필터 조건에 맞는 데이터가 없습니다"
        case .timeframeTooShort:
            return "통계를 표시하기에는 기간이 너무 짧습니다"
        }
    }
    
    var actionSuggestion: String {
        switch self {
        case .noReflections:
            return "감정 기록을 작성해보세요"
        case .noDataForTimeframe:
            return "다른 기간을 선택해보세요"
        case .allFiltered:
            return "필터를 조정하거나 초기화해보세요"
        case .timeframeTooShort:
            return "더 긴 기간을 선택해보세요"
        }
    }
}