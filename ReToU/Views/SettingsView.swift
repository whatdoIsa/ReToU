//
//  SettingsView.swift
//  ReToU
//
//  설정 — 잠금(opt-in), 리마인더, 앱 정보
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var storage: ReflectionStorage

    @State private var lockEnabled = AppSettings.lockEnabled
    @State private var reminderEnabled = AppSettings.reminderEnabled
    @State private var reminderTime = AppSettings.reminderTime
    @State private var showPinSetup = false
    @State private var showPermissionDeniedAlert = false

    var body: some View {
        ZStack {
            AppColor.paper.ignoresSafeArea()
            PaperGrain().ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("settings_title")
                        .font(AppFont.serif(24, relativeTo: .title))
                        .foregroundColor(AppColor.ink)
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppColor.inkFaint)
                    }
                    .accessibilityLabel("닫기")
                }
                .padding(.top, 20)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 26) {
                        // MARK: 리마인더
                        section("settings_section_reminder") {
                            toggleRow(
                                title: "settings_reminder_toggle",
                                subtitle: "settings_reminder_subtitle",
                                isOn: $reminderEnabled
                            )
                            .onChange(of: reminderEnabled) { _, newValue in
                                handleReminderToggle(newValue)
                            }

                            if reminderEnabled {
                                HStack {
                                    Text("settings_reminder_time")
                                        .font(AppFont.label(13, weight: .semibold))
                                        .foregroundColor(AppColor.ink)
                                    Spacer()
                                    DatePicker(
                                        "", selection: $reminderTime,
                                        displayedComponents: .hourAndMinute
                                    )
                                    .labelsHidden()
                                    .onChange(of: reminderTime) { _, newValue in
                                        AppSettings.reminderTime = newValue
                                        ReminderManager.shared.reschedule(hasWrittenToday: storage.hasReflectionForToday())
                                    }
                                }
                                .padding(.top, 2)
                            }
                        }

                        // MARK: 잠금
                        section("settings_section_lock") {
                            toggleRow(
                                title: "settings_lock_toggle",
                                subtitle: "settings_lock_subtitle",
                                isOn: $lockEnabled
                            )
                            .onChange(of: lockEnabled) { _, newValue in
                                handleLockToggle(newValue)
                            }

                            if lockEnabled && KeychainHelper.hasPin {
                                Button {
                                    showPinSetup = true
                                } label: {
                                    Text("settings_change_pin")
                                        .font(AppFont.label(13, weight: .semibold))
                                        .foregroundColor(AppColor.inkSecondary)
                                        .underline()
                                }
                                .padding(.top, 2)
                            }
                        }

                        // MARK: 정보
                        section("settings_section_about") {
                            HStack {
                                Text("settings_version")
                                    .font(AppFont.label(13, weight: .semibold))
                                    .foregroundColor(AppColor.ink)
                                Spacer()
                                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-")
                                    .font(AppFont.label(13, weight: .medium))
                                    .foregroundColor(AppColor.inkFaint)
                                    .monospacedDigit()
                            }
                            Text("settings_privacy_note")
                                .font(AppFont.label(11, weight: .medium))
                                .foregroundColor(AppColor.inkFaint)
                                .padding(.top, 4)
                        }
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 40)
                }
            }
            .padding(.horizontal, 22)
        }
        .sheet(isPresented: $showPinSetup) {
            PinPadView(mode: .setup) { success in
                if success {
                    showPinSetup = false
                    // 설정 도중 취소로 PIN이 없으면 잠금을 켤 수 없음
                    lockEnabled = KeychainHelper.hasPin
                    AppSettings.lockEnabled = lockEnabled
                }
            }
            .onDisappear {
                // 시트를 그냥 닫아 PIN이 저장되지 않았다면 잠금 해제 상태로 되돌림
                if !KeychainHelper.hasPin {
                    lockEnabled = false
                    AppSettings.lockEnabled = false
                }
            }
        }
        .alert("settings_notification_denied_title", isPresented: $showPermissionDeniedAlert) {
            Button("error_confirm", role: .cancel) {}
        } message: {
            Text("settings_notification_denied_message")
        }
    }

    // MARK: - Components

    private func section(_ titleKey: LocalizedStringKey, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(titleKey)
                .font(AppFont.label(11, weight: .bold))
                .foregroundColor(AppColor.inkFaint)
            VStack(alignment: .leading, spacing: 8) {
                content()
            }
            Divider().overlay(AppColor.hairline)
        }
    }

    private func toggleRow(title: LocalizedStringKey, subtitle: LocalizedStringKey, isOn: Binding<Bool>) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(AppFont.label(14, weight: .bold))
                    .foregroundColor(AppColor.ink)
                Text(subtitle)
                    .font(AppFont.label(11, weight: .medium))
                    .foregroundColor(AppColor.inkFaint)
            }
            Spacer()
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(AppColor.ink)
        }
    }

    // MARK: - Actions

    private func handleReminderToggle(_ enabled: Bool) {
        if enabled {
            ReminderManager.shared.requestPermission { granted in
                if granted {
                    AppSettings.reminderEnabled = true
                    ReminderManager.shared.reschedule(hasWrittenToday: storage.hasReflectionForToday())
                    Analytics.track(.reminderEnabled)
                } else {
                    reminderEnabled = false
                    AppSettings.reminderEnabled = false
                    showPermissionDeniedAlert = true
                }
            }
        } else {
            AppSettings.reminderEnabled = false
            ReminderManager.shared.cancelAll()
            Analytics.track(.reminderDisabled)
        }
    }

    private func handleLockToggle(_ enabled: Bool) {
        if enabled {
            if KeychainHelper.hasPin {
                AppSettings.lockEnabled = true
                Analytics.track(.lockEnabled)
            } else {
                showPinSetup = true
            }
        } else {
            AppSettings.lockEnabled = false
            KeychainHelper.deletePin()
            Analytics.track(.lockDisabled)
        }
    }
}
