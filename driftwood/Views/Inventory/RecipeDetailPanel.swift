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
        VStack(spacing: 12) {
            headerRow
            Divider().background(Color.gray)
            materialsSection
            Spacer()
            craftButton
        }
        .padding(16)
        .frame(width: 220, height: 280)
        .background(Color.black.opacity(0.95))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
        )
    }

    private var headerRow: some View {
        HStack {
            recipeIcon
            VStack(alignment: .leading, spacing: 2) {
                Text(recipe.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                if let count = viewModel.resultCount(for: recipe) {
                    Text("Owned: \(count)")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                }
            }
            Spacer()
            Button(action: onClose) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.gray)
            }
        }
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
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
        }
    }

    private var materialsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Materials")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.gray)

            ForEach(recipe.materials, id: \.resource) { material in
                materialRow(material)
            }
        }
    }

    private func materialRow(_ material: CraftingMaterial) -> some View {
        let have = viewModel.materialCount(for: material.resource)
        let need = material.quantity
        let hasEnough = have >= need

        return HStack(spacing: 8) {
            materialIcon(material.resource)
            Text(material.resource.displayName)
                .font(.system(size: 12))
                .foregroundColor(.white)
            Spacer()
            Text("\(have) / \(need)")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(hasEnough ? .green : .red)
        }
    }

    @ViewBuilder
    private func materialIcon(_ resource: ResourceType) -> some View {
        if resource.usesCustomImage {
            Image(resource.iconName)
                .resizable()
                .interpolation(.none)
                .frame(width: 20, height: 20)
        } else {
            Image(systemName: resource.iconName)
                .font(.system(size: 14))
                .foregroundColor(.white)
                .frame(width: 20, height: 20)
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
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(canCraft ? Color.green : Color.gray.opacity(0.5))
                .cornerRadius(8)
        }
        .disabled(!canCraft)
    }
}
