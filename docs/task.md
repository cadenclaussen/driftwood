# Tasks

### 21. Implement sailboat system
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: Models/Sailboat.swift, Models/SailingState.swift, Views/Sailing/, GameViewModel.swift, GameView.swift
- **Requested**: Implement sailboat that players craft and use to navigate the ocean. Controls via joystick with wind mechanics (HUD arrow shows direction, gently pushes boat, direction drifts randomly). Speed is 4x swim speed. Boarding/disembarking via contextual prompts. Summonable from inventory when 1 tile from water and facing it. Boat stays where left in world. Black rectangle placeholder sprite (larger than character).
- **Context**: Major upgrade for ocean exploration. Crafted from 1 Sail + 1 Wheel + 20 Metal Scraps + 10 Wood. No fishing from boat, no other islands yet.
- **Acceptance Criteria**:
  - [x] Sailboat model with position tracking
  - [x] SailingState model with wind mechanics (angle, drift, strength)
  - [x] Save/load sailboat position and sailing state
  - [x] Sailing movement at 4x swim speed (2x walk)
  - [x] Wind pushes boat, direction drifts over time
  - [x] Water-only collision (boat stays on water)
  - [x] Summon/board/disembark actions
  - [x] UI views: SailboatView, WindArrowView, SailboatPromptView
  - [x] GameView integration (conditional player/boat rendering)
  - [x] Crafting already wired up via existing MajorUpgrades
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Created Sailboat.swift (Codable position), SailingState.swift (wind angle/direction/drift). Extended SaveProfile with sailboatPosition and isSailing. Added Player.isSailing and sailingSpeedMultiplier. GameViewModel: added sailboat/sailingState properties, canSummonSailboat/isNearSailboat/isNearLandWhileSailing computed properties, updateSailingPosition() with wind, canSailTo() for water-only collision, summonSailboat()/boardSailboat()/disembark() actions. Created Views/Sailing/ with SailboatView (48x36 black rectangle), WindArrowView (rotating arrow in HUD), SailboatPromptView (contextual buttons). GameView: shows boat in world, swaps player/boat at center when sailing, wind arrow in HUD when sailing, contextual prompts. Added Sailboat.imageset with custom sailboat.png icon. Updated MajorUpgradeType to use custom image (usesCustomImage=true, iconName="Sailboat"). Updated CharacterPageView.upgradeIcon() to render custom image for upgrades that use them.

### 20. Implement directional tool usage (fishing, axe)
- **Status**: IN_PROGRESS
- **Type**: Feature
- **Location**: GameViewModel.swift, World.swift
- **Requested**: Change fishing rod to only work if facing towards water (in addition to being 1 block away). Implement axe: if less than 1 block from tree and facing it, gives wood; if less than 1 block from rock and facing it, gives stone.
- **Context**: Tools should require facing the target object, making gameplay more intentional
- **Acceptance Criteria**:
  - [ ] Fishing rod only activates when facing water
  - [ ] Axe gives wood when facing tree within 1 block
  - [ ] Axe gives stone when facing rock within 1 block
  - [ ] Resources added to inventory on tool use
- **Failure Count**: 0
- **Failures**: None
- **Solution**: TBD

### 19. Implement rock sprites with collision
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: Tile.swift, World.swift, GameView.swift, Assets.xcassets
- **Requested**: Add rock sprites as tile overlays with collision. 4 small rocks, 3 medium rocks, 1 large rock (2 tiles: left/right). Rocks overlay existing tiles (like grass) but block player movement. Each rock type has custom collision bounds (pixel offsets from 32px tile edges). Test by placing one small-1, one mid-1, and one large rock on the island.
- **Context**: Second world decoration type. Unlike trees, rocks are ground-level obstacles without depth sorting - they just overlay tiles and block movement with partial collision bounds.
- **Acceptance Criteria**:
  - [ ] Add 9 imagesets to Assets.xcassets (RockSmall1-4, RockMid1-3, RockBigLeft, RockBigRight)
  - [ ] Create rock overlay system with custom collision bounds per rock type
  - [ ] Collision bounds use pixel offsets: small-1 (L6,R5,B3,T12), small-2 (L10,R1,B12,T3), small-3 (L2,R9,B9,T6), small-4 (L2,R9,B2,T13), mid-1 (L2,R4,B2,T12), mid-2 (L4,R2,B10,T4), mid-3 (L1,R5,B8,T6), large combined (L12,R12,B6,T5)
  - [ ] Place test rocks on island (one small-1, one mid-1, one large)
  - [ ] Player blocked by rock collision bounds
- **Failure Count**: 0
- **Failures**: None
- **Solution**: TBD

### 18. Implement tree with overlay depth sorting
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: Tile.swift, World.swift, GameView.swift, Assets.xcassets
- **Requested**: Create a tree on the home island using 6 32x32 assets. The tree is a 3x2 grid: top row (flake-top-left, top, flake-top-right), bottom row (flake-bottom-left, trunk, flake-bottom-right). The trunk is a solid tile that replaces the ground and blocks player movement. The other 5 pieces are overlays that render on top of the player when the player is "behind" them (y-position based depth sorting). Tree spawns 4 tiles to the right of island center. Scale all assets to fit exactly in one tile (32px → 24pt).
- **Context**: First world decoration with depth-sorted overlays. Establishes pattern for future trees and objects.
- **Acceptance Criteria**:
  - [x] Add 6 imagesets to Assets.xcassets (Tree1Trunk, Tree1Top, Tree1FlakeTopLeft, etc.)
  - [x] Trunk tile replaces ground tile and has solid collision
  - [x] 5 overlay tiles render with depth sorting (on top of player when player.y < overlay.y)
  - [x] Tree spawns 4 tiles right of island center
  - [x] Assets scaled from 32px to 24pt tile size
- **Failure Count**: 0
- **Failures**: None
- **Solution**:
  - Created 6 imagesets in Assets.xcassets/PixelArt/ (Tree1Trunk, Tree1Top, Tree1FlakeTopLeft, Tree1FlakeTopRight, Tree1FlakeBottomLeft, Tree1FlakeBottomRight)
  - Added treeTrunk to TileType enum with isWalkable=false, isSwimmable=false, and spriteName property
  - Created OverlayType enum and WorldOverlay struct (Identifiable) in Tile.swift
  - Updated World.swift: added overlays array, islandCenterX/Y computed properties, addTree() function that places trunk tile and 5 overlays
  - Updated GameView.swift: TileView now renders sprite for tiles with spriteName, added overlaysLayer() function with depth sorting (behindPlayer parameter filters overlays based on playerTileY comparison)
  - Depth sorting: overlays render behind player when playerTileY >= overlayY, in front when playerTileY < overlayY

### 17. Implement 1000x1000 world with camera system
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: World.swift, GameView.swift, GameViewModel.swift, SaveProfile.swift, MiniMapView.swift
- **Requested**: Implement extremely large world feature - 1000x1000 ocean with current island in the center. Screen must be centered around the character, and the camera tiles as the character moves.
- **Context**: Major architectural change to support exploration. Current world is 16x16 tiles. Need camera following player and only rendering visible tiles for performance.
- **Acceptance Criteria**:
  - [x] World expanded to 1000x1000 tiles
  - [x] Island centered at position ~500,500 in world
  - [x] Camera follows player (screen centered on player)
  - [x] Only visible tiles rendered (performance optimization)
  - [x] Player can explore ocean in all directions
  - [x] Minimap updated for larger world
- **Failure Count**: 0
- **Failures**: None
- **Solution**:
  - World.swift: Changed from 16x16 to 1000x1000 tiles. Replaced oceanPadding with worldSize=1000, islandOriginX/Y computed properties to center 10x10 island at tile (495,495).
  - GameView.swift: Replaced static worldOffset centering with camera-based rendering. Camera is centered on player position. New cameraGrid() function calculates visible tile range based on player position and only renders tiles on screen. Uses pixel-level offset for smooth scrolling. Player always rendered at screen center.
  - SaveProfile.swift: Updated empty() to spawn player at island center (tile 500,500) instead of old world center.
  - MiniMapView.swift: Changed from rendering entire world to showing 50x50 tile region centered on player position (viewRadius=25), making it efficient for the larger world.
  - SaveManager.swift: Added migrateProfilesToNewWorld() to automatically migrate old saves from the 16x16 world to the new 1000x1000 world center.

### 16. Implement sword swing animation (upward direction)
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: PlayerView.swift, GameViewModel.swift, Player.swift, Assets.xcassets
- **Requested**: Animate the swing of the sword for facing upwards direction. Ten frames provided (swing-sword-up-1.png through swing-sword-up-10.png). Animation plays when character has sword equipped and clicks the tool button.
- **Context**: First sword attack animation, upward direction only for now
- **Acceptance Criteria**:
  - [x] Add 10 animation frames to asset catalog
  - [x] Create animation system to cycle through frames
  - [x] Trigger animation when tool button pressed with sword equipped
  - [x] Animation plays for upward facing direction
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Added 10 SwordSwingUp imagesets (SwordSwingUp1-10) to Assets.xcassets. Added attack animation state to Player (isAttacking, attackAnimationFrame, attackAnimationTime). Added attackSpriteName(frame:) to FacingDirection (returns sprite name for up, nil for others). Updated PlayerView to show animation frame when attacking. Added startSwordSwing() and updateAttackAnimation() to GameViewModel with 50ms per frame timing. Generalized ToolButtonView to use canUseTool instead of canFish, and useTool() which routes to appropriate action based on equipped tool.

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

