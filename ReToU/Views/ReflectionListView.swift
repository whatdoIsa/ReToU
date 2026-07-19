//  ReflectionListView.swift
//  ReToU
//
//  Created by Dean_SSONG on 4/18/25.
//

import SwiftUI

struct ReflectionListView: View {
    @EnvironmentObject var storage: ReflectionStorage
    @State private var isShowingPicker = false
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())
    @State private var selectedReflection: Reflection? = nil
    @State private var isShowingStatsView = false

    var body: some View {
        NavigationStack {
            VStack {
                Text("list_title")
                    .font(AppFont.hand(40, relativeTo: .largeTitle))
                    .fontWeight(.bold)
                    .foregroundColor(AppColor.textPrimary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(AppColor.background)

                Spacer()

                Button(action: {
                    isShowingPicker = true
                }) {
                    Text("\(Date.localizedYearMonth(year: selectedYear, month: selectedMonth)) ▼")
                        .font(AppFont.hand(20, relativeTo: .body))
                        .foregroundColor(AppColor.textPrimary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: AppRadius.field)
                                .fill(AppColor.surface)
                                .shadow(color: .gray.opacity(0.3), radius: 2, x: 0, y: 1)
                        )
                }
                .accessibilityLabel("조회할 연도와 월 선택")
                .sheet(isPresented: $isShowingPicker) {
                    YearMonthPickerSheet(
                        selectedYear: $selectedYear,
                        selectedMonth: $selectedMonth,
                        onDone: {
                            isShowingPicker = false
                            storage.fetchReflections(forYear: selectedYear, month: selectedMonth)
                        }
                    )
                }
                .navigationBarBackButtonHidden(true)

                if storage.reflections.isEmpty {
                    // 해당 월에 기록이 없을 때의 빈 상태
                    emptyState
                } else {
                    reflectionList
                }
            }
            .background(AppColor.background.ignoresSafeArea())
            .sheet(item: $selectedReflection) { reflection in
                ReflectionDetailView(reflection: reflection)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isShowingStatsView = true
                    }) {
                        Image(systemName: "chart.bar.xaxis")
                            .font(.system(size: 24))
                            .foregroundColor(AppColor.coral)
                            .symbolRenderingMode(.hierarchical)
                    }
                    .accessibilityLabel("감정 통계 보기")
                }
            }
            .sheet(isPresented: $isShowingStatsView) {
                EmotionStatsView()
                    .environmentObject(storage)
            }
        }
        .onAppear {
            storage.fetchReflections(forYear: selectedYear, month: selectedMonth)
        }
        .onChange(of: selectedYear) { _, _ in
            storage.fetchReflections(forYear: selectedYear, month: selectedMonth)
        }
        .onChange(of: selectedMonth) { _, _ in
            storage.fetchReflections(forYear: selectedYear, month: selectedMonth)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Text("🌿")
                .font(.system(size: 48))
                .accessibilityHidden(true)
            Text("list_empty_title")
                .font(AppFont.hand(26, relativeTo: .title2))
                .foregroundColor(AppColor.textPrimary)
            Text("list_empty_subtitle")
                .font(AppFont.hand(20, relativeTo: .body))
                .foregroundColor(AppColor.textSecondary)
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var reflectionList: some View {
        List {
            ForEach(storage.reflections) { reflection in
                Button {
                    selectedReflection = reflection
                } label: {
                    ReflectionRow(reflection: reflection)
                }
                .buttonStyle(PlainButtonStyle())
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
                .padding(.horizontal)
                .padding(.vertical, 4)
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(AppColor.background)
    }
}

/// 리스트의 개별 회고 행
private struct ReflectionRow: View {
    let reflection: Reflection

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppRadius.field)
                .fill(AppColor.surface)
                .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(reflection.date.formattedDate())
                        .font(AppFont.hand(22, relativeTo: .title3))
                        .foregroundColor(AppColor.textPrimary)

                    Text(reflection.content.components(separatedBy: "\n").first ?? "")
                        .font(AppFont.hand(18, relativeTo: .body))
                        .foregroundColor(AppColor.textPrimary)
                        .lineLimit(1)
                }

                Spacer()

                Text(reflection.emotion)
                    .font(AppFont.hand(34, relativeTo: .title))
                    .accessibilityLabel(EmotionType(rawValue: reflection.emotion)?.accessibilityName ?? reflection.emotion)
            }
            .padding()
        }
    }
}
