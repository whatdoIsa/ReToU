//  Reflection.swift
//  ReToU
//
//  Created by Dean_SSONG on 4/17/25.
//

import Foundation
import SwiftData

@Model
final class Reflection {
    var id: UUID
    var date: Date
    var emotion: String
    var content: String
    var order: Int
    var createdAt: Date
    var updatedAt: Date
    
    init(date: Date, emotion: String, content: String, order: Int = 0) {
        self.id = UUID()
        self.date = date
        self.emotion = emotion
        self.content = content
        self.order = order
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
