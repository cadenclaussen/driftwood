//
//  Inventory.swift
//  driftwood
//

import Foundation

// MARK: - Gear Inventory

struct GearInventory: Codable, Equatable {
    var sailsTier: Int = 0 // 0-4
    var hasMotor: Bool = false
    var pouchTier: Int = 0 // 0-3

    func tier(for gear: GearType) -> Int {
        switch gear {
        case .sails: return sailsTier
        case .motor: return hasMotor ? 1 : 0
        case .pouch: return pouchTier
        }
    }

    mutating func setTier(_ tier: Int, for gear: GearType) {
        switch gear {
        case .sails: sailsTier = min(tier, 4)
        case .motor: hasMotor = tier > 0
        case .pouch: pouchTier = min(tier, 3)
        }
    }
}

// MARK: - Tool Inventory

struct ToolInventory: Codable, Equatable {
    var fishingRodTier: Int = 0 // 0-4
    var swordTier: Int = 0 // 0-3
    var axeTier: Int = 0 // 0-3
    var hasWand: Bool = false

    func tier(for tool: ToolType) -> Int {
        switch tool {
        case .fishingRod: return fishingRodTier
        case .sword: return swordTier
        case .axe: return axeTier
        case .wand: return hasWand ? 1 : 0
        }
    }

    mutating func setTier(_ tier: Int, for tool: ToolType) {
        switch tool {
        case .fishingRod: fishingRodTier = min(tier, 4)
        case .sword: swordTier = min(tier, 3)
        case .axe: axeTier = min(tier, 3)
        case .wand: hasWand = tier > 0
        }
    }

    var fishingFortune: Int {
        switch fishingRodTier {
        case 0: return 0
        case 1: return 20
        case 2: return 50
        case 3: return 90
        default: return 90
        }
    }
}

// MARK: - Equipment Slots

struct EquipmentSlots: Codable, Equatable {
    var hat: ArmorPiece?
    var shirt: ArmorPiece?
    var pants: ArmorPiece?
    var boots: ArmorPiece?

    func piece(for slot: ArmorSlotType) -> ArmorPiece? {
        switch slot {
        case .hat: return hat
        case .shirt: return shirt
        case .pants: return pants
        case .boots: return boots
        }
    }

    mutating func equip(_ piece: ArmorPiece?) -> ArmorPiece? {
        guard let piece = piece else { return nil }
        let old = self.piece(for: piece.slot)
        switch piece.slot {
        case .hat: hat = piece
        case .shirt: shirt = piece
        case .pants: pants = piece
        case .boots: boots = piece
        }
        return old
    }

    mutating func unequip(_ slot: ArmorSlotType) -> ArmorPiece? {
        let old = piece(for: slot)
        switch slot {
        case .hat: hat = nil
        case .shirt: shirt = nil
        case .pants: pants = nil
        case .boots: boots = nil
        }
        return old
    }

    var totalStats: ArmorStats {
        var stats = ArmorStats.zero
        if let hat = hat { stats = stats + hat.stats }
        if let shirt = shirt { stats = stats + shirt.stats }
        if let pants = pants { stats = stats + pants.stats }
        if let boots = boots { stats = stats + boots.stats }
        return stats
    }

    var allPieces: [ArmorPiece] {
        [hat, shirt, pants, boots].compactMap { $0 }
    }
}

// MARK: - Accessory Slots

struct AccessorySlots: Codable, Equatable {
    var anklet: Accessory?
    var ring: Accessory?
    var chain: Accessory?
    var bracelet: Accessory?

    func accessory(for slot: AccessorySlotType) -> Accessory? {
        switch slot {
        case .anklet: return anklet
        case .ring: return ring
        case .chain: return chain
        case .bracelet: return bracelet
        }
    }

    mutating func equip(_ accessory: Accessory?) -> Accessory? {
        guard let accessory = accessory else { return nil }
        let old = self.accessory(for: accessory.slot)
        switch accessory.slot {
        case .anklet: anklet = accessory
        case .ring: ring = accessory
        case .chain: chain = accessory
        case .bracelet: bracelet = accessory
        }
        return old
    }

    mutating func unequip(_ slot: AccessorySlotType) -> Accessory? {
        let old = accessory(for: slot)
        switch slot {
        case .anklet: anklet = nil
        case .ring: ring = nil
        case .chain: chain = nil
        case .bracelet: bracelet = nil
        }
        return old
    }

    var totalStats: AccessoryStats {
        var stats = AccessoryStats.zero
        if let anklet = anklet { stats = stats + anklet.stats }
        if let ring = ring { stats = stats + ring.stats }
        if let chain = chain { stats = stats + chain.stats }
        if let bracelet = bracelet { stats = stats + bracelet.stats }
        return stats
    }

    var allAccessories: [Accessory] {
        [anklet, ring, chain, bracelet].compactMap { $0 }
    }
}

// MARK: - Major Upgrades

struct MajorUpgrades: Codable, Equatable {
    var hasSailboat: Bool = false
    var hasFlippers: Bool = false
    var hasWings: Bool = false
    var hasPegasusBoots: Bool = false

    func has(_ upgrade: MajorUpgradeType) -> Bool {
        switch upgrade {
        case .sailboat: return hasSailboat
        case .flippers: return hasFlippers
        case .wings: return hasWings
        case .pegasusBoots: return hasPegasusBoots
        }
    }

    mutating func unlock(_ upgrade: MajorUpgradeType) {
        switch upgrade {
        case .sailboat: hasSailboat = true
        case .flippers: hasFlippers = true
        case .wings: hasWings = true
        case .pegasusBoots: hasPegasusBoots = true
        }
    }
}

// MARK: - Inventory

struct Inventory: Codable, Equatable {
    var gear: GearInventory
    var tools: ToolInventory
    var collectibles: [CollectibleSlot]
    var equipment: EquipmentSlots
    var accessories: AccessorySlots
    var majorUpgrades: MajorUpgrades

    static let mealSlotCount = 5
    static let totalSlotCount = 30

    static func empty() -> Inventory {
        Inventory(
            gear: GearInventory(),
            tools: ToolInventory(),
            collectibles: (0..<totalSlotCount).map { _ in CollectibleSlot() },
            equipment: EquipmentSlots(),
            accessories: AccessorySlots(),
            majorUpgrades: MajorUpgrades()
        )
    }

    var mealSlots: ArraySlice<CollectibleSlot> {
        collectibles[0..<Inventory.mealSlotCount]
    }

    var resourceSlots: ArraySlice<CollectibleSlot> {
        collectibles[Inventory.mealSlotCount..<Inventory.totalSlotCount]
    }

    var mealCount: Int {
        mealSlots.filter { $0.content?.isMeal == true }.count
    }

    var totalFishingFortune: Int {
        tools.fishingFortune + equipment.totalStats.fishingFortune + accessories.totalStats.fishingFortune
    }
}
