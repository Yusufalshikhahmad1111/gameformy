# Stage 13 — Combat, Ranged Warfare & Castle Assault

Date: 2026-11-10

## Status

**IMPLEMENTED — repository gate complete; Studio runtime visual gate pending.**

Stage 13 converts the Stage 12 army system into an automatic battlefield system.

## Implemented

### 1. CombatService

Added:
- target acquisition;
- role priority;
- detection range;
- formation modifiers;
- hit chance;
- damage calculation;
- terrain modifiers;
- retreat thresholds.

This keeps combat rules out of the UI and reduces the chance of Stage 14 bots inventing a second combat system.

### 2. Automatic target acquisition

Armies can acquire nearby enemy armies automatically.

Priority is influenced by:
- troop counter relationship;
- target health ratio;
- distance;
- current attack order.

Examples:
- Cavalry values Archers more highly;
- Spearmen value Cavalry more highly;
- Archers value exposed Spearmen more highly.

### 3. Ranged warfare

Archers now:
- use an attack range;
- evaluate hit chance;
- choose a living attacker;
- calculate a real hit;
- apply soldier-level damage;
- generate ranged projectile feedback.

The client only renders the projectile trace/VFX. The server remains authoritative over hit/miss and damage.

### 4. Melee combat

Spearmen and Cavalry:
- close distance automatically;
- enter an Engaging state;
- resolve individual soldier damage;
- use formation modifiers;
- apply fatigue;
- generate melee impact feedback.

### 5. Morale / fatigue / retreat

Combat can force an army into:
- Retreating;
- Recovering.

Retreat is triggered by low morale or low remaining health.

An army remembers a fallback point and moves away from danger instead of fighting until its last soldier.

### 6. Castle warfare

Added CastleService with states:
- Safe
- Contested
- Assaulted
- Stabilizing

Every castle now has:
- tier;
- owner;
- garrison;
- maximum garrison;
- capture progress;
- stabilization timer.

Tier defaults:
- Capital: 140 garrison
- Major: 95 garrison
- Regional: 60 garrison

### 7. Assault flow

Army reaches a castle gate:
- if multiple teams are present -> Contested;
- if enemy garrison remains -> Assaulted;
- garrison absorbs assault damage;
- garrison can fire back;
- once garrison is displaced -> capture progress begins;
- capture completes after the normal capture duration;
- ownership changes;
- castle stabilizes briefly;
- garrison is restored.

This means a castle is no longer a flat “walk into region for 10 seconds” objective.

### 8. World/UI feedback

Added:
- Arrow projectile trace;
- melee impact pulse;
- castle hit feedback;
- castle captured ring;
- live army CombatState labels;
- castle garrison/state in the existing castle panel.

## Tuning philosophy

Initial values are intentionally conservative.

The system is built so Stage 19 can simulate:
- ranged-vs-melee;
- formation-vs-formation;
- role counters;
- terrain;
- castle assault;
- morale/fatigue.

Numbers are not locked balance decisions.

## Not included yet

Stage 13 intentionally leaves these for later stages:
- Bot commanders -> Stage 14
- deeper economic logistics -> Stage 15
- final hero castle art -> Stage 16
- full contextual HUD redesign -> Stage 17
- richer personality behavior/audio -> Stage 18

## Verification

Repository checks performed:
- CombatService exists;
- CastleService exists;
- Config contains combat/castle tuning;
- army state contains CombatState/FallbackPosition;
- state schemas include combat/castle state;
- server uses CombatService target selection and attack resolution;
- server uses CastleService for garrison/capture;
- VFX client handles ranged/melee/castle events;
- HUD reads castle state.

A Roblox Studio runtime session was not available in this turn, so the final gate remains:
- clean Rojo build;
- automatic army-vs-army combat;
- visible archer fire;
- retreat behavior;
- castle assault;
- castle garrison response;
- capture after garrison collapse.

## Definition of Done for Studio

1. Start a match.
2. Have two armies approach.
3. They automatically acquire each other.
4. Archers visibly fire at range.
5. Melee engages after closing.
6. Soldiers die individually.
7. Morale/fatigue change.
8. Low-morale/low-health army retreats.
9. Army reaches a castle gate.
10. Garrison damages attackers.
11. Garrison is reduced.
12. Capture starts only after garrison is displaced.
13. Castle ownership changes and stabilizes.
