//
//  OnboardingView.swift
//  ReToU
//
//  첫 실행 온보딩 — 컨셉 소개 → 리마인더 설정 → 잠금 제안
//

import SwiftUI

struct OnboardingView: View {
    var onDone: () -> Void

    @State private var page = 0
    @State private var reminderTime = AppSettings.reminderTime
    @State private var showPinSetup = false

    var body: some View {
        ZStack {
            AppColor.paper.ignoresSafeArea()
            PaperGrain().ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $page) {
                    conceptPage.contentColumn(maxWidth: 560).tag(0)
                    reminderPage.contentColumn(maxWidth: 560).tag(1)
                    lockPage.contentColumn(maxWidth: 560).tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // 페이지 인디케이터 — 인장 점
                HStack(spacing: 10) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(index == page ? AppColor.sealRed : AppColor.sealIdle.opacity(0.5))
                            .frame(width: 7, height: 7)
                    }
                }
                .padding(.bottom, 30)
            }
        }
        .sheet(isPresented: $showPinSetup) {
            PinPadView(mode: .setup) { success in
                if success {
                    AppSettings.lockEnabled = true
                    showPinSetup = false
                    finish()
                }
            }
        }
    }

    // MARK: - ① 컨셉

    private var conceptPage: some View {
        VStack(spacing: 0) {
            Spacer()

            HStack(spacing: 14) {
                EmotionSealView(emotion: .happy, style: .stamped, size: 44, rotationSeed: 1)
                EmotionSealView(emotion: .tired, style: .outline, size: 40, rotationSeed: 2)
                EmotionSealView(emotion: .neutral, style: .outline, size: 40, rotationSeed: 3)
                EmotionSealView(emotion: .sad, style: .outline, size: 40, rotationSeed: 4)
                EmotionSealView(emotion: .angry, style: .outline, size: 40, rotationSeed: 5)
            }

            Text("onboarding_concept_title")
                .font(AppFont.serif(26, relativeTo: .largeTitle))
                .foregroundColor(AppColor.ink)
                .multilineTextAlignment(.center)
                .lineSpacing(8)
                .padding(.top, 30)

            Text("onboarding_concept_body")
                .font(AppFont.serifBody(14, relativeTo: .body))
                .foregroundColor(AppColor.inkSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(8)
                .padding(.top, 14)
                .padding(.horizontal, 40)

            Spacer()

            Button {
                withAnimation { page = 1 }
            } label: {
                Text("onboarding_next")
            }
            .buttonStyle(InkButtonStyle())
            .padding(.horizontal, 40)
            .padding(.bottom, 24)
        }
    }

    // MARK: - ② 리마인더

    private var reminderPage: some View {
        VStack(spacing: 0) {
            Spacer()

            Text("onboarding_reminder_title")
                .font(AppFont.serif(24, relativeTo: .largeTitle))
                .foregroundColor(AppColor.ink)
                .multilineTextAlignment(.center)
                .lineSpacing(8)

            Text("onboarding_reminder_body")
                .font(AppFont.serifBody(14, relativeTo: .body))
                .foregroundColor(AppColor.inkSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(8)
                .padding(.top, 14)
                .padding(.horizontal, 40)

            DatePicker("", selection: $reminderTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .frame(height: 150)
                .padding(.top, 10)

            Spacer()

            VStack(spacing: 12) {
                Button {
                    AppSettings.reminderTime = reminderTime
                    ReminderManager.shared.requestPermission { granted in
                        if granted {
                            AppSettings.reminderEnabled = true
                            ReminderManager.shared.reschedule(hasWrittenToday: false)
                            Analytics.track(.reminderEnabled)
                        }
                        withAnimation { page = 2 }
                    }
                } label: {
                    Text("onboarding_reminder_enable")
                }
                .buttonStyle(InkButtonStyle())

                Button {
                    withAnimation { page = 2 }
                } label: {
                    Text("onboarding_skip")
                        .font(AppFont.label(12, weight: .semibold))
                        .foregroundColor(AppColor.inkFaint)
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 24)
        }
    }

    // MARK: - ③ 잠금 제안

    private var lockPage: some View {
        VStack(spacing: 0) {
            Spacer()

            Image(systemName: "lock")
                .font(.system(size: 34, weight: .light))
                .foregroundColor(AppColor.inkSecondary)

            Text("onboarding_lock_title")
                .font(AppFont.serif(24, relativeTo: .largeTitle))
                .foregroundColor(AppColor.ink)
                .multilineTextAlignment(.center)
                .lineSpacing(8)
                .padding(.top, 24)

            Text("onboarding_lock_body")
                .font(AppFont.serifBody(14, relativeTo: .body))
                .foregroundColor(AppColor.inkSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(8)
                .padding(.top, 14)
                .padding(.horizontal, 40)

            Spacer()

            VStack(spacing: 12) {
                Button {
                    showPinSetup = true
                } label: {
                    Text("onboarding_lock_enable")
                }
                .buttonStyle(InkButtonStyle())

                Button {
                    finish()
                } label: {
                    Text("onboarding_start")
                        .font(AppFont.label(12, weight: .semibold))
                        .foregroundColor(AppColor.inkFaint)
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 24)
        }
    }

    private func finish() {
        AppSettings.hasOnboarded = true
        Analytics.track(.onboardingCompleted)
        onDone()
    }
}
