# Stage 14 — Bot Commanders Implementation Report

Date: 2026-11-10

## Status

**IMPLEMENTED — repository gate complete; Studio runtime gate pending.**

## Core design

Bots are commanders, not alternate combat engines.

They issue decisions into the same:
- ArmyService;
- SoldierService;
- CombatService;
- CastleService;
- economy/resource pool.

No hidden damage multiplier or free combat power is used.

## Implemented

### Bot commander model
Every bot has:
- Team;
- Difficulty;
- State;
- LastAction;
- ObjectiveId;
- ArmyIds;
- failure memory;
- active objective army.

### Match fill

On match activation:
- every team without a human receives one bot commander;
- bots receive the same team Supplies pool;
- the bot creates its starting army with the same Soldier/Army creation path as humans.

When a human joins a bot's team:
- that bot is removed;
- its armies are removed;
- the team remains human-controlled.

When the match ends:
- all bot commanders and bot armies are cleared.

### Decision states

Implemented:
- Idle;
- Recruiting;
- Marching;
- Attacking;
- Defending;
- Retreating;
- Reinforcing;
- Recovering.

### Objective selection

Bots score provinces using:
- income;
- strategic value;
- capital value;
- enemy ownership;
- nearby threats;
- travel distance;
- recent objective failure memory.

### Recruitment

Bots can:
- create a new army;
- choose a troop type according to available Supplies;
- cap themselves at configured army count.

Default cap:
- 3 armies per commander.

### Reinforcement

Bots can reinforce an existing wounded/rested army one soldier at a time using the normal per-soldier economy.

### Defensive behavior

If a valuable owned objective is under strong local threat:
- bot assigns an army to hold/defend;
- it cancels an attack order and watches the threat.

### Retreat

Bots evaluate:
- health;
- morale;
- local enemy strength.

A weak army retreats to its fallback point instead of fighting until destruction.

### Adaptation

If a bot's active army is destroyed, or an attack causes a retreat:
- the objective is temporarily penalized;
- the bot is less likely to repeat the same failed push immediately.

This directly addresses the "repeat the same attack forever" failure mode.

### Difficulty

Three decision profiles exist:
- Recruit;
- Veteran;
- Warlord.

Difficulty changes:
- think cadence;
- planning horizon;
- attack/defense/economy biases;
- risk tolerance.

Difficulty does NOT grant hidden combat multipliers.

## Player population behavior

The match can now be meaningful with:
- 1 human + bots;
- several humans + bots filling empty teams;
- full human teams without unnecessary bots.

## State publication

The server publishes bot commander state alongside Army/Castle state:
- Team;
- Name;
- Difficulty;
- State;
- LastAction;
- ObjectiveId.

## Important limitation

The current AI is deliberately strategic at the commander level, not a full tactical planner.

Stage 14 does NOT yet implement:
- multi-army coordinated flanks;
- explicit escort/screen formations;
- fog-of-war intelligence;
- long-horizon path planning;
- diplomacy/alliances;
- siege weapon targeting.

Those belong to later expansion after economy/world/UI foundations.

## Verification gate

Repository checks completed:
- BotCommanderService exists;
- Config exposes difficulty and army cap;
- Stage 1 creates/removes bots with match lifecycle;
- bots use the existing Army creation path;
- bot state is published;
- reinforcement uses the existing SoldierService path;
- failed objectives are remembered;
- no bot-specific damage cheat was added.

Studio gate still required:
1. 1 human starts a match;
2. empty teams spawn bots;
3. bot army appears;
4. bot moves toward a meaningful objective;
5. bot attacks/defends;
6. bot reinforces;
7. bot retreats when pressured;
8. bot stops existing after match end;
9. a human joining a bot team removes that bot.

## Definition of Done

Stage 14 is fully closed when a single human can start a match and observe at least one bot:
- recruit;
- move;
- attack;
- defend;
- retreat;
- reinforce;
- adapt after a failed push.
