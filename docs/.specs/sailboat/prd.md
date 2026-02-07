# Sailboat - Product Requirements

## Summary

Implement a sailboat system for Driftwood Kingdom that allows players to craft and use a sailboat to navigate the 1000x1000 ocean surrounding the island. The sailboat provides faster water travel than swimming, uses the existing joystick for movement, and includes wind mechanics that affect navigation.

## Problem Statement

Players currently have limited options for ocean exploration:
- Swimming is slow and consumes stamina
- The 1000x1000 ocean is vast and inaccessible without efficient travel
- No way to explore distant areas or future ocean content (shipwrecks, other islands)

The sailboat provides:
- Fast, stamina-free ocean travel
- A crafting goal that uses fishing resources (Sail, Wheel, Metal Scraps, Wood)
- Foundation for future ocean content and upgrades (Sails tiers, Motor)

## Goals

- Allow players to craft a sailboat using existing resources
- Enable sailing via the same joystick used for walking
- Implement wind mechanics with HUD indicator and gentle boat push
- Provide boarding/disembarking via contextual prompts
- Allow summoning the sailboat from inventory when near water
- Persist sailboat position in the world when not in use

## Non-Goals

- Fishing from the sailboat (future enhancement)
- Multiple boats or boat customization
- Other islands or ocean destinations (future content)
- Motor upgrade implementation (future feature)
- Sail tier upgrades affecting speed (future feature)
- Combat or enemy encounters while sailing
- Boat damage or durability

## Target Users

All players who have progressed far enough to gather crafting materials:
- Seaweed -> Plant Fiber -> String -> Cotton -> Sail
- Broken Wheel -> Wheel
- Metal Scraps (20) and Wood (10)

## Scope

### Included

1. **Sailboat Crafting**: Recipe using 1 Sail + 1 Wheel + 20 Metal Scraps + 10 Wood
2. **Sailboat Item**: Inventory item that can be summoned when near water
3. **Sailing Movement**: Joystick control at 4x swim speed
4. **Wind System**: HUD arrow showing wind direction, gentle push on boat, direction drifts over time
5. **Boarding**: Contextual prompt when player is near sailboat in water
6. **Disembarking**: Contextual prompt when sailing near land
7. **Summoning**: From inventory when player is 1 tile from water and facing it
8. **Persistence**: Sailboat remains where left in the world
9. **Collision**: Boat stops when hitting land

### UI Components

- Wind direction arrow on HUD
- "Board Sailboat" prompt (contextual)
- "Disembark" prompt (contextual)
- Sailboat inventory item with icon

### Visual

- Placeholder: Black rectangle larger than character sprite
- Later: Proper sailboat sprite (asset provided for inventory icon)
