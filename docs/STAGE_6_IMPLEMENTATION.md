# Stage 6 — Content Expansion

## Delivered
- Four-team configuration: Crimson, Azure, Emerald, Amber.
- Two registered maps: Heartland and Riverlands.
- Map registry with per-map spawns, river modifiers, province topology and starting ownership.
- Dynamic province generation from the selected map registry.
- Dynamic team creation and team colors.
- Dynamic matchmaking team assignment for 2–4 teams.
- Dynamic victory target based on map province count and victory ratio.
- Stage 3 world-polish code now follows the selected map registry instead of hard-coded Heartland province names.
- Season 1 framework: Founding Wars.
- Seasonal XP events from captures and victories.
- Season UI and server-authoritative season state.

## Product intent
Stage 6 expands replayability without introducing a second combat ruleset. Maps change topology and tempo; teams change strategic pressure; seasons provide a light return loop.

## Map identities
### Heartland
Compact six-province battlefield. Best for the default first-time experience and fast 2-team matches.

### Riverlands
Eight-province battlefield with a stronger river choke and four-corner spawn geometry. Intended for 3/4-team matches and later competitive playlists.

## Runtime contract
The map/team values are registry-driven, but a production match must choose its mode before the world is constructed in the reserved server. Stage 7 should harden match bootstrap so TeleportData selects MapId and TeamCount before Stage 1 world creation. This avoids rebuilding the live world after players arrive.

## Season contract
Season XP is session-scoped in Stage 6. Permanent seasonal rank/reward persistence should be merged into the Stage 5 profile schema during Stage 7 launch hardening, after datastore migration rules are tested.
