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
