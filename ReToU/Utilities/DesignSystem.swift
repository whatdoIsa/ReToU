//
//  DesignSystem.swift
//  ReToU
//
//  "감정 인장" 디자인 시스템 — 종이·먹·인주의 물성
//  재료: 종이 #FBF9F4, 먹 #26241F, 인주 레드 #C34A36(오늘 표시·삭제에만)
//

import SwiftUI

/// 앱 색상 팔레트
enum AppColor {
    /// 미색 한지 톤 종이 — 전 화면 기본 배경
    static let paper = Color(hex: "#FBF9F4")
    /// 어두운 배경 위 종이(페이월 등)
    static let paperDark = Color(hex: "#211F1B")
    /// 먹 — 기본 텍스트·버튼
    static let ink = Color(hex: "#26241F")
    /// 보조 텍스트
    static let inkSecondary = Color(hex: "#7B766C")
    /// 흐린 안내 텍스트
    static let inkFaint = Color(hex: "#A8A294")
    /// 실선·점선 구분선
    static let hairline = Color(hex: "#E7E2D6")
    /// 공책 괘선
    static let ruledLine = Color(hex: "#EAE4D5")
    /// 미선택 인장 모노톤
    static let sealIdle = Color(hex: "#C9C3B4")
    /// 인주 레드 — 오늘 표시·삭제 확인, 단 두 곳에만
    static let sealRed = Color(hex: "#C34A36")

    // 하위 호환 별칭 (기존 코드 사용처)
    static let background = paper
    static let surface = Color.white
    static let accent = ink
    static let coral = sealRed
    static let textPrimary = ink
    static let textSecondary = inkSecondary
}

/// 앱 폰트 — 명조(감정) × 고딕(조작) 이원 체계, Dynamic Type 연동
enum AppFont {
    /// 명조 디스플레이/제목 — 감정이 담기는 모든 글
    static func serif(_ size: CGFloat, relativeTo style: Font.TextStyle = .body) -> Font {
        .custom("NanumMyeongjoExtraBold", size: size, relativeTo: style)
    }

    /// 명조 본문 — 일기 텍스트
    static func serifBody(_ size: CGFloat, relativeTo style: Font.TextStyle = .body) -> Font {
        .custom("NanumMyeongjo", size: size, relativeTo: style)
    }

    /// 고딕 UI 라벨 — 조작되는 모든 글 (시스템 폰트)
    static func label(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight)
    }

    // 하위 호환 별칭 (기존 손글씨 폰트 사용처 — 점진 교체 대상)
    static func hand(_ size: CGFloat, relativeTo style: Font.TextStyle = .body) -> Font {
        serif(size, relativeTo: style)
    }
}

/// 모서리 라운드 — 컨테이너 6pt 한 종류, 버튼만 비정형
enum AppRadius {
    static let container: CGFloat = 6
    // 하위 호환 별칭
    static let card: CGFloat = 6
    static let field: CGFloat = 6
}

/// 도장 느낌의 비정형 라운드 버튼 배경 (10 12 10 13)
struct InkButtonShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path(
            roundedRect: rect,
            cornerRadii: RectangleCornerRadii(
                topLeading: 10, bottomLeading: 13, bottomTrailing: 10, topTrailing: 12
            )
        )
    }
}

/// 먹 버튼 스타일 — 눌리면 도장 찍듯 살짝 가라앉음
struct InkButtonStyle: ButtonStyle {
    var background: Color = AppColor.ink
    var foreground: Color = AppColor.paper

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppFont.label(15, weight: .bold))
            .foregroundColor(foreground)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(InkButtonShape().fill(background))
            .shadow(color: background.opacity(0.25), radius: 0, x: 0, y: configuration.isPressed ? 0 : 3)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .offset(y: configuration.isPressed ? 2 : 0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

/// 공책 괘선 배경 — 일기 입력·본문 뒤에 깔리는 가로줄
struct RuledPaper: View {
    var lineSpacing: CGFloat = 28

    var body: some View {
        GeometryReader { geo in
            Path { path in
                var y = lineSpacing
                while y < geo.size.height {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: geo.size.width, y: y))
                    y += lineSpacing
                }
            }
            .stroke(AppColor.ruledLine, lineWidth: 1)
        }
    }
}

/// 종이 그레인 — 디지털의 매끈함을 지우는 3% 노이즈
struct PaperGrain: View {
    var body: some View {
        Canvas { context, size in
            var generator = SeededRandom(seed: 7)
            let count = Int(size.width * size.height / 110)
            for _ in 0..<count {
                let x = generator.next() * size.width
                let y = generator.next() * size.height
                let alpha = 0.015 + generator.next() * 0.030
                context.fill(
                    Path(ellipseIn: CGRect(x: x, y: y, width: 1.1, height: 1.1)),
                    with: .color(AppColor.ink.opacity(alpha))
                )
            }
        }
        .allowsHitTesting(false)
    }
}

/// 결정적 난수 — 같은 시드는 항상 같은 결과 (인장 각도·그레인에 사용)
struct SeededRandom {
    private var state: UInt64

    init(seed: UInt64) {
        self.state = seed &* 0x9E3779B97F4A7C15 &+ 1
    }

    mutating func next() -> CGFloat {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return CGFloat((state >> 33) & 0xFFFFFF) / CGFloat(0xFFFFFF)
    }
}
