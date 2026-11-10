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

The Stage 18 change set is committed to main with no known branch divergence from the Stage 17 closeout base.

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

Full repository audit completed after Stage 18.

Legacy tactical-map, legacy combat-VFX and legacy season-overlay clients now yield to the Stage 17/18 systems when the new runtime is healthy.

Full audit document: `docs/FULL_REPOSITORY_BUG_AUDIT_2026-11-10.md`

The correct handoff is therefore:

READY FOR STUDIO VALIDATION → then Stage 19.