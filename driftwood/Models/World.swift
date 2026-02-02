//
//  World.swift
//  driftwood
//

import Foundation

struct World {
    let width: Int
    let height: Int
    private(set) var tiles: [[TileType]]

    static let islandSize = 10
    static let oceanPadding = 3

    init() {
        let totalSize = World.islandSize + (World.oceanPadding * 2)
        self.width = totalSize
        self.height = totalSize
        self.tiles = World.generateIsland(width: totalSize, height: totalSize)
    }

    static func generateIsland(width: Int, height: Int) -> [[TileType]] {
        var tiles = Array(repeating: Array(repeating: TileType.ocean, count: width), count: height)

        // place grass island in center
        for y in oceanPadding..<(oceanPadding + islandSize) {
            for x in oceanPadding..<(oceanPadding + islandSize) {
                tiles[y][x] = .grass
            }
        }

        // add beach on left side of island
        for y in oceanPadding..<(oceanPadding + islandSize) {
            tiles[y][oceanPadding] = .beach
        }

        return tiles
    }

    func tile(at x: Int, y: Int) -> TileType {
        guard x >= 0, x < width, y >= 0, y < height else {
            return .ocean
        }
        return tiles[y][x]
    }
}
