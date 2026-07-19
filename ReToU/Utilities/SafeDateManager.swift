import Foundation

/// 안전한 날짜 처리를 위한 매니저
/// "하루에 1개 기록" 규칙을 일관되게 적용하기 위해 모든 날짜 비교를 표준화
final class SafeDateManager {
    static let shared = SafeDateManager()

    /// 앱 실행 중 타임존/설정 변경을 반영하기 위해 매번 현재 캘린더 사용
    private var calendar: Calendar { Calendar.current }

    /// DateFormatter는 생성 비용이 크므로 캐싱 (timeZone은 호출 시점에 동기화)
    private static let dateKeyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    private init() {}

    // MARK: - Core Date Key Generation

    /// 날짜를 YYYY-MM-DD 형태의 표준 키로 변환
    /// 사용자 로컬 캘린더의 startOfDay 기준으로 일관된 키 생성
    func generateDateKey(for date: Date) -> String {
        let startOfDay = calendar.startOfDay(for: date)
        let formatter = Self.dateKeyFormatter
        formatter.timeZone = calendar.timeZone
        return formatter.string(from: startOfDay)
    }

    /// 오늘 날짜의 표준 키 반환
    func todayDateKey() -> String {
        return generateDateKey(for: Date())
    }

    /// dateKey 문자열을 Date로 변환
    func date(from dateKey: String) -> Date? {
        let formatter = Self.dateKeyFormatter
        formatter.timeZone = calendar.timeZone
        return formatter.date(from: dateKey)
    }

    // MARK: - Date Range Utilities

    /// 특정 연/월의 [시작, 끝) 범위 반환
    /// end는 "다음 달 1일 00:00"으로, 비교 시 반드시 `date < end` (exclusive)를 사용해야
    /// 월의 마지막 날에 작성된 회고가 누락되지 않음
    func dateRange(for year: Int, month: Int) -> (start: Date, end: Date)? {
        guard let startOfMonth = calendar.date(from: DateComponents(year: year, month: month, day: 1)) else {
            return nil
        }

        guard let startOfNextMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth) else {
            return nil
        }

        return (start: startOfMonth, end: startOfNextMonth)
    }

    /// 특정 날짜가 속한 하루의 [시작, 끝) 범위 반환
    func dayRange(for date: Date) -> (start: Date, end: Date)? {
        let start = calendar.startOfDay(for: date)
        guard let end = calendar.date(byAdding: .day, value: 1, to: start) else {
            return nil
        }
        return (start: start, end: end)
    }

    // MARK: - Validation

    /// dateKey가 유효한 형식인지 검증
    func isValidDateKey(_ dateKey: String) -> Bool {
        return date(from: dateKey) != nil
    }

    /// 두 Date가 같은 날인지 확인 (startOfDay 기준)
    func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        return calendar.isDate(date1, inSameDayAs: date2)
    }

    // MARK: - Debug Helpers

    /// 현재 시간대 정보 반환
    func currentTimeZoneInfo() -> String {
        return "TimeZone: \(calendar.timeZone.identifier), Locale: \(calendar.locale?.identifier ?? "unknown")"
    }
}

// MARK: - Reflection Extension for DateKey
extension Reflection {
    /// 이 Reflection의 dateKey 반환
    var dateKey: String {
        return SafeDateManager.shared.generateDateKey(for: date)
    }
}
