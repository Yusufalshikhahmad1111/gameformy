# Kingdoms Conquest — Runtime Bugfix Audit (2026-11-08)

## Plan executed

1. Restore Stage 1 runtime state (provinceStates, mapNodes, initialOwner, terrain speed) and fix PlayerAdded ordering.
2. Make authoritative state a reliable RemoteEvent and normalize army IDs for client state tables.
3. Repair HUD syntax and season payload compatibility.
4. Repair map ownership/start positions, scale geographic MapPacks to a safe 2x battlefield, and derive spawns outside home castles.
5. Make world-art generation wait for bootstrap.
6. Add army recruitment and direct attack-target interaction in the HUD.
7. Make armies contribute to castle capture; contested capture now stalls instead of decaying.
8. Make Practice/rematch state reset cleanly when MatchActive changes.
9. Replace invalid reserved-server routing with ReserveServerAsync + ReservedServerAccessCode.
10. Remove the duplicate legacy Stage6 season runtime and enforce active season dates in Stage5.

## Verification status

- Repository/static review completed on the repair branch.
- No Roblox Studio runtime was available to this execution, so Studio Play/Local Server verification is NOT claimed.
- The remaining required gate is the exact Studio checklist from the inspection report: Play, Practice, two-player Local Server, capture, victory/defeat, minimap, season panel, and Output scan.

## Follow-up Runtime Fix Sweep — 2026-11-08

Additional root-cause fixes applied after Studio runtime logs:

1. **Map build failure fixed:** `MapService.lua` referenced `WORLD_SCALE` without defining it. That could stop Stage 1 before creating the runtime world, leaving the Studio camera with only the sky. `WORLD_SCALE` is now defined and city, river, and spawn coordinates are scaled consistently.
2. **Runtime world bounds fixed:** Stage 1 now derives the world floor extent from the selected map instead of relying only on a fixed bound.
3. **Studio DataStore fallback fixed:** Stage 5 now skips DataStore access in Studio and loads an in-memory default profile. Published servers retain real persistence.
4. **Studio MemoryStore fallback fixed:** Stage 4 no longer initializes MemoryStore collections in Studio. Local Studio matchmaking continues through the existing local queue path.
5. **Reserved-server publishing bug fixed:** Stage 4 now consistently uses the current GUID-based `TeleportOptions.ReservedServerId` route; the previous undefined `reservedServerAccessCode` reference is removed.
6. **Studio MessagingService subscription disabled:** cross-server subscription is now only initialized outside Studio.
7. **Verification limitation:** Roblox Studio runtime execution was not available through this connector, so final visual/console verification still requires the user's local Studio Play test.
