# Stage 17 — Implementation Report

## Status

**Implemented and ready for handoff to Stage 18.**

The Stage 17 interaction model replaces the legacy Stage 10 HUD rather than layering another interface on top of it.

## UX architecture

### Desktop Command Center

- top command/status strip:
  - team;
  - territory score;
  - countdown;
  - map;
  - team count;
  - Gold;
  - Supplies;
  - income;
  - upkeep;
  - language switch;
- left army command card;
- contextual castle command panel;
- tactical map;
- bottom-center command bar;
- compact economy strip.

### Mobile Command Center

- touch-safe command buttons;
- five primary battlefield commands:
  - Move;
  - Attack;
  - Hold;
  - Follow;
  - Retreat;
- dedicated formation row;
- recruit/reinforce action;
- contextual castle panel;
- tactical map with:
  - drag;
  - pinch zoom;
  - zoom/reset controls;
  - castle nodes;
  - route lines;
  - army dots;
- compact economy strip;
- no desktop panel stacking.

## Army UX

The selected army card now communicates:

- role;
- soldier count;
- health;
- morale;
- fatigue;
- power;
- order;
- combat state;
- destination;
- economy strain/comeback context.

Click/tap an army to select it.

Command mode then changes the meaning of the next world interaction.

## Castle UX

Castle inspection now includes:

- owner;
- tier;
- state;
- garrison;
- max garrison;
- capture progress.

Context actions:

- Inspect;
- Focus tactical map;
- Route selected army to the castle;
- Set objective marker.

The player can still capture through the existing gate gameplay system; Stage 17 does not bypass the server-authoritative capture rules.

## Tactical map

The map is derived from the existing authoritative `MapNodes` and `MapEdges` state.

No parallel strategic graph was introduced.

Army dots use live army positions. Castle colors follow province ownership. Contested/assaulted castles receive a visible state marker.

## Onboarding

During the first 90 seconds of a match, a compact Command Brief guides the new player through:

1. selecting an army;
2. sending it toward a castle;
3. holding a gate to capture;
4. watching income;
5. choosing a formation.

The brief disappears after the initial learning window or can be closed manually.

## Localization

Stage 17 expands the shared UI vocabulary for English and Arabic.

The client supports live EN/AR switching and updates:

- static labels;
- command labels;
- formation labels;
- castle labels;
- dynamic state names;
- army role names;
- RTL alignment for major information panels.

## Network / gameplay integration

Added authoritative commands:

- `Follow`;
- `Retreat`.

`Follow` tracks a friendly army position server-side and stops safely when the target disappears.

`Retreat` reuses the existing server retreat logic instead of creating a second combat escape system.

The state schema is now **v3** and exposes `FollowTargetArmyId`.

## Safety

Stage 17 does not make the client authoritative over:

- movement validation;
- attack validation;
- recruitment;
- capture;
- economy;
- bot behavior;
- team ownership.

All new commands pass through the existing `StateSchemas` + `RateLimiter` server path.

## Runtime gate

Added:

`src/ServerScriptService/Stage17UXUI.server.lua`

It verifies:

- NetworkContract availability;
- core remote availability;
- StateSchemas v3+;
- Stage 16 readiness.

Published signals:

- `KC_Stage17Ready`
- `KC_Stage17Studio`
- `KC_Stage17StateSchemaVersion`
- `KC_Stage17NetworkReady`
- `KC_Stage17MobileReady`

## Static audit

Performed after implementation:

- block-balance scan for the modified Luau files;
- old Stage 10 HUD identifier removed;
- Follow command appears in schema + client + server;
- Retreat command appears in schema + client + server;
- Arabic UI keys present;
- Stage 17 gate requires Stage 16;
- no second network hierarchy introduced.

## Remaining verification

Roblox Studio runtime remains the external gate for:

- exact device rendering;
- touch feel;
- live camera/world click interaction;
- visual spacing at device resolutions;
- performance under a real multi-player session.

This is the normal Studio verification step and is not an unfinished code requirement.

## Handoff

**Stage 17 is complete enough to stop changing its scope.**

Next stage: **Stage 18 — Presentation, Personality, Audio & VFX.**
