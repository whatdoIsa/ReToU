//
//  RecordsView.swift
//  ReToU
//
//  기록 탭 — 도장 자국이 쌓이는 인장 달력 + 장부식 목록
//

import SwiftUI

struct RecordsView: View {
    @EnvironmentObject var storage: ReflectionStorage
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())
    @State private var selectedReflection: Reflection?

    private var calendar: Calendar { Calendar.current }

    /// 이번 달 회고를 일(day) 기준으로 매핑
    private var reflectionsByDay: [Int: Reflection] {
        var map: [Int: Reflection] = [:]
        for reflection in storage.reflections {
            let day = calendar.component(.day, from: reflection.date)
            map[day] = reflection
        }
        return map
    }

    private var daysInMonth: Int {
        let components = DateComponents(year: selectedYear, month: selectedMonth)
        guard let date = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: date) else { return 30 }
        return range.count
    }

    /// 1일의 요일 오프셋 (일요일 시작)
    private var firstWeekdayOffset: Int {
        let components = DateComponents(year: selectedYear, month: selectedMonth, day: 1)
        guard let date = calendar.date(from: components) else { return 0 }
        return calendar.component(.weekday, from: date) - 1
    }

    private var isCurrentMonth: Bool {
        selectedYear == calendar.component(.year, from: Date())
            && selectedMonth == calendar.component(.month, from: Date())
    }

    private var todayDay: Int { calendar.component(.day, from: Date()) }

    /// 이번 달에서 오늘까지(또는 말일까지) 지난 일수
    private var elapsedDays: Int {
        isCurrentMonth ? todayDay : daysInMonth
    }

    var body: some View {
        ZStack {
            AppColor.paper.ignoresSafeArea()
            PaperGrain().ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                header
                countLine
                calendarGrid
                    .padding(.top, 16)
                ledgerList
            }
            .padding(.horizontal, 22)
        }
        .onAppear { reload() }
        .sheet(item: $selectedReflection) { reflection in
            ReflectionDetailView(reflection: reflection)
                .environmentObject(storage)
        }
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            (Text(KoreanLiteraryDate.yearPhrase(selectedYear) + " ")
                .foregroundColor(AppColor.ink)
             + Text(KoreanLiteraryDate.monthName(selectedMonth))
                .foregroundColor(AppColor.sealRed))
                .font(AppFont.serif(24, relativeTo: .title))

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

    private var countLine: some View {
        let stamped = storage.reflections.count
        return (Text("\(elapsedDays)일 중 ")
            + Text("\(stamped)번").fontWeight(.heavy).foregroundColor(AppColor.ink)
            + Text(" 찍었어요"))
            .font(AppFont.label(11, weight: .semibold))
            .foregroundColor(AppColor.inkFaint)
            .padding(.top, 4)
    }

    private var calendarGrid: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
        let weekdays = ["일", "월", "화", "수", "목", "금", "토"]

        return LazyVGrid(columns: columns, spacing: 8) {
            ForEach(weekdays, id: \.self) { day in
                Text(day)
                    .font(AppFont.label(9, weight: .bold))
                    .foregroundColor(AppColor.inkFaint)
            }
            ForEach(0..<firstWeekdayOffset, id: \.self) { _ in
                Color.clear.frame(height: 30)
            }
            ForEach(1...daysInMonth, id: \.self) { day in
                dayCell(day)
            }
        }
    }

    @ViewBuilder
    private func dayCell(_ day: Int) -> some View {
        if let reflection = reflectionsByDay[day],
           let emotion = EmotionType(rawValue: reflection.emotion) {
            let isToday = isCurrentMonth && day == todayDay
            Button {
                selectedReflection = reflection
            } label: {
                EmotionSealView(
                    emotion: emotion,
                    style: isToday ? .today : .outline,
                    size: isToday ? 30 : 28,
                    rotationSeed: reflection.dateKey.hashValue
                )
            }
            .buttonStyle(.plain)
            .frame(height: 30)
            .accessibilityLabel("\(day)일, \(emotion.accessibilityName)")
        } else {
            Text("\(day)")
                .font(AppFont.label(10, weight: .medium))
                .foregroundColor(AppColor.sealIdle)
                .monospacedDigit()
                .frame(height: 30)
        }
    }

    private var ledgerList: some View {
        let sorted = storage.reflections.sorted { $0.date > $1.date }
        return ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                ForEach(Array(sorted.enumerated()), id: \.element.id) { index, reflection in
                    Button {
                        selectedReflection = reflection
                    } label: {
                        HStack(alignment: .firstTextBaseline, spacing: 12) {
                            Text(shortDate(reflection.date))
                                .font(AppFont.serif(13, relativeTo: .subheadline))
                                .foregroundColor(AppColor.ink)
                                .fixedSize()
                            Text(reflection.content.components(separatedBy: "\n").first ?? "")
                                .font(AppFont.label(12, weight: .regular))
                                .foregroundColor(AppColor.inkSecondary)
                                .lineLimit(1)
                            Spacer(minLength: 0)
                        }
                        .padding(.vertical, 11)
                    }
                    .buttonStyle(.plain)
                    if index < sorted.count - 1 {
                        Rectangle()
                            .fill(AppColor.hairline)
                            .frame(height: 1)
                            .opacity(0.7)
                    }
                }
            }
        }
        .padding(.top, 14)
        .overlay(alignment: .top) {
            Rectangle().fill(AppColor.hairline).frame(height: 1)
        }
        .overlay {
            if storage.reflections.isEmpty {
                VStack(spacing: 10) {
                    EmotionSealView(emotion: .happy, style: .idle, size: 44)
                    Text("list_empty_title")
                        .font(AppFont.serif(16, relativeTo: .title3))
                        .foregroundColor(AppColor.ink)
                    Text("list_empty_subtitle")
                        .font(AppFont.label(12, weight: .medium))
                        .foregroundColor(AppColor.inkFaint)
                }
            }
        }
    }

    private func shortDate(_ date: Date) -> String {
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        return "\(month)월 \(day)일"
    }

    private func changeMonth(by value: Int) {
        var month = selectedMonth + value
        var year = selectedYear
        if month < 1 { month = 12; year -= 1 }
        if month > 12 { month = 1; year += 1 }
        selectedMonth = month
        selectedYear = year
        reload()
    }

    private func reload() {
        storage.fetchReflections(forYear: selectedYear, month: selectedMonth)
    }
}
