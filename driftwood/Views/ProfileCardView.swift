//
//  ProfileCardView.swift
//  driftwood
//

import SwiftUI

struct ProfileCardView: View {
    let profile: SaveProfile
    let slotNumber: Int

    var body: some View {
        VStack(spacing: 12) {
            // header
            Text(profile.isEmpty ? "New Game" : "Profile \(slotNumber)")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)

            // mini map preview
            MiniMapView(
                playerPosition: profile.position.cgPoint,
                size: 80
            )

            // stats
            VStack(alignment: .leading, spacing: 6) {
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
        .padding(16)
        .background(Color.gray.opacity(0.3))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}
