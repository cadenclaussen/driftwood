# Archived Tasks

### 32. Wave 5 Theme migration: screen views and inline HUD structs
- **Status**: COMPLETED
- **Type**: Feature
- **Solution**: Migrated InventoryView, FullMapView, DeathScreenView, MainMenuView, ProfileSelectionView, ProfileCardView, MainMenuConfirmationView, and GameView inline structs (HeartsView, StaminaBarView, SprintButtonView) to Theme tokens.

### 31. Wave 3 Theme migration: Inventory panel views
- **Status**: COMPLETED
- **Type**: Feature
- **Solution**: Migrated ItemDetailPanel and RecipeDetailPanel to Theme tokens. Replaced rarityColor with Theme.Color.rarity(). Stat colors mapped to Theme.Color.stat* tokens.

### 30. Wave 1 Theme migration: Leaf view files
- **Status**: COMPLETED
- **Type**: Feature
- **Solution**: Migrated 12 leaf view files (MagicBarView, JoystickView, MiniMapView, WindArrowView, SailboatPromptView, TeleportPromptView, WaypointMarkerView, GameMiniMapView, MenuButton, InventoryButton, ItemIconView, LevelUpNotificationView) to Theme tokens.

### 29. Wave 4 Theme migration: Page views
- **Status**: COMPLETED
- **Type**: Feature
- **Solution**: Migrated ItemsPageView, CollectiblesPageView, CharacterPageView to Theme tokens. Replaced rarityColor function with Theme.Color.rarity() delegation.

### 28. Add Theme.swift to Xcode project
- **Status**: COMPLETED
- **Type**: Feature
- **Solution**: No changes needed. PBXFileSystemSynchronizedRootGroup auto-discovers files.

### 27. Centralized Theme system
- **Status**: COMPLETED
- **Type**: Feature
- **Solution**: Created Theme.swift with all design tokens (Color, Font, Spacing, Radius, Border, Size, Anim, Opacity). Migrated 30+ view files across 5 waves. All hardcoded styling replaced with Theme references. No visual changes. Build verified successful.

### 26. Move right-side buttons further left
- **Status**: COMPLETED
- **Type**: Feature
- **Solution**: Added rightBuffer (36) in controlsLayer. Applied to inventory/menu buttons, tool/sprint buttons, and wind arrow.

### 25. Rotate sailboat 180 degrees and add main menu confirmation
- **Status**: COMPLETED
- **Type**: Feature
- **Solution**: Changed SailboatView rotation from `+ .pi / 2` to `- .pi / 2`. Created MainMenuConfirmationView.swift. Added showMainMenuConfirmation state to GameView.

### 24. Make sailboat twice as big with water boarding
- **Status**: COMPLETED
- **Type**: Feature
- **Solution**: Changed SailboatView size 32->64, collision halfSize 7->14. Removed !player.isSwimming from isNearSailboat guard.

### 23. Add blackout transition to teleport
- **Status**: COMPLETED
- **Type**: Feature
- **Solution**: Modified teleportTo() to close map, fade to black (0.2s), wait 250ms, move player, save, fade back in (0.2s).

### 22. Implement teleport and map system
- **Status**: COMPLETED
- **Type**: Feature
- **Solution**: Created TeleportPad model, teleportPad tile type, Views/Map/ with GameMiniMapView, FullMapView, WaypointMarkerView, TeleportPromptView.

### 21. Implement sailboat system
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: Models/Sailboat.swift, Models/SailingState.swift, Views/Sailing/, GameViewModel.swift, GameView.swift
- **Solution**: Created Sailboat.swift (Codable position), SailingState.swift (wind angle/direction/drift). Extended SaveProfile with sailboatPosition and isSailing. Added Player.isSailing and sailingSpeedMultiplier. GameViewModel: added sailboat/sailingState properties, canSummonSailboat/isNearSailboat/isNearLandWhileSailing computed properties, updateSailingPosition() with wind, canSailTo() for water-only collision, summonSailboat()/boardSailboat()/disembark() actions. Created Views/Sailing/ with SailboatView (48x36 black rectangle), WindArrowView (rotating arrow in HUD), SailboatPromptView (contextual buttons). GameView: shows boat in world, swaps player/boat at center when sailing, wind arrow in HUD when sailing, contextual prompts. Added Sailboat.imageset with custom sailboat.png icon. Updated MajorUpgradeType to use custom image. Updated CharacterPageView.upgradeIcon() to render custom image for upgrades.

### 20. Implement directional tool usage (fishing, axe)
- **Status**: COMPLETED
- **Type**: Feature
- **Solution**: canFish now checks isFacingWater(). useAxe() checks isFacingTree() and isFacingRock(). Helper functions facingOffset(), isFacingWater(), isFacingTree(), isFacingRock() use player.facingDirection.

### 19. Implement rock sprites with collision
- **Status**: COMPLETED
- **Type**: Feature
- **Solution**: Created rock overlay system with custom collision bounds per rock type.

### 18. Implement tree with overlay depth sorting
- **Status**: COMPLETED
- **Type**: Feature
- **Solution**: Created 6 imagesets. Added treeTrunk to TileType. Created OverlayType/WorldOverlay. Updated World.swift/GameView.swift with overlay rendering and depth sorting.

### 17. Implement 1000x1000 world with camera system
- **Status**: COMPLETED
- **Type**: Feature
- **Solution**: World expanded to 1000x1000 tiles. Camera-based rendering. Only visible tiles rendered.

### 16. Implement sword swing animation (upward direction)
- **Status**: COMPLETED
- **Type**: Feature
- **Solution**: Added 10 SwordSwingUp imagesets. Added attack animation state. Generalized ToolButtonView.

### 15. Combine collectibles and crafting tabs
- **Status**: COMPLETED
- **Type**: Feature
- **Solution**: Rewrote CollectiblesPageView with HStack layout. Removed separate crafting tab.

### 14. Update crafting recipes and simplify item types
- **Status**: COMPLETED
- **Type**: Feature
- **Solution**: Added plantFiber, string, cotton, sail to ResourceType. Updated recipes. Changed axe maxTier to 1. Removed GearType.

### 13. Implement crafting system
- **Status**: COMPLETED
- **Type**: Feature
- **Solution**: Created Recipe.swift, RecipeSlotView, RecipeDetailPanel, CraftingPageView.

### 12. Add Crafting tab to inventory
- **Status**: COMPLETED
- **Type**: Feature
- **Solution**: Added crafting case to InventoryPage enum.

### 11. Respawn player when clicking Main Menu from death screen
- **Status**: COMPLETED
- **Type**: Bug
- **Solution**: Modified returnToMainMenu() to include respawn logic.

### 10. Double fish icon size in collectibles and total bonuses
- **Status**: COMPLETED
- **Type**: Feature
- **Solution**: CharacterPageView fish icon 16->32. InventorySlotView slot 44->56, icons 28->40.

### 9. Implement death/game over screen
- **Status**: COMPLETED
- **Type**: Feature
- **Solution**: Created DeathScreenView. Modified GameViewModel to track isDead state.

### 8. Implement fishing system
- **Status**: COMPLETED
- **Type**: Feature
- **Solution**: Complete fishing system via Kiro specs. Created FishingState, FishingLootTable, FishingViewModel, fishing views.

### 7. Implement inventory system
- **Status**: COMPLETED
- **Type**: Feature
- **Solution**: Created full inventory system with models, views, and view models.

### 6. Add 5 hearts health system
- **Status**: COMPLETED
- **Type**: Feature
- **Solution**: Added health/maxHealth to Player. Created HeartsView.

### 5. Implement swimming
- **Status**: COMPLETED
- **Type**: Feature
- **Solution**: Added isSwimmable to TileType. Swimming uses stamina.

### 4. Create stamina system and sprinting system
- **Status**: COMPLETED
- **Type**: Feature
- **Solution**: Added stamina (100 max, 20/sec regen) and sprinting (2x speed).

### 3. Create player.md outline documentation
- **Status**: COMPLETED
- **Type**: Feature
- **Solution**: Created comprehensive player.md.

### 2. Create fishing.md minigame documentation
- **Status**: COMPLETED
- **Type**: Feature
- **Solution**: Created docs/minigames/fishing.md.

### 1. Add player with joystick movement and landscape orientation
- **Status**: COMPLETED
- **Type**: Feature
- **Solution**: Created Player model, PlayerView, JoystickView, GameViewModel.
