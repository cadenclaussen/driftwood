//
//  ItemType.swift
//  driftwood
//

import Foundation

// MARK: - Gear

enum GearType: String, Codable, CaseIterable {
    case sails
    case motor
    case pouch

    var displayName: String {
        switch self {
        case .sails: return "Sails"
        case .motor: return "Motor"
        case .pouch: return "Pouch"
        }
    }

    var iconName: String {
        switch self {
        case .sails: return "Sail"
        case .motor: return "engine.combustion"
        case .pouch: return "bag"
        }
    }

    var usesCustomImage: Bool {
        switch self {
        case .sails: return true
        case .motor, .pouch: return false
        }
    }

    var maxTier: Int {
        switch self {
        case .sails: return 4
        case .motor: return 1
        case .pouch: return 3
        }
    }
}

// MARK: - Tools

enum ToolType: String, Codable, CaseIterable {
    case fishingRod
    case sword
    case axe
    case wand

    var displayName: String {
        switch self {
        case .fishingRod: return "Fishing Rod"
        case .sword: return "Sword"
        case .axe: return "Axe"
        case .wand: return "Wand"
        }
    }

    var iconName: String {
        switch self {
        case .fishingRod: return "FishingRod"
        case .sword: return "Sword"
        case .axe: return "Axe"
        case .wand: return "wand.and.stars"
        }
    }

    var usesCustomImage: Bool {
        switch self {
        case .fishingRod, .sword, .axe: return true
        case .wand: return false
        }
    }

    var maxTier: Int {
        switch self {
        case .fishingRod: return 4
        case .sword: return 3
        case .axe: return 3
        case .wand: return 1
        }
    }
}

// MARK: - Resources

enum ResourceType: String, Codable, CaseIterable {
    // general
    case wood
    case metalScrap
    case cloth
    case oil

    // fishing resources
    case commonFish
    case rareFish
    case rainbowFish
    case driftwood
    case seaweed
    case overgrownCoin
    case sharkTooth
    case scale
    case brokenWheel
    case wire
    case plastic
    case sailorsJournal
    case platinumScraps
    case messageInBottle
    case theOldOne
    case timeLocket
    case moonFragment
    case sunFragment
    case leatherScrap
    case wheel

    var displayName: String {
        switch self {
        case .wood: return "Wood"
        case .metalScrap: return "Metal Scrap"
        case .cloth: return "Cloth"
        case .oil: return "Oil"
        case .commonFish: return "Fish"
        case .rareFish: return "Rare Fish"
        case .rainbowFish: return "Rainbow Fish"
        case .driftwood: return "Driftwood"
        case .seaweed: return "Seaweed"
        case .overgrownCoin: return "Overgrown Coin"
        case .sharkTooth: return "Shark Tooth"
        case .scale: return "Scale"
        case .brokenWheel: return "Broken Wheel"
        case .wire: return "Wire"
        case .plastic: return "Plastic"
        case .sailorsJournal: return "Sailor's Journal"
        case .platinumScraps: return "Platinum Scraps"
        case .messageInBottle: return "Message in a Bottle"
        case .theOldOne: return "The Old One"
        case .timeLocket: return "Time Locket"
        case .moonFragment: return "Moon Fragment"
        case .sunFragment: return "Sun Fragment"
        case .leatherScrap: return "Leather Scrap"
        case .wheel: return "Wheel"
        }
    }

    var iconName: String {
        switch self {
        case .wood: return "Wood"
        case .metalScrap: return "gearshape"
        case .cloth: return "tshirt"
        case .oil: return "drop.fill"
        case .commonFish: return "Fish"
        case .rareFish: return "Fish"
        case .rainbowFish: return "sparkles"
        case .driftwood: return "Wood"
        case .seaweed: return "Seaweed"
        case .overgrownCoin: return "OvergrownCoin"
        case .sharkTooth: return "SharkTooth"
        case .scale: return "Scale"
        case .brokenWheel: return "BrokenWheel"
        case .wire: return "cable.connector"
        case .plastic: return "cube"
        case .sailorsJournal: return "book.closed"
        case .platinumScraps: return "diamond"
        case .messageInBottle: return "envelope"
        case .theOldOne: return "Fish"
        case .timeLocket: return "clock"
        case .moonFragment: return "moon.fill"
        case .sunFragment: return "sun.max.fill"
        case .leatherScrap: return "LeatherScrap"
        case .wheel: return "Wheel"
        }
    }

    var usesCustomImage: Bool {
        switch self {
        case .commonFish, .rareFish, .theOldOne, .wood, .driftwood, .seaweed, .leatherScrap, .overgrownCoin, .sharkTooth, .scale, .brokenWheel, .wheel: return true
        default: return false
        }
    }

    var isStackable: Bool { true }

    var rarity: ItemRarity {
        switch self {
        case .wood, .cloth, .driftwood, .seaweed, .leatherScrap, .commonFish:
            return .common
        case .metalScrap, .oil, .overgrownCoin, .sharkTooth, .scale, .wire, .plastic:
            return .uncommon
        case .rareFish, .sailorsJournal, .platinumScraps, .brokenWheel, .wheel:
            return .rare
        case .rainbowFish, .messageInBottle, .theOldOne, .timeLocket, .moonFragment, .sunFragment:
            return .epic
        }
    }
}

// MARK: - Food Ingredients

enum FoodIngredientType: String, Codable, CaseIterable {
    case apple
    case carrot
    case mushroom
    case herb

    var displayName: String {
        switch self {
        case .apple: return "Apple"
        case .carrot: return "Carrot"
        case .mushroom: return "Mushroom"
        case .herb: return "Herb"
        }
    }

    var iconName: String {
        switch self {
        case .apple: return "apple.logo"
        case .carrot: return "carrot"
        case .mushroom: return "leaf"
        case .herb: return "leaf.fill"
        }
    }

    var isStackable: Bool { false }

    var rarity: ItemRarity { .common }
}

// MARK: - Meals

enum MealType: String, Codable, CaseIterable {
    case basicMeal
    case heartMeal
    case staminaMeal

    var displayName: String {
        switch self {
        case .basicMeal: return "Basic Meal"
        case .heartMeal: return "Heart Meal"
        case .staminaMeal: return "Stamina Meal"
        }
    }

    var iconName: String {
        switch self {
        case .basicMeal: return "fork.knife"
        case .heartMeal: return "heart.circle.fill"
        case .staminaMeal: return "bolt.circle.fill"
        }
    }

    var healAmount: Int {
        switch self {
        case .basicMeal: return 2
        case .heartMeal: return 3
        case .staminaMeal: return 1
        }
    }

    var rarity: ItemRarity {
        switch self {
        case .basicMeal: return .common
        case .heartMeal: return .uncommon
        case .staminaMeal: return .uncommon
        }
    }
}

// MARK: - Armor

enum ArmorSlotType: String, Codable, CaseIterable {
    case hat
    case shirt
    case pants
    case boots

    var displayName: String {
        switch self {
        case .hat: return "Hat"
        case .shirt: return "Shirt"
        case .pants: return "Pants"
        case .boots: return "Boots"
        }
    }

    var iconName: String {
        switch self {
        case .hat: return "hat.widebrim"
        case .shirt: return "tshirt"
        case .pants: return "figure.walk"
        case .boots: return "shoe"
        }
    }
}

enum ArmorSetType: String, Codable, CaseIterable {
    case old
    case mossy
    case magic
    case melee
    case movement

    var displayName: String {
        switch self {
        case .old: return "Old Set"
        case .mossy: return "Mossy Set"
        case .magic: return "Magic Set"
        case .melee: return "Melee Set"
        case .movement: return "Movement Set"
        }
    }

    var rarity: ItemRarity {
        switch self {
        case .old: return .uncommon
        case .mossy: return .epic
        case .magic: return .rare
        case .melee: return .rare
        case .movement: return .uncommon
        }
    }
}

// MARK: - Accessories

enum AccessorySlotType: String, Codable, CaseIterable {
    case anklet
    case ring
    case chain
    case bracelet

    var displayName: String {
        switch self {
        case .anklet: return "Anklet"
        case .ring: return "Ring"
        case .chain: return "Chain"
        case .bracelet: return "Bracelet"
        }
    }

    var iconName: String {
        switch self {
        case .anklet: return "figure.walk"
        case .ring: return "circle.circle"
        case .chain: return "link"
        case .bracelet: return "lasso"
        }
    }
}

// MARK: - Major Upgrades

enum MajorUpgradeType: String, Codable, CaseIterable {
    case sailboat
    case flippers
    case wings
    case pegasusBoots

    var displayName: String {
        switch self {
        case .sailboat: return "Sailboat"
        case .flippers: return "Flippers"
        case .wings: return "Wings"
        case .pegasusBoots: return "Pegasus Boots"
        }
    }

    var iconName: String {
        switch self {
        case .sailboat: return "sailboat"
        case .flippers: return "figure.pool.swim"
        case .wings: return "bird"
        case .pegasusBoots: return "hare"
        }
    }
}

// MARK: - Rarity

enum ItemRarity: String, Codable, CaseIterable, Comparable {
    case common
    case uncommon
    case rare
    case epic

    var displayName: String {
        rawValue.capitalized
    }

    var sortOrder: Int {
        switch self {
        case .common: return 0
        case .uncommon: return 1
        case .rare: return 2
        case .epic: return 3
        }
    }

    static func < (lhs: ItemRarity, rhs: ItemRarity) -> Bool {
        lhs.sortOrder < rhs.sortOrder
    }
}
