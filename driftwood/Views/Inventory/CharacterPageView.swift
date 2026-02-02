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

                Image(systemName: upgrade.iconName)
                    .font(.system(size: 18))
                    .foregroundColor(hasUpgrade ? .green : .gray.opacity(0.4))
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
                    statLine(icon: "fish", label: "Fortune", value: "+\(totalFortune)", color: .cyan)
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
}
