//
//  CollectiblesPageView.swift
//  driftwood
//

import SwiftUI

struct CollectiblesPageView: View {
    @ObservedObject var viewModel: InventoryViewModel

    private let collectibleColumns = Array(repeating: GridItem(.fixed(Theme.Size.inventorySlot), spacing: Theme.Spacing.xxs), count: 5)
    private let recipeColumns = Array(repeating: GridItem(.fixed(Theme.Size.inventorySlot), spacing: Theme.Spacing.xxs), count: 3)

    var body: some View {
        ZStack {
            HStack(alignment: .top, spacing: Theme.Spacing.lg) {
                collectiblesSection
                Divider()
                    .background(Theme.Color.borderMedium)
                craftingSection
            }
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.top, Theme.Spacing.sm)

            if let recipeId = viewModel.selectedRecipeId,
               let recipe = viewModel.unlockedRecipes.first(where: { $0.id == recipeId }) {
                RecipeDetailPanel(
                    recipe: recipe,
                    viewModel: viewModel,
                    onClose: { viewModel.clearRecipeSelection() },
                    onCraft: { _ = viewModel.craft(recipe) }
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
    }

    // MARK: - Collectibles Section (Left)

    private var collectiblesSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            collectiblesHeader
            collectiblesGrid
            Spacer()
        }
        .frame(width: Theme.Size.collectiblesSectionWidth)
    }

    private var collectiblesHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: Theme.Spacing.xxxs) {
                Text("Collectibles")
                    .font(Theme.Font.captionBold)
                    .foregroundColor(Theme.Color.textPrimary)
                Text("Meals | Resources")
                    .font(Theme.Font.nano)
                    .foregroundColor(Theme.Color.textSecondary)
            }
            Spacer()
            sortButton
        }
    }

    private var sortButton: some View {
        Menu {
            ForEach(SortMode.allCases, id: \.self) { mode in
                Button(action: { viewModel.sortCollectibles(by: mode) }) {
                    HStack {
                        Text(mode.displayName)
                        if viewModel.sortMode == mode {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: Theme.Spacing.xxxs) {
                Image(systemName: "arrow.up.arrow.down")
                Text("Sort")
            }
            .font(Theme.Font.micro)
            .foregroundColor(Theme.Color.textPrimary)
            .padding(.horizontal, Theme.Spacing.xs)
            .padding(.vertical, Theme.Spacing.xxs)
            .background(Theme.Color.emptySlot)
            .cornerRadius(Theme.Radius.small)
        }
    }

    private var collectiblesGrid: some View {
        LazyVGrid(columns: collectibleColumns, spacing: Theme.Spacing.xxs) {
            ForEach(0..<Inventory.totalSlotCount, id: \.self) { index in
                InventorySlotView(
                    slot: viewModel.inventory.collectibles[index],
                    isSelected: viewModel.selectedSlotIndex == index,
                    isMealSlot: viewModel.isMealSlot(index),
                    onTap: { handleSlotTap(index) }
                )
            }
        }
    }

    private func handleSlotTap(_ index: Int) {
        viewModel.clearRecipeSelection()
        if viewModel.selectedSlotIndex == index {
            viewModel.clearSelection()
        } else if !viewModel.inventory.collectibles[index].isEmpty {
            viewModel.selectSlot(index)
        } else {
            viewModel.clearSelection()
        }
    }

    // MARK: - Crafting Section (Right)

    private var craftingSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            craftingHeader
            recipeGrid
            Spacer()
        }
        .frame(width: Theme.Size.craftingSectionWidth)
    }

    private var craftingHeader: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xxxs) {
            Text("Crafting")
                .font(Theme.Font.captionBold)
                .foregroundColor(Theme.Color.textPrimary)
            Text("Tap to craft")
                .font(Theme.Font.nano)
                .foregroundColor(Theme.Color.textSecondary)
        }
    }

    private var recipeGrid: some View {
        LazyVGrid(columns: recipeColumns, spacing: Theme.Spacing.xxs) {
            ForEach(viewModel.unlockedRecipes) { recipe in
                RecipeSlotView(
                    recipe: recipe,
                    isCraftable: viewModel.canCraft(recipe),
                    isSelected: viewModel.selectedRecipeId == recipe.id,
                    onTap: { handleRecipeTap(recipe) }
                )
            }
        }
    }

    private func handleRecipeTap(_ recipe: Recipe) {
        viewModel.clearSelection()
        if viewModel.selectedRecipeId == recipe.id {
            viewModel.clearRecipeSelection()
        } else {
            viewModel.selectRecipe(recipe.id)
        }
    }
}
