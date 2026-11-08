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