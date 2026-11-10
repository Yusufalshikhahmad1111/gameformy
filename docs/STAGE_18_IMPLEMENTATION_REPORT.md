# Kingdoms Conquest — Stage 18 Implementation Report

Date: 2026-11-10

## Objective

Stage 18 makes the battlefield communicate state through soldier personality, morale, animation, VFX, optional audio hooks, and a match-results/rematch loop without introducing a second gameplay authority.

## Implemented

### 1. Soldier personality
Every soldier now receives deterministic, bounded values from its existing PersonalitySeed:

- Courage: 0–100
- Aggression: 0–100
- Discipline: 0–100
- Loyalty: 0–100

The values remain hidden from the public HUD/state contract.

### 2. Morale and behavior
Morale now reacts to:

- successful kills/victories;
- nearby friendly support;
- supply availability;
- formation changes;
- casualties;
- leader loss;
- enemy concentration/surrounding pressure;
- isolation and low loyalty.

Bounded effects:
- Courage slightly changes damage morale loss and retreat threshold.
- Discipline affects accuracy/cohesion and recovery.
- Aggression lightly affects power and target preference.
- Loyalty and morale affect regroup/recovery speed.
- Army cohesion is clamped to a narrow band so personality cannot create chaotic combat outcomes.

### 3. Combat correctness fix
CombatService.lua had return CombatService before GetTerrainModifiers and ShouldAutoAcquire. Stage 18 moves the module return to the true end of the module so those functions are actually registered.

### 4. World presentation
Added Stage18Presentation.client.lua with client-only presentation:

- animated castle hero banners;
- animated army pennants;
- marching dust;
- castle capture progress treatment;
- castle gate highlight during contest/assault;
- territory pulse on ownership transition;
- capture burst/ring VFX;
- restrained combat impact emphasis.

The presentation layer never creates gameplay remotes or authoritative state.

### 5. Optional audio hooks
No unverified Roblox asset IDs were invented.

Audio is configurable through workspace attributes referenced by Config.Stage18.OptionalAudioAttributes:

- selection;
- command;
- bow release;
- melee impact;
- castle contested/captured;
- battle impact;
- army destroyed;
- victory/defeat.

When no SoundId attribute is configured, the game remains silent instead of using fake assets.

### 6. Capture state publication
Visible castle models now publish CaptureProgress alongside Owner, CastleState, Garrison, and CaptureTeam. This gives the Stage 18 visual layer authoritative progress data.

### 7. Match results and rematch
finishMatch() now produces a player-facing match summary containing:

- territory count;
- surviving armies;
- surviving soldiers;
- field reward value;
- current Gold/Supplies.

A new Rematch command safely restarts the match after the results screen is shown.

The displayed field reward is a match-result value; it is not falsely presented as persisted progression XP.

### 8. Runtime gate
Added Stage18Presentation.server.lua.

The gate verifies:

- Bootstrap/Runtime readiness;
- Stage 16 readiness;
- Stage 17 readiness;
- NetworkContract remotes;
- StateSchemas v4+;
- personality fields;
- Stage 18 presentation configuration.

It publishes:
- KC_Stage18Ready
- KC_Stage18Studio
- KC_Stage18StateSchemaVersion
- KC_Stage18NetworkReady
- KC_Stage18PersonalityReady
- KC_Stage18PresentationReady

## Files changed

- src/ReplicatedStorage/Shared/Config.lua
- src/ReplicatedStorage/Shared/StateSchemas.lua
- src/ServerScriptService/Services/SoldierService.lua
- src/ServerScriptService/Services/ArmyService.lua
- src/ServerScriptService/Services/CombatService.lua
- src/ServerScriptService/KingdomsConquestStage1.server.lua
- src/ServerScriptService/Stage18Presentation.server.lua
- src/StarterPlayer/StarterPlayerScripts/Stage18Presentation.client.lua
- src/StarterPlayer/StarterPlayerScripts/Stage18Victory.client.lua

## Verification

Repository-level checks completed:

- Stage 18 structural assertions: PASS
- Luau structural block-balance sanity check: PASS
- State schema v4 presence: PASS
- Rematch command contract: PASS
- CaptureProgress publication: PASS
- personality fields and aggregation: PASS
- leader-loss morale hook: PASS
- CombatService return ordering: PASS
- Stage 18 runtime gate: PASS
- visual/audio hook wiring: PASS
- no second RemoteEvent hierarchy introduced: PASS
- Rojo mapping covers all new files: PASS

The repository is 17 commits ahead of the Stage 17 closeout base.

## External gate

Roblox Studio runtime/visual testing was not executed in this session.

Still required in Studio:
- banner motion quality from gameplay camera distances;
- mobile safe-area/text scaling;
- dust frequency and particle readability;
- VFX intensity at battle scale;
- optional audio assets and spatial mix;
- rematch lifecycle across real multiplayer clients;
- FPS/replication impact.

Stage 18 is therefore repository-audit READY, with the Studio runtime gate still external.