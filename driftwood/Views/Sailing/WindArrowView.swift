//
//  WindArrowView.swift
//  driftwood
//

import SwiftUI

struct WindArrowView: View {
    let windAngle: CGFloat

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(Color.black.opacity(0.5))
                    .frame(width: 44, height: 44)

                Image(systemName: "arrow.up")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .rotationEffect(.radians(windAngle + .pi / 2))
            }

            Text("Wind")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.white)
        }
    }
}
