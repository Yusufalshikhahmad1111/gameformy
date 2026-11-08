# Stage 13 — Combat, Ranged Warfare & Castle Assault
## Objective

Create a battlefield where armies fight automatically and the player wins through command quality.

## Combat pipeline

1. acquire target;
2. evaluate threat;
3. approach;
4. enter combat;
5. resolve attacks;
6. apply morale/fatigue;
7. resolve casualties;
8. check retreat;
9. re-form;
10. resume order.

## Ranged combat

Archers:
- acquire target within range;
- prefer exposed or high-value targets;
- fire with readable cadence;
- use projectile/trace feedback;
- lose effectiveness while moving or heavily fatigued.

## Melee combat

Spearmen:
- stabilize frontline;
- resist cavalry;
- defend gates.

Cavalry:
- close distance quickly;
- prefer flanks;
- pressure archers;
- avoid prolonged spear contact.

## Formation effects

Line:
balanced and stable.

Wedge:
stronger first-contact pressure; smaller effective frontage.

Column:
better travel / lower ranged exposure; weaker frontline.

Spread:
lower ranged-area vulnerability; weaker cohesion.

Terrain modifies:
- movement speed;
- detection;
- ranged effectiveness;
- cavalry mobility.

## Castle warfare

Castle states:
- Safe
- Contested
- Assaulted
- Captured
- Stabilizing

Capture:
- army presence at gate drives progress;
- defenders stop progress;
- contested state pauses progress;
- progress decays rather than hard-resetting.

Garrison:
- castle has defender strength;
- ranged defenders can fire from walls;
- attackers need to defeat or displace garrison before capture becomes reliable.

## Definition of Done

Two armies can:
- meet;
- fight automatically;
- use ranged attacks;
- lose soldiers;
- change morale;
- retreat;
- re-form;
- assault a castle;
- capture it.

No player-avatar sword fighting may be required for the core loop.
