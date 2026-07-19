import SwiftUI

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct ReflectionWriteView: View {
    @EnvironmentObject var storage: ReflectionStorage
    @State private var selectedEmotion: EmotionType?
    @State private var reflectionText: String = ""
    @Environment(\.dismiss) var dismiss
    @State private var navigateToList = false
    @State private var saveErrorMessage: String?

    /// 감정 선택 + 내용 입력이 모두 완료되어야 저장 가능
    private var canSubmit: Bool {
        selectedEmotion != nil
            && !reflectionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    Text("write_title")
                        .font(AppFont.hand(48, relativeTo: .largeTitle))
                        .foregroundColor(AppColor.textPrimary)

                    Text(DateFormatter.localizedDate.string(from: Date()))
                        .font(AppFont.hand(26, relativeTo: .title2))
                        .foregroundColor(AppColor.textPrimary)

                    // 감정 선택
                    EmotionPicker(selection: $selectedEmotion)

                    // 회고 입력
                    VStack(alignment: .leading, spacing: 14) {
                        Text("write_example_1 \n       write_example_answer_1")
                            .font(AppFont.hand(18, relativeTo: .body))
                            .foregroundColor(AppColor.textSecondary.opacity(0.7))

                        Text("write_example_2 \n       write_example_answer_2")
                            .font(AppFont.hand(18, relativeTo: .body))
                            .foregroundColor(AppColor.textSecondary.opacity(0.7))

                        TextEditor(text: $reflectionText)
                            .frame(height: 200)
                            .padding(8)
                            .scrollContentBackground(.hidden)
                            .background(AppColor.background)
                            .foregroundColor(AppColor.textPrimary)
                    }
                    .padding()
                    .background(AppColor.background)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.field))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.field)
                            .stroke(Color.gray.opacity(1))
                    )
                    .padding(.horizontal)

                    // 작성 완료 버튼 — 입력이 완료될 때까지 비활성화
                    Button(action: submit) {
                        Text("write_button")
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
                .padding(.top)
            }
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
            .background(AppColor.background.ignoresSafeArea())
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $navigateToList) {
                ReflectionListView()
            }
            // 저장 실패는 스쳐 지나가는 텍스트가 아닌 alert로 명확히 전달
            .alert("error_title", isPresented: .init(
                get: { saveErrorMessage != nil },
                set: { if !$0 { saveErrorMessage = nil } }
            )) {
                Button("error_confirm", role: .cancel) {}
            } message: {
                Text(saveErrorMessage ?? "")
            }
        }
    }

    private func submit() {
        guard let emotion = selectedEmotion else { return }
        let trimmedText = reflectionText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }

        switch storage.add(content: trimmedText, emotion: emotion.rawValue, date: Date()) {
        case .success:
            navigateToList = true
        case .failure(let error):
            saveErrorMessage = error.userFriendlyMessage
        }
    }
}
