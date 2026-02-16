//
//  WindArrowView.swift
//  driftwood
//

import SwiftUI

struct WindArrowView: View {
    let windAngle: CGFloat

    var body: some View {
        VStack(spacing: Theme.Spacing.xxs) {
            ZStack {
                Circle()
                    .fill(Theme.Color.overlayHalf)
                    .frame(width: Theme.Size.windArrow, height: Theme.Size.windArrow)

                Image(systemName: "arrow.up")
                    .font(.system(size: Theme.Size.iconSmall, weight: .bold))
                    .foregroundColor(Theme.Color.textPrimary)
                    .rotationEffect(.radians(windAngle + .pi / 2))
            }

            Text("Wind")
                .font(Theme.Font.microMedium)
                .foregroundColor(Theme.Color.textPrimary)
        }
    }
}
