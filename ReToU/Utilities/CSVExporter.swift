//
//  CSVExporter.swift
//  ReToU
//
//  전체 기록을 CSV 파일로 내보내기 — "내 데이터는 언제든 가지고 나갈 수 있다"
//

import Foundation

enum CSVExporter {
    /// 회고 목록을 CSV 파일로 만들어 임시 경로를 반환
    static func export(_ reflections: [Reflection]) -> URL? {
        var rows: [String] = ["날짜,요일,감정,내용"]

        let sorted = reflections.sorted { $0.date < $1.date }
        for reflection in sorted {
            let dateKey = reflection.dateKey
            let weekday = KoreanLiteraryDate.weekdayName(reflection.date)
            let emotionName = EmotionType(rawValue: reflection.emotion)?.accessibilityName ?? reflection.emotion
            rows.append("\(dateKey),\(weekday),\(emotionName),\(escape(reflection.content))")
        }

        // UTF-8 BOM — 엑셀에서 한글이 깨지지 않도록
        let bom = "\u{FEFF}"
        let csv = bom + rows.joined(separator: "\n")

        let fileName = "오늘의넌_기록_\(SafeDateManager.shared.todayDateKey()).csv"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        do {
            try csv.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            print("❌ CSV export failed: \(error)")
            return nil
        }
    }

    /// CSV 필드 이스케이프 — 쉼표·따옴표·줄바꿈 처리
    private static func escape(_ field: String) -> String {
        if field.contains(",") || field.contains("\"") || field.contains("\n") {
            return "\"" + field.replacingOccurrences(of: "\"", with: "\"\"") + "\""
        }
        return field
    }
}
