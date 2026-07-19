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

    /// 통계 차트용 감정별 색상
    var color: Color {
        switch self {
        case .happy: return Color(hex: "#FFB3B3")
        case .tired: return Color(hex: "#C9C9C9")
        case .neutral: return Color(hex: "#FFD580")
        case .sad: return Color(hex: "#B3D1FF")
        case .angry: return Color(hex: "#FF8C8C")
        }
    }
}
