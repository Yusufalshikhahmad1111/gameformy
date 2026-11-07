# 05 — Combat and Formations

## Combat philosophy
The player wins because they made a better command decision, not because they spam-clicked NPCs.

## Unit triangle
Spearmen:
- strong front;
- resist cavalry;
- weak pursuit.

Archers:
- high ranged pressure;
- vulnerable when surrounded;
- strong behind a frontline.

Cavalry:
- fast;
- excellent flanking;
- strong against exposed archers;
- weak into prepared spears.

## Formation behavior
### Line
Balanced front, best default.

### Wedge
Concentrated breakthrough, vulnerable to surround.

### Column
Fast movement through narrow paths, poor combat frontage.

### Spread
Reduces ranged splash and makes flanking harder, but lowers focus fire.

## Terrain modifiers
Use small modifiers, not huge multipliers.
Example:
- forest: cavalry speed -10%, archer visibility -5%;
- high ground: ranged range +8%;
- road: movement +10%;
- bridge: frontage restricted.

## Battle readability
Every formation must communicate:
- team;
- health;
- selected state;
- destination;
- current order.

Avoid health bars over every soldier. Prefer one formation bar plus optional local damage indicators.

## NPC architecture
Do not simulate 100 fully independent expensive NPC brains.
Use:
- formation controller;
- squad leader logic;
- pooled visual soldiers;
- distance-based update rates.

The player sees an army; the server simulates a manageable abstraction.

## Feel
Commands should have:
- click/target confirmation;
- movement response;
- formation transition;
- sound;
- subtle dust/weapon feedback.

VFX must explain action, not decorate it.