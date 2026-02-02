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
            let profiles = try JSONDecoder().decode([SaveProfile].self, from: data)
            if profiles.count == 3 {
                return profiles
            }
            return createEmptyProfiles()
        } catch {
            print("Failed to decode profiles: \(error)")
            return createEmptyProfiles()
        }
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
