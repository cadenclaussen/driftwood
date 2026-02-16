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

    private let slotSize: CGFloat = Theme.Size.inventorySlot

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
        .onTapGesture {
            HapticService.shared.selection()
            onTap()
        }
    }

    private var slotBackground: some View {
        RoundedRectangle(cornerRadius: Theme.Radius.slot)
            .fill(slot.isEmpty ? Theme.Color.emptySlot : Theme.Color.rarity(slot.content?.rarity ?? .common).opacity(Theme.Opacity.slot))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.slot)
                    .stroke(Theme.Color.borderDarkSubtle, lineWidth: Theme.Border.thin)
            )
    }

    @ViewBuilder
    private func itemIcon(_ content: SlotContent) -> some View {
        if content.usesCustomImage {
            Image(content.iconName)
                .resizable()
                .interpolation(.none)
                .frame(width: Theme.Size.slotImage, height: Theme.Size.slotImage)
        } else {
            Image(systemName: content.iconName)
                .font(.system(size: Theme.Size.iconSmall))
                .foregroundColor(iconColor(for: content))
        }
    }

    private func quantityBadge(_ content: SlotContent) -> some View {
        Group {
            if content.quantity > 1 {
                Text("\(content.quantity)")
                    .font(Theme.Font.microBold)
                    .foregroundColor(Theme.Color.textPrimary)
                    .padding(.horizontal, Theme.Spacing.xxxsm)
                    .padding(.vertical, Theme.Spacing.xxxxs)
                    .background(Theme.Color.overlayDimmed)
                    .cornerRadius(Theme.Radius.small)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .padding(Theme.Spacing.xxxs)
            }
        }
    }

    private var mealSlotIndicator: some View {
        Image(systemName: "fork.knife")
            .font(.system(size: Theme.Size.iconMicro))
            .foregroundColor(Theme.Color.filledSlot)
    }

    private var favoriteIndicator: some View {
        Group {
            if slot.isFavorite {
                Image(systemName: "star.fill")
                    .font(.system(size: Theme.Size.iconPico))
                    .foregroundColor(Theme.Color.favorite)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(Theme.Spacing.xxxs)
            }
        }
    }

    private var junkIndicator: some View {
        Group {
            if slot.isJunk {
                Image(systemName: "trash.fill")
                    .font(.system(size: Theme.Size.iconPico))
                    .foregroundColor(Theme.Color.junk)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding(Theme.Spacing.xxxs)
            }
        }
    }

    private var selectionBorder: some View {
        Group {
            if isSelected {
                RoundedRectangle(cornerRadius: Theme.Radius.slot)
                    .stroke(Theme.Color.selection, lineWidth: Theme.Border.standard)
            }
        }
    }

    private var rarityColor: Color {
        guard let content = slot.content else { return Theme.Color.textSecondary }
        return Theme.Color.rarity(content.rarity)
    }

    private func iconColor(for content: SlotContent) -> Color {
        switch content {
        case .resource(let type, _):
            return Theme.Color.resourceIcon(type)
        case .foodIngredient:
            return Theme.Color.positive
        case .meal:
            return Theme.Color.food
        case .armor:
            return Theme.Color.textSecondary
        case .accessory:
            return Theme.Color.selection
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

    private let slotSize: CGFloat = Theme.Size.equipmentSlot

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
        VStack(spacing: Theme.Spacing.xxs) {
            ZStack {
                RoundedRectangle(cornerRadius: Theme.Radius.button)
                    .fill(item != nil ? Theme.Color.equippedSlotLight : Theme.Color.emptySlot)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.Radius.button)
                            .stroke(isSelected ? Theme.Color.selection : Theme.Color.borderDarkSubtle, lineWidth: isSelected ? Theme.Border.standard : Theme.Border.thin)
                    )

                if let itemIcon = itemIconName {
                    if itemUsesCustomImage {
                        Image(itemIcon)
                            .resizable()
                            .interpolation(.none)
                            .frame(width: Theme.Size.slotImage, height: Theme.Size.slotImage)
                    } else {
                        Image(systemName: itemIcon)
                            .font(.system(size: Theme.Size.iconMedSm))
                            .foregroundColor(Theme.Color.textPrimary)
                    }
                } else {
                    Image(systemName: iconName)
                        .font(.system(size: Theme.Size.iconMini))
                        .foregroundColor(Theme.Color.textDisabled)
                }
            }
            .frame(width: slotSize, height: slotSize)
            .onTapGesture { onTap() }

            Text(label)
                .font(Theme.Font.micro)
                .foregroundColor(Theme.Color.textSecondary)
        }
    }
}
