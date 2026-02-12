//
//  SaveManager.swift
//  driftwood
//

import Foundation

class SaveManager {
    static let shared = SaveManager()
    private let key = "driftwood.profiles"

    private init() {}

    func loadProfiles() -> [SaveProfile] {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return createEmptyProfiles()
        }

        do {
            var profiles = try JSONDecoder().decode([SaveProfile].self, from: data)
            if profiles.count == 3 {
                // migrate old saves to new world center if needed
                profiles = migrateProfilesToNewWorld(profiles)
                // clear any spawned sailboats (reset for testing)
                profiles = clearSailboats(profiles)
                // grant sailboat to all profiles for testing
                profiles = grantSailboatToAll(profiles)
                for p in profiles { debugPrintProfile(p) }
                return profiles
            }
            return createEmptyProfiles()
        } catch {
            print("Failed to decode profiles: \(error)")
            return createEmptyProfiles()
        }
    }

    private func clearSailboats(_ profiles: [SaveProfile]) -> [SaveProfile] {
        var updated = profiles
        var needsSave = false
        for i in 0..<updated.count {
            if updated[i].sailboatPosition != nil || updated[i].isSailing {
                updated[i].sailboatPosition = nil
                updated[i].isSailing = false
                needsSave = true
            }
        }
        if needsSave {
            saveAllProfiles(updated)
        }
        return updated
    }

    private func grantSailboatToAll(_ profiles: [SaveProfile]) -> [SaveProfile] {
        var updated = profiles
        var needsSave = false
        for i in 0..<updated.count {
            if !updated[i].inventory.majorUpgrades.hasSailboat {
                updated[i].inventory.majorUpgrades.hasSailboat = true
                needsSave = true
            }
        }
        if needsSave {
            saveAllProfiles(updated)
        }
        return updated
    }

    private func migrateProfilesToNewWorld(_ profiles: [SaveProfile]) -> [SaveProfile] {
        let tileSize: CGFloat = 24
        let newCenterX = (CGFloat(World.islandOriginX) + CGFloat(World.islandSize) / 2) * tileSize
        let newCenterY = (CGFloat(World.islandOriginY) + CGFloat(World.islandSize) / 2) * tileSize

        // migrate if position is not near the current island center
        // island spans from islandOrigin to islandOrigin + islandSize
        let islandMinX = CGFloat(World.islandOriginX) * tileSize
        let islandMaxX = CGFloat(World.islandOriginX + World.islandSize) * tileSize
        let islandMinY = CGFloat(World.islandOriginY) * tileSize
        let islandMaxY = CGFloat(World.islandOriginY + World.islandSize) * tileSize

        var migrated = profiles
        var needsSave = false

        for i in 0..<migrated.count {
            if migrated[i].isEmpty {
                // regenerate empty profiles with current world spawn position
                let expectedX = newCenterX
                let expectedY = newCenterY
                if migrated[i].position.x != expectedX || migrated[i].position.y != expectedY {
                    print("Updating empty profile \(i) spawn to (\(Int(newCenterX)), \(Int(newCenterY)))")
                    migrated[i] = SaveProfile.empty(id: i)
                    needsSave = true
                }
            } else {
                let x = migrated[i].position.x
                let y = migrated[i].position.y
                let onIsland = x >= islandMinX && x <= islandMaxX && y >= islandMinY && y <= islandMaxY
                if !onIsland {
                    print("Migrating profile \(i) from (\(Int(x)), \(Int(y))) to island center (\(Int(newCenterX)), \(Int(newCenterY)))")
                    migrated[i].position = CodablePoint(x: newCenterX, y: newCenterY)
                    needsSave = true
                }
            }
        }

        if needsSave {
            saveAllProfiles(migrated)
        }

        return migrated
    }

    func debugPrintProfile(_ profile: SaveProfile) {
        print("DEBUG Profile \(profile.id): position=(\(Int(profile.position.x)), \(Int(profile.position.y))), isEmpty=\(profile.isEmpty)")
    }

    func saveProfile(_ profile: SaveProfile) {
        var profiles = loadProfiles()
        guard profile.id >= 0 && profile.id < 3 else { return }
        profiles[profile.id] = profile
        saveAllProfiles(profiles)
    }

    func saveAllProfiles(_ profiles: [SaveProfile]) {
        do {
            let data = try JSONEncoder().encode(profiles)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("Failed to encode profiles: \(error)")
        }
    }

    private func createEmptyProfiles() -> [SaveProfile] {
        return [
            SaveProfile.empty(id: 0),
            SaveProfile.empty(id: 1),
            SaveProfile.empty(id: 2)
        ]
    }
}
