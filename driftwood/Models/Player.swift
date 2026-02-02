//
//  Player.swift
//  driftwood
//

import Foundation

struct Player {
    var position: CGPoint
    var lookDirection: CGPoint = CGPoint(x: 1, y: 0) // unit vector, default looking right
    let size: CGFloat = 12 // half of 24pt tile

    init(startPosition: CGPoint) {
        self.position = startPosition
    }
}
