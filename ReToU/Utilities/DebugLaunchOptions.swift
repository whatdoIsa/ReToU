//
//  DebugLaunchOptions.swift
//  ReToU
//
//  DEBUG 전용 실행 옵션 — 스크린샷/스냅샷 검증용 하네스
//  사용 예: simctl launch <udid> com.dean.ReToU -SeedDemoData 1 -InitialTab records
//

#if DEBUG
import Foundation
import SwiftUI

enum DebugLaunchOptions {
    /// -SeedDemoData 1: 이번 달에 데모 회고를 채워 넣음 (기존 데이터 없을 때만)
    static var shouldSeedDemoData: Bool {
        UserDefaults.standard.bool(forKey: "SeedDemoData")
    }

    /// -InitialTab today|records|mind: 시작 탭 지정
    static var initialTab: String? {
        UserDefaults.standard.string(forKey: "InitialTab")
    }

    /// 이번 달에 감정이 섞인 데모 회고를 시드
    @MainActor
    static func seedDemoDataIfNeeded(using storage: ReflectionStorage) {
        guard shouldSeedDemoData else { return }

        let calendar = Calendar.current
        let today = Date()
        let day = calendar.component(.day, from: today)
        guard day > 1 else { return }

        let samples: [(EmotionType, String)] = [
            (.happy, "드디어 리뉴얼 방향이 정해졌다. 오랜만에 설레는 기분."),
            (.neutral, "평범했지만 나쁘지 않은 하루."),
            (.tired, "일이 많아서 하루가 통째로 사라진 기분."),
            (.happy, "친구랑 저녁. 별거 아닌 얘기가 제일 좋다."),
            (.sad, "괜히 마음이 가라앉는 날이었다."),
            (.happy, "산책하다가 마음이 한결 가벼워졌다."),
            (.angry, "말도 안 되는 일로 화가 났다. 내일은 잊자."),
            (.neutral, "차분하게 하루를 정리했다."),
            (.tired, "몸이 무거웠다. 일찍 자야지."),
            (.happy, "작은 성취가 쌓이는 게 느껴진다.")
        ]

        var sampleIndex = 0
        for d in 1..<day {
            // 이틀에 하루꼴로 비워서 자연스럽게
            if d % 3 == 0 { continue }
            guard let date = calendar.date(from: DateComponents(
                year: calendar.component(.year, from: today),
                month: calendar.component(.month, from: today),
                day: d, hour: 21
            )) else { continue }

            let sample = samples[sampleIndex % samples.count]
            sampleIndex += 1
            _ = storage.add(content: sample.1, emotion: sample.0.rawValue, date: date)
        }

        // "지난 오늘" 검증용 — 작년 같은 날짜에 기록 하나
        if let lastYear = calendar.date(byAdding: .year, value: -1, to: today) {
            _ = storage.add(
                content: "일 년 전의 나도 오늘을 기록하고 있었다. 신기한 기분.",
                emotion: EmotionType.happy.rawValue,
                date: lastYear
            )
        }

        // -SeedToday 1: 오늘 기록까지 채워 완료 상태 확인
        if UserDefaults.standard.bool(forKey: "SeedToday") {
            _ = storage.add(
                content: "드디어 v2.1 기능이 들어갔다. 지난 오늘을 다시 만나는 날.",
                emotion: EmotionType.happy.rawValue,
                date: today
            )
        }
    }
}
#endif
