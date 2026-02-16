//
//  RecipeSlotView.swift
//  driftwood
//

import SwiftUI

struct RecipeSlotView: View {
    let recipe: Recipe
    let isCraftable: Bool
    let isSelected: Bool
    let onTap: () -> Void

    private let slotSize: CGFloat = Theme.Size.inventorySlot

    var body: some View {
        ZStack {
            slotBackground
            recipeIcon
            selectionBorder
        }
        .frame(width: slotSize, height: slotSize)
        .onTapGesture { onTap() }
    }

    private var slotBackground: some View {
        RoundedRectangle(cornerRadius: Theme.Radius.slot)
            .fill(isCraftable ? Theme.Color.craftable.opacity(Theme.Opacity.subtle) : Theme.Color.uncraftable.opacity(Theme.Opacity.subtle))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.slot)
                    .stroke(isCraftable ? Theme.Color.craftable : Theme.Color.uncraftable, lineWidth: Theme.Border.standard)
            )
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
                .font(.system(size: Theme.Size.iconSmall))
                .foregroundColor(Theme.Color.textPrimary)
        }
    }

    private var selectionBorder: some View {
        Group {
            if isSelected {
                RoundedRectangle(cornerRadius: Theme.Radius.slot)
                    .stroke(Theme.Color.selection, lineWidth: Theme.Border.thick)
            }
        }
    }
}
