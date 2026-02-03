//
//  InventoryViewModel.swift
//  driftwood
//

import SwiftUI
import Combine

enum InventoryPage: Int, CaseIterable {
    case items = 0
    case collectibles = 1
    case character = 2

    var title: String {
        switch self {
        case .items: return "Items"
        case .collectibles: return "Collectibles"
        case .character: return "Character"
        }
    }

    var iconName: String {
        switch self {
        case .items: return "wrench.and.screwdriver"
        case .collectibles: return "square.grid.3x3"
        case .character: return "person"
        }
    }
}

enum SortMode: String, CaseIterable {
    case type
    case rarity
    case recent

    var displayName: String {
        rawValue.capitalized
    }
}

class InventoryViewModel: ObservableObject {
    @Published var inventory: Inventory
    @Published var currentPage: InventoryPage = .collectibles
    @Published var selectedSlotIndex: Int?
    @Published var selectedRecipeId: String?
    @Published var sortMode: SortMode = .recent

    init(inventory: Inventory = .empty()) {
        self.inventory = inventory
    }

    // MARK: - Add Item

    func addItem(_ content: SlotContent) -> Bool {
        // track discovered resources for recipe unlocking
        if case .resource(let type, _) = content {
            inventory.discoveredResources.insert(type)
        }
        if content.isMeal {
            return addMeal(content)
        }
        return addToResourceSlots(content)
    }

    private func addMeal(_ content: SlotContent) -> Bool {
        for i in 0..<Inventory.mealSlotCount {
            if inventory.collectibles[i].isEmpty {
                inventory.collectibles[i].content = content
                inventory.collectibles[i].addedAt = Date()
                return true
            }
        }
        return false // meal slots full
    }

    private func addToResourceSlots(_ content: SlotContent) -> Bool {
        // try to stack with existing
        if content.isStackable {
            if case .resource(let type, let qty) = content {
                for i in Inventory.mealSlotCount..<Inventory.totalSlotCount {
                    if let existing = inventory.collectibles[i].content,
                       case .resource(let existingType, let existingQty) = existing,
                       existingType == type && existingQty < 99 {
                        let newQty = min(existingQty + qty, 99)
                        inventory.collectibles[i].content = .resource(type: type, quantity: newQty)
                        let remaining = qty - (newQty - existingQty)
                        if remaining > 0 {
                            return addToResourceSlots(.resource(type: type, quantity: remaining))
                        }
                        return true
                    }
                }
            }
        }

        // find empty slot
        for i in Inventory.mealSlotCount..<Inventory.totalSlotCount {
            if inventory.collectibles[i].isEmpty {
                inventory.collectibles[i].content = content
                inventory.collectibles[i].addedAt = Date()
                return true
            }
        }
        return false // inventory full
    }

    // MARK: - Remove Item

    func removeItem(at index: Int) {
        guard index >= 0 && index < inventory.collectibles.count else { return }
        inventory.collectibles[index].clear()
    }

    func decrementStack(at index: Int, by amount: Int = 1) {
        guard index >= 0 && index < inventory.collectibles.count else { return }
        guard let content = inventory.collectibles[index].content else { return }

        if case .resource(let type, let qty) = content {
            let newQty = qty - amount
            if newQty <= 0 {
                inventory.collectibles[index].clear()
            } else {
                inventory.collectibles[index].content = .resource(type: type, quantity: newQty)
            }
        } else {
            inventory.collectibles[index].clear()
        }
    }

    // MARK: - Equipment

    func equipArmor(_ piece: ArmorPiece, from slotIndex: Int) {
        let oldPiece = inventory.equipment.equip(piece)
        inventory.collectibles[slotIndex].clear()

        if let old = oldPiece {
            _ = addItem(.armor(piece: old))
        }
    }

    func unequipArmor(_ slot: ArmorSlotType) {
        guard let piece = inventory.equipment.unequip(slot) else { return }
        _ = addItem(.armor(piece: piece))
    }

    func equipAccessory(_ accessory: Accessory, from slotIndex: Int) {
        let oldAccessory = inventory.accessories.equip(accessory)
        inventory.collectibles[slotIndex].clear()

        if let old = oldAccessory {
            _ = addItem(.accessory(item: old))
        }
    }

    func unequipAccessory(_ slot: AccessorySlotType) {
        guard let accessory = inventory.accessories.unequip(slot) else { return }
        _ = addItem(.accessory(item: accessory))
    }

    // MARK: - Use Meal

    func useMeal(at index: Int, player: inout Player, effectiveMaxHealth: Int) {
        guard index >= 0 && index < Inventory.mealSlotCount else { return }
        guard let content = inventory.collectibles[index].content else { return }

        if case .meal(_, let healAmount, let tempHearts) = content {
            player.health = min(player.health + healAmount, effectiveMaxHealth)
            // temp hearts would be handled separately
            _ = tempHearts // placeholder for future temp heart system
            inventory.collectibles[index].clear()
        }
    }

    // MARK: - Favorites & Junk

    func toggleFavorite(at index: Int) {
        guard index >= 0 && index < inventory.collectibles.count else { return }
        guard !inventory.collectibles[index].isEmpty else { return }
        inventory.collectibles[index].isFavorite.toggle()
        if inventory.collectibles[index].isFavorite {
            inventory.collectibles[index].isJunk = false
        }
    }

    func toggleJunk(at index: Int) {
        guard index >= 0 && index < inventory.collectibles.count else { return }
        guard !inventory.collectibles[index].isEmpty else { return }
        inventory.collectibles[index].isJunk.toggle()
        if inventory.collectibles[index].isJunk {
            inventory.collectibles[index].isFavorite = false
        }
    }

    // MARK: - Sorting

    func sortCollectibles(by mode: SortMode) {
        sortMode = mode

        // sort only resource slots (indices 5-29), keep meal slots in place
        var resourceSlots = Array(inventory.collectibles[Inventory.mealSlotCount...])

        resourceSlots.sort { slot1, slot2 in
            // empty slots go to the end
            guard let content1 = slot1.content else { return false }
            guard let content2 = slot2.content else { return true }

            // favorites first
            if slot1.isFavorite != slot2.isFavorite {
                return slot1.isFavorite
            }

            // junk last (before empty)
            if slot1.isJunk != slot2.isJunk {
                return !slot1.isJunk
            }

            switch mode {
            case .type:
                return content1.displayName < content2.displayName
            case .rarity:
                return content1.rarity > content2.rarity
            case .recent:
                return slot1.addedAt > slot2.addedAt
            }
        }

        for (i, slot) in resourceSlots.enumerated() {
            inventory.collectibles[Inventory.mealSlotCount + i] = slot
        }
    }

    // MARK: - Selection

    func selectSlot(_ index: Int?) {
        selectedSlotIndex = index
    }

    func clearSelection() {
        selectedSlotIndex = nil
    }

    // MARK: - Helpers

    func isMealSlot(_ index: Int) -> Bool {
        index < Inventory.mealSlotCount
    }

    func canAddMeal() -> Bool {
        inventory.mealCount < Inventory.mealSlotCount
    }

    func hasEmptyResourceSlot() -> Bool {
        inventory.resourceSlots.contains { $0.isEmpty }
    }

    // MARK: - Crafting

    func selectRecipe(_ id: String?) {
        selectedRecipeId = id
    }

    func clearRecipeSelection() {
        selectedRecipeId = nil
    }

    func materialCount(for resource: ResourceType) -> Int {
        var total = 0
        for slot in inventory.collectibles {
            if case .resource(let type, let qty) = slot.content, type == resource {
                total += qty
            }
        }
        return total
    }

    func isRecipeUnlocked(_ recipe: Recipe) -> Bool {
        inventory.discoveredResources.contains(recipe.unlocksAfter)
    }

    var unlockedRecipes: [Recipe] {
        Recipe.allRecipes.filter { isRecipeUnlocked($0) }
    }

    func canCraft(_ recipe: Recipe) -> Bool {
        for material in recipe.materials {
            if materialCount(for: material.resource) < material.quantity {
                return false
            }
        }
        switch recipe.result {
        case .collectible(let content):
            if content.isMeal {
                return canAddMeal()
            }
            if content.isStackable {
                return true
            }
            return hasEmptyResourceSlot()
        case .toolUpgrade(let tool, let tier):
            return inventory.tools.tier(for: tool) < tier
        case .majorUpgrade(let upgrade):
            return !inventory.majorUpgrades.has(upgrade)
        }
    }

    func craft(_ recipe: Recipe) -> Bool {
        guard canCraft(recipe) else { return false }

        for material in recipe.materials {
            consumeMaterial(material.resource, quantity: material.quantity)
        }

        switch recipe.result {
        case .collectible(let content):
            _ = addItem(content)
        case .toolUpgrade(let tool, let tier):
            inventory.tools.setTier(tier, for: tool)
        case .majorUpgrade(let upgrade):
            inventory.majorUpgrades.unlock(upgrade)
        }

        selectedRecipeId = nil
        return true
    }

    private func consumeMaterial(_ resource: ResourceType, quantity: Int) {
        var remaining = quantity
        for i in 0..<inventory.collectibles.count {
            guard remaining > 0 else { break }
            if case .resource(let type, let qty) = inventory.collectibles[i].content, type == resource {
                let consumed = min(qty, remaining)
                remaining -= consumed
                if qty - consumed <= 0 {
                    inventory.collectibles[i].clear()
                } else {
                    inventory.collectibles[i].content = .resource(type: type, quantity: qty - consumed)
                }
            }
        }
    }
}
