# Stage 11 — Stability & Architecture Implementation Report

Date: 2026-11-08

## Implemented

### 1. Single network contract
Added:
- `src/ReplicatedStorage/Shared/NetworkContract.lua`

Authoritative folder:
- `ReplicatedStorage.KingdomsRemotes`

Contract v1:
- Command
- State
- Feedback
- VFX
- LobbyAction
- LobbyState
- RequestState
- RequestLobbyState

Existing Stage 1 no longer destroys and recreates `KingdomsRemotes` during startup. This prevents clients that are already waiting for the folder from being stranded.

### 2. Shared state schemas
Added:
- `src/ReplicatedStorage/Shared/StateSchemas.lua`

Contracts are defined for:
- Match
- Army
- Soldier
- Province
- Economy

Army command payloads are validated before the server accepts them.

### 3. Service boundaries
Added:
- `ServerScriptService/Services/ArmyService.lua`
- `CaptureService.lua`
- `EconomyService.lua`
- `MatchService.lua`
- `WorldBuilder.lua`
- `ServiceRegistry.lua`

The existing Stage 1 runtime now uses the ArmyService for combat damage calculation and MatchService for victory target calculation.

### 4. Runtime architecture health gate
Added:
- `ServerScriptService/Stage11Architecture.server.lua`

It records:
- Stage 11 readiness;
- network contract readiness/version;
- selected map readiness;
- Studio/runtime mode;
- state schema version.

## Important compatibility decision

Stage 11 does NOT delete the current Stage 1 runtime.

The current runtime remains the compatibility shell while Stage 12–15 progressively move army, combat, bot and economy orchestration into the new service boundaries.

This avoids another large destructive rewrite.

## Camera

The project continues to use Roblox's normal player camera configuration:
- CameraMode = Classic
- Computer camera = UserChoice
- Touch camera = UserChoice

No custom script should attempt to set `DevCameraOcclusionMode` at runtime. The previous permission error came from attempting to write a developer-only camera property from a LocalScript.

## Verification gate

Local Roblox Studio verification is still required before declaring Stage 11 closed.

Run:
1. `git pull --ff-only`
2. `rojo build -o gameformy.rbxlx`
3. Open the generated place in Studio.
4. Press Play.
5. Confirm Output contains:
   `[KingdomsConquest][Stage11] architecture ready`
6. Confirm there is no `KingdomsRemotes` infinite-yield error.
7. Confirm existing map/lobby still load.
8. Confirm selecting/creating an army still works.

## Stage 11 exit condition

Stage 11 becomes COMPLETE only after:
- clean Rojo build;
- clean Studio startup;
- no critical network/runtime errors;
- match can start;
- match can end;
- lobby can return.

Until those are verified, status is **IMPLEMENTED — AWAITING STUDIO GATE**.
