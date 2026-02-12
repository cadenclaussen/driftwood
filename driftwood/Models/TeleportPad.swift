//
//  TeleportPad.swift
//  driftwood

import Foundation

struct TeleportPad: Identifiable, Codable {
    let id: UUID
    let name: String
    let tileX: Int
    let tileY: Int

    init(id: UUID = UUID(), name: String, tileX: Int, tileY: Int) {
        self.id = id
        self.name = name
        self.tileX = tileX
        self.tileY = tileY
    }

    var worldPosition: CGPoint {
        let tileSize: CGFloat = 24
        return CGPoint(
            x: CGFloat(tileX) * tileSize + tileSize / 2,
            y: CGFloat(tileY) * tileSize + tileSize / 2
        )
    }
}
