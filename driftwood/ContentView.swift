//
//  ContentView.swift
//  driftwood
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appViewModel = AppViewModel()

    var body: some View {
        ZStack {
            switch appViewModel.appState {
            case .mainMenu:
                MainMenuView(onPlayTapped: appViewModel.showProfileSelection)

            case .profileSelection:
                ProfileSelectionView(
                    profiles: appViewModel.profiles,
                    onProfileSelected: appViewModel.selectProfile,
                    onBackTapped: appViewModel.backToMainMenu
                )

            case .playing:
                if let profileIndex = appViewModel.selectedProfileIndex {
                    GameView(profile: appViewModel.profiles[profileIndex])
                }
            }

            Color.black
                .opacity(appViewModel.fadeOpacity)
                .ignoresSafeArea()
                .allowsHitTesting(false)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
