# Stage 16 — Implementation Report

## Status

**Implemented on `main`.**  
**Studio runtime gate: pending.** The repository was edited and statically audited, but Roblox Studio was not available in this execution environment, so no claim is made that the Stage 16 runtime gate has passed.

## What Stage 16 adds

Stage 16 upgrades the four editable launch maps without replacing the authoritative gameplay world:

- Capital / Major / Regional castle presentation kits.
- Castle roof/crown treatment and tower caps.
- Four readable gatehouses with pillars, beams, portcullis detail and lanterns.
- Hero banners with owner-colored cloth.
- Owner markers and a compact castle-state indicator.
- Small city blocks around each castle to create a stronger settlement silhouette.
- Terrain presentation accents and road-side stone markers.
- Shared atmospheric lighting and color treatment.
- Runtime labels for the strategic landmark hierarchy.

The art layer is intentionally visual-only. It does not create a second province graph, capture system, army system, economy system or network hierarchy.

## Gameplay integration

Stage 1 now publishes authoritative castle attributes to the visible static castle model:

- `Owner`
- `CastleState`
- `Garrison`
- `CaptureTeam`

Stage 16 listens to those attributes and updates the visible banner, ownership markers and state indicator.

The static map prefab remains the visible world source of truth. Stage 1's gameplay proxies remain invisible/non-collidable.

## Anti-overlap rules

Stage 16:

- Builds only under `Map_<Id>` static prefabs.
- Sets all new art parts to non-collidable / non-querying.
- Keeps state indicators and owner markers inside the castle footprint.
- Reuses the same `Config.MapPacks` + `MapService` city graph.
- Runs a spatial castle-spacing validation pass for every launch map.

The builder is also idempotent for a castle: an existing `Stage16Art` folder is removed before rebuilding.

## Full bug-audit findings

### Fixed in this stage

**Stage 4 remote bootstrap race**

The multiplayer script previously destroyed and recreated `Stage4Remotes`, then exposed `Stage4Ready` before the remotes were guaranteed to exist.

It now:

1. Reuses an existing `Stage4Remotes` folder.
2. Reuses correctly typed remotes.
3. Recreates only a remote with the wrong class.
4. Sets `Stage4Ready` only after the three Stage 4 remotes exist.

This aligns Stage 4 with the existing Stage 11 network-contract/idempotent startup rule.

### Confirmed during audit

- `KingdomsRemotes` is created through the authoritative `NetworkContract`.
- Stage 5 remotes are already idempotent.
- Stage 7 bootstrap runs before Stage 11 architecture validation.
- The custom Scriptable camera path is absent; the project keeps Roblox's default camera mode.
- Stage 1 runtime gameplay geometry is converted to invisible/non-collidable proxies before runtime play.
- Stage 15 economy state remains on schema v2.
- Stage 14 bot/economy integration remains server-authoritative.

## Files added / changed

### Added

`src/ServerScriptService/Stage16WorldArt.server.lua`

Runtime art builder + validation gate.

### Added

`docs/STAGE_16_IMPLEMENTATION_REPORT.md`

This report.

### Changed

`src/ServerScriptService/KingdomsConquestStage1.server.lua`

Publishes castle ownership/state/garrison attributes to the static visible map.

`src/ServerScriptService/Stage4Multiplayer.server.lua`

Removes destructive remote-folder recreation and fixes the Stage 4 readiness ordering.

## Stage 16 runtime signals

The Stage 16 script publishes:

- `KC_Stage16Ready`
- `KC_Stage16Studio`
- `KC_Stage16MapCount`
- `KC_Stage16CastleCount`
- `KC_Stage16AuditFailures`

Expected healthy shape in Studio:

`KC_Stage16Ready = true`  
`KC_Stage16AuditFailures = 0`  
`KC_Stage16MapCount = 4`

The exact castle count is derived from the configured city lists.

## Final gate

**Code / architecture:** ready.  
**Full bug audit:** completed for the inspected startup/network/world paths.  
**Roblox Studio visual/runtime validation:** pending.
