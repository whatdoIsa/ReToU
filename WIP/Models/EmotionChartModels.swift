import Foundation

// MARK: - Chart Data Models
// Note: This file extends existing models with new functionality for Ticket 3

// Required type imports for other models
// PatternDTO, EmotionType, StatsDataDTO, etc. are defined in other files

/// 추세 시간 범위
enum TrendTimeframe: String, CaseIterable {
    case week = "week"
    case month = "month"
    case threeMonths = "3months"
    case sixMonths = "6months"
    case year = "year"
    
    var displayName: String {
        switch self {
        case .week: return "1주"
        case .month: return "1개월"
        case .threeMonths: return "3개월"
        case .sixMonths: return "6개월"
        case .year: return "1년"
        }
    }
    
    var days: Int {
        switch self {
        case .week: return 7
        case .month: return 30
        case .threeMonths: return 90
        case .sixMonths: return 180
        case .year: return 365
        }
    }
}

// MARK: - Basic Chart Configuration

/// 차트 표시 설정
struct ChartConfiguration {
    let showDataPoints: Bool
    let showTrendLine: Bool
    let colorScheme: ChartColorScheme
    
    static let `default` = ChartConfiguration(
        showDataPoints: true,
        showTrendLine: true,
        colorScheme: .emotional
    )
}

/// 차트 색상 스키마
enum ChartColorScheme {
    case emotional    // 감정별 색상
    case monochrome   // 단색
    case gradient     // 그라데이션
}