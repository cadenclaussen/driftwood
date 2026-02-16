//
//  ItemsPageView.swift
//  driftwood
//

import SwiftUI

struct ItemsPageView: View {
    @ObservedObject var viewModel: InventoryViewModel

    var body: some View {
        VStack(spacing: Theme.Spacing.xl) {
            toolsSection
            Spacer()
        }
        .padding()
    }

    private var toolsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Tools")
                .font(Theme.Font.bodySmallBold)
                .foregroundColor(Theme.Color.textPrimary)

            HStack(spacing: Theme.Spacing.lg) {
                ForEach(ToolType.allCases, id: \.self) { tool in
                    toolItem(tool)
                }
            }
        }
    }

    private func toolItem(_ tool: ToolType) -> some View {
        let tier = viewModel.inventory.tools.tier(for: tool)
        let isOwned = tier > 0

        return VStack(spacing: Theme.Spacing.xs) {
            ZStack {
                RoundedRectangle(cornerRadius: Theme.Radius.button)
                    .fill(isOwned ? Theme.Color.ownedToolSlot : Theme.Color.unownedSlot)
                    .frame(width: Theme.Size.circleButton, height: Theme.Size.circleButton)

                VStack(spacing: Theme.Spacing.xxs) {
                    toolIcon(tool, isOwned: isOwned)

                    if tool == .wand {
                        Text(isOwned ? "Owned" : "Locked")
                            .font(Theme.Font.pico)
                            .foregroundColor(isOwned ? Theme.Color.positive : Theme.Color.textSecondary)
                    } else {
                        Text("\(tier)/\(tool.maxTier)")
                            .font(Theme.Font.microBold)
                            .foregroundColor(isOwned ? Theme.Color.textPrimary : Theme.Color.textSecondary)
                    }
                }
            }

            Text(tool.displayName)
                .font(Theme.Font.label)
                .foregroundColor(Theme.Color.textSecondary)
                .lineLimit(1)
        }
    }

    @ViewBuilder
    private func toolIcon(_ tool: ToolType, isOwned: Bool) -> some View {
        if tool.usesCustomImage {
            Image(tool.iconName)
                .resizable()
                .interpolation(.none)
                .frame(width: Theme.Size.iconHuge, height: Theme.Size.iconHuge)
                .opacity(isOwned ? 1.0 : 0.5)
        } else {
            Image(systemName: tool.iconName)
                .font(.system(size: Theme.Size.iconMedium))
                .foregroundColor(isOwned ? Theme.Color.textPrimary : Theme.Color.textDisabled)
        }
    }

}
