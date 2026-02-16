//
//  SlimeView.swift
//  driftwood
//

import SwiftUI

struct SlimeView: View {
    let screenX: CGFloat
    let screenY: CGFloat
    let bouncePhase: CGFloat
    let isFlashing: Bool

    private var bounceScale: CGFloat {
        1.0 + 0.15 * sin(bouncePhase)
    }

    var body: some View {
        ZStack {
            // slime body (green blob)
            Ellipse()
                .fill(Color(red: 0.2, green: 0.7, blue: 0.2))
                .frame(width: 20, height: 16)
            // highlight
            Ellipse()
                .fill(Color(red: 0.4, green: 0.85, blue: 0.4))
                .frame(width: 8, height: 6)
                .offset(x: -3, y: -3)
            // eyes
            HStack(spacing: 4) {
                Circle().fill(.white).frame(width: 5, height: 5)
                    .overlay(Circle().fill(.black).frame(width: 2.5, height: 2.5).offset(y: 0.5))
                Circle().fill(.white).frame(width: 5, height: 5)
                    .overlay(Circle().fill(.black).frame(width: 2.5, height: 2.5).offset(y: 0.5))
            }
            .offset(y: -1)
        }
        .frame(width: Slime.size, height: Slime.size)
        .scaleEffect(x: 1.0, y: bounceScale, anchor: .bottom)
        .overlay(
            isFlashing ?
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.white.opacity(0.7))
                    .frame(width: Slime.size, height: Slime.size)
                : nil
        )
        .position(x: screenX, y: screenY)
    }
}
