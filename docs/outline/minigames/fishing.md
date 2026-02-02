# Fishing

Fishing has levels, starting at level 1, and maximum of level 10, as you level up the loot table becomes bigger.

## Minigame Mechanics

1. A bar appears with a randomly placed green section
2. An indicator moves across the bar
3. When the indicator enters the green section, click to catch
4. On success, another bar appears with a new random green section
5. Repeat until all catches are complete

### Perfect Catch

The green zone has a smaller "perfect" sub-zone in the center. Clicking in the perfect zone triggers a perfect catch.

### Combo Meter

Consecutive perfect catches build a combo. Each combo level adds +1 fishing fortune for that session. Combo resets on any miss.

## Water Types

Different water types have different loot tables:

| Water Type | Location | Loot Table |
|------------|----------|------------|
| Ocean | Surrounding waters | Standard (documented below) |
| River | Island interior | TBD |
| Pond | Forest clearings | TBD |

## Fish Shadows

Fish shadows appear in the water before casting. Shadow size/shape hints at potential catch rarity:
- Small shadow = common fish
- Medium shadow = uncommon items
- Large shadow = rare catches
- Glowing shadow = very rare

### Fishing Fortune

Fishing Fortune determines how many catches (loot rolls) you get per session.

**Formula**: `catches = floor(fortune / 10) + 1`

| Fortune | Catches |
|---------|---------|
| 0-9 | 1 |
| 10-19 | 2 |
| 20-29 | 3 |
| 56 | 6 |
| 100 | 11 |

Fortune is increased by armor (Old Set, Mossy Set), fishing rod upgrades, and Bracelet accessory.

### Fishing Rod Fortune by Tier

| Tier | Fortune |
|------|---------|
| 1 | +0 |
| 2 | +20 |
| 3 | +50 |
| 4 | +90 |

## Loot Table

### LVL 1

| Item | Chance |
|------|--------|
| Fish | 80% |
| Driftwood | 20% |

### LVL 2 (levels up after 10 catches total)

| Item | Chance |
|------|--------|
| Fish | 70% |
| Driftwood | 20% |
| Seaweed | 10% |

### LVL 3 (levels up after 25 catches total)

| Item | Chance |
|------|--------|
| Fish | 60% |
| Old Set (reference later) | 16% |
| Seaweed | 14% |
| Driftwood | 10% |

### LVL 4 (levels up after 50 catches total)

| Item | Chance |
|------|--------|
| Fish | 50% |
| Old Set (reference later) | 16% |
| Seaweed | 14% |
| Driftwood | 10% |
| Rusty Coin | 5% |
| Shark Tooth | 5% |

### LVL 5 (levels up after 100 catches total)

| Item | Chance |
|------|--------|
| Fish | 50% |
| Seaweed | 14% |
| Driftwood | 10% |
| Old Set (reference later) | 8% |
| Rusty Coin | 5% |
| Shark Tooth | 5% |
| Scale | 4% |
| Broken Wheel | 4% |

### LVL 6 (levels up after 250 catches total)

| Item | Chance |
|------|--------|
| Fish | 50% |
| Metal Scraps | 10% |
| Old Set (reference later) | 8% |
| Seaweed | 8% |
| Rusty Coin | 8% |
| Shark Tooth | 8% |
| Broken Wheel | 8% |

### LVL 7 (levels up after 500 catches total)

| Item | Chance |
|------|--------|
| Fish | 50% |
| Old Set (reference later) | 8% |
| Seaweed | 8% |
| Rusty Coin | 8% |
| Shark Tooth | 8% |
| Wire | 4% |
| Plastic | 4% |
| Sailor's Journal | 4% |
| Metal Scraps | 4% |
| Rainbow Fish | 2% |

### LVL 8 (levels up after 1000 catches total)

| Item | Chance |
|------|--------|
| Fish | 49.99% |
| Mossy Set (reference later) | 8% |
| Seaweed | 8% |
| Rusty Coin | 8% |
| Shark Tooth | 8% |
| Old Set (reference later) | 4% |
| Wire | 4% |
| Platinum Scraps | 4% |
| Rainbow Fish | 2% |
| Plastic | 2% |
| Sailor's Journal | 2% |
| Message in a Bottle | 0.01% |

### LVL 9 (levels up after 2500 catches total)

| Item | Chance |
|------|--------|
| Fish | 49.95% |
| Mossy Set (reference later) | 8% |
| Seaweed | 8% |
| Rusty Coin | 8% |
| Shark Tooth | 8% |
| Old Set (reference later) | 4% |
| Treasure Chest (reference later) | 4% |
| Wire | 4% |
| Rainbow Fish | 2% |
| Platinum Scraps | 2% |
| Plastic | 1% |
| Sailor's Journal | 1% |
| Message in a Bottle | 0.05% |

### LVL 10 (levels up after 5000 catches total)

| Item | Chance |
|------|--------|
| Fish | 45% |
| Seaweed | 8% |
| Rusty Coin | 8% |
| Shark Tooth | 8% |
| Message in a Bottle | 5% |
| Old Set (reference later) | 4% |
| Mossy Set (reference later) | 4% |
| Treasure Chest (reference later) | 4% |
| Wire | 4% |
| The Old One | 2% |
| Rainbow Fish | 2% |
| Platinum Scraps | 2% |
| Time Locket | 2% |
| Moon Fragment | 1% |
| Sun Fragment | 1% |
| Plastic | 1% |
| Sailor's Journal | 1% |

## Special Loot Sets

### x% Old Set

| Item | Chance | Notes |
|------|--------|-------|
| Old Shoes | X/4% | Only can be collected once |
| Old Trousers | X/4% | Only can be collected once |
| Old Tunic | X/4% | Only can be collected once |
| Old Hat | X/4% | Only can be collected once |
| Leather Scrap | +X/4% | For every old piece collected |

### x% Mossy Set

| Item | Chance | Notes |
|------|--------|-------|
| Mossy Hat | X/4% | Only can be collected once |
| Mossy Shirt | X/4% | Only can be collected once |
| Mossy Shorts | X/4% | Only can be collected once |
| Mossy Boots | X/4% | Only can be collected once |
| Leather Scrap | +X/4% | For every old piece collected |

### Treasure Chest

| Roll | Reward | Chance |
|------|--------|--------|
| 1 | 5 coins | 100% |
| 2 | Another 2 coins | 80% |
| 3 | Another 3 coins | 60% |
| 4 | Another 2 coins | 40% |
| 5 | Another 3 coins | 20% |
| 6 | Another 5 coins | 10% |
| 7 | Another 10 coins | 2% |
