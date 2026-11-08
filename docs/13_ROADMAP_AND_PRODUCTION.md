# 13 — Roadmap and Production

## Stage 0 — Product lock
Deliver:
- GDD;
- art bible;
- map topology;
- economy spreadsheet/simulation;
- technical architecture.

Exit:
No unresolved core-rule contradictions.

## Stage 1 — Graybox vertical slice
Build:
- one map;
- two teams;
- six provinces;
- castle;
- capture;
- three units;
- four formations;
- win condition.

No cosmetics.

Exit:
A full match is playable from lobby to result.

## Stage 2 — Combat quality
Build:
- formation movement;
- combat;
- terrain;
- readable VFX;
- tactical pings.

Exit:
A 5-minute battle is fun even without progression.

## Stage 3 — Premium presentation
Build:
- hero castle;
- final terrain materials;
- UI system;
- camera;
- sound;
- onboarding.

Exit:
A stranger sees the game and immediately understands the fantasy.

## Stage 4 — Multiplayer/social
Build:
- party;
- matchmaking;
- reserved servers;
- reconnect/failure handling.

Exit:
Real groups can play reliably.

## Stage 5 — Retention
Build:
- progression;
- cosmetics;
- profile;
- rematch;
- analytics.

Exit:
Players have reasons to return beyond novelty.

## Stage 6 — Content — COMPLETED
Delivered:
- four-team configuration and team registry;
- second map (Riverlands) plus map registry;
- dynamic province/team/victory rules;
- matchmaking assignment support for 2–4 teams;
- seasonal content framework and Season 1;
- seasonal XP UI and server-side events.

Hardening carried into Stage 7:
- select MapId and TeamCount from TeleportData before world construction in reserved servers;
- persist seasonal progression in the permanent profile schema after migration testing.

## Stage 7 — Launch Hardening — COMPLETED

Delivered:
- pre-world bootstrap from TeleportData with validated MapId / TeamCount;
- server-side rate limiting for command, party, matchmaking and profile remotes;
- efficient unreliable state/VFX remotes where appropriate;
- persistent SeasonId / SeasonXP / reward-claim schema migration;
- reconnect-safe profile initialization and season synchronization;
- launch QA checklist covering runtime, security, data, performance and mobile;
- production release gate documented.

Studio-only release gate remains mandatory: source inspection cannot substitute for a real Roblox multiplayer playtest.


## Stage 8 — World Map Architecture — COMPLETED
Delivered:
- data-driven MapPacks for Syria, Saudi Arabia, Palestine and Europe;
- map-aware matchmaking and team-count selection;
- MapService world graph;
- dynamic tactical minimap;
- map/team mode transport through TeleportData;
- production bootstrap validation.

## Stage 9 — World Map Art & Castle Content — IMPLEMENTED
Delivered:
- regional art profiles for all four world maps;
- map-aware terrain, river and lighting presentation;
- reusable castle tiers: Capital / Major / Regional;
- castle metadata for city, province and tier;
- graph-driven roads derived from MapService edges;
- reusable trees, rocks, bridges and regional accents;
- capital/major visual hierarchy;
- city/province labels driven by MapService;
- team-colored banners and ownership markers;
- tactical minimap polish for capitals, armies and contested castles;
- strategic map selection metadata and difficulty descriptions;
- multi-team starting ownership and economy/victory compatibility fixes discovered during Stage 9 audit.

Release gate:
- repository-level structural verification completed;
- real Roblox Studio visual/performance verification remains mandatory for every map, mobile layouts, dense castle scenes, streaming and multiplayer runtime.


## Stage 10 — Full UX/UI Interaction Overhaul — IMPLEMENTED
Delivered:
- unified contextual HUD;
- shared UITheme and Arabic/English interaction vocabulary;
- responsive desktop/mobile command controls;
- contextual army and castle interaction feedback;
- expandable tactical minimap;
- touch-compatible season interaction;
- responsive map-first lobby presentation;
- victory/defeat feedback;
- Stage 10 implementation report and Studio runtime gate.

Release gate:
- repository implementation complete;
- Roblox Studio verification remains mandatory for desktop, mobile, RTL, respawn stacking and performance.
