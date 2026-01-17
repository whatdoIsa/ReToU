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
    @State private var errorMessage: String = ""
    @State private var showError: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    Text("오늘의 넌 어때?")
                        .font(.custom("BMYEONSUNG-OTF", size: 48))
                        .foregroundColor(.black)

                    Text(DateFormatter.koreanDate.string(from: Date()))
                        .font(.custom("BMYEONSUNG-OTF", size: 26))
                        .foregroundColor(.black)

                    // 감정 선택
                    HStack(spacing: 10) {
                        ForEach(EmotionType.allCases) { emotion in
                            Text(emotion.rawValue)
                                .font(.title3)
                                .padding(12)
                                .background(
                                    selectedEmotion == emotion ? Color(hex: "#FF8977") : Color.white
                                )
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.gray.opacity(0.3))
                                )
                                .onTapGesture {
                                    selectedEmotion = emotion
                                }
                        }
                    }

                    // 회고 입력
                    VStack(alignment: .leading, spacing: 14) {
                        Text("예시) 오늘 하루는 어땠나요? \n       코드에 오류가 너무 많아서 찾는데 오래 걸렸어요")
                            .font(.custom("BMYEONSUNG-OTF", size: 18))
                            .foregroundColor(.gray.opacity(0.7))
                        Text("예시) 오늘 힘들었거나 행복했던 일이 있었나요? \n       여행을 가서 너무 설레요!!")
                            .font(.custom("BMYEONSUNG-OTF", size: 18))
                            .foregroundColor(.gray.opacity(0.7))

                        ScrollView {
                            TextEditor(text: $reflectionText)
                                .frame(height: 200)
                                .padding(8)
                                .background(Color(hex: "#FFF9EC"))
                                .foregroundColor(.black)
                                .colorScheme(.light) // 강제 라이트모드 적용
                        }
                        .frame(height: 200)
                    }
                    .padding()
                    .background(Color(hex: "#FFF9EC"))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(1))
                    )
                    .padding(.horizontal)

                    // 에러 메시지 표시
                    if showError {
                        Text(errorMessage)
                            .font(.custom("BMYEONSUNG-OTF", size: 16))
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }
                    
                    // 작성 완료 버튼
                    Button(action: {
                        guard let emotion = selectedEmotion else {
                            showErrorMessage("감정을 선택해주세요 😊")
                            return
                        }
                        let trimmedText = reflectionText.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmedText.isEmpty else {
                            showErrorMessage("회고 내용을 입력해주세요 ✍️")
                            return
                        }

                        let result = storage.add(content: trimmedText, emotion: emotion.rawValue, date: Date())
                        switch result {
                        case .success(_):
                            navigateToList = true
                        case .failure(let error):
                            showErrorMessage(error.userFriendlyMessage)
                        }
                    }) {
                        Text("오늘을 기억하기")
                            .font(.custom("BMYEONSUNG-OTF", size: 22))
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(hex: "#4ECFD8"))
                            .cornerRadius(25)
                    }
                    .padding(.horizontal)
                    .frame(width: 240, height: 54)
                    .disabled(selectedEmotion == nil)
                    
                    NavigationLink(destination: ReflectionListView(), isActive: $navigateToList) {
                        EmptyView()
                    }
                    .hidden()
                }
                .padding(.top)
            }
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
            .background(Color(hex: "#FFF9EC").ignoresSafeArea())
            .navigationBarBackButtonHidden(true)
        }
    }
    
    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
        
        // 3초 후 에러 메시지 자동 숨김
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            showError = false
        }
    }
}
