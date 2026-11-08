# Stage 11 — Stability & Architecture Foundation
## Objective

Make the project safe to evolve.

The study warns that stages 7–10 accumulated defects because they were written without complete runtime verification. Stage 11 therefore has one job: stop architecture debt from multiplying. fileciteturn90file0L27-L46

## Deliverables

### Services
Split responsibility into:
- MatchService
- ArmyService
- SoldierService
- CaptureService
- EconomyService
- BotCommanderService
- WorldBuilder
- CombatService

### State
Define explicit schemas for:
- MatchState
- ArmyState
- SoldierState
- ProvinceState
- EconomyState
- PlayerCommandState

### Network
Create one authoritative remote contract:
- Command
- RequestState
- State
- Feedback
- VFX

No system may silently create a second remote hierarchy.

### Quality gates
- StyLua
- Selene
- unit tests
- integration smoke tests
- Studio startup test
- Studio match-start test
- Studio match-end test

### Runtime acceptance
Test:
1. lobby spawn;
2. party creation;
3. map selection;
4. match activation;
5. army creation;
6. capture;
7. match end;
8. return to lobby.

## Definition of Done

- build succeeds;
- no syntax/lint errors;
- no duplicate authoritative state;
- match can start/end repeatedly;
- a new feature can be isolated to a service/module;
- Studio evidence exists for the complete loop.
