//
//  Sailboat.swift
//  driftwood

import Foundation

struct Sailboat: Codable {
    var position: CGPoint
    var rotationAngle: Double // radians

    init(position: CGPoint, rotationAngle: Double = .pi / 2) { // default pointing down
        self.position = position
        self.rotationAngle = rotationAngle
    }

    // Codable support for CGPoint
    enum CodingKeys: String, CodingKey {
        case x, y, rotationAngle
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let x = try container.decode(CGFloat.self, forKey: .x)
        let y = try container.decode(CGFloat.self, forKey: .y)
        self.position = CGPoint(x: x, y: y)
        self.rotationAngle = try container.decodeIfPresent(Double.self, forKey: .rotationAngle) ?? .pi / 2
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(position.x, forKey: .x)
        try container.encode(position.y, forKey: .y)
        try container.encode(rotationAngle, forKey: .rotationAngle)
    }
}
