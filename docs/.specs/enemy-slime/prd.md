# Enemy Slime System - Product Requirements

## Summary
Add combat enemies to Driftwood Kingdom by introducing a slime enemy type on North Island. This includes slime AI (patrol and chase), contact-based damage with invincibility frames, knockback mechanics, 4-directional sword combat, death effects, and full save persistence. This is the first enemy type and establishes the foundation for future combat content.

## Problem Statement
The game currently has exploration, fishing, crafting, and sailing — but no combat challenge. The sword exists with an upward swing animation but has nothing to hit. Health is only threatened by drowning. There is no reason to craft better gear or armor. The game feels like a walking simulator rather than an adventure. Enemies create the core gameplay loop: explore, fight, survive, gear up.

## Goals
- Introduce the first enemy type (slime) with believable patrol/chase AI
- Implement a contact damage system with invincibility frames and knockback
- Upgrade the sword to 4-directional swings with active hitboxes during animation
- Add satisfying enemy death effects (pop + particles)
- Persist enemy state (alive/dead, position) across save/load cycles
- Establish an extensible enemy architecture for future enemy types
- Make North Island feel dangerous while Home Island remains safe

## Non-Goals
- Loot drops from enemies (future feature)
- Multiple enemy types (only slime for now)
- Combat XP or leveling system
- Enemy respawning mechanics
- Boss enemies
- Ranged enemy attacks
- Sound effects (separate feature)
- Enemy spawning on Home Island

## Target Users
Players of Driftwood Kingdom who have explored the basics (fishing, crafting, sailing) and need a combat challenge to give purpose to swords, armor, and progression.

## Scope

### Slime Enemy
- Classic green blob, 16x16 or 32x32 pixel sprite
- Bounce-in-place idle animation
- 2 HP (dies in 2 sword hits)
- Deals half a heart of contact damage
- 3 fixed spawn positions on North Island (grass/forest tiles)
- Fixed count, no respawn after death

### AI Behavior
- **Patrol state**: Wander within 5 tiles of spawn point at ~40% walk speed
- **Chase state**: Detect player within 8 tiles, chase at ~60-70% walk speed
- **Return**: If player leaves chase range, return to patrol area

### Combat Mechanics
- **Contact damage**: Player takes half a heart when touching a slime
- **Invincibility frames**: 0.5 seconds after taking damage (player blinks/flashes)
- **Knockback**: Both player and slime are knocked back on contact and sword hit
- **Sword hitbox**: Active only during the swing animation (~360ms window)
- **4-directional sword**: Swing left/right/up/down matching player facing direction

### Death Effects
- Slime pops with a particle burst effect on death
- Slime is removed from the world permanently

### Persistence
- Slime alive/dead state saved per profile
- Slime position saved per profile
- On player death/respawn: slimes stay as-is (no reset)
- On app restart/load: slimes restore to saved state
