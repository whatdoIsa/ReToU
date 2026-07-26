//
//  JogakboView.swift
//  ReToU
//
//  조각보 통계 — 염색한 한지 조각을 이어 붙인 보자기.
//  조각의 넓이가 곧 그 감정의 날수.
//

import SwiftUI

struct JogakboView: View {
    /// 많이 새긴 순으로 정렬된 (감정, 날수)
    let entries: [(emotion: EmotionType, count: Int)]

    private let seam: CGFloat = 3

    var body: some View {
        GeometryReader { geo in
            let topRow = Array(entries.prefix(2))
            let bottomRow = Array(entries.dropFirst(2))
            let topHeight: CGFloat = bottomRow.isEmpty ? geo.size.height : geo.size.height * 0.6
            let bottomHeight = geo.size.height - topHeight - (bottomRow.isEmpty ? 0 : seam)

            VStack(spacing: seam) {
                patchRow(topRow, width: geo.size.width, height: topHeight)
                if !bottomRow.isEmpty {
                    patchRow(bottomRow, width: geo.size.width, height: bottomHeight)
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("이 달의 감정 조각보")
    }

    private func patchRow(_ row: [(emotion: EmotionType, count: Int)], width: CGFloat, height: CGFloat) -> some View {
        let total = max(1, row.reduce(0) { $0 + $1.count })
        let seams = CGFloat(max(0, row.count - 1)) * seam
        let available = width - seams

        return HStack(spacing: seam) {
            ForEach(row, id: \.emotion) { entry in
                patch(entry, width: max(58, available * CGFloat(entry.count) / CGFloat(total)), height: height)
            }
        }
        .frame(width: width, alignment: .leading)
    }

    private func patch(_ entry: (emotion: EmotionType, count: Int), width: CGFloat, height: CGFloat) -> some View {
        ZStack(alignment: .bottomLeading) {
            TornRectShape(seed: entry.emotion.rawValue.hashValue)
                .fill(entry.emotion.sealColor.opacity(0.5))

            (Text(entry.emotion.accessibilityName)
                .font(AppFont.serif(13, relativeTo: .subheadline))
             + Text(" \(KoreanLiteraryDate.nativeCount(entry.count)) 날")
                .font(AppFont.serifBody(10, relativeTo: .caption)))
                .foregroundColor(AppColor.ink.opacity(0.8))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .padding(.leading, 10)
                .padding(.bottom, 8)
        }
        .frame(width: width, height: height)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(entry.emotion.accessibilityName) \(entry.count)일")
    }
}
