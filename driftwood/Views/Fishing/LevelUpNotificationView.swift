//
//  LevelUpNotificationView.swift
//  driftwood
//

import SwiftUI

struct LevelUpNotificationView: View {
    let level: Int
    let isVisible: Bool

    var body: some View {
        VStack(spacing: Theme.Spacing.sm) {
            Image(systemName: "arrow.up.circle.fill")
                .font(.system(size: Theme.Size.iconHuge))
                .foregroundColor(Theme.Color.selection)

            Text("Fishing Level Up!")
                .font(Theme.Font.bodyLargeSemibold)
                .foregroundColor(Theme.Color.textPrimary)

            Text("Level \(level)")
                .font(Theme.Font.headingLight)
                .fontWeight(.bold)
                .foregroundColor(Theme.Color.magicCyan)
        }
        .padding(.horizontal, Theme.Spacing.xxl)
        .padding(.vertical, Theme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.panel)
                .fill(Theme.Color.overlayMedium)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.panel)
                .stroke(Theme.Color.fishing.opacity(Theme.Opacity.button), lineWidth: Theme.Border.standard)
        )
        .scaleEffect(isVisible ? 1 : 0.5)
        .opacity(isVisible ? 1 : 0)
        .animation(Theme.Anim.spring, value: isVisible)
    }
}
