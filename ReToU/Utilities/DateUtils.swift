//
//  DateUtils.swift
//  ReToU
//
//  Created by Dean_SSONG on 4/17/25.
//

import Foundation

extension Date {
    /// 현재 날짜를 "yyyy년 M월 d일" 형식의 문자열로 반환
    func formattedDate() -> String {
        return DateFormatter.localizedDate.string(from: self)
    }

    /// 현재 날짜를 "yyyy년 M월" 형식의 문자열로 반환
    func yearMonthString() -> String {
        return DateFormatter.localizedYearMonth.string(from: self)
    }

    /// 연/월 정수를 로컬라이즈된 "yyyy년 M월" 문자열로 변환
    static func localizedYearMonth(year: Int, month: Int) -> String {
        var components = DateComponents()
        components.year = year
        components.month = month

        let date = Calendar.current.date(from: components) ?? Date()
        return DateFormatter.localizedYearMonth.string(from: date)
    }
}

// MARK: - 문어체 한국어 날짜 (인장 디자인의 세로쓰기·달력 헤더용)

enum KoreanLiteraryDate {
    private static let monthNames = [
        "일월", "이월", "삼월", "사월", "오월", "유월",
        "칠월", "팔월", "구월", "시월", "십일월", "십이월"
    ]

    private static let nativeNumbers = [
        "한", "두", "세", "네", "다섯", "여섯", "일곱", "여덟", "아홉", "열",
        "열한", "열두", "열세", "열네", "열다섯", "열여섯", "열일곱", "열여덟", "열아홉", "스무",
        "스물한", "스물두", "스물세", "스물네", "스물다섯", "스물여섯", "스물일곱", "스물여덟", "스물아홉", "서른",
        "서른한"
    ]

    private static let sinoDigits = ["", "일", "이", "삼", "사", "오", "육", "칠", "팔", "구"]

    /// 7 → "칠월"
    static func monthName(_ month: Int) -> String {
        guard (1...12).contains(month) else { return "\(month)월" }
        return monthNames[month - 1]
    }

    /// 19 → "열아홉 번째 날"
    static func dayPhrase(_ day: Int) -> String {
        guard (1...31).contains(day) else { return "\(day)일" }
        return "\(nativeNumbers[day - 1]) 번째 날"
    }

    /// 2026 → "이천이십육년"
    static func yearPhrase(_ year: Int) -> String {
        var result = ""
        let thousands = year / 1000
        let hundreds = (year % 1000) / 100
        let tens = (year % 100) / 10
        let ones = year % 10
        if thousands > 0 { result += (thousands == 1 ? "천" : sinoDigits[thousands] + "천") }
        if hundreds > 0 { result += (hundreds == 1 ? "백" : sinoDigits[hundreds] + "백") }
        if tens > 0 { result += (tens == 1 ? "십" : sinoDigits[tens] + "십") }
        if ones > 0 { result += sinoDigits[ones] }
        return result + "년"
    }

    /// "토요일"
    static func weekdayName(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
}

extension DateFormatter {
    private static var isKorean: Bool {
        Locale.current.language.languageCode?.identifier == "ko"
    }

    /// 현재 언어 설정에 따라 날짜 포맷을 자동 지정해주는 포맷터 (yyyy년 M월 d일)
    static let localizedDate: DateFormatter = {
        let formatter = DateFormatter()
        if isKorean {
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.dateFormat = "yyyy년 M월 d일"
        } else {
            formatter.locale = Locale(identifier: "en_US")
            formatter.dateFormat = "MMMM d, yyyy"
        }
        return formatter
    }()

    /// 현재 언어 설정에 따른 연·월 포맷터 (yyyy년 M월)
    static let localizedYearMonth: DateFormatter = {
        let formatter = DateFormatter()
        if isKorean {
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.dateFormat = "yyyy년 M월"
        } else {
            formatter.locale = Locale(identifier: "en_US")
            formatter.dateFormat = "MMMM yyyy"
        }
        return formatter
    }()
}
