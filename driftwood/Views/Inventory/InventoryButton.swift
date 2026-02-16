//
//  InventoryButton.swift
//  driftwood
//

import SwiftUI

struct InventoryButton: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: {
            HapticService.shared.selection()
            onTap()
        }) {
            ZStack {
                Circle()
                    .fill(Theme.Color.buttonInventory)
                    .frame(width: Theme.Size.circleButton, height: Theme.Size.circleButton)

                Image("InventoryChest")
                    .resizable()
                    .interpolation(.none)
                    .frame(width: Theme.Size.inventoryButtonIcon, height: Theme.Size.inventoryButtonIcon)
            }
            .overlay(
                Circle()
                    .stroke(Theme.Color.borderDark, lineWidth: Theme.Border.standard)
            )
        }
    }
}
