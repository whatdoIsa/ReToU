//  Reflection.swift
//  ReToU
//
//  Created by Dean_SSONG on 4/17/25.
//

import Foundation

struct Reflection: Identifiable, Codable {
    let id: UUID = UUID()
    let date: Date
    let emotion: String
    let content: String
}
