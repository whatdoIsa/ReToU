//
//  MainTabView.swift
//  ReToU
//
//  오늘 · 기록 · 마음 — 3탭 구조
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var storage: ReflectionStorage
    @State private var selectedTab: Tab = MainTabView.initialTab

    enum Tab { case today, records, mind }

    private static var initialTab: Tab {
        #if DEBUG
        switch DebugLaunchOptions.initialTab {
        case "records": return .records
        case "mind": return .mind
        default: return .today
        }
        #else
        return .today
        #endif
    }

    init() {
        // 탭바를 종이 톤으로
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(AppColor.paper)
        appearance.shadowColor = UIColor(AppColor.hairline)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView()
                .tabItem { Label("tab_today", systemImage: "smallcircle.filled.circle") }
                .tag(Tab.today)

            RecordsView()
                .tabItem { Label("tab_records", systemImage: "book.closed") }
                .tag(Tab.records)

            MindView()
                .tabItem { Label("tab_mind", systemImage: "heart") }
                .tag(Tab.mind)
        }
        .tint(AppColor.ink)
        .onAppear {
            #if DEBUG
            DebugLaunchOptions.seedDemoDataIfNeeded(using: storage)
            #endif
            // 앱을 열 때마다 향후 14일 리마인더 창을 앞으로 굴림
            ReminderManager.shared.reschedule(hasWrittenToday: storage.hasReflectionForToday())
        }
    }
}
