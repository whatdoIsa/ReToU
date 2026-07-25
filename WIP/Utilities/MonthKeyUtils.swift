import Foundation

/// 월 키 생성 및 관리 유틸리티
struct MonthKeyUtils {
    
    /// 년/월을 "YYYY-MM" 형태의 monthKey로 변환
    /// - Parameters:
    ///   - year: 년도
    ///   - month: 월 (1-12)
    /// - Returns: "YYYY-MM" 형태의 문자열
    static func generateMonthKey(year: Int, month: Int) -> String {
        return String(format: "%04d-%02d", year, month)
    }
    
    /// 현재 날짜의 monthKey 생성
    /// - Returns: 현재 년월의 "YYYY-MM" 형태 문자열
    static func currentMonthKey() -> String {
        let calendar = Calendar.current
        let now = Date()
        let year = calendar.component(.year, from: now)
        let month = calendar.component(.month, from: now)
        return generateMonthKey(year: year, month: month)
    }
    
    /// Date 객체로부터 monthKey 생성
    /// - Parameter date: 날짜 객체
    /// - Returns: "YYYY-MM" 형태의 문자열
    static func monthKey(from date: Date) -> String {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        return generateMonthKey(year: year, month: month)
    }
    
    /// monthKey를 년/월로 파싱
    /// - Parameter monthKey: "YYYY-MM" 형태의 문자열
    /// - Returns: (year, month) 튜플 또는 nil (파싱 실패시)
    static func parseMonthKey(_ monthKey: String) -> (year: Int, month: Int)? {
        let components = monthKey.split(separator: "-")
        guard components.count == 2,
              let year = Int(components[0]),
              let month = Int(components[1]),
              month >= 1, month <= 12 else {
            return nil
        }
        return (year: year, month: month)
    }
    
    /// 이전 월의 monthKey 계산
    /// - Parameter monthKey: 현재 monthKey
    /// - Returns: 이전 월의 monthKey 또는 nil
    static func previousMonthKey(_ monthKey: String) -> String? {
        guard let (year, month) = parseMonthKey(monthKey) else { return nil }
        
        if month == 1 {
            return generateMonthKey(year: year - 1, month: 12)
        } else {
            return generateMonthKey(year: year, month: month - 1)
        }
    }
    
    /// 다음 월의 monthKey 계산
    /// - Parameter monthKey: 현재 monthKey
    /// - Returns: 다음 월의 monthKey 또는 nil
    static func nextMonthKey(_ monthKey: String) -> String? {
        guard let (year, month) = parseMonthKey(monthKey) else { return nil }
        
        if month == 12 {
            return generateMonthKey(year: year + 1, month: 1)
        } else {
            return generateMonthKey(year: year, month: month + 1)
        }
    }
    
    /// monthKey의 표시용 이름 생성
    /// - Parameter monthKey: "YYYY-MM" 형태의 문자열
    /// - Returns: "YYYY년 M월" 형태의 문자열
    static func displayName(for monthKey: String) -> String {
        guard let (year, month) = parseMonthKey(monthKey) else { return monthKey }
        return "\(year)년 \(month)월"
    }
    
    /// monthKey 유효성 검사
    /// - Parameter monthKey: 검사할 monthKey
    /// - Returns: 유효한지 여부
    static func isValid(_ monthKey: String) -> Bool {
        return parseMonthKey(monthKey) != nil
    }
}

// MARK: - Extensions

extension Date {
    /// Date 객체로부터 monthKey 생성
    var monthKey: String {
        return MonthKeyUtils.monthKey(from: self)
    }
}