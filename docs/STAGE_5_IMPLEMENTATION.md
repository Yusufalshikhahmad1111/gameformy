# Stage 5 — Progression / Profile / Retention Foundation

## Implemented
- Persistent player profiles with DataStoreService.
- Schema versioning and safe defaults.
- Atomic UpdateAsync saves with retry.
- Autosave, PlayerRemoving save, and BindToClose shutdown save.
- XP, levels, coins, wins/losses, captures, streaks and match statistics.
- Server-authoritative achievements.
- Daily reward: 100 Coins + 50 XP once per UTC day.
- Analytics-safe custom event hooks.
- Commander profile UI with compact badge.
- Client cannot directly award XP, coins, levels or achievements.

## Progression
- 500 XP per level.
- Capture: +100 XP.
- Win: +300 XP and +250 Coins.
- Loss: +100 XP.
- Daily reward: +50 XP and +100 Coins.
- Level-up: +50 Coins per level.

## QA acceptance
1. New player receives level 1 safe profile.
2. Rejoin preserves profile.
3. Daily reward is once per UTC day.
4. Capture and match-result events award progression only on the server.
5. Client cannot set profile values.
6. Failed DataStore calls do not crash the match.
7. Autosave and shutdown paths are protected.
8. Profile UI handles empty achievements.

## Runtime note
Full persistence and analytics require a published Roblox experience with the relevant API services enabled. The safe-default path remains usable for local development.