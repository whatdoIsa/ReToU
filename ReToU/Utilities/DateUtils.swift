//
//  DateUtils.swift
//  ReToU
//
//  Created by Dean_SSONG on 4/17/25.
//

import Foundation

extension Date {
    // 현재 날짜를 "yyyy년 M월 d일" 형식의 문자열로 반환
    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR_POSIX")
        formatter.dateFormat = "yyyy년 M월 d일"
        return formatter.string(from: self)
    }
    
    // 현재 날짜를 "yyyy년 M월" 형식의 문자열로 반환
    func yearMonthString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR_POSIX")
        formatter.dateFormat = "yyyy년 M월"
        return formatter.string(from: self)
    }
}

extension DateFormatter {
    // 전역적으로 사용할 수 있는 한국어 날짜 포맷터 ("yyyy년 M월 d일")
    static let koreanDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR_POSIX")
        formatter.dateFormat = "yyyy년 M월 d일"
        return formatter
    }()
}
