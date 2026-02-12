//
//  GameViewModel.swift
//  driftwood
//

import SwiftUI
import Combine

@MainActor
class GameViewModel: ObservableObject {
    @Published var player: Player
    @Published var world: World
    @Published var inventoryViewModel: InventoryViewModel
    @Published var isInventoryOpen: Bool = false
    @Published var isDead: Bool = false

    // tool/fishing state
    @Published var isToolMenuOpen: Bool = false
    @Published var isFishing: Bool = false
    @Published var showingFishingResults: Bool = false
    @Published var fishingViewModel: FishingViewModel?
    @Published var fishingState: FishingState = FishingState()

    // notifications
    @Published var showLevelUpNotification: Bool = false
    @Published var levelUpNotificationLevel: Int = 0

    // sailing state
    @Published var sailboat: Sailboat?
    @Published var sailingState: SailingState = SailingState()

    // map/teleport state
    @Published var isMapOpen: Bool = false
    @Published var isMapTeleportMode: Bool = false

    @Published var joystickOffset: CGSize = .zero
    @Published var screenFadeOpacity: Double = 0

    var onReturnToMainMenu: (() -> Void)?
    private var deathPosition: CGPoint?
    private var respawnLandPosition: CGPoint?

    var effectiveMaxHealth: Int {
        let bonusHearts = inventoryViewModel.inventory.equipment.totalStats.bonusHearts
        return player.maxHealth + Int(bonusHearts)
    }

    var currentProfileIndex: Int
    private let tileSize: CGFloat = 24
    private var isDrowning: Bool = false
    private let movementSpeed: CGFloat = 100
    private var gameLoopCancellable: AnyCancellable?
    private var autoSaveCancellable: AnyCancellable?
    private var lastHealth: Int = 5

    init(profile: SaveProfile) {
        self.world = World()
        self.currentProfileIndex = profile.id
        self.inventoryViewModel = InventoryViewModel(inventory: profile.inventory)

        var player = Player(startPosition: profile.position.cgPoint)
        player.lookDirection = profile.lookDirection.cgPoint
        player.facingDirection = profile.facingDirection ?? FacingDirection.from(direction: profile.lookDirection.cgPoint)
        player.health = profile.health
        player.stamina = profile.stamina
        player.magic = profile.magic
        self.player = player
        self.lastHealth = profile.health

        // load fishing state
        self.fishingState = profile.fishingState
        self.player.equippedTool = profile.equippedTool

        // load sailing state (only if boat exists)
        if let sailboatPos = profile.sailboatPosition {
            self.sailboat = Sailboat(position: sailboatPos.cgPoint)
            self.player.isSailing = profile.isSailing
        } else {
            self.sailboat = nil
            self.player.isSailing = false
        }
    }

    // MARK: - Inventory

    func openInventory() {
        isInventoryOpen = true
        gameLoopCancellable?.cancel()
        gameLoopCancellable = nil
    }

    func closeInventory() {
        isInventoryOpen = false
        inventoryViewModel.clearSelection()
        startGameLoop()
    }

    func useMeal(at index: Int) {
        inventoryViewModel.useMeal(at: index, player: &player, effectiveMaxHealth: effectiveMaxHealth)
        if player.health != lastHealth {
            lastHealth = player.health
            saveCurrentProfile()
        }
    }

    func startGameLoop() {
        gameLoopCancellable = Timer.publish(every: 1.0 / 60.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updatePlayerPosition()
            }

        // auto-save every 30 seconds
        autoSaveCancellable = Timer.publish(every: 30.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.saveCurrentProfile()
            }
    }

    func stopGameLoop() {
        gameLoopCancellable?.cancel()
        gameLoopCancellable = nil
        autoSaveCancellable?.cancel()
        autoSaveCancellable = nil
        saveCurrentProfile()
    }

    func createSaveProfile() -> SaveProfile {
        let sailboatPos = sailboat.map { CodablePoint($0.position) }

        // if sailing, save the board position (last land position) and not sailing
        if player.isSailing, let landPosition = player.sailingBoardPosition {
            var landPlayer = player
            landPlayer.position = landPosition
            landPlayer.isSailing = false
            landPlayer.sailingBoardPosition = nil
            return SaveProfile(from: landPlayer, id: currentProfileIndex, inventory: inventoryViewModel.inventory, fishingState: fishingState, equippedTool: player.equippedTool, sailboatPosition: sailboatPos)
        }

        // if swimming, save the last land position instead of current water position
        if player.isSwimming, let landPosition = player.swimStartPoint {
            var landPlayer = player
            landPlayer.position = landPosition
            landPlayer.isSwimming = false
            landPlayer.swimStartPoint = nil
            return SaveProfile(from: landPlayer, id: currentProfileIndex, inventory: inventoryViewModel.inventory, fishingState: fishingState, equippedTool: player.equippedTool, sailboatPosition: sailboatPos)
        }

        return SaveProfile(from: player, id: currentProfileIndex, inventory: inventoryViewModel.inventory, fishingState: fishingState, equippedTool: player.equippedTool, sailboatPosition: sailboatPos)
    }

    func saveCurrentProfile() {
        let profile = createSaveProfile()
        SaveManager.shared.saveProfile(profile)
    }

    private func updateStamina(deltaTime: CGFloat, isMoving: Bool) {
        // no stamina drain while sailing
        if player.isSailing {
            if player.stamina < player.maxStamina {
                player.stamina = min(player.stamina + player.staminaRegenRate * deltaTime, player.maxStamina)
            }
            return
        }

        if player.isSwimming {
            if isMoving {
                let drainRate = player.isSprinting ? player.swimSprintStaminaDrainRate : player.swimStaminaDrainRate
                player.stamina -= drainRate * deltaTime
                if player.stamina <= 0 {
                    player.stamina = 0
                    handleStaminaDepleted()
                }
            }
        } else if player.stamina < player.maxStamina {
            player.stamina = min(player.stamina + player.staminaRegenRate * deltaTime, player.maxStamina)
        }
    }

    private func handleStaminaDepleted() {
        guard let startPoint = player.swimStartPoint else { return }
        guard !isDrowning else { return }
        isDrowning = true

        // check if this drowning will kill the player
        let willDie = player.health <= 1

        if willDie {
            // store positions for respawn
            deathPosition = player.position
            respawnLandPosition = startPoint
        }

        withAnimation(.easeIn(duration: 0.3)) {
            screenFadeOpacity = 1
        }

        Task {
            try? await Task.sleep(for: .milliseconds(400))

            if willDie {
                player.health = 0
                lastHealth = 0
                saveCurrentProfile()
                isDead = true
                isDrowning = false
                return
            }

            player.position = startPoint
            player.isSwimming = false
            player.swimStartPoint = nil
            player.health = max(0, player.health - 1)

            if player.health != lastHealth {
                lastHealth = player.health
                saveCurrentProfile()
            }

            withAnimation(.easeOut(duration: 0.3)) {
                screenFadeOpacity = 0
            }

            try? await Task.sleep(for: .milliseconds(300))
            isDrowning = false
        }
    }

    func respawn() {
        // if died in water, respawn at last land position; otherwise at death position
        let respawnPosition = respawnLandPosition ?? deathPosition ?? player.position

        player.position = respawnPosition
        player.isSwimming = false
        player.swimStartPoint = nil
        player.health = effectiveMaxHealth
        player.stamina = player.maxStamina

        lastHealth = player.health
        saveCurrentProfile()

        deathPosition = nil
        respawnLandPosition = nil

        withAnimation(.easeOut(duration: 0.3)) {
            screenFadeOpacity = 0
        }

        isDead = false
    }

    func returnToMainMenu() {
        // respawn player before returning to menu so they're alive when they return
        let respawnPosition = respawnLandPosition ?? deathPosition ?? player.position
        player.position = respawnPosition
        player.isSwimming = false
        player.swimStartPoint = nil
        player.health = effectiveMaxHealth
        player.stamina = player.maxStamina
        isDead = false
        deathPosition = nil
        respawnLandPosition = nil

        saveCurrentProfile()
        stopGameLoop()
        onReturnToMainMenu?()
    }

    private func updatePlayerPosition() {
        let deltaTime: CGFloat = 1.0 / 60.0
        let maxRadius = (120.0 - 50.0) / 2
        let distance = hypot(joystickOffset.width, joystickOffset.height)
        let isMoving = distance > 0

        player.isWalking = isMoving && !player.isSailing

        updateAttackAnimation(deltaTime: deltaTime)
        updateStamina(deltaTime: deltaTime, isMoving: isMoving)

        // handle sailing movement
        if player.isSailing {
            updateSailingPosition(deltaTime: deltaTime, distance: distance, maxRadius: maxRadius)
            return
        }

        guard isMoving else { return }

        let clampedDistance = min(distance, maxRadius)
        let normalizedX = (joystickOffset.width / distance) * (clampedDistance / maxRadius)
        let normalizedY = (joystickOffset.height / distance) * (clampedDistance / maxRadius)

        let speedMultiplier: CGFloat
        if player.isSwimming {
            speedMultiplier = player.isSprinting ? 0.8 : player.swimSpeedMultiplier
        } else {
            speedMultiplier = player.isSprinting ? player.sprintSpeedMultiplier : 1.0
        }
        let currentSpeed = movementSpeed * speedMultiplier
        let deltaX = normalizedX * currentSpeed * deltaTime
        let deltaY = normalizedY * currentSpeed * deltaTime

        let previousPosition = player.position

        let newPosition = CGPoint(
            x: player.position.x + deltaX,
            y: player.position.y + deltaY
        )

        if canMoveTo(newPosition) {
            player.position = newPosition
        } else {
            let slideX = CGPoint(x: player.position.x + deltaX, y: player.position.y)
            if canMoveTo(slideX) {
                player.position = slideX
            }
            let slideY = CGPoint(x: player.position.x, y: player.position.y + deltaY)
            if canMoveTo(slideY) {
                player.position = slideY
            }
        }

        player.lookDirection = CGPoint(
            x: joystickOffset.width / distance,
            y: joystickOffset.height / distance
        )
        player.facingDirection = FacingDirection.from(direction: player.lookDirection)

        updateSwimmingState(previousPosition: previousPosition)
    }

    private func updateSailingPosition(deltaTime: CGFloat, distance: CGFloat, maxRadius: CGFloat) {
        // update wind
        sailingState.updateWind(deltaTime: deltaTime)

        // calculate joystick velocity
        var deltaX: CGFloat = 0
        var deltaY: CGFloat = 0

        if distance > 0 {
            let clampedDistance = min(distance, maxRadius)
            let normalizedX = (joystickOffset.width / distance) * (clampedDistance / maxRadius)
            let normalizedY = (joystickOffset.height / distance) * (clampedDistance / maxRadius)

            // sailing speed: 4x swim speed = 2x walk speed
            let sailingSpeed = movementSpeed * player.swimSpeedMultiplier * player.sailingSpeedMultiplier
            deltaX = normalizedX * sailingSpeed * deltaTime
            deltaY = normalizedY * sailingSpeed * deltaTime

            // update facing direction
            player.lookDirection = CGPoint(
                x: joystickOffset.width / distance,
                y: joystickOffset.height / distance
            )
            player.facingDirection = FacingDirection.from(direction: player.lookDirection)
        }

        // add wind push
        let windPush = sailingState.windDirection
        deltaX += windPush.x * sailingState.windStrength * deltaTime
        deltaY += windPush.y * sailingState.windStrength * deltaTime

        let newPosition = CGPoint(
            x: player.position.x + deltaX,
            y: player.position.y + deltaY
        )

        // use sailing collision check
        if canSailTo(newPosition) {
            player.position = newPosition
            sailboat?.position = newPosition
        } else {
            // slide movement
            let slideX = CGPoint(x: player.position.x + deltaX, y: player.position.y)
            if canSailTo(slideX) {
                player.position = slideX
                sailboat?.position = slideX
            }
            let slideY = CGPoint(x: player.position.x, y: player.position.y + deltaY)
            if canSailTo(slideY) {
                player.position = slideY
                sailboat?.position = slideY
            }
        }
    }

    private func canSailTo(_ position: CGPoint) -> Bool {
        // boat hitbox: 32x32 sprite with 9px inset on each side = 14x14 collision
        let halfSize: CGFloat = 7

        let leftTile = Int(floor((position.x - halfSize) / tileSize))
        let rightTile = Int(floor((position.x + halfSize - 0.01) / tileSize))
        let topTile = Int(floor((position.y - halfSize) / tileSize))
        let bottomTile = Int(floor((position.y + halfSize - 0.01) / tileSize))

        for tileY in topTile...bottomTile {
            for tileX in leftTile...rightTile {
                if !world.tile(at: tileX, y: tileY).isSwimmable {
                    return false
                }
            }
        }
        return true
    }

    private func canMoveTo(_ position: CGPoint) -> Bool {
        // player hitbox: 24 wide x 32 tall (4 pixel margin on each side horizontally)
        let halfWidth: CGFloat = 12
        let halfHeight: CGFloat = 16

        // get tile range that the player hitbox overlaps
        let leftTile = Int(floor((position.x - halfWidth) / tileSize))
        let rightTile = Int(floor((position.x + halfWidth - 0.01) / tileSize))
        let topTile = Int(floor((position.y - halfHeight) / tileSize))
        let bottomTile = Int(floor((position.y + halfHeight - 0.01) / tileSize))

        // check all tiles the hitbox overlaps
        for tileY in topTile...bottomTile {
            for tileX in leftTile...rightTile {
                let tile = world.tile(at: tileX, y: tileY)
                if !tile.isWalkable && !tile.isSwimmable {
                    return false
                }
            }
        }

        // check rock collision bounds
        let playerRect = CGRect(
            x: position.x - halfWidth,
            y: position.y - halfHeight,
            width: halfWidth * 2,
            height: halfHeight * 2
        )
        for rock in world.rockOverlays {
            let rockRect = rock.collisionRect(tileSize: tileSize)
            if playerRect.intersects(rockRect) {
                return false
            }
        }

        return true
    }

    private func isInWater(_ position: CGPoint) -> Bool {
        let tileX = Int(position.x / tileSize)
        let tileY = Int(position.y / tileSize)
        return world.tile(at: tileX, y: tileY).isSwimmable
    }

    private func updateSwimmingState(previousPosition: CGPoint) {
        let wasSwimming = player.isSwimming
        let nowInWater = isInWater(player.position)

        if nowInWater && !wasSwimming {
            player.isSwimming = true
            player.swimStartPoint = previousPosition
        } else if !nowInWater && wasSwimming {
            player.isSwimming = false
            player.swimStartPoint = nil
        }
    }

    // MARK: - Tools

    func equipTool(_ tool: ToolType?) {
        player.equippedTool = tool
        isToolMenuOpen = false
    }

    func openToolMenu() {
        isToolMenuOpen = true
    }

    func closeToolMenu() {
        isToolMenuOpen = false
    }

    func ownedTools() -> [ToolType] {
        var tools: [ToolType] = []
        if inventoryViewModel.inventory.tools.fishingRodTier > 0 {
            tools.append(.fishingRod)
        }
        if inventoryViewModel.inventory.tools.swordTier > 0 {
            tools.append(.sword)
        }
        if inventoryViewModel.inventory.tools.axeTier > 0 {
            tools.append(.axe)
        }
        if inventoryViewModel.inventory.tools.hasWand {
            tools.append(.wand)
        }
        return tools
    }

    // MARK: - Tool Actions

    var canUseTool: Bool {
        guard let tool = player.equippedTool else { return false }
        if player.isAttacking { return false }
        switch tool {
        case .fishingRod:
            return isFacingWater() && !player.isSwimming
        case .sword:
            return inventoryViewModel.inventory.tools.swordTier > 0
        case .axe:
            return isFacingTree() || isFacingRock()
        case .wand:
            return false // not yet implemented
        }
    }

    func useTool() {
        guard let tool = player.equippedTool else { return }
        switch tool {
        case .fishingRod:
            startFishing()
        case .sword:
            startSwordSwing()
        case .axe:
            useAxe()
        case .wand:
            break // not yet implemented
        }
    }

    // MARK: - Axe

    func useAxe() {
        if isFacingTree() {
            _ = inventoryViewModel.addItem(.resource(type: .wood, quantity: 1))
            saveCurrentProfile()
        } else if isFacingRock() {
            _ = inventoryViewModel.addItem(.resource(type: .stone, quantity: 1))
            saveCurrentProfile()
        }
    }

    // MARK: - Sword

    func startSwordSwing() {
        guard !player.isAttacking else { return }
        player.isAttacking = true
        player.attackAnimationFrame = 1
        player.attackAnimationTime = 0
    }

    private func updateAttackAnimation(deltaTime: CGFloat) {
        guard player.isAttacking else { return }

        player.attackAnimationTime += deltaTime
        let frameIndex = Int(player.attackAnimationTime / Player.attackFrameDuration) + 1
        if frameIndex > Player.attackFrameCount {
            player.isAttacking = false
            player.attackAnimationFrame = 0
            player.attackAnimationTime = 0
        } else {
            player.attackAnimationFrame = frameIndex
        }
    }

    // MARK: - Directional Detection

    private func facingOffset() -> (dx: Int, dy: Int) {
        switch player.facingDirection {
        case .up: return (0, -1)
        case .down: return (0, 1)
        case .left: return (-1, 0)
        case .right: return (1, 0)
        }
    }

    func isFacingWater() -> Bool {
        let playerTileX = Int(player.position.x / tileSize)
        let playerTileY = Int(player.position.y / tileSize)
        let (dx, dy) = facingOffset()
        // check both 1 and 2 tiles away (boat is summoned 2 tiles out)
        let tile1 = world.tile(at: playerTileX + dx, y: playerTileY + dy)
        let tile2 = world.tile(at: playerTileX + dx * 2, y: playerTileY + dy * 2)
        return tile1.isSwimmable && tile2.isSwimmable
    }

    func isFacingTree() -> Bool {
        let playerTileX = Int(player.position.x / tileSize)
        let playerTileY = Int(player.position.y / tileSize)
        let (dx, dy) = facingOffset()
        let targetX = playerTileX + dx
        let targetY = playerTileY + dy

        // trees use groundSprites (trunk is 2x2 tiles)
        for sprite in world.groundSprites {
            let spriteLeft = sprite.x
            let spriteRight = sprite.x + sprite.size - 1
            let spriteTop = sprite.y
            let spriteBottom = sprite.y + sprite.size - 1

            if targetX >= spriteLeft && targetX <= spriteRight &&
               targetY >= spriteTop && targetY <= spriteBottom {
                return true
            }
        }
        return false
    }

    func isFacingRock() -> Bool {
        let playerTileX = Int(player.position.x / tileSize)
        let playerTileY = Int(player.position.y / tileSize)
        let (dx, dy) = facingOffset()
        let targetX = playerTileX + dx
        let targetY = playerTileY + dy

        // rocks are 2x2 tiles anchored at top-left
        for rock in world.rockOverlays {
            let rockLeft = rock.x
            let rockRight = rock.x + 1  // 2 tiles wide
            let rockTop = rock.y
            let rockBottom = rock.y + 1  // 2 tiles tall

            if targetX >= rockLeft && targetX <= rockRight &&
               targetY >= rockTop && targetY <= rockBottom {
                return true
            }
        }
        return false
    }

    // MARK: - Fishing

    var canFish: Bool {
        player.equippedTool == .fishingRod && isFacingWater() && !player.isSwimming
    }

    func startFishing() {
        guard canFish else { return }

        gameLoopCancellable?.cancel()
        gameLoopCancellable = nil

        let fortune = inventoryViewModel.inventory.totalFishingFortune
        let vm = FishingViewModel(
            fortune: fortune,
            level: fishingState.fishingLevel,
            inventoryViewModel: inventoryViewModel,
            fishingState: fishingState
        )
        fishingViewModel = vm
        isFishing = true
    }

    func endFishing() {
        guard let vm = fishingViewModel else { return }

        // check for level up
        let previousLevel = fishingState.fishingLevel
        let newLevel = vm.fishingState.fishingLevel

        // update fishing state with new catches
        fishingState = vm.fishingState
        showingFishingResults = true

        // trigger level up notification if leveled up
        if newLevel > previousLevel {
            showFishingLevelUp(newLevel)
        }
    }

    func showFishingLevelUp(_ level: Int) {
        levelUpNotificationLevel = level
        showLevelUpNotification = true

        Task {
            try? await Task.sleep(for: .seconds(3))
            await MainActor.run {
                showLevelUpNotification = false
            }
        }
    }

    func dismissFishingResults() {
        showingFishingResults = false
        isFishing = false
        fishingViewModel = nil
        saveCurrentProfile()
        startGameLoop()
    }

    // MARK: - Sailing

    var canSummonSailboat: Bool {
        inventoryViewModel.inventory.majorUpgrades.hasSailboat &&
        !player.isSwimming &&
        !player.isSailing &&
        isFacingWater()
    }

    var isNearSailboat: Bool {
        guard let boat = sailboat, !player.isSailing, !player.isSwimming else { return false }
        let distance = hypot(player.position.x - boat.position.x,
                             player.position.y - boat.position.y)
        return distance < tileSize * 2.0
    }

    var isNearLandWhileSailing: Bool {
        guard player.isSailing else { return false }
        let playerTileX = Int(player.position.x / tileSize)
        let playerTileY = Int(player.position.y / tileSize)
        for dy in -1...1 {
            for dx in -1...1 {
                let tile = world.tile(at: playerTileX + dx, y: playerTileY + dy)
                if tile.isWalkable { return true }
            }
        }
        return false
    }

    func summonSailboat() {
        guard canSummonSailboat else { return }

        let playerTileX = Int(player.position.x / tileSize)
        let playerTileY = Int(player.position.y / tileSize)
        let (dx, dy) = facingOffset()
        // place boat 2 tiles away so it doesn't get stuck in land collision
        let targetTileX = playerTileX + dx * 2
        let targetTileY = playerTileY + dy * 2

        // place boat at center of target water tile
        let boatX = CGFloat(targetTileX) * tileSize + tileSize / 2
        let boatY = CGFloat(targetTileY) * tileSize + tileSize / 2

        sailboat = Sailboat(position: CGPoint(x: boatX, y: boatY))
        saveCurrentProfile()
    }

    func boardSailboat() {
        guard let boat = sailboat, isNearSailboat else { return }

        player.sailingBoardPosition = player.position // save land position before boarding
        player.position = boat.position
        player.isSailing = true
        player.isSwimming = false
        player.swimStartPoint = nil
        saveCurrentProfile()
    }

    func disembark() {
        guard player.isSailing, isNearLandWhileSailing else { return }

        // keep sailboat at current position and rotation
        sailboat?.position = player.position
        sailboat?.rotationAngle = atan2(player.lookDirection.y, player.lookDirection.x)

        // find nearest walkable tile, prefer facing direction
        let playerTileX = Int(player.position.x / tileSize)
        let playerTileY = Int(player.position.y / tileSize)
        let (facingDx, facingDy) = facingOffset()

        // check facing direction first
        let facingTile = world.tile(at: playerTileX + facingDx, y: playerTileY + facingDy)
        if facingTile.isWalkable {
            let landX = CGFloat(playerTileX + facingDx) * tileSize + tileSize / 2
            let landY = CGFloat(playerTileY + facingDy) * tileSize + tileSize / 2
            player.position = CGPoint(x: landX, y: landY)
            player.isSailing = false
            player.sailingBoardPosition = nil
            saveCurrentProfile()
            return
        }

        // search all adjacent tiles for walkable
        for dy in -1...1 {
            for dx in -1...1 {
                if dx == 0 && dy == 0 { continue }
                let tile = world.tile(at: playerTileX + dx, y: playerTileY + dy)
                if tile.isWalkable {
                    let landX = CGFloat(playerTileX + dx) * tileSize + tileSize / 2
                    let landY = CGFloat(playerTileY + dy) * tileSize + tileSize / 2
                    player.position = CGPoint(x: landX, y: landY)
                    player.isSailing = false
                    player.sailingBoardPosition = nil
                    saveCurrentProfile()
                    return
                }
            }
        }
    }

    // MARK: - Map/Teleport

    var isOnTeleportPad: Bool {
        guard !player.isSailing, !player.isSwimming else { return false }
        let playerTileX = Int(player.position.x / tileSize)
        let playerTileY = Int(player.position.y / tileSize)
        return world.tile(at: playerTileX, y: playerTileY) == .teleportPad
    }

    var currentTeleportPad: TeleportPad? {
        guard isOnTeleportPad else { return nil }
        let playerTileX = Int(player.position.x / tileSize)
        let playerTileY = Int(player.position.y / tileSize)
        return world.teleportPads.first { $0.tileX == playerTileX && $0.tileY == playerTileY }
    }

    func openMap(teleportMode: Bool) {
        isMapTeleportMode = teleportMode
        isMapOpen = true
    }

    func closeMap() {
        isMapOpen = false
        isMapTeleportMode = false
    }

    func teleportTo(pad: TeleportPad) {
        // don't teleport to current location
        if let current = currentTeleportPad, current.id == pad.id {
            closeMap()
            return
        }
        player.position = pad.worldPosition
        closeMap()
        saveCurrentProfile()
    }
}
