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

    @Published var joystickOffset: CGSize = .zero
    @Published var screenFadeOpacity: Double = 0

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
        inventoryViewModel.useMeal(at: index, player: &player)
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
            return SaveProfile(from: landPlayer, id: currentProfileIndex, inventory: inventoryViewModel.inventory)
        }
        return SaveProfile(from: player, id: currentProfileIndex, inventory: inventoryViewModel.inventory)
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

        withAnimation(.easeIn(duration: 0.3)) {
            screenFadeOpacity = 1
        }

        Task {
            try? await Task.sleep(for: .milliseconds(400))
            player.position = startPoint
            player.isSwimming = false
            player.swimStartPoint = nil
            player.health = max(0, player.health - 1)

            // save on health change
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
}
