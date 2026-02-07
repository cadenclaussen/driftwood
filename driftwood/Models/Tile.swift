//
//  Tile.swift
//  driftwood
//

import SwiftUI

enum TileType {
    case ocean
    case grass
    case beach
    case rock

    var color: Color {
        switch self {
        case .ocean: return Color(red: 0.2, green: 0.5, blue: 0.8)
        case .grass: return Color(red: 173/255, green: 241/255, blue: 83/255) // #adf153
        case .beach: return Color(red: 0.9, green: 0.85, blue: 0.6)
        case .rock: return Color(red: 0.5, green: 0.5, blue: 0.5)
        }
    }

    var isWalkable: Bool {
        switch self {
        case .ocean: return false
        case .grass: return true
        case .beach: return true
        case .rock: return false
        }
    }

    var isSwimmable: Bool {
        switch self {
        case .ocean: return true
        case .grass: return false
        case .beach: return false
        case .rock: return false
        }
    }
}

enum OverlayType {
    case tree1Top
    case tree1FlakeTopLeft
    case tree1FlakeTopRight
    case tree1FlakeBottomLeft
    case tree1FlakeBottomRight

    var spriteName: String {
        switch self {
        case .tree1Top: return "Tree1Top"
        case .tree1FlakeTopLeft: return "Tree1FlakeTopLeft"
        case .tree1FlakeTopRight: return "Tree1FlakeTopRight"
        case .tree1FlakeBottomLeft: return "Tree1FlakeBottomLeft"
        case .tree1FlakeBottomRight: return "Tree1FlakeBottomRight"
        }
    }
}

struct GroundSprite: Identifiable {
    let id = UUID()
    let x: Int  // top-left tile x
    let y: Int  // top-left tile y
    let spriteName: String
    let size: Int  // size in tiles
}

struct WorldOverlay: Identifiable {
    let id = UUID()
    let x: Int  // top-left tile x
    let y: Int  // top-left tile y
    let type: OverlayType
    let size: Int = 2  // 2x2 tiles
}

// collision bounds as pixel offsets from edges of 32px tile
struct CollisionBounds {
    let left: CGFloat   // pixels inset from left edge
    let right: CGFloat  // pixels inset from right edge
    let top: CGFloat    // pixels inset from top edge
    let bottom: CGFloat // pixels inset from bottom edge

    // scale from 32px sprite to 48pt (2 tiles)
    static let scale: CGFloat = 48.0 / 32.0

    // convert to world-space bounds for a rock at tile position (rock is 2x2 tiles)
    func worldBounds(tileX: Int, tileY: Int, tileSize: CGFloat) -> CGRect {
        let rockSize = tileSize * 2
        let scaledLeft = left * CollisionBounds.scale
        let scaledRight = right * CollisionBounds.scale
        let scaledTop = top * CollisionBounds.scale
        let scaledBottom = bottom * CollisionBounds.scale

        let worldX = CGFloat(tileX) * tileSize + scaledLeft
        let worldY = CGFloat(tileY) * tileSize + scaledTop
        let width = rockSize - scaledLeft - scaledRight
        let height = rockSize - scaledTop - scaledBottom

        return CGRect(x: worldX, y: worldY, width: width, height: height)
    }
}

enum RockType {
    case small1, small2, small3, small4
    case mid1, mid2, mid3
    case bigLeft, bigRight

    var spriteName: String {
        switch self {
        case .small1: return "RockSmall1"
        case .small2: return "RockSmall2"
        case .small3: return "RockSmall3"
        case .small4: return "RockSmall4"
        case .mid1: return "RockMid1"
        case .mid2: return "RockMid2"
        case .mid3: return "RockMid3"
        case .bigLeft: return "RockBigLeft"
        case .bigRight: return "RockBigRight"
        }
    }

    var collisionBounds: CollisionBounds {
        switch self {
        case .small1: return CollisionBounds(left: 6, right: 5, top: 12, bottom: 3)
        case .small2: return CollisionBounds(left: 10, right: 1, top: 3, bottom: 12)
        case .small3: return CollisionBounds(left: 2, right: 9, top: 6, bottom: 9)
        case .small4: return CollisionBounds(left: 2, right: 9, top: 13, bottom: 2)
        case .mid1: return CollisionBounds(left: 2, right: 4, top: 12, bottom: 2)
        case .mid2: return CollisionBounds(left: 4, right: 2, top: 4, bottom: 10)
        case .mid3: return CollisionBounds(left: 1, right: 5, top: 6, bottom: 8)
        // large rock combined bounds (split across 2 tiles)
        case .bigLeft: return CollisionBounds(left: 12, right: 0, top: 5, bottom: 6)
        case .bigRight: return CollisionBounds(left: 0, right: 12, top: 5, bottom: 6)
        }
    }
}

struct RockOverlay: Identifiable {
    let id = UUID()
    let x: Int  // tile x
    let y: Int  // tile y
    let type: RockType

    func collisionRect(tileSize: CGFloat) -> CGRect {
        return type.collisionBounds.worldBounds(tileX: x, tileY: y, tileSize: tileSize)
    }
}
