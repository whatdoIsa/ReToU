//
//  ReflectionDetailView.swift
//  ReToU
//
//  회고 상세 — 책장 한 페이지. 세로쓰기 날짜와 밑줄 글귀 버튼.
//

import SwiftUI

/// 세로쓰기 텍스트 (책장 여백의 날짜)
struct VerticalText: View {
    let text: String
    var font: Font
    var color: Color
    var spacing: CGFloat = 2

    var body: some View {
        VStack(spacing: spacing) {
            ForEach(Array(text.enumerated()), id: \.offset) { _, char in
                Text(String(char))
                    .font(font)
                    .foregroundColor(color)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(text)
    }
}

struct ReflectionDetailView: View {
    let reflection: Reflection
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var storage: ReflectionStorage
    @State private var showDeleteAlert = false
    @State private var isEditing = false
    @State private var deleteErrorMessage: String?

    private var emotion: EmotionType {
        EmotionType(rawValue: reflection.emotion) ?? .neutral
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.paper.ignoresSafeArea()
                PaperGrain().ignoresSafeArea()

                HStack(alignment: .top, spacing: 14) {
                    // 본문 영역
                    VStack(alignment: .leading, spacing: 0) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppColor.inkFaint)
                        }
                        .accessibilityLabel("닫기")
                        .padding(.top, 8)

                        HStack(spacing: 9) {
                            EmotionSealView(
                                emotion: emotion, style: .stamped, size: 38,
                                rotationSeed: reflection.dateKey.hashValue
                            )
                            Text(emotion.stampedDayLabel)
                                .font(AppFont.label(11, weight: .bold))
                                .foregroundColor(emotion.sealColor)
                        }
                        .padding(.top, 18)

                        ScrollView(showsIndicators: false) {
                            ZStack(alignment: .topLeading) {
                                RuledPaper(lineSpacing: 30)
                                Text(reflection.content)
                                    .font(AppFont.serifBody(15, relativeTo: .body))
                                    .lineSpacing(9)
                                    .foregroundColor(AppColor.ink)
                                    .padding(.top, 5)
                                    .frame(maxWidth: .infinity, alignment: .topLeading)
                            }
                        }
                        .padding(.top, 16)

                        HStack(spacing: 22) {
                            Button {
                                isEditing = true
                            } label: {
                                underlined("detail_button_edit", color: AppColor.ink)
                            }
                            Button {
                                showDeleteAlert = true
                            } label: {
                                underlined("detail_button_delete", color: AppColor.sealRed)
                            }
                        }
                        .padding(.vertical, 14)
                    }

                    // 세로쓰기 날짜
                    VStack(alignment: .center, spacing: 14) {
                        VerticalText(
                            text: verticalDateText,
                            font: AppFont.serif(16, relativeTo: .title3),
                            color: AppColor.ink
                        )
                        VerticalText(
                            text: verticalSubText,
                            font: AppFont.serifBody(10, relativeTo: .caption),
                            color: AppColor.inkFaint
                        )
                        Spacer()
                    }
                    .padding(.top, 34)
                    .padding(.leading, 12)
                    .overlay(alignment: .leading) {
                        Rectangle().fill(AppColor.hairline).frame(width: 1)
                    }
                }
                .padding(.horizontal, 22)
            }
            .navigationDestination(isPresented: $isEditing) {
                ReflectionEditView(reflection: reflection)
            }
            .alert("delete_alert_title \n delete_alert_subtitle", isPresented: $showDeleteAlert) {
                Button("delete_alert_confirm", role: .destructive) {
                    deleteReflection()
                }
                Button("delete_alert_cancel", role: .cancel) {}
            }
            .alert("error_title", isPresented: .init(
                get: { deleteErrorMessage != nil },
                set: { if !$0 { deleteErrorMessage = nil } }
            )) {
                Button("error_confirm", role: .cancel) {}
            } message: {
                Text(deleteErrorMessage ?? "")
            }
        }
    }

    private var verticalDateText: String {
        let month = Calendar.current.component(.month, from: reflection.date)
        let day = Calendar.current.component(.day, from: reflection.date)
        return "\(KoreanLiteraryDate.monthName(month)) \(KoreanLiteraryDate.dayPhrase(day))"
    }

    private var verticalSubText: String {
        let year = Calendar.current.component(.year, from: reflection.date)
        return "\(KoreanLiteraryDate.yearPhrase(year)) \(KoreanLiteraryDate.weekdayName(reflection.date))"
    }

    private func underlined(_ key: LocalizedStringKey, color: Color) -> some View {
        Text(key)
            .font(AppFont.serif(14, relativeTo: .subheadline))
            .foregroundColor(color)
            .overlay(alignment: .bottom) {
                Rectangle().fill(color).frame(height: 1.5).offset(y: 3)
            }
    }

    private func deleteReflection() {
        switch storage.delete(reflection: reflection) {
        case .success:
            Analytics.track(.reflectionDeleted)
            // 오늘 기록을 지웠다면 오늘 리마인더가 되살아나야 함
            ReminderManager.shared.reschedule(hasWrittenToday: storage.hasReflectionForToday())
            dismiss()
        case .failure(let error):
            deleteErrorMessage = error.userFriendlyMessage
        }
    }
}
