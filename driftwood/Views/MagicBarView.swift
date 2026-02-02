//
//  MagicBarView.swift
//  driftwood
//

import SwiftUI

struct MagicBarView: View {
    let magic: CGFloat
    let maxMagic: CGFloat

    private let barWidth: CGFloat = 100
    private let barHeight: CGFloat = 12

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.5))
                .frame(width: barWidth, height: barHeight)
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(red: 0.75, green: 0.25, blue: 0.85))
                .frame(width: barWidth * (magic / maxMagic), height: barHeight)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.black.opacity(0.3), lineWidth: 1)
        )
    }
}
