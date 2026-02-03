//
//  InventoryButton.swift
//  driftwood
//

import SwiftUI

struct InventoryButton: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack {
                Circle()
                    .fill(Color.brown.opacity(0.8))
                    .frame(width: 60, height: 60)

                Image("InventoryChest")
                    .resizable()
                    .interpolation(.none)
                    .frame(width: 64, height: 64)
            }
            .overlay(
                Circle()
                    .stroke(Color.black.opacity(0.3), lineWidth: 2)
            )
        }
    }
}
