//
//  ReToUApp.swift
//  ReToU
//
//  Created by Dean_SSONG on 4/21/25.
//

import SwiftUI
import SwiftData

@main
struct ReToUApp: App {
    @StateObject private var storage = ReflectionStorage()
    
    var body: some Scene {
        WindowGroup {
            LaunchView()
                .environmentObject(storage)
                .modelContainer(DataContainer.shared.container)
        }
    }
}

