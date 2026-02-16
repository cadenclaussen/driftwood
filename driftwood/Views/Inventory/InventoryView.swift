//
//  InventoryView.swift
//  driftwood
//

import SwiftUI

struct InventoryView: View {
    @ObservedObject var viewModel: InventoryViewModel
    let onClose: () -> Void
    let onUseMeal: (Int) -> Void

    var body: some View {
        ZStack {
            Theme.Color.overlayDark
                .ignoresSafeArea()
                .onTapGesture {
                    onClose()
                }

            VStack(spacing: 0) {
                headerBar
                pageContent
                    .frame(height: Theme.Size.inventoryPanelHeight)
            }
            .frame(width: Theme.Size.inventoryPanelWidth)
            .background(Theme.Color.panelBackground)
            .cornerRadius(Theme.Radius.large)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.large)
                    .stroke(Theme.Color.borderMedium, lineWidth: Theme.Border.thin)
            )
            .scaleEffect(0.85)
            .offset(y: -15)

            if let index = viewModel.selectedSlotIndex,
               let content = viewModel.inventory.collectibles[index].content {
                detailPanelOverlay(index: index, content: content)
            }
        }
        .onAppear {
            viewModel.compactCollectibles()
        }
        .onDisappear {
            viewModel.clearRecipeSelection()
        }
    }

    private var headerBar: some View {
        HStack {
            ForEach(InventoryPage.allCases, id: \.self) { page in
                pageTab(page)
            }

            Spacer()

            Button(action: onClose) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: Theme.Size.iconLarge))
                    .foregroundColor(Theme.Color.textSecondary)
            }
            .padding(.trailing, Theme.Spacing.sm)
        }
        .padding(.horizontal, Theme.Spacing.md)
        .padding(.vertical, Theme.Spacing.sm)
        .background(Theme.Color.unownedSlot)
    }

    private func pageTab(_ page: InventoryPage) -> some View {
        let isSelected = viewModel.currentPage == page

        return Button(action: {
            viewModel.currentPage = page
            viewModel.clearSelection()
        }) {
            HStack(spacing: Theme.Spacing.xxs) {
                Image(systemName: page.iconName)
                Text(page.title)
            }
            .font(isSelected ? Theme.Font.captionBold : Theme.Font.caption)
            .foregroundColor(isSelected ? Theme.Color.textPrimary : Theme.Color.textSecondary)
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.xs)
            .background(isSelected ? Theme.Color.tabSelected : Color.clear)
            .cornerRadius(Theme.Radius.button)
        }
    }

    @ViewBuilder
    private var pageContent: some View {
        switch viewModel.currentPage {
        case .items:
            ItemsPageView(viewModel: viewModel)
        case .collectibles:
            CollectiblesPageView(viewModel: viewModel)
        case .character:
            CharacterPageView(viewModel: viewModel)
        }
    }

    private func detailPanelOverlay(index: Int, content: SlotContent) -> some View {
        let slot = viewModel.inventory.collectibles[index]

        return ItemDetailPanel(
            content: content,
            isFavorite: slot.isFavorite,
            isJunk: slot.isJunk,
            onUse: content.isMeal ? { onUseMeal(index) } : nil,
            onEquip: content.isEquippable ? { handleEquip(index: index, content: content) } : nil,
            onFavorite: { viewModel.toggleFavorite(at: index) },
            onJunk: { viewModel.toggleJunk(at: index) },
            onDrop: {
                viewModel.removeItem(at: index)
                viewModel.clearSelection()
            },
            onClose: { viewModel.clearSelection() },
            onAdd: content.resourceType.map { type in { viewModel.debugAddResource(type) } }
        )
        .transition(.scale.combined(with: .opacity))
    }

    private func handleEquip(index: Int, content: SlotContent) {
        switch content {
        case .armor(let piece):
            viewModel.equipArmor(piece, from: index)
        case .accessory(let item):
            viewModel.equipAccessory(item, from: index)
        default:
            break
        }
        viewModel.clearSelection()
    }
}
