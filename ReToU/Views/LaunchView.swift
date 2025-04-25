//
//  LaunchView.swift
//  ReToU
//
//  Created by Dean_SSONG on 4/18/25.
//

import SwiftUI
import LocalAuthentication

struct LaunchView: View {
    @State private var isReady = false
    @EnvironmentObject private var storage: ReflectionStorage
    @State private var routeToWrite = false // 회고 작성 페이지로 이동할지 여부
    @State private var routeToList = false // 회고 리스트 페이지로 이동할지 여부
    @State private var showAuthFailedAlert = false // 인증 실패 알림 표시 여부

    var body: some View {
        ZStack {
            Color(hex: "#FFF9EC").ignoresSafeArea()
            // 사용자 인증이 완료했을 때
            if routeToWrite { // 회고가 없다면 작성 페이지로 이동
                ReflectionWriteView()
            } else if routeToList {  // 회고가 있다면 리스트 페이지로 이동
                ReflectionListView()
            } else {
                VStack(spacing: 16) {
                    Spacer()

                    Text("오늘의 넌")
                        .font(.custom("BMYEONSUNG-OTF", size: 48))
                        .foregroundColor(.black)

                    Text("하루의 나를 솔직하게 바라보는 시간")
                        .font(.custom("BMYEONSUNG-OTF", size: 24))
                        .foregroundColor(.gray)

                    Spacer()

                    Spacer().frame(height: 60)
                }
                .padding()
            }
        }
        // 인증이 필요할 때 알림 표시
        .alert("인증이 필요합니다.", isPresented: $showAuthFailedAlert) {
            Button("확인", role: .cancel) {}
        }
        .onAppear {
            // 생체 인증 또는 패스코드 인증 수행
            AuthManager.shared.authenticateWithBiometricsOrPasscode(
                onSuccess: {
                    // 인증 성공 시 다음 화면으로 전환
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        if storage.hasReflectionForToday() {
                            // 오늘의 회고가 있다면 리스트로 이동
                            routeToList = true
                        } else {
                            // 오늘의 회고가 없다면 작성 페이지로 이동
                            routeToWrite = true
                        }
                    }
                },
                onFailure: {
                    // 인증 실패 시 알림 표시
                    showAuthFailedAlert = true
                }
            )
        }
    }
}
