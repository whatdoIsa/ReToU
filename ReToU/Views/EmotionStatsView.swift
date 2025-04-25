//
//  EmotionStatsView.swift
//  ReToU_1
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
    
    
    var body: some View {
        VStack {
            // 월 이동 헤더
            HStack(spacing: 8) {
                Button(action: { changeMonth(by: -1) }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.gray)
                }

                Text(currentDate.yearMonthString())
                    .font(.custom("BMYEONSUNG-OTF", size: 26))
                    .fontWeight(.semibold)

                Button(action: { changeMonth(by: 1) }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray.opacity(0.5))
                }
            }

            Divider()
                .padding(.bottom, 8)

            // 현재 월 기준 데이터 계산
            let year = Calendar.current.component(.year, from: currentDate)
            let month = Calendar.current.component(.month, from: currentDate)
            let summary = storage.emotionSummary(forYear: year, month: month)
            let stats: [EmotionStat] = summary.map { EmotionStat(emotion: $0.key, count: $0.value) }
            let (_, message) = storage.dominantEmotionMessage(forYear: year, month: month)

            // 차트 표시
            Chart(stats) { stat in
                BarMark(
                    x: .value("감정", stat.emotion.rawValue),
                    y: .value("횟수", stat.count)
                )
                .foregroundStyle(stat.emotion.color)
            }
            .chartXAxis {
                AxisMarks { value in
                    if let emotionString = value.as(String.self),
                       let emotion = EmotionType(rawValue: emotionString) {
                        AxisValueLabel {
                            Text(emotion.rawValue)
                                .font(.custom("BMYEONSUNG-OTF", size: 26))
                        }
                    }
                }
            }
            .frame(height: 220)
            .padding(.horizontal)

            // 감정 분석 메시지
            Text(message)
                .font(.custom("BMYEONSUNG-OTF", size: 22))
                .padding()
                .multilineTextAlignment(.center)

            Spacer()
        }
        .padding()
        .background(Color(hex: "#FFF9EC").ignoresSafeArea())
    }
    func changeMonth(by value: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: value, to: currentDate) {
            currentDate = newDate
        }
    }
}

