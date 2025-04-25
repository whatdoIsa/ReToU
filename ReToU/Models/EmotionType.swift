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
    
    var color: Color { //감정 분석을 넣을 수 있는 시간이 있다면..
        switch self {
        case .happy: return Color(hex: "#FFB3B3")
        case .tired: return Color(hex: "#C9C9C9")
        case .neutral: return Color(hex: "#FFD580")
        case .sad: return Color(hex: "#B3D1FF")
        case .angry: return Color(hex: "#FF8C8C")
        }
    }
}
