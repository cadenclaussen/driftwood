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
        player.health = profile.health
        player.stamina = profile.stamina
        player.magic = profile.magic
        self.player = player
        self.lastHealth = profile.health

        // load fishing state
        self.fishingState = profile.fishingState
        self.player.equippedTool = profile.equippedTool
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
        // if swimming, save the last land position instead of current water position
        if player.isSwimming, let landPosition = player.swimStartPoint {
            var landPlayer = player
            landPlayer.position = landPosition
            landPlayer.isSwimming = false
            landPlayer.swimStartPoint = nil
            return SaveProfile(from: landPlayer, id: currentProfileIndex, inventory: inventoryViewModel.inventory, fishingState: fishingState, equippedTool: player.equippedTool)
        }
        return SaveProfile(from: player, id: currentProfileIndex, inventory: inventoryViewModel.inventory, fishingState: fishingState, equippedTool: player.equippedTool)
    }

    func saveCurrentProfile() {
        let profile = createSaveProfile()
        SaveManager.shared.saveProfile(profile)
    }

    private func updateStamina(deltaTime: CGFloat, isMoving: Bool) {
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
        stopGameLoop()
        onReturnToMainMenu?()
    }

    private func updatePlayerPosition() {
        let deltaTime: CGFloat = 1.0 / 60.0
        let maxRadius = (120.0 - 50.0) / 2
        let distance = hypot(joystickOffset.width, joystickOffset.height)
        let isMoving = distance > 0

        updateStamina(deltaTime: deltaTime, isMoving: isMoving)

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

        updateSwimmingState(previousPosition: previousPosition)
    }

    private func canMoveTo(_ position: CGPoint) -> Bool {
        let radius = player.size / 2
        let checkPoints = [
            CGPoint(x: position.x - radius, y: position.y - radius),
            CGPoint(x: position.x + radius, y: position.y - radius),
            CGPoint(x: position.x - radius, y: position.y + radius),
            CGPoint(x: position.x + radius, y: position.y + radius),
        ]

        for point in checkPoints {
            let tileX = Int(point.x / tileSize)
            let tileY = Int(point.y / tileSize)
            let tile = world.tile(at: tileX, y: tileY)
            if !tile.isWalkable && !tile.isSwimmable {
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

    // MARK: - Fishing

    var canFish: Bool {
        player.equippedTool == .fishingRod && isNearWater() && !player.isSwimming
    }

    func isNearWater() -> Bool {
        let playerTileX = Int(player.position.x / tileSize)
        let playerTileY = Int(player.position.y / tileSize)

        let directions = [(0, -1), (0, 1), (-1, 0), (1, 0)] // up, down, left, right
        for (dx, dy) in directions {
            let tile = world.tile(at: playerTileX + dx, y: playerTileY + dy)
            if tile.isSwimmable {
                return true
            }
        }
        return false
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
}
