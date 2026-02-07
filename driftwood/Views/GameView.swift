//
//  GameView.swift
//  driftwood
//

import SwiftUI

struct GameView: View {
    @StateObject private var viewModel: GameViewModel

    private let tileSize: CGFloat = 24
    private let onReturnToMainMenu: () -> Void

    init(profile: SaveProfile, onReturnToMainMenu: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: GameViewModel(profile: profile))
        self.onReturnToMainMenu = onReturnToMainMenu
    }

    var body: some View {
        GeometryReader { geometry in
            // camera is centered on player
            let cameraX = viewModel.player.position.x
            let cameraY = viewModel.player.position.y
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height

            // iPhone 16e landscape safe area insets (hardcoded since parent ignores safe area)
            // tuned for rounded corners + notch + home indicator
            let safeLeft: CGFloat = 15
            let safeRight: CGFloat = 59
            let safeTop: CGFloat = 0
            let safeBottom: CGFloat = 60

            // calculate visible tile range (add 1 tile buffer on each side)
            let screenTilesX = Int(ceil(screenWidth / tileSize)) + 2
            let screenTilesY = Int(ceil(screenHeight / tileSize)) + 2

            ZStack(alignment: .topLeading) {
                cameraGrid(
                    screenTilesX: screenTilesX,
                    screenTilesY: screenTilesY,
                    cameraX: cameraX,
                    cameraY: cameraY,
                    screenWidth: screenWidth,
                    screenHeight: screenHeight
                )
                // ground sprites (always behind player, like tiles)
                groundSpritesLayer(
                    cameraX: cameraX,
                    cameraY: cameraY,
                    screenWidth: screenWidth,
                    screenHeight: screenHeight
                )
                // rock overlays (ground level, behind player)
                rockOverlaysLayer(
                    cameraX: cameraX,
                    cameraY: cameraY,
                    screenWidth: screenWidth,
                    screenHeight: screenHeight
                )
                // overlays not overlapping player (behind)
                overlaysLayer(
                    overlapping: false,
                    cameraX: cameraX,
                    cameraY: cameraY,
                    screenWidth: screenWidth,
                    screenHeight: screenHeight
                )
                // player is always at screen center
                PlayerView(
                    size: viewModel.player.size,
                    facingDirection: viewModel.player.facingDirection,
                    isWalking: viewModel.player.isWalking,
                    isAttacking: viewModel.player.isAttacking,
                    attackFrame: viewModel.player.attackAnimationFrame
                )
                .position(
                    x: screenWidth / 2,
                    y: screenHeight / 2
                )
                // overlays overlapping player (on top)
                overlaysLayer(
                    overlapping: true,
                    cameraX: cameraX,
                    cameraY: cameraY,
                    screenWidth: screenWidth,
                    screenHeight: screenHeight
                )
                hudLayer(safeLeft: safeLeft, safeTop: safeTop)
                controlsLayer(safeLeft: safeLeft, safeRight: safeRight, safeBottom: safeBottom)
                Color.black
                    .opacity(viewModel.screenFadeOpacity)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)

                if viewModel.isInventoryOpen {
                    InventoryView(
                        viewModel: viewModel.inventoryViewModel,
                        onClose: { viewModel.closeInventory() },
                        onUseMeal: { index in viewModel.useMeal(at: index) }
                    )
                }

                if viewModel.isDead {
                    DeathScreenView(
                        onMainMenu: { viewModel.returnToMainMenu() },
                        onRespawn: { viewModel.respawn() }
                    )
                }

                // tool quick menu overlay
                if viewModel.isToolMenuOpen {
                    ToolQuickMenuView(
                        tools: viewModel.ownedTools(),
                        currentTool: viewModel.player.equippedTool,
                        onSelect: { tool in viewModel.equipTool(tool) },
                        onDismiss: { viewModel.closeToolMenu() }
                    )
                }

                // fishing minigame overlay
                if viewModel.isFishing, let fishingVM = viewModel.fishingViewModel, !viewModel.showingFishingResults {
                    FishingMinigameView(
                        viewModel: fishingVM,
                        onComplete: { viewModel.endFishing() }
                    )
                }

                // fishing results overlay
                if viewModel.showingFishingResults, let fishingVM = viewModel.fishingViewModel {
                    FishingResultsView(
                        catches: fishingVM.sessionCatches,
                        leveledUp: fishingVM.fishingState.fishingLevel > viewModel.fishingState.fishingLevel,
                        newLevel: fishingVM.fishingState.fishingLevel,
                        onDismiss: { viewModel.dismissFishingResults() }
                    )
                }

                // level up notification
                VStack {
                    Spacer()
                        .frame(height: 80)
                    LevelUpNotificationView(
                        level: viewModel.levelUpNotificationLevel,
                        isVisible: viewModel.showLevelUpNotification
                    )
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .allowsHitTesting(false)
            }
        }
        .onAppear {
            viewModel.onReturnToMainMenu = onReturnToMainMenu
            viewModel.startGameLoop()
        }
        .onDisappear { viewModel.stopGameLoop() }
    }

    private func cameraGrid(
        screenTilesX: Int,
        screenTilesY: Int,
        cameraX: CGFloat,
        cameraY: CGFloat,
        screenWidth: CGFloat,
        screenHeight: CGFloat
    ) -> some View {
        // calculate the top-left world tile visible on screen
        let cameraTileX = Int(floor(cameraX / tileSize))
        let cameraTileY = Int(floor(cameraY / tileSize))
        let startTileX = cameraTileX - screenTilesX / 2
        let startTileY = cameraTileY - screenTilesY / 2

        let _ = print("DEBUG cameraGrid: camera=(\(Int(cameraX)), \(Int(cameraY))), cameraTile=(\(cameraTileX), \(cameraTileY))")

        // calculate pixel offset for smooth scrolling
        let tileOffsetX = cameraX.truncatingRemainder(dividingBy: tileSize)
        let tileOffsetY = cameraY.truncatingRemainder(dividingBy: tileSize)
        let gridOffsetX = screenWidth / 2 - tileOffsetX - CGFloat(screenTilesX / 2) * tileSize
        let gridOffsetY = screenHeight / 2 - tileOffsetY - CGFloat(screenTilesY / 2) * tileSize

        return VStack(spacing: 0) {
            ForEach(0..<screenTilesY, id: \.self) { screenY in
                HStack(spacing: 0) {
                    ForEach(0..<screenTilesX, id: \.self) { screenX in
                        let worldX = startTileX + screenX
                        let worldY = startTileY + screenY
                        let tileType = viewModel.world.tile(at: worldX, y: worldY)
                        TileView(type: tileType, size: tileSize)
                    }
                }
            }
        }
        .offset(x: gridOffsetX, y: gridOffsetY)
    }

    private func groundSpritesLayer(
        cameraX: CGFloat,
        cameraY: CGFloat,
        screenWidth: CGFloat,
        screenHeight: CGFloat
    ) -> some View {
        return ZStack {
            ForEach(viewModel.world.groundSprites) { sprite in
                let spriteSize = tileSize * CGFloat(sprite.size)
                let spritePixelX = CGFloat(sprite.x) * tileSize + spriteSize / 2
                let spritePixelY = CGFloat(sprite.y) * tileSize + spriteSize / 2
                let screenX = screenWidth / 2 + (spritePixelX - cameraX)
                let screenY = screenHeight / 2 + (spritePixelY - cameraY)

                Image(sprite.spriteName)
                    .interpolation(.none)
                    .resizable()
                    .frame(width: spriteSize, height: spriteSize)
                    .position(x: screenX, y: screenY)
            }
        }
    }

    private func rockOverlaysLayer(
        cameraX: CGFloat,
        cameraY: CGFloat,
        screenWidth: CGFloat,
        screenHeight: CGFloat
    ) -> some View {
        let rockSize = tileSize * 2  // rocks are 2x2 tiles
        return ZStack {
            ForEach(viewModel.world.rockOverlays) { rock in
                // rock is 2x2 tiles, anchored at top-left tile position
                let rockPixelX = CGFloat(rock.x) * tileSize + rockSize / 2
                let rockPixelY = CGFloat(rock.y) * tileSize + rockSize / 2
                let screenX = screenWidth / 2 + (rockPixelX - cameraX)
                let screenY = screenHeight / 2 + (rockPixelY - cameraY)

                Image(rock.type.spriteName)
                    .interpolation(.none)
                    .resizable()
                    .frame(width: rockSize, height: rockSize)
                    .position(x: screenX, y: screenY)
            }
        }
    }

    private func overlaysLayer(
        overlapping: Bool,
        cameraX: CGFloat,
        cameraY: CGFloat,
        screenWidth: CGFloat,
        screenHeight: CGFloat
    ) -> some View {
        // player bounds in tile coordinates
        let playerLeft = Int(floor((viewModel.player.position.x - viewModel.player.size / 2) / tileSize))
        let playerRight = Int(floor((viewModel.player.position.x + viewModel.player.size / 2) / tileSize))
        let playerTop = Int(floor((viewModel.player.position.y - viewModel.player.size / 2) / tileSize))
        let playerBottom = Int(floor((viewModel.player.position.y + viewModel.player.size / 2) / tileSize))

        // filter overlays based on overlap with player
        let filteredOverlays = viewModel.world.overlays.filter { overlay in
            // overlay covers tiles from (x, y) to (x + size - 1, y + size - 1)
            let overlayLeft = overlay.x
            let overlayRight = overlay.x + overlay.size - 1
            let overlayTop = overlay.y
            let overlayBottom = overlay.y + overlay.size - 1

            // check if player overlaps with overlay
            let hasOverlap = playerRight >= overlayLeft && playerLeft <= overlayRight &&
                             playerBottom >= overlayTop && playerTop <= overlayBottom

            return overlapping ? hasOverlap : !hasOverlap
        }

        // overlay size: 2x2 tiles
        let overlaySize = tileSize * 2

        return ZStack {
            ForEach(filteredOverlays) { overlay in
                // position at center of 2x2 overlay
                let overlayPixelX = CGFloat(overlay.x) * tileSize + overlaySize / 2
                let overlayPixelY = CGFloat(overlay.y) * tileSize + overlaySize / 2
                let screenX = screenWidth / 2 + (overlayPixelX - cameraX)
                let screenY = screenHeight / 2 + (overlayPixelY - cameraY)

                Image(overlay.type.spriteName)
                    .interpolation(.none)
                    .resizable()
                    .frame(width: overlaySize, height: overlaySize)
                    .position(x: screenX, y: screenY)
            }
        }
    }

    private func hudLayer(safeLeft: CGFloat, safeTop: CGFloat) -> some View {
        let buffer: CGFloat = 16
        return VStack {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HeartsView(
                        health: viewModel.player.health,
                        maxHealth: viewModel.effectiveMaxHealth
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
                .padding(.leading, safeLeft + buffer)
                .padding(.top, safeTop + buffer)
                Spacer()
            }
            Spacer()
        }
    }

    private func controlsLayer(safeLeft: CGFloat, safeRight: CGFloat, safeBottom: CGFloat) -> some View {
        let buffer: CGFloat = 16

        return VStack {
            HStack(spacing: 12) {
                Spacer()
                InventoryButton(onTap: { viewModel.openInventory() })
                MenuButton(onTap: { viewModel.returnToMainMenu() })
            }
            .padding(.trailing, safeRight + buffer)
            .padding(.top, buffer)
            Spacer()
            HStack(alignment: .bottom) {
                JoystickView(offset: $viewModel.joystickOffset)
                    .padding(.leading, safeLeft + buffer)
                    .padding(.bottom, safeBottom + buffer)

                Spacer()

                // right side controls
                VStack(spacing: 15) {
                    // tool button (turns cyan when can use equipped tool)
                    ToolButtonView(
                        equippedTool: viewModel.player.equippedTool,
                        canUseTool: viewModel.canUseTool,
                        onTap: { viewModel.useTool() },
                        onLongPress: { viewModel.openToolMenu() }
                    )

                    // sprint button
                    SprintButtonView(isSprinting: $viewModel.player.isSprinting)
                }
                .padding(.trailing, safeRight + buffer)
                .padding(.bottom, safeBottom + buffer)
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
    }
}
