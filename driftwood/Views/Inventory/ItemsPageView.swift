//
//  ItemsPageView.swift
//  driftwood
//

import SwiftUI

struct ItemsPageView: View {
    @ObservedObject var viewModel: InventoryViewModel

    var body: some View {
        VStack(spacing: 20) {
            gearSection
            Divider()
            toolsSection
            Spacer()
        }
        .padding()
    }

    private var gearSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Gear")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)

            HStack(spacing: 16) {
                ForEach(GearType.allCases, id: \.self) { gear in
                    gearItem(gear)
                }
            }
        }
    }

    private func gearItem(_ gear: GearType) -> some View {
        let tier = viewModel.inventory.gear.tier(for: gear)
        let isOwned = tier > 0

        return VStack(spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(isOwned ? Color.blue.opacity(0.3) : Color.gray.opacity(0.2))
                    .frame(width: 60, height: 60)

                VStack(spacing: 4) {
                    gearIcon(gear, isOwned: isOwned)

                    if gear == .motor {
                        Text(isOwned ? "Owned" : "Locked")
                            .font(.system(size: 8))
                            .foregroundColor(isOwned ? .green : .gray)
                    } else {
                        Text("\(tier)/\(gear.maxTier)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(isOwned ? .white : .gray)
                    }
                }
            }

            Text(gear.displayName)
                .font(.system(size: 11))
                .foregroundColor(.gray)
        }
    }

    private var toolsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tools")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)

            HStack(spacing: 16) {
                ForEach(ToolType.allCases, id: \.self) { tool in
                    toolItem(tool)
                }
            }
        }
    }

    private func toolItem(_ tool: ToolType) -> some View {
        let tier = viewModel.inventory.tools.tier(for: tool)
        let isOwned = tier > 0

        return VStack(spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(isOwned ? Color.orange.opacity(0.3) : Color.gray.opacity(0.2))
                    .frame(width: 60, height: 60)

                VStack(spacing: 4) {
                    toolIcon(tool, isOwned: isOwned)

                    if tool == .wand {
                        Text(isOwned ? "Owned" : "Locked")
                            .font(.system(size: 8))
                            .foregroundColor(isOwned ? .green : .gray)
                    } else {
                        Text("\(tier)/\(tool.maxTier)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(isOwned ? .white : .gray)
                    }
                }
            }

            Text(tool.displayName)
                .font(.system(size: 11))
                .foregroundColor(.gray)
                .lineLimit(1)
        }
    }

    @ViewBuilder
    private func toolIcon(_ tool: ToolType, isOwned: Bool) -> some View {
        if tool.usesCustomImage {
            Image(tool.iconName)
                .resizable()
                .interpolation(.none)
                .frame(width: 32, height: 32)
                .opacity(isOwned ? 1.0 : 0.5)
        } else {
            Image(systemName: tool.iconName)
                .font(.system(size: 24))
                .foregroundColor(isOwned ? .white : .gray.opacity(0.5))
        }
    }

    @ViewBuilder
    private func gearIcon(_ gear: GearType, isOwned: Bool) -> some View {
        if gear.usesCustomImage {
            Image(gear.iconName)
                .resizable()
                .interpolation(.none)
                .frame(width: 32, height: 32)
                .opacity(isOwned ? 1.0 : 0.5)
        } else {
            Image(systemName: gear.iconName)
                .font(.system(size: 24))
                .foregroundColor(isOwned ? .white : .gray.opacity(0.5))
        }
    }
}
