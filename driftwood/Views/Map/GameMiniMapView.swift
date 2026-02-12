//
//  GameMiniMapView.swift
//  driftwood

import SwiftUI

struct GameMiniMapView: View {
    let world: World
    let playerPosition: CGPoint
    let onTap: () -> Void
    let size: CGFloat = 80

    private let tileSize: CGFloat = 24
    private let viewRadius = 25

    var body: some View {
        let playerTileX = Int(playerPosition.x / tileSize)
        let playerTileY = Int(playerPosition.y / tileSize)
        let startX = playerTileX - viewRadius
        let startY = playerTileY - viewRadius
        let viewSize = viewRadius * 2
        let scale = size / CGFloat(viewSize)

        Canvas { context, canvasSize in
            for localY in 0..<viewSize {
                for localX in 0..<viewSize {
                    let worldX = startX + localX
                    let worldY = startY + localY
                    let color = world.tile(at: worldX, y: worldY).color
                    let rect = CGRect(
                        x: CGFloat(localX) * scale,
                        y: CGFloat(localY) * scale,
                        width: scale + 0.5,
                        height: scale + 0.5
                    )
                    context.fill(Path(rect), with: .color(color))
                }
            }
            // player dot
            let dotSize: CGFloat = 6
            let dotRect = CGRect(
                x: size / 2 - dotSize / 2,
                y: size / 2 - dotSize / 2,
                width: dotSize,
                height: dotSize
            )
            context.fill(Path(ellipseIn: dotRect), with: .color(.red))
        }
        .frame(width: size, height: size)
        .cornerRadius(4)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.black.opacity(0.5), lineWidth: 1)
        )
        .onTapGesture {
            onTap()
        }
    }
}
