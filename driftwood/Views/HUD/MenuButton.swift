//
//  MenuButton.swift
//  driftwood
//

import SwiftUI

struct MenuButton: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: {
            onTap()
        }) {
            ZStack {
                Circle()
                    .fill(Theme.Color.buttonMenu)
                    .frame(width: Theme.Size.circleButton, height: Theme.Size.circleButton)

                Image(systemName: "house.fill")
                    .font(.system(size: Theme.Size.iconMedium))
                    .foregroundColor(Theme.Color.textPrimary)
            }
            .overlay(
                Circle()
                    .stroke(Theme.Color.borderDark, lineWidth: Theme.Border.standard)
            )
        }
    }
}
