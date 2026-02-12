# Teleport and Map System - Implementation Tasks

## Summary
- Total tasks: 8
- Estimated complexity: Medium

## Task Dependency Graph

```
T1 [TeleportPad Model]
    ↓
T2 [TileType + World Gen] ──→ T3 [GameViewModel Logic]
                                      ↓
                              T4 [TeleportPromptView]
                                      ↓
T5 [GameMiniMapView] ────────→ T6 [FullMapView]
                                      ↓
                              T7 [GameView Integration]
                                      ↓
                              T8 [Testing & Polish]
```

## Tasks

### Task 1: Create TeleportPad Model
- **Status**: Pending
- **Dependencies**: None
- **Files**:
  - Create: `driftwood/Models/TeleportPad.swift`
- **Requirements Addressed**: FR-3, FR-12
- **Description**:
  Create the TeleportPad model struct that represents a teleport waypoint location with name and tile coordinates.
- **Implementation Notes**:
  - Struct with id (UUID), name (String), tileX (Int), tileY (Int)
  - Computed property `worldPosition` returning CGPoint at tile center
  - Conform to Identifiable and Codable
  - Use tileSize constant of 24
- **Acceptance Criteria**:
  - [ ] TeleportPad struct created with all properties
  - [ ] worldPosition computes center of tile correctly

---

### Task 2: Add Teleport Tile Type and Second Island
- **Status**: Pending
- **Dependencies**: Task 1
- **Files**:
  - Modify: `driftwood/Models/Tile.swift`
  - Modify: `driftwood/Models/World.swift`
- **Requirements Addressed**: FR-1, FR-2, FR-3
- **Description**:
  Add teleportPad case to TileType enum with purple color. Update World to generate a second island 50 tiles north and place teleport pads at both island centers.
- **Implementation Notes**:
  - TileType.teleportPad with color `Color(red: 0.6, green: 0.3, blue: 0.8)`
  - isWalkable = true, isSwimmable = false
  - Second island at Y origin 445 (center at 450)
  - Add `var teleportPads: [TeleportPad]` to World
  - Create teleport pads: "Home Island" at (500, 500), "North Island" at (500, 450)
  - Place teleportPad tiles at those coordinates
- **Acceptance Criteria**:
  - [ ] teleportPad tile renders purple
  - [ ] Second island generates at correct position
  - [ ] Both islands have teleport pad tiles at center
  - [ ] world.teleportPads contains both pads

---

### Task 3: Add Teleport Logic to GameViewModel
- **Status**: Pending
- **Dependencies**: Task 2
- **Files**:
  - Modify: `driftwood/ViewModels/GameViewModel.swift`
- **Requirements Addressed**: FR-8, FR-10, FR-11
- **Description**:
  Add state and methods for teleport detection, map opening, and teleportation.
- **Implementation Notes**:
  - `@Published var isMapOpen = false`
  - `@Published var isMapTeleportMode = false`
  - Computed `var isOnTeleportPad: Bool` - check if player tile matches any teleport pad
  - Computed `var currentTeleportPad: TeleportPad?` - return pad player is standing on
  - `func openMap(teleportMode: Bool)` - sets both flags
  - `func closeMap()` - resets both flags
  - `func teleportTo(pad: TeleportPad)` - sets player.position to pad.worldPosition, closes map
- **Acceptance Criteria**:
  - [ ] isOnTeleportPad returns true when standing on pad
  - [ ] currentTeleportPad returns correct pad
  - [ ] teleportTo moves player to destination pad center
  - [ ] Map state flags work correctly

---

### Task 4: Create TeleportPromptView
- **Status**: Pending
- **Dependencies**: Task 3
- **Files**:
  - Create: `driftwood/Views/TeleportPromptView.swift`
- **Requirements Addressed**: FR-9
- **Description**:
  Create the contextual prompt button that appears when standing on a teleport pad. Follow SailboatPromptView pattern.
- **Implementation Notes**:
  - Simple button with "Teleport" text and SF Symbol icon (e.g., `arrow.up.and.down.circle`)
  - Purple/violet background to match teleport pad
  - `onTap` callback closure
  - Match styling of SailboatPromptView (padding, corner radius, font)
- **Acceptance Criteria**:
  - [ ] Prompt renders with icon and text
  - [ ] Tapping triggers onTap callback
  - [ ] Styling matches other prompts

---

### Task 5: Create GameMiniMapView
- **Status**: Pending
- **Dependencies**: Task 2
- **Files**:
  - Create: `driftwood/Views/Map/GameMiniMapView.swift`
- **Requirements Addressed**: FR-4, FR-5, FR-6
- **Description**:
  Create the always-visible minimap component for the top-left HUD. Shows 50x50 tile region centered on player with tap-to-expand gesture.
- **Implementation Notes**:
  - Reuse rendering logic from existing MiniMapView
  - Size: 80-100 points square
  - Player indicator: red dot at center
  - Show teleport pad tiles as purple
  - Add tap gesture that calls `onTap` closure
  - Subtle border/background for visibility
- **Acceptance Criteria**:
  - [ ] Minimap renders tile colors correctly
  - [ ] Player dot centered in view
  - [ ] Teleport pads visible as purple
  - [ ] Tap gesture triggers callback

---

### Task 6: Create FullMapView
- **Status**: Pending
- **Dependencies**: Task 5, Task 3
- **Files**:
  - Create: `driftwood/Views/Map/FullMapView.swift`
  - Create: `driftwood/Views/Map/WaypointMarkerView.swift`
- **Requirements Addressed**: FR-6, FR-7, FR-10, FR-11, FR-12
- **Description**:
  Create the full-screen map overlay with waypoint markers. Supports view-only mode (from minimap tap) and teleport mode (from teleport prompt).
- **Implementation Notes**:
  - Dark semi-transparent background (0.85 opacity) following existing overlay pattern
  - Larger map view (300-400 points) showing more world area
  - Player position indicator
  - WaypointMarkerView for each teleport pad:
    - 44x44pt minimum tap target
    - Different appearance for current location vs other
    - Only tappable when isTeleportMode = true
    - Purple circle with label
  - Close on background tap or X button
  - onSelectWaypoint callback when waypoint tapped in teleport mode
  - onClose callback
- **Acceptance Criteria**:
  - [ ] Map overlay appears with dark background
  - [ ] All waypoints displayed with markers
  - [ ] Current location marker visually distinct
  - [ ] Waypoints tappable only in teleport mode
  - [ ] Tapping waypoint calls onSelectWaypoint
  - [ ] Background tap or X closes map

---

### Task 7: Integrate into GameView
- **Status**: Pending
- **Dependencies**: Task 4, Task 6
- **Files**:
  - Modify: `driftwood/Views/GameView.swift`
- **Requirements Addressed**: FR-4, FR-9, All UI requirements
- **Description**:
  Add minimap to HUD, teleport prompt to controls, and full map overlay to GameView.
- **Implementation Notes**:
  - GameMiniMapView in top-left, inside safe area, with padding
  - Hide minimap when: inventory open, fishing, death screen, map open
  - TeleportPromptView in controls area (above joystick, similar to sailboat prompt)
  - Show teleport prompt when: isOnTeleportPad && !player.isSailing
  - FullMapView overlay when isMapOpen
  - Wire up callbacks:
    - Minimap tap → viewModel.openMap(teleportMode: false)
    - Teleport prompt tap → viewModel.openMap(teleportMode: true)
    - Waypoint select → viewModel.teleportTo(pad)
    - Map close → viewModel.closeMap()
- **Acceptance Criteria**:
  - [ ] Minimap visible in top-left during gameplay
  - [ ] Minimap hidden during other overlays
  - [ ] Teleport prompt appears on teleport pad
  - [ ] Tapping minimap opens view-only map
  - [ ] Tapping prompt opens teleport map
  - [ ] Selecting waypoint teleports player
  - [ ] Map closes properly

---

### Task 8: Testing and Polish
- **Status**: Pending
- **Dependencies**: Task 7
- **Files**:
  - Possibly minor adjustments to any file
- **Requirements Addressed**: NFR-1, NFR-2, NFR-3, All requirements
- **Description**:
  Manual testing and polish. Verify all functionality works correctly.
- **Implementation Notes**:
  - Test walking to both islands
  - Test teleporting between islands
  - Test minimap visibility conditions
  - Test map open/close from both entry points
  - Verify safe area compliance on iPhone 16e
  - Check for any performance issues
  - Adjust sizing/positioning as needed
- **Acceptance Criteria**:
  - [ ] Can teleport from Home to North island
  - [ ] Can teleport from North to Home island
  - [ ] Minimap shows correct tiles and player position
  - [ ] No teleport to current location
  - [ ] UI within safe areas
  - [ ] No performance issues

---

## Implementation Order
1. Task 1 - TeleportPad model (foundation)
2. Task 2 - Tile type and world generation (world structure)
3. Task 3 - GameViewModel logic (business logic)
4. Task 4 - TeleportPromptView (simple UI component)
5. Task 5 - GameMiniMapView (minimap component)
6. Task 6 - FullMapView + WaypointMarkerView (main map UI)
7. Task 7 - GameView integration (wire everything together)
8. Task 8 - Testing and polish (verification)

## Integration Checklist
- [ ] All tasks completed
- [ ] Build succeeds
- [ ] Manual testing passed
- [ ] Both islands accessible
- [ ] Teleportation works both directions
- [ ] Map UI polished and usable
