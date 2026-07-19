//
//  DesignSystem.swift
//  ReToU
//
//  앱 전역 디자인 토큰 — 색상/폰트/라운드를 한 곳에서 관리
//

import SwiftUI

/// 앱 색상 팔레트 (4색 체계)
enum AppColor {
    /// 크림색 기본 배경
    static let background = Color(hex: "#FFF9EC")
    /// 카드·입력 필드 표면
    static let surface = Color.white
    /// 브랜드 틸 — 주요 액션 버튼
    static let accent = Color(hex: "#4ECFD8")
    /// 코랄 — 선택 강조·삭제 등 주의 액션
    static let coral = Color(hex: "#FF8977")
    /// 기본 텍스트
    static let textPrimary = Color.black
    /// 보조 텍스트
    static let textSecondary = Color.gray
}

/// 앱 폰트 — Dynamic Type(사용자 글자 크기 설정)에 연동
enum AppFont {
    static func hand(_ size: CGFloat, relativeTo style: Font.TextStyle = .body) -> Font {
        .custom("BMYEONSUNG-OTF", size: size, relativeTo: style)
    }
}

/// 모서리 라운드 (2종 체계)
enum AppRadius {
    /// 카드·큰 컨테이너
    static let card: CGFloat = 16
    /// 입력 필드·작은 컨트롤
    static let field: CGFloat = 12
}
