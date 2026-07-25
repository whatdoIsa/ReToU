//
//  DummyData.swift
//  ReToU
//
//  Created by Dean_SSONG on 4/20/25.
//

import Foundation

// 프리뷰/개발 전용 더미 데이터 — 배포 빌드에는 포함되지 않음
// 주의: 이 인스턴스들은 ModelContext에 insert되지 않으므로 삭제/수정 대상이 되어서는 안 됨
#if DEBUG
struct DummyData {
    static let reflections: [Reflection] = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        var dummyReflections: [Reflection] = []
        
        // February 2025
        let feb05 = Reflection(date: formatter.date(from: "2025-02-05")!, emotion: "😊", content: "2월 초 즐거운 하루!", order: 0)
        let feb15 = Reflection(date: formatter.date(from: "2025-02-15")!, emotion: "😐", content: "2월 중순 평범한 날", order: 1)
        let feb25 = Reflection(date: formatter.date(from: "2025-02-25")!, emotion: "😐", content: "2월 말 슬펐던 하루", order: 2)
        
        // March 2025
        let mar01 = Reflection(date: formatter.date(from: "2025-03-01")!, emotion: "😊", content: "3월 시작 활기차게!", order: 3)
        let mar12 = Reflection(date: formatter.date(from: "2025-03-12")!, emotion: "😊", content: "3월 중순 화나는 일 발생", order: 4)
        let mar28 = Reflection(date: formatter.date(from: "2025-03-28")!, emotion: "😐", content: "3월 말 차분한 마무리", order: 5)
        
        dummyReflections.append(contentsOf: [feb05, feb15, feb25, mar01, mar12, mar28])
        
        return dummyReflections
    }()
}
#endif
