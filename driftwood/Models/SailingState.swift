//
//  SailingState.swift
//  driftwood
//

import Foundation

struct SailingState {
    var windAngle: CGFloat = 0 // radians, 0 = right
    let windStrength: CGFloat = 15 // pixels per second push
    let windDriftRate: CGFloat = 0.3 // radians per second max drift

    var windDirection: CGPoint {
        CGPoint(x: cos(windAngle), y: sin(windAngle))
    }

    mutating func updateWind(deltaTime: CGFloat) {
        let drift = CGFloat.random(in: -1...1) * windDriftRate * deltaTime
        windAngle += drift
    }
}
