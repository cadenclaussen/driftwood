//
//  PlayerView.swift
//  driftwood
//

import SwiftUI

struct PlayerView: View {
    let size: CGFloat
    let lookDirection: CGPoint

    private let indicatorSize: CGFloat = 4

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.red)
                .frame(width: size, height: size)
            Circle()
                .fill(Color(red: 0.1, green: 0.2, blue: 0.5))
                .frame(width: indicatorSize, height: indicatorSize)
                .offset(x: lookOffset.x, y: lookOffset.y)
        }
    }

    private var lookOffset: CGPoint {
        let radius = (size - indicatorSize) / 2
        return CGPoint(
            x: lookDirection.x * radius,
            y: lookDirection.y * radius
        )
    }
}
