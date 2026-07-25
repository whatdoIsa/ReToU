//
//  AppSettings.swift
//  ReToU
//
//  앱 설정 값 — UserDefaults 키를 한 곳에서 관리
//

import Foundation

enum AppSettings {
    private static let defaults = UserDefaults.standard

    enum Keys {
        static let hasOnboarded = "has_onboarded"
        static let lockEnabled = "lock_enabled"
        static let reminderEnabled = "reminder_enabled"
        static let reminderHour = "reminder_hour"
        static let reminderMinute = "reminder_minute"
    }

    /// 온보딩 완료 여부
    static var hasOnboarded: Bool {
        get { defaults.bool(forKey: Keys.hasOnboarded) }
        set { defaults.set(newValue, forKey: Keys.hasOnboarded) }
    }

    /// 잠금 사용 여부 (기본 꺼짐 — 온보딩/설정에서 opt-in)
    static var lockEnabled: Bool {
        get { defaults.bool(forKey: Keys.lockEnabled) }
        set { defaults.set(newValue, forKey: Keys.lockEnabled) }
    }

    /// 리마인더 사용 여부
    static var reminderEnabled: Bool {
        get { defaults.bool(forKey: Keys.reminderEnabled) }
        set { defaults.set(newValue, forKey: Keys.reminderEnabled) }
    }

    /// 리마인더 시각 (기본 21:30)
    static var reminderHour: Int {
        get { defaults.object(forKey: Keys.reminderHour) as? Int ?? 21 }
        set { defaults.set(newValue, forKey: Keys.reminderHour) }
    }

    static var reminderMinute: Int {
        get { defaults.object(forKey: Keys.reminderMinute) as? Int ?? 30 }
        set { defaults.set(newValue, forKey: Keys.reminderMinute) }
    }

    /// 리마인더 시각을 Date로 (TimePicker 바인딩용)
    static var reminderTime: Date {
        get {
            var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            components.hour = reminderHour
            components.minute = reminderMinute
            return Calendar.current.date(from: components) ?? Date()
        }
        set {
            reminderHour = Calendar.current.component(.hour, from: newValue)
            reminderMinute = Calendar.current.component(.minute, from: newValue)
        }
    }
}
