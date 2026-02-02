# Main Menu System - Product Requirements

## Summary

A main menu system for Driftwood Kingdom that presents players with a Play button, followed by a save profile selection screen showing 3 account cards. Each card displays the player's stats (hearts, stamina, magic) and a preview of their last location. Selecting a profile triggers a fade-to-black transition before loading the game.

## Problem Statement

Currently, the game launches directly into gameplay with no menu system. Players need:
- A way to choose between multiple save profiles (for sharing devices with friends)
- Visual feedback about each profile's progress before selecting
- A polished transition into gameplay

## Goals

- Display a main menu with a prominent "Play" button on game launch
- Show 3 save profile cards after pressing Play
- Each card displays: hearts, stamina, magic power, and a location preview image
- Implement smooth fade-to-black transition when selecting a profile
- Load the player at their last saved position after transition

## Non-Goals

- Profile creation/deletion UI (profiles are pre-existing slots)
- Settings menu or options
- Profile naming or customization
- Cloud save synchronization
- New game vs continue distinction (empty profiles just start fresh)

## Target Users

- Primary players of Driftwood Kingdom
- Friends/family sharing a single device (3 profile slots)

## Scope

### Included
- MainMenuView with Play button
- ProfileSelectionView with 3 profile cards
- SaveProfile model to store player state
- Profile card UI showing stats and location preview
- Fade-to-black transition animation
- Loading player at last saved position
- Persistence of save profiles between sessions

### Excluded
- Audio/music integration
- Animated backgrounds
- Profile management (create/delete/rename)
- Tutorial or onboarding flow
