//
//  MagicBarView.swift
//  driftwood
//

import SwiftUI

struct MagicBarView: View {
    let magic: CGFloat
    let maxMagic: CGFloat

    private let barWidth: CGFloat = Theme.Size.barWidth
    private let barHeight: CGFloat = Theme.Size.barHeight

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: Theme.Radius.small)
                .fill(Theme.Color.borderMedium)
                .frame(width: barWidth, height: barHeight)
            RoundedRectangle(cornerRadius: Theme.Radius.small)
                .fill(Theme.Color.magic)
                .frame(width: barWidth * (magic / maxMagic), height: barHeight)
        }
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.small)
                .stroke(Theme.Color.borderDark, lineWidth: Theme.Border.thin)
        )
    }
}
