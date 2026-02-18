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

    func attackSpriteName(frame: Int, tool: ToolType?) -> String? {
        // all directions use same sprites; view applies transforms
        let prefix: String
        switch tool {
        case .axe:
            prefix = "AxeSwingUp"
        case .sword, .fishingRod, nil:
            prefix = "SwordSwingUp"
        }
        return "\(prefix)\(frame)"
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

    // health system (1 unit = 1 full heart, 5 = 5 hearts)
    var health: Int = 5
    let maxHealth: Int = 5

    // stamina system
    var stamina: CGFloat = 100
    let maxStamina: CGFloat = 100
    let staminaRegenRate: CGFloat = 20 // full bar (100) in 5 seconds

    // magic system
    var mp: CGFloat = 50
    let baseMaxMp: CGFloat = 50

    // dash state
    var isDashing: Bool = false
    static let dashDuration: CGFloat = 0.1

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
    var attackSwingId: Int = 0 // increments each swing, used for hit-once-per-swing tracking
    var currentSwingDamage: Int = 1 // base damage, can be multiplied by charge
    var isChargedAttack: Bool = false // true if this swing is from a charged attack (AoE)
    static let attackFrameDuration: CGFloat = 0.03 // 30ms per frame
    static let attackFrameCount: Int = 12

    // invincibility frames (after taking enemy damage or during dash)
    var invincibilityTimer: CGFloat = 0
    var isInvincible: Bool { invincibilityTimer > 0 || isDashing }
    static let invincibilityDuration: CGFloat = 0.5

    // swimming
    var isSwimming: Bool = false
    var swimStartPoint: CGPoint? = nil
    let swimSpeedMultiplier: CGFloat = 0.5 // half of walk speed
    let swimStaminaDrainRate: CGFloat = 12 // base drain while swimming
    let swimSprintStaminaDrainRate: CGFloat = 25 // drain while sprint-swimming

    // sailing
    var isSailing: Bool = false
    var sailingBoardPosition: CGPoint? = nil // where player boarded from (for save/respawn)
    let sailingSpeedMultiplier: CGFloat = 3.0 // 3x swim speed = 1.5x walk speed

    // block state
    var isBlocking: Bool = false
    var blockStartTime: TimeInterval = 0
    var blockCooldownTimer: CGFloat = 0

    // charge state
    var isCharging: Bool = false
    var chargeStartTime: TimeInterval = 0
    var chargeProgress: CGFloat = 0 // 0.0 to 1.0

    // block/charge constants
    static let blockDuration: CGFloat = 0.6
    static let parryWindow: CGFloat = 0.15
    static let blockCooldown: CGFloat = 0.3
    static let chargeTime: CGFloat = 1.0
    static let maxChargeDamageMultiplier: CGFloat = 2.0
    static let chargingMoveSpeedMultiplier: CGFloat = 0.5

    init(startPosition: CGPoint) {
        self.position = startPosition
    }
}
