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

    /// VoiceOver 등 접근성에서 읽어줄 감정 이름
    var accessibilityName: String {
        switch self {
        case .happy: return String(localized: "emotion_happy", defaultValue: "행복")
        case .tired: return String(localized: "emotion_tired", defaultValue: "피곤")
        case .neutral: return String(localized: "emotion_neutral", defaultValue: "보통")
        case .sad: return String(localized: "emotion_sad", defaultValue: "슬픔")
        case .angry: return String(localized: "emotion_angry", defaultValue: "화남")
        }
    }

    /// 인장(도장) 색상 — 채도를 낮춘 인주의 물성
    var sealColor: Color {
        switch self {
        case .happy: return Color(hex: "#D99A3E")
        case .tired: return Color(hex: "#8F7FA8")
        case .neutral: return Color(hex: "#7D8F6D")
        case .sad: return Color(hex: "#5F7F9E")
        case .angry: return Color(hex: "#C34A36")
        }
    }

    /// 통계 차트용 감정별 색상 (인장 색과 동일 체계)
    var color: Color { sealColor }

    /// 상세 화면의 "○○을 찍은 날" 라벨
    var stampedDayLabel: String {
        switch self {
        case .happy: return String(localized: "stamped_happy", defaultValue: "행복을 찍은 날")
        case .tired: return String(localized: "stamped_tired", defaultValue: "피곤을 찍은 날")
        case .neutral: return String(localized: "stamped_neutral", defaultValue: "보통을 찍은 날")
        case .sad: return String(localized: "stamped_sad", defaultValue: "슬픔을 찍은 날")
        case .angry: return String(localized: "stamped_angry", defaultValue: "화남을 찍은 날")
        }
    }
}
