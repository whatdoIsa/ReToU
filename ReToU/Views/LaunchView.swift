//
//  LaunchView.swift
//  ReToU
//
//  진입 플로우: (잠금 해제) → (온보딩) → 메인
//

import SwiftUI
import LocalAuthentication

struct LaunchView: View {
    @EnvironmentObject private var storage: ReflectionStorage

    private enum Phase {
        case locked
        case onboarding
        case main
    }

    @State private var phase: Phase = .locked
    @State private var showAuthFailedAlert = false
    @State private var showPinPad = false

    /// 구버전(잠금 강제) 사용자가 업데이트한 경우 — 온보딩 전이라도 기존 방식으로 잠금 유지
    private var isLegacyLockedUser: Bool {
        !AppSettings.hasOnboarded && storage.daysTogether() != nil
    }

    private var needsLock: Bool {
        AppSettings.lockEnabled || isLegacyLockedUser
    }

    var body: some View {
        ZStack {
            AppColor.paper.ignoresSafeArea()

            switch phase {
            case .main:
                MainTabView()

            case .onboarding:
                OnboardingView {
                    withAnimation(.easeOut(duration: 0.25)) { phase = .main }
                }

            case .locked:
                if showPinPad {
                    VStack(spacing: 0) {
                        PinPadView(mode: .unlock) { success in
                            if success { unlock() }
                        }
                        Button {
                            showPinPad = false
                            attemptBiometrics()
                        } label: {
                            Label("lock_use_faceid", systemImage: "faceid")
                                .font(AppFont.label(13, weight: .semibold))
                                .foregroundColor(AppColor.inkSecondary)
                        }
                        .padding(.bottom, 26)
                        .background(AppColor.paper)
                    }
                } else {
                    lockScreen
                }
            }
        }
        .alert("auth_failed_title", isPresented: $showAuthFailedAlert) {
            Button("auth_retry") { authenticate() }
        } message: {
            Text("auth_failed_message")
        }
        .onAppear {
            Analytics.track(.appOpened)
            if needsLock {
                authenticate()
            } else {
                unlock()
            }
        }
    }

    private var lockScreen: some View {
        VStack(spacing: 18) {
            Spacer()

            EmotionSealView(emotion: .happy, style: .stamped, size: 64, rotationSeed: 3)

            Text(LocalizedStringKey("launch_title"))
                .font(AppFont.serif(36, relativeTo: .largeTitle))
                .foregroundColor(AppColor.ink)

            Text("launch_subtitle")
                .font(AppFont.serifBody(15, relativeTo: .title3))
                .foregroundColor(AppColor.inkSecondary)

            Spacer()

            Button {
                authenticate()
            } label: {
                Label("lock_unlock", systemImage: "faceid")
                    .font(AppFont.label(14, weight: .bold))
                    .foregroundColor(AppColor.ink)
            }
            .padding(.bottom, 70)
        }
        .padding()
    }

    // MARK: - Flow

    private func unlock() {
        withAnimation(.easeOut(duration: 0.25)) {
            phase = AppSettings.hasOnboarded ? .main : .onboarding
        }
    }

    private func authenticate() {
        if AppSettings.lockEnabled && KeychainHelper.hasPin {
            // 새 방식: Face ID 우선, 실패 시 앱 자체 6자리 비밀번호
            attemptBiometrics()
        } else if isLegacyLockedUser {
            // 구버전 사용자: 기존 방식(생체 → 시스템 암호) 유지
            legacyAuthenticate()
        } else {
            unlock()
        }
    }

    private func attemptBiometrics() {
        AuthManager.shared.authenticateWithBiometricsOnly(
            onSuccess: { unlock() },
            onFailure: { showPinPad = true }
        )
    }

    private func legacyAuthenticate() {
        // 시뮬레이터에는 생체인증/암호가 없어 개발 확인이 막히므로 건너뜀 (실기기 영향 없음)
        #if targetEnvironment(simulator)
        unlock()
        #else
        AuthManager.shared.authenticateWithBiometricsOrPasscode(
            onSuccess: { unlock() },
            onFailure: { showAuthFailedAlert = true }
        )
        #endif
    }
}
