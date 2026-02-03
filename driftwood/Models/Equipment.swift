//
//  Equipment.swift
//  driftwood
//

import Foundation

// MARK: - Armor Stats

struct ArmorStats: Codable, Equatable {
    var bonusHearts: CGFloat = 0
    var fishingFortune: Int = 0
    var defense: Int = 0
    var magicRegen: CGFloat = 0
    var movementSpeed: CGFloat = 0

    static func + (lhs: ArmorStats, rhs: ArmorStats) -> ArmorStats {
        ArmorStats(
            bonusHearts: lhs.bonusHearts + rhs.bonusHearts,
            fishingFortune: lhs.fishingFortune + rhs.fishingFortune,
            defense: lhs.defense + rhs.defense,
            magicRegen: lhs.magicRegen + rhs.magicRegen,
            movementSpeed: lhs.movementSpeed + rhs.movementSpeed
        )
    }

    static let zero = ArmorStats()
}

// MARK: - Armor Piece

struct ArmorPiece: Codable, Identifiable, Equatable {
    let id: UUID
    let slot: ArmorSlotType
    let setType: ArmorSetType

    var stats: ArmorStats {
        switch setType {
        case .old:
            return ArmorStats(bonusHearts: 0.5, fishingFortune: 5)
        case .mossy:
            return ArmorStats(bonusHearts: 1.0, fishingFortune: 20)
        case .magic:
            return ArmorStats(defense: 1, magicRegen: 0.5)
        case .melee:
            return ArmorStats(bonusHearts: 0.5, defense: 2)
        case .movement:
            return ArmorStats(movementSpeed: 0.1)
        }
    }

    var displayName: String {
        "\(setType.displayName) \(slot.displayName)"
    }

    var iconName: String {
        if usesCustomImage {
            switch (setType, slot) {
            case (.old, .hat): return "OldHat"
            case (.old, .shirt): return "OldShirt"
            case (.old, .pants): return "OldPants"
            case (.old, .boots): return "OldBoots"
            default: return slot.iconName
            }
        }
        return slot.iconName
    }

    var usesCustomImage: Bool {
        switch (setType, slot) {
        case (.old, .hat), (.old, .shirt), (.old, .pants), (.old, .boots): return true
        default: return false
        }
    }

    var rarity: ItemRarity {
        setType.rarity
    }

    init(slot: ArmorSlotType, setType: ArmorSetType) {
        self.id = UUID()
        self.slot = slot
        self.setType = setType
    }

    init(id: UUID, slot: ArmorSlotType, setType: ArmorSetType) {
        self.id = id
        self.slot = slot
        self.setType = setType
    }

    static func create(slot: ArmorSlotType, setType: ArmorSetType) -> ArmorPiece {
        ArmorPiece(slot: slot, setType: setType)
    }
}

// MARK: - Accessory

struct Accessory: Codable, Identifiable, Equatable {
    let id: UUID
    let slot: AccessorySlotType
    var tier: Int // 1-5

    var displayName: String {
        "\(slot.displayName) (Tier \(tier))"
    }

    var iconName: String {
        slot.iconName
    }

    var rarity: ItemRarity {
        switch tier {
        case 1: return .common
        case 2: return .uncommon
        case 3: return .rare
        case 4, 5: return .epic
        default: return .common
        }
    }

    var stats: AccessoryStats {
        let multiplier = CGFloat(tier)
        switch slot {
        case .anklet:
            return AccessoryStats(movementSpeed: 0.05 * multiplier, bonusHealth: 0.2 * multiplier)
        case .ring:
            return AccessoryStats(maxMP: 10 * multiplier, mpRegen: 0.1 * multiplier)
        case .chain:
            return AccessoryStats(bonusHealth: 0.5 * multiplier, defense: Int(multiplier))
        case .bracelet:
            return AccessoryStats(fishingFortune: Int(5 * multiplier))
        }
    }

    init(slot: AccessorySlotType, tier: Int) {
        self.id = UUID()
        self.slot = slot
        self.tier = min(max(tier, 1), 5)
    }

    init(id: UUID, slot: AccessorySlotType, tier: Int) {
        self.id = id
        self.slot = slot
        self.tier = min(max(tier, 1), 5)
    }
}

// MARK: - Accessory Stats

struct AccessoryStats: Codable, Equatable {
    var movementSpeed: CGFloat = 0
    var bonusHealth: CGFloat = 0
    var maxMP: CGFloat = 0
    var mpRegen: CGFloat = 0
    var defense: Int = 0
    var fishingFortune: Int = 0

    static func + (lhs: AccessoryStats, rhs: AccessoryStats) -> AccessoryStats {
        AccessoryStats(
            movementSpeed: lhs.movementSpeed + rhs.movementSpeed,
            bonusHealth: lhs.bonusHealth + rhs.bonusHealth,
            maxMP: lhs.maxMP + rhs.maxMP,
            mpRegen: lhs.mpRegen + rhs.mpRegen,
            defense: lhs.defense + rhs.defense,
            fishingFortune: lhs.fishingFortune + rhs.fishingFortune
        )
    }

    static let zero = AccessoryStats()
}
