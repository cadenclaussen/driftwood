//
//  AppViewModel.swift
//  driftwood
//

import SwiftUI
import Combine

enum AppState {
    case mainMenu
    case profileSelection
    case playing
}

@MainActor
class AppViewModel: ObservableObject {
    @Published var appState: AppState = .mainMenu
    @Published var fadeOpacity: Double = 0
    @Published var profiles: [SaveProfile]
    @Published var isTransitioning: Bool = false

    var selectedProfileIndex: Int?

    init() {
        self.profiles = SaveManager.shared.loadProfiles()
    }

    func showProfileSelection() {
        appState = .profileSelection
    }

    func backToMainMenu() {
        appState = .mainMenu
    }

    func selectProfile(index: Int) {
        guard !isTransitioning else { return }
        guard index >= 0 && index < profiles.count else { return }

        isTransitioning = true
        selectedProfileIndex = index

        withAnimation(.easeIn(duration: 0.3)) {
            fadeOpacity = 1
        }

        Task {
            try? await Task.sleep(for: .milliseconds(400))
            appState = .playing

            withAnimation(.easeOut(duration: 0.3)) {
                fadeOpacity = 0
            }

            try? await Task.sleep(for: .milliseconds(300))
            isTransitioning = false
        }
    }

    func reloadProfiles() {
        profiles = SaveManager.shared.loadProfiles()
    }
}
