//
//  GameView.swift
//  driftwood
//

import SwiftUI

struct GameView: View {
    @StateObject private var viewModel = GameViewModel()

    private let tileSize: CGFloat = 24

    var body: some View {
        GeometryReader { geometry in
            let screenTilesX = Int(ceil(geometry.size.width / tileSize)) + 1
            let screenTilesY = Int(ceil(geometry.size.height / tileSize)) + 1
            let worldOffsetX = (screenTilesX - viewModel.world.width) / 2
            let worldOffsetY = (screenTilesY - viewModel.world.height) / 2
            let pixelOffsetX = CGFloat(worldOffsetX) * tileSize
            let pixelOffsetY = CGFloat(worldOffsetY) * tileSize

            ZStack(alignment: .topLeading) {
                unifiedGrid(
                    screenTilesX: screenTilesX,
                    screenTilesY: screenTilesY,
                    worldOffsetX: worldOffsetX,
                    worldOffsetY: worldOffsetY
                )
                PlayerView(
                    size: viewModel.player.size,
                    lookDirection: viewModel.player.lookDirection
                )
                .position(
                    x: pixelOffsetX + viewModel.player.position.x,
                    y: pixelOffsetY + viewModel.player.position.y
                )
                joystickLayer
            }
        }
        .onAppear { viewModel.startGameLoop() }
        .onDisappear { viewModel.stopGameLoop() }
    }

    private func unifiedGrid(
        screenTilesX: Int,
        screenTilesY: Int,
        worldOffsetX: Int,
        worldOffsetY: Int
    ) -> some View {
        VStack(spacing: 0) {
            ForEach(0..<screenTilesY, id: \.self) { screenY in
                HStack(spacing: 0) {
                    ForEach(0..<screenTilesX, id: \.self) { screenX in
                        let worldX = screenX - worldOffsetX
                        let worldY = screenY - worldOffsetY
                        let tileType = viewModel.world.tile(at: worldX, y: worldY)
                        TileView(type: tileType, size: tileSize)
                    }
                }
            }
        }
    }

    private var joystickLayer: some View {
        VStack {
            Spacer()
            HStack {
                JoystickView(offset: $viewModel.joystickOffset)
                    .padding(30)
                Spacer()
            }
        }
    }
}

struct TileView: View {
    let type: TileType
    let size: CGFloat

    var body: some View {
        Rectangle()
            .fill(type.color)
            .frame(width: size, height: size)
            .border(Color.black.opacity(0.1), width: 0.5)
    }
}

#Preview {
    GameView()
}
