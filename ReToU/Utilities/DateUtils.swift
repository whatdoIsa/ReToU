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
