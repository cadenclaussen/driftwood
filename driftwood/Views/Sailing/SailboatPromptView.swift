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
            HStack(spacing: 8) {
                Image(systemName: promptType.icon)
                    .font(.system(size: 16))
                Text(promptType.text)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.blue.opacity(0.8))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
        }
    }
}
