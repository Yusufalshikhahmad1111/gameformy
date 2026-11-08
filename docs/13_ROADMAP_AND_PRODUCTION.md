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

## Stage 7 — Launch hardening
- performance;
- exploit testing;
- mobile;
- crash recovery;
- moderation;
- telemetry;
- store page assets.

## Production rule
One stage at a time.
Implement → test → fix → report → stop.
Never stack five unverified systems.