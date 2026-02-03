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

    var displayName: String {
        switch self {
        case .collectible(let content):
            return content.displayName
        case .toolUpgrade(let tool, _):
            return tool.displayName
        }
    }

    var iconName: String {
        switch self {
        case .collectible(let content):
            return content.iconName
        case .toolUpgrade(let tool, _):
            return tool.iconName
        }
    }

    var usesCustomImage: Bool {
        switch self {
        case .collectible(let content):
            return content.usesCustomImage
        case .toolUpgrade(let tool, _):
            return tool.usesCustomImage
        }
    }
}

struct Recipe: Identifiable {
    let id: String
    let name: String
    let result: CraftResult
    let materials: [CraftingMaterial]

    static var allRecipes: [Recipe] {
        [
            Recipe(
                id: "wheel",
                name: "Wheel",
                result: .collectible(.resource(type: .wheel, quantity: 1)),
                materials: [
                    CraftingMaterial(resource: .driftwood, quantity: 4),
                    CraftingMaterial(resource: .brokenWheel, quantity: 1)
                ]
            ),
            Recipe(
                id: "sword",
                name: "Sword",
                result: .toolUpgrade(.sword, tier: 1),
                materials: [
                    CraftingMaterial(resource: .sharkTooth, quantity: 5),
                    CraftingMaterial(resource: .driftwood, quantity: 8)
                ]
            )
        ]
    }
}
