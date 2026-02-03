# Tasks

### 15. Combine collectibles and crafting tabs
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: Views/Inventory/CollectiblesPageView.swift, InventoryViewModel.swift
- **Requested**: Combine collectibles and crafting tabs into one view. Collectibles grid on the left, crafting menu on the right.
- **Context**: Simplify inventory UI by merging related tabs
- **Acceptance Criteria**:
  - [x] Collectibles grid on left side (5 columns, 240px width)
  - [x] Crafting recipes on right side (3 columns, 150px width)
  - [x] Remove separate crafting tab
  - [x] Detail panels still work for both (mutual exclusion)
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Rewrote CollectiblesPageView to use HStack with collectibles on left and crafting on right, separated by a divider. Reduced grid spacing and font sizes to fit. Added mutual exclusion so selecting a collectible clears recipe selection and vice versa. Removed crafting case from InventoryPage enum. Updated InventoryView switch statement. Deleted unused CraftingPageView.swift.

### 14. Update crafting recipes and simplify item types
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: Models/Recipe.swift, Models/ItemType.swift, docs/crafting-recipes.md
- **Requested**: Create crafting recipes documentation and update code: 2 Driftwood => 1 Wood, 5 Seaweed => 1 Plant Fiber, 2 Plant Fibers => 1 String, 2 Wood + 1 String + 4 Shark Teeth => Sword (tier 1), 2 Wood + 1 String + 4 Shark Teeth => Axe (tier 1), 1 Broken Wheel + 1 Wood => Wheel, 4 String => 1 Cotton, 5 Cotton + 5 Metal Scraps => 1 Sail, 1 Sail + 1 Wheel + 20 Metal Scraps + 10 Wood => Sailboat. Also: Axe to 1 tier only, remove flippers/wings/pegasusBoots (keep sailboat), remove all GearType (sails, motor, pouch).
- **Context**: Streamlining crafting progression and item types
- **Acceptance Criteria**:
  - [x] Create docs/crafting-recipes.md with all recipes
  - [x] Add Plant Fiber, String, Cotton, Sail to ResourceType
  - [x] Update Recipe.swift with all 9 recipes + unlock conditions
  - [x] Change Axe maxTier to 1
  - [x] Remove flippers, wings, pegasusBoots from MajorUpgradeType
  - [x] Remove GearType enum entirely
  - [x] Update any references to removed types
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Created docs/crafting-recipes.md with full recipe documentation. Added plantFiber, string, cotton, sail to ResourceType with display names, icons, and rarities. Removed cloth from ResourceType. Updated Recipe.swift with 9 recipes (wood, plantFiber, string, cotton, sword, axe, wheel, sail, sailboat), added unlocksAfter field and majorUpgrade CraftResult case. Added discoveredResources tracking to Inventory for recipe unlocking. Added isRecipeUnlocked and unlockedRecipes to InventoryViewModel. Updated CraftingPageView to only show unlocked recipes. Changed axe maxTier to 1. Removed GearType enum, GearInventory struct, gear property from Inventory, and gearSection from ItemsPageView. Simplified MajorUpgradeType to only sailboat.

### 13. Implement crafting system
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: Views/Inventory/CraftingPageView.swift, Models/, ViewModels/
- **Requested**: Implement crafting system with: 1) Grid of unlocked recipes (5 columns x 6 rows like collectibles), 2) Red/green color indicating craftability, 3) Click recipe to see required items, 4) Green craft button when craftable, 5) Crafted item moves to collectibles. Recipes: Fixed Wheel (4 driftwood + 1 broken wheel), Sword (5 shark teeth + 8 driftwood).
- **Context**: Core crafting gameplay loop
- **Acceptance Criteria**:
  - [x] Kiro specs completed (init, requirements, design, tasks)
  - [x] Recipe grid display (5x6 like collectibles)
  - [x] Red/green color based on craftability
  - [x] Recipe detail view with required items
  - [x] Craft button (green when craftable)
  - [x] Crafted items added to collectibles / tools upgraded
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Created Recipe.swift with CraftingMaterial struct and CraftResult enum (supports collectibles and tool upgrades). Added fixedWheel to ResourceType. Added crafting methods to InventoryViewModel (materialCount, canCraft, craft, consumeMaterial). Created RecipeSlotView (green/red border based on craftability), RecipeDetailPanel (materials list with have/need, craft button). Updated CraftingPageView with 5-column grid and detail panel overlay. Two recipes: Fixed Wheel (4 driftwood + 1 broken wheel) and Sword (5 shark teeth + 8 driftwood, upgrades sword tier to 1).

### 12. Add Crafting tab to inventory
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: InventoryViewModel.swift, InventoryView.swift
- **Requested**: Add a new tab in the inventory called "Crafting". This is a placeholder for crafting system that will be implemented afterwards.
- **Context**: Preparing UI structure for upcoming crafting feature
- **Acceptance Criteria**:
  - [x] Add crafting case to InventoryPage enum
  - [x] Add crafting tab to inventory header
  - [x] Create placeholder CraftingPageView
  - [x] Tab displays correctly in inventory UI
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Added `crafting` case to InventoryPage enum (index 2, shifted character to 3) with title "Crafting" and hammer icon. Created CraftingPageView.swift with "Coming Soon" placeholder. Updated InventoryView switch to include crafting case.

### 11. Respawn player when clicking Main Menu from death screen
- **Status**: COMPLETED
- **Type**: Bug
- **Location**: GameViewModel.swift:215
- **Requested**: When player dies and clicks "Main Menu", the player should also respawn with full HP. They should go to main menu and not enter the world until they select that save again, but when they do return, they should have full HP (not still be dead).
- **Context**: Currently clicking Main Menu leaves player in dead state, so returning to the game shows death screen again
- **Acceptance Criteria**:
  - [x] Clicking "Main Menu" on death screen resets player health to max
  - [x] Player is respawned (isDead = false, position reset)
  - [x] Game state is saved before returning to menu
  - [x] Returning to saved game shows player alive with full HP
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Modified returnToMainMenu() to include respawn logic before saving and exiting. Resets position (to last land position if drowned), clears swimming state, restores health/stamina to max, sets isDead=false, then saves profile before returning to menu.

### 10. Double fish icon size in collectibles and total bonuses
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: CharacterPageView.swift, InventorySlotView.swift, CollectiblesPageView.swift
- **Requested**: In the collectibles and total bonuses screens, the fish icon needs to be double the size it currently is
- **Context**: Fish icons are too small to see clearly
- **Acceptance Criteria**:
  - [x] Fish icon in Total Bonuses (CharacterPageView) doubled from 16 to 32
  - [x] Item icons in collectibles grid (InventorySlotView) increased from 28 to 40
- **Failure Count**: 0
- **Failures**: None
- **Solution**: CharacterPageView fish icon frame changed from 16x16 to 32x32. InventorySlotView slot size increased from 44 to 56, custom image icons increased from 28x28 to 40x40. CollectiblesPageView grid columns updated to match new 56px slot size.

### 9. Implement death/game over screen
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: Views/DeathScreenView.swift, ViewModels/GameViewModel.swift, Views/GameView.swift, ContentView.swift
- **Requested**: When player loses all HP, show a death screen with 2 options: (1) Main Menu button - returns to main menu with play button, (2) Respawn button - respawns player where they died. If player died in ocean, respawn at last land position touched.
- **Context**: Core gameplay loop - players need a way to recover from death
- **Acceptance Criteria**:
  - [x] Death screen appears when health reaches 0
  - [x] Main Menu button returns to main menu
  - [x] Respawn button respawns player at death location
  - [x] If died in ocean, respawn at last land position
  - [x] Health resets on respawn
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Created DeathScreenView with "You Died" text and two buttons (Respawn/Main Menu). Modified GameViewModel to track isDead state, deathPosition (where player died), and respawnLandPosition (swimStartPoint if died in water). When health reaches 0 during drowning, shows death screen instead of teleporting. Respawn resets health to max and positions player at last land if drowned, or death position otherwise. Main Menu button stops game loop and triggers callback to return to main menu. Updated GameView to show death screen overlay and pass callback from ContentView.

### 8. Implement fishing system
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: Models/FishingState.swift, Models/FishingLootTable.swift, ViewModels/FishingViewModel.swift, Views/Fishing/
- **Requested**: Implement fishing with: 1) Give player fishing rod at game start, 2) Quick tool menu (hold button, drag to select tool from row), 3) Fishing button appears when rod equipped within 1 tile of water and not swimming, 4) Fishing minigame activates on button press, 5) Catches auto-add to inventory unless full. Use Kiro spec-driven development for all 4 stages before implementation.
- **Context**: Core gameplay loop - fishing minigame mechanics already documented in docs/outline/minigames/fishing.md
- **Acceptance Criteria**:
  - [x] Player starts with fishing rod in inventory
  - [x] Quick tool menu: hold button shows tool row, drag to equip
  - [x] Fishing button visible when: rod equipped, within 1 tile of water, not swimming
  - [x] Fishing minigame functional
  - [x] Catches auto-added to inventory (or rejected if full)
  - [x] Kiro specs completed (init, requirements, design, tasks)
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Created complete fishing system via Kiro specs (docs/.specs/). New files: FishingState.swift (level 1-10, catches tracking, level thresholds), FishingLootTable.swift (all 10 loot tables from fishing.md with Old Set/Mossy Set/Treasure Chest logic), FishingViewModel.swift (minigame with bouncing indicator, green/perfect zones, combo tracking). Views: ToolButtonView (long-press HUD), ToolQuickMenuView (hold-drag selection), FishButtonView (context-sensitive), FishingMinigameView (timing bar), FishingResultsView (session summary with level-up). Modified: Player.swift (+equippedTool), SaveProfile.swift (+fishingState, +equippedTool persistence), Inventory.swift (starter rod tier=1), GameViewModel.swift (tool menu, isNearWater, canFish, fishing flow), GameView.swift (UI integration), ItemType.swift (+16 fishing resources), InventorySlotView.swift (resource colors).

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

