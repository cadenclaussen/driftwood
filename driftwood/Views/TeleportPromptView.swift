//
//  TeleportPromptView.swift
//  driftwood

import SwiftUI

struct TeleportPromptView: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Theme.Spacing.xs) {
                Image(systemName: "arrow.up.and.down.circle.fill")
                    .font(.system(size: Theme.Size.iconTiny, weight: .semibold))
                Text("Teleport")
                    .font(Theme.Font.bodySmallSemibold)
            }
            .foregroundColor(Theme.Color.textPrimary)
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.sm)
            .background(Theme.Color.teleport)
            .cornerRadius(Theme.Radius.button)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.button)
                    .stroke(Theme.Color.borderLight, lineWidth: Theme.Border.thin)
            )
        }
    }
}
