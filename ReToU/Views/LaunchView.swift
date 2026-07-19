//
//  LaunchView.swift
//  ReToU
//
//  Created by Dean_SSONG on 4/18/25.
//

import SwiftUI
import LocalAuthentication

struct LaunchView: View {
    @EnvironmentObject private var storage: ReflectionStorage
    @State private var isAuthenticated = false
    @State private var showAuthFailedAlert = false

    var body: some View {
        ZStack {
            AppColor.paper.ignoresSafeArea()

            if isAuthenticated {
                MainTabView()
            } else {
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
                    Spacer().frame(height: 60)
                }
                .padding()
            }
        }
        // 인증 실패 시 재시도 경로 제공 — 막다른 길 방지
        .alert("auth_failed_title", isPresented: $showAuthFailedAlert) {
            Button("auth_retry") {
                authenticate()
            }
        } message: {
            Text("auth_failed_message")
        }
        .onAppear {
            authenticate()
        }
    }

    /// 생체 인증 또는 패스코드 인증 수행
    private func authenticate() {
        // 시뮬레이터에는 생체인증/암호가 없어 개발 확인이 막히므로 건너뜀 (실기기 영향 없음)
        #if targetEnvironment(simulator)
        withAnimation(.easeOut(duration: 0.25)) { isAuthenticated = true }
        #else
        AuthManager.shared.authenticateWithBiometricsOrPasscode(
            onSuccess: {
                withAnimation(.easeOut(duration: 0.25)) {
                    isAuthenticated = true
                }
            },
            onFailure: {
                showAuthFailedAlert = true
            }
        )
        #endif
    }
}
