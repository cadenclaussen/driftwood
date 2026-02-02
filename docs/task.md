# Tasks

### 7. Implement inventory system
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: Models/, Views/Inventory/, ViewModels/
- **Requested**: Implement the inventory system as specified in docs/outline/player.md. 3 pages: Items (gear/tools), Collectibles (30 slots: 5 meals + 25 resources), Character (equipment/accessories). Features include sorting, favorites, junk tagging.
- **Context**: Core player system for managing items, gear, and equipment
- **Acceptance Criteria**:
  - [x] Create inventory data models (Item types, Inventory structure)
  - [x] Page 1: Items page with Gear and Tools
  - [x] Page 2: Collectibles page (5x6 grid, top row meals, bottom resources)
  - [x] Page 3: Character page (4 armor slots, 4 accessory slots, major upgrades)
  - [x] Inventory UI overlay accessible from HUD
  - [x] Sorting by type, rarity, recent
  - [x] Favorites marking
  - [x] Junk tagging for quick-sell
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Created full inventory system with 12 implementation tasks via Kiro specs. Models: ItemType.swift (all enums), CollectibleSlot.swift (slot content), Equipment.swift (armor/accessories), Inventory.swift (root container). ViewModel: InventoryViewModel.swift with add/remove/equip/sort logic. Views: InventoryView (overlay), ItemsPageView (gear/tools), CollectiblesPageView (5x6 grid), CharacterPageView (equipment), InventorySlotView, ItemDetailPanel, InventoryButton. Integrated with SaveProfile for persistence and GameView for HUD button.

### 6. Add 5 hearts health system
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: Player.swift, GameView.swift, GameViewModel.swift
- **Requested**: Add the 5 hearts health system. Display hearts in HUD. Lose 1 heart when stamina depletes while swimming.
- **Context**: Core player resource, ties into swimming stamina depletion
- **Acceptance Criteria**:
  - [x] Add health property to Player (5 hearts)
  - [x] Display hearts in HUD
  - [x] Lose 1 heart when swimming stamina depletes
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Added health/maxHealth (5) to Player. Created HeartsView with filled/empty heart icons. Updated handleStaminaDepleted to reduce health by 1. Fixed stamina to stay constant when stationary in water (no regen, no drain).

### 5. Implement swimming
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: Tile.swift, Player.swift, GameViewModel.swift
- **Requested**: Implement swimming. Player can enter water (ocean tiles), consumes stamina while swimming. When stamina depletes, teleport back to swim start point.
- **Context**: Swimming uses stamina system, core movement mechanic
- **Acceptance Criteria**:
  - [x] Ocean tiles are swimmable (player can enter)
  - [x] Track swim start point when entering water
  - [x] Consume stamina while swimming
  - [x] When stamina depletes: teleport to swim start point
  - [x] Stamina regenerates when not swimming
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Added isSwimmable to TileType. Added isSwimming, swimStartPoint, swimStaminaDrainRate (15/sec) to Player. Modified canMoveTo to allow swimmable tiles. Added updateSwimmingState to track water entry/exit, storing last land position as swimStartPoint. handleStaminaDepleted teleports player back when stamina hits 0.

### 4. Create stamina system and sprinting system
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: Player.swift, GameViewModel.swift, GameView.swift
- **Requested**: Create the stamina system and the sprinting system. Stamina is consumed by swimming/climbing (not sprint). Sprint is a toggle that doubles walk speed with no stamina cost. Stamina bar refills fully in 5 seconds.
- **Context**: Core player resource system for movement mechanics
- **Acceptance Criteria**:
  - [x] Add stamina property to Player model (0-100 range)
  - [x] Stamina regenerates at constant rate (full in 5 seconds = 20/sec)
  - [x] Add sprint toggle (2x movement speed)
  - [x] Sprint has no stamina cost
  - [x] Add stamina bar UI display
  - [x] Add sprint button/toggle UI
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Added stamina (100 max, 20/sec regen) and isSprinting properties to Player.swift. Added updateStamina() and toggleSprint() to GameViewModel. Created StaminaBarView (green bar, top-left HUD) and SprintButtonView (orange toggle, bottom-right) in GameView.swift. Sprint doubles speed (2x multiplier).

### 3. Create player.md outline documentation
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: docs/outline/player.md
- **Requested**: Create player.md in outline folder with all player system information (health, stamina, magic, money, inventory with 3 pages: items containing gear/tools, and collectibles). Format nicely and ask clarifying questions before implementation. Also added improvement mechanics from brainstorm session.
- **Context**: Core player systems documentation that will be used as reference for coding
- **Acceptance Criteria**:
  - [x] Create docs/outline/player.md with all provided content
  - [x] Proper markdown formatting
  - [x] Ask clarifying questions about unclear mechanics
  - [x] Add selected improvement mechanics (fishing: perfect catch, combo; combat: charged attack, parry, dodge roll, knockback, weak points; movement: sprint, climbing, footsteps, map markers, fast travel; inventory: sorting, favorites, junk, recipe book, storage)
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Created comprehensive player.md with all systems documented. Updated fishing.md with minigame mechanics, perfect catch, and combo system. Documented combat (charged attacks, parry with 1s stun, dodge roll), movement (2x sprint, stamina-based climbing, fast travel), inventory features (sorting, junk/merchant system, 30-slot storage), and crafting TBD.

### 2. Create fishing.md minigame documentation
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: docs/outline/minigames/fishing.md
- **Requested**: Create fishing.md in minigames folder with the provided fishing minigame information. Format properly as markdown but do not edit the content.
- **Context**: Fishing is a leveling minigame (1-10) with expanding loot tables as player progresses
- **Acceptance Criteria**:
  - [x] Create docs/outline/minigames/ folder
  - [x] Create fishing.md with all provided content
  - [x] Proper markdown formatting (headers, tables, lists)
  - [x] Content preserved exactly as provided
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Created docs/minigames/fishing.md with all fishing content formatted using markdown headers for levels, tables for loot chances, and separate sections for special sets (Old Set, Mossy Set, Treasure Chest).

### 1. Add player with joystick movement and landscape orientation
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: GameView.swift, new Player.swift, new JoystickView.swift
- **Requested**: Add a player who is 1/2 by 1/2 a tile, rendered as a red circle, can move freely with a joystick. Game should be landscape on iPhone.
- **Context**: Core gameplay mechanic for player movement in the 2D adventure game
- **Acceptance Criteria**:
  - [ ] Player is 1/2 tile size (red circle)
  - [ ] Joystick allows free movement (not grid-locked)
  - [ ] App forced to landscape orientation
  - [ ] Player renders on top of world grid
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Created Player model, PlayerView, JoystickView, GameViewModel. Integrated in GameView with ZStack layering. Configured landscape-only in project.pbxproj.

