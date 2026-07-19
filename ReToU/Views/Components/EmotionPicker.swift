//
//  EmotionPicker.swift
//  ReToU
//
//  작성/수정 화면에서 공용으로 사용하는 감정 선택 컴포넌트
//

import SwiftUI

struct EmotionPicker: View {
    @Binding var selection: EmotionType?

    var body: some View {
        HStack(spacing: 10) {
            ForEach(EmotionType.allCases) { emotion in
                Button {
                    selection = emotion
                } label: {
                    Text(emotion.rawValue)
                        .font(.title3)
                        .padding(12)
                        .background(selection == emotion ? AppColor.coral : AppColor.surface)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.gray.opacity(0.3))
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(emotion.accessibilityName)
                .accessibilityAddTraits(selection == emotion ? [.isSelected] : [])
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("감정 선택")
    }
}
