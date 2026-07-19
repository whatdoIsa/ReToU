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
    @State private var routeToWrite = false // 회고 작성 페이지로 이동할지 여부
    @State private var routeToList = false // 회고 리스트 페이지로 이동할지 여부
    @State private var showAuthFailedAlert = false // 인증 실패 알림 표시 여부

    var body: some View {
        ZStack {
            AppColor.background.ignoresSafeArea()
            // 사용자 인증이 완료했을 때
            if routeToWrite { // 회고가 없다면 작성 페이지로 이동
                ReflectionWriteView()
            } else if routeToList {  // 회고가 있다면 리스트 페이지로 이동
                ReflectionListView()
            } else {
                VStack(spacing: 16) {
                    Spacer()

                    Text(LocalizedStringKey("launch_title"))
                        .font(AppFont.hand(48, relativeTo: .largeTitle))
                        .foregroundColor(AppColor.textPrimary)

                    Text("launch_subtitle")
                        .font(AppFont.hand(24, relativeTo: .title3))
                        .foregroundColor(AppColor.textSecondary)

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
        AuthManager.shared.authenticateWithBiometricsOrPasscode(
            onSuccess: {
                // 인증 성공 시 즉시 다음 화면으로 전환
                if storage.hasReflectionForToday() {
                    // 오늘의 회고가 있다면 리스트로 이동
                    routeToList = true
                } else {
                    // 오늘의 회고가 없다면 작성 페이지로 이동
                    routeToWrite = true
                }
            },
            onFailure: {
                // 인증 실패 시 알림 표시
                showAuthFailedAlert = true
            }
        )
    }
}
