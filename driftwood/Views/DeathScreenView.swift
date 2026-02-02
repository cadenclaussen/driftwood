//
//  DeathScreenView.swift
//  driftwood
//

import SwiftUI

struct DeathScreenView: View {
    let onMainMenu: () -> Void
    let onRespawn: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.85)
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Text("You Died")
                    .font(.system(size: 42, weight: .bold))
                    .foregroundColor(.red)

                VStack(spacing: 20) {
                    Button(action: onRespawn) {
                        Text("Respawn")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(Color.green.opacity(0.8))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
                            )
                    }

                    Button(action: onMainMenu) {
                        Text("Main Menu")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(Color.gray.opacity(0.6))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
                            )
                    }
                }
            }
        }
    }
}
