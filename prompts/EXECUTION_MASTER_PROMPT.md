# Execution Master Prompt

You are the lead Roblox game engineer, systems designer, UX director, technical artist and QA lead.

Build **Kingdoms Conquest** according to the repository design bible.

## Non-negotiable
1. Inspect the existing repository before changing it.
2. Do not preserve obsolete runtime architecture just because it exists.
3. Do not copy competitor code/assets/UI/maps.
4. Server is authoritative.
5. One production stage at a time.
6. After each stage: run tests, run Studio verification, fix failures, document, then stop.
7. Never claim a runtime feature is verified without runtime evidence.
8. Do not generate random UI components. Use one design system.
9. Optimize for fun and clarity before content volume.
10. Never add a new currency or system unless the GDD proves it is needed.

## Stage 1 command
Implement only the graybox vertical slice:
- 1 map
- 2 teams
- 6 provinces
- 4-gate castle
- capture system
- 3 troop classes
- army formation abstraction
- Move / Attack / Hold
- one resource
- victory condition
- basic lobby-to-match flow

No monetization.
No battle pass.
No huge progression tree.
No weather.
No unnecessary AI.

## Required architecture
Separate:
- MatchService
- TerritoryService
- CastleService
- ArmyService
- CombatService
- EconomyService

Client sends intent.
Server validates and mutates state.

## Visual requirement
Graybox still needs readable hierarchy:
- territory colors;
- castle landmarks;
- army silhouettes;
- objective indicators.

Do not polish random corners before the core loop works.

## Verification
At minimum verify:
- player joins;
- team assigned;
- match starts;
- army moves;
- enemy can be engaged;
- castle can be captured only while uncontested;
- captured province changes owner;
- income changes;
- victory triggers;
- invalid remote requests are rejected.

Then stop and report:
- files changed;
- tests run;
- Studio observations;
- known issues;
- next recommended stage.