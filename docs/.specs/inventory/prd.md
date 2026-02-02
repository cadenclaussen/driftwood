# Inventory System - Product Requirements

## Summary

A 3-page inventory system for the Driftwood Kingdom game that manages items, collectibles, and character equipment. Players can organize, sort, and tag items for efficient gameplay and trading.

## Problem Statement

Players need a way to store, organize, and manage the items they collect throughout the game including tools, gear, resources, meals, armor, and accessories. Without an inventory system, players cannot progress through crafting, combat upgrades, or resource management aspects of the game.

## Goals

- Provide organized storage across 3 distinct inventory pages
- Support item stacking for resources (up to 99)
- Enable equipment management (armor, accessories)
- Allow quality-of-life features: sorting, favorites, junk tagging
- Integrate with save/load system for persistence
- Clear visual feedback for item types, rarities, and states

## Non-Goals

- Multiplayer item trading (single-player game)
- Real-time inventory sync (not needed)
- Drag-and-drop reorganization (v1 uses tap-to-select)
- Storage chest UI (separate feature)
- Shop/merchant UI (separate feature)

## Target Users

Single players of Driftwood Kingdom who need to manage collected items, equip gear, and organize resources for crafting and progression.

## Scope

### Page 1: Items
- **Gear section**: Sails (4 tiers), Motor (1 tier), Pouch (3 tiers)
- **Tools section**: Fishing Rod (4 tiers), Sword (3 tiers), Axe (3 tiers), Wand (1 tier)
- Display current tier and upgrade path

### Page 2: Collectibles (5x6 grid = 30 slots)
- **Top row (5 slots)**: Meals only, max 5 carried
- **Bottom 25 slots**: Resources, stackable up to 99
- Food ingredients are NOT stackable (1 per slot)
- Non-food resources ARE stackable

### Page 3: Character
- **Armor (4 slots)**: Hat, Shirt, Pants, Boots
- **Accessories (4 slots)**: Anklet, Ring, Chain, Bracelet (5 upgrade tiers each)
- **Major Upgrades display**: Sailboat, Flippers, Wings, Pegasus Boots

### Inventory Features
- **Sorting**: By type, rarity, or recent acquisition
- **Favorites**: Mark slots for quick access
- **Junk tag**: Mark items for quick-sell at shops
- **Toggle button**: Access inventory from HUD
