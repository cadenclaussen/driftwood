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
    private let viewRadius = 25 // show 50x50 tile region centered on player

    var body: some View {
        let playerTileX = Int(playerPosition.x / tileSize)
        let playerTileY = Int(playerPosition.y / tileSize)

        let startX = playerTileX - viewRadius
        let startY = playerTileY - viewRadius
        let viewSize = viewRadius * 2

        let scale = size / CGFloat(viewSize)

        ZStack {
            VStack(spacing: 0) {
                ForEach(0..<viewSize, id: \.self) { localY in
                    HStack(spacing: 0) {
                        ForEach(0..<viewSize, id: \.self) { localX in
                            let worldX = startX + localX
                            let worldY = startY + localY
                            Rectangle()
                                .fill(world.tile(at: worldX, y: worldY).color)
                                .frame(width: scale, height: scale)
                        }
                    }
                }
            }

            // player dot (always centered)
            Circle()
                .fill(Theme.Color.health)
                .frame(width: Theme.Size.mapMiniDot, height: Theme.Size.mapMiniDot)
                .position(x: size / 2, y: size / 2)
        }
        .frame(width: size, height: size)
        .cornerRadius(Theme.Radius.small)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.small)
                .stroke(Theme.Color.borderDark, lineWidth: Theme.Border.thin)
        )
    }
}
