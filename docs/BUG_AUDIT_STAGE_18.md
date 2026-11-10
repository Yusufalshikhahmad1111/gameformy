# Kingdoms Conquest — Stage 18 Bug Audit

Date: 2026-11-10

## A. Authority and networking

- [x] Stage 18 uses the existing NetworkContract.
- [x] No new RemoteEvent/RemoteFunction hierarchy was introduced.
- [x] Rematch is validated by StateSchemas.
- [x] Rematch is accepted only after match end.
- [x] Server owns all gameplay outcomes.
- [x] Presentation scripts are cosmetic-only.

## B. Personality safety

- [x] Courage is bounded.
- [x] Aggression is bounded.
- [x] Discipline is bounded.
- [x] Loyalty is bounded.
- [x] Personality is deterministic from PersonalitySeed.
- [x] Personality is not exposed through publicArmyState.
- [x] Modifiers are narrow rather than random combat multipliers.

## C. Morale behavior

- [x] Victory increases morale.
- [x] Casualties reduce morale.
- [x] Leader loss reduces morale.
- [x] Nearby friendly support improves morale.
- [x] Supplied armies recover morale more reliably.
- [x] Isolation and enemy concentration create pressure.
- [x] Low morale reduces combat effectiveness through existing accuracy/power logic.
- [x] Courage changes retreat pressure.
- [x] Discipline changes cohesion/recovery.
- [x] Loyalty affects regroup/recovery.
- [x] High morale improves cohesion and first-contact behavior.

## D. Combat correctness

- [x] CombatService.GetTerrainModifiers is defined before module return.
- [x] CombatService.ShouldAutoAcquire is defined before module return.
- [x] Existing ranged/mixed combat remains server-authoritative.
- [x] Stage 18 keeps existing target/damage rules and only layers bounded personality modifiers.

## E. Castle presentation

- [x] Visible castles publish CaptureProgress.
- [x] Contest/assault gate highlight is client-only.
- [x] Capture progress is shown as a contextual bar.
- [x] Owner changes tween visible banner/territory colors.
- [x] Capture pulse/burst is cosmetic.
- [x] Static Stage 16 art remains the source of visible castle geometry.

## F. Army presentation

- [x] Existing army banner/pennant is reused.
- [x] Pennant motion is client-side.
- [x] Marching dust is throttled per army.
- [x] Army visuals remain separate from gameplay state.

## G. Audio safety

- [x] No unverified asset IDs were invented.
- [x] Audio is optional through Workspace attributes.
- [x] Missing SoundIds do not block gameplay.
- [x] Audio events are rate-limited.

## H. Results/rematch

- [x] Match result contains territory/army/soldier summary.
- [x] Field reward is clearly a match-result value, not fake persisted XP.
- [x] Rematch starts through a server command.
- [x] Rematch resets through the existing MatchActive lifecycle.
- [x] Result UI is mobile-sized and touch-based.

## I. Structural verification

- [x] New Stage 18 scripts pass the repository structural block-balance sanity check.
- [x] Existing touched services also pass the structural check.
- [x] Stage 18 files are covered by default.project.json directory mappings.
- [x] No duplicate HUD/remote layer was introduced.

## Remaining external validation

Studio is still required for:
- actual Roblox runtime startup;
- mobile touch feel;
- real safe-area behavior;
- real camera distance and visual hierarchy;
- multiplayer replication;
- audio playback;
- performance under active combat.

Decision: Repository audit PASS. Studio runtime gate PENDING.