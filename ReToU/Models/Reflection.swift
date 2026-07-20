//  Reflection.swift
//  ReToU
//
//  Created by Dean_SSONG on 4/17/25.
//

import Foundation
import SwiftData

@Model
final class Reflection {
    // CloudKit 동기화 요건: 모든 속성은 기본값을 가져야 함
    var id: UUID = UUID()
    var date: Date = Date()
    var emotion: String = ""
    var content: String = ""
    var order: Int = 0
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

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
