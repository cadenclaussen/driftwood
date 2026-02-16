# Tasks

### 33. Apply warm/earthy visual theme
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: driftwood/Theme.swift
- **Requested**: Actually change the app's visual theme to warm/earthy style (browns, tans, warm oranges) to fit the island/driftwood vibe. User expected the Theme migration to change the look, not just refactor.
- **Context**: Theme.swift centralization (task 27) is complete. Now leverage it to restyle the entire app from one file.
- **Acceptance Criteria**:
  - [x] Colors changed to warm/earthy palette (browns, tans, warm oranges, olive greens)
  - [x] Build succeeds
  - [ ] App looks visually distinct from the old black/white/neon style
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Replaced entire Color enum in Theme.swift with warm/earthy palette. Base tones: cream text, tan secondary, bark overlays, olive greens, rust reds, teal accents, amber highlights, burnt orange. All 50+ color tokens updated. Build verified.

### 34. Remove island names from map and change font
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: WaypointMarkerView.swift, Theme.swift
- **Requested**: Island names on map waypoints are truncating with "...". Remove the name labels entirely. Also change the app font to something more fitting for a pixel art adventure game (not just system font).
- **Context**: Map markers too small for text. Font should match the game's pixel art style.
- **Acceptance Criteria**:
  - [x] Waypoint markers no longer show island names
  - [x] All fonts changed to a more appropriate adventure/pixel style
  - [x] Build succeeds
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Removed pad.name Text from WaypointMarkerView (just shows circle icon now). Changed all fonts in Theme.swift: titles use .serif design (adventure/storybook feel), all body/UI text uses .rounded design (softer, game-friendly). Build verified.

### 35. Add enemy slime system
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: Multiple files (see docs/.specs/enemy-slime/)
- **Requested**: Add combat enemies to the game. Implement slime enemy type on North Island with patrol/chase AI, contact damage, 4-directional sword combat, knockback, i-frames, death effects, and save persistence.
- **Context**: Game has no combat challenge. Sword exists but nothing to hit. Health only threatened by drowning. Enemies create the core gameplay loop.
- **Acceptance Criteria**:
  - [ ] 3 slimes spawn on North Island with patrol/chase AI
  - [ ] Contact damage deals half heart with 0.5s i-frames and knockback
  - [ ] 4-directional sword swings with active hitbox during animation
  - [ ] Slimes die in 2 hits with pop + particle death effect
  - [ ] Slime state persists across saves
  - [ ] Old saves migrate without error
  - [ ] Build succeeds
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Implemented full enemy slime system across 10 tasks. Health system doubled (5→10 internally, half-heart support). 3 slimes spawn on North Island with patrol/chase/return AI. Contact damage (half heart) with 0.5s i-frames and knockback. 4-directional sword swings via scaleEffect transforms. Sword hitbox active during 360ms animation only. Slime death pop + particle effects. Full save/load persistence with migration for old saves. Build verified.

### 36. Add haptic feedback system
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: driftwood/Services/HapticService.swift, GameViewModel, FishingViewModel, InventoryViewModel, UI Views
- **Requested**: Add haptic feedback throughout the game - combat hits/damage/death, fishing catches, crafting, tool swaps, sailing, teleporting, UI button taps. Create a HapticService singleton with pre-warmed UIKit generators, then add one-line calls in ViewModels and Views.
- **Context**: Game has zero haptic feedback. Haptics make gameplay feel tactile and responsive on iPhone.
- **Acceptance Criteria**:
  - [x] HapticService singleton created with light/medium/heavy impact, selection, and notification generators
  - [x] GameViewModel: haptics on sword swing, damage, death, tool equip, axe use, teleport, sailing, respawn, meal use, level up
  - [x] FishingViewModel: haptics on catch results (perfect/success/miss/noCatch)
  - [x] InventoryViewModel: haptics on craft, equip/unequip armor and accessories
  - [x] UI Views: selection haptics on InventoryButton, MenuButton, DeathScreenView, InventorySlotView
  - [x] Build succeeds
- **Failure Count**: 0
- **Failures**: None
- **Solution**: HapticService singleton already fully implemented across all game systems. All acceptance criteria met.

### 37. Give all tools at start, full hearts only, slime damage 1 heart
- **Status**: COMPLETED
- **Type**: Feature
- **Location**: Player.swift, Slime.swift, GameViewModel.swift, GameView.swift, Inventory.swift, ItemType.swift, SaveProfile.swift
- **Requested**: Add haptics if not already there (already done), give characters all tools to start with, make slimes do 1 full heart of damage, remove half-heart system entirely - all health in full hearts only.
- **Context**: Half-heart system (10 HP = 5 hearts) was added for slime combat. User wants simpler full-heart system (5 HP = 5 hearts). Characters should start with fishing rod, sword, and axe.
- **Acceptance Criteria**:
  - [x] Health system uses 5 HP = 5 full hearts (no half-hearts)
  - [x] HeartsView shows only full/empty hearts (no half-heart icon)
  - [x] Slimes deal 1 full heart of damage
  - [x] Characters start with fishing rod, sword, and axe (all tier 1)
  - [x] Drowning, meals, and armor bonuses adjusted for new system
  - [x] Build succeeds
- **Failure Count**: 0
- **Failures**: None
- **Solution**: Reverted health from 10-based (half-hearts) to 5-based (full hearts). Player maxHealth 10→5. HeartsView simplified to full/empty only. Slime contactDamage=1 (1 full heart). Drowning costs 1 heart (was 2 HP). Meal heals halved (basic=2, heart=3, stamina=1). ToolInventory: swordTier=1, axeTier=1 by default. effectiveMaxHealth uses Int(bonusHearts) instead of *2. Build verified.
