# Sailboat - Requirements

## Functional Requirements

### FR-1: Sailboat Crafting Recipe
- **Type**: Ubiquitous
- **Statement**: The crafting system shall include a sailboat recipe requiring 1 Sail, 1 Wheel, 20 Metal Scraps, and 10 Wood
- **Acceptance Criteria**:
  - [ ] Recipe appears in crafting UI after obtaining a Sail
  - [ ] Recipe consumes correct materials when crafted
  - [ ] Crafting grants the sailboat to the player's inventory
- **Priority**: Must
- **Notes**: Recipe already exists in Recipe.swift, but crafting result needs to grant actual sailboat ownership

### FR-2: Sailboat Inventory Item
- **Type**: Ubiquitous
- **Statement**: The inventory system shall display the sailboat as a major upgrade item with the provided icon
- **Acceptance Criteria**:
  - [ ] Sailboat appears in Character page (Page 3) under Major Upgrades
  - [ ] Uses provided sailboat inventory icon asset
  - [ ] Shows "Sailboat" as display name
- **Priority**: Must
- **Notes**: MajorUpgradeType.sailboat already exists in ItemType.swift

### FR-3: Sailboat Summoning Conditions
- **Type**: State-Driven
- **Statement**: While the player owns a sailboat, is 1 tile from water, and is facing water, the system shall enable sailboat summoning
- **Acceptance Criteria**:
  - [ ] Summon option only available when player owns sailboat
  - [ ] Summon option only available when exactly 1 tile from water
  - [ ] Summon option only available when facing toward water
  - [ ] Summon option disabled while swimming
- **Priority**: Must

### FR-4: Sailboat Summoning Action
- **Type**: Event-Driven
- **Statement**: When the player triggers summon while conditions are met, the sailboat shall appear on the water tile the player is facing
- **Acceptance Criteria**:
  - [ ] Sailboat spawns on the water tile in front of player
  - [ ] Sailboat is positioned correctly for boarding
  - [ ] If sailboat exists elsewhere in world, it moves to new location
- **Priority**: Must

### FR-5: Boarding Prompt
- **Type**: State-Driven
- **Statement**: While the player is adjacent to the sailboat in water and not swimming, the system shall display a "Board Sailboat" prompt
- **Acceptance Criteria**:
  - [ ] Prompt appears as contextual text box
  - [ ] Prompt only shows when player is within 1 tile of sailboat
  - [ ] Prompt hidden while player is swimming
  - [ ] Tapping prompt boards the player
- **Priority**: Must

### FR-6: Boarding Action
- **Type**: Event-Driven
- **Statement**: When the player taps the board prompt, the player shall transition to sailing state on the sailboat
- **Acceptance Criteria**:
  - [ ] Player position moves to sailboat position
  - [ ] Player state changes to sailing (not walking, not swimming)
  - [ ] Camera follows sailboat
  - [ ] Sailboat sprite replaces player sprite visually
- **Priority**: Must

### FR-7: Sailing Movement
- **Type**: State-Driven
- **Statement**: While sailing, the joystick shall move the sailboat at 4x swim speed (without sprint)
- **Acceptance Criteria**:
  - [ ] Same joystick controls as walking
  - [ ] Movement speed is 4x base swim speed (0.5x walk = 2x walk speed)
  - [ ] Sailboat moves in direction of joystick input
  - [ ] No stamina consumption while sailing
- **Priority**: Must

### FR-8: Wind Direction Display
- **Type**: State-Driven
- **Statement**: While sailing, the HUD shall display an arrow indicating the current wind direction
- **Acceptance Criteria**:
  - [ ] Wind arrow visible on HUD
  - [ ] Arrow rotates to show wind direction
  - [ ] Arrow updates as wind direction changes
- **Priority**: Must

### FR-9: Wind Effect on Sailboat
- **Type**: State-Driven
- **Statement**: While sailing, the wind shall apply a gentle push to the sailboat in the wind direction
- **Acceptance Criteria**:
  - [ ] Sailboat drifts slightly in wind direction
  - [ ] Push is noticeable but not overwhelming
  - [ ] Push applies continuously while sailing
  - [ ] Push combines with player joystick input
- **Priority**: Must

### FR-10: Wind Direction Drift
- **Type**: Ubiquitous
- **Statement**: The wind direction shall gradually and randomly change over time
- **Acceptance Criteria**:
  - [ ] Wind direction changes smoothly (not sudden jumps)
  - [ ] Changes are random in nature
  - [ ] Wind never stops completely
- **Priority**: Must

### FR-11: Land Collision
- **Type**: Event-Driven
- **Statement**: When the sailboat contacts land tiles, the sailboat shall stop movement in that direction
- **Acceptance Criteria**:
  - [ ] Sailboat cannot move onto land tiles
  - [ ] Sailboat stops at water's edge
  - [ ] Player can still move in other directions (slide along coast)
- **Priority**: Must

### FR-12: Disembark Prompt
- **Type**: State-Driven
- **Statement**: While sailing and adjacent to land, the system shall display a "Disembark" prompt
- **Acceptance Criteria**:
  - [ ] Prompt appears when sailboat is within 1 tile of land
  - [ ] Prompt shows as contextual text box
  - [ ] Tapping prompt disembarks the player
- **Priority**: Must

### FR-13: Disembark Action
- **Type**: Event-Driven
- **Statement**: When the player taps the disembark prompt, the player shall exit the sailboat onto adjacent land
- **Acceptance Criteria**:
  - [ ] Player position moves to nearest land tile
  - [ ] Player state changes from sailing to walking
  - [ ] Sailboat remains at current water position
  - [ ] Player sprite replaces sailboat visually
- **Priority**: Must

### FR-14: Sailboat World Persistence
- **Type**: Ubiquitous
- **Statement**: The sailboat shall remain at its last position in the world when not in use
- **Acceptance Criteria**:
  - [ ] Sailboat stays where player disembarked
  - [ ] Sailboat position persists across save/load
  - [ ] Sailboat visible in world when not being used
- **Priority**: Must

### FR-15: Sailboat Ownership Persistence
- **Type**: Ubiquitous
- **Statement**: The save system shall persist sailboat ownership status
- **Acceptance Criteria**:
  - [ ] Sailboat ownership saved to profile
  - [ ] Ownership restored on game load
- **Priority**: Must

### FR-16: Sailboat Position Persistence
- **Type**: Ubiquitous
- **Statement**: The save system shall persist the sailboat's world position
- **Acceptance Criteria**:
  - [ ] Sailboat position saved to profile
  - [ ] Position restored on game load
  - [ ] Sailboat appears at saved position when game loads
- **Priority**: Must

### FR-17: Sailboat Visual Representation
- **Type**: Ubiquitous
- **Statement**: The sailboat shall be rendered as a black rectangle larger than the character sprite (placeholder)
- **Acceptance Criteria**:
  - [ ] Sailboat displays as black rectangle
  - [ ] Rectangle is visibly larger than player sprite (32x32)
  - [ ] Placeholder is clearly visible on water tiles
- **Priority**: Must
- **Notes**: Temporary placeholder until real sprite is provided

## Non-Functional Requirements

### NFR-1: Sailing Responsiveness
- **Category**: Performance
- **Statement**: The sailing controls shall respond with the same latency as walking controls
- **Acceptance Criteria**:
  - [ ] No perceptible input lag when sailing
  - [ ] Joystick response matches walking feel
- **Priority**: Must

### NFR-2: Wind Arrow Clarity
- **Category**: Usability
- **Statement**: The wind direction arrow shall be clearly visible and distinguishable on the HUD
- **Acceptance Criteria**:
  - [ ] Arrow contrasts with game background
  - [ ] Arrow direction is unambiguous
  - [ ] Arrow size is appropriate for mobile display
- **Priority**: Should

### NFR-3: Prompt Discoverability
- **Category**: Usability
- **Statement**: The board and disembark prompts shall be immediately noticeable when conditions are met
- **Acceptance Criteria**:
  - [ ] Prompts appear in consistent, visible location
  - [ ] Text is readable on mobile
  - [ ] Prompts don't obstruct gameplay
- **Priority**: Should

## Constraints

- Sailboat cannot travel on land tiles
- No fishing from sailboat (per PRD non-goals)
- Single sailboat per player (no multiple boats)
- No boat damage or durability system
- Placeholder sprite (black rectangle) until real asset provided

## Assumptions

- World water tiles are already properly marked as swimmable
- Joystick input system is already functional (used for walking)
- Save system can accommodate additional fields (sailboat position, ownership)
- HUD system exists and can accommodate new wind arrow element
- Player swimming state detection already works correctly

## Edge Cases

- **Summon while sailboat is far away**: Sailboat teleports to player's facing tile
- **Disembark with no valid land nearby**: Prompt not shown (only shows when land is adjacent)
- **Save while sailing**: Save sailboat position; on load, player starts on sailboat
- **Summon at world boundary**: Only allow if facing tile is valid water
- **Wind pushes boat into land**: Collision stops boat; wind push continues but boat doesn't move
- **Player dies while sailing**: Respawn on land at last valid land position (like swimming death)
