//
//  Recipe.swift
//  driftwood
//

import Foundation

struct CraftingMaterial {
    let resource: ResourceType
    let quantity: Int
}

enum CraftResult {
    case collectible(SlotContent)
    case toolUpgrade(ToolType, tier: Int)
    case majorUpgrade(MajorUpgradeType)

    var displayName: String {
        switch self {
        case .collectible(let content):
            return content.displayName
        case .toolUpgrade(let tool, _):
            return tool.displayName
        case .majorUpgrade(let upgrade):
            return upgrade.displayName
        }
    }

    var iconName: String {
        switch self {
        case .collectible(let content):
            return content.iconName
        case .toolUpgrade(let tool, _):
            return tool.iconName
        case .majorUpgrade(let upgrade):
            return upgrade.iconName
        }
    }

    var usesCustomImage: Bool {
        switch self {
        case .collectible(let content):
            return content.usesCustomImage
        case .toolUpgrade(let tool, _):
            return tool.usesCustomImage
        case .majorUpgrade:
            return false
        }
    }
}

struct Recipe: Identifiable {
    let id: String
    let name: String
    let result: CraftResult
    let materials: [CraftingMaterial]
    let unlocksAfter: ResourceType // recipe unlocks after obtaining this resource

    static var allRecipes: [Recipe] {
        [
            // basic processing
            Recipe(
                id: "plantFiber",
                name: "Plant Fiber",
                result: .collectible(.resource(type: .plantFiber, quantity: 1)),
                materials: [
                    CraftingMaterial(resource: .seaweed, quantity: 5)
                ],
                unlocksAfter: .seaweed
            ),
            Recipe(
                id: "string",
                name: "String",
                result: .collectible(.resource(type: .string, quantity: 1)),
                materials: [
                    CraftingMaterial(resource: .plantFiber, quantity: 2)
                ],
                unlocksAfter: .plantFiber
            ),
            Recipe(
                id: "cotton",
                name: "Cotton",
                result: .collectible(.resource(type: .cotton, quantity: 1)),
                materials: [
                    CraftingMaterial(resource: .string, quantity: 4)
                ],
                unlocksAfter: .string
            ),
            // tools
            Recipe(
                id: "sword",
                name: "Sword",
                result: .toolUpgrade(.sword, tier: 1),
                materials: [
                    CraftingMaterial(resource: .wood, quantity: 2),
                    CraftingMaterial(resource: .string, quantity: 1),
                    CraftingMaterial(resource: .sharkTooth, quantity: 4)
                ],
                unlocksAfter: .sharkTooth
            ),
            Recipe(
                id: "axe",
                name: "Axe",
                result: .toolUpgrade(.axe, tier: 1),
                materials: [
                    CraftingMaterial(resource: .wood, quantity: 2),
                    CraftingMaterial(resource: .string, quantity: 1),
                    CraftingMaterial(resource: .sharkTooth, quantity: 4)
                ],
                unlocksAfter: .sharkTooth
            ),
            // components
            Recipe(
                id: "wheel",
                name: "Wheel",
                result: .collectible(.resource(type: .wheel, quantity: 1)),
                materials: [
                    CraftingMaterial(resource: .brokenWheel, quantity: 1),
                    CraftingMaterial(resource: .wood, quantity: 1)
                ],
                unlocksAfter: .brokenWheel
            ),
            Recipe(
                id: "sail",
                name: "Sail",
                result: .collectible(.resource(type: .sail, quantity: 1)),
                materials: [
                    CraftingMaterial(resource: .cotton, quantity: 5),
                    CraftingMaterial(resource: .metalScrap, quantity: 5)
                ],
                unlocksAfter: .cotton
            ),
            // major upgrades
            Recipe(
                id: "sailboat",
                name: "Sailboat",
                result: .majorUpgrade(.sailboat),
                materials: [
                    CraftingMaterial(resource: .sail, quantity: 1),
                    CraftingMaterial(resource: .wheel, quantity: 1),
                    CraftingMaterial(resource: .metalScrap, quantity: 20),
                    CraftingMaterial(resource: .wood, quantity: 10)
                ],
                unlocksAfter: .sail
            )
        ]
    }
}
