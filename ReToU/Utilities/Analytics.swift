//
//  Analytics.swift
//  ReToU
//
//  경량 측정 추상화 — 익명 이벤트만 기록
//  현재 백엔드는 로컬 로그. TelemetryDeck 등 실제 서비스 연동 시
//  AnalyticsBackend 구현체 하나만 추가하면 됨 (호출부 변경 없음).
//

import Foundation

enum AnalyticsEvent: String {
    case appOpened = "app_opened"
    case onboardingCompleted = "onboarding_completed"
    case reflectionSaved = "reflection_saved"
    case reflectionEdited = "reflection_edited"
    case reflectionDeleted = "reflection_deleted"
    case reminderEnabled = "reminder_enabled"
    case reminderDisabled = "reminder_disabled"
    case lockEnabled = "lock_enabled"
    case lockDisabled = "lock_disabled"
}

protocol AnalyticsBackend {
    func send(_ event: AnalyticsEvent, parameters: [String: String])
}

enum Analytics {
    /// 실제 서비스 연동 시 여기에 백엔드를 추가 (예: TelemetryDeckBackend())
    private static let backends: [AnalyticsBackend] = [ConsoleAnalyticsBackend()]

    static func track(_ event: AnalyticsEvent, parameters: [String: String] = [:]) {
        for backend in backends {
            backend.send(event, parameters: parameters)
        }
    }
}

/// 개발용 콘솔 로거 — 릴리즈에서는 아무것도 하지 않음
struct ConsoleAnalyticsBackend: AnalyticsBackend {
    func send(_ event: AnalyticsEvent, parameters: [String: String]) {
        #if DEBUG
        let params = parameters.isEmpty ? "" : " \(parameters)"
        print("📊 [\(event.rawValue)]\(params)")
        #endif
    }
}
