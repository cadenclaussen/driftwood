//
//  MenuButton.swift
//  driftwood
//

import SwiftUI

struct MenuButton: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.8))
                    .frame(width: 60, height: 60)

                Image(systemName: "house.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            }
            .overlay(
                Circle()
                    .stroke(Color.black.opacity(0.3), lineWidth: 2)
            )
        }
    }
}
