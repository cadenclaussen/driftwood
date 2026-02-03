//
//  FishingState.swift
//  driftwood
//

import Foundation

struct FishingState: Codable, Equatable {
    var fishingLevel: Int = 1
    var totalCatches: Int = 0

    static let levelThresholds = [0, 10, 25, 50, 100, 250, 500, 1000, 2500, 5000]

    mutating func addCatch() {
        totalCatches += 1
        updateLevel()
    }

    private mutating func updateLevel() {
        for (index, threshold) in Self.levelThresholds.enumerated() {
            let level = index + 1
            if totalCatches >= threshold && level > fishingLevel && level <= 10 {
                fishingLevel = level
            }
        }
    }

    func catchesForNextLevel() -> Int? {
        guard fishingLevel < 10 else { return nil }
        return Self.levelThresholds[fishingLevel] - totalCatches
    }
}

struct FishingCatch: Identifiable {
    let id = UUID()
    let item: SlotContent
    var addedToInventory: Bool = false
}

enum CatchResult {
    case miss
    case noCatch // hit the zone but 50% chance failed
    case success(item: FishingCatch)
    case perfect(item: FishingCatch)

    var isSuccess: Bool {
        switch self {
        case .miss, .noCatch: return false
        case .success, .perfect: return true
        }
    }

    var isPerfect: Bool {
        if case .perfect = self { return true }
        return false
    }

    var isNoCatch: Bool {
        if case .noCatch = self { return true }
        return false
    }
}
