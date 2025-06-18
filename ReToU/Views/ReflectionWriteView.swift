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

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    Text("write_title")
                        .font(.custom("BMYEONSUNG-OTF", size: 48))
                        .foregroundColor(.black)

                    Text(DateFormatter.localizedDate.string(from: Date()))
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
                        Text("write_example_1 \n       write_example_answer_1")
                            .font(.custom("BMYEONSUNG-OTF", size: 18))
                            .foregroundColor(.gray.opacity(0.7))

                        Text("write_example_2 \n       write_example_answer_2")
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

                    // 작성 완료 버튼
                    Button(action: {
                        guard let emotion = selectedEmotion else { return }
                        let trimmedText = reflectionText.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmedText.isEmpty else { return }

                        storage.add(content: trimmedText, emotion: emotion.rawValue, date: Date())
                        navigateToList = true
                    }) {
                        Text("write_button")
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
                        Text("")
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
}
