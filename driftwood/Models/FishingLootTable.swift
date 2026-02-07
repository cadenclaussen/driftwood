//
//  FishingLootTable.swift
//  driftwood
//

import Foundation

struct FishingLootTable {

    // MARK: - Public API

    static func roll(level: Int, collectedOldPieces: Set<ArmorSlotType>, collectedMossyPieces: Set<ArmorSlotType>) -> SlotContent {
        let table = getLootTable(level: level)
        let roll = Double.random(in: 0..<100)

        var cumulative: Double = 0
        for entry in table {
            cumulative += entry.chance
            if roll < cumulative {
                return resolveItem(entry.item, collectedOldPieces: collectedOldPieces, collectedMossyPieces: collectedMossyPieces)
            }
        }

        return .resource(type: .commonFish, quantity: 1)
    }

    static func rollTreasureChest() -> Int {
        var coins = 5 // roll 1 always succeeds
        if Double.random(in: 0..<100) < 80 { coins += 2 } else { return coins }
        if Double.random(in: 0..<100) < 60 { coins += 3 } else { return coins }
        if Double.random(in: 0..<100) < 40 { coins += 2 } else { return coins }
        if Double.random(in: 0..<100) < 20 { coins += 3 } else { return coins }
        if Double.random(in: 0..<100) < 10 { coins += 5 } else { return coins }
        if Double.random(in: 0..<100) < 2 { coins += 10 }
        return coins
    }

    // MARK: - Loot Tables

    private static func getLootTable(level: Int) -> [(item: LootItem, chance: Double)] {
        switch level {
        case 1: return level1Table
        case 2: return level2Table
        case 3: return level3Table
        case 4: return level4Table
        case 5: return level5Table
        case 6: return level6Table
        case 7: return level7Table
        case 8: return level8Table
        case 9: return level9Table
        case 10: return level10Table
        default: return level1Table
        }
    }

    private static let level1Table: [(item: LootItem, chance: Double)] = [
        (.resource(.commonFish), 80),
        (.resource(.wood), 20),
    ]

    private static let level2Table: [(item: LootItem, chance: Double)] = [
        (.resource(.commonFish), 70),
        (.resource(.wood), 20),
        (.resource(.seaweed), 10),
    ]

    private static let level3Table: [(item: LootItem, chance: Double)] = [
        (.resource(.commonFish), 60),
        (.oldSet, 16),
        (.resource(.seaweed), 14),
        (.resource(.wood), 10),
    ]

    private static let level4Table: [(item: LootItem, chance: Double)] = [
        (.resource(.commonFish), 50),
        (.oldSet, 16),
        (.resource(.seaweed), 14),
        (.resource(.wood), 10),
        (.resource(.overgrownCoin), 5),
        (.resource(.sharkTooth), 5),
    ]

    private static let level5Table: [(item: LootItem, chance: Double)] = [
        (.resource(.commonFish), 50),
        (.resource(.seaweed), 14),
        (.resource(.wood), 10),
        (.oldSet, 8),
        (.resource(.overgrownCoin), 5),
        (.resource(.sharkTooth), 5),
        (.resource(.scale), 4),
        (.resource(.brokenWheel), 4),
    ]

    private static let level6Table: [(item: LootItem, chance: Double)] = [
        (.resource(.commonFish), 50),
        (.resource(.metalScrap), 10),
        (.oldSet, 8),
        (.resource(.seaweed), 8),
        (.resource(.overgrownCoin), 8),
        (.resource(.sharkTooth), 8),
        (.resource(.brokenWheel), 8),
    ]

    private static let level7Table: [(item: LootItem, chance: Double)] = [
        (.resource(.commonFish), 50),
        (.oldSet, 8),
        (.resource(.seaweed), 8),
        (.resource(.overgrownCoin), 8),
        (.resource(.sharkTooth), 8),
        (.resource(.wire), 4),
        (.resource(.plastic), 4),
        (.resource(.sailorsJournal), 4),
        (.resource(.metalScrap), 4),
        (.resource(.rainbowFish), 2),
    ]

    private static let level8Table: [(item: LootItem, chance: Double)] = [
        (.resource(.commonFish), 49.99),
        (.mossySet, 8),
        (.resource(.seaweed), 8),
        (.resource(.overgrownCoin), 8),
        (.resource(.sharkTooth), 8),
        (.oldSet, 4),
        (.resource(.wire), 4),
        (.resource(.platinumScraps), 4),
        (.resource(.rainbowFish), 2),
        (.resource(.plastic), 2),
        (.resource(.sailorsJournal), 2),
        (.resource(.messageInBottle), 0.01),
    ]

    private static let level9Table: [(item: LootItem, chance: Double)] = [
        (.resource(.commonFish), 49.95),
        (.mossySet, 8),
        (.resource(.seaweed), 8),
        (.resource(.overgrownCoin), 8),
        (.resource(.sharkTooth), 8),
        (.oldSet, 4),
        (.treasureChest, 4),
        (.resource(.wire), 4),
        (.resource(.rainbowFish), 2),
        (.resource(.platinumScraps), 2),
        (.resource(.plastic), 1),
        (.resource(.sailorsJournal), 1),
        (.resource(.messageInBottle), 0.05),
    ]

    private static let level10Table: [(item: LootItem, chance: Double)] = [
        (.resource(.commonFish), 45),
        (.resource(.seaweed), 8),
        (.resource(.overgrownCoin), 8),
        (.resource(.sharkTooth), 8),
        (.resource(.messageInBottle), 5),
        (.oldSet, 4),
        (.mossySet, 4),
        (.treasureChest, 4),
        (.resource(.wire), 4),
        (.resource(.theOldOne), 2),
        (.resource(.rainbowFish), 2),
        (.resource(.platinumScraps), 2),
        (.resource(.timeLocket), 2),
        (.resource(.moonFragment), 1),
        (.resource(.sunFragment), 1),
        (.resource(.plastic), 1),
        (.resource(.sailorsJournal), 1),
    ]

    // MARK: - Item Resolution

    private static func resolveItem(_ item: LootItem, collectedOldPieces: Set<ArmorSlotType>, collectedMossyPieces: Set<ArmorSlotType>) -> SlotContent {
        switch item {
        case .resource(let type):
            return .resource(type: type, quantity: 1)
        case .oldSet:
            return resolveArmorSet(.old, collected: collectedOldPieces)
        case .mossySet:
            return resolveArmorSet(.mossy, collected: collectedMossyPieces)
        case .treasureChest:
            let coins = rollTreasureChest()
            return .resource(type: .overgrownCoin, quantity: coins)
        }
    }

    private static func resolveArmorSet(_ setType: ArmorSetType, collected: Set<ArmorSlotType>) -> SlotContent {
        let uncollected = ArmorSlotType.allCases.filter { !collected.contains($0) }

        if uncollected.isEmpty {
            return .resource(type: .leatherScrap, quantity: 1)
        }

        let slot = uncollected.randomElement()!
        let piece = ArmorPiece(slot: slot, setType: setType)
        return .armor(piece: piece)
    }
}

// MARK: - Loot Item Type

private enum LootItem {
    case resource(ResourceType)
    case oldSet
    case mossySet
    case treasureChest
}
