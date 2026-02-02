# Fishing System - Product Requirements

## Summary

Implement a complete fishing system for Driftwood Kingdom, including tool selection UI, fishing rod mechanics, water proximity detection, and the fishing minigame with loot collection.

## Problem Statement

The game needs a core gameplay loop beyond exploration. Fishing provides:
- Engaging minigame mechanics with skill-based timing
- Resource collection for crafting and progression
- Equipment acquisition (Old Set, Mossy Set armor)
- Leveling system (1-10) with expanding loot tables

Players currently have no way to equip tools or interact with water tiles beyond swimming.

## Goals

- Give players a fishing rod at game start
- Create intuitive tool selection via hold-drag quick menu
- Enable fishing when near water with rod equipped
- Implement timing-based fishing minigame with perfect catch zones
- Auto-collect catches to inventory with full-inventory handling
- Track fishing level and total catches for loot table progression

## Non-Goals

- Fish shadows/visual hints (future enhancement)
- River/pond water types (only ocean for now)
- Fishing fortune from armor/accessories (armor not yet implemented)
- Rod upgrades/tiers (start with tier 1 rod only)
- Combo meter display (track internally, UI later)
- Sailboat fishing (land-based only for now)

## Target Users

All players - fishing is a core progression mechanic available from game start.

## Scope

### Included

1. **Starter Fishing Rod**: Player begins with tier 1 fishing rod in inventory
2. **Quick Tool Menu**: Hold button shows horizontal tool row, drag to equip
3. **Fishing Detection**: Show fish button when rod equipped, within 1 tile of water, not swimming
4. **Fishing Minigame**: Bar with moving indicator, click in green zone to catch
5. **Loot System**: Roll against loot table based on fishing level, add to inventory
6. **Level Progression**: Track total catches, level up at thresholds (10, 25, 50, 100, etc.)

### UI Components

- Tool quick-select overlay (horizontal row of tools)
- Equipped tool indicator on HUD
- "Fish" action button (context-sensitive)
- Fishing minigame overlay (timing bar)
- Catch result notification

### Data

- Equipped tool tracking in player state
- Fishing level and total catches in save profile
- Loot tables per fishing level (from fishing.md)
