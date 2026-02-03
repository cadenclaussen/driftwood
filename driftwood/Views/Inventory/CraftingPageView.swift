//
//  CraftingPageView.swift
//  driftwood
//

import SwiftUI

struct CraftingPageView: View {
    @ObservedObject var viewModel: InventoryViewModel

    private let columns = Array(repeating: GridItem(.fixed(44), spacing: 6), count: 5)
    private let recipes = Recipe.allRecipes

    var body: some View {
        ZStack {
            VStack(spacing: 12) {
                headerRow
                    .padding(.top, 26)
                recipeGrid
                Spacer()
            }
            .padding()

            if let recipeId = viewModel.selectedRecipeId,
               let recipe = recipes.first(where: { $0.id == recipeId }) {
                detailPanelOverlay(recipe: recipe)
            }
        }
    }

    private var headerRow: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Crafting")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                Text("Tap a recipe to craft")
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            }
            Spacer()
        }
    }

    private var recipeGrid: some View {
        LazyVGrid(columns: columns, spacing: 6) {
            ForEach(recipes) { recipe in
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
        if viewModel.selectedRecipeId == recipe.id {
            viewModel.clearRecipeSelection()
        } else {
            viewModel.selectRecipe(recipe.id)
        }
    }

    private func detailPanelOverlay(recipe: Recipe) -> some View {
        RecipeDetailPanel(
            recipe: recipe,
            viewModel: viewModel,
            onClose: { viewModel.clearRecipeSelection() },
            onCraft: { _ = viewModel.craft(recipe) }
        )
        .transition(.scale.combined(with: .opacity))
    }
}
