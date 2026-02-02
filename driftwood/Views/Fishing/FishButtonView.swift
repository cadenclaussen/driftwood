//
//  FishButtonView.swift
//  driftwood
//

import SwiftUI

struct FishButtonView: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack {
                Circle()
                    .fill(Color.cyan.opacity(0.85))
                    .frame(width: 60, height: 60)

                Image(systemName: "figure.fishing")
                    .font(.system(size: 26))
                    .foregroundColor(.white)
            }
            .overlay(
                Circle()
                    .stroke(Color.cyan, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}
