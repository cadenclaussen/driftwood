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

    @Published var joystickOffset: CGSize = .zero

    private let tileSize: CGFloat = 24
    private let movementSpeed: CGFloat = 100 // points per second
    private var gameLoopCancellable: AnyCancellable?

    init() {
        let world = World()
        let centerX = CGFloat(world.width) * tileSize / 2
        let centerY = CGFloat(world.height) * tileSize / 2
        self.world = world
        self.player = Player(startPosition: CGPoint(x: centerX, y: centerY))
    }

    func startGameLoop() {
        gameLoopCancellable = Timer.publish(every: 1.0 / 60.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updatePlayerPosition()
            }
    }

    func stopGameLoop() {
        gameLoopCancellable?.cancel()
        gameLoopCancellable = nil
    }

    private func updatePlayerPosition() {
        let maxRadius = (120.0 - 50.0) / 2 // joystick base - thumb / 2
        let distance = hypot(joystickOffset.width, joystickOffset.height)
        guard distance > 0 else { return }

        let clampedDistance = min(distance, maxRadius)
        let normalizedX = (joystickOffset.width / distance) * (clampedDistance / maxRadius)
        let normalizedY = (joystickOffset.height / distance) * (clampedDistance / maxRadius)

        let deltaTime: CGFloat = 1.0 / 60.0
        let deltaX = normalizedX * movementSpeed * deltaTime
        let deltaY = normalizedY * movementSpeed * deltaTime

        // try full movement
        let newPosition = CGPoint(
            x: player.position.x + deltaX,
            y: player.position.y + deltaY
        )

        if canMoveTo(newPosition) {
            player.position = newPosition
        } else {
            // try sliding along X axis only
            let slideX = CGPoint(x: player.position.x + deltaX, y: player.position.y)
            if canMoveTo(slideX) {
                player.position = slideX
            }
            // try sliding along Y axis only
            let slideY = CGPoint(x: player.position.x, y: player.position.y + deltaY)
            if canMoveTo(slideY) {
                player.position = slideY
            }
        }

        // face the direction of movement
        player.lookDirection = CGPoint(
            x: joystickOffset.width / distance,
            y: joystickOffset.height / distance
        )
    }

    private func canMoveTo(_ position: CGPoint) -> Bool {
        let radius = player.size / 2
        let checkPoints = [
            CGPoint(x: position.x - radius, y: position.y - radius), // top-left
            CGPoint(x: position.x + radius, y: position.y - radius), // top-right
            CGPoint(x: position.x - radius, y: position.y + radius), // bottom-left
            CGPoint(x: position.x + radius, y: position.y + radius), // bottom-right
        ]

        for point in checkPoints {
            let tileX = Int(point.x / tileSize)
            let tileY = Int(point.y / tileSize)
            let tile = world.tile(at: tileX, y: tileY)
            if !tile.isWalkable {
                return false
            }
        }
        return true
    }
}
