# Teleport and Map System - Product Requirements

## Summary
Add a teleportation system with visual waypoints and an interactive map. Players can fast-travel between islands using teleport pads. A minimap is always visible during gameplay and expands to a full map view when clicked. Standing on a teleport pad opens the map with selectable waypoint destinations.

## Problem Statement
The game world is 1000x1000 tiles with currently only one island. As additional islands are added, players need:
1. A way to quickly navigate between discovered locations
2. Visual awareness of their position in the world
3. An intuitive interface for selecting teleport destinations

Without these features, exploring the expanded world would be tedious and players would lose spatial awareness.

## Goals
- Add a second island 50 tiles north of the current island (center at Y=450)
- Place teleport pads (purple tiles) on both islands
- Display a persistent minimap in the top-left corner during gameplay
- Allow clicking the minimap to expand to a full-screen map view
- When standing on a teleport pad, show a prompt that opens the map with waypoint selection
- Instant teleportation when clicking a waypoint on the map

## Non-Goals
- Waypoint unlocking/discovery system (deferred to later)
- Animated teleport effects or transitions
- Multiple teleport pads per island
- Map fog-of-war or exploration tracking
- Custom waypoint naming

## Target Users
Players exploring the game world who want to quickly travel between discovered islands and maintain spatial awareness of their position.

## Scope

### Included
1. **World Generation**
   - Second 10x10 grass island at (495, 445) to (504, 454)
   - Beach on left side like current island
   - Teleport pad tile type (purple color)
   - One teleport pad per island

2. **Minimap**
   - Always visible in top-left corner during gameplay
   - Shows player position as centered icon
   - Clickable to expand to full map

3. **Full Map View**
   - Overlay that shows when minimap clicked or teleport prompt used
   - Shows all islands and teleport waypoint locations
   - Player position indicator
   - Clickable waypoints for teleportation (when accessed from teleport pad)
   - Close button or tap-outside-to-dismiss

4. **Teleport Interaction**
   - Contextual prompt when standing on teleport pad
   - Opens map in "waypoint selection" mode
   - Clicking a waypoint instantly teleports player to that pad
   - All waypoints visible/selectable (no unlock system yet)

### Excluded
- Teleport cooldowns
- Teleport costs (resources/currency)
- Animation effects
- Sound effects
- Waypoint discovery mechanics
