//
//  TodayView.swift
//  ReToU
//
//  오늘 탭 — 도장을 고르고, 괘선 위에 쓰고, 오늘을 기억한다
//

import SwiftUI

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct TodayView: View {
    @EnvironmentObject var storage: ReflectionStorage
    @State private var selectedEmotion: EmotionType?
    @State private var reflectionText: String = ""
    @State private var promptIndex: Int = 0
    @State private var saveErrorMessage: String?
    @State private var todayReflection: Reflection?
    @State private var showStampOverlay = false
    @State private var isEditingToday = false
    @State private var pastReflections: [Reflection] = []
    @State private var selectedPastReflection: Reflection?

    private static let prompts: [String] = [
        String(localized: "prompt_1", defaultValue: "오늘 마음에 가장 오래 남은 장면은,"),
        String(localized: "prompt_2", defaultValue: "오늘의 나에게 한마디를 건넨다면,"),
        String(localized: "prompt_3", defaultValue: "오늘 가장 고마웠던 순간은,"),
        String(localized: "prompt_4", defaultValue: "오늘 놓아주고 싶은 마음이 있다면,"),
        String(localized: "prompt_5", defaultValue: "내일의 나에게 남기고 싶은 말은,")
    ]

    private var canSubmit: Bool {
        selectedEmotion != nil
            && !reflectionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ZStack {
            AppColor.paper.ignoresSafeArea()
            PaperGrain().ignoresSafeArea()

            if let reflection = todayReflection {
                stampedState(reflection)
            } else {
                writingState
            }

            // 저장 순간의 도장 찍기 오버레이
            if showStampOverlay, let emotion = selectedEmotion ?? todayReflection.flatMap({ EmotionType(rawValue: $0.emotion) }) {
                EmotionSealView(emotion: emotion, style: .stamped, size: 140, rotationSeed: SafeDateManager.shared.todayDateKey().hashValue)
                    .transition(.scale(scale: 1.6).combined(with: .opacity))
            }
        }
        .onAppear { refresh() }
        .alert("error_title", isPresented: .init(
            get: { saveErrorMessage != nil },
            set: { if !$0 { saveErrorMessage = nil } }
        )) {
            Button("error_confirm", role: .cancel) {}
        } message: {
            Text(saveErrorMessage ?? "")
        }
    }

    // MARK: - 작성 상태

    private var writingState: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(Date().formattedDate() + " " + KoreanLiteraryDate.weekdayName(Date()))
                    .font(AppFont.label(12, weight: .bold))
                    .foregroundColor(AppColor.inkFaint)
                Spacer()
                if let days = storage.daysTogether() {
                    Text("함께한 \(days)일째")
                        .font(AppFont.label(11, weight: .bold))
                        .foregroundColor(AppColor.sealRed)
                }
            }
            .padding(.top, 8)

            Text("write_title")
                .font(AppFont.serif(30, relativeTo: .largeTitle))
                .foregroundColor(AppColor.ink)
                .lineSpacing(6)
                .padding(.top, 10)

            EmotionSealPicker(selection: $selectedEmotion)
                .padding(.top, 22)

            Divider()
                .overlay(AppColor.hairline)
                .padding(.top, 18)

            ZStack(alignment: .topLeading) {
                RuledPaper(lineSpacing: 30)
                if reflectionText.isEmpty {
                    Text(Self.prompts[promptIndex])
                        .font(AppFont.serifBody(15, relativeTo: .body))
                        .foregroundColor(AppColor.inkFaint)
                        .padding(.top, 7)
                        .padding(.leading, 5)
                }
                TextEditor(text: $reflectionText)
                    .font(AppFont.serifBody(15, relativeTo: .body))
                    .lineSpacing(9)
                    .foregroundColor(AppColor.ink)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
            }
            .frame(maxHeight: .infinity)

            HStack {
                Button {
                    promptIndex = (promptIndex + 1) % Self.prompts.count
                } label: {
                    Text("prompt_change")
                        .font(AppFont.label(11, weight: .semibold))
                        .foregroundColor(AppColor.inkFaint)
                }
                Spacer()
                Text("\(reflectionText.count)자")
                    .font(AppFont.label(11, weight: .semibold))
                    .foregroundColor(AppColor.inkFaint)
                    .monospacedDigit()
            }
            .padding(.vertical, 6)

            Button(action: submit) {
                Text("write_button")
            }
            .buttonStyle(InkButtonStyle(
                background: canSubmit ? AppColor.ink : AppColor.ink.opacity(0.35)
            ))
            .disabled(!canSubmit)
            .padding(.bottom, 8)
        }
        .padding(.horizontal, 22)
        .onTapGesture { UIApplication.shared.endEditing() }
    }

    // MARK: - 기록 완료 상태

    private func stampedState(_ reflection: Reflection) -> some View {
        let emotion = EmotionType(rawValue: reflection.emotion) ?? .neutral
        return VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(Date().formattedDate() + " " + KoreanLiteraryDate.weekdayName(Date()))
                    .font(AppFont.label(12, weight: .bold))
                    .foregroundColor(AppColor.inkFaint)
                Spacer()
                if let days = storage.daysTogether() {
                    Text("함께한 \(days)일째")
                        .font(AppFont.label(11, weight: .bold))
                        .foregroundColor(AppColor.sealRed)
                }
            }
            .padding(.top, 8)

            Text("today_done_title")
                .font(AppFont.serif(30, relativeTo: .largeTitle))
                .foregroundColor(AppColor.ink)
                .lineSpacing(6)
                .padding(.top, 10)

            HStack(spacing: 10) {
                EmotionSealView(
                    emotion: emotion, style: .stamped, size: 44,
                    rotationSeed: reflection.dateKey.hashValue
                )
                Text(emotion.stampedDayLabel)
                    .font(AppFont.label(12, weight: .bold))
                    .foregroundColor(emotion.sealColor)
            }
            .padding(.top, 24)

            ZStack(alignment: .topLeading) {
                RuledPaper(lineSpacing: 30)
                Text(reflection.content)
                    .font(AppFont.serifBody(15, relativeTo: .body))
                    .lineSpacing(9)
                    .foregroundColor(AppColor.ink)
                    .padding(.top, 5)
            }
            .frame(maxHeight: .infinity, alignment: .topLeading)
            .padding(.top, 14)

            // 지난 오늘 — 이전 연도들의 같은 날 기록
            if let past = pastReflections.first,
               let pastEmotion = EmotionType(rawValue: past.emotion) {
                Divider().overlay(AppColor.hairline)
                Button {
                    selectedPastReflection = past
                    Analytics.track(.pastTodayViewed)
                } label: {
                    HStack(spacing: 10) {
                        EmotionSealView(
                            emotion: pastEmotion, style: .outline, size: 30,
                            rotationSeed: past.dateKey.hashValue
                        )
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(yearsAgo(past))년 전 오늘의 넌")
                                .font(AppFont.label(11, weight: .bold))
                                .foregroundColor(AppColor.inkFaint)
                            Text(past.content.components(separatedBy: "\n").first ?? "")
                                .font(AppFont.serifBody(13, relativeTo: .subheadline))
                                .foregroundColor(AppColor.ink)
                                .lineLimit(1)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(AppColor.inkFaint)
                    }
                    .padding(.vertical, 10)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(yearsAgo(past))년 전 오늘의 기록 보기")
            }

            Button {
                isEditingToday = true
            } label: {
                Text("detail_button_edit")
                    .font(AppFont.serif(14, relativeTo: .subheadline))
                    .foregroundColor(AppColor.ink)
                    .overlay(alignment: .bottom) {
                        Rectangle().fill(AppColor.ink).frame(height: 1.5).offset(y: 3)
                    }
            }
            .padding(.bottom, 14)
        }
        .padding(.horizontal, 22)
        .sheet(isPresented: $isEditingToday, onDismiss: { refresh() }) {
            if let reflection = todayReflection {
                ReflectionEditView(reflection: reflection)
                    .environmentObject(storage)
            }
        }
        .sheet(item: $selectedPastReflection) { reflection in
            ReflectionDetailView(reflection: reflection)
                .environmentObject(storage)
        }
    }

    private func yearsAgo(_ reflection: Reflection) -> Int {
        let currentYear = Calendar.current.component(.year, from: Date())
        let pastYear = Calendar.current.component(.year, from: reflection.date)
        return max(1, currentYear - pastYear)
    }

    // MARK: - Actions

    private func refresh() {
        todayReflection = storage.todayReflection()
        pastReflections = storage.reflectionsOnThisDay()
        if let reflection = todayReflection {
            selectedEmotion = EmotionType(rawValue: reflection.emotion)
            reflectionText = reflection.content
        }
    }

    private func submit() {
        guard let emotion = selectedEmotion else { return }
        let trimmedText = reflectionText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        UIApplication.shared.endEditing()

        switch storage.add(content: trimmedText, emotion: emotion.rawValue, date: Date()) {
        case .success:
            Analytics.track(.reflectionSaved)
            // 오늘 기록 완료 → 오늘 리마인더는 취소하고 이후 일정만 유지
            ReminderManager.shared.reschedule(hasWrittenToday: true)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                showStampOverlay = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                withAnimation(.easeOut(duration: 0.25)) {
                    showStampOverlay = false
                    refresh()
                }
            }
        case .failure(let error):
            saveErrorMessage = error.userFriendlyMessage
        }
    }
}
