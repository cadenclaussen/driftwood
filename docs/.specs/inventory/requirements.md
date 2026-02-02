# Inventory System - Requirements

## Functional Requirements

### FR-1: Inventory Access
- **Type**: Event-Driven
- **Statement**: When the player taps the inventory button, the system shall display the inventory overlay on the current page.
- **Acceptance Criteria**:
  - [ ] Inventory button visible in HUD
  - [ ] Tapping opens inventory overlay
  - [ ] Tapping again or close button dismisses overlay
  - [ ] Game pauses while inventory is open
- **Priority**: Must
- **Notes**: Button positioned in bottom-right HUD area

### FR-2: Page Navigation
- **Type**: Event-Driven
- **Statement**: When the player taps a page tab, the system shall switch to display that inventory page.
- **Acceptance Criteria**:
  - [ ] 3 tabs visible: Items, Collectibles, Character
  - [ ] Active tab visually highlighted
  - [ ] Page content updates immediately on tab tap
  - [ ] Last viewed page remembered when reopening inventory
- **Priority**: Must

### FR-3: Items Page - Gear Display
- **Type**: Ubiquitous
- **Statement**: The system shall display all gear items (Sails, Motor, Pouch) with their current tier and max tier.
- **Acceptance Criteria**:
  - [ ] Sails displayed with tier indicator (0-4)
  - [ ] Motor displayed with owned/not owned state
  - [ ] Pouch displayed with tier indicator (0-3)
  - [ ] Unowned gear shown as locked/grayed
- **Priority**: Must

### FR-4: Items Page - Tools Display
- **Type**: Ubiquitous
- **Statement**: The system shall display all tools (Fishing Rod, Sword, Axe, Wand) with their current tier.
- **Acceptance Criteria**:
  - [ ] Fishing Rod displayed with tier (0-4)
  - [ ] Sword displayed with tier (0-3)
  - [ ] Axe displayed with tier (0-3)
  - [ ] Wand displayed with owned/not owned state
  - [ ] Unowned tools shown as locked/grayed
- **Priority**: Must

### FR-5: Collectibles Page - Grid Layout
- **Type**: Ubiquitous
- **Statement**: The system shall display a 5x6 grid (30 slots) for collectible items.
- **Acceptance Criteria**:
  - [ ] Grid renders 5 columns x 6 rows
  - [ ] Empty slots visually distinct from filled
  - [ ] Top row (5 slots) has meal icon indicator
  - [ ] Bottom 25 slots have resource icon indicator
- **Priority**: Must

### FR-6: Collectibles Page - Meal Slots
- **Type**: Unwanted Behavior
- **Statement**: If the player attempts to place a non-meal item in the top row, the system shall prevent the action and display feedback.
- **Acceptance Criteria**:
  - [ ] Only meal items can occupy top 5 slots
  - [ ] Visual feedback when invalid placement attempted
  - [ ] Maximum 5 meals enforceable
- **Priority**: Must

### FR-7: Collectibles Page - Resource Stacking
- **Type**: State-Driven
- **Statement**: While a stackable resource is added to inventory, the system shall stack it with existing items of the same type up to 99.
- **Acceptance Criteria**:
  - [ ] Same resources stack automatically
  - [ ] Stack count displayed on slot (e.g., "x45")
  - [ ] New slot used when stack reaches 99
  - [ ] Food ingredients do NOT stack (1 per slot)
  - [ ] Non-food resources DO stack
- **Priority**: Must

### FR-8: Character Page - Armor Slots
- **Type**: Ubiquitous
- **Statement**: The system shall display 4 armor equipment slots (Hat, Shirt, Pants, Boots).
- **Acceptance Criteria**:
  - [ ] 4 labeled slots displayed
  - [ ] Equipped armor shows item icon and name
  - [ ] Empty slots show placeholder icon
  - [ ] Stats summary visible for equipped set
- **Priority**: Must

### FR-9: Character Page - Accessory Slots
- **Type**: Ubiquitous
- **Statement**: The system shall display 4 accessory slots (Anklet, Ring, Chain, Bracelet) with tier indicators.
- **Acceptance Criteria**:
  - [ ] 4 labeled slots displayed
  - [ ] Equipped accessories show tier (1-5)
  - [ ] Empty slots show placeholder
  - [ ] Accessory stats visible
- **Priority**: Must

### FR-10: Character Page - Major Upgrades
- **Type**: Ubiquitous
- **Statement**: The system shall display major upgrade status (Sailboat, Flippers, Wings, Pegasus Boots).
- **Acceptance Criteria**:
  - [ ] All 4 upgrades displayed
  - [ ] Owned upgrades highlighted
  - [ ] Unowned upgrades grayed/locked
- **Priority**: Should

### FR-11: Item Selection
- **Type**: Event-Driven
- **Statement**: When the player taps an item slot, the system shall display item details and available actions.
- **Acceptance Criteria**:
  - [ ] Tap selects item and shows detail panel
  - [ ] Detail panel shows: name, description, stats
  - [ ] Available actions shown (Use, Equip, Favorite, Junk, Drop)
  - [ ] Tap outside dismisses detail panel
- **Priority**: Must

### FR-12: Sorting
- **Type**: Event-Driven
- **Statement**: When the player selects a sort option, the system shall reorder items in the current page accordingly.
- **Acceptance Criteria**:
  - [ ] Sort button accessible on Collectibles page
  - [ ] Sort options: Type, Rarity, Recent
  - [ ] Items reorder immediately
  - [ ] Sort preference persists for session
- **Priority**: Should

### FR-13: Favorites
- **Type**: Event-Driven
- **Statement**: When the player marks an item as favorite, the system shall display a star indicator on that slot.
- **Acceptance Criteria**:
  - [ ] Favorite toggle in item detail panel
  - [ ] Star icon on favorited slots
  - [ ] Favorites sort to top when sorting by type
- **Priority**: Should

### FR-14: Junk Tagging
- **Type**: Event-Driven
- **Statement**: When the player marks an item as junk, the system shall display a junk indicator on that slot.
- **Acceptance Criteria**:
  - [ ] Junk toggle in item detail panel
  - [ ] Junk icon (e.g., trash) on tagged slots
  - [ ] Junk items sort to bottom
  - [ ] Cannot mark equipped items as junk
- **Priority**: Should

### FR-15: Inventory Persistence
- **Type**: Event-Driven
- **Statement**: When the game saves, the system shall persist all inventory data to the save profile.
- **Acceptance Criteria**:
  - [ ] All items saved with quantities
  - [ ] Equipped items saved
  - [ ] Favorite/junk tags saved
  - [ ] Inventory loads correctly on game resume
- **Priority**: Must

### FR-16: Equip Item
- **Type**: Event-Driven
- **Statement**: When the player selects Equip on an armor or accessory, the system shall equip the item to the appropriate slot.
- **Acceptance Criteria**:
  - [ ] Item moves to equipment slot
  - [ ] Previously equipped item returns to inventory
  - [ ] Player stats update immediately
  - [ ] Visual feedback on successful equip
- **Priority**: Must

### FR-17: Use Meal
- **Type**: Event-Driven
- **Statement**: When the player selects Use on a meal, the system shall consume the meal and heal the player.
- **Acceptance Criteria**:
  - [ ] Meal removed from inventory
  - [ ] Player healed based on meal type
  - [ ] Temp hearts applied if applicable
  - [ ] Can use meals even at full health
- **Priority**: Must

## Non-Functional Requirements

### NFR-1: Inventory Performance
- **Category**: Performance
- **Statement**: The system shall open the inventory overlay within 100ms of button tap.
- **Acceptance Criteria**:
  - [ ] No perceptible lag on inventory open
  - [ ] Smooth page transitions
- **Priority**: Must

### NFR-2: Visual Clarity
- **Category**: Usability
- **Statement**: The system shall display item icons at minimum 32x32 points for readability on iPhone 16e.
- **Acceptance Criteria**:
  - [ ] Icons clearly visible
  - [ ] Stack counts readable
  - [ ] Tier indicators distinct
- **Priority**: Must

### NFR-3: Touch Targets
- **Category**: Accessibility
- **Statement**: The system shall provide touch targets of minimum 44x44 points for all interactive elements.
- **Acceptance Criteria**:
  - [ ] All buttons/slots meet minimum size
  - [ ] Adequate spacing between elements
- **Priority**: Must

## Constraints

- Must integrate with existing SaveProfile/SaveManager system
- Must work in landscape orientation only
- Must fit iPhone 16e screen without scrolling main grid
- No SwiftData dependency (use Codable for persistence)

## Assumptions

- Player can only have one of each gear/tool type (no duplicates)
- Armor pieces are unique (one hat, not multiple hats)
- Accessories have unique slots (one ring slot, not generic accessory slots)
- Resources are predefined types (wood, fish, etc.)

## Edge Cases

- **Full inventory**: When adding item to full collectibles page, show "Inventory Full" message and don't pick up item
- **Stack overflow**: When adding to a stack at 99, create new stack if space available
- **No space for unequip**: When equipping and no space for old item, prevent equip and show message
- **Duplicate meals**: If 5 meals carried and cooking creates new meal, show "Meal slots full" message
