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
        case .grass: return Color(red: 0.3, green: 0.7, blue: 0.3)
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
}
