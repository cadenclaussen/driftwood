//
//  FishingResultsView.swift
//  driftwood
//

import SwiftUI

struct FishingResultsView: View {
    let catches: [FishingCatch]
    let leveledUp: Bool
    let newLevel: Int
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Fishing Complete")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                if leveledUp {
                    Text("Level Up! Now level \(newLevel)")
                        .font(.headline)
                        .foregroundColor(.yellow)
                }

                if catches.isEmpty {
                    Text("No catches this time")
                        .foregroundColor(.gray)
                } else {
                    catchesGrid
                }

                Button(action: onDismiss) {
                    Text("Done")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding(.top, 10)
            }
            .padding(30)
        }
    }

    private var catchesGrid: some View {
        let columns = [
            GridItem(.adaptive(minimum: 60), spacing: 10)
        ]

        return LazyVGrid(columns: columns, spacing: 10) {
            ForEach(catches) { catch_ in
                catchItem(catch_)
            }
        }
        .frame(maxWidth: 300)
    }

    private func catchItem(_ catch_: FishingCatch) -> some View {
        VStack(spacing: 4) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(catch_.addedToInventory ? Color.gray.opacity(0.3) : Color.red.opacity(0.3))
                    .frame(width: 50, height: 50)

                Image(systemName: catch_.item.iconName)
                    .font(.system(size: 24))
                    .foregroundColor(catch_.addedToInventory ? .white : .red.opacity(0.6))
            }

            if !catch_.addedToInventory {
                Text("Full")
                    .font(.caption2)
                    .foregroundColor(.red)
            }
        }
    }
}
