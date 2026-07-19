//
//  EmotionSeal.swift
//  ReToU
//
//  감정 인장(印章) — 이 앱의 시그니처 오브젝트
//  획이 고르지 않은 원 + 손그림 얼굴. 선택되면 인주가 묻은 듯 채워지고 살짝 기운다.
//

import SwiftUI

// MARK: - 인장 테두리 (손도장의 비뚤어진 원)

struct SealRing: Shape {
    func path(in rect: CGRect) -> Path {
        let s = min(rect.width, rect.height) / 100
        var p = Path()
        p.move(to: CGPoint(x: 50 * s, y: 7 * s))
        p.addCurve(to: CGPoint(x: 93 * s, y: 49 * s),
                   control1: CGPoint(x: 73 * s, y: 4 * s),
                   control2: CGPoint(x: 94 * s, y: 21 * s))
        p.addCurve(to: CGPoint(x: 50 * s, y: 93 * s),
                   control1: CGPoint(x: 92 * s, y: 75 * s),
                   control2: CGPoint(x: 76 * s, y: 94 * s))
        p.addCurve(to: CGPoint(x: 7 * s, y: 50 * s),
                   control1: CGPoint(x: 25 * s, y: 92 * s),
                   control2: CGPoint(x: 7 * s, y: 76 * s))
        p.addCurve(to: CGPoint(x: 50 * s, y: 7 * s),
                   control1: CGPoint(x: 7 * s, y: 25 * s),
                   control2: CGPoint(x: 28 * s, y: 10 * s))
        p.closeSubpath()
        return p
    }
}

// MARK: - 감정별 얼굴

struct SealFace: Shape {
    let emotion: EmotionType

    func path(in rect: CGRect) -> Path {
        let s = min(rect.width, rect.height) / 100
        var p = Path()

        func dot(_ x: CGFloat, _ y: CGFloat, r: CGFloat = 5) {
            p.addEllipse(in: CGRect(x: (x - r) * s, y: (y - r) * s, width: r * 2 * s, height: r * 2 * s))
        }

        switch emotion {
        case .happy:
            dot(36, 42); dot(64, 42)
            p.move(to: CGPoint(x: 34 * s, y: 60 * s))
            p.addQuadCurve(to: CGPoint(x: 66 * s, y: 60 * s), control: CGPoint(x: 50 * s, y: 74 * s))

        case .tired:
            // 감은 눈
            p.move(to: CGPoint(x: 29 * s, y: 42 * s))
            p.addQuadCurve(to: CGPoint(x: 43 * s, y: 42 * s), control: CGPoint(x: 36 * s, y: 48 * s))
            p.move(to: CGPoint(x: 57 * s, y: 42 * s))
            p.addQuadCurve(to: CGPoint(x: 71 * s, y: 42 * s), control: CGPoint(x: 64 * s, y: 48 * s))
            // 벌어진 입 (하품)
            p.addEllipse(in: CGRect(x: 43 * s, y: 56 * s, width: 14 * s, height: 18 * s))

        case .neutral:
            dot(36, 42); dot(64, 42)
            p.move(to: CGPoint(x: 36 * s, y: 63 * s))
            p.addLine(to: CGPoint(x: 64 * s, y: 63 * s))

        case .sad:
            dot(36, 42); dot(64, 42)
            p.move(to: CGPoint(x: 34 * s, y: 68 * s))
            p.addQuadCurve(to: CGPoint(x: 66 * s, y: 68 * s), control: CGPoint(x: 50 * s, y: 56 * s))
            // 눈물 한 방울
            p.move(to: CGPoint(x: 68 * s, y: 50 * s))
            p.addQuadCurve(to: CGPoint(x: 68 * s, y: 61 * s), control: CGPoint(x: 74 * s, y: 56 * s))

        case .angry:
            // 치켜올린 눈썹
            p.move(to: CGPoint(x: 28 * s, y: 34 * s))
            p.addLine(to: CGPoint(x: 44 * s, y: 40 * s))
            p.move(to: CGPoint(x: 72 * s, y: 34 * s))
            p.addLine(to: CGPoint(x: 56 * s, y: 40 * s))
            dot(37, 48); dot(63, 48)
            p.move(to: CGPoint(x: 36 * s, y: 68 * s))
            p.addQuadCurve(to: CGPoint(x: 64 * s, y: 68 * s), control: CGPoint(x: 50 * s, y: 58 * s))
        }
        return p
    }
}

// MARK: - 인장 뷰

enum SealStyle {
    /// 모노톤 외곽선 (미선택)
    case idle
    /// 감정색 외곽선 (달력 미니 등)
    case outline
    /// 인주가 묻은 듯 채워진 상태 (선택·기록됨)
    case stamped
    /// 인주 레드로 꽉 채움 (오늘)
    case today
}

struct EmotionSealView: View {
    let emotion: EmotionType
    var style: SealStyle
    var size: CGFloat
    /// 회전 시드 — dateKey 해시 등. 같은 시드는 항상 같은 각도 (-5°~+5°)
    var rotationSeed: Int = 0

    private var rotation: Angle {
        var rng = SeededRandom(seed: UInt64(bitPattern: Int64(rotationSeed)) &+ 17)
        return .degrees(Double(rng.next() * 10 - 5))
    }

    private var color: Color {
        switch style {
        case .idle: return AppColor.sealIdle
        case .today: return AppColor.sealRed
        case .outline, .stamped: return emotion.sealColor
        }
    }

    private var strokeWidth: CGFloat { size * 0.05 }

    var body: some View {
        ZStack {
            switch style {
            case .idle, .outline:
                SealRing().stroke(color, style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
                face(in: color)
            case .stamped, .today:
                SealRing().fill(color)
                face(in: AppColor.paper)
            }
        }
        .frame(width: size, height: size)
        .rotationEffect(rotation)
        .shadow(
            color: (style == .stamped || style == .today) ? color.opacity(0.4) : .clear,
            radius: 3, x: 0, y: 2
        )
        .accessibilityLabel(emotion.accessibilityName)
    }

    @ViewBuilder
    private func face(in faceColor: Color) -> some View {
        SealFace(emotion: emotion)
            .stroke(faceColor, style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
        SealFace(emotion: emotion)
            .fill(faceColor)
    }
}

// MARK: - 감정 인장 선택기 (작성·수정 화면 공용)

struct EmotionSealPicker: View {
    @Binding var selection: EmotionType?
    var sealSize: CGFloat = 46

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(EmotionType.allCases) { emotion in
                let isSelected = selection == emotion
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                        selection = emotion
                    }
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                } label: {
                    VStack(spacing: 5) {
                        EmotionSealView(
                            emotion: emotion,
                            style: isSelected ? .stamped : .idle,
                            size: sealSize,
                            rotationSeed: isSelected ? emotion.rawValue.hashValue : 0
                        )
                        .scaleEffect(isSelected ? 1.08 : 1)
                        Text(emotion.accessibilityName)
                            .font(AppFont.label(10, weight: .bold))
                            .foregroundColor(isSelected ? AppColor.ink : AppColor.inkFaint)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(emotion.accessibilityName)
                .accessibilityAddTraits(isSelected ? [.isSelected] : [])
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("감정 선택")
    }
}
