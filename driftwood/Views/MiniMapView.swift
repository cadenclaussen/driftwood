//
//  MiniMapView.swift
//  driftwood
//

import SwiftUI

struct MiniMapView: View {
    let playerPosition: CGPoint
    let size: CGFloat

    private let world = World()
    private let tileSize: CGFloat = 24

    var body: some View {
        let scale = size / CGFloat(world.width)

        ZStack {
            VStack(spacing: 0) {
                ForEach(0..<world.height, id: \.self) { y in
                    HStack(spacing: 0) {
                        ForEach(0..<world.width, id: \.self) { x in
                            Rectangle()
                                .fill(world.tile(at: x, y: y).color)
                                .frame(width: scale, height: scale)
                        }
                    }
                }
            }

            // player dot
            Circle()
                .fill(Color.red)
                .frame(width: 6, height: 6)
                .position(
                    x: (playerPosition.x / tileSize) * scale,
                    y: (playerPosition.y / tileSize) * scale
                )
        }
        .frame(width: size, height: size)
        .cornerRadius(4)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.black.opacity(0.3), lineWidth: 1)
        )
    }
}
