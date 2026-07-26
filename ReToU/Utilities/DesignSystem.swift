//
//  DesignSystem.swift
//  ReToU
//
//  "한지와 감정 인장" 디자인 시스템 — 한지·먹·전통 안료의 물성
//  재료: 한지 #F5EFDF, 먹 #2B2721, 인주(연지) #B04A3C
//

import SwiftUI

/// 앱 색상 팔레트
enum AppColor {
    /// 한지 — 닥섬유 미색, 전 화면 기본 배경
    static let paper = Color(hex: "#F5EFDF")
    /// 어두운 배경 위 종이(페이월 등)
    static let paperDark = Color(hex: "#2C2820")
    /// 먹 — 기본 텍스트·버튼
    static let ink = Color(hex: "#2B2721")
    /// 보조 텍스트
    static let inkSecondary = Color(hex: "#7D7566")
    /// 흐린 안내 텍스트
    static let inkFaint = Color(hex: "#A89D86")
    /// 실선·점선 구분선
    static let hairline = Color(hex: "#DDD3BD")
    /// 공책 괘선
    static let ruledLine = Color(hex: "#E2D9C2")
    /// 미선택 인장 모노톤
    static let sealIdle = Color(hex: "#C3B899")
    /// 인주(연지) — 오늘 표시·삭제 확인, 단 두 곳에만
    static let sealRed = Color(hex: "#B04A3C")

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

    // 하위 호환 별칭
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

/// 한지의 결 — ① 닥섬유(가로로 긴 섬유 노이즈) ② 발(簾) 자국의 미세한 가로줄
struct PaperGrain: View {
    var body: some View {
        Canvas { context, size in
            var generator = SeededRandom(seed: 7)

            // 발 무늬 — 3pt 간격의 아주 옅은 가로줄
            var y: CGFloat = 0
            while y < size.height {
                var line = Path()
                line.move(to: CGPoint(x: 0, y: y))
                line.addLine(to: CGPoint(x: size.width, y: y))
                context.stroke(line, with: .color(AppColor.ink.opacity(0.018)), lineWidth: 0.5)
                y += 3
            }

            // 닥섬유 — 가로로 긴 섬유 조각들
            let fiberCount = Int(size.width * size.height / 260)
            for _ in 0..<fiberCount {
                let x = generator.next() * size.width
                let fy = generator.next() * size.height
                let width = 2.0 + generator.next() * 6.0
                let alpha = 0.015 + generator.next() * 0.030
                context.fill(
                    Path(ellipseIn: CGRect(x: x, y: fy, width: width, height: 0.9)),
                    with: .color(AppColor.ink.opacity(alpha))
                )
            }
        }
        .allowsHitTesting(false)
    }
}

/// 찢은 한지 가장자리 — 조각보·부착물에 쓰는 비정형 사각형
struct TornRectShape: Shape {
    /// 같은 시드는 항상 같은 가장자리
    var seed: Int = 0

    func path(in rect: CGRect) -> Path {
        var rng = SeededRandom(seed: UInt64(bitPattern: Int64(seed)) &+ 41)
        let jag: CGFloat = min(rect.width, rect.height) * 0.035
        let steps = 8

        func wobble() -> CGFloat { (rng.next() - 0.5) * 2 * jag }

        var p = Path()
        p.move(to: CGPoint(x: rect.minX + abs(wobble()), y: rect.minY + abs(wobble())))
        // 위
        for i in 1...steps {
            let x = rect.minX + rect.width * CGFloat(i) / CGFloat(steps)
            p.addLine(to: CGPoint(x: x, y: rect.minY + abs(wobble())))
        }
        // 오른쪽
        for i in 1...steps {
            let y = rect.minY + rect.height * CGFloat(i) / CGFloat(steps)
            p.addLine(to: CGPoint(x: rect.maxX - abs(wobble()), y: y))
        }
        // 아래
        for i in 1...steps {
            let x = rect.maxX - rect.width * CGFloat(i) / CGFloat(steps)
            p.addLine(to: CGPoint(x: x, y: rect.maxY - abs(wobble())))
        }
        // 왼쪽
        for i in 1...steps {
            let y = rect.maxY - rect.height * CGFloat(i) / CGFloat(steps)
            p.addLine(to: CGPoint(x: rect.minX + abs(wobble()), y: y))
        }
        p.closeSubpath()
        return p
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
