import SwiftUI

struct ReflectionDetailView: View {
    let reflection: Reflection
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var storage: ReflectionStorage
    @State private var showDeleteAlert = false
    @State private var isEditing = false
    @State private var deleteErrorMessage: String?

    var body: some View {
        NavigationStack {
            ZStack(alignment: .topTrailing) {
                AppColor.background.ignoresSafeArea()

                VStack(spacing: 28) {
                    Text("detail_title")
                        .font(AppFont.hand(48, relativeTo: .largeTitle))
                        .foregroundColor(AppColor.textPrimary.opacity(0.7))
                        .padding(.top, 10)

                    Text("detail_subtitle")
                        .font(AppFont.hand(28, relativeTo: .title2))
                        .foregroundColor(AppColor.textPrimary)

                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: AppRadius.card)
                            .fill(AppColor.surface)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppRadius.card)
                                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                            )
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(alignment: .top) {
                                Text(reflection.date.formattedDate())
                                    .font(AppFont.hand(28, relativeTo: .title2))
                                    .foregroundColor(AppColor.textPrimary)
                                Spacer()
                                Text(reflection.emotion)
                                    .font(AppFont.hand(44, relativeTo: .largeTitle))
                                    .accessibilityLabel(EmotionType(rawValue: reflection.emotion)?.accessibilityName ?? reflection.emotion)
                            }

                            Text(reflection.content)
                                .font(AppFont.hand(22, relativeTo: .title3))
                                .foregroundColor(AppColor.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.vertical, 20)
                        .padding(.horizontal, 28)
                    }
                    .frame(height: 320)

                    HStack(spacing: 20) {
                        Button("detail_button_edit") {
                            isEditing = true
                        }
                        .font(AppFont.hand(22, relativeTo: .title3))
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 10)
                        .frame(width: 140)
                        .background(AppColor.accent)
                        .clipShape(Capsule())

                        Button("detail_button_delete") {
                            showDeleteAlert = true
                        }
                        .font(AppFont.hand(22, relativeTo: .title3))
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .frame(width: 140)
                        .background(AppColor.coral)
                        .clipShape(Capsule())
                        .alert("delete_alert_title \n delete_alert_subtitle", isPresented: $showDeleteAlert) {
                            Button("delete_alert_confirm", role: .destructive) {
                                deleteReflection()
                            }
                            Button("delete_alert_cancel", role: .cancel) {}
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 16)
                }
                .padding(.top, 60)
                .padding()

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
            .navigationDestination(isPresented: $isEditing) {
                ReflectionEditView(reflection: reflection)
            }
            // 삭제 실패를 사용자에게 명확히 전달
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

    private func deleteReflection() {
        switch storage.delete(reflection: reflection) {
        case .success:
            dismiss()
        case .failure(let error):
            deleteErrorMessage = error.userFriendlyMessage
        }
    }
}
