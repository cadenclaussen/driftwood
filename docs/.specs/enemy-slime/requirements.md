# Enemy Slime System - Requirements

## Functional Requirements

### FR-1: Slime Entity Model
- **Type**: Ubiquitous
- **Statement**: The system shall represent each slime as an entity with a unique ID, world position (CGPoint), health (Int), alive/dead state, spawn origin (tile coordinates), and current AI state (patrol/chase/returning).
- **Acceptance Criteria**:
  - [ ] Slime struct is Codable and Identifiable
  - [ ] Slime has position, health (max 2), isAlive, spawnOrigin, and aiState fields
  - [ ] Slime has a collision hitbox size (matching sprite size)
- **Priority**: Must

### FR-2: Slime Spawning on North Island
- **Type**: Event-Driven
- **Statement**: When the world is generated, the system shall place 3 slimes at fixed grass tile positions on North Island.
- **Acceptance Criteria**:
  - [ ] Exactly 3 slimes spawn on North Island grass tiles
  - [ ] Spawn positions are deterministic (same every new game)
  - [ ] No slimes spawn on Home Island or ocean
  - [ ] Slime positions are stored in world pixel coordinates (tile * tileSize + offset)
- **Priority**: Must

### FR-3: Slime Patrol AI
- **Type**: State-Driven
- **Statement**: While in the patrol state, the slime shall wander randomly within 5 tiles of its spawn origin at approximately 40% of the player's walk speed (40 px/s).
- **Acceptance Criteria**:
  - [ ] Slime picks a random walkable target within 5 tiles of spawn
  - [ ] Slime moves toward target at ~40 px/s
  - [ ] On reaching target, slime pauses briefly then picks a new target
  - [ ] Slime does not walk onto non-walkable tiles (ocean, rock)
  - [ ] Slime does not leave the 5-tile patrol radius from spawn origin
- **Priority**: Must

### FR-4: Slime Chase AI
- **Type**: Event-Driven
- **Statement**: When the player enters within 8 tiles (192 pixels) of a patrolling slime, the slime shall transition to chase state and move directly toward the player at approximately 60-70% of walk speed (60-70 px/s).
- **Acceptance Criteria**:
  - [ ] Slime detects player within 8-tile radius (Euclidean distance)
  - [ ] Slime moves directly toward player position each frame
  - [ ] Chase speed is 60-70 px/s (faster than patrol, slower than player walk)
  - [ ] Slime respects tile collision (does not walk through rocks/ocean)
- **Priority**: Must

### FR-5: Slime Return to Patrol
- **Type**: Event-Driven
- **Statement**: When the player moves beyond the 8-tile chase range, the slime shall stop chasing and return to its patrol area around the spawn origin.
- **Acceptance Criteria**:
  - [ ] Slime stops chasing when player distance exceeds 8 tiles
  - [ ] Slime walks back toward spawn origin at patrol speed
  - [ ] Once near spawn origin, slime resumes normal patrol behavior
  - [ ] Transition is smooth (no teleporting)
- **Priority**: Must

### FR-6: Contact Damage to Player
- **Type**: Event-Driven
- **Statement**: When the player's hitbox overlaps a slime's hitbox, the system shall deal half a heart (0.5) of damage to the player.
- **Acceptance Criteria**:
  - [ ] Damage is dealt when player hitbox (24x32) overlaps slime hitbox
  - [ ] Damage amount is half a heart
  - [ ] Player health decreases correctly (existing health system)
  - [ ] Damage triggers only on alive slimes
- **Priority**: Must

### FR-7: Player Invincibility Frames
- **Type**: State-Driven
- **Statement**: While the player is in the invincibility state (0.5 seconds after taking contact damage), the system shall prevent all further enemy damage and display a blinking/flashing visual effect on the player sprite.
- **Acceptance Criteria**:
  - [ ] Player cannot take damage for 0.5 seconds after being hit
  - [ ] Player sprite blinks/flashes during i-frames (opacity toggle every ~0.1s)
  - [ ] I-frame timer resets on each new damage instance
  - [ ] I-frames apply to all slime contacts (not just the one that hit)
- **Priority**: Must

### FR-8: Contact Knockback - Player
- **Type**: Event-Driven
- **Statement**: When the player takes contact damage from a slime, the system shall push the player away from the slime by a fixed distance in the opposite direction.
- **Acceptance Criteria**:
  - [ ] Player is knocked back along the vector from slime center to player center
  - [ ] Knockback distance is noticeable but not excessive (~32-48 pixels)
  - [ ] Knockback respects collision (player stops at walls/rocks, not pushed into ocean)
  - [ ] Knockback feels snappy (applied instantly or over 1-2 frames)
- **Priority**: Must

### FR-9: Sword Hitbox - 4 Directional
- **Type**: Event-Driven
- **Statement**: When the player swings the sword, the system shall place the sword hitbox in front of the player based on the current facing direction (up, down, left, right).
- **Acceptance Criteria**:
  - [ ] Sword hitbox is placed above player when facing up
  - [ ] Sword hitbox is placed below player when facing down
  - [ ] Sword hitbox is placed left of player when facing left
  - [ ] Sword hitbox is placed right of player when facing right
  - [ ] Hitbox size is consistent across all directions (~24x24 pixels or similar)
- **Priority**: Must

### FR-10: Sword Hitbox Active Window
- **Type**: State-Driven
- **Statement**: While the sword swing animation is playing (~360ms, 12 frames), the sword hitbox shall be active and able to damage enemies. The hitbox shall be inactive at all other times.
- **Acceptance Criteria**:
  - [ ] Hitbox is only checked during `player.isAttacking == true`
  - [ ] Hitbox deactivates when attack animation ends
  - [ ] A single swing can only damage a given slime once (no multi-hit per swing)
- **Priority**: Must

### FR-11: Sword Damage to Slime
- **Type**: Event-Driven
- **Statement**: When the active sword hitbox overlaps a slime's hitbox, the system shall deal 1 HP of damage to the slime.
- **Acceptance Criteria**:
  - [ ] Slime loses 1 HP per sword hit
  - [ ] Slime with 2 HP dies in exactly 2 hits
  - [ ] Damage only applies to alive slimes
  - [ ] Hit slime displays a brief visual feedback (flash white/red)
- **Priority**: Must

### FR-12: Sword Knockback on Slime
- **Type**: Event-Driven
- **Statement**: When a slime is hit by the sword, the system shall push the slime away from the player in the player's facing direction.
- **Acceptance Criteria**:
  - [ ] Slime is knocked back along the player's facing direction vector
  - [ ] Knockback distance is ~32-48 pixels
  - [ ] Knockback respects tile collision (slime stops at non-walkable tiles)
  - [ ] Knockback feels responsive and immediate
- **Priority**: Must

### FR-13: Slime Death Effect
- **Type**: Event-Driven
- **Statement**: When a slime's health reaches 0, the system shall play a pop animation with particle burst, then permanently remove the slime from the world.
- **Acceptance Criteria**:
  - [ ] Slime sprite scales up briefly then disappears (pop effect)
  - [ ] Small particles scatter outward from slime position (3-6 particles)
  - [ ] Particles fade out over ~0.3-0.5 seconds
  - [ ] Slime is marked as dead and no longer rendered or interactive
  - [ ] Dead slime is never re-added to the world (permanent removal)
- **Priority**: Must

### FR-14: Slime Bounce Animation
- **Type**: State-Driven
- **Statement**: While a slime is alive, the system shall display a continuous bounce-in-place animation by scaling the sprite vertically.
- **Acceptance Criteria**:
  - [ ] Slime sprite squishes and stretches rhythmically (scaleY oscillation)
  - [ ] Bounce cycle is ~0.8-1.0 seconds per loop
  - [ ] Animation plays during patrol, chase, and idle states
  - [ ] Animation is smooth at 60 FPS
- **Priority**: Should

### FR-15: Save Slime State
- **Type**: Event-Driven
- **Statement**: When the game auto-saves or manually saves, the system shall persist each slime's alive/dead state and current position to the save profile.
- **Acceptance Criteria**:
  - [ ] Slime data is added to SaveProfile as a Codable field
  - [ ] Each slime's ID, position, health, and isAlive are saved
  - [ ] Save works with existing 30-second auto-save cycle
  - [ ] Save data is per-profile (3 independent profiles)
- **Priority**: Must

### FR-16: Load Slime State
- **Type**: Event-Driven
- **Statement**: When a save profile is loaded, the system shall restore slimes to their saved positions and states. Dead slimes shall remain dead.
- **Acceptance Criteria**:
  - [ ] Slimes restore to exact saved positions
  - [ ] Dead slimes are not rendered or interactive
  - [ ] Slime health is restored to saved value
  - [ ] Loading a new/empty profile spawns fresh slimes at default positions
- **Priority**: Must

### FR-17: Save Migration for Existing Profiles
- **Type**: Unwanted Behavior
- **Statement**: If an existing save profile does not contain slime data (pre-enemy saves), the system shall initialize default slime spawns rather than crashing or corrupting the save.
- **Acceptance Criteria**:
  - [ ] Old saves without slime data load without error
  - [ ] Missing slime data defaults to fresh spawns (3 alive slimes at default positions)
  - [ ] No data loss in other save fields during migration
- **Priority**: Must

### FR-18: Player Death Does Not Reset Slimes
- **Type**: Event-Driven
- **Statement**: When the player dies and respawns, the system shall keep all slimes in their current state (position, health, alive/dead).
- **Acceptance Criteria**:
  - [ ] Slimes do not move or reset on player death
  - [ ] Damaged slimes keep their reduced HP
  - [ ] Dead slimes stay dead after player respawn
- **Priority**: Must

### FR-19: Slime Rendering and Depth Sorting
- **Type**: Ubiquitous
- **Statement**: The system shall render alive slimes in the game world with correct depth sorting relative to the player, trees, and rocks.
- **Acceptance Criteria**:
  - [ ] Slimes render at their world position relative to camera
  - [ ] Slimes behind the player (higher on screen) render behind
  - [ ] Slimes in front of the player (lower on screen) render in front
  - [ ] Slimes use pixel-art rendering (no interpolation smoothing)
- **Priority**: Must

### FR-20: 4-Directional Sword Swing Animation
- **Type**: Event-Driven
- **Statement**: When the player swings the sword, the system shall play the swing animation matching the player's current facing direction.
- **Acceptance Criteria**:
  - [ ] Upward swing uses existing SwordSwingUp sprites
  - [ ] Down, left, and right swings need corresponding sprite assets or mirrored/rotated rendering
  - [ ] Animation timing is consistent across all directions (12 frames, 30ms each)
  - [ ] Player sprite shows correct facing during swing
- **Priority**: Must
- **Notes**: Currently only SwordSwingUp1-12 sprites exist. Down/left/right may need new sprites or programmatic transformation.

### FR-21: Slime-Tile Collision
- **Type**: Ubiquitous
- **Statement**: The system shall prevent slimes from moving onto non-walkable tiles (ocean, rock tiles, rock overlays).
- **Acceptance Criteria**:
  - [ ] Slimes cannot walk into ocean tiles
  - [ ] Slimes cannot walk through rock collision bounds
  - [ ] Slimes stay on the island surface
  - [ ] Collision uses same AABB pattern as player collision
- **Priority**: Must

## Non-Functional Requirements

### NFR-1: Performance - 60 FPS with Enemies
- **Category**: Performance
- **Statement**: The system shall maintain 60 FPS gameplay with up to 3 active slimes updating AI, collision, and rendering each frame.
- **Acceptance Criteria**:
  - [ ] No frame drops below 55 FPS with all 3 slimes active and visible
  - [ ] AI pathfinding does not cause frame hitches
  - [ ] Particle effects do not cause performance issues
- **Priority**: Must

### NFR-2: Extensibility for Future Enemy Types
- **Category**: Reliability
- **Statement**: The enemy system architecture shall support adding new enemy types in the future without major refactoring.
- **Acceptance Criteria**:
  - [ ] Enemy model uses a protocol or base pattern that other enemies can adopt
  - [ ] AI states are reusable or composable for different behaviors
  - [ ] Rendering pipeline handles enemies generically (not slime-specific)
- **Priority**: Should

### NFR-3: Visual Clarity
- **Category**: Usability
- **Statement**: The slime shall be visually distinct from the environment and clearly readable as an enemy at the game's default zoom level.
- **Acceptance Criteria**:
  - [ ] Green slime contrasts against brown/tan island terrain
  - [ ] Bounce animation makes slimes visually active and noticeable
  - [ ] Damage flash provides clear hit feedback
- **Priority**: Must

## Constraints

- **Sprite assets**: Only SwordSwingUp1-12 exist. Down/left/right swing sprites need to be created or generated via programmatic mirroring/rotation.
- **Tile size**: 24 pixels. All slime positioning and collision must align with the 24px tile grid.
- **Player hitbox**: Fixed at 24x32 pixels. Slime collision detection must use this exact hitbox.
- **Save format**: Must remain backwards-compatible with existing SaveProfile. Use optional field with default for migration.
- **Single-threaded update**: All AI and collision runs on the main thread in the 60 FPS game loop.

## Assumptions

- The slime sprite will be provided or created as a pixel art asset (green blob, ~24x24 or 32x32 pixels).
- North Island grass tiles are suitable spawn locations (no special terrain requirements).
- The existing health system (integer hearts) can represent half-heart damage (either use Float health or deal 1 damage where max is 10 representing 5 hearts).
- 3 slimes is a low enough count that simple direct-toward-player pathfinding is sufficient (no A* needed).
- Knockback collision checking can reuse the existing `canMoveTo` function.

## Edge Cases

- **Slime knocked into ocean**: Knockback must clamp to walkable tiles. If no valid position exists, minimize knockback distance.
- **Player hits multiple slimes in one swing**: Each slime in the hitbox takes damage independently. All overlapping slimes take 1 HP.
- **Slime chases player off island**: Slime stops at ocean tiles and returns to patrol when player is out of range.
- **Player swings while invincible**: I-frames only prevent incoming damage. Player can still swing and deal damage during i-frames.
- **Save during combat**: Auto-save captures current slime state mid-combat (damaged HP, chase position). This is correct behavior.
- **All slimes killed**: North Island becomes permanently safe. No special behavior needed.
- **Player teleports away during chase**: Slime loses target (distance > 8 tiles) and returns to patrol area.
- **Slime and player spawn overlap on load**: If a saved slime position overlaps the player's load position, slime should deal contact damage normally (player can react).
- **Half-heart damage representation**: Current health is integer (5 hearts = health 5). Half-heart damage requires either changing to health 10 (each unit = half heart) or using Float. Needs design decision during implementation.
