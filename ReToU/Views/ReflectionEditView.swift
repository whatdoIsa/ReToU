//
//  ReflectionEditView.swift
//  ReToU
//
//  Created by Dean_SSONG on 4/20/25.
//

import SwiftUI



struct ReflectionEditView: View {
    @Binding var reflection: Reflection
    @EnvironmentObject var storage: ReflectionStorage
    @State private var selectedEmotion: EmotionType
    @State private var reflectionText: String
    @Environment(\.dismiss) var dismiss

    init(reflection: Binding<Reflection>) {
        self._reflection = reflection
        _selectedEmotion = State(initialValue: EmotionType(rawValue: reflection.wrappedValue.emotion) ?? .happy)
        _reflectionText = State(initialValue: reflection.wrappedValue.content)
    }

    var body: some View {
        //네비게이션 스택 내에 스크롤이 가능한 뷰를 구성
        ZStack(alignment: .topTrailing){
            NavigationStack {
                ScrollView {
                    VStack(spacing: 28) {
                        Text("그때의 너")
                            .font(.custom("BMYEONSUNG-OTF", size: 40))
                            .foregroundColor(.black.opacity(0.7))
                        
                        
                        Text(reflection.date.formattedDate())
                            .font(.custom("BMYEONSUNG-OTF", size: 26))
                            .foregroundColor(.black)
                        
                        emotionPicker
                        
                        TextEditor(text: $reflectionText)
                            .frame(height: 200)
                            .padding()
                            .background(Color(hex: "#FFF9EC"))
                            .foregroundColor(.black)
                            .cornerRadius(12)
                            .padding(.horizontal)
                            .colorScheme(.light) // 강제 라이트모드 적용
                        
                        Button(action: {
                            let trimmedText = reflectionText.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !trimmedText.isEmpty else { return }
                            
                            storage.update(reflection: reflection, content: trimmedText, emotion: selectedEmotion.rawValue)
                            dismiss()
                        }) {
                            submitButton
                        }
                        .padding(.horizontal)
                        .frame(width: 240, height: 54)
                        .disabled(selectedEmotion == nil)
                    }
                    .padding(.top, 60)
                    .navigationBarBackButtonHidden(true)
                }
                .onTapGesture {
                    UIApplication.shared.endEditing()
                }
                .background(Color(hex: "#FFF9EC").ignoresSafeArea())
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
            .padding()
        }
    }
    
    var submitButton: some View {
        Text("이대로 기억하기")
            .font(.custom("BMYEONSUNG-OTF", size: 22))
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(hex: "#4ECFD8"))
            .cornerRadius(25)
    }

    var emotionPicker: some View {
        HStack(spacing: 10) {
            ForEach(EmotionType.allCases) { emotion in
                emotionButton(for: emotion)
            }
        }
    }

    @ViewBuilder
    func emotionButton(for emotion: EmotionType) -> some View {
        let isSelected = selectedEmotion == emotion
        Text(emotion.rawValue)
            .font(.title3)
            .padding(12)
            .background(isSelected ? Color(hex: "#FF8977") : Color.white)
            .clipShape(Circle())
            .overlay(
                Circle().stroke(Color.gray.opacity(0.3))
            )
            .onTapGesture {
                selectedEmotion = emotion
            }
    }
}
