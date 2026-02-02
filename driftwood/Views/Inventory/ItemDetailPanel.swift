//
//  ItemDetailPanel.swift
//  driftwood
//

import SwiftUI

struct ItemDetailPanel: View {
    let content: SlotContent
    let isFavorite: Bool
    let isJunk: Bool
    let onUse: (() -> Void)?
    let onEquip: (() -> Void)?
    let onFavorite: () -> Void
    let onJunk: () -> Void
    let onDrop: () -> Void
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            headerSection
            Divider()
            descriptionSection
            statsSection
            Divider()
            actionButtons
        }
        .padding(16)
        .background(Color.black.opacity(0.9))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(rarityColor, lineWidth: 2)
        )
        .frame(maxWidth: 280)
    }

    private var headerSection: some View {
        HStack {
            Image(systemName: content.iconName)
                .font(.system(size: 32))
                .foregroundColor(rarityColor)

            VStack(alignment: .leading, spacing: 2) {
                Text(content.displayName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)

                Text(content.rarity.displayName)
                    .font(.system(size: 12))
                    .foregroundColor(rarityColor)
            }

            Spacer()

            Button(action: onClose) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.gray)
            }
        }
    }

    private var descriptionSection: some View {
        Text(descriptionText)
            .font(.system(size: 12))
            .foregroundColor(.gray)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var statsSection: some View {
        switch content {
        case .meal(_, let healAmount, let tempHearts):
            HStack {
                Label("\(healAmount)", systemImage: "heart.fill")
                    .foregroundColor(.red)
                if tempHearts > 0 {
                    Label("+\(tempHearts) temp", systemImage: "heart")
                        .foregroundColor(.yellow)
                }
            }
            .font(.system(size: 12))

        case .armor(let piece):
            armorStatsView(piece.stats)

        case .accessory(let item):
            accessoryStatsView(item.stats)

        case .resource(_, let quantity):
            Text("Quantity: \(quantity)")
                .font(.system(size: 12))
                .foregroundColor(.gray)

        default:
            EmptyView()
        }
    }

    private func armorStatsView(_ stats: ArmorStats) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            if stats.bonusHearts > 0 {
                statRow(icon: "heart.fill", value: "+\(String(format: "%.1f", stats.bonusHearts))", color: .red)
            }
            if stats.fishingFortune > 0 {
                statRow(icon: "fish", value: "+\(stats.fishingFortune) Fortune", color: .cyan)
            }
            if stats.defense > 0 {
                statRow(icon: "shield.fill", value: "+\(stats.defense) Defense", color: .blue)
            }
            if stats.magicRegen > 0 {
                statRow(icon: "sparkles", value: "+\(String(format: "%.1f", stats.magicRegen)) MP/s", color: .purple)
            }
            if stats.movementSpeed > 0 {
                statRow(icon: "figure.run", value: "+\(Int(stats.movementSpeed * 100))% Speed", color: .green)
            }
        }
    }

    private func accessoryStatsView(_ stats: AccessoryStats) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            if stats.bonusHealth > 0 {
                statRow(icon: "heart.fill", value: "+\(String(format: "%.1f", stats.bonusHealth))", color: .red)
            }
            if stats.maxMP > 0 {
                statRow(icon: "sparkles", value: "+\(Int(stats.maxMP)) Max MP", color: .purple)
            }
            if stats.mpRegen > 0 {
                statRow(icon: "sparkles", value: "+\(String(format: "%.1f", stats.mpRegen)) MP/s", color: .purple)
            }
            if stats.defense > 0 {
                statRow(icon: "shield.fill", value: "+\(stats.defense) Defense", color: .blue)
            }
            if stats.fishingFortune > 0 {
                statRow(icon: "fish", value: "+\(stats.fishingFortune) Fortune", color: .cyan)
            }
            if stats.movementSpeed > 0 {
                statRow(icon: "figure.run", value: "+\(Int(stats.movementSpeed * 100))% Speed", color: .green)
            }
        }
    }

    private func statRow(icon: String, value: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(value)
                .foregroundColor(.white)
        }
        .font(.system(size: 11))
    }

    private var actionButtons: some View {
        HStack(spacing: 8) {
            if let onUse = onUse, content.isMeal {
                actionButton(title: "Use", icon: "fork.knife", color: .orange, action: onUse)
            }

            if let onEquip = onEquip, content.isEquippable {
                actionButton(title: "Equip", icon: "square.and.arrow.down", color: .blue, action: onEquip)
            }

            actionButton(
                title: isFavorite ? "Unfav" : "Fav",
                icon: isFavorite ? "star.fill" : "star",
                color: .yellow,
                action: onFavorite
            )

            actionButton(
                title: isJunk ? "Keep" : "Junk",
                icon: isJunk ? "arrow.uturn.left" : "trash",
                color: .red,
                action: onJunk
            )

            actionButton(title: "Drop", icon: "xmark", color: .gray, action: onDrop)
        }
    }

    private func actionButton(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(title)
                    .font(.system(size: 9))
            }
            .foregroundColor(color)
            .frame(width: 44, height: 44)
            .background(color.opacity(0.2))
            .cornerRadius(8)
        }
    }

    private var rarityColor: Color {
        switch content.rarity {
        case .common: return .gray
        case .uncommon: return .green
        case .rare: return .blue
        case .epic: return .purple
        }
    }

    private var descriptionText: String {
        switch content {
        case .resource(let type, _):
            return "A useful resource for crafting. \(type.displayName) can be combined with other materials."
        case .foodIngredient(let type):
            return "\(type.displayName) - A cooking ingredient. Combine with other foods to create meals."
        case .meal(let type, _, _):
            return "\(type.displayName) - Consume to restore health. Can be used even at full health."
        case .armor(let piece):
            return "\(piece.displayName) - Part of the \(piece.setType.displayName). Equip for stat bonuses."
        case .accessory(let item):
            return "\(item.displayName) - Equip to gain passive bonuses. Higher tiers provide better stats."
        }
    }
}
