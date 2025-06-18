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
        formatter.locale = Locale.current
        
        if Locale.current.languageCode == "ko"{
            formatter.dateFormat = "yyyy년 M월 d일"
        } else {
            formatter.dateFormat = "MMMM d, yyyy"
        }
        return formatter.string(from: self)
    }
    
    // 현재 날짜를 "yyyy년 M월" 형식의 문자열로 반환
    func yearMonthString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        
        if Locale.current.languageCode == "ko" {
            formatter.dateFormat = "yyyy년 M월"
        } else {
            formatter.dateFormat = "MMMM yyyy"
        }
        return formatter.string(from: self)
    }
}

extension DateFormatter {
    /// 현재 언어 설정에 따라 날짜 포맷을 자동 지정해주는 포맷터
    static let localizedDate: DateFormatter = {
        let formatter = DateFormatter()
        let currentLanguage = Locale.current.languageCode
        
        if currentLanguage == "ko" {
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.dateFormat = "yyyy년 M월 d일"
        } else {
            formatter.locale = Locale(identifier: "en_US")
            formatter.dateFormat = "MMMM d, yyyy"
        }
        return formatter
    }()
}
