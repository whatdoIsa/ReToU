//
//  PinPadView.swift
//  ReToU
//
//  6자리 비밀번호 패드 — 설정(2회 입력)과 잠금 해제에 공용
//

import SwiftUI

enum PinPadMode {
    /// 새 비밀번호 설정 (입력 → 확인 2단계)
    case setup
    /// 잠금 해제 (저장된 비밀번호와 대조)
    case unlock
}

struct PinPadView: View {
    let mode: PinPadMode
    var onComplete: (Bool) -> Void

    @State private var input: String = ""
    @State private var firstEntry: String?
    @State private var shake = false
    @State private var subtitleKey: String

    init(mode: PinPadMode, onComplete: @escaping (Bool) -> Void) {
        self.mode = mode
        self.onComplete = onComplete
        _subtitleKey = State(initialValue: mode == .setup ? "pin_enter_new" : "pin_enter")
    }

    var body: some View {
        VStack(spacing: 0) {
            EmotionSealView(emotion: .neutral, style: .idle, size: 44)
                .padding(.top, 30)

            Text(LocalizedStringKey(subtitleKey))
                .font(AppFont.serif(18, relativeTo: .title3))
                .foregroundColor(AppColor.ink)
                .padding(.top, 16)

            // 입력 표시 점 6개
            HStack(spacing: 16) {
                ForEach(0..<6, id: \.self) { index in
                    Circle()
                        .strokeBorder(AppColor.ink.opacity(0.35), lineWidth: 1.2)
                        .background(
                            Circle().fill(index < input.count ? AppColor.sealRed : Color.clear)
                        )
                        .frame(width: 13, height: 13)
                }
            }
            .padding(.top, 26)
            .offset(x: shake ? -8 : 0)
            .animation(shake ? .spring(response: 0.12, dampingFraction: 0.2) : .default, value: shake)

            Spacer()

            // 숫자 패드
            VStack(spacing: 14) {
                ForEach(0..<3, id: \.self) { row in
                    HStack(spacing: 42) {
                        ForEach(1...3, id: \.self) { col in
                            digitButton(row * 3 + col)
                        }
                    }
                }
                HStack(spacing: 42) {
                    Color.clear.frame(width: 66, height: 58)
                    digitButton(0)
                    Button {
                        if !input.isEmpty { input.removeLast() }
                    } label: {
                        Image(systemName: "delete.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(AppColor.inkSecondary)
                            .frame(width: 66, height: 58)
                    }
                    .accessibilityLabel("지우기")
                }
            }
            .padding(.bottom, 40)
        }
        .contentColumn(maxWidth: 480)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.paper.ignoresSafeArea())
    }

    private func digitButton(_ digit: Int) -> some View {
        Button {
            appendDigit(digit)
        } label: {
            Text("\(digit)")
                .font(AppFont.serif(24, relativeTo: .title2))
                .foregroundColor(AppColor.ink)
                .frame(width: 66, height: 58)
        }
        .buttonStyle(.plain)
    }

    private func appendDigit(_ digit: Int) {
        guard input.count < 6 else { return }
        input.append("\(digit)")
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        guard input.count == 6 else { return }
        // 입력 완료 처리 (잠깐 여섯 번째 점을 보여준 뒤)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            handleCompleted()
        }
    }

    private func handleCompleted() {
        switch mode {
        case .setup:
            if let first = firstEntry {
                if first == input {
                    KeychainHelper.savePin(input)
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    onComplete(true)
                } else {
                    rejectInput(resetTo: "pin_enter_new")
                    firstEntry = nil
                }
            } else {
                firstEntry = input
                input = ""
                subtitleKey = "pin_confirm"
            }
        case .unlock:
            if KeychainHelper.loadPin() == input {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                onComplete(true)
            } else {
                rejectInput(resetTo: "pin_wrong")
            }
        }
    }

    private func rejectInput(resetTo key: String) {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
        subtitleKey = key
        input = ""
        shake = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { shake = false }
    }
}
