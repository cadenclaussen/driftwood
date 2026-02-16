//
//  SailboatPromptView.swift
//  driftwood
//

import SwiftUI

enum SailboatPromptType {
    case summon
    case board
    case disembark

    var text: String {
        switch self {
        case .summon: return "Summon Sailboat"
        case .board: return "Board"
        case .disembark: return "Disembark"
        }
    }

    var icon: String {
        switch self {
        case .summon: return "plus.circle"
        case .board: return "arrow.down.circle"
        case .disembark: return "arrow.up.circle"
        }
    }
}

struct SailboatPromptView: View {
    let promptType: SailboatPromptType
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Theme.Spacing.sm) {
                Image(systemName: promptType.icon)
                    .font(.system(size: Theme.Size.iconTiny))
                Text(promptType.text)
                    .font(Theme.Font.bodySmallMedium)
            }
            .foregroundColor(Theme.Color.textPrimary)
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.vertical, Theme.Spacing.smd)
            .background(Theme.Color.buttonBlue)
            .cornerRadius(Theme.Radius.button)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.button)
                    .stroke(Theme.Color.borderLight, lineWidth: Theme.Border.thin)
            )
        }
    }
}
