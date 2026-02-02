# Player Movement System - Requirements

## Functional Requirements

### FR-1: Player Character Display
- **Type**: Ubiquitous
- **Statement**: The system shall display the player as a red circle with diameter equal to half the tile size (12 points).
- **Acceptance Criteria**:
  - [ ] Player renders as a filled red circle
  - [ ] Player diameter is 12 points (half of 24pt tile)
  - [ ] Player is visible on top of the world grid
- **Priority**: Must
- **Notes**: Using Circle shape with .fill(Color.red)

### FR-2: Player Initial Position
- **Type**: Ubiquitous
- **Statement**: The system shall spawn the player at the center of the island when the game starts.
- **Acceptance Criteria**:
  - [ ] Player spawns at world center coordinates
  - [ ] Player is visible on grass tiles at game start
- **Priority**: Must
- **Notes**: Center of 10x10 island with 3-tile ocean padding = tile (8, 8) approximately

### FR-3: Virtual Joystick Display
- **Type**: Ubiquitous
- **Statement**: The system shall display a virtual joystick control in the bottom-left area of the screen.
- **Acceptance Criteria**:
  - [ ] Joystick has a visible base circle (outer ring)
  - [ ] Joystick has a draggable thumb/knob (inner circle)
  - [ ] Joystick is positioned in bottom-left with safe area padding
- **Priority**: Must
- **Notes**: Semi-transparent to not obstruct gameplay view

### FR-4: Joystick Touch Interaction
- **Type**: Event-Driven
- **Statement**: When the user touches and drags within the joystick area, the system shall move the joystick thumb to follow the touch position within the joystick bounds.
- **Acceptance Criteria**:
  - [ ] Thumb follows finger position during drag
  - [ ] Thumb is constrained within the joystick base radius
  - [ ] Thumb returns to center when touch ends
- **Priority**: Must
- **Notes**: Use DragGesture for touch handling

### FR-5: Player Movement from Joystick
- **Type**: State-Driven
- **Statement**: While the joystick is being dragged, the system shall move the player in the direction and at a speed proportional to the joystick displacement.
- **Acceptance Criteria**:
  - [ ] Player moves in direction of joystick offset
  - [ ] Movement speed scales with joystick displacement (further = faster)
  - [ ] Movement is smooth and continuous (not grid-locked)
  - [ ] Player stops moving when joystick is released
- **Priority**: Must
- **Notes**: Use Timer or DisplayLink for continuous movement updates

### FR-6: Landscape Orientation Lock
- **Type**: Ubiquitous
- **Statement**: The system shall lock the app to landscape orientation on iPhone devices.
- **Acceptance Criteria**:
  - [ ] App launches in landscape mode
  - [ ] App does not rotate to portrait mode
  - [ ] Both landscape left and landscape right are supported
- **Priority**: Must
- **Notes**: Configure via Info.plist UISupportedInterfaceOrientations

### FR-7: Player Layer Ordering
- **Type**: Ubiquitous
- **Statement**: The system shall render the player above the world grid layer.
- **Acceptance Criteria**:
  - [ ] Player is visible when over any tile type
  - [ ] Player does not get obscured by tiles
- **Priority**: Must
- **Notes**: Use ZStack with player overlay or .overlay modifier

## Non-Functional Requirements

### NFR-1: Movement Smoothness
- **Category**: Performance
- **Statement**: The system shall update player position at a minimum of 60 frames per second during movement.
- **Acceptance Criteria**:
  - [ ] No visible stuttering during player movement
  - [ ] Movement feels responsive to joystick input
- **Priority**: Should
- **Notes**: Use withAnimation or Timer at 1/60 interval

### NFR-2: Joystick Usability
- **Category**: Usability
- **Statement**: The joystick shall be sized appropriately for comfortable thumb control (minimum 100pt diameter).
- **Acceptance Criteria**:
  - [ ] Joystick base is at least 100 points in diameter
  - [ ] Joystick thumb is at least 40 points in diameter
  - [ ] Touch target is easy to hit without looking
- **Priority**: Should
- **Notes**: Consider different device sizes

### NFR-3: Visual Clarity
- **Category**: Usability
- **Statement**: The joystick shall be semi-transparent to minimize obstruction of the game world.
- **Acceptance Criteria**:
  - [ ] Joystick has reduced opacity (0.5-0.7)
  - [ ] Game world remains visible behind joystick
- **Priority**: Could
- **Notes**: Balance visibility of control with gameplay view

## Constraints
- Must use SwiftUI (existing codebase pattern)
- Must work on iPhone devices (primary target)
- Tile size is fixed at 24 points (existing constant)
- No external dependencies (pure SwiftUI implementation)

## Assumptions
- Device has touch screen capability
- Single touch point for joystick control
- Player can move freely anywhere (no collision boundaries yet)
- World view will eventually follow player (camera system is future work)

## Edge Cases
- **Joystick touch outside bounds**: Clamp thumb position to maximum radius
- **Very fast drag movements**: Ensure thumb stays within bounds, position updates smoothly
- **Player moves off visible screen**: No restriction for now (camera follow is future feature)
- **App backgrounded during movement**: Stop movement, reset joystick to center
- **Device rotation attempt**: Block rotation, maintain landscape
