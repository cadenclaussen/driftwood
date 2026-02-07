//
//  InventorySlotView.swift
//  driftwood
//

import SwiftUI

struct InventorySlotView: View {
    let slot: CollectibleSlot
    let isSelected: Bool
    let isMealSlot: Bool
    let onTap: () -> Void

    private let slotSize: CGFloat = 44

    var body: some View {
        ZStack {
            slotBackground
            if let content = slot.content {
                itemIcon(content)
                quantityBadge(content)
            } else if isMealSlot {
                mealSlotIndicator
            }
            favoriteIndicator
            junkIndicator
            selectionBorder
        }
        .frame(width: slotSize, height: slotSize)
        .onTapGesture { onTap() }
    }

    private var slotBackground: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(slot.isEmpty ? Color.gray.opacity(0.3) : rarityColor.opacity(0.4))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.black.opacity(0.2), lineWidth: 1)
            )
    }

    @ViewBuilder
    private func itemIcon(_ content: SlotContent) -> some View {
        if content.usesCustomImage {
            Image(content.iconName)
                .resizable()
                .interpolation(.none)
                .frame(width: 40, height: 40)
        } else {
            Image(systemName: content.iconName)
                .font(.system(size: 20))
                .foregroundColor(iconColor(for: content))
        }
    }

    private func quantityBadge(_ content: SlotContent) -> some View {
        Group {
            if content.quantity > 1 {
                Text("\(content.quantity)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 3)
                    .padding(.vertical, 1)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(4)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .padding(2)
            }
        }
    }

    private var mealSlotIndicator: some View {
        Image(systemName: "fork.knife")
            .font(.system(size: 14))
            .foregroundColor(.gray.opacity(0.4))
    }

    private var favoriteIndicator: some View {
        Group {
            if slot.isFavorite {
                Image(systemName: "star.fill")
                    .font(.system(size: 10))
                    .foregroundColor(.yellow)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(2)
            }
        }
    }

    private var junkIndicator: some View {
        Group {
            if slot.isJunk {
                Image(systemName: "trash.fill")
                    .font(.system(size: 10))
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding(2)
            }
        }
    }

    private var selectionBorder: some View {
        Group {
            if isSelected {
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.yellow, lineWidth: 2)
            }
        }
    }

    private var rarityColor: Color {
        guard let content = slot.content else { return .gray }
        switch content.rarity {
        case .common: return .gray
        case .uncommon: return .green
        case .rare: return .blue
        case .epic: return .purple
        }
    }

    private func iconColor(for content: SlotContent) -> Color {
        switch content {
        case .resource(let type, _):
            switch type {
            case .wood: return .brown
            case .stone: return .gray
            case .metalScrap, .platinumScraps: return .gray
            case .leatherScrap: return .white
            case .oil: return .black
            case .commonFish, .rareFish: return .cyan
            case .rainbowFish, .theOldOne: return .purple
            case .seaweed, .plantFiber: return .green
            case .overgrownCoin: return .yellow
            case .sharkTooth, .scale: return .white
            case .brokenWheel, .wire, .plastic, .wheel: return .gray
            case .sailorsJournal: return .brown
            case .messageInBottle: return .cyan
            case .timeLocket: return .yellow
            case .moonFragment: return .blue
            case .sunFragment: return .orange
            case .string: return .white
            case .cotton, .sail: return .white
            }
        case .foodIngredient:
            return .green
        case .meal:
            return .orange
        case .armor:
            return .gray
        case .accessory:
            return .yellow
        }
    }
}

// MARK: - Equipment Slot View

struct EquipmentSlotView: View {
    let label: String
    let iconName: String
    let item: (any Identifiable)?
    let itemIconName: String?
    let itemUsesCustomImage: Bool
    let isSelected: Bool
    let onTap: () -> Void

    private let slotSize: CGFloat = 50

    init(label: String, iconName: String, item: (any Identifiable)?, itemIconName: String?, itemUsesCustomImage: Bool = false, isSelected: Bool, onTap: @escaping () -> Void) {
        self.label = label
        self.iconName = iconName
        self.item = item
        self.itemIconName = itemIconName
        self.itemUsesCustomImage = itemUsesCustomImage
        self.isSelected = isSelected
        self.onTap = onTap
    }

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(item != nil ? Color.blue.opacity(0.3) : Color.gray.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? Color.yellow : Color.black.opacity(0.2), lineWidth: isSelected ? 2 : 1)
                    )

                if let itemIcon = itemIconName {
                    if itemUsesCustomImage {
                        Image(itemIcon)
                            .resizable()
                            .interpolation(.none)
                            .frame(width: 40, height: 40)
                    } else {
                        Image(systemName: itemIcon)
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                    }
                } else {
                    Image(systemName: iconName)
                        .font(.system(size: 18))
                        .foregroundColor(.gray.opacity(0.5))
                }
            }
            .frame(width: slotSize, height: slotSize)
            .onTapGesture { onTap() }

            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.gray)
        }
    }
}
