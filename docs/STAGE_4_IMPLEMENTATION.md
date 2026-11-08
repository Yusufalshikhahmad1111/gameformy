# Stage 4 — Multiplayer / Social Implementation

## Scope
Stage 4 adds the multiplayer shell around the existing Kingdoms Conquest battlefield.

### Implemented
- Party creation.
- 6-digit party join code.
- Party size cap of 4.
- Party leader queue authority.
- Cross-server MemoryStore matchmaking queue.
- Match grouping up to 8 players.
- Reserved-server routing using the current `TeleportOptions.ReservedServerId` flow.
- Per-player teleport data containing match ID and team assignment.
- Reconnect handoff through a short-lived MemoryStore reconnect record.
- Teleport failure reporting via `TeleportService.TeleportInitFailed`.
- Roblox Studio fallback: local two-party queue and practice mode without real teleports.
- Lobby spawn and lobby UI.
- Server-side party/queue validation.

## Production flow

```
Lobby
  ↓
Create / Join Party
  ↓
Party Leader queues
  ↓
MemoryStore matchmaking queue
  ↓
Match coordinator groups parties
  ↓
Generate ReservedServerId + MatchId
  ↓
Publish match-ready message to each source server
  ↓
Teleport each party into the same reserved server
  ↓
TeleportData carries team map + match ID
  ↓
Stage 1 battlefield activates
```

## Security
The client cannot:
- assign itself to a team;
- create a fake match;
- teleport itself;
- queue another party;
- change another party;
- bypass party size limits.

All party/queue/match decisions are server-side.

## Studio testing
Roblox Studio does not provide the same teleport environment as a published experience. Stage 4 therefore has two local paths:
- **QUEUE MATCH:** starts when at least two queued parties exist in the same Studio server.
- **PRACTICE:** starts a single-player local match so the battlefield can still be inspected.

For real cross-server testing, publish the experience and use the live server flow.

## Acceptance
Before Stage 4 is called release-ready, manually verify in Studio/live:
- Two players can create/join the same party.
- Party code is copied/shared correctly.
- Only leader can queue.
- Two parties can enter matchmaking.
- Published experience routes both parties to the same reserved server.
- Both players receive the same MatchId.
- Team assignments are preserved through teleport.
- Disconnect + rejoin returns the player to the reserved match while the reconnect record is still valid.
- Teleport failure does not crash the lobby.

## Note
Stage 4 is code-complete in the repository, but the final runtime acceptance requires Roblox Studio/live-experience testing.
