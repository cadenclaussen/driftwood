//
//  Sailboat.swift
//  driftwood
//

import Foundation

struct Sailboat: Codable {
    var position: CGPoint

    init(position: CGPoint) {
        self.position = position
    }

    // Codable support for CGPoint
    enum CodingKeys: String, CodingKey {
        case x, y
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let x = try container.decode(CGFloat.self, forKey: .x)
        let y = try container.decode(CGFloat.self, forKey: .y)
        self.position = CGPoint(x: x, y: y)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(position.x, forKey: .x)
        try container.encode(position.y, forKey: .y)
    }
}
