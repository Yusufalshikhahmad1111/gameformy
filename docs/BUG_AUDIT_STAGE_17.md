# Stage 17 — Full Bug Audit

## Scope

Audit performed after the Stage 17 Command Center, Follow/Retreat commands and localization pass.

## Contract checks

| Area | Result |
|---|---|
| State schema | v3 |
| Follow command | Client + schema + server |
| Retreat command | Client + schema + server |
| Existing NetworkContract | Preserved |
| Stage 16 dependency | Required by Stage 17 gate |
| Client remains non-authoritative | Pass |

## UX checks

| Area | Result |
|---|---|
| Legacy Stage 10 HUD removed | Pass |
| Desktop command center | Implemented |
| Mobile command center | Implemented |
| Tactical map | Implemented |
| Castle contextual actions | Implemented |
| First-90-second onboarding | Implemented |
| EN/AR switching | Implemented |
| RTL panel alignment | Implemented |
| Mobile recruit drawer | Implemented |
| Touch-safe controls | Implemented |

## World interaction checks

- Army selection uses the existing ArmyId attributes.
- Castle selection uses the existing Province attributes.
- Move and Attack still use the existing server command validation.
- Follow only accepts a friendly army.
- Retreat reuses existing retreat behavior.
- Castle route uses authoritative map-node positions.
- Tactical map uses the same MapNodes/MapEdges published by the server.
- No client-created gameplay graph exists.

## Static code audit

The modified Luau files were checked with a block-balance scan after stripping comments and quoted strings.

Result:

- Stage 17 HUD: balanced blocks;
- Stage 1 server: balanced blocks;
- Stage 17 gate: balanced blocks;
- StateSchemas: balanced blocks;
- UITheme: balanced blocks.

This is a static structural check, not a Roblox Studio compile/runtime proof.

## Remaining external gate

Roblox Studio is still required to verify:

- real touch gestures;
- final safe-area positioning;
- mobile text scaling;
- actual camera/world raycast feel;
- multi-client behavior;
- frame-time impact.

## Decision

**Repository audit: PASS. Stage 17 READY for Stage 18 handoff.**
