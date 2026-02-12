//
//  TeleportPromptView.swift
//  driftwood

import SwiftUI

struct TeleportPromptView: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Image(systemName: "arrow.up.and.down.circle.fill")
                    .font(.system(size: 16, weight: .semibold))
                Text("Teleport")
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(red: 0.6, green: 0.3, blue: 0.8))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
        }
    }
}
