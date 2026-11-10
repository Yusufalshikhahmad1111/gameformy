# Kingdoms Conquest — Full Repository Bug Audit

Date: 2026-11-10

## Audit scope

This audit covers the current main branch across the gameplay runtime, Stage 4 lobby/matchmaking, Stage 5 progression, Stage 7 bootstrap, Stage 11 network contract, Stages 12–18 gameplay and presentation layers, the main HUD, legacy client overlays, shared map/config/schema modules, and Rojo project mapping.

## Critical findings fixed

### 1. Legacy tactical minimap could run beside Stage 17
Stage8TacticalMinimap.client.lua was still creating a second tactical-map surface during active matches.
Fix: it now waits briefly for KC_Stage17Ready and exits when the Stage 17 command center is healthy. It remains only as a fallback if the new command center fails to initialize.

### 2. Legacy combat VFX could duplicate Stage 18
Stage2VFX.client.lua consumed the same VFX stream as the new Stage 18 presentation layer and could duplicate hit/projectile/castle effects.
Fix: it now yields for Stage 18 readiness and exits when Stage 18 is healthy. It remains a fallback for boot failures.

### 3. Legacy season badge could overlap the Stage 17 command bar
Stage6Season.client.lua created an in-match top-right season overlay that competed with the new command-center top bar.
Fix: it now remains fallback-only when Stage 17 is healthy.

### 4. Stage 18 combat-module return ordering
CombatService.lua previously returned the module before terrain/auto-acquire helper definitions.
Fix: module return is now at the true end of the file.

### 5. Castle capture progress was not published to visible models
The runtime castle state had CaptureProgress, but the visible proxy did not publish it as an attribute.
Fix: Stage 1 now publishes CaptureProgress to runtime and static castle models.

### 6. Stage 18 marching dust could generate too frequently
Dust throttling was initially keyed by world position, which changes continuously.
Fix: throttling is now keyed per army model.

## Security/authority audit

- NetworkContract remains the authoritative gameplay remote hierarchy.
- Army commands continue through StateSchemas and server-side ownership validation.
- Follow and Retreat remain server-authoritative.
- Rematch is validated server-side and only accepted after match end.
- Stage 18 personality values are deterministic and bounded.
- Personality values are intentionally excluded from publicArmyState.
- Presentation scripts do not create gameplay authority.

## Startup/lifecycle audit

- Stage 7 resolves MapId/TeamCount from TeleportData before Stage 1 world construction.
- Studio DataStore/MemoryStore/cross-server paths remain disabled where required by the existing lifecycle.
- Stage 16 waits for runtime readiness.
- Stage 17 waits for Bootstrap/Runtime/Stage16 readiness.
- Stage 18 waits for Bootstrap/Runtime/Stage16/Stage17 readiness.
- Classic Roblox camera settings remain in default.project.json.

## UI audit

Active match primary UI is now Stage 17 Command Center.
Stage 18 owns match-results presentation.
Stage 4 owns the lobby/party surface.
Stage 5 profile remains optional and opens only on demand.
Legacy tactical map, legacy combat VFX, and legacy season overlay now yield to the newer systems.

## Repository hygiene

`TerritoryService.lua` is an empty legacy compatibility module and is not part of the active authority path.
`ServiceRegistry.lua` is retained as a lightweight registry but the live match path explicitly owns service dependencies.
`default.project.json` maps the complete src/ServerScriptService, ReplicatedStorage, StarterPlayerScripts and visible map assets into Rojo.

## Static verification

- Stage 18 touched files: structural Lua block-balance PASS.
- Stage 18 targeted assertions: PASS.
- No second gameplay RemoteEvent hierarchy added by Stage 18.
- Default Roblox camera configuration preserved.
- Current code inventory was reviewed across 30 source files surfaced by repository-wide code searches.

## Remaining external gate

No static audit can replace Roblox Studio execution.
Before launch, Studio still must verify actual startup, camera behavior, mobile touch targets, VFX intensity, banner motion, optional audio playback, multiplayer replication, teleport behavior in a published experience, and sustained FPS/memory behavior.

## Decision

Repository-level bug audit: PASS.
Legacy visual duplication fixes: APPLIED.
Stage 18 runtime gate: READY.
Studio launch gate: PENDING.