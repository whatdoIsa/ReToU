//
//  EmotionStatsView.swift
//  ReToU
//
//  Created by Dean_SSONG on 4/22/25.
//

import SwiftUI
import Charts

struct EmotionStat: Identifiable {
    let id = UUID()
    let emotion: EmotionType
    let count: Int
}

struct EmotionStatsView: View {
    @EnvironmentObject var storage: ReflectionStorage
    @State private var currentDate = Date()

    // 현재 월 기준 데이터 — body 밖에서 계산해 뷰 코드와 분리
    private var currentYear: Int { Calendar.current.component(.year, from: currentDate) }
    private var currentMonth: Int { Calendar.current.component(.month, from: currentDate) }

    private var stats: [EmotionStat] {
        storage.emotionSummary(forYear: currentYear, month: currentMonth)
            .map { EmotionStat(emotion: $0.key, count: $0.value) }
    }

    private var feedbackMessage: String {
        storage.dominantEmotionMessage(forYear: currentYear, month: currentMonth).1
    }

    var body: some View {
        VStack {
            // 월 이동 헤더
            HStack(spacing: 8) {
                Button(action: { changeMonth(by: -1) }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.gray)
                }
                .accessibilityLabel("이전 달")

                Text(currentDate.yearMonthString())
                    .font(AppFont.hand(26, relativeTo: .title2))
                    .fontWeight(.semibold)
                    .foregroundColor(AppColor.textPrimary)

                Button(action: { changeMonth(by: 1) }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray.opacity(0.5))
                }
                .accessibilityLabel("다음 달")
            }

            Divider()
                .padding(.bottom, 8)

            // 차트 표시
            Chart(stats) { stat in
                BarMark(
                    x: .value("감정", stat.emotion.rawValue),
                    y: .value("횟수", stat.count)
                )
                .foregroundStyle(stat.emotion.color)
            }
            .chartXAxis {
                AxisMarks(preset: .aligned) { value in
                    AxisGridLine()
                        .foregroundStyle(Color.gray.opacity(0.4))
                    AxisTick()
                    AxisValueLabel {
                        if let emotionString = value.as(String.self),
                           let emotion = EmotionType(rawValue: emotionString) {
                            Text(emotion.rawValue)
                                .font(AppFont.hand(26, relativeTo: .title2))
                                .foregroundColor(AppColor.textPrimary)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(preset: .extended) { value in
                    AxisGridLine()
                        .foregroundStyle(Color.gray.opacity(0.7))
                    AxisTick()
                    AxisValueLabel {
                        Text("\(value.as(Int.self) ?? 0)")
                            .font(AppFont.hand(14, relativeTo: .caption))
                            .foregroundColor(AppColor.textPrimary.opacity(0.7))
                    }
                }
            }
            .frame(height: 220)
            .padding(.horizontal)

            // 감정 분석 메시지
            Text(feedbackMessage)
                .font(AppFont.hand(22, relativeTo: .title3))
                .padding()
                .multilineTextAlignment(.center)
                .foregroundColor(AppColor.textPrimary)

            Spacer()
        }
        .padding()
        .background(AppColor.background.ignoresSafeArea())
    }

    func changeMonth(by value: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: value, to: currentDate) {
            currentDate = newDate
        }
    }
}
