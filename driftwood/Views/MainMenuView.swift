//
//  MainMenuView.swift
//  driftwood
//

import SwiftUI

struct MainMenuView: View {
    let onPlayTapped: () -> Void

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: Theme.Spacing.colossal) {
                Text("Driftwood Kingdom")
                    .font(Theme.Font.titleLarge)
                    .foregroundColor(Theme.Color.textPrimary)

                Button(action: onPlayTapped) {
                    Text("Play")
                        .font(Theme.Font.titleSemibold)
                        .foregroundColor(Theme.Color.textPrimary)
                        .frame(width: Theme.Size.menuButtonWidth, height: Theme.Size.menuButtonHeight)
                        .background(Theme.Color.buttonPositive)
                        .cornerRadius(Theme.Radius.panel)
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.Radius.panel)
                                .stroke(Theme.Color.borderLight, lineWidth: Theme.Border.standard)
                        )
                }
            }
        }
    }
}
