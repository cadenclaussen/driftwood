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
    var facingDirection: FacingDirection?
    var health: Int
    var stamina: CGFloat
    var magic: CGFloat
    var isEmpty: Bool
    var lastPlayed: Date?
    var inventory: Inventory
    var fishingState: FishingState
    var equippedTool: ToolType?
    var sailboatPosition: CodablePoint?
    var isSailing: Bool

    static func empty(id: Int) -> SaveProfile {
        let tileSize: CGFloat = 24
        // spawn at center of island (which is centered in world)
        let islandCenterTileX = CGFloat(World.islandOriginX) + CGFloat(World.islandSize) / 2
        let islandCenterTileY = CGFloat(World.islandOriginY) + CGFloat(World.islandSize) / 2
        let centerX = islandCenterTileX * tileSize
        let centerY = islandCenterTileY * tileSize
        return SaveProfile(
            id: id,
            position: CodablePoint(x: centerX, y: centerY),
            lookDirection: CodablePoint(x: 0, y: 1),
            facingDirection: .down,
            health: 5,
            stamina: 100,
            magic: 100,
            isEmpty: true,
            lastPlayed: nil,
            inventory: .empty(),
            fishingState: FishingState(),
            equippedTool: nil,
            sailboatPosition: nil,
            isSailing: false
        )
    }

    init(id: Int, position: CodablePoint, lookDirection: CodablePoint, facingDirection: FacingDirection? = .down, health: Int, stamina: CGFloat, magic: CGFloat, isEmpty: Bool, lastPlayed: Date?, inventory: Inventory = .empty(), fishingState: FishingState = FishingState(), equippedTool: ToolType? = nil, sailboatPosition: CodablePoint? = nil, isSailing: Bool = false) {
        self.id = id
        self.position = position
        self.lookDirection = lookDirection
        self.facingDirection = facingDirection
        self.health = health
        self.stamina = stamina
        self.magic = magic
        self.isEmpty = isEmpty
        self.lastPlayed = lastPlayed
        self.inventory = inventory
        self.fishingState = fishingState
        self.equippedTool = equippedTool
        self.sailboatPosition = sailboatPosition
        self.isSailing = isSailing
    }

    init(from player: Player, id: Int, inventory: Inventory, fishingState: FishingState, equippedTool: ToolType?, sailboatPosition: CodablePoint? = nil) {
        self.id = id
        self.position = CodablePoint(player.position)
        self.lookDirection = CodablePoint(player.lookDirection)
        self.facingDirection = player.facingDirection
        self.health = player.health
        self.stamina = player.stamina
        self.magic = player.magic
        self.isEmpty = false
        self.lastPlayed = Date()
        self.inventory = inventory
        self.fishingState = fishingState
        self.equippedTool = equippedTool
        self.sailboatPosition = sailboatPosition
        self.isSailing = player.isSailing
    }
}
