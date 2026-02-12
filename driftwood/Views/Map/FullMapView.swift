//
//  FullMapView.swift
//  driftwood

import SwiftUI

struct FullMapView: View {
    let world: World
    let playerPosition: CGPoint
    let teleportPads: [TeleportPad]
    let currentPadId: UUID?
    let isTeleportMode: Bool
    let onSelectWaypoint: (TeleportPad) -> Void
    let onClose: () -> Void

    private let tileSize: CGFloat = 24
    private let mapSize: CGFloat = 300
    private let viewRadius = 60

    var body: some View {
        ZStack {
            // dark background
            Color.black.opacity(0.85)
                .ignoresSafeArea()
                .onTapGesture { onClose() }

            VStack(spacing: 16) {
                // header
                HStack {
                    Text(isTeleportMode ? "Select Destination" : "World Map")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.horizontal, 20)

                // map
                ZStack {
                    mapCanvas
                        .frame(width: mapSize, height: mapSize)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                        )

                    // waypoint markers
                    ForEach(teleportPads) { pad in
                        let markerPos = waypointPosition(for: pad)
                        WaypointMarkerView(
                            pad: pad,
                            isCurrentLocation: pad.id == currentPadId,
                            isSelectable: isTeleportMode,
                            onTap: { onSelectWaypoint(pad) }
                        )
                        .position(x: markerPos.x, y: markerPos.y)
                    }

                    // player indicator (if not on teleport pad)
                    if currentPadId == nil {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 10, height: 10)
                            .position(x: mapSize / 2, y: mapSize / 2)
                    }
                }
                .frame(width: mapSize, height: mapSize)

                if isTeleportMode {
                    Text("Tap a waypoint to teleport")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
    }

    private var mapCanvas: some View {
        let playerTileX = Int(playerPosition.x / tileSize)
        let playerTileY = Int(playerPosition.y / tileSize)
        let startX = playerTileX - viewRadius
        let startY = playerTileY - viewRadius
        let viewSize = viewRadius * 2
        let scale = mapSize / CGFloat(viewSize)

        return Canvas { context, canvasSize in
            for localY in 0..<viewSize {
                for localX in 0..<viewSize {
                    let worldX = startX + localX
                    let worldY = startY + localY
                    let color = world.tile(at: worldX, y: worldY).color
                    let rect = CGRect(
                        x: CGFloat(localX) * scale,
                        y: CGFloat(localY) * scale,
                        width: scale + 0.5, // slight overlap to avoid gaps
                        height: scale + 0.5
                    )
                    context.fill(Path(rect), with: .color(color))
                }
            }
        }
    }

    private func waypointPosition(for pad: TeleportPad) -> CGPoint {
        let playerTileX = Int(playerPosition.x / tileSize)
        let playerTileY = Int(playerPosition.y / tileSize)

        let offsetX = pad.tileX - playerTileX
        let offsetY = pad.tileY - playerTileY

        let scale = mapSize / CGFloat(viewRadius * 2)
        let x = mapSize / 2 + CGFloat(offsetX) * scale
        let y = mapSize / 2 + CGFloat(offsetY) * scale

        return CGPoint(x: x, y: y)
    }
}
