//
//  CollectiblesPageView.swift
//  driftwood
//

import SwiftUI

struct CollectiblesPageView: View {
    @ObservedObject var viewModel: InventoryViewModel

    private let collectibleColumns = Array(repeating: GridItem(.fixed(44), spacing: 4), count: 5)
    private let recipeColumns = Array(repeating: GridItem(.fixed(44), spacing: 4), count: 3)

    var body: some View {
        ZStack {
            HStack(alignment: .top, spacing: 16) {
                collectiblesSection
                Divider()
                    .background(Color.gray.opacity(0.5))
                craftingSection
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)

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
        VStack(alignment: .leading, spacing: 8) {
            collectiblesHeader
            collectiblesGrid
            Spacer()
        }
        .frame(width: 240)
    }

    private var collectiblesHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Collectibles")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                Text("Meals | Resources")
                    .font(.system(size: 9))
                    .foregroundColor(.gray)
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
            HStack(spacing: 2) {
                Image(systemName: "arrow.up.arrow.down")
                Text("Sort")
            }
            .font(.system(size: 10))
            .foregroundColor(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(Color.gray.opacity(0.3))
            .cornerRadius(4)
        }
    }

    private var collectiblesGrid: some View {
        LazyVGrid(columns: collectibleColumns, spacing: 4) {
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
        VStack(alignment: .leading, spacing: 8) {
            craftingHeader
            recipeGrid
            Spacer()
        }
        .frame(width: 150)
    }

    private var craftingHeader: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Crafting")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
            Text("Tap to craft")
                .font(.system(size: 9))
                .foregroundColor(.gray)
        }
    }

    private var recipeGrid: some View {
        LazyVGrid(columns: recipeColumns, spacing: 4) {
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
