//
//  MindView.swift
//  ReToU
//
//  마음 탭 — 그래프가 아니라 답장. 분포는 인장 + 잉크 막대, 인사이트는 짧은 편지.
//

import SwiftUI

struct MindView: View {
    @EnvironmentObject var storage: ReflectionStorage
    @State private var currentDate = Date()

    private var calendar: Calendar { Calendar.current }
    private var year: Int { calendar.component(.year, from: currentDate) }
    private var month: Int { calendar.component(.month, from: currentDate) }

    private var summary: [EmotionType: Int] {
        storage.emotionSummary(forYear: year, month: month)
    }

    private var totalCount: Int {
        summary.values.reduce(0, +)
    }

    /// 많이 찍힌 순으로 정렬된 (감정, 횟수)
    private var sortedSummary: [(emotion: EmotionType, count: Int)] {
        EmotionType.allCases
            .map { ($0, summary[$0] ?? 0) }
            .filter { $0.1 > 0 }
            .sorted { $0.1 > $1.1 }
    }

    private var maxCount: Int {
        sortedSummary.first?.count ?? 1
    }

    private var isCurrentMonth: Bool {
        year == calendar.component(.year, from: Date())
            && month == calendar.component(.month, from: Date())
    }

    var body: some View {
        ZStack {
            AppColor.paper.ignoresSafeArea()
            PaperGrain().ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                header

                Text("\(totalCount)번의 기록으로 그려졌어요")
                    .font(AppFont.label(11, weight: .semibold))
                    .foregroundColor(AppColor.inkFaint)
                    .padding(.top, 4)

                if totalCount == 0 {
                    emptyState
                } else {
                    distribution
                        .padding(.top, 20)

                    Divider()
                        .overlay(AppColor.hairline)
                        .padding(.top, 20)

                    letter
                        .padding(.top, 16)
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 22)
        }
        .onAppear { currentDate = Date() }
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("\(KoreanLiteraryDate.monthName(month))의 마음")
                .font(AppFont.serif(24, relativeTo: .title))
                .foregroundColor(AppColor.ink)

            Spacer()

            HStack(spacing: 22) {
                Button { changeMonth(by: -1) } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColor.inkSecondary)
                }
                .accessibilityLabel("이전 달")

                Button { changeMonth(by: 1) } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(isCurrentMonth ? AppColor.hairline : AppColor.inkSecondary)
                }
                .disabled(isCurrentMonth)
                .accessibilityLabel("다음 달")
            }
        }
        .padding(.top, 12)
    }

    private var distribution: some View {
        VStack(spacing: 10) {
            ForEach(sortedSummary, id: \.emotion) { entry in
                HStack(spacing: 10) {
                    EmotionSealView(emotion: entry.emotion, style: .outline, size: 22)
                    Text(entry.emotion.accessibilityName)
                        .font(AppFont.label(12, weight: .bold))
                        .foregroundColor(AppColor.ink)
                        .frame(width: 30, alignment: .leading)

                    GeometryReader { geo in
                        InkButtonShape()
                            .fill(entry.emotion.sealColor)
                            .frame(width: max(14, geo.size.width * CGFloat(entry.count) / CGFloat(maxCount)), height: 10)
                            .frame(maxHeight: .infinity, alignment: .center)
                    }

                    Text("\(entry.count)일")
                        .font(AppFont.label(12, weight: .medium))
                        .foregroundColor(AppColor.inkSecondary)
                        .monospacedDigit()
                        .frame(width: 32, alignment: .trailing)
                }
                .frame(height: 24)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(entry.emotion.accessibilityName) \(entry.count)일")
            }
        }
    }

    private var letter: some View {
        let (dominant, message) = storage.dominantEmotionMessage(forYear: year, month: month)
        return VStack(alignment: .leading, spacing: 8) {
            Text("mind_letter_title")
                .font(AppFont.label(11, weight: .bold))
                .foregroundColor(AppColor.inkFaint)

            Text(letterBody(dominant: dominant, message: message))
                .font(AppFont.serifBody(14, relativeTo: .body))
                .foregroundColor(AppColor.ink)
                .lineSpacing(10)

            HStack {
                Spacer()
                Text("mind_letter_signature")
                    .font(AppFont.serifBody(12, relativeTo: .caption))
                    .foregroundColor(AppColor.inkFaint)
            }
            .padding(.top, 4)

            Text("mind_privacy_note")
                .font(AppFont.label(9, weight: .medium))
                .foregroundColor(AppColor.sealIdle)
                .padding(.top, 2)
        }
    }

    private func letterBody(dominant: EmotionType?, message: String) -> String {
        guard let dominant, let count = summary[dominant] else { return message }
        let opening = String(
            localized: "mind_letter_opening",
            defaultValue: "이번 달엔 \(dominant.accessibilityName) 도장을 \(count)번 찍었어요."
        )
        return opening + "\n" + message
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Spacer()
            EmotionSealView(emotion: .neutral, style: .idle, size: 44)
            Text("mind_empty_title")
                .font(AppFont.serif(16, relativeTo: .title3))
                .foregroundColor(AppColor.ink)
            Text("list_empty_subtitle")
                .font(AppFont.label(12, weight: .medium))
                .foregroundColor(AppColor.inkFaint)
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private func changeMonth(by value: Int) {
        if let newDate = calendar.date(byAdding: .month, value: value, to: currentDate) {
            currentDate = newDate
        }
    }
}
