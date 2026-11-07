# 10 — Multiplayer, Security and Performance

## Threat model
Assume exploiters can call every exposed RemoteEvent with arbitrary arguments.

Server must validate:
- player is in match;
- player owns/controls the selected army;
- target exists;
- target is reachable;
- command cooldown;
- capture proximity;
- team ownership;
- resource cost.

## Rate limiting
Use per-action limits.
Do not use one global throttle that makes legitimate command-heavy play feel broken.

## Performance targets
MVP target:
- stable 60 FPS on capable desktop;
- acceptable mobile performance;
- server frame budget protected during full battle.

Avoid:
- hundreds of active pathfinding agents;
- unbounded Heartbeat loops;
- cloning NPCs per hit;
- particle emitters on every soldier;
- continuous remote spam.

## Object pooling
Pool:
- arrows;
- hit effects;
- capture indicators;
- dust;
- temporary markers.

## LOD
Far units can become:
- lower animation frequency;
- simplified visuals;
- formation proxy.

## Network discipline
Replicate:
- state changes;
- commands;
- important events.

Do not stream every cosmetic animation as a remote event.

## Failure handling
If a player disconnects:
- army receives fallback order;
- party state updates;
- reconnection rules are explicit.

If a server crashes:
- match is not silently marked as a loss.