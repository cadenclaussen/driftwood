//
//  Player.swift
//  driftwood
//

import Foundation

enum FacingDirection: String, Codable {
    case up, down, left, right

    var spriteName: String {
        switch self {
        case .up: return "PlayerUp"
        case .down: return "PlayerDown"
        case .left: return "PlayerLeft"
        case .right: return "PlayerRight"
        }
    }

    static func from(direction: CGPoint) -> FacingDirection {
        // determine which direction has the largest component
        let absX = abs(direction.x)
        let absY = abs(direction.y)
        if absX > absY {
            return direction.x > 0 ? .right : .left
        } else {
            return direction.y > 0 ? .down : .up
        }
    }
}

struct Player {
    var position: CGPoint
    var lookDirection: CGPoint = CGPoint(x: 0, y: 1) // unit vector, default looking down
    var facingDirection: FacingDirection = .down
    let size: CGFloat = 40

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
