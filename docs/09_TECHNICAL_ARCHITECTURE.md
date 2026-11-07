# 09 — Technical Architecture

## Authority
Server authoritative.

Client sends intent:
- move formation;
- attack target;
- change formation;
- attempt capture.

Server decides:
- legality;
- ownership;
- resources;
- combat;
- capture;
- victory.

## Suggested Roblox services
ServerScriptService:
- MatchService
- TerritoryService
- CastleService
- ArmyService
- CombatService
- EconomyService
- PartyService
- AntiCheatService
- AnalyticsService

ReplicatedStorage:
- SharedTypes
- Config
- Remotes
- UI state contracts

ServerStorage:
- server-only assets/templates.

## Match lifecycle
Lobby server:
- party;
- queue;
- map selection.

Match server:
- reserved/private server;
- match state;
- simulation;
- result.

Persistent progression:
- DataStoreService.

Temporary matchmaking/state:
- MemoryStoreService.

Cross-server messaging:
- MessagingService only where required.

## Simulation
Use fixed logical ticks for strategic simulation.
Do not tie game rules to render FPS.

NPC updates:
- high frequency near player;
- lower frequency at distance;
- pooled agents.

## Streaming
Enable streaming for large maps.
Design critical gameplay so it does not require every object to be locally loaded.

## Remotes
Never trust:
- target ownership;
- resource amount;
- capture state;
- damage;
- cooldown;
- troop count.

Client requests, server validates.

## Existing project migration
The current `game` repository has an older turn-based grid history and a newer real-time world-PvP pivot. Do not keep both runtime architectures alive.
Create a clean `KingdomsConquest` runtime namespace and migrate only reusable infrastructure.

## Code quality
- typed configuration;
- small services;
- deterministic pure logic where possible;
- unit tests for rules;
- Studio playtests for runtime behavior;
- no giant 1000-line manager script.