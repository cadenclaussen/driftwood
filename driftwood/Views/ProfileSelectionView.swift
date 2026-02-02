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

            VStack(spacing: 30) {
                HStack {
                    Button(action: onBackTapped) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.leading, 20)

                    Spacer()
                }

                Text("Select Profile")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)

                HStack(spacing: 24) {
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
            .padding(.top, 20)
        }
    }
}
