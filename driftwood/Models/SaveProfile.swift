//
//  SaveProfile.swift
//  driftwood
//

import Foundation

struct CodablePoint: Codable {
    var x: CGFloat
    var y: CGFloat

    var cgPoint: CGPoint { CGPoint(x: x, y: y) }

    init(_ point: CGPoint) {
        self.x = point.x
        self.y = point.y
    }

    init(x: CGFloat, y: CGFloat) {
        self.x = x
        self.y = y
    }
}

struct SaveProfile: Codable, Identifiable {
    let id: Int // 0, 1, or 2
    var position: CodablePoint
    var lookDirection: CodablePoint
    var health: Int
    var stamina: CGFloat
    var magic: CGFloat
    var isEmpty: Bool
    var lastPlayed: Date?
    var inventory: Inventory
    var fishingState: FishingState
    var equippedTool: ToolType?

    static func empty(id: Int) -> SaveProfile {
        let tileSize: CGFloat = 24
        let totalSize = World.islandSize + (World.oceanPadding * 2)
        let centerX = CGFloat(totalSize) * tileSize / 2
        let centerY = CGFloat(totalSize) * tileSize / 2
        return SaveProfile(
            id: id,
            position: CodablePoint(x: centerX, y: centerY),
            lookDirection: CodablePoint(x: 1, y: 0),
            health: 5,
            stamina: 100,
            magic: 100,
            isEmpty: true,
            lastPlayed: nil,
            inventory: .empty(),
            fishingState: FishingState(),
            equippedTool: nil
        )
    }

    init(id: Int, position: CodablePoint, lookDirection: CodablePoint, health: Int, stamina: CGFloat, magic: CGFloat, isEmpty: Bool, lastPlayed: Date?, inventory: Inventory = .empty(), fishingState: FishingState = FishingState(), equippedTool: ToolType? = nil) {
        self.id = id
        self.position = position
        self.lookDirection = lookDirection
        self.health = health
        self.stamina = stamina
        self.magic = magic
        self.isEmpty = isEmpty
        self.lastPlayed = lastPlayed
        self.inventory = inventory
        self.fishingState = fishingState
        self.equippedTool = equippedTool
    }

    init(from player: Player, id: Int, inventory: Inventory, fishingState: FishingState, equippedTool: ToolType?) {
        self.id = id
        self.position = CodablePoint(player.position)
        self.lookDirection = CodablePoint(player.lookDirection)
        self.health = player.health
        self.stamina = player.stamina
        self.magic = player.magic
        self.isEmpty = false
        self.lastPlayed = Date()
        self.inventory = inventory
        self.fishingState = fishingState
        self.equippedTool = equippedTool
    }
}
