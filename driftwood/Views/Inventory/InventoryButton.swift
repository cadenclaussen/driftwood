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
                    .frame(width: 50, height: 50)

                Image(systemName: "bag.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.white)
            }
            .overlay(
                Circle()
                    .stroke(Color.black.opacity(0.3), lineWidth: 2)
            )
        }
    }
}
