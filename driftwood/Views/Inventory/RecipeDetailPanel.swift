//
//  RecipeDetailPanel.swift
//  driftwood
//

import SwiftUI

struct RecipeDetailPanel: View {
    let recipe: Recipe
    @ObservedObject var viewModel: InventoryViewModel
    let onClose: () -> Void
    let onCraft: () -> Void

    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            headerRow
            Divider().background(Theme.Color.textSecondary)
            materialsSection
            Spacer()
            craftButton
        }
        .padding(Theme.Spacing.lg)
        .frame(width: Theme.Size.recipePanelWidth, height: Theme.Size.recipePanelHeight)
        .background(Theme.Color.panelBackground)
        .cornerRadius(Theme.Radius.panel)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.panel)
                .stroke(Theme.Color.borderMedium, lineWidth: Theme.Border.thin)
        )
    }

    private var headerRow: some View {
        HStack {
            recipeIcon
            VStack(alignment: .leading, spacing: Theme.Spacing.xxxs) {
                Text(recipe.name)
                    .font(Theme.Font.bodyBold)
                    .foregroundColor(Theme.Color.textPrimary)
                if let count = viewModel.resultCount(for: recipe) {
                    Text("Owned: \(count)")
                        .font(Theme.Font.micro)
                        .foregroundColor(Theme.Color.textSecondary)
                }
            }
            Spacer()
            Button(action: onClose) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: Theme.Size.iconMedSm))
                    .foregroundColor(Theme.Color.textSecondary)
            }
        }
    }

    @ViewBuilder
    private var recipeIcon: some View {
        if recipe.result.usesCustomImage {
            Image(recipe.result.iconName)
                .resizable()
                .interpolation(.none)
                .frame(width: Theme.Size.iconHuge, height: Theme.Size.iconHuge)
        } else {
            Image(systemName: recipe.result.iconName)
                .font(.system(size: Theme.Size.iconMedium))
                .foregroundColor(Theme.Color.textPrimary)
                .frame(width: Theme.Size.iconHuge, height: Theme.Size.iconHuge)
        }
    }

    private var materialsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("Materials")
                .font(Theme.Font.captionSemibold)
                .foregroundColor(Theme.Color.textSecondary)

            ForEach(recipe.materials, id: \.resource) { material in
                materialRow(material)
            }
        }
    }

    private func materialRow(_ material: CraftingMaterial) -> some View {
        let have = viewModel.materialCount(for: material.resource)
        let need = material.quantity
        let hasEnough = have >= need

        return HStack(spacing: Theme.Spacing.sm) {
            materialIcon(material.resource)
            Text(material.resource.displayName)
                .font(Theme.Font.caption)
                .foregroundColor(Theme.Color.textPrimary)
            Spacer()
            Text("\(have) / \(need)")
                .font(Theme.Font.captionBold)
                .foregroundColor(hasEnough ? Theme.Color.craftable : Theme.Color.uncraftable)
        }
    }

    @ViewBuilder
    private func materialIcon(_ resource: ResourceType) -> some View {
        if resource.usesCustomImage {
            Image(resource.iconName)
                .resizable()
                .interpolation(.none)
                .frame(width: Theme.Size.iconSmall, height: Theme.Size.iconSmall)
        } else {
            Image(systemName: resource.iconName)
                .font(.system(size: Theme.Size.iconMicro))
                .foregroundColor(Theme.Color.textPrimary)
                .frame(width: Theme.Size.iconSmall, height: Theme.Size.iconSmall)
        }
    }

    private var craftButton: some View {
        let canCraft = viewModel.canCraft(recipe)

        return Button(action: {
            if canCraft {
                onCraft()
            }
        }) {
            Text("Craft")
                .font(Theme.Font.bodySmallBold)
                .foregroundColor(Theme.Color.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: Theme.Size.actionButton)
                .background(canCraft ? Theme.Color.craftable : Theme.Color.borderMedium)
                .cornerRadius(Theme.Radius.button)
        }
        .disabled(!canCraft)
    }
}
