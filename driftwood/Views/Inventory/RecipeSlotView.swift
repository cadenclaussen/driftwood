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

    private let slotSize: CGFloat = 44

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
        RoundedRectangle(cornerRadius: 6)
            .fill(isCraftable ? Color.green.opacity(0.3) : Color.red.opacity(0.3))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isCraftable ? Color.green : Color.red, lineWidth: 2)
            )
    }

    @ViewBuilder
    private var recipeIcon: some View {
        if recipe.result.usesCustomImage {
            Image(recipe.result.iconName)
                .resizable()
                .interpolation(.none)
                .frame(width: 32, height: 32)
        } else {
            Image(systemName: recipe.result.iconName)
                .font(.system(size: 20))
                .foregroundColor(.white)
        }
    }

    private var selectionBorder: some View {
        Group {
            if isSelected {
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.yellow, lineWidth: 3)
            }
        }
    }
}
