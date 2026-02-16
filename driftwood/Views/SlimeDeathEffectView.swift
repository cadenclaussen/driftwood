//
//  SlimeDeathEffectView.swift
//  driftwood
//

import SwiftUI

struct SlimeDeathEffectView: View {
    let screenX: CGFloat
    let screenY: CGFloat
    let progress: CGFloat // 0.0 to 1.0

    private let particleAngles: [CGFloat] = [0, 60, 120, 200, 280, 340]

    var body: some View {
        ZStack {
            // pop circle (scales up then fades)
            Circle()
                .fill(Color(red: 0.2, green: 0.7, blue: 0.2))
                .frame(width: 20, height: 20)
                .scaleEffect(1.0 + progress * 0.8)
                .opacity(1.0 - progress)

            // scatter particles
            ForEach(0..<particleAngles.count, id: \.self) { i in
                let angle = particleAngles[i] * .pi / 180
                let dist = progress * 25
                Circle()
                    .fill(Color(red: 0.3, green: 0.8, blue: 0.3))
                    .frame(width: 4, height: 4)
                    .offset(x: cos(angle) * dist, y: sin(angle) * dist)
                    .opacity(1.0 - progress)
            }
        }
        .position(x: screenX, y: screenY)
    }
}
