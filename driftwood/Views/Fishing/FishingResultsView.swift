//
//  FishingResultsView.swift
//  driftwood
//

import SwiftUI

struct StackedCatch: Identifiable {
    let id = UUID()
    let item: SlotContent
    var quantity: Int
    var addedCount: Int
}

struct FishingResultsView: View {
    let catches: [FishingCatch]
    let leveledUp: Bool
    let newLevel: Int
    let onDismiss: () -> Void

    private var stackedCatches: [StackedCatch] {
        var stacks: [String: StackedCatch] = [:]
        for catch_ in catches {
            let key = catch_.item.iconName
            if var existing = stacks[key] {
                existing.quantity += 1
                if catch_.addedToInventory {
                    existing.addedCount += 1
                }
                stacks[key] = existing
            } else {
                stacks[key] = StackedCatch(
                    item: catch_.item,
                    quantity: 1,
                    addedCount: catch_.addedToInventory ? 1 : 0
                )
            }
        }
        return Array(stacks.values)
    }

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
            ForEach(stackedCatches) { stack in
                stackedCatchItem(stack)
            }
        }
        .frame(maxWidth: 300)
    }

    private func stackedCatchItem(_ stack: StackedCatch) -> some View {
        let allAdded = stack.addedCount == stack.quantity
        let noneAdded = stack.addedCount == 0

        return VStack(spacing: 4) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(noneAdded ? Color.red.opacity(0.3) : Color.gray.opacity(0.3))
                    .frame(width: 50, height: 50)

                catchItemIcon(stack.item, added: !noneAdded)

                if stack.quantity > 1 {
                    Text("\(stack.quantity)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(4)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                        .padding(2)
                }
            }
            .frame(width: 50, height: 50)

            if !allAdded {
                Text(noneAdded ? "Full" : "\(stack.quantity - stack.addedCount) lost")
                    .font(.caption2)
                    .foregroundColor(.red)
            }
        }
    }

    @ViewBuilder
    private func catchItemIcon(_ item: SlotContent, added: Bool) -> some View {
        if item.usesCustomImage {
            Image(item.iconName)
                .resizable()
                .interpolation(.none)
                .frame(width: 32, height: 32)
                .opacity(added ? 1.0 : 0.6)
        } else {
            Image(systemName: item.iconName)
                .font(.system(size: 24))
                .foregroundColor(added ? .white : .red.opacity(0.6))
        }
    }
}
