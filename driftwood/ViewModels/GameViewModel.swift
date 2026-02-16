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

    // enemy state
    @Published var slimes: [Slime] = []
    @Published var deathEffects: [SlimeDeathEffect] = []

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

        // load slimes from save or generate defaults
        if let savedSlimes = profile.slimes {
            let defaults = World.defaultSlimeSpawns()
            self.slimes = savedSlimes.map { data in
                var slime = defaults.first { $0.id == data.id } ?? Slime(id: data.id, position: data.position.cgPoint, spawnOrigin: data.position.cgPoint)
                slime.position = data.position.cgPoint
                slime.health = data.health
                slime.isAlive = data.isAlive
                return slime
            }
        } else {
            self.slimes = World.defaultSlimeSpawns()
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
            HapticService.shared.success()
            lastHealth = player.health
            saveCurrentProfile()
        }
    }

    func startGameLoop() {
        HapticService.shared.prepare()
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
        let slimeData = slimes.map { $0.toSaveData() }

        // if sailing, save the board position (last land position) and not sailing
        if player.isSailing, let landPosition = player.sailingBoardPosition {
            var landPlayer = player
            landPlayer.position = landPosition
            landPlayer.isSailing = false
            landPlayer.sailingBoardPosition = nil
            return SaveProfile(from: landPlayer, id: currentProfileIndex, inventory: inventoryViewModel.inventory, fishingState: fishingState, equippedTool: player.equippedTool, sailboatPosition: sailboatPos, slimes: slimeData)
        }

        // if swimming, save the last land position instead of current water position
        if player.isSwimming, let landPosition = player.swimStartPoint {
            var landPlayer = player
            landPlayer.position = landPosition
            landPlayer.isSwimming = false
            landPlayer.swimStartPoint = nil
            return SaveProfile(from: landPlayer, id: currentProfileIndex, inventory: inventoryViewModel.inventory, fishingState: fishingState, equippedTool: player.equippedTool, sailboatPosition: sailboatPos, slimes: slimeData)
        }

        return SaveProfile(from: player, id: currentProfileIndex, inventory: inventoryViewModel.inventory, fishingState: fishingState, equippedTool: player.equippedTool, sailboatPosition: sailboatPos, slimes: slimeData)
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
            HapticService.shared.error()
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
            player.health = max(0, player.health - 1) // drowning costs 1 heart
            HapticService.shared.warning()

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
        HapticService.shared.success()
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
        updateSlimes(deltaTime: deltaTime)
        checkSlimeContactDamage()
        checkSwordHits()
        updateDeathEffects(deltaTime: deltaTime)

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
        // boat hitbox: 64x64 sprite with 18px inset on each side = 28x28 collision
        let halfSize: CGFloat = 14

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
        HapticService.shared.light()
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
            HapticService.shared.medium()
            saveCurrentProfile()
        } else if isFacingRock() {
            _ = inventoryViewModel.addItem(.resource(type: .stone, quantity: 1))
            HapticService.shared.medium()
            saveCurrentProfile()
        }
    }

    // MARK: - Sword

    func startSwordSwing() {
        guard !player.isAttacking else { return }
        HapticService.shared.medium()
        player.isAttacking = true
        player.attackAnimationFrame = 1
        player.attackAnimationTime = 0
        player.attackSwingId += 1
    }

    private func updateAttackAnimation(deltaTime: CGFloat) {
        // decrement invincibility timer
        if player.invincibilityTimer > 0 {
            player.invincibilityTimer = max(0, player.invincibilityTimer - deltaTime)
        }

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
        HapticService.shared.success()
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
        guard let boat = sailboat, !player.isSailing else { return false }
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
        HapticService.shared.medium()

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
        HapticService.shared.medium()

        player.sailingBoardPosition = player.position // save land position before boarding
        player.position = boat.position
        player.isSailing = true
        player.isSwimming = false
        player.swimStartPoint = nil
        saveCurrentProfile()
    }

    func disembark() {
        guard player.isSailing, isNearLandWhileSailing else { return }
        HapticService.shared.light()

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

    // MARK: - Enemies

    private func updateSlimes(deltaTime: CGFloat) {
        for i in 0..<slimes.count {
            guard slimes[i].isAlive else { continue }

            // decrement hit flash
            if slimes[i].hitFlashTimer > 0 {
                slimes[i].hitFlashTimer = max(0, slimes[i].hitFlashTimer - deltaTime)
            }

            let distToPlayer = hypot(
                player.position.x - slimes[i].position.x,
                player.position.y - slimes[i].position.y
            )

            // state transitions
            switch slimes[i].aiState {
            case .patrol:
                if distToPlayer <= Slime.chaseRadius {
                    slimes[i].aiState = .chase
                }
            case .chase:
                if distToPlayer > Slime.chaseRadius {
                    slimes[i].aiState = .returning
                }
            case .returning:
                if distToPlayer <= Slime.chaseRadius {
                    slimes[i].aiState = .chase
                }
                let distToSpawn = hypot(
                    slimes[i].spawnOrigin.x - slimes[i].position.x,
                    slimes[i].spawnOrigin.y - slimes[i].position.y
                )
                if distToSpawn < tileSize {
                    slimes[i].aiState = .patrol(target: slimes[i].spawnOrigin)
                }
            }

            // movement
            switch slimes[i].aiState {
            case .patrol(let target):
                moveSlime(index: i, toward: target, speed: Slime.patrolSpeed, deltaTime: deltaTime)
                let distToTarget = hypot(target.x - slimes[i].position.x, target.y - slimes[i].position.y)
                if distToTarget < 4 {
                    slimes[i].patrolPauseTimer = CGFloat.random(in: 1.0...2.0)
                    slimes[i].aiState = .patrol(target: randomPatrolTarget(for: slimes[i]))
                }
                if slimes[i].patrolPauseTimer > 0 {
                    slimes[i].patrolPauseTimer -= deltaTime
                }
            case .chase:
                moveSlime(index: i, toward: player.position, speed: Slime.chaseSpeed, deltaTime: deltaTime)
            case .returning:
                moveSlime(index: i, toward: slimes[i].spawnOrigin, speed: Slime.patrolSpeed, deltaTime: deltaTime)
            }
        }
    }

    private func moveSlime(index: Int, toward target: CGPoint, speed: CGFloat, deltaTime: CGFloat) {
        // skip if pausing during patrol
        if case .patrol = slimes[index].aiState, slimes[index].patrolPauseTimer > 0 {
            return
        }

        let dx = target.x - slimes[index].position.x
        let dy = target.y - slimes[index].position.y
        let dist = hypot(dx, dy)
        guard dist > 1 else { return }

        let moveX = (dx / dist) * speed * deltaTime
        let moveY = (dy / dist) * speed * deltaTime

        let newPos = CGPoint(x: slimes[index].position.x + moveX, y: slimes[index].position.y + moveY)
        if slimeCanMoveTo(newPos) {
            slimes[index].position = newPos
        } else {
            // slide movement
            let slideX = CGPoint(x: slimes[index].position.x + moveX, y: slimes[index].position.y)
            if slimeCanMoveTo(slideX) {
                slimes[index].position = slideX
            }
            let slideY = CGPoint(x: slimes[index].position.x, y: slimes[index].position.y + moveY)
            if slimeCanMoveTo(slideY) {
                slimes[index].position = slideY
            }
        }
    }

    private func randomPatrolTarget(for slime: Slime) -> CGPoint {
        let angle = CGFloat.random(in: 0...(2 * .pi))
        let dist = CGFloat.random(in: 20...Slime.patrolRadius)
        let target = CGPoint(
            x: slime.spawnOrigin.x + cos(angle) * dist,
            y: slime.spawnOrigin.y + sin(angle) * dist
        )
        // validate the target is walkable
        if slimeCanMoveTo(target) { return target }
        return slime.spawnOrigin // fallback to spawn if target is invalid
    }

    private func slimeCanMoveTo(_ position: CGPoint) -> Bool {
        let half = Slime.halfSize
        let leftTile = Int(floor((position.x - half) / tileSize))
        let rightTile = Int(floor((position.x + half - 0.01) / tileSize))
        let topTile = Int(floor((position.y - half) / tileSize))
        let bottomTile = Int(floor((position.y + half - 0.01) / tileSize))

        for tileY in topTile...bottomTile {
            for tileX in leftTile...rightTile {
                let tile = world.tile(at: tileX, y: tileY)
                if !tile.isWalkable { return false }
            }
        }

        let slimeRect = CGRect(x: position.x - half, y: position.y - half, width: Slime.size, height: Slime.size)
        for rock in world.rockOverlays {
            if slimeRect.intersects(rock.collisionRect(tileSize: tileSize)) {
                return false
            }
        }
        return true
    }

    // MARK: - Combat

    private func checkSlimeContactDamage() {
        guard !player.isInvincible && !player.isSailing && !isDead else { return }

        let playerRect = CGRect(
            x: player.position.x - 12,
            y: player.position.y - 16,
            width: 24, height: 32
        )

        for i in 0..<slimes.count {
            guard slimes[i].isAlive else { continue }
            guard playerRect.intersects(slimes[i].collisionRect) else { continue }

            // deal half-heart damage
            player.health = max(0, player.health - Slime.contactDamage)
            player.invincibilityTimer = Player.invincibilityDuration
            lastHealth = player.health

            // knockback player away from slime
            let dir = CGPoint(
                x: player.position.x - slimes[i].position.x,
                y: player.position.y - slimes[i].position.y
            )
            applyKnockback(position: &player.position, direction: dir, distance: Slime.knockbackDistance, halfWidth: 12, halfHeight: 16)
            HapticService.shared.heavy()

            // check death
            if player.health <= 0 {
                deathPosition = player.position
                respawnLandPosition = player.position
                HapticService.shared.error()
                saveCurrentProfile()
                isDead = true
            }
            return // only process one hit per frame
        }
    }

    private func checkSwordHits() {
        guard player.isAttacking else { return }
        guard let hitbox = swordHitbox() else { return }

        for i in 0..<slimes.count {
            guard slimes[i].isAlive else { continue }
            guard slimes[i].hitCooldown != player.attackSwingId else { continue }
            guard hitbox.intersects(slimes[i].collisionRect) else { continue }

            // deal damage
            slimes[i].health -= 1
            slimes[i].hitCooldown = player.attackSwingId
            slimes[i].hitFlashTimer = Slime.hitFlashDuration
            HapticService.shared.medium()

            // knockback slime in facing direction
            let (dx, dy) = facingOffset()
            let dir = CGPoint(x: CGFloat(dx), y: CGFloat(dy))
            applyKnockback(position: &slimes[i].position, direction: dir, distance: Slime.knockbackDistance, halfWidth: Slime.halfSize, halfHeight: Slime.halfSize)

            // check slime death
            if slimes[i].health <= 0 {
                slimes[i].isAlive = false
                deathEffects.append(SlimeDeathEffect(position: slimes[i].position))
                HapticService.shared.heavy()
            }
        }
    }

    private func swordHitbox() -> CGRect? {
        guard player.isAttacking else { return nil }
        let reach: CGFloat = 20
        let hitboxSize: CGFloat = 28
        let half = hitboxSize / 2

        let cx: CGFloat
        let cy: CGFloat
        switch player.facingDirection {
        case .up:    cx = player.position.x; cy = player.position.y - reach
        case .down:  cx = player.position.x; cy = player.position.y + reach
        case .left:  cx = player.position.x - reach; cy = player.position.y
        case .right: cx = player.position.x + reach; cy = player.position.y
        }
        return CGRect(x: cx - half, y: cy - half, width: hitboxSize, height: hitboxSize)
    }

    private func applyKnockback(position: inout CGPoint, direction: CGPoint, distance: CGFloat, halfWidth: CGFloat, halfHeight: CGFloat) {
        let length = hypot(direction.x, direction.y)
        guard length > 0 else { return }
        let nx = direction.x / length
        let ny = direction.y / length

        // apply in steps to respect collision
        let steps = 4
        let stepDist = distance / CGFloat(steps)
        for _ in 0..<steps {
            let newPos = CGPoint(x: position.x + nx * stepDist, y: position.y + ny * stepDist)
            if canEntityMoveTo(newPos, halfWidth: halfWidth, halfHeight: halfHeight) {
                position = newPos
            } else {
                break
            }
        }
    }

    private func canEntityMoveTo(_ position: CGPoint, halfWidth: CGFloat, halfHeight: CGFloat) -> Bool {
        let leftTile = Int(floor((position.x - halfWidth) / tileSize))
        let rightTile = Int(floor((position.x + halfWidth - 0.01) / tileSize))
        let topTile = Int(floor((position.y - halfHeight) / tileSize))
        let bottomTile = Int(floor((position.y + halfHeight - 0.01) / tileSize))

        for tileY in topTile...bottomTile {
            for tileX in leftTile...rightTile {
                let tile = world.tile(at: tileX, y: tileY)
                if !tile.isWalkable && !tile.isSwimmable { return false }
            }
        }

        let entityRect = CGRect(x: position.x - halfWidth, y: position.y - halfHeight, width: halfWidth * 2, height: halfHeight * 2)
        for rock in world.rockOverlays {
            if entityRect.intersects(rock.collisionRect(tileSize: tileSize)) {
                return false
            }
        }
        return true
    }

    private func updateDeathEffects(deltaTime: CGFloat) {
        for i in (0..<deathEffects.count).reversed() {
            deathEffects[i].elapsed += deltaTime
            if deathEffects[i].elapsed >= SlimeDeathEffect.duration {
                deathEffects.remove(at: i)
            }
        }
    }

    // MARK: - Map/Teleport

    var isOnTeleportPad: Bool {
        guard !player.isSailing, !player.isSwimming else { return false }
        return currentTeleportPad != nil
    }

    var currentTeleportPad: TeleportPad? {
        guard !player.isSailing, !player.isSwimming else { return nil }
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

        // close map immediately
        closeMap()

        // fade to black
        withAnimation(.easeIn(duration: 0.3)) {
            screenFadeOpacity = 1
        }

        Task {
            try? await Task.sleep(for: .milliseconds(500))

            // teleport player
            HapticService.shared.heavy()
            player.position = pad.worldPosition
            saveCurrentProfile()

            // fade back in
            withAnimation(.easeOut(duration: 0.3)) {
                screenFadeOpacity = 0
            }
        }
    }
}
