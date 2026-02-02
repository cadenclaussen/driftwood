# Player Movement System - Product Requirements

## Summary
Add a player character to the Driftwood Kingdom game that can move freely around the island using a virtual joystick. The player is rendered as a red circle at half-tile size, and the game is locked to landscape orientation on iPhone.

## Problem Statement
The game currently displays a static island world with no player interaction. Players need a character they can control to explore the world, which is the fundamental requirement for any adventure game.

## Goals
- Add a visible player character (red circle, 1/2 tile size)
- Implement smooth, free-form movement via virtual joystick (not grid-locked)
- Lock the app to landscape orientation for optimal gameplay view
- Player renders above the world grid

## Non-Goals
- Collision detection with terrain (future feature)
- Player animations or sprites (starting with simple circle)
- Sound effects for movement
- Multiple player characters

## Target Users
Single players on iPhone devices who want to explore the island world.

## Scope
- Player model with position tracking (CGPoint for free movement)
- Player view rendered as red circle at 12x12 points (half of 24pt tile)
- Virtual joystick overlay in bottom-left corner
- Joystick controls player velocity/direction
- Landscape orientation lock in Info.plist or app configuration
- Player spawns at center of island
