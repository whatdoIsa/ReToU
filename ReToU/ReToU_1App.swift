//
//  ReToU_1App.swift
//  ReToU_1
//
//  Created by Dean_SSONG on 4/21/25.
//

import SwiftUI

@main
struct ReToUApp: App {
    @StateObject private var storage = ReflectionStorage(useDummy: true)
    
    var body: some Scene {
        WindowGroup {
            LaunchView()
                .environmentObject(storage)
        }
    }
}

