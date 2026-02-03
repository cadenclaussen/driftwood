# Crafting System - Requirements

## Functional Requirements

### FR-1: Recipe Grid Display
- **Type**: Ubiquitous
- **Statement**: The crafting page shall display unlocked recipes in a 5-column by 6-row grid layout matching the collectibles page format.
- **Acceptance Criteria**:
  - [ ] Grid uses LazyVGrid with 5 columns and 44pt fixed width
  - [ ] Grid supports up to 30 recipe slots (5x6)
  - [ ] Empty slots are displayed as empty grid cells
  - [ ] Layout matches CollectiblesPageView styling
- **Priority**: Must
- **Notes**: Uses same GridItem configuration as collectibles (44pt, 6pt spacing)

### FR-2: Recipe Craftability Indication
- **Type**: State-Driven
- **Statement**: While displaying a recipe, the crafting page shall show the recipe slot in green if all required materials are available, or red if any materials are missing.
- **Acceptance Criteria**:
  - [ ] Green border/tint when player has all required materials in sufficient quantities
  - [ ] Red border/tint when player is missing any required material
  - [ ] Color updates immediately when inventory changes
- **Priority**: Must
- **Notes**: Check against collectibles inventory for material counts

### FR-3: Recipe Selection
- **Type**: Event-Driven
- **Statement**: When a player taps on a recipe slot, the crafting page shall display a detail panel showing the recipe's required materials.
- **Acceptance Criteria**:
  - [ ] Tapping a recipe slot selects it and shows detail panel
  - [ ] Tapping the same slot again deselects it
  - [ ] Tapping outside the detail panel closes it
  - [ ] Detail panel shows recipe name and icon
- **Priority**: Must
- **Notes**: Similar interaction pattern to collectibles slot selection

### FR-4: Material Requirements Display
- **Type**: State-Driven
- **Statement**: While a recipe is selected, the detail panel shall display each required material with its icon, name, required quantity, and current inventory quantity.
- **Acceptance Criteria**:
  - [ ] Each material shows icon matching the resource type
  - [ ] Each material shows display name
  - [ ] Each material shows "X/Y" format (have/need)
  - [ ] Materials player has enough of are shown in green text
  - [ ] Materials player lacks are shown in red text
- **Priority**: Must
- **Notes**: Material icons should match InventorySlotView styling

### FR-5: Craft Button State
- **Type**: State-Driven
- **Statement**: While a recipe is selected, the craft button shall be enabled and green when all materials are available, or disabled and grayed out when materials are insufficient.
- **Acceptance Criteria**:
  - [ ] Craft button is green and tappable when craftable
  - [ ] Craft button is gray and non-interactive when not craftable
  - [ ] Button state updates if inventory changes while panel is open
- **Priority**: Must
- **Notes**: Visual feedback should be clear and immediate

### FR-6: Craft Execution
- **Type**: Event-Driven
- **Statement**: When the player taps the craft button on a craftable recipe, the system shall consume the required materials and add the crafted item to the collectibles inventory.
- **Acceptance Criteria**:
  - [ ] Required materials are removed from collectibles inventory
  - [ ] Resource quantities are decremented appropriately
  - [ ] Crafted item is added to first available collectibles slot
  - [ ] Detail panel closes after successful craft
  - [ ] Recipe slot color updates to reflect new inventory state
- **Priority**: Must
- **Notes**: Use existing InventoryViewModel add/remove methods

### FR-7: Inventory Full Handling
- **Type**: Unwanted Behavior
- **Statement**: If the collectibles inventory is full when crafting, the system shall prevent the craft and display a message indicating the inventory is full.
- **Acceptance Criteria**:
  - [ ] Craft button is disabled if no empty slots in collectibles
  - [ ] Visual indication that inventory is full (gray button, tooltip, or text)
  - [ ] Materials are NOT consumed if craft cannot complete
- **Priority**: Must
- **Notes**: Check for available slot before consuming materials

### FR-8: Recipe Data Model
- **Type**: Ubiquitous
- **Statement**: The system shall define recipes with a unique identifier, result item, and list of required materials with quantities.
- **Acceptance Criteria**:
  - [ ] Recipe struct with id, result SlotContent, and materials array
  - [ ] Materials array contains tuples of ResourceType and quantity
  - [ ] Recipes are defined as static data (not persisted)
- **Priority**: Must
- **Notes**: Start with a few sample recipes for meals using fishing resources

## Non-Functional Requirements

### NFR-1: UI Responsiveness
- **Category**: Performance
- **Statement**: The crafting page shall update craftability colors within 100ms of inventory changes.
- **Acceptance Criteria**:
  - [ ] No visible lag when switching to crafting tab
  - [ ] Color updates are immediate after crafting
- **Priority**: Should

### NFR-2: Visual Consistency
- **Category**: Usability
- **Statement**: The crafting page shall match the visual style of existing inventory pages (fonts, colors, spacing, borders).
- **Acceptance Criteria**:
  - [ ] Uses same 12pt system font for labels
  - [ ] Uses same gray.opacity(0.3) backgrounds
  - [ ] Uses same cornerRadius(6) for slots
  - [ ] Uses same color scheme (white text, gray secondary)
- **Priority**: Must

### NFR-3: Touch Target Size
- **Category**: Usability
- **Statement**: All interactive elements shall have a minimum touch target of 44x44 points per Apple HIG.
- **Acceptance Criteria**:
  - [ ] Recipe slots are at least 44x44 points
  - [ ] Craft button is at least 44 points tall
- **Priority**: Must

## Constraints
- Must integrate with existing InventoryViewModel and Inventory model
- Must use existing SlotContent and ResourceType enums
- Recipes are hardcoded (no persistence needed for recipe unlocks)
- Single page only (30 recipes max for MVP)

## Assumptions
- All recipes are unlocked by default (unlocking system is out of scope)
- Recipes only consume resources from collectibles inventory
- Crafted items are always SlotContent types (meals, armor, accessories)
- Player cannot craft while inventory is full

## Edge Cases
- **Empty recipe list**: Display "No recipes available" placeholder
- **Last material used**: Recipe turns red immediately after crafting uses last of a material
- **Multiple recipes using same material**: All affected recipes update color simultaneously
- **Crafting consumes stacked resources**: Decrement quantity, remove slot only when quantity reaches 0
