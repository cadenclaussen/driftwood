//
//  World.swift
//  driftwood

import Foundation

struct World {
    let width: Int
    let height: Int
    private(set) var tiles: [[TileType]]
    let overlays: [WorldOverlay]
    let groundSprites: [GroundSprite]
    let rockOverlays: [RockOverlay]
    let teleportPads: [TeleportPad]

    static let worldSize = 1000
    static let islandSize = 10

    // home island (centered in world)
    static var islandOriginX: Int { (worldSize - islandSize) / 2 }
    static var islandOriginY: Int { (worldSize - islandSize) / 2 }
    static var islandCenterX: Int { islandOriginX + islandSize / 2 }
    static var islandCenterY: Int { islandOriginY + islandSize / 2 }

    // north island (50 tiles north of home island)
    static var northIslandOriginX: Int { islandOriginX }
    static var northIslandOriginY: Int { islandOriginY - 50 }
    static var northIslandCenterX: Int { northIslandOriginX + islandSize / 2 }
    static var northIslandCenterY: Int { northIslandOriginY + islandSize / 2 }

    init() {
        self.width = World.worldSize
        self.height = World.worldSize
        let (tiles, overlays, groundSprites, rockOverlays, teleportPads) = World.generateWorld()
        self.tiles = tiles
        self.overlays = overlays
        self.groundSprites = groundSprites
        self.rockOverlays = rockOverlays
        self.teleportPads = teleportPads
    }

    static func generateWorld() -> ([[TileType]], [WorldOverlay], [GroundSprite], [RockOverlay], [TeleportPad]) {
        var tiles = Array(repeating: Array(repeating: TileType.ocean, count: worldSize), count: worldSize)
        var overlays: [WorldOverlay] = []
        var groundSprites: [GroundSprite] = []
        var rockOverlays: [RockOverlay] = []
        var teleportPads: [TeleportPad] = []

        // home island
        addIsland(originX: islandOriginX, originY: islandOriginY, tiles: &tiles)
        tiles[islandCenterY][islandCenterX] = .teleportPad
        teleportPads.append(TeleportPad(name: "Home Island", tileX: islandCenterX, tileY: islandCenterY))

        // north island
        addIsland(originX: northIslandOriginX, originY: northIslandOriginY, tiles: &tiles)
        tiles[northIslandCenterY][northIslandCenterX] = .teleportPad
        teleportPads.append(TeleportPad(name: "North Island", tileX: northIslandCenterX, tileY: northIslandCenterY))

        // add tree 3 tiles right of home island center
        let trunkX = islandCenterX + 3
        let trunkY = islandCenterY
        addTree(at: trunkX, y: trunkY, tiles: &tiles, overlays: &overlays, groundSprites: &groundSprites)

        // add test rocks on home island
        rockOverlays.append(RockOverlay(x: islandCenterX - 4, y: islandCenterY, type: .small1))
        rockOverlays.append(RockOverlay(x: islandCenterX, y: islandCenterY - 3, type: .mid1))
        rockOverlays.append(RockOverlay(x: islandCenterX - 2, y: islandCenterY + 2, type: .bigLeft))
        rockOverlays.append(RockOverlay(x: islandCenterX, y: islandCenterY + 2, type: .bigRight))

        return (tiles, overlays, groundSprites, rockOverlays, teleportPads)
    }

    private static func addIsland(originX: Int, originY: Int, tiles: inout [[TileType]]) {
        // place grass
        for y in originY..<(originY + islandSize) {
            for x in originX..<(originX + islandSize) {
                tiles[y][x] = .grass
            }
        }
        // add beach on left side
        for y in originY..<(originY + islandSize) {
            tiles[y][originX] = .beach
        }
    }

    private static func addTree(at trunkX: Int, y trunkY: Int, tiles: inout [[TileType]], overlays: inout [WorldOverlay], groundSprites: inout [GroundSprite]) {
        // trunk collision (2x2 tiles)
        for dy in 0..<2 {
            for dx in 0..<2 {
                tiles[trunkY + dy][trunkX + dx] = .rock
            }
        }

        // trunk sprite
        groundSprites.append(GroundSprite(x: trunkX, y: trunkY, spriteName: "Tree1Trunk", size: 2))

        // overlays
        overlays.append(WorldOverlay(x: trunkX - 2, y: trunkY - 2, type: .tree1FlakeTopLeft))
        overlays.append(WorldOverlay(x: trunkX, y: trunkY - 2, type: .tree1Top))
        overlays.append(WorldOverlay(x: trunkX + 2, y: trunkY - 2, type: .tree1FlakeTopRight))
        overlays.append(WorldOverlay(x: trunkX - 2, y: trunkY, type: .tree1FlakeBottomLeft))
        overlays.append(WorldOverlay(x: trunkX + 2, y: trunkY, type: .tree1FlakeBottomRight))
    }

    func tile(at x: Int, y: Int) -> TileType {
        guard x >= 0, x < width, y >= 0, y < height else {
            return .ocean
        }
        return tiles[y][x]
    }
}
