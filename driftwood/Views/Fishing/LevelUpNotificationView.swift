//
//  LevelUpNotificationView.swift
//  driftwood
//

import SwiftUI

struct LevelUpNotificationView: View {
    let level: Int
    let isVisible: Bool

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "arrow.up.circle.fill")
                .font(.system(size: 32))
                .foregroundColor(.yellow)

            Text("Fishing Level Up!")
                .font(.headline)
                .foregroundColor(.white)

            Text("Level \(level)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.cyan)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.8))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.cyan.opacity(0.6), lineWidth: 2)
        )
        .scaleEffect(isVisible ? 1 : 0.5)
        .opacity(isVisible ? 1 : 0)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isVisible)
    }
}
