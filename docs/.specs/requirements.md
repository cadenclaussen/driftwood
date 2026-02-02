# Fishing System - Requirements

## Functional Requirements

### FR-1: Starter Fishing Rod
- **Type**: Ubiquitous
- **Statement**: The system shall give new save profiles a tier 1 fishing rod in their tool inventory.
- **Acceptance Criteria**:
  - [ ] New profiles have `fishingRodTier = 1` in `ToolInventory`
  - [ ] Existing empty profiles are unaffected until played
- **Priority**: Must
- **Notes**: Modify `SaveProfile.empty()` or `Inventory.empty()` to include starter rod

### FR-2: Equipped Tool State
- **Type**: Ubiquitous
- **Statement**: The player state shall track which tool is currently equipped (or none).
- **Acceptance Criteria**:
  - [ ] Player model has `equippedTool: ToolType?` property
  - [ ] Equipped tool persists in SaveProfile
  - [ ] Default equipped tool is `nil`
- **Priority**: Must
- **Notes**: Add to Player.swift and SaveProfile

### FR-3: Tool Quick Menu Activation
- **Type**: Event-Driven
- **Statement**: When the player holds the tool button for 0.3+ seconds, the system shall display a horizontal row of available tools.
- **Acceptance Criteria**:
  - [ ] Tool button visible on HUD (bottom area)
  - [ ] Long press (0.3s) triggers menu appearance
  - [ ] Menu shows only tools player owns (tier > 0)
  - [ ] Menu appears as horizontal row above the button
- **Priority**: Must
- **Notes**: Use gesture with minimumDuration

### FR-4: Tool Selection via Drag
- **Type**: Event-Driven
- **Statement**: When the player drags over a tool in the quick menu and releases, the system shall equip that tool.
- **Acceptance Criteria**:
  - [ ] Dragging finger highlights hovered tool
  - [ ] Releasing on a tool equips it
  - [ ] Releasing outside menu cancels selection
  - [ ] Menu dismisses after selection/cancel
- **Priority**: Must
- **Notes**: Track drag position relative to tool icons

### FR-5: Tool Quick Menu Dismiss
- **Type**: Event-Driven
- **Statement**: When the player releases without selecting a tool, the system shall dismiss the menu without changing equipped tool.
- **Acceptance Criteria**:
  - [ ] Releasing finger outside tool icons dismisses menu
  - [ ] Equipped tool remains unchanged
- **Priority**: Must

### FR-6: Equipped Tool HUD Indicator
- **Type**: State-Driven
- **Statement**: While a tool is equipped, the system shall display the tool icon on the HUD.
- **Acceptance Criteria**:
  - [ ] Tool icon visible near tool button when equipped
  - [ ] No icon shown when `equippedTool == nil`
  - [ ] Icon updates immediately on equip change
- **Priority**: Should
- **Notes**: Small icon badge on or near tool button

### FR-7: Water Proximity Detection
- **Type**: Ubiquitous
- **Statement**: The system shall calculate whether the player is within 1 tile of water.
- **Acceptance Criteria**:
  - [ ] Check tiles in cardinal directions (up/down/left/right)
  - [ ] Return true if any adjacent tile is swimmable
  - [ ] Distance is 1 tile (24pt) from player center
- **Priority**: Must
- **Notes**: Add `isNearWater()` method to GameViewModel

### FR-8: Fish Button Visibility
- **Type**: State-Driven
- **Statement**: While the fishing rod is equipped AND the player is within 1 tile of water AND the player is not swimming, the system shall display a "Fish" action button.
- **Acceptance Criteria**:
  - [ ] Button appears when all 3 conditions met
  - [ ] Button disappears when any condition fails
  - [ ] Button is clearly distinguishable from other HUD elements
- **Priority**: Must
- **Notes**: Position near joystick or action area

### FR-9: Fishing Minigame Activation
- **Type**: Event-Driven
- **Statement**: When the player taps the Fish button, the system shall pause normal gameplay and start the fishing minigame.
- **Acceptance Criteria**:
  - [ ] Movement disabled during minigame
  - [ ] Fishing overlay appears fullscreen
  - [ ] Minigame state initialized
- **Priority**: Must

### FR-10: Fishing Minigame Bar Display
- **Type**: Ubiquitous
- **Statement**: The fishing minigame shall display a horizontal bar with a green catch zone and a moving indicator.
- **Acceptance Criteria**:
  - [ ] Bar spans ~80% of screen width
  - [ ] Green zone is randomly positioned each catch
  - [ ] Green zone has visible "perfect" sub-zone in center
  - [ ] Indicator moves smoothly left-to-right or bounces
- **Priority**: Must
- **Notes**: Green zone width ~15-20% of bar, perfect zone ~5%

### FR-11: Fishing Minigame Catch Attempt
- **Type**: Event-Driven
- **Statement**: When the player taps during the minigame, the system shall evaluate whether the indicator is in the catch zone.
- **Acceptance Criteria**:
  - [ ] Tap anywhere on screen triggers evaluation
  - [ ] If indicator in green zone: success
  - [ ] If indicator in perfect zone: perfect catch
  - [ ] If indicator outside green zone: failure
- **Priority**: Must

### FR-12: Fishing Minigame Success Flow
- **Type**: Event-Driven
- **Statement**: When the player successfully catches, the system shall either show the next catch bar or end the session.
- **Acceptance Criteria**:
  - [ ] Track remaining catches based on fortune
  - [ ] On success: decrement catches, show new bar if remaining > 0
  - [ ] On final catch: end minigame, show results
- **Priority**: Must
- **Notes**: Catches = floor(fortune / 10) + 1

### FR-13: Fishing Minigame Failure
- **Type**: Event-Driven
- **Statement**: When the player misses the catch zone, the system shall end the minigame session with partial results.
- **Acceptance Criteria**:
  - [ ] Missing ends the session immediately
  - [ ] Player keeps catches made before failure
  - [ ] Combo meter resets (internal tracking)
- **Priority**: Must

### FR-14: Loot Roll on Catch
- **Type**: Event-Driven
- **Statement**: When a catch succeeds, the system shall roll against the loot table for the player's fishing level.
- **Acceptance Criteria**:
  - [ ] Use loot table from fishing.md for current level
  - [ ] Random roll determines item type
  - [ ] Handle special sets (Old Set, Mossy Set) per rules
- **Priority**: Must
- **Notes**: Implement LootTable model with level-based tables

### FR-15: Add Catch to Inventory
- **Type**: Event-Driven
- **Statement**: When a loot item is determined, the system shall attempt to add it to the player's inventory.
- **Acceptance Criteria**:
  - [ ] Resources stack in collectibles slots
  - [ ] Armor pieces go to collectibles (equip later)
  - [ ] If inventory full: item is lost (no overflow)
- **Priority**: Must
- **Notes**: Use existing `InventoryViewModel.addItem()`

### FR-16: Fishing Level Tracking
- **Type**: Ubiquitous
- **Statement**: The save profile shall track fishing level (1-10) and total catches.
- **Acceptance Criteria**:
  - [ ] `fishingLevel: Int` (1-10) in SaveProfile
  - [ ] `totalCatches: Int` in SaveProfile
  - [ ] Level up at thresholds: 10, 25, 50, 100, 250, 500, 1000, 2500, 5000
- **Priority**: Must

### FR-17: Fishing Level Progression
- **Type**: Event-Driven
- **Statement**: When total catches reaches a level threshold, the system shall increase fishing level.
- **Acceptance Criteria**:
  - [ ] Check after each successful catch
  - [ ] Level up unlocks new loot table entries
  - [ ] Max level is 10
- **Priority**: Must

### FR-18: Fishing Session Results
- **Type**: Event-Driven
- **Statement**: When the fishing minigame ends, the system shall display a summary of caught items.
- **Acceptance Criteria**:
  - [ ] Show list/grid of items caught this session
  - [ ] Indicate items lost due to full inventory
  - [ ] Dismiss button returns to gameplay
- **Priority**: Should

### FR-19: Perfect Catch Tracking
- **Type**: Event-Driven
- **Statement**: When the player catches in the perfect zone, the system shall increment the combo counter.
- **Acceptance Criteria**:
  - [ ] Combo increments on perfect catch
  - [ ] Combo resets on miss or non-perfect catch
  - [ ] Each combo level adds +1 fishing fortune for session
- **Priority**: Should
- **Notes**: Session-only bonus, no UI for now

## Non-Functional Requirements

### NFR-1: Minigame Responsiveness
- **Category**: Performance
- **Statement**: The fishing minigame indicator shall update at 60fps with no input lag.
- **Acceptance Criteria**:
  - [ ] Indicator animation smooth at 60fps
  - [ ] Tap detection < 16ms latency
- **Priority**: Must

### NFR-2: Tool Menu Usability
- **Category**: Usability
- **Statement**: The tool quick menu shall be operable with one thumb on iPhone 16e.
- **Acceptance Criteria**:
  - [ ] Tool icons minimum 44pt touch target
  - [ ] Menu positioned within thumb reach from button
  - [ ] Visual feedback on hover/selection
- **Priority**: Must

### NFR-3: State Persistence
- **Category**: Reliability
- **Statement**: The fishing level, total catches, and equipped tool shall persist across app restarts.
- **Acceptance Criteria**:
  - [ ] Data saved to SaveProfile
  - [ ] Auto-save includes fishing state
- **Priority**: Must

## Constraints

- iOS 17+ (SwiftUI gestures, animations)
- Must work in landscape orientation only
- iPhone 16e screen dimensions (primary target)
- Loot tables defined in docs/outline/minigames/fishing.md are authoritative

## Assumptions

- Player can only fish from land (not while swimming or in boat)
- Tier 1 fishing rod provides +0 fortune (base: 1 catch per session)
- Only ocean water type implemented initially
- Armor from fishing (Old Set, Mossy Set) goes to collectibles, not auto-equip

## Edge Cases

- **Inventory full during fishing**: Catches are lost, show "Inventory Full" indicator
- **All tool slots empty**: Tool button still visible but menu shows "No Tools"
- **Player enters water while fishing**: Cancel fishing session (shouldn't happen since button hidden)
- **App backgrounded during minigame**: Pause minigame, resume on foreground
- **Multiple perfect catches**: Combo stacks, fortune bonus applies to remaining catches in session
- **Level 10 reached**: No further level ups, continue tracking total catches
