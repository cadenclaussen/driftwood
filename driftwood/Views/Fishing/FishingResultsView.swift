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
            Theme.Color.overlayMedium
                .ignoresSafeArea()

            VStack(spacing: Theme.Spacing.xl) {
                Text("Fishing Complete")
                    .font(Theme.Font.headingLight)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.Color.textPrimary)

                if leveledUp {
                    Text("Level Up! Now level \(newLevel)")
                        .font(Theme.Font.bodyLargeSemibold)
                        .foregroundColor(Theme.Color.selection)
                }

                if catches.isEmpty {
                    Text("No catches this time")
                        .foregroundColor(Theme.Color.textSecondary)
                } else {
                    catchesGrid
                }

                Button(action: onDismiss) {
                    Text("Done")
                        .font(Theme.Font.bodyLargeSemibold)
                        .foregroundColor(Theme.Color.textPrimary)
                        .padding(.horizontal, Theme.Spacing.massive)
                        .padding(.vertical, Theme.Spacing.md)
                        .background(Theme.Color.equipped)
                        .cornerRadius(Theme.Radius.button)
                }
                .padding(.top, Theme.Spacing.smd)
            }
            .padding(Theme.Spacing.xxxl)
        }
    }

    private var catchesGrid: some View {
        let columns = [
            GridItem(.adaptive(minimum: Theme.Size.circleButton), spacing: Theme.Spacing.smd)
        ]

        return LazyVGrid(columns: columns, spacing: Theme.Spacing.smd) {
            ForEach(stackedCatches) { stack in
                stackedCatchItem(stack)
            }
        }
        .frame(maxWidth: Theme.Size.resultsMaxWidth)
    }

    private func stackedCatchItem(_ stack: StackedCatch) -> some View {
        let allAdded = stack.addedCount == stack.quantity
        let noneAdded = stack.addedCount == 0

        return VStack(spacing: Theme.Spacing.xxs) {
            ZStack {
                RoundedRectangle(cornerRadius: Theme.Radius.button)
                    .fill(noneAdded ? Theme.Color.uncraftable.opacity(Theme.Opacity.subtle) : Theme.Color.emptySlot)
                    .frame(width: Theme.Size.equipmentSlot, height: Theme.Size.equipmentSlot)

                catchItemIcon(stack.item, added: !noneAdded)

                if stack.quantity > 1 {
                    Text("\(stack.quantity)")
                        .font(Theme.Font.microBold)
                        .foregroundColor(Theme.Color.textPrimary)
                        .padding(.horizontal, Theme.Spacing.xxs)
                        .padding(.vertical, Theme.Spacing.xxxs)
                        .background(Theme.Color.overlayDimmed)
                        .cornerRadius(Theme.Radius.small)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                        .padding(Theme.Spacing.xxxs)
                }
            }
            .frame(width: Theme.Size.equipmentSlot, height: Theme.Size.equipmentSlot)

            if !allAdded {
                Text(noneAdded ? "Full" : "\(stack.quantity - stack.addedCount) lost")
                    .font(Theme.Font.label)
                    .foregroundColor(Theme.Color.negative)
            }
        }
    }

    @ViewBuilder
    private func catchItemIcon(_ item: SlotContent, added: Bool) -> some View {
        if item.usesCustomImage {
            Image(item.iconName)
                .resizable()
                .interpolation(.none)
                .frame(width: Theme.Size.iconHuge, height: Theme.Size.iconHuge)
                .opacity(added ? 1.0 : 0.6)
        } else {
            Image(systemName: item.iconName)
                .font(.system(size: Theme.Size.iconMedium))
                .foregroundColor(added ? Theme.Color.textPrimary : Theme.Color.negative.opacity(Theme.Opacity.button))
        }
    }
}
