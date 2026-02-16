//
//  ProfileCardView.swift
//  driftwood
//

import SwiftUI

struct ProfileCardView: View {
    let profile: SaveProfile
    let slotNumber: Int

    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            // header
            Text(profile.isEmpty ? "New Game" : "Profile \(slotNumber)")
                .font(Theme.Font.bodySemibold)
                .foregroundColor(Theme.Color.textPrimary)

            // mini map preview
            MiniMapView(
                playerPosition: profile.position.cgPoint,
                size: 80
            )

            // stats
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                HeartsView(
                    health: profile.health,
                    maxHealth: 5
                )

                StaminaBarView(
                    stamina: profile.stamina,
                    maxStamina: 100
                )

                MagicBarView(
                    magic: profile.magic,
                    maxMagic: 100
                )
            }
        }
        .padding(Theme.Spacing.lg)
        .background(Theme.Color.emptySlot)
        .cornerRadius(Theme.Radius.panel)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.panel)
                .stroke(Theme.Color.borderFaint, lineWidth: Theme.Border.thin)
        )
    }
}
