//
//  ReflectionEditView.swift
//  ReToU
//
//  Created by Dean_SSONG on 4/20/25.
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

    /// 감정 선택 + 내용 입력이 모두 완료되어야 저장 가능
    private var canSubmit: Bool {
        selectedEmotion != nil
            && !reflectionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            NavigationStack {
                ScrollView {
                    VStack(spacing: 28) {
                        Text("edit_title")
                            .font(AppFont.hand(40, relativeTo: .largeTitle))
                            .foregroundColor(AppColor.textPrimary.opacity(0.7))

                        Text(reflection.date.formattedDate())
                            .font(AppFont.hand(26, relativeTo: .title2))
                            .foregroundColor(AppColor.textPrimary)

                        EmotionPicker(selection: $selectedEmotion)

                        TextEditor(text: $reflectionText)
                            .frame(height: 200)
                            .padding()
                            .scrollContentBackground(.hidden)
                            .background(AppColor.background)
                            .foregroundColor(AppColor.textPrimary)
                            .cornerRadius(AppRadius.field)
                            .padding(.horizontal)

                        Button(action: submit) {
                            Text("edit_button")
                                .font(AppFont.hand(22, relativeTo: .title3))
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(canSubmit ? AppColor.accent : AppColor.accent.opacity(0.4))
                                .clipShape(Capsule())
                        }
                        .padding(.horizontal)
                        .frame(width: 240, height: 54)
                        .disabled(!canSubmit)
                    }
                    .padding(.top, 60)
                    .navigationBarBackButtonHidden(true)
                }
                .onTapGesture {
                    UIApplication.shared.endEditing()
                }
                .background(AppColor.background.ignoresSafeArea())
                // 저장 실패를 사용자에게 명확히 전달
                .alert("error_title", isPresented: .init(
                    get: { saveErrorMessage != nil },
                    set: { if !$0 { saveErrorMessage = nil } }
                )) {
                    Button("error_confirm", role: .cancel) {}
                } message: {
                    Text(saveErrorMessage ?? "")
                }
            }
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(.gray)
                    .padding(10)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(Circle())
            }
            .accessibilityLabel("닫기")
            .padding()
        }
    }

    private func submit() {
        guard let emotion = selectedEmotion else { return }
        let trimmedText = reflectionText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }

        switch storage.update(reflection: reflection, content: trimmedText, emotion: emotion.rawValue) {
        case .success:
            dismiss()
        case .failure(let error):
            saveErrorMessage = error.userFriendlyMessage
        }
    }
}
