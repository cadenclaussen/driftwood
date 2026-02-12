# Teleport and Map System - Requirements

## Functional Requirements

### FR-1: Second Island Generation
- **Type**: Ubiquitous
- **Statement**: The system shall generate a second 10x10 grass island centered at tile (500, 450) with beach tiles on the left edge.
- **Acceptance Criteria**:
  - [ ] Island spans tiles (495, 445) to (504, 454)
  - [ ] Left column (x=495) is beach tiles
  - [ ] Remaining tiles are grass
  - [ ] Island is surrounded by ocean
- **Priority**: Must

### FR-2: Teleport Pad Tile Type
- **Type**: Ubiquitous
- **Statement**: The system shall include a teleport pad tile type that renders as purple and is walkable.
- **Acceptance Criteria**:
  - [ ] TileType.teleportPad case exists
  - [ ] Tile renders with purple color
  - [ ] Tile isWalkable = true
  - [ ] Tile isSwimmable = false
- **Priority**: Must

### FR-3: Teleport Pad Placement
- **Type**: Ubiquitous
- **Statement**: The system shall place one teleport pad tile on each island at the island center.
- **Acceptance Criteria**:
  - [ ] Original island has teleport pad at (500, 500)
  - [ ] New island has teleport pad at (500, 450)
- **Priority**: Must

### FR-4: Minimap Display
- **Type**: State-Driven
- **Statement**: While the player is in gameplay (not in inventory, fishing, or death screen), the system shall display a minimap in the top-left corner.
- **Acceptance Criteria**:
  - [ ] Minimap visible during normal gameplay
  - [ ] Minimap hidden when inventory open
  - [ ] Minimap hidden when fishing minigame active
  - [ ] Minimap hidden when death screen shown
  - [ ] Minimap positioned in top-left with safe area padding
- **Priority**: Must

### FR-5: Minimap Player Position
- **Type**: Ubiquitous
- **Statement**: The minimap shall display the player's current position as a centered indicator.
- **Acceptance Criteria**:
  - [ ] Player shown as distinct icon/dot on minimap
  - [ ] Player position is always centered in minimap view
  - [ ] World tiles scroll around player position
- **Priority**: Must

### FR-6: Minimap Expansion
- **Type**: Event-Driven
- **Statement**: When the player taps the minimap, the system shall expand it to a full-screen map overlay.
- **Acceptance Criteria**:
  - [ ] Tapping minimap opens full map view
  - [ ] Full map shows larger area of the world
  - [ ] Full map shows player position
  - [ ] Full map shows teleport waypoint markers
- **Priority**: Must

### FR-7: Full Map Close
- **Type**: Event-Driven
- **Statement**: When the player taps outside the map content or taps a close button, the system shall close the full map overlay.
- **Acceptance Criteria**:
  - [ ] Tapping dark background closes map
  - [ ] Close button/X visible and functional
  - [ ] Returns to normal gameplay view
- **Priority**: Must

### FR-8: Teleport Pad Detection
- **Type**: State-Driven
- **Statement**: While the player is standing on a teleport pad tile, the system shall detect this state for prompt display.
- **Acceptance Criteria**:
  - [ ] System detects when player tile position matches teleport pad
  - [ ] Detection works for all teleport pad locations
- **Priority**: Must

### FR-9: Teleport Prompt Display
- **Type**: State-Driven
- **Statement**: While the player is standing on a teleport pad and not sailing, the system shall display a "Teleport" prompt button.
- **Acceptance Criteria**:
  - [ ] Prompt appears when on teleport pad
  - [ ] Prompt hidden when not on teleport pad
  - [ ] Prompt hidden while sailing
  - [ ] Prompt styled consistently with other prompts (sailboat style)
- **Priority**: Must

### FR-10: Teleport Map Mode
- **Type**: Event-Driven
- **Statement**: When the player taps the teleport prompt, the system shall open the full map in waypoint selection mode.
- **Acceptance Criteria**:
  - [ ] Map opens with waypoints highlighted/selectable
  - [ ] Current location waypoint visually distinct
  - [ ] Other waypoints clearly tappable
- **Priority**: Must

### FR-11: Waypoint Teleportation
- **Type**: Event-Driven
- **Statement**: When the player taps a waypoint on the teleport map, the system shall instantly move the player to that teleport pad location.
- **Acceptance Criteria**:
  - [ ] Tapping waypoint teleports player to that pad's position
  - [ ] Player position updated to center of destination teleport pad
  - [ ] Map closes after teleportation
  - [ ] Cannot teleport to current location (no-op or disabled)
- **Priority**: Must

### FR-12: Waypoint Markers on Map
- **Type**: Ubiquitous
- **Statement**: The full map shall display markers for all teleport pad locations.
- **Acceptance Criteria**:
  - [ ] Each teleport pad shown as distinct marker
  - [ ] Markers visible at map scale
  - [ ] Markers positioned correctly relative to world coordinates
- **Priority**: Must

## Non-Functional Requirements

### NFR-1: Minimap Performance
- **Category**: Performance
- **Statement**: The minimap shall render without causing frame drops during gameplay movement.
- **Acceptance Criteria**:
  - [ ] Minimap updates smoothly as player moves
  - [ ] No visible lag or stuttering
- **Priority**: Must

### NFR-2: Map Usability
- **Category**: Usability
- **Statement**: The map waypoint markers shall be large enough to tap accurately on mobile.
- **Acceptance Criteria**:
  - [ ] Waypoint tap targets at least 44x44 points
  - [ ] Visual marker clearly indicates tappable area
- **Priority**: Should

### NFR-3: Safe Area Compliance
- **Category**: Usability
- **Statement**: The minimap shall be positioned within safe areas on iPhone 16e.
- **Acceptance Criteria**:
  - [ ] Minimap fully visible in landscape orientation
  - [ ] Respects notch/safe area insets
- **Priority**: Must

## Constraints
- Must use existing tile rendering system
- Must integrate with existing GameView overlay pattern
- Teleport pads are tiles, not overlays
- Map view follows existing modal overlay patterns (dark background, centered content)

## Assumptions
- All teleport waypoints are available from start (no unlock system)
- Only one teleport pad per island
- Player cannot teleport while sailing or swimming
- Teleportation is instantaneous with no animation

## Edge Cases
- **Player on teleport pad while sailing**: Prompt should not appear
- **Player swimming over teleport pad**: Should not trigger (pads are on land)
- **Tapping current location waypoint**: Either disabled or no-op (don't teleport to same spot)
- **Opening map from minimap vs teleport prompt**: Minimap opens view-only map; teleport prompt opens selection mode
