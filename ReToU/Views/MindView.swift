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

    @State private var showSettings = false

    var body: some View {
        ZStack {
            AppColor.paper.ignoresSafeArea()
            PaperGrain().ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                header

                (Text("\(String(year))년 \(month)월 · ")
                 + Text("\(KoreanLiteraryDate.nativeCount(totalCount)) 번의 새김으로 지어졌어요"))
                    .font(AppFont.label(11, weight: .semibold))
                    .foregroundColor(AppColor.inkFaint)
                    .padding(.top, 4)

                if totalCount == 0 {
                    emptyState
                } else {
                    JogakboView(entries: sortedSummary)
                        .frame(height: sortedSummary.count > 2 ? 158 : 96)
                        .padding(.top, 16)

                    Text("한 달의 마음을 이어 붙인 조각보 — 조각의 크기가 곧 날수예요")
                        .font(AppFont.label(10, weight: .medium))
                        .foregroundColor(AppColor.inkFaint)
                        .padding(.top, 8)

                    Divider()
                        .overlay(AppColor.hairline)
                        .padding(.top, 16)

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
            Text("\(KoreanLiteraryDate.monthName(month))의 마음결")
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

                Button { showSettings = true } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColor.inkSecondary)
                }
                .accessibilityLabel("설정")
            }
        }
        .padding(.top, 12)
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environmentObject(storage)
        }
    }

    // (조각보 뷰로 대체됨 — JogakboView)

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
            defaultValue: "이번 달 조각보에서 가장 넓은 조각은 \(dominant.accessibilityName), \(KoreanLiteraryDate.nativeCount(count)) 날이에요."
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
