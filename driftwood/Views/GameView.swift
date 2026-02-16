//
//  GameView.swift
//  driftwood
//

import SwiftUI

struct GameView: View {
    @StateObject private var viewModel: GameViewModel
    @State private var showMainMenuConfirmation = false
    @State private var slimeBouncePhase: CGFloat = 0

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
                // teleport pad overlays (flat on grass)
                teleportPadsLayer(
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
                // slimes behind player (bottomY < player bottomY)
                slimesLayer(
                    behind: true,
                    cameraX: cameraX,
                    cameraY: cameraY,
                    screenWidth: screenWidth,
                    screenHeight: screenHeight
                )
                // sailboat in world (when not sailing, show at its position)
                if let boat = viewModel.sailboat, !viewModel.player.isSailing {
                    SailboatView(rotationAngle: boat.rotationAngle)
                        .position(
                            x: screenWidth / 2 + (boat.position.x - cameraX),
                            y: screenHeight / 2 + (boat.position.y - cameraY)
                        )
                }
                // player or sailboat at screen center
                if viewModel.player.isSailing {
                    let angle = atan2(viewModel.player.lookDirection.y, viewModel.player.lookDirection.x)
                    SailboatView(rotationAngle: angle)
                        .position(
                            x: screenWidth / 2,
                            y: screenHeight / 2
                        )
                } else {
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
                    .opacity(playerBlinkOpacity)
                }
                // slimes in front of player (bottomY >= player bottomY)
                slimesLayer(
                    behind: false,
                    cameraX: cameraX,
                    cameraY: cameraY,
                    screenWidth: screenWidth,
                    screenHeight: screenHeight
                )
                // death effects
                deathEffectsLayer(
                    cameraX: cameraX,
                    cameraY: cameraY,
                    screenWidth: screenWidth,
                    screenHeight: screenHeight
                )
                // overlays overlapping player (on top)
                overlaysLayer(
                    overlapping: true,
                    cameraX: cameraX,
                    cameraY: cameraY,
                    screenWidth: screenWidth,
                    screenHeight: screenHeight
                )
                hudLayer(safeLeft: safeLeft, safeRight: safeRight, safeTop: safeTop)
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

                // map overlay
                if viewModel.isMapOpen {
                    FullMapView(
                        world: viewModel.world,
                        playerPosition: viewModel.player.position,
                        teleportPads: viewModel.world.teleportPads,
                        currentPadId: viewModel.currentTeleportPad?.id,
                        isTeleportMode: viewModel.isMapTeleportMode,
                        onSelectWaypoint: { pad in viewModel.teleportTo(pad: pad) },
                        onClose: { viewModel.closeMap() }
                    )
                }

                // level up notification
                VStack {
                    Spacer()
                        .frame(height: Theme.Size.notificationTopOffset)
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
            // bounce animation timer
            Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { _ in
                slimeBouncePhase += 0.12 // ~0.9s full cycle at 60fps
            }
        }
        .onDisappear { viewModel.stopGameLoop() }
        .overlay {
            if showMainMenuConfirmation {
                MainMenuConfirmationView(
                    onCancel: { showMainMenuConfirmation = false },
                    onConfirm: { viewModel.returnToMainMenu() }
                )
            }
        }
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

    private func teleportPadsLayer(
        cameraX: CGFloat,
        cameraY: CGFloat,
        screenWidth: CGFloat,
        screenHeight: CGFloat
    ) -> some View {
        ZStack {
            ForEach(viewModel.world.teleportPads) { pad in
                let padPixelX = CGFloat(pad.tileX) * tileSize + tileSize / 2
                let padPixelY = CGFloat(pad.tileY) * tileSize + tileSize / 2
                let screenX = screenWidth / 2 + (padPixelX - cameraX)
                let screenY = screenHeight / 2 + (padPixelY - cameraY)

                Image("TeleportPad")
                    .interpolation(.none)
                    .resizable()
                    .frame(width: tileSize, height: tileSize)
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

    private var playerBlinkOpacity: Double {
        guard viewModel.player.isInvincible else { return 1.0 }
        return Int(viewModel.player.invincibilityTimer * 10) % 2 == 0 ? 0.3 : 1.0
    }

    private func slimesLayer(
        behind: Bool,
        cameraX: CGFloat,
        cameraY: CGFloat,
        screenWidth: CGFloat,
        screenHeight: CGFloat
    ) -> some View {
        let playerBottomY = viewModel.player.position.y + viewModel.player.size / 2
        let aliveSlimes = viewModel.slimes.filter { slime in
            guard slime.isAlive else { return false }
            let slimeBottomY = slime.position.y + Slime.halfSize
            return behind ? (slimeBottomY < playerBottomY) : (slimeBottomY >= playerBottomY)
        }

        return ZStack {
            ForEach(aliveSlimes) { slime in
                let sx = screenWidth / 2 + (slime.position.x - cameraX)
                let sy = screenHeight / 2 + (slime.position.y - cameraY)
                SlimeView(
                    screenX: sx,
                    screenY: sy,
                    bouncePhase: slimeBouncePhase + CGFloat(slime.id), // offset per slime
                    isFlashing: slime.hitFlashTimer > 0
                )
            }
        }
    }

    private func deathEffectsLayer(
        cameraX: CGFloat,
        cameraY: CGFloat,
        screenWidth: CGFloat,
        screenHeight: CGFloat
    ) -> some View {
        ZStack {
            ForEach(viewModel.deathEffects) { effect in
                let sx = screenWidth / 2 + (effect.position.x - cameraX)
                let sy = screenHeight / 2 + (effect.position.y - cameraY)
                let progress = min(effect.elapsed / SlimeDeathEffect.duration, 1.0)
                SlimeDeathEffectView(screenX: sx, screenY: sy, progress: progress)
            }
        }
    }

    private func hudLayer(safeLeft: CGFloat, safeRight: CGFloat, safeTop: CGFloat) -> some View {
        let buffer: CGFloat = Theme.Spacing.lg
        let showMinimap = !viewModel.isInventoryOpen && !viewModel.isFishing && !viewModel.isDead && !viewModel.isMapOpen
        return VStack {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
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
                    // minimap
                    if showMinimap {
                        GameMiniMapView(
                            world: viewModel.world,
                            playerPosition: viewModel.player.position,
                            onTap: { viewModel.openMap(teleportMode: false) }
                        )
                        .padding(.top, Theme.Spacing.sm)
                    }
                }
                .padding(.leading, safeLeft + buffer)
                .padding(.top, safeTop + buffer)
                Spacer()
                // wind arrow (only when sailing)
                if viewModel.player.isSailing {
                    WindArrowView(windAngle: viewModel.sailingState.windAngle)
                        .padding(.trailing, safeRight + Theme.Size.hudRightBuffer)
                        .padding(.top, safeTop + buffer + Theme.Size.windArrowTopOffset)
                }
            }
            Spacer()
        }
    }

    private func controlsLayer(safeLeft: CGFloat, safeRight: CGFloat, safeBottom: CGFloat) -> some View {
        let buffer: CGFloat = Theme.Spacing.lg
        let rightBuffer: CGFloat = Theme.Size.hudRightBuffer

        return VStack {
            HStack(spacing: Theme.Spacing.md) {
                Spacer()
                InventoryButton(onTap: { viewModel.openInventory() })
                MenuButton(onTap: { showMainMenuConfirmation = true })
            }
            .padding(.trailing, safeRight + rightBuffer)
            .padding(.top, buffer)
            Spacer()
            // contextual prompts (centered above controls)
            if viewModel.isOnTeleportPad {
                TeleportPromptView(onTap: { viewModel.openMap(teleportMode: true) })
                    .padding(.bottom, Theme.Spacing.sm)
            } else if viewModel.canSummonSailboat {
                SailboatPromptView(promptType: .summon, onTap: { viewModel.summonSailboat() })
                    .padding(.bottom, Theme.Spacing.sm)
            } else if viewModel.isNearSailboat {
                SailboatPromptView(promptType: .board, onTap: { viewModel.boardSailboat() })
                    .padding(.bottom, Theme.Spacing.sm)
            } else if viewModel.isNearLandWhileSailing {
                SailboatPromptView(promptType: .disembark, onTap: { viewModel.disembark() })
                    .padding(.bottom, Theme.Spacing.sm)
            }
            HStack(alignment: .bottom) {
                JoystickView(offset: $viewModel.joystickOffset)
                    .padding(.leading, safeLeft + buffer)
                    .padding(.bottom, safeBottom + buffer)

                Spacer()

                // right side controls
                VStack(spacing: Theme.Spacing.mdl) {
                    // tool button (turns cyan when can use equipped tool)
                    if !viewModel.player.isSailing {
                        ToolButtonView(
                            equippedTool: viewModel.player.equippedTool,
                            canUseTool: viewModel.canUseTool,
                            onTap: { viewModel.useTool() },
                            onLongPress: { viewModel.openToolMenu() }
                        )
                    }

                    // sprint button (hidden while sailing)
                    if !viewModel.player.isSailing {
                        SprintButtonView(isSprinting: $viewModel.player.isSprinting)
                    }
                }
                .padding(.trailing, safeRight + rightBuffer)
                .padding(.bottom, safeBottom + buffer)
            }
        }
    }
}

struct HeartsView: View {
    let health: Int // 1 unit = 1 full heart
    let maxHealth: Int

    var body: some View {
        HStack(spacing: Theme.Spacing.xxs) {
            ForEach(0..<maxHealth, id: \.self) { index in
                Image(systemName: index < health ? "heart.fill" : "heart")
                    .font(.system(size: Theme.Size.iconTiny))
                    .foregroundColor(index < health ? Theme.Color.health : Theme.Color.textDisabled)
            }
        }
    }
}

struct StaminaBarView: View {
    let stamina: CGFloat
    let maxStamina: CGFloat

    private let barWidth: CGFloat = Theme.Size.barWidth
    private let barHeight: CGFloat = Theme.Size.barHeight

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: Theme.Radius.small)
                .fill(Theme.Color.borderMedium)
                .frame(width: barWidth, height: barHeight)
            RoundedRectangle(cornerRadius: Theme.Radius.small)
                .fill(Theme.Color.stamina)
                .frame(width: barWidth * (stamina / maxStamina), height: barHeight)
        }
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.small)
                .stroke(Theme.Color.borderDark, lineWidth: Theme.Border.thin)
        )
    }
}

struct SprintButtonView: View {
    @Binding var isSprinting: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(isSprinting ? Theme.Color.sprint : Theme.Color.buttonInactive)
                .frame(width: Theme.Size.circleButton, height: Theme.Size.circleButton)
            Image(systemName: "figure.run")
                .font(.system(size: Theme.Size.iconMedium))
                .foregroundColor(Theme.Color.textPrimary)
        }
        .overlay(
            Circle()
                .stroke(isSprinting ? Theme.Color.sprint.opacity(Theme.Opacity.overlayMedium) : Theme.Color.borderDark, lineWidth: Theme.Border.standard)
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
