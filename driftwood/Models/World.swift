//
//  World.swift
//  driftwood
//

import Foundation

struct World {
    let width: Int
    let height: Int
    private(set) var tiles: [[TileType]]
    let overlays: [WorldOverlay]
    let groundSprites: [GroundSprite]
    let rockOverlays: [RockOverlay]

    static let worldSize = 1000
    static let islandSize = 10

    // island starts at this tile coordinate (centered in world)
    static var islandOriginX: Int { (worldSize - islandSize) / 2 }
    static var islandOriginY: Int { (worldSize - islandSize) / 2 }

    // island center (player spawn point)
    static var islandCenterX: Int { islandOriginX + islandSize / 2 }
    static var islandCenterY: Int { islandOriginY + islandSize / 2 }

    init() {
        self.width = World.worldSize
        self.height = World.worldSize
        let (tiles, overlays, groundSprites, rockOverlays) = World.generateWorld()
        self.tiles = tiles
        self.overlays = overlays
        self.groundSprites = groundSprites
        self.rockOverlays = rockOverlays

        let centerTile = self.tiles[World.islandCenterY][World.islandCenterX]
        print("DEBUG World init: worldSize=\(World.worldSize), island origin=(\(World.islandOriginX), \(World.islandOriginY)), center=(\(World.islandCenterX),\(World.islandCenterY)), tile=\(centerTile)")
    }

    static func generateWorld() -> ([[TileType]], [WorldOverlay], [GroundSprite], [RockOverlay]) {
        // start with all ocean
        var tiles = Array(repeating: Array(repeating: TileType.ocean, count: worldSize), count: worldSize)
        var overlays: [WorldOverlay] = []
        var groundSprites: [GroundSprite] = []
        var rockOverlays: [RockOverlay] = []

        // place grass island in center
        for y in islandOriginY..<(islandOriginY + islandSize) {
            for x in islandOriginX..<(islandOriginX + islandSize) {
                tiles[y][x] = .grass
            }
        }

        // add beach on left side of island
        for y in islandOriginY..<(islandOriginY + islandSize) {
            tiles[y][islandOriginX] = .beach
        }

        // add tree 3 tiles right of island center
        // tree is 3 wide x 2 tall, trunk is center of bottom row
        let trunkX = islandCenterX + 3
        let trunkY = islandCenterY
        addTree(at: trunkX, y: trunkY, tiles: &tiles, overlays: &overlays, groundSprites: &groundSprites)

        // add test rocks on island
        // small rock (type 1) - 4 tiles left of center
        rockOverlays.append(RockOverlay(x: islandCenterX - 4, y: islandCenterY, type: .small1))
        // medium rock (type 1) - 3 tiles up from center
        rockOverlays.append(RockOverlay(x: islandCenterX, y: islandCenterY - 3, type: .mid1))
        // large rock (left + right) - 2 tiles down from center, each part is 2 tiles wide
        rockOverlays.append(RockOverlay(x: islandCenterX - 2, y: islandCenterY + 2, type: .bigLeft))
        rockOverlays.append(RockOverlay(x: islandCenterX, y: islandCenterY + 2, type: .bigRight))

        return (tiles, overlays, groundSprites, rockOverlays)
    }

    private static func addTree(at trunkX: Int, y trunkY: Int, tiles: inout [[TileType]], overlays: inout [WorldOverlay], groundSprites: inout [GroundSprite]) {
        // All overlay assets are 2x2 tiles, trunk is a ground sprite
        // Tree layout:
        //   FTL  TOP  FTR   (top row, y = trunkY - 2)
        //   FBL  TRK  FBR   (bottom row, y = trunkY)

        // trunk collision (2x2 tiles)
        for dy in 0..<2 {
            for dx in 0..<2 {
                tiles[trunkY + dy][trunkX + dx] = .rock
            }
        }

        // trunk sprite renders on top of tiles but behind player
        groundSprites.append(GroundSprite(x: trunkX, y: trunkY, spriteName: "Tree1Trunk", size: 2))

        // top row overlays (2 tiles above trunk)
        overlays.append(WorldOverlay(x: trunkX - 2, y: trunkY - 2, type: .tree1FlakeTopLeft))
        overlays.append(WorldOverlay(x: trunkX, y: trunkY - 2, type: .tree1Top))
        overlays.append(WorldOverlay(x: trunkX + 2, y: trunkY - 2, type: .tree1FlakeTopRight))
        // bottom row overlays (left and right of trunk)
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
