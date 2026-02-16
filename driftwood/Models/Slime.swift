//
//  Slime.swift
//  driftwood
//

import CoreGraphics
import Foundation

enum SlimeAIState {
    case patrol(target: CGPoint)
    case chase
    case returning
}

struct Slime: Identifiable {
    let id: Int // 0, 1, 2 — stable for save persistence
    var position: CGPoint
    let spawnOrigin: CGPoint
    var health: Int = Slime.maxHealth
    var isAlive: Bool = true
    var aiState: SlimeAIState = .patrol(target: .zero)
    var patrolPauseTimer: CGFloat = 0
    var hitCooldown: Int = -1 // attackSwingId that last hit this slime
    var hitFlashTimer: CGFloat = 0

    static let size: CGFloat = 24
    static let halfSize: CGFloat = 12
    static let maxHealth: Int = 2
    static let patrolSpeed: CGFloat = 40 // ~40% of player walk speed
    static let chaseSpeed: CGFloat = 65 // ~65% of player walk speed
    static let patrolRadius: CGFloat = 120 // 5 tiles * 24px
    static let chaseRadius: CGFloat = 192 // 8 tiles * 24px
    static let knockbackDistance: CGFloat = 40
    static let contactDamage: Int = 1 // 1 HP = 1 full heart
    static let hitFlashDuration: CGFloat = 0.15

    var collisionRect: CGRect {
        CGRect(
            x: position.x - Slime.halfSize,
            y: position.y - Slime.halfSize,
            width: Slime.size,
            height: Slime.size
        )
    }

    func toSaveData() -> SlimeSaveData {
        SlimeSaveData(
            id: id,
            position: CodablePoint(position),
            health: health,
            isAlive: isAlive
        )
    }
}

struct SlimeSaveData: Codable {
    let id: Int
    let position: CodablePoint
    let health: Int
    let isAlive: Bool
}

struct SlimeDeathEffect: Identifiable {
    let id = UUID()
    let position: CGPoint
    var elapsed: CGFloat = 0
    static let duration: CGFloat = 0.4
}
