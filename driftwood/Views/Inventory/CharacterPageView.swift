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
            HStack(spacing: 24) {
                VStack(spacing: 16) {
                    armorSection
                    accessorySection
                }

                VStack(spacing: 16) {
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
        VStack(alignment: .leading, spacing: 8) {
            Text("Armor")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)

            HStack(spacing: 8) {
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
        VStack(alignment: .leading, spacing: 8) {
            Text("Accessories")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)

            HStack(spacing: 8) {
                ForEach(AccessorySlotType.allCases, id: \.self) { slot in
                    accessorySlotView(slot)
                }
            }
        }
    }

    private func accessorySlotView(_ slot: AccessorySlotType) -> some View {
        let accessory = viewModel.inventory.accessories.accessory(for: slot)
        let isSelected = selectedAccessorySlot == slot

        return VStack(spacing: 4) {
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
                    .font(.system(size: 9))
                    .foregroundColor(.yellow)
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
        VStack(alignment: .leading, spacing: 8) {
            Text("Major Upgrades")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)

            HStack(spacing: 12) {
                ForEach(MajorUpgradeType.allCases, id: \.self) { upgrade in
                    upgradeIcon(upgrade)
                }
            }
        }
    }

    private func upgradeIcon(_ upgrade: MajorUpgradeType) -> some View {
        let hasUpgrade = viewModel.inventory.majorUpgrades.has(upgrade)

        return VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(hasUpgrade ? Color.green.opacity(0.3) : Color.gray.opacity(0.2))
                    .frame(width: 40, height: 40)

                if upgrade.usesCustomImage {
                    Image(upgrade.iconName)
                        .resizable()
                        .interpolation(.none)
                        .frame(width: 32, height: 32)
                        .opacity(hasUpgrade ? 1.0 : 0.4)
                } else {
                    Image(systemName: upgrade.iconName)
                        .font(.system(size: 18))
                        .foregroundColor(hasUpgrade ? .green : .gray.opacity(0.4))
                }
            }

            Text(upgrade.displayName)
                .font(.system(size: 8))
                .foregroundColor(hasUpgrade ? .white : .gray)
                .lineLimit(1)
        }
    }

    // MARK: - Stats Section

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Total Bonuses")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)

            VStack(alignment: .leading, spacing: 4) {
                let armorStats = viewModel.inventory.equipment.totalStats
                let accStats = viewModel.inventory.accessories.totalStats

                let totalHearts = armorStats.bonusHearts + accStats.bonusHealth
                let totalDefense = armorStats.defense + accStats.defense
                let totalFortune = armorStats.fishingFortune + accStats.fishingFortune + viewModel.inventory.tools.fishingFortune
                let totalSpeed = armorStats.movementSpeed + accStats.movementSpeed

                if totalHearts > 0 {
                    statLine(icon: "heart.fill", label: "Health", value: "+\(String(format: "%.1f", totalHearts))", color: .red)
                }
                if totalDefense > 0 {
                    statLine(icon: "shield.fill", label: "Defense", value: "+\(totalDefense)", color: .blue)
                }
                if totalFortune > 0 {
                    fishFortuneLine(value: totalFortune)
                }
                if totalSpeed > 0 {
                    statLine(icon: "figure.run", label: "Speed", value: "+\(Int(totalSpeed * 100))%", color: .green)
                }
                if accStats.maxMP > 0 {
                    statLine(icon: "sparkles", label: "Max MP", value: "+\(Int(accStats.maxMP))", color: .purple)
                }
            }
            .padding(8)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)
        }
    }

    private func statLine(icon: String, label: String, value: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 16)
            Text(label)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .foregroundColor(.white)
        }
        .font(.system(size: 11))
    }

    private func fishFortuneLine(value: Int) -> some View {
        HStack {
            Image("Fish")
                .resizable()
                .interpolation(.none)
                .frame(width: 32, height: 32)
            Text("Fortune")
                .foregroundColor(.gray)
            Spacer()
            Text("+\(value)")
                .foregroundColor(.white)
        }
        .font(.system(size: 11))
    }

    // MARK: - Armor Detail Panel

    private func armorDetailPanel(piece: ArmorPiece, slot: ArmorSlotType) -> some View {
        VStack(spacing: 12) {
            HStack {
                if piece.usesCustomImage {
                    Image(piece.iconName)
                        .resizable()
                        .interpolation(.none)
                        .frame(width: 32, height: 32)
                } else {
                    Image(systemName: piece.iconName)
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(piece.displayName)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    Text(piece.rarity.displayName)
                        .font(.system(size: 11))
                        .foregroundColor(rarityColor(piece.rarity))
                }

                Spacer()

                Button(action: { selectedArmorSlot = nil }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.gray)
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
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.red)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.red.opacity(0.2))
                .cornerRadius(6)
            }
        }
        .padding(16)
        .background(Color.black.opacity(0.95))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(rarityColor(piece.rarity), lineWidth: 2)
        )
        .frame(maxWidth: 220)
    }

    private func armorStatsSection(_ stats: ArmorStats) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Stats")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.gray)

            if stats.bonusHearts > 0 {
                statLine(icon: "heart.fill", label: "Health", value: "+\(String(format: "%.1f", stats.bonusHearts))", color: .red)
            }
            if stats.defense > 0 {
                statLine(icon: "shield.fill", label: "Defense", value: "+\(stats.defense)", color: .blue)
            }
            if stats.fishingFortune > 0 {
                statLine(icon: "fish", label: "Fortune", value: "+\(stats.fishingFortune)", color: .cyan)
            }
            if stats.magicRegen > 0 {
                statLine(icon: "sparkles", label: "MP Regen", value: "+\(String(format: "%.1f", stats.magicRegen))/s", color: .purple)
            }
            if stats.movementSpeed > 0 {
                statLine(icon: "figure.run", label: "Speed", value: "+\(Int(stats.movementSpeed * 100))%", color: .green)
            }
        }
    }

    // MARK: - Accessory Detail Panel

    private func accessoryDetailPanel(accessory: Accessory, slot: AccessorySlotType) -> some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: accessory.iconName)
                    .font(.system(size: 24))
                    .foregroundColor(.white)

                VStack(alignment: .leading, spacing: 2) {
                    Text(accessory.displayName)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    Text(accessory.rarity.displayName)
                        .font(.system(size: 11))
                        .foregroundColor(rarityColor(accessory.rarity))
                }

                Spacer()

                Button(action: { selectedAccessorySlot = nil }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.gray)
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
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.red)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.red.opacity(0.2))
                .cornerRadius(6)
            }
        }
        .padding(16)
        .background(Color.black.opacity(0.95))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(rarityColor(accessory.rarity), lineWidth: 2)
        )
        .frame(maxWidth: 220)
    }

    private func accessoryStatsSection(_ stats: AccessoryStats) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Stats")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.gray)

            if stats.bonusHealth > 0 {
                statLine(icon: "heart.fill", label: "Health", value: "+\(String(format: "%.1f", stats.bonusHealth))", color: .red)
            }
            if stats.defense > 0 {
                statLine(icon: "shield.fill", label: "Defense", value: "+\(stats.defense)", color: .blue)
            }
            if stats.fishingFortune > 0 {
                statLine(icon: "fish", label: "Fortune", value: "+\(stats.fishingFortune)", color: .cyan)
            }
            if stats.maxMP > 0 {
                statLine(icon: "sparkles", label: "Max MP", value: "+\(Int(stats.maxMP))", color: .purple)
            }
            if stats.mpRegen > 0 {
                statLine(icon: "sparkles", label: "MP Regen", value: "+\(String(format: "%.1f", stats.mpRegen))/s", color: .purple)
            }
            if stats.movementSpeed > 0 {
                statLine(icon: "figure.run", label: "Speed", value: "+\(Int(stats.movementSpeed * 100))%", color: .green)
            }
        }
    }

    private func rarityColor(_ rarity: ItemRarity) -> Color {
        switch rarity {
        case .common: return .gray
        case .uncommon: return .green
        case .rare: return .blue
        case .epic: return .purple
        }
    }
}
