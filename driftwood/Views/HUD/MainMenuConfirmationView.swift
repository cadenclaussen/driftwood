//
//  MainMenuConfirmationView.swift
//  driftwood

import SwiftUI

struct MainMenuConfirmationView: View {
    let onCancel: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        ZStack {
            Theme.Color.overlayDimmed
                .ignoresSafeArea()

            VStack(spacing: Theme.Spacing.xxl) {
                Text("Return to Main Menu?")
                    .font(Theme.Font.title)
                    .foregroundColor(Theme.Color.textPrimary)

                Text("Your progress is saved automatically.")
                    .font(Theme.Font.body)
                    .foregroundColor(Theme.Color.textSecondary)

                HStack(spacing: Theme.Spacing.xl) {
                    Button(action: onCancel) {
                        Text("Cancel")
                            .font(Theme.Font.subheading)
                            .foregroundColor(Theme.Color.textPrimary)
                            .frame(width: Theme.Size.dialogButtonWidth, height: Theme.Size.dialogButtonHeight)
                            .background(Theme.Color.buttonNeutral)
                            .cornerRadius(Theme.Radius.medium)
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.Radius.medium)
                                    .stroke(Theme.Color.borderLight, lineWidth: Theme.Border.standard)
                            )
                    }

                    Button(action: onConfirm) {
                        Text("Exit")
                            .font(Theme.Font.subheading)
                            .foregroundColor(Theme.Color.textPrimary)
                            .frame(width: Theme.Size.dialogButtonWidth, height: Theme.Size.dialogButtonHeight)
                            .background(Theme.Color.buttonNegative)
                            .cornerRadius(Theme.Radius.medium)
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.Radius.medium)
                                    .stroke(Theme.Color.borderLight, lineWidth: Theme.Border.standard)
                            )
                    }
                }
            }
            .padding(Theme.Spacing.huge)
            .background(Theme.Color.overlayHalf)
            .cornerRadius(Theme.Radius.large)
        }
    }
}
