# Crafting System - Product Requirements

## Summary
A crafting system integrated into the inventory UI that allows players to view unlocked recipes, check material requirements, and craft items that get added to their collectibles.

## Problem Statement
Players collect resources through fishing and other activities but currently have no way to combine these materials into useful items. A crafting system provides progression and purpose to resource gathering.

## Goals
- Display unlocked recipes in a grid format matching the collectibles layout (5 columns x 6 rows)
- Visually indicate craftability with color coding (green = craftable, red = missing materials)
- Show detailed material requirements when a recipe is selected
- Allow crafting when all materials are available
- Add crafted items to the collectibles inventory

## Non-Goals
- Recipe discovery/unlocking system (recipes will be predefined for now)
- Crafting stations or location-based crafting
- Crafting time delays or animations
- Recipe categories or filtering
- Multiple pages (can be added later)

## Target Users
Players who have gathered resources and want to create useful items like meals, equipment upgrades, or tools.

## Scope
### Included
- Recipe grid view (5x6 layout, matching collectibles)
- Red/green color coding based on material availability
- Recipe detail panel showing required materials
- Craft button that activates when materials are sufficient
- Integration with collectibles inventory for crafted items
- Material consumption on successful craft

### Excluded
- Recipe unlocking mechanics
- Crafting queue or batch crafting
- Recipe search or sorting
- Crafting achievements or statistics
