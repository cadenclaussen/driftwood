//
//  CollectiblesPageView.swift
//  driftwood
//

import SwiftUI

struct CollectiblesPageView: View {
    @ObservedObject var viewModel: InventoryViewModel
    @State private var showingSortPicker = false

    private let columns = Array(repeating: GridItem(.fixed(44), spacing: 6), count: 5)

    var body: some View {
        VStack(spacing: 12) {
            headerRow
                .padding(.top, 26)
            slotGrid
            Spacer()
        }
        .padding()
    }

    private var headerRow: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Collectibles")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                Text("Meals (top row) | Resources")
                    .font(.system(size: 10))
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
            HStack(spacing: 4) {
                Image(systemName: "arrow.up.arrow.down")
                Text("Sort")
            }
            .font(.system(size: 12))
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.gray.opacity(0.3))
            .cornerRadius(6)
        }
    }

    private var slotGrid: some View {
        LazyVGrid(columns: columns, spacing: 6) {
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
        if viewModel.selectedSlotIndex == index {
            viewModel.clearSelection()
        } else if !viewModel.inventory.collectibles[index].isEmpty {
            viewModel.selectSlot(index)
        } else {
            viewModel.clearSelection()
        }
    }
}
