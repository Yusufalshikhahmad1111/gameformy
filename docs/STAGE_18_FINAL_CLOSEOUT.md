# Kingdoms Conquest — Stage 18 Final Closeout

## Status

Stage 18 — Repository Audit READY

Stage 18 now covers the full intended presentation pass:

1. bounded soldier personality;
2. reactive morale;
3. leader-loss consequences;
4. readable banner/pennant motion;
5. marching dust;
6. castle capture presentation;
7. territory transition feedback;
8. optional audio integration hooks;
9. match result overview;
10. rematch loop;
11. Stage 18 runtime readiness diagnostics.

## Important engineering fixes included

The stage was not treated as a cosmetic-only pass.

A pre-existing CombatService module-return ordering bug was repaired so terrain helpers and auto-acquire helpers actually load.

The visible castle now receives CaptureProgress, closing the data path required for real capture-progress presentation.

Marching dust is rate-limited per army so its visual loop does not scale with continuously changing world positions.

## Git handoff

Stage 17 closeout base:
ef2dc81a9118d53efc06927f1387f348d43f150c

Current Stage 18 audit head:
3d1e4b610ce7477181e7db50e97827401924d4f5

The repository is 20 commits ahead of the Stage 17 closeout base and has no known branch divergence from that base.

## Studio gate

Not executed in this session.

That means Stage 18 should not be called fully runtime-verified until Roblox Studio confirms:
- startup;
- actual battle VFX;
- mobile layout;
- banner motion;
- capture progression;
- rematch;
- multiplayer;
- performance.

The correct handoff is therefore:

READY FOR STUDIO VALIDATION → then Stage 19.