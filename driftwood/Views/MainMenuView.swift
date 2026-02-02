//
//  MainMenuView.swift
//  driftwood
//

import SwiftUI

struct MainMenuView: View {
    let onPlayTapped: () -> Void

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 60) {
                Text("Driftwood Kingdom")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)

                Button(action: onPlayTapped) {
                    Text("Play")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 180, height: 60)
                        .background(Color.green.opacity(0.8))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                        )
                }
            }
        }
    }
}
