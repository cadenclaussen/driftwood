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
            Color.black.opacity(0.85)
                .ignoresSafeArea()
                .onTapGesture {
                    onClose()
                }

            VStack(spacing: 0) {
                headerBar
                pageContent
                    .frame(height: 370)
            }
            .frame(width: 500)
            .background(Color.black.opacity(0.95))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
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
                    .font(.system(size: 28))
                    .foregroundColor(.gray)
            }
            .padding(.trailing, 8)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.2))
    }

    private func pageTab(_ page: InventoryPage) -> some View {
        let isSelected = viewModel.currentPage == page

        return Button(action: {
            viewModel.currentPage = page
            viewModel.clearSelection()
        }) {
            HStack(spacing: 4) {
                Image(systemName: page.iconName)
                Text(page.title)
            }
            .font(.system(size: 12, weight: isSelected ? .bold : .regular))
            .foregroundColor(isSelected ? .white : .gray)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.blue.opacity(0.5) : Color.clear)
            .cornerRadius(8)
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
            onClose: { viewModel.clearSelection() }
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
