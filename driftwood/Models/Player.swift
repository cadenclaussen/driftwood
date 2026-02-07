//
//  Player.swift
//  driftwood
//

import Foundation

enum FacingDirection: String, Codable {
    case up, down, left, right

    var idleSpriteName: String {
        switch self {
        case .up: return "LookUp"
        case .down: return "LookDown"
        case .left: return "LookLeft"
        case .right: return "LookRight"
        }
    }

    var walkSpriteName: String {
        switch self {
        case .up: return "WalkUp1"
        case .down: return "WalkDown1"
        case .left: return "WalkLeft1"
        case .right: return "WalkRight1"
        }
    }

    func attackSpriteName(frame: Int) -> String? {
        switch self {
        case .up: return "SwordSwingUp\(frame)"
        case .down, .left, .right: return nil // not yet implemented
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
    let size: CGFloat = 32

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

    // walking state
    var isWalking: Bool = false

    // attack animation
    var isAttacking: Bool = false
    var attackAnimationFrame: Int = 0
    var attackAnimationTime: CGFloat = 0
    static let attackFrameDuration: CGFloat = 0.03 // 30ms per frame
    static let attackFrameCount: Int = 12

    // swimming
    var isSwimming: Bool = false
    var swimStartPoint: CGPoint? = nil
    let swimSpeedMultiplier: CGFloat = 0.5 // half of walk speed
    let swimStaminaDrainRate: CGFloat = 12 // base drain while swimming
    let swimSprintStaminaDrainRate: CGFloat = 25 // drain while sprint-swimming

    // sailing
    var isSailing: Bool = false
    let sailingSpeedMultiplier: CGFloat = 3.0 // 3x swim speed = 1.5x walk speed

    init(startPosition: CGPoint) {
        self.position = startPosition
    }
}
