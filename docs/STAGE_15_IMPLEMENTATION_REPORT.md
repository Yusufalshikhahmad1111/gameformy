# Stage 15 — Economy, Recruitment & Progression

Date: 2026-11-10

## Status

**IMPLEMENTED — repository gate complete; Roblox Studio runtime gate pending.**

## 1. Economy model

The match economy now contains two readable resources:

### Gold
Used for:
- recruiting soldiers;
- reinforcing armies;
- paying army upkeep.

### Supplies
Used for:
- recruiting soldiers;
- reinforcing armies;
- tactical capacity.

Account `Coins` from Stage 5 remain the meta/profile currency. They are intentionally not used as battlefield power.

## 2. Territory income

Each owned province contributes Gold and Supplies per minute.

Income is modified by:

### Connected territory
Connected to the team's home capital:
- 100% base income.

Disconnected:
- 55% base income.

This is calculated from the map's real province graph and `Edges`.

### Stabilization
A newly captured castle temporarily produces reduced income:
- 60% of normal province income.

### Comeback
Teams controlling 30% or less of the map receive a modest economic recovery:
- +12% income;
- 10% recruitment cost reduction;
- 12% reinforcement cost reduction.

No combat damage multiplier is granted.

## 3. Upkeep

Every living soldier contributes role-specific Gold upkeep:

| Role | Gold / soldier / minute |
|---|---:|
| Spearmen | 0.60 |
| Archers | 0.80 |
| Cavalry | 1.20 |

Large armies therefore have a real strategic cost.

If net Gold becomes negative, the system marks:
- `EconomyStrain=true`

and applies a small morale/fatigue pressure instead of deleting troops or creating arbitrary penalties.

## 4. Recruitment

Current baseline:

| Role | Gold / soldier | Supplies / soldier |
|---|---:|---:|
| Spearmen | 10 | 2 |
| Archers | 12 | 2 |
| Cavalry | 16 | 3 |

New armies buy an affordable initial batch up to the configured size.

Reinforcement buys one soldier at a time.

All recruitment paths — human and bot — use `EconomyService`.

## 5. Bot integration

Stage 14 was updated for the new economy:
- bot recruitment evaluates Gold + Supplies;
- bot reinforcement reads the team economy state;
- no free bot resources;
- failed economy checks stop recruitment naturally.

## 6. State/UI

The authoritative state now publishes:

- Gold;
- Supplies;
- GoldIncomePerMinute;
- SupplyIncomePerMinute;
- UpkeepGoldPerMinute;
- NetGoldPerMinute;
- ConnectedProvinces;
- OwnedProvinces;
- StabilizedProvinces;
- Comeback;
- EconomyStrain.

The current HUD exposes:
- Gold;
- Supplies;
- income/minute;
- upkeep/minute;
- recruitment cost as Gold + Supplies.

## 7. Debug fixes found during Stage 15 audit

### Stage 14 BotCommanderService
Fixed:
- helper functions were placed after `return BotCommanderService`;
- reinforcement previously expected a numeric Supplies value but now receives an Economy state.

### Stage 1 economy loop
Removed:
- the old independent Supplies income loop.

Reason:
It would have created double income after the new EconomyService became authoritative.

### Stage 5 progression
Fixed:
- Stage5Remotes and Stage7SeasonRemotes were being destroyed/recreated on startup.

They are now preserved/created idempotently, matching the Stage 11 network safety principle.

### State schema
Bumped:
- `StateSchemas.Version = 2`

because Economy and Bot state are now part of the shared contract.

## 8. Architecture

Authoritative flow:

`Province/Edges/Castle → EconomyService → Team Economy → Army Recruitment/Upkeep → State → HUD/Bot`

The UI never owns balances.

Bots never bypass economy.

## 9. Explicit non-goals

Still reserved for later stages:
- full meta progression UX;
- polished economic dashboard;
- final mobile command redesign;
- final 3D resource/city presentation;
- long-term season economy balancing.

## 10. Verification

Repository audit completed:
- no legacy autonomous Supplies income loop remains;
- recruitment uses EconomyService;
- reinforcement uses EconomyService;
- bot recruitment/reinforcement use Economy state;
- BotCommanderService has no executable code after module return;
- Stage5 progression remotes are startup-safe;
- state schema version is 2.

Studio gate still required:
1. start match;
2. observe starting Gold + Supplies;
3. recruit;
4. watch Gold/Supplies decrease;
5. observe province income increase balances over time;
6. create multiple armies and see upkeep rise;
7. lose territory and verify income changes;
8. capture a castle and verify stabilization income penalty;
9. fall behind and observe comeback modifier;
10. verify bots use the same resource pool and can become economically strained.

## Definition of Done

A player can visually understand:
- how much money they have;
- what recruiting costs;
- how much their armies cost to maintain;
- where their income comes from;
- why an isolated or newly captured province pays less;
- how economic recovery works after losing ground.
