# Enemy Slime System - Design

## Overview

Add an enemy system to Driftwood Kingdom starting with slimes on North Island. The design follows existing MVVM patterns: a `Slime` model for data, logic added to `GameViewModel` for AI/combat updates within the existing 60 FPS game loop, a `SlimeView` for rendering, and `SaveProfile` extended for persistence. Health is doubled from 5 to 10 internally (each unit = half heart) to support half-heart damage without changing the visual heart display.

## Tech Stack
- SwiftUI (existing)
- No new dependencies

## Architecture Diagram

```
GameViewModel (owns slime state, runs AI + combat each frame)
    ├── [Slime] array (model data)
    ├── Player (existing, + i-frame fields)
    └── World (existing, provides collision)

GameView
    ├── SlimeView (renders each alive slime)
    ├── PlayerView (existing, + i-frame blink opacity)
    └── SlimeDeathEffectView (particle burst on kill)

SaveProfile
    └── slimes: [SlimeSaveData]? (optional for migration)
```

## Component Design

### New Files

#### `driftwood/Models/Slime.swift`
- **Type**: Model
- **Purpose**: Data model for a slime enemy entity
- **Dependencies**: Foundation
- **Key Properties**:
  - `id: Int` — stable identifier (0, 1, 2) for save persistence
  - `position: CGPoint` — world position in pixels
  - `spawnOrigin: CGPoint` — original spawn position (pixels)
  - `health: Int` — current HP (max 2)
  - `isAlive: Bool` — dead slimes are hidden and non-interactive
  - `aiState: SlimeAIState` — enum: `.patrol(target: CGPoint)`, `.chase`, `.returning`
  - `patrolPauseTimer: CGFloat` — countdown before picking next patrol target
  - `hitCooldown: Set<Int>` — tracks which attack swing already hit this slime (prevents multi-hit per swing, cleared when player stops attacking)
  - `hitFlashTimer: CGFloat` — countdown for damage flash visual (0 = not flashing)
- **Key Constants**:
  - `static let size: CGFloat = 24` — sprite size (1 tile, matches tileSize)
  - `static let halfSize: CGFloat = 12` — hitbox half-extent
  - `static let maxHealth: Int = 2`
  - `static let patrolSpeed: CGFloat = 40` — ~40% of player walk (100)
  - `static let chaseSpeed: CGFloat = 65` — ~65% of player walk
  - `static let patrolRadius: CGFloat = 120` — 5 tiles * 24px
  - `static let chaseRadius: CGFloat = 192` — 8 tiles * 24px
  - `static let knockbackDistance: CGFloat = 40` — pixels pushed on hit
  - `static let contactDamage: Int = 1` — 1 unit = half heart (in new 10-based health)
  - `static let hitFlashDuration: CGFloat = 0.15` — seconds of white flash after hit

#### `driftwood/Models/SlimeSaveData.swift`
- **Type**: Model
- **Purpose**: Codable subset of Slime for save persistence
- **Key Properties**:
  - `id: Int`
  - `position: CodablePoint`
  - `health: Int`
  - `isAlive: Bool`

#### `driftwood/Views/SlimeView.swift`
- **Type**: View
- **Purpose**: Renders a single slime sprite with bounce animation and hit flash
- **Dependencies**: SwiftUI
- **Key Properties**:
  - `position: CGPoint` — screen-space position
  - `bouncePhase: CGFloat` — time-based bounce cycle
  - `isFlashing: Bool` — white overlay during hit flash

#### `driftwood/Views/SlimeDeathEffectView.swift`
- **Type**: View
- **Purpose**: Particle burst effect when a slime dies
- **Dependencies**: SwiftUI
- **Key Behavior**:
  - Shows 4-6 small green circles scattering outward
  - Scales up briefly then fades over ~0.4 seconds
  - Self-removes after animation completes

### Modified Files

#### `driftwood/Models/Player.swift`
- **Changes**:
  - Add `invincibilityTimer: CGFloat = 0` — countdown for i-frames (0.5s)
  - Add `isInvincible: Bool` computed property (`invincibilityTimer > 0`)
  - Change `health` default from `5` to `10`, `maxHealth` from `5` to `10`
  - Add `static let invincibilityDuration: CGFloat = 0.5`
  - Add `attackSwingId: Int = 0` — increments each new swing, used by slime hit tracking
- **Reason**: Support i-frames and half-heart damage (1 unit = half heart)

#### `driftwood/Models/SaveProfile.swift`
- **Changes**:
  - Add `slimes: [SlimeSaveData]?` optional field (nil = use defaults, for migration)
  - Update `empty(id:)` to set `health: 10`, `slimes: nil`
  - Update `init(from player:...)` to accept slimes parameter
  - Add health migration in SaveManager (old `health: 5` → `health: 10`)
- **Reason**: Persist slime state per profile; backwards compatibility via optional

#### `driftwood/ViewModels/GameViewModel.swift`
- **Changes**:
  - Add `@Published var slimes: [Slime]` — array of slime entities
  - Add `@Published var deathEffects: [SlimeDeathEffect]` — active death animations
  - Add `var attackSwingId: Int = 0` tracking on player
  - In `init(profile:)`: load slimes from SaveProfile or generate defaults
  - In `updatePlayerPosition()`: call `updateSlimes(deltaTime:)` and `checkCombat()`
  - New `updateSlimes(deltaTime:)` — runs AI state machine for each alive slime
  - New `checkCombat()` — checks contact damage (slime→player) and sword hits (player→slime)
  - New `applyKnockback(to:direction:)` — push entity with collision clamping
  - New `swordHitbox() -> CGRect` — returns active sword hitbox based on facing direction
  - New `slimeCanMoveTo(_:)` — reuses tile/rock collision logic for slime bounds
  - In `startSwordSwing()`: increment `attackSwingId`, clear slime hitCooldown sets
  - In `createSaveProfile()`: include slime save data
  - In `updateAttackAnimation()`: update invincibility timer
  - In `respawn()`: set health to `effectiveMaxHealth` (already does this)
- **Reason**: Core game logic for enemy AI, combat, and persistence

#### `driftwood/Views/GameView.swift`
- **Changes**:
  - Add slime rendering layer between rock overlays and player (with depth sorting)
  - Add death effect overlay layer
  - Add i-frame blink opacity modifier to PlayerView (`.opacity(blinkOpacity)`)
  - Depth sort: slimes with `bottomY < playerBottomY` render before player, others after
- **Reason**: Visual rendering of enemies in the game world

#### `driftwood/Views/PlayerView.swift`
- **Changes**:
  - No structural changes needed — opacity handled by parent GameView
- **Reason**: I-frame blink is applied as a modifier in GameView, not inside PlayerView

#### `driftwood/Models/World.swift`
- **Changes**:
  - Add `static func defaultSlimeSpawns() -> [Slime]` — returns 3 slimes at fixed North Island positions
- **Reason**: Deterministic spawn positions for new games

#### `driftwood/Services/SaveManager.swift`
- **Changes**:
  - Add health migration function: profiles with `health <= 5` get doubled (e.g., 5 → 10, 3 → 6)
  - Call migration in `loadProfiles()`
- **Reason**: Backwards compatibility for the 5→10 health scale change

#### `driftwood/Views/GameView.swift` (HeartsView)
- **Changes**:
  - Update HeartsView to render hearts from 10-based health: each heart = 2 HP, support half-heart display
  - Full heart: `health >= (index + 1) * 2`, half heart: `health >= index * 2 + 1`, empty: else
  - Use `heart.fill` (full), `heart.leadinghalf.fill` (half), `heart` (empty) SF Symbols
- **Reason**: Visual display of half-heart damage

#### `driftwood/Models/Player.swift` (FacingDirection)
- **Changes**:
  - Implement `attackSpriteName(frame:)` for `.down`, `.left`, `.right`
  - For down: flip the up sprites vertically, or use a placeholder approach
  - For left/right: flip horizontally
  - Strategy: Use the existing SwordSwingUp sprites and apply programmatic transforms in PlayerView
- **Reason**: Enable 4-directional sword swings

#### `driftwood/Views/PlayerView.swift`
- **Changes**:
  - Apply `.scaleEffect` transforms for sword directions:
    - Up: no transform (use existing sprites as-is)
    - Down: `scaleEffect(y: -1)` to flip vertically
    - Left: `scaleEffect(x: -1)` to mirror horizontally
    - Right: no transform (use up sprites, mirror of left)
  - Alternatively, use rotation: left = -90°, right = 90°, down = 180°
  - Decision: Use `scaleEffect` mirroring since rotation would rotate the character body oddly
- **Reason**: 4-directional attack visuals from single sprite set

## Data Flow

```
Every frame (60 FPS):
  GameViewModel.updatePlayerPosition()
    ├── updateAttackAnimation(deltaTime)     // existing + decrement invincibility timer
    ├── updateSlimes(deltaTime)              // AI: patrol / chase / return
    ├── checkSlimeContactDamage()            // slime touches player → damage + knockback + i-frames
    ├── checkSwordHits()                     // sword hitbox overlaps slime → damage + knockback
    └── updateDeathEffects(deltaTime)        // animate and clean up particle effects

Save flow:
  GameViewModel.createSaveProfile()
    └── Maps each Slime → SlimeSaveData
    └── Stored in SaveProfile.slimes

Load flow:
  GameViewModel.init(profile:)
    ├── if profile.slimes != nil → restore from save
    └── else → World.defaultSlimeSpawns() (migration path)
```

## Data Models

### Slime
```swift
enum SlimeAIState {
    case patrol(target: CGPoint)
    case chase
    case returning
}

struct Slime: Identifiable {
    let id: Int // 0, 1, 2 — stable for save matching
    var position: CGPoint
    let spawnOrigin: CGPoint
    var health: Int = 2
    var isAlive: Bool = true
    var aiState: SlimeAIState = .patrol(target: .zero)
    var patrolPauseTimer: CGFloat = 0
    var hitCooldown: Int = -1 // attackSwingId that last hit this slime
    var hitFlashTimer: CGFloat = 0

    static let size: CGFloat = 24
    static let halfSize: CGFloat = 12
    static let maxHealth: Int = 2
    static let patrolSpeed: CGFloat = 40
    static let chaseSpeed: CGFloat = 65
    static let patrolRadius: CGFloat = 120
    static let chaseRadius: CGFloat = 192
    static let knockbackDistance: CGFloat = 40
    static let contactDamage: Int = 1
    static let hitFlashDuration: CGFloat = 0.15

    var collisionRect: CGRect {
        CGRect(
            x: position.x - Slime.halfSize,
            y: position.y - Slime.halfSize,
            width: Slime.size,
            height: Slime.size
        )
    }
}
```

### SlimeSaveData
```swift
struct SlimeSaveData: Codable {
    let id: Int
    let position: CodablePoint
    let health: Int
    let isAlive: Bool
}
```

### SlimeDeathEffect
```swift
struct SlimeDeathEffect: Identifiable {
    let id = UUID()
    let position: CGPoint
    var elapsed: CGFloat = 0
    static let duration: CGFloat = 0.4
}
```

## State Management

- `@Published var slimes: [Slime]` on GameViewModel — source of truth for slime state
- `@Published var deathEffects: [SlimeDeathEffect]` on GameViewModel — active death animations
- `player.invincibilityTimer` on Player struct — decremented each frame, checked before applying damage
- `player.attackSwingId` on Player struct — incremented per swing, compared against `slime.hitCooldown` to prevent multi-hit

## Sword Hitbox Calculation

```swift
func swordHitbox() -> CGRect? {
    guard player.isAttacking else { return nil }
    let reach: CGFloat = 20 // pixels in front of player center
    let hitboxSize: CGFloat = 28 // slightly wider than 1 tile
    let halfHitbox = hitboxSize / 2

    let centerX: CGFloat
    let centerY: CGFloat

    switch player.facingDirection {
    case .up:
        centerX = player.position.x
        centerY = player.position.y - reach
    case .down:
        centerX = player.position.x
        centerY = player.position.y + reach
    case .left:
        centerX = player.position.x - reach
        centerY = player.position.y
    case .right:
        centerX = player.position.x + reach
        centerY = player.position.y
    }

    return CGRect(
        x: centerX - halfHitbox,
        y: centerY - halfHitbox,
        width: hitboxSize,
        height: hitboxSize
    )
}
```

## AI State Machine

```
┌─────────┐  player within 8 tiles  ┌─────────┐
│ PATROL  │ ──────────────────────→  │  CHASE  │
│(wander) │                          │(pursue) │
└────┬────┘  ←──────────────────────  └────┬────┘
     │        player beyond 8 tiles        │
     │                                     │
     │         ┌───────────┐               │
     └────────→│ RETURNING │←──────────────┘
               │(go home)  │  (also triggered when player leaves range)
               └─────┬─────┘
                     │ near spawn origin
                     ↓
               ┌─────────┐
               │ PATROL   │
               └──────────┘
```

**Patrol**: Pick random walkable point within `patrolRadius` of `spawnOrigin`. Move toward it at `patrolSpeed`. On arrival, pause 1-2 seconds, pick new target.

**Chase**: Move directly toward `player.position` at `chaseSpeed`. Check distance each frame — if > `chaseRadius`, transition to returning.

**Returning**: Move toward `spawnOrigin` at `patrolSpeed`. When within 1 tile, transition to patrol.

## Knockback Implementation

```swift
func applyKnockback(position: inout CGPoint, direction: CGPoint, distance: CGFloat, halfSize: CGFloat) {
    let length = hypot(direction.x, direction.y)
    guard length > 0 else { return }
    let normalized = CGPoint(x: direction.x / length, y: direction.y / length)

    // apply in small steps to respect collision
    let steps = 4
    let stepDist = distance / CGFloat(steps)
    for _ in 0..<steps {
        let newPos = CGPoint(
            x: position.x + normalized.x * stepDist,
            y: position.y + normalized.y * stepDist
        )
        if canEntityMoveTo(newPos, halfSize: halfSize) {
            position = newPos
        } else {
            break // stop at collision
        }
    }
}
```

## Health System Migration

**Before**: `health: Int = 5`, `maxHealth: Int = 5` (1 unit = 1 full heart)
**After**: `health: Int = 10`, `maxHealth: Int = 10` (1 unit = half heart, 2 units = 1 full heart)

**Migration**: In `SaveManager.loadProfiles()`, check if health ≤ 5 and double it. Set new maxHealth baseline. This is a one-time migration that runs on old saves.

**HeartsView update**:
```swift
ForEach(0..<(maxHealth / 2), id: \.self) { index in
    let heartHealth = health - index * 2
    Image(systemName: heartHealth >= 2 ? "heart.fill" :
                      heartHealth == 1 ? "heart.lefthalf.fill" : "heart")
}
```

## Depth Sorting Strategy

Slimes are depth-sorted relative to the player using bottom-edge Y comparison (same as tree overlays):

```
1. Ground tiles
2. Ground sprites (tree trunks)
3. Rock overlays
4. Non-overlapping tree overlays
5. Slimes BEHIND player (slime bottomY < player bottomY)
6. Player
7. Slimes IN FRONT of player (slime bottomY >= player bottomY)
8. Overlapping tree overlays
9. HUD / UI layers
```

This ensures slimes walking below the player appear in front, creating correct visual depth.

## Performance Considerations

- Only 3 slimes — negligible CPU cost for AI updates
- Collision checks per slime: 1 distance check (chase detection) + 1 rect overlap (contact) + 1 rect overlap (sword) = ~9 checks per frame total
- Particle effects: 4-6 simple SwiftUI views with opacity animation, self-removed after 0.4s
- No pathfinding algorithm needed — direct movement toward target with tile collision checks
- Slimes outside camera view still update AI (they're on a different island most of the time, so this is fine for 3 entities)

## Edge Case Handling

| Case | Resolution |
|------|-----------|
| Knockback into ocean | `applyKnockback` steps check `canEntityMoveTo` — stops at last valid position |
| Multi-slime sword hit | Each slime's `hitCooldown` is independent — all overlapping slimes take damage |
| Slime chases off island | `slimeCanMoveTo` prevents stepping on ocean tiles; slime stops at beach edge |
| Player teleports during chase | Distance > 192px instantly → slime transitions to returning |
| All slimes killed | North Island safe permanently, no special handling |
| Old save without slimes | `slimes: [SlimeSaveData]?` is nil → generate defaults |
| Save during combat | Slime position/health captured as-is by auto-save |
