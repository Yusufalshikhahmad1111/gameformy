# Stage 1 — Graybox Vertical Slice

This stage implements the first playable Kingdoms Conquest loop.

## Included
- Rojo project file.
- Generated 6-province battlefield.
- 6 castles, each with 4 gate capture zones.
- 2 teams with automatic balancing.
- Server-authoritative province ownership and capture.
- 10-second uncontested capture.
- Capture contest and decay.
- War Supplies income.
- Spearmen / Archers / Cavalry.
- Move / Attack / Hold.
- Line / Wedge / Spread formations.
- Basic army combat and counters.
- Victory at 4 owned provinces.
- Desktop/touch HUD.
- Army purchasing from supplies.
- Spawn and team assignment.

## Run
1. Clone repository.
2. Install Rojo.
3. Run `rojo serve`.
4. Open Roblox Studio and connect the Rojo plugin.
5. Sync the project using `default.project.json`.
6. Press Play.
7. For two-player testing use Studio > Test > Start with 2 Players.

## Stage boundary
This is deliberately graybox. No monetization, progression tree, seasons, live ops, or final art pipeline are included here.

## Acceptance
A complete test should demonstrate:
spawn → select army → move → capture a castle → province changes team color → supplies increase → create another army → engage enemy → reach 4 provinces → victory.