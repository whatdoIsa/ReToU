//
//  ReflectionEditView.swift
//  ReToU
//
//  회고 수정 — 그때의 마음을 다시 담는다
//

import SwiftUI

struct ReflectionEditView: View {
    let reflection: Reflection
    @EnvironmentObject var storage: ReflectionStorage
    @State private var selectedEmotion: EmotionType?
    @State private var reflectionText: String
    @Environment(\.dismiss) var dismiss
    @State private var saveErrorMessage: String?

    init(reflection: Reflection) {
        self.reflection = reflection
        _selectedEmotion = State(initialValue: EmotionType(rawValue: reflection.emotion) ?? .happy)
        _reflectionText = State(initialValue: reflection.content)
    }

    private var canSubmit: Bool {
        selectedEmotion != nil
            && !reflectionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ZStack {
            AppColor.paper.ignoresSafeArea()
            PaperGrain().ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("edit_title")
                        .font(AppFont.serif(24, relativeTo: .title))
                        .foregroundColor(AppColor.ink)
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppColor.inkFaint)
                    }
                    .accessibilityLabel("닫기")
                }
                .padding(.top, 12)

                Text(reflection.date.formattedDate() + " " + KoreanLiteraryDate.weekdayName(reflection.date))
                    .font(AppFont.label(12, weight: .bold))
                    .foregroundColor(AppColor.inkFaint)
                    .padding(.top, 4)

                EmotionSealPicker(selection: $selectedEmotion)
                    .padding(.top, 20)

                Divider()
                    .overlay(AppColor.hairline)
                    .padding(.top, 16)

                ZStack(alignment: .topLeading) {
                    RuledPaper(lineSpacing: 30)
                    TextEditor(text: $reflectionText)
                        .font(AppFont.serifBody(15, relativeTo: .body))
                        .lineSpacing(9)
                        .foregroundColor(AppColor.ink)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                }
                .frame(maxHeight: .infinity)

                Button(action: submit) {
                    Text("edit_button")
                }
                .buttonStyle(InkButtonStyle(
                    background: canSubmit ? AppColor.ink : AppColor.ink.opacity(0.35)
                ))
                .disabled(!canSubmit)
                .padding(.vertical, 12)
            }
            .padding(.horizontal, 22)
            .onTapGesture { UIApplication.shared.endEditing() }
        }
        .navigationBarBackButtonHidden(true)
        .alert("error_title", isPresented: .init(
            get: { saveErrorMessage != nil },
            set: { if !$0 { saveErrorMessage = nil } }
        )) {
            Button("error_confirm", role: .cancel) {}
        } message: {
            Text(saveErrorMessage ?? "")
        }
    }

    private func submit() {
        guard let emotion = selectedEmotion else { return }
        let trimmedText = reflectionText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }

        switch storage.update(reflection: reflection, content: trimmedText, emotion: emotion.rawValue) {
        case .success:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            dismiss()
        case .failure(let error):
            saveErrorMessage = error.userFriendlyMessage
        }
    }
}
