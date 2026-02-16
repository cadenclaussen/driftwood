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
    let onAdd: (() -> Void)?

    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            headerSection
            Divider()
            descriptionSection
            statsSection
            Divider()
            actionButtons
        }
        .padding(Theme.Spacing.lg)
        .background(Theme.Color.panelBackgroundLight)
        .cornerRadius(Theme.Radius.panel)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.panel)
                .stroke(rarityColor, lineWidth: Theme.Border.standard)
        )
        .frame(maxWidth: Theme.Size.itemPanelMaxWidth)
    }

    private var headerSection: some View {
        HStack {
            itemHeaderIcon

            VStack(alignment: .leading, spacing: Theme.Spacing.xxxs) {
                Text(content.displayName)
                    .font(Theme.Font.bodyBold)
                    .foregroundColor(Theme.Color.textPrimary)

                Text(content.rarity.displayName)
                    .font(Theme.Font.caption)
                    .foregroundColor(rarityColor)
            }

            Spacer()

            Button(action: onClose) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: Theme.Size.iconMedium))
                    .foregroundColor(Theme.Color.textSecondary)
            }
        }
    }

    private var descriptionSection: some View {
        Text(descriptionText)
            .font(Theme.Font.caption)
            .foregroundColor(Theme.Color.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var statsSection: some View {
        switch content {
        case .meal(_, let healAmount, let tempHearts):
            HStack {
                Label("\(healAmount)", systemImage: "heart.fill")
                    .foregroundColor(Theme.Color.health)
                if tempHearts > 0 {
                    Label("+\(tempHearts) temp", systemImage: "heart")
                        .foregroundColor(Theme.Color.selection)
                }
            }
            .font(Theme.Font.caption)

        case .armor(let piece):
            armorStatsView(piece.stats)

        case .accessory(let item):
            accessoryStatsView(item.stats)

        case .resource(_, let quantity):
            Text("Quantity: \(quantity)")
                .font(Theme.Font.caption)
                .foregroundColor(Theme.Color.textSecondary)

        default:
            EmptyView()
        }
    }

    private func armorStatsView(_ stats: ArmorStats) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
            if stats.bonusHearts > 0 {
                statRow(icon: "heart.fill", value: "+\(String(format: "%.1f", stats.bonusHearts))", color: Theme.Color.statHealth)
            }
            if stats.fishingFortune > 0 {
                fishFortuneRow(value: stats.fishingFortune)
            }
            if stats.defense > 0 {
                statRow(icon: "shield.fill", value: "+\(stats.defense) Defense", color: Theme.Color.statDefense)
            }
            if stats.magicRegen > 0 {
                statRow(icon: "sparkles", value: "+\(String(format: "%.1f", stats.magicRegen)) MP/s", color: Theme.Color.statMagic)
            }
            if stats.movementSpeed > 0 {
                statRow(icon: "figure.run", value: "+\(Int(stats.movementSpeed * 100))% Speed", color: Theme.Color.statSpeed)
            }
        }
    }

    private func accessoryStatsView(_ stats: AccessoryStats) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
            if stats.bonusHealth > 0 {
                statRow(icon: "heart.fill", value: "+\(String(format: "%.1f", stats.bonusHealth))", color: Theme.Color.statHealth)
            }
            if stats.maxMP > 0 {
                statRow(icon: "sparkles", value: "+\(Int(stats.maxMP)) Max MP", color: Theme.Color.statMagic)
            }
            if stats.mpRegen > 0 {
                statRow(icon: "sparkles", value: "+\(String(format: "%.1f", stats.mpRegen)) MP/s", color: Theme.Color.statMagic)
            }
            if stats.defense > 0 {
                statRow(icon: "shield.fill", value: "+\(stats.defense) Defense", color: Theme.Color.statDefense)
            }
            if stats.fishingFortune > 0 {
                fishFortuneRow(value: stats.fishingFortune)
            }
            if stats.movementSpeed > 0 {
                statRow(icon: "figure.run", value: "+\(Int(stats.movementSpeed * 100))% Speed", color: Theme.Color.statSpeed)
            }
        }
    }

    private func statRow(icon: String, value: String, color: Color) -> some View {
        HStack(spacing: Theme.Spacing.xxs) {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(value)
                .foregroundColor(Theme.Color.textPrimary)
        }
        .font(Theme.Font.label)
    }

    private func fishFortuneRow(value: Int) -> some View {
        HStack(spacing: Theme.Spacing.xxs) {
            Image("Fish")
                .resizable()
                .interpolation(.none)
                .frame(width: Theme.Size.iconLarge, height: Theme.Size.iconLarge)
            Text("+\(value) Fortune")
                .foregroundColor(Theme.Color.textPrimary)
        }
        .font(Theme.Font.label)
    }

    private var actionButtons: some View {
        HStack(spacing: Theme.Spacing.sm) {
            if let onUse = onUse, content.isMeal {
                actionButton(title: "Use", icon: "fork.knife", color: .orange, action: onUse)
            }

            if let onEquip = onEquip, content.isEquippable {
                actionButton(title: "Equip", icon: "square.and.arrow.down", color: .blue, action: onEquip)
            }

            if let onAdd = onAdd, content.isResource {
                actionButton(title: "Add", icon: "plus", color: .green, action: onAdd)
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
            VStack(spacing: Theme.Spacing.xxxs) {
                Image(systemName: icon)
                    .font(.system(size: Theme.Size.iconMicro))
                Text(title)
                    .font(Theme.Font.nano)
            }
            .foregroundColor(color)
            .frame(width: Theme.Size.actionButton, height: Theme.Size.actionButton)
            .background(color.opacity(Theme.Opacity.faint))
            .cornerRadius(Theme.Radius.button)
        }
    }

    @ViewBuilder
    private var itemHeaderIcon: some View {
        if content.usesCustomImage {
            Image(content.iconName)
                .resizable()
                .interpolation(.none)
                .frame(width: Theme.Size.slotImage, height: Theme.Size.slotImage)
        } else {
            Image(systemName: content.iconName)
                .font(.system(size: Theme.Size.iconHuge))
                .foregroundColor(rarityColor)
        }
    }

    private var rarityColor: Color {
        Theme.Color.rarity(content.rarity)
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
