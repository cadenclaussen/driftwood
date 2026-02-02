//
//  CollectibleSlot.swift
//  driftwood
//

import Foundation

// MARK: - Slot Content

enum SlotContent: Codable, Equatable {
    case resource(type: ResourceType, quantity: Int)
    case foodIngredient(type: FoodIngredientType)
    case meal(type: MealType, healAmount: Int, tempHearts: Int)
    case armor(piece: ArmorPiece)
    case accessory(item: Accessory)

    var displayName: String {
        switch self {
        case .resource(let type, _):
            return type.displayName
        case .foodIngredient(let type):
            return type.displayName
        case .meal(let type, _, _):
            return type.displayName
        case .armor(let piece):
            return piece.displayName
        case .accessory(let item):
            return item.displayName
        }
    }

    var iconName: String {
        switch self {
        case .resource(let type, _):
            return type.iconName
        case .foodIngredient(let type):
            return type.iconName
        case .meal(let type, _, _):
            return type.iconName
        case .armor(let piece):
            return piece.iconName
        case .accessory(let item):
            return item.iconName
        }
    }

    var rarity: ItemRarity {
        switch self {
        case .resource(let type, _):
            return type.rarity
        case .foodIngredient(let type):
            return type.rarity
        case .meal(let type, _, _):
            return type.rarity
        case .armor(let piece):
            return piece.rarity
        case .accessory(let item):
            return item.rarity
        }
    }

    var quantity: Int {
        switch self {
        case .resource(_, let qty):
            return qty
        default:
            return 1
        }
    }

    var isMeal: Bool {
        if case .meal = self { return true }
        return false
    }

    var isArmor: Bool {
        if case .armor = self { return true }
        return false
    }

    var isAccessory: Bool {
        if case .accessory = self { return true }
        return false
    }

    var isEquippable: Bool {
        isArmor || isAccessory
    }

    var isStackable: Bool {
        if case .resource = self { return true }
        return false
    }

    func canStack(with other: SlotContent) -> Bool {
        guard isStackable else { return false }
        if case .resource(let myType, let myQty) = self,
           case .resource(let otherType, _) = other {
            return myType == otherType && myQty < 99
        }
        return false
    }

    func withQuantity(_ newQuantity: Int) -> SlotContent {
        if case .resource(let type, _) = self {
            return .resource(type: type, quantity: min(newQuantity, 99))
        }
        return self
    }
}

// MARK: - Collectible Slot

struct CollectibleSlot: Codable, Identifiable, Equatable {
    let id: UUID
    var content: SlotContent?
    var isFavorite: Bool
    var isJunk: Bool
    var addedAt: Date

    var isEmpty: Bool { content == nil }

    init() {
        self.id = UUID()
        self.content = nil
        self.isFavorite = false
        self.isJunk = false
        self.addedAt = Date()
    }

    init(id: UUID, content: SlotContent?, isFavorite: Bool = false, isJunk: Bool = false, addedAt: Date = Date()) {
        self.id = id
        self.content = content
        self.isFavorite = isFavorite
        self.isJunk = isJunk
        self.addedAt = addedAt
    }

    init(content: SlotContent) {
        self.id = UUID()
        self.content = content
        self.isFavorite = false
        self.isJunk = false
        self.addedAt = Date()
    }

    mutating func clear() {
        content = nil
        isFavorite = false
        isJunk = false
    }
}
