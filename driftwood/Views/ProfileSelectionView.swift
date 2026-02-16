//
//  ProfileSelectionView.swift
//  driftwood
//

import SwiftUI

struct ProfileSelectionView: View {
    let profiles: [SaveProfile]
    let onProfileSelected: (Int) -> Void
    let onBackTapped: () -> Void

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: Theme.Spacing.xxxl) {
                HStack {
                    Button(action: onBackTapped) {
                        HStack(spacing: Theme.Spacing.xxs) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .font(Theme.Font.body)
                        .foregroundColor(Theme.Color.textPrimary.opacity(Theme.Opacity.overlayMedium))
                    }
                    .padding(.leading, Theme.Spacing.xl)

                    Spacer()
                }

                Text("Select Profile")
                    .font(Theme.Font.title)
                    .foregroundColor(Theme.Color.textPrimary)

                HStack(spacing: Theme.Spacing.xxl) {
                    ForEach(0..<profiles.count, id: \.self) { index in
                        Button(action: { onProfileSelected(index) }) {
                            ProfileCardView(
                                profile: profiles[index],
                                slotNumber: index + 1
                            )
                        }
                    }
                }

                Spacer()
            }
            .padding(.top, Theme.Spacing.xl)
        }
    }
}
