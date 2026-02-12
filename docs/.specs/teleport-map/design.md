# Teleport and Map System - Design

## Overview
This feature adds a teleportation fast-travel system with an interactive map UI. The architecture follows the existing MVVM pattern with new tile types, models for waypoints, and SwiftUI views for the minimap and full map overlay.

## Tech Stack
- SwiftUI (existing)
- No new dependencies

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                        GameView                              │
│  ┌──────────┐  ┌──────────────┐  ┌───────────────────────┐  │
│  │ MiniMap  │  │ TeleportPrompt│  │    FullMapView       │  │
│  │  View    │  │    View       │  │  (overlay modal)     │  │
│  └────┬─────┘  └──────┬───────┘  └───────────┬───────────┘  │
│       │               │                       │              │
└───────┼───────────────┼───────────────────────┼──────────────┘
        │               │                       │
        └───────────────┼───────────────────────┘
                        │
                        ▼
              ┌─────────────────┐
              │  GameViewModel  │
              │                 │
              │ - isOnTeleport  │
              │ - isMapOpen     │
              │ - teleportPads  │
              │ - teleportTo()  │
              └────────┬────────┘
                       │
          ┌────────────┴────────────┐
          ▼                         ▼
   ┌─────────────┐          ┌─────────────┐
   │    World    │          │ TeleportPad │
   │             │          │   (model)   │
   │ - tiles[][] │          │ - position  │
   │ - teleport  │          │ - name      │
   │   Pads[]    │          └─────────────┘
   └─────────────┘
```

## Component Design

### New Files

#### Models/TeleportPad.swift
- **Type**: Model
- **Purpose**: Represents a teleport waypoint location
- **Dependencies**: None
```swift
struct TeleportPad: Identifiable, Codable {
    let id: UUID
    let name: String        // "Home Island", "North Island"
    let tileX: Int
    let tileY: Int

    var worldPosition: CGPoint {
        CGPoint(x: CGFloat(tileX) * 24 + 12, y: CGFloat(tileY) * 24 + 12)
    }
}
```

#### Views/Map/GameMiniMapView.swift
- **Type**: View
- **Purpose**: Always-visible minimap in top-left corner during gameplay
- **Dependencies**: World, Player position
- **Key Methods**:
  - Renders 50x50 tile region centered on player
  - Tap gesture to open full map
```swift
struct GameMiniMapView: View {
    let world: World
    let playerPosition: CGPoint
    let onTap: () -> Void
    let size: CGFloat = 100
}
```

#### Views/Map/FullMapView.swift
- **Type**: View
- **Purpose**: Full-screen map overlay with waypoint markers
- **Dependencies**: World, TeleportPad[], Player position, selection mode flag
- **Key Methods**:
  - Shows world overview with islands
  - Displays waypoint markers
  - Handles waypoint selection when in teleport mode
```swift
struct FullMapView: View {
    let world: World
    let playerPosition: CGPoint
    let teleportPads: [TeleportPad]
    let currentPadId: UUID?           // nil if not on a pad
    let isTeleportMode: Bool          // true when opened from teleport prompt
    let onSelectWaypoint: (TeleportPad) -> Void
    let onClose: () -> Void
}
```

#### Views/Map/WaypointMarkerView.swift
- **Type**: View
- **Purpose**: Tappable waypoint marker on the full map
- **Dependencies**: TeleportPad
```swift
struct WaypointMarkerView: View {
    let pad: TeleportPad
    let isCurrentLocation: Bool
    let isSelectable: Bool
    let onTap: () -> Void
}
```

#### Views/TeleportPromptView.swift
- **Type**: View
- **Purpose**: Contextual prompt button when standing on teleport pad
- **Dependencies**: None (follows SailboatPromptView pattern)
```swift
struct TeleportPromptView: View {
    let onTap: () -> Void
}
```

### Modified Files

#### Models/Tile.swift
- **Changes**: Add `teleportPad` case to TileType enum
- **Additions**:
  - `case teleportPad` in TileType
  - Purple color: `Color(red: 0.6, green: 0.3, blue: 0.8)`
  - `isWalkable = true`
  - `isSwimmable = false`

#### Models/World.swift
- **Changes**:
  - Add second island generation
  - Add teleportPads array
  - Place teleport pad tiles at island centers
- **Additions**:
  - `var teleportPads: [TeleportPad]`
  - `static let northIslandOriginY = 445`
  - Update `generateWorld()` to create both islands and teleport pads

#### ViewModels/GameViewModel.swift
- **Changes**: Add teleport-related state and methods
- **Additions**:
  - `@Published var isMapOpen = false`
  - `@Published var isMapTeleportMode = false`
  - `var isOnTeleportPad: Bool` (computed)
  - `var currentTeleportPad: TeleportPad?` (computed)
  - `func openMap(teleportMode: Bool)`
  - `func closeMap()`
  - `func teleportTo(pad: TeleportPad)`

#### Views/GameView.swift
- **Changes**:
  - Add minimap to HUD layer
  - Add teleport prompt to controls layer
  - Add full map overlay
- **Additions**:
  - GameMiniMapView in top-left (conditional on gameplay state)
  - TeleportPromptView in controls area
  - FullMapView overlay when isMapOpen

## Data Flow

### Minimap Tap → Full Map
```
User taps minimap
    → GameMiniMapView.onTap()
    → viewModel.openMap(teleportMode: false)
    → isMapOpen = true, isMapTeleportMode = false
    → GameView shows FullMapView (view-only mode)
```

### Teleport Prompt → Waypoint Selection → Teleport
```
User on teleport pad
    → viewModel.isOnTeleportPad = true
    → GameView shows TeleportPromptView

User taps prompt
    → viewModel.openMap(teleportMode: true)
    → isMapOpen = true, isMapTeleportMode = true
    → FullMapView shows with selectable waypoints

User taps waypoint
    → FullMapView.onSelectWaypoint(pad)
    → viewModel.teleportTo(pad)
    → player.position = pad.worldPosition
    → viewModel.closeMap()
```

## Data Models

### TeleportPad
```swift
struct TeleportPad: Identifiable, Codable {
    let id: UUID
    let name: String
    let tileX: Int
    let tileY: Int

    var worldPosition: CGPoint {
        let tileSize: CGFloat = 24
        return CGPoint(
            x: CGFloat(tileX) * tileSize + tileSize / 2,
            y: CGFloat(tileY) * tileSize + tileSize / 2
        )
    }
}
```

### TileType Extension
```swift
enum TileType {
    case ocean
    case grass
    case beach
    case rock
    case teleportPad  // NEW

    var color: Color {
        switch self {
        // ... existing cases
        case .teleportPad: return Color(red: 0.6, green: 0.3, blue: 0.8)
        }
    }

    var isWalkable: Bool {
        switch self {
        case .grass, .beach, .teleportPad: return true
        case .ocean, .rock: return false
        }
    }
}
```

## State Management

| State | Type | Location | Purpose |
|-------|------|----------|---------|
| isMapOpen | @Published Bool | GameViewModel | Controls full map visibility |
| isMapTeleportMode | @Published Bool | GameViewModel | Determines if waypoints are selectable |
| teleportPads | [TeleportPad] | World | Static list of all waypoints |
| isOnTeleportPad | Computed Bool | GameViewModel | Checks player standing on pad |

## Performance Considerations

### Minimap Rendering
- Reuse existing MiniMapView pattern (50x50 tile viewport)
- Only re-render when player position changes tiles
- Use simple colored rectangles for tiles (no images)

### Full Map
- Render at lower resolution (1 pixel per tile or similar)
- Only show when explicitly opened (not always in memory)
- Waypoint markers are lightweight SF Symbols

## Accessibility
- Waypoint markers sized at 44x44pt minimum for tap targets
- High contrast purple for teleport pads
- Labels on waypoints for VoiceOver

## Testing Strategy

### Manual Testing
1. Walk to teleport pad → verify prompt appears
2. Tap prompt → verify map opens with waypoints
3. Tap waypoint → verify instant teleport to destination
4. Tap minimap → verify map opens in view-only mode
5. Test on both islands

### Verification Points
- [ ] Second island generates correctly at Y=445-454
- [ ] Teleport pads render purple at both island centers
- [ ] Minimap visible during gameplay, hidden during overlays
- [ ] Full map shows both islands and waypoints
- [ ] Teleportation moves player to exact pad center
- [ ] Cannot teleport to current location
