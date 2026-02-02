# Player

## Health

- 5 hearts (gains more over the course of the game)
- Damage taken varies by enemy type

### Healing

- Sleeping
- Completing dungeons
- Eating food/meals

## Movement

### On Land

- **Walk**: Base movement speed
- **Sprint**: Toggle, 2x walk speed, no stamina cost
- **Climbing**: Automatic when moving into climbable surface (cliffs, trees), consumes stamina
- **Footsteps**: Sound changes based on terrain (grass, sand, wood, stone)

### Swimming

- Consumes stamina
- When stamina depleted: lose 1 heart, teleport back to swim start point
- Stamina regeneration: full bar refills in 5 seconds (constant rate)

### Navigation

- **Map markers**: Discovered fishing spots marked on map
- **Fast travel**: Visiting a location unlocks it for fast travel

## Combat

### Sword Attacks

- **Basic attack**: Standard swing
- **Charged attack**: Hold for 0.8 seconds for 2x damage
- Attacks cause knockback on enemies

### Defense

- **Parry/Block**: 0.5 second timing window, successful parry stuns enemy for 1 second
- **Dodge roll**: Brief invincibility frames, 0.5 second cooldown between rolls

### Enemy Weak Points

Enemies have weak points that deal bonus damage when hit.

## Magic Bar

- Starts with 50 MP (increases over the course of the game)
- Regenerates at 1 MP every 0.1 seconds by default
- Regeneration rate can be improved with armor, wands, and accessories
- **Passive regen buff**: After 2 seconds of not casting, MP regen is doubled

### Spell Quick-Select

Hold button to open spell wheel, drag to select spell for quick casting.

### Spells

| Spell | MP Cost | Effect |
|-------|---------|--------|
| Fireball | 50 MP | Ranged AoE attack |
| Dash | 20 MP | Dash in facing direction (longer range than dodge roll) |
| Tornado | 100 MP | Pulls enemies from large area into small area (combos with Fireball) |

## Money

- Currency of coins

## Inventory

The inventory contains 3 pages.

### Inventory Features

- **Sorting**: Sort items by type, rarity, or recent
- **Favorites**: Mark slots for quick access
- **Junk tag**: Mark items for quick-sell at shops (player confirms sale). A merchant can convert junk back to normal items for money (used for crafting)

## Crafting

TBD - includes Wheels and other items crafted from resources.
- **Recipe book**: Tracks discovered cooking combinations (discovered by experimentation)
- **Storage chest**: 30 slots at home base, not upgradeable

### Page 1: Items

Contains Gear and Tools.

#### Gear (Major Upgrades)

| Gear | Tiers | Details |
|------|-------|---------|
| Sails | 4 | Improves sailing speed |
| Motor | 1 | Requires oil to operate, permanently attaches to sailboat |
| Pouch | 3 | Increases inventory size |

#### Tools

| Tool | Tiers | Effect per Tier | Details |
|------|-------|-----------------|---------|
| Fishing Rod | 4 | +Fortune (0/20/50/90) | See [fishing.md](minigames/fishing.md) |
| Sword | 3 | +Damage | Combat |
| Axe | 3 | +Chopping speed | Resource gathering |
| Wand | 1 | Enables spell casting | Obtained later |

### Page 2: Collectibles

- 30 slots total (5x6 grid)
- Top row (5 slots): Meals only, max 5 meals carried
- Bottom 25 slots: Resources, stackable up to 99 per slot
- Food ingredients are NOT stackable (each takes 1 slot)
- Non-food resources ARE stackable (wood, metal scraps, etc.)
- Meals can be eaten at full health

#### Cooking

Combining foods creates meals that heal hearts. Some ingredients grant temporary hearts:

| Ingredient | Temp Heart Chance |
|------------|-------------------|
| Rainbow Fish | 50% = +1 temp heart, 20% = +2 temp hearts |

### Page 3: Character

Equipment and major progression items.

#### Armor (4 slots: Hat, Shirt, Pants, Boots)

Individual piece stats only, no set bonuses.

| Set | Source | Stats |
|-----|--------|-------|
| Old Set | Fishing | +2 hearts (0.5 each), +20 fishing fortune (5 each). Starter set. |
| Mossy Set | Fishing | +4 hearts (1 each), +80 fishing fortune (20 each). Endgame fishing. |
| Magic Set | TBD | +MP regen, +max MP, +magic damage. No bonus health/defense. |
| Melee Set | TBD | +health, +defense, +melee damage. |
| Movement Set | TBD | +stamina, +movement speed. |

#### Accessories (4 slots)

Each accessory has 5 upgrade tiers. Buffs increase with each tier.

| Accessory | Stats |
|-----------|-------|
| Anklet | +movement speed, +health (slight) |
| Ring | +max MP, +MP regen |
| Chain | +health, +defense |
| Bracelet | +fishing fortune |

#### Major Upgrades

| Upgrade | Effect |
|---------|--------|
| Sailboat | Water travel (uses sails, upgradeable speed) |
| Motorboat | Permanent upgrade to sailboat (requires oil) |
| Flippers | Heavily reduces swimming stamina cost |
| Wings | Ride wind currents, access sky islands (Part 2) |
| Pegasus Boots | Jump over gaps in sky islands (Part 2) |
