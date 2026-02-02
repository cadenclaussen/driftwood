//
//  GameView.swift
//  driftwood
//

import SwiftUI

struct GameView: View {
    @StateObject private var viewModel: GameViewModel

    private let tileSize: CGFloat = 24

    init(profile: SaveProfile) {
        _viewModel = StateObject(wrappedValue: GameViewModel(profile: profile))
    }

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
                hudLayer
                controlsLayer
                Color.black
                    .opacity(viewModel.screenFadeOpacity)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
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

    private var hudLayer: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HeartsView(
                        health: viewModel.player.health,
                        maxHealth: viewModel.player.maxHealth
                    )
                    StaminaBarView(
                        stamina: viewModel.player.stamina,
                        maxStamina: viewModel.player.maxStamina
                    )
                    MagicBarView(
                        magic: viewModel.player.magic,
                        maxMagic: viewModel.player.maxMagic
                    )
                }
                .padding(16)
                Spacer()
            }
            Spacer()
        }
    }

    private var controlsLayer: some View {
        VStack {
            Spacer()
            HStack {
                JoystickView(offset: $viewModel.joystickOffset)
                    .padding(.leading, 20)
                    .padding(.bottom, 50)
                Spacer()
                SprintButtonView(
                    isSprinting: $viewModel.player.isSprinting
                )
                .padding(.trailing, 60)
                .padding(.bottom, 20)
            }
        }
    }
}

struct HeartsView: View {
    let health: Int
    let maxHealth: Int

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<maxHealth, id: \.self) { index in
                Image(systemName: index < health ? "heart.fill" : "heart")
                    .font(.system(size: 16))
                    .foregroundColor(index < health ? .red : .gray.opacity(0.5))
            }
        }
    }
}

struct StaminaBarView: View {
    let stamina: CGFloat
    let maxStamina: CGFloat

    private let barWidth: CGFloat = 100
    private let barHeight: CGFloat = 12

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.5))
                .frame(width: barWidth, height: barHeight)
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.green)
                .frame(width: barWidth * (stamina / maxStamina), height: barHeight)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.black.opacity(0.3), lineWidth: 1)
        )
    }
}

struct SprintButtonView: View {
    @Binding var isSprinting: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(isSprinting ? Color.orange : Color.gray.opacity(0.7))
                .frame(width: 60, height: 60)
            Image(systemName: "figure.run")
                .font(.system(size: 24))
                .foregroundColor(.white)
        }
        .overlay(
            Circle()
                .stroke(isSprinting ? Color.orange.opacity(0.8) : Color.black.opacity(0.3), lineWidth: 2)
        )
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isSprinting = true }
                .onEnded { _ in isSprinting = false }
        )
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
