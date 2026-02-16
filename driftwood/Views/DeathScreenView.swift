//
//  DeathScreenView.swift
//  driftwood
//

import SwiftUI

struct DeathScreenView: View {
    let onMainMenu: () -> Void
    let onRespawn: () -> Void

    var body: some View {
        ZStack {
            Theme.Color.overlayDark
                .ignoresSafeArea()

            VStack(spacing: Theme.Spacing.massive) {
                Text("You Died")
                    .font(Theme.Font.titleHuge)
                    .foregroundColor(Theme.Color.negative)

                VStack(spacing: Theme.Spacing.xl) {
                    Button(action: onRespawn) {
                        Text("Respawn")
                            .font(Theme.Font.heading)
                            .foregroundColor(Theme.Color.textPrimary)
                            .frame(width: Theme.Size.deathButtonWidth, height: Theme.Size.deathButtonHeight)
                            .background(Theme.Color.buttonPositive)
                            .cornerRadius(Theme.Radius.medium)
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.Radius.medium)
                                    .stroke(Theme.Color.borderLight, lineWidth: Theme.Border.standard)
                            )
                    }

                    Button(action: {
                        HapticService.shared.selection()
                        onMainMenu()
                    }) {
                        Text("Main Menu")
                            .font(Theme.Font.heading)
                            .foregroundColor(Theme.Color.textPrimary)
                            .frame(width: Theme.Size.deathButtonWidth, height: Theme.Size.deathButtonHeight)
                            .background(Theme.Color.buttonNeutral)
                            .cornerRadius(Theme.Radius.medium)
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.Radius.medium)
                                    .stroke(Theme.Color.borderLight, lineWidth: Theme.Border.standard)
                            )
                    }
                }
            }
        }
    }
}
