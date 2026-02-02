# Main Menu System - Requirements

## Functional Requirements

### FR-1: Main Menu Display
- **Type**: Ubiquitous
- **Statement**: The system shall display a main menu screen when the app launches.
- **Acceptance Criteria**:
  - [ ] Main menu appears on app launch instead of game world
  - [ ] Menu contains a visible "Play" button
  - [ ] Menu is centered and appropriately styled
- **Priority**: Must
- **Notes**: Replace direct GameView launch in ContentView

### FR-2: Play Button Interaction
- **Type**: Event-Driven
- **Statement**: When the user taps the Play button, the system shall navigate to the profile selection screen.
- **Acceptance Criteria**:
  - [ ] Play button responds to tap gesture
  - [ ] Profile selection screen appears after tapping Play
  - [ ] Transition is smooth (no abrupt jumps)
- **Priority**: Must
- **Notes**: Consider a subtle animation for the transition

### FR-3: Profile Selection Display
- **Type**: Ubiquitous
- **Statement**: The system shall display exactly 3 profile cards on the profile selection screen.
- **Acceptance Criteria**:
  - [ ] Three cards are visible on screen
  - [ ] Cards are arranged horizontally or in a clear layout
  - [ ] Each card is clearly tappable
- **Priority**: Must
- **Notes**: Cards should be evenly spaced for iPhone 16e landscape

### FR-4: Profile Card Stats Display
- **Type**: Ubiquitous
- **Statement**: Each profile card shall display the player's current hearts, stamina, and magic power.
- **Acceptance Criteria**:
  - [ ] Hearts displayed using heart icons (filled/empty)
  - [ ] Stamina displayed as a bar or numeric value
  - [ ] Magic power displayed appropriately
  - [ ] Stats reflect saved profile data
- **Priority**: Must
- **Notes**: Match existing HUD style (HeartsView, StaminaBarView)

### FR-5: Profile Card Location Preview
- **Type**: Ubiquitous
- **Statement**: Each profile card shall display a preview image showing where the player was when they last saved.
- **Acceptance Criteria**:
  - [ ] Preview shows a snapshot of the game world
  - [ ] Player position is visible in the preview
  - [ ] Preview is appropriately sized within the card
- **Priority**: Must
- **Notes**: Could be a rendered mini-map or a screenshot thumbnail

### FR-6: Empty Profile Card Display
- **Type**: State-Driven
- **Statement**: While a profile has no saved data, the system shall display the card with default/empty state indicators.
- **Acceptance Criteria**:
  - [ ] Empty profiles show "New Game" or empty state
  - [ ] Hearts show max health (5 hearts)
  - [ ] Stamina shows full bar
  - [ ] Location preview shows starting area or placeholder
- **Priority**: Must
- **Notes**: Empty profiles start fresh at island center

### FR-7: Profile Selection
- **Type**: Event-Driven
- **Statement**: When the user taps a profile card, the system shall initiate a fade-to-black transition and load that profile's game state.
- **Acceptance Criteria**:
  - [ ] Tapping a card triggers the transition
  - [ ] Screen fades to black smoothly
  - [ ] Game loads after fade completes
- **Priority**: Must
- **Notes**: Use existing screenFadeOpacity pattern from GameViewModel

### FR-8: Fade-to-Black Transition
- **Type**: Event-Driven
- **Statement**: When a profile is selected, the system shall perform a fade-to-black animation lasting approximately 0.5 seconds, then fade in to the game view.
- **Acceptance Criteria**:
  - [ ] Fade-out to black takes ~0.3 seconds
  - [ ] Brief pause at full black (~0.2 seconds)
  - [ ] Fade-in to game takes ~0.3 seconds
  - [ ] Total transition feels polished, not rushed
- **Priority**: Must
- **Notes**: Similar to drowning fade but for menu transition

### FR-9: Player Position Restoration
- **Type**: Event-Driven
- **Statement**: When a saved profile is loaded, the system shall position the player at their last saved location.
- **Acceptance Criteria**:
  - [ ] Player spawns at saved coordinates
  - [ ] Player faces saved direction
  - [ ] Stats (health, stamina) match saved values
- **Priority**: Must
- **Notes**: New profiles start at island center

### FR-10: Save Profile Model
- **Type**: Ubiquitous
- **Statement**: The system shall store save profile data including player position, health, stamina, and magic power.
- **Acceptance Criteria**:
  - [ ] SaveProfile struct/class contains all required fields
  - [ ] Profile can be encoded/decoded for persistence
  - [ ] Profile ID identifies which slot (1, 2, or 3)
- **Priority**: Must
- **Notes**: Add magic property to Player model

### FR-11: Profile Persistence
- **Type**: Event-Driven
- **Statement**: When the game state changes significantly, the system shall persist the current profile to storage.
- **Acceptance Criteria**:
  - [ ] Profile saves to UserDefaults or file storage
  - [ ] Profile persists across app launches
  - [ ] Save does not cause frame drops or lag
- **Priority**: Must
- **Notes**: Consider auto-save at regular intervals or on specific events

### FR-12: Profile Loading on App Launch
- **Type**: Event-Driven
- **Statement**: When the app launches, the system shall load all existing profiles from storage to display on the profile selection screen.
- **Acceptance Criteria**:
  - [ ] Saved profiles load with correct data
  - [ ] Empty/missing profiles show as new
  - [ ] Loading completes before menu display
- **Priority**: Must
- **Notes**: Use Codable for easy serialization

## Non-Functional Requirements

### NFR-1: Transition Smoothness
- **Category**: Performance
- **Statement**: The fade transition shall maintain 60 FPS throughout the animation.
- **Acceptance Criteria**:
  - [ ] No frame drops during fade animation
  - [ ] No visible stuttering or jank
- **Priority**: Should
- **Notes**: Use SwiftUI animation system

### NFR-2: Menu Responsiveness
- **Category**: Usability
- **Statement**: All menu buttons and cards shall respond to taps within 100ms.
- **Acceptance Criteria**:
  - [ ] Button tap feedback is immediate
  - [ ] No perceived input lag
- **Priority**: Should
- **Notes**: Avoid heavy computations on tap

### NFR-3: Card Readability
- **Category**: Usability
- **Statement**: Profile card stats and preview shall be clearly readable on iPhone 16e.
- **Acceptance Criteria**:
  - [ ] Text is legible without squinting
  - [ ] Icons are appropriately sized
  - [ ] Preview image has sufficient detail
- **Priority**: Should
- **Notes**: Optimize for iPhone 16e landscape

### NFR-4: Save Reliability
- **Category**: Reliability
- **Statement**: Profile saves shall not corrupt or lose data during normal operation.
- **Acceptance Criteria**:
  - [ ] Saves complete successfully
  - [ ] Data loads without corruption
  - [ ] App crash during save does not corrupt profile
- **Priority**: Must
- **Notes**: Consider atomic writes

## Constraints
- Must use SwiftUI (existing codebase pattern)
- Must work on iPhone 16e (target device)
- No external dependencies (pure SwiftUI/Foundation)
- Landscape orientation only
- Maximum 3 save profiles (no profile management UI)

## Assumptions
- Player model will be extended with magic power property
- Profiles are fixed slots (1, 2, 3), not dynamically created
- App has write access to UserDefaults/Documents
- Device has sufficient storage for 3 profiles

## Edge Cases
- **All profiles empty**: Show 3 "New Game" cards, any can be selected
- **App killed during save**: Use atomic writes to prevent corruption
- **Storage full**: Show error, do not corrupt existing saves
- **Corrupted profile data**: Reset to empty state, log error
- **Rapid profile tap**: Debounce to prevent multiple transitions
- **App backgrounded during transition**: Complete transition, pause game if needed
