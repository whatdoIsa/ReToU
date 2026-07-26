//
//  EmotionType.swift
//  ReToU
//
//  Created by Dean_SSONG on 4/17/25.
//

import SwiftUI

enum EmotionType: String, CaseIterable, Identifiable, Codable {
    case happy = "😊"
    case tired = "🥱"
    case neutral = "😐"
    case sad = "😢"
    case angry = "😠"
    
    var id: String { rawValue }

    /// 감정 이름 — 기쁨·고단·덤덤·슬픔·분노
    var accessibilityName: String {
        switch self {
        case .happy: return String(localized: "emotion_happy", defaultValue: "기쁨")
        case .tired: return String(localized: "emotion_tired", defaultValue: "고단")
        case .neutral: return String(localized: "emotion_neutral", defaultValue: "덤덤")
        case .sad: return String(localized: "emotion_sad", defaultValue: "슬픔")
        case .angry: return String(localized: "emotion_angry", defaultValue: "분노")
        }
    }

    /// 인장(도장) 색상 — 전통 안료: 치자·자초·갈매·쪽·연지
    var sealColor: Color {
        switch self {
        case .happy: return Color(hex: "#C99A3F")   // 치자
        case .tired: return Color(hex: "#8A79A0")   // 자초
        case .neutral: return Color(hex: "#6E8267") // 갈매
        case .sad: return Color(hex: "#4E6C8D")     // 쪽
        case .angry: return Color(hex: "#B04A3C")   // 연지
        }
    }

    /// 통계 차트용 감정별 색상 (인장 색과 동일 체계)
    var color: Color { sealColor }

    /// 상세 화면의 "○○을 새긴 날" 라벨
    var stampedDayLabel: String {
        switch self {
        case .happy: return String(localized: "stamped_happy", defaultValue: "기쁨을 새긴 날")
        case .tired: return String(localized: "stamped_tired", defaultValue: "고단을 새긴 날")
        case .neutral: return String(localized: "stamped_neutral", defaultValue: "덤덤을 새긴 날")
        case .sad: return String(localized: "stamped_sad", defaultValue: "슬픔을 새긴 날")
        case .angry: return String(localized: "stamped_angry", defaultValue: "분노를 새긴 날")
        }
    }
}
