//
//  CharacterPageView.swift
//  driftwood
//

import SwiftUI

struct CharacterPageView: View {
    @ObservedObject var viewModel: InventoryViewModel
    @State private var selectedArmorSlot: ArmorSlotType?
    @State private var selectedAccessorySlot: AccessorySlotType?

    var body: some View {
        ZStack {
            HStack(spacing: Theme.Spacing.xxl) {
                VStack(spacing: Theme.Spacing.lg) {
                    armorSection
                    accessorySection
                }

                VStack(spacing: Theme.Spacing.lg) {
                    upgradesSection
                    statsSection
                }
            }
            .padding()

            if let slot = selectedArmorSlot,
               let piece = viewModel.inventory.equipment.piece(for: slot) {
                armorDetailPanel(piece: piece, slot: slot)
            }

            if let slot = selectedAccessorySlot,
               let accessory = viewModel.inventory.accessories.accessory(for: slot) {
                accessoryDetailPanel(accessory: accessory, slot: slot)
            }
        }
    }

    // MARK: - Armor Section

    private var armorSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("Armor")
                .font(Theme.Font.captionBold)
                .foregroundColor(Theme.Color.textPrimary)

            HStack(spacing: Theme.Spacing.sm) {
                ForEach(ArmorSlotType.allCases, id: \.self) { slot in
                    armorSlotView(slot)
                }
            }
        }
    }

    private func armorSlotView(_ slot: ArmorSlotType) -> some View {
        let piece = viewModel.inventory.equipment.piece(for: slot)
        let isSelected = selectedArmorSlot == slot

        return EquipmentSlotView(
            label: slot.displayName,
            iconName: slot.iconName,
            item: piece,
            itemIconName: piece?.iconName,
            itemUsesCustomImage: piece?.usesCustomImage ?? false,
            isSelected: isSelected,
            onTap: {
                if piece != nil {
                    selectedArmorSlot = isSelected ? nil : slot
                    selectedAccessorySlot = nil
                }
            }
        )
        .contextMenu {
            if piece != nil {
                Button("Unequip") {
                    viewModel.unequipArmor(slot)
                }
            }
        }
    }

    // MARK: - Accessory Section

    private var accessorySection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("Accessories")
                .font(Theme.Font.captionBold)
                .foregroundColor(Theme.Color.textPrimary)

            HStack(spacing: Theme.Spacing.sm) {
                ForEach(AccessorySlotType.allCases, id: \.self) { slot in
                    accessorySlotView(slot)
                }
            }
        }
    }

    private func accessorySlotView(_ slot: AccessorySlotType) -> some View {
        let accessory = viewModel.inventory.accessories.accessory(for: slot)
        let isSelected = selectedAccessorySlot == slot

        return VStack(spacing: Theme.Spacing.xxs) {
            EquipmentSlotView(
                label: slot.displayName,
                iconName: slot.iconName,
                item: accessory,
                itemIconName: accessory?.iconName,
                isSelected: isSelected,
                onTap: {
                    if accessory != nil {
                        selectedAccessorySlot = isSelected ? nil : slot
                        selectedArmorSlot = nil
                    }
                }
            )

            if let acc = accessory {
                Text("Tier \(acc.tier)")
                    .font(Theme.Font.nano)
                    .foregroundColor(Theme.Color.selection)
            }
        }
        .contextMenu {
            if accessory != nil {
                Button("Unequip") {
                    viewModel.unequipAccessory(slot)
                }
            }
        }
    }

    // MARK: - Upgrades Section

    private var upgradesSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("Major Upgrades")
                .font(Theme.Font.captionBold)
                .foregroundColor(Theme.Color.textPrimary)

            HStack(spacing: Theme.Spacing.md) {
                ForEach(MajorUpgradeType.allCases, id: \.self) { upgrade in
                    upgradeIcon(upgrade)
                }
            }
        }
    }

    private func upgradeIcon(_ upgrade: MajorUpgradeType) -> some View {
        let hasUpgrade = viewModel.inventory.majorUpgrades.has(upgrade)

        return VStack(spacing: Theme.Spacing.xxs) {
            ZStack {
                Circle()
                    .fill(hasUpgrade ? Theme.Color.craftable.opacity(Theme.Opacity.subtle) : Theme.Color.unownedSlot)
                    .frame(width: Theme.Spacing.massive, height: Theme.Spacing.massive)

                if upgrade.usesCustomImage {
                    Image(upgrade.iconName)
                        .resizable()
                        .interpolation(.none)
                        .frame(width: Theme.Size.iconHuge, height: Theme.Size.iconHuge)
                        .opacity(hasUpgrade ? 1.0 : 0.4)
                } else {
                    Image(systemName: upgrade.iconName)
                        .font(.system(size: Theme.Size.iconMini))
                        .foregroundColor(hasUpgrade ? Theme.Color.positive : Theme.Color.textSecondary.opacity(Theme.Opacity.slot))
                }
            }

            Text(upgrade.displayName)
                .font(Theme.Font.pico)
                .foregroundColor(hasUpgrade ? Theme.Color.textPrimary : Theme.Color.textSecondary)
                .lineLimit(1)
        }
    }

    // MARK: - Stats Section

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text("Total Bonuses")
                .font(Theme.Font.captionBold)
                .foregroundColor(Theme.Color.textPrimary)

            VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                let armorStats = viewModel.inventory.equipment.totalStats
                let accStats = viewModel.inventory.accessories.totalStats

                let totalHearts = armorStats.bonusHearts + accStats.bonusHealth
                let totalDefense = armorStats.defense + accStats.defense
                let totalFortune = armorStats.fishingFortune + accStats.fishingFortune + viewModel.inventory.tools.fishingFortune
                let totalSpeed = armorStats.movementSpeed + accStats.movementSpeed

                if totalHearts > 0 {
                    statLine(icon: "heart.fill", label: "Health", value: "+\(String(format: "%.1f", totalHearts))", color: Theme.Color.statHealth)
                }
                if totalDefense > 0 {
                    statLine(icon: "shield.fill", label: "Defense", value: "+\(totalDefense)", color: Theme.Color.statDefense)
                }
                if totalFortune > 0 {
                    fishFortuneLine(value: totalFortune)
                }
                if totalSpeed > 0 {
                    statLine(icon: "figure.run", label: "Speed", value: "+\(Int(totalSpeed * 100))%", color: Theme.Color.statSpeed)
                }
                if accStats.maxMP > 0 {
                    statLine(icon: "sparkles", label: "Max MP", value: "+\(Int(accStats.maxMP))", color: Theme.Color.statMagic)
                }
            }
            .padding(Theme.Spacing.sm)
            .background(Theme.Color.unownedSlot)
            .cornerRadius(Theme.Radius.button)
        }
    }

    private func statLine(icon: String, label: String, value: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: Theme.Size.iconTiny)
            Text(label)
                .foregroundColor(Theme.Color.textSecondary)
            Spacer()
            Text(value)
                .foregroundColor(Theme.Color.textPrimary)
        }
        .font(Theme.Font.label)
    }

    private func fishFortuneLine(value: Int) -> some View {
        HStack {
            Image("Fish")
                .resizable()
                .interpolation(.none)
                .frame(width: Theme.Size.iconHuge, height: Theme.Size.iconHuge)
            Text("Fortune")
                .foregroundColor(Theme.Color.textSecondary)
            Spacer()
            Text("+\(value)")
                .foregroundColor(Theme.Color.textPrimary)
        }
        .font(Theme.Font.label)
    }

    // MARK: - Armor Detail Panel

    private func armorDetailPanel(piece: ArmorPiece, slot: ArmorSlotType) -> some View {
        VStack(spacing: Theme.Spacing.md) {
            HStack {
                if piece.usesCustomImage {
                    Image(piece.iconName)
                        .resizable()
                        .interpolation(.none)
                        .frame(width: Theme.Size.iconHuge, height: Theme.Size.iconHuge)
                } else {
                    Image(systemName: piece.iconName)
                        .font(.system(size: Theme.Size.iconMedium))
                        .foregroundColor(Theme.Color.textPrimary)
                }

                VStack(alignment: .leading, spacing: Theme.Spacing.xxxs) {
                    Text(piece.displayName)
                        .font(Theme.Font.bodySmallBold)
                        .foregroundColor(Theme.Color.textPrimary)
                    Text(piece.rarity.displayName)
                        .font(Theme.Font.label)
                        .foregroundColor(rarityColor(piece.rarity))
                }

                Spacer()

                Button(action: { selectedArmorSlot = nil }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: Theme.Size.iconSmall))
                        .foregroundColor(Theme.Color.textSecondary)
                }
            }

            Divider()

            armorStatsSection(piece.stats)

            Divider()

            Button(action: {
                viewModel.unequipArmor(slot)
                selectedArmorSlot = nil
            }) {
                HStack {
                    Image(systemName: "arrow.uturn.backward")
                    Text("Remove")
                }
                .font(Theme.Font.captionMedium)
                .foregroundColor(Theme.Color.negative)
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.vertical, Theme.Spacing.sm)
                .background(Theme.Color.negative.opacity(Theme.Opacity.faint))
                .cornerRadius(Theme.Radius.slot)
            }
        }
        .padding(Theme.Spacing.lg)
        .background(Theme.Color.panelBackground)
        .cornerRadius(Theme.Radius.panel)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.panel)
                .stroke(rarityColor(piece.rarity), lineWidth: Theme.Border.standard)
        )
        .frame(maxWidth: Theme.Size.detailPanelMaxWidth)
    }

    private func armorStatsSection(_ stats: ArmorStats) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
            Text("Stats")
                .font(Theme.Font.labelBold)
                .foregroundColor(Theme.Color.textSecondary)

            if stats.bonusHearts > 0 {
                statLine(icon: "heart.fill", label: "Health", value: "+\(String(format: "%.1f", stats.bonusHearts))", color: Theme.Color.statHealth)
            }
            if stats.defense > 0 {
                statLine(icon: "shield.fill", label: "Defense", value: "+\(stats.defense)", color: Theme.Color.statDefense)
            }
            if stats.fishingFortune > 0 {
                statLine(icon: "fish", label: "Fortune", value: "+\(stats.fishingFortune)", color: Theme.Color.statFortune)
            }
            if stats.magicRegen > 0 {
                statLine(icon: "sparkles", label: "MP Regen", value: "+\(String(format: "%.1f", stats.magicRegen))/s", color: Theme.Color.statMagic)
            }
            if stats.movementSpeed > 0 {
                statLine(icon: "figure.run", label: "Speed", value: "+\(Int(stats.movementSpeed * 100))%", color: Theme.Color.statSpeed)
            }
        }
    }

    // MARK: - Accessory Detail Panel

    private func accessoryDetailPanel(accessory: Accessory, slot: AccessorySlotType) -> some View {
        VStack(spacing: Theme.Spacing.md) {
            HStack {
                Image(systemName: accessory.iconName)
                    .font(.system(size: Theme.Size.iconMedium))
                    .foregroundColor(Theme.Color.textPrimary)

                VStack(alignment: .leading, spacing: Theme.Spacing.xxxs) {
                    Text(accessory.displayName)
                        .font(Theme.Font.bodySmallBold)
                        .foregroundColor(Theme.Color.textPrimary)
                    Text(accessory.rarity.displayName)
                        .font(Theme.Font.label)
                        .foregroundColor(rarityColor(accessory.rarity))
                }

                Spacer()

                Button(action: { selectedAccessorySlot = nil }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: Theme.Size.iconSmall))
                        .foregroundColor(Theme.Color.textSecondary)
                }
            }

            Divider()

            accessoryStatsSection(accessory.stats)

            Divider()

            Button(action: {
                viewModel.unequipAccessory(slot)
                selectedAccessorySlot = nil
            }) {
                HStack {
                    Image(systemName: "arrow.uturn.backward")
                    Text("Remove")
                }
                .font(Theme.Font.captionMedium)
                .foregroundColor(Theme.Color.negative)
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.vertical, Theme.Spacing.sm)
                .background(Theme.Color.negative.opacity(Theme.Opacity.faint))
                .cornerRadius(Theme.Radius.slot)
            }
        }
        .padding(Theme.Spacing.lg)
        .background(Theme.Color.panelBackground)
        .cornerRadius(Theme.Radius.panel)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.panel)
                .stroke(rarityColor(accessory.rarity), lineWidth: Theme.Border.standard)
        )
        .frame(maxWidth: Theme.Size.detailPanelMaxWidth)
    }

    private func accessoryStatsSection(_ stats: AccessoryStats) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
            Text("Stats")
                .font(Theme.Font.labelBold)
                .foregroundColor(Theme.Color.textSecondary)

            if stats.bonusHealth > 0 {
                statLine(icon: "heart.fill", label: "Health", value: "+\(String(format: "%.1f", stats.bonusHealth))", color: Theme.Color.statHealth)
            }
            if stats.defense > 0 {
                statLine(icon: "shield.fill", label: "Defense", value: "+\(stats.defense)", color: Theme.Color.statDefense)
            }
            if stats.fishingFortune > 0 {
                statLine(icon: "fish", label: "Fortune", value: "+\(stats.fishingFortune)", color: Theme.Color.statFortune)
            }
            if stats.maxMP > 0 {
                statLine(icon: "sparkles", label: "Max MP", value: "+\(Int(stats.maxMP))", color: Theme.Color.statMagic)
            }
            if stats.mpRegen > 0 {
                statLine(icon: "sparkles", label: "MP Regen", value: "+\(String(format: "%.1f", stats.mpRegen))/s", color: Theme.Color.statMagic)
            }
            if stats.movementSpeed > 0 {
                statLine(icon: "figure.run", label: "Speed", value: "+\(Int(stats.movementSpeed * 100))%", color: Theme.Color.statSpeed)
            }
        }
    }

    private func rarityColor(_ rarity: ItemRarity) -> Color {
        Theme.Color.rarity(rarity)
    }
}
