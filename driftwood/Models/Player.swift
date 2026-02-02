//
//  Player.swift
//  driftwood
//

import Foundation

struct Player {
    var position: CGPoint
    var lookDirection: CGPoint = CGPoint(x: 1, y: 0) // unit vector, default looking right
    let size: CGFloat = 12 // half of 24pt tile

    // health system
    var health: Int = 5
    let maxHealth: Int = 5

    // stamina system
    var stamina: CGFloat = 100
    let maxStamina: CGFloat = 100
    let staminaRegenRate: CGFloat = 20 // full bar (100) in 5 seconds

    // magic system
    var magic: CGFloat = 100
    let maxMagic: CGFloat = 100

    // sprinting
    var isSprinting: Bool = false
    let sprintSpeedMultiplier: CGFloat = 2.0

    // tools
    var equippedTool: ToolType? = nil

    // swimming
    var isSwimming: Bool = false
    var swimStartPoint: CGPoint? = nil
    let swimSpeedMultiplier: CGFloat = 0.5 // half of walk speed
    let swimStaminaDrainRate: CGFloat = 12 // base drain while swimming
    let swimSprintStaminaDrainRate: CGFloat = 25 // drain while sprint-swimming

    init(startPosition: CGPoint) {
        self.position = startPosition
    }
}
