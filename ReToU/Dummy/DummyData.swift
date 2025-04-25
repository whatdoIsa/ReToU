//
//  DummyData.swift
//  ReToU
//
//  Created by Dean_SSONG on 4/20/25.
//

import Foundation

struct DummyData {
    static let reflections: [Reflection] = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        return [
            // February 2025
            Reflection(date: formatter.date(from: "2025-02-05")!, emotion: "😊", content: "2월 초 즐거운 하루!"),
            Reflection(date: formatter.date(from: "2025-02-15")!, emotion: "😐", content: "2월 중순 평범한 날"),
            Reflection(date: formatter.date(from: "2025-02-25")!, emotion: "😐", content: "2월 말 슬펐던 하루"),

            // March 2025
            Reflection(date: formatter.date(from: "2025-03-01")!, emotion: "😊", content: "3월 시작 활기차게!"),
            Reflection(date: formatter.date(from: "2025-03-12")!, emotion: "😊", content: "3월 중순 화나는 일 발생"),
            Reflection(date: formatter.date(from: "2025-03-28")!, emotion: "😐", content: "3월 말 차분한 마무리"),

        ]
    }()
}
