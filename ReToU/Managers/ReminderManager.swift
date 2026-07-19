//
//  ReminderManager.swift
//  ReToU
//
//  일일 기록 리마인더 — "오늘의 도장, 아직이에요"
//  향후 14일치를 개별 예약하고, 이미 기록한 날은 건너뛴다.
//

import Foundation
import UserNotifications

@MainActor
final class ReminderManager {
    static let shared = ReminderManager()
    private init() {}

    private let identifierPrefix = "daily-reminder-"

    // MARK: - Permission

    /// 알림 권한 요청. 결과를 콜백으로 전달.
    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async { completion(granted) }
        }
    }

    func permissionStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async { completion(settings.authorizationStatus) }
        }
    }

    // MARK: - Scheduling

    /// 설정에 맞춰 리마인더 전체 재예약.
    /// - 꺼져 있으면 전부 취소
    /// - 켜져 있으면 향후 14일을 개별 예약하되, 오늘 이미 기록했으면 오늘은 제외
    func reschedule(hasWrittenToday: Bool) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        guard AppSettings.reminderEnabled else { return }

        let calendar = Calendar.current
        let hour = AppSettings.reminderHour
        let minute = AppSettings.reminderMinute
        let now = Date()

        for offset in 0..<14 {
            guard let day = calendar.date(byAdding: .day, value: offset, to: now) else { continue }

            // 오늘 이미 기록했으면 오늘 알림은 건너뜀
            if offset == 0 && hasWrittenToday { continue }

            var components = calendar.dateComponents([.year, .month, .day], from: day)
            components.hour = hour
            components.minute = minute

            // 오늘인데 알림 시각이 이미 지났으면 건너뜀
            guard let fireDate = calendar.date(from: components), fireDate > now else { continue }

            let content = UNMutableNotificationContent()
            content.title = String(localized: "reminder_title", defaultValue: "오늘의 넌")
            content.body = String(localized: "reminder_body", defaultValue: "오늘의 도장, 아직이에요. 한 줄이면 충분해요.")
            content.sound = .default

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(
                identifier: identifierPrefix + SafeDateManager.shared.generateDateKey(for: day),
                content: content,
                trigger: trigger
            )
            center.add(request)
        }
    }

    /// 리마인더 전체 취소
    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
