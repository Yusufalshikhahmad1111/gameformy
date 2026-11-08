# Stage 14 — Bot Commanders
## Objective

Make matches playable with low player population.

## Bot responsibilities

A bot must:
- understand its territory;
- value provinces;
- recruit;
- move armies;
- attack;
- defend;
- retreat;
- reinforce;
- protect capital;
- respond to threats.

## Decision system

Every decision evaluates:

Score =
ObjectiveValue
+ ThreatValue
+ TeamNeed
+ ArmyFit
+ TravelCost
+ Intelligence

Use bounded weights and cooldowns so bots do not oscillate.

## States

- Idle
- Recruiting
- Marching
- Attacking
- Defending
- Retreating
- Reinforcing
- Recovering

## Difficulty

Recruit:
- slower reassessment;
- shorter planning horizon.

Veteran:
- better target selection;
- better formations.

Warlord:
- better economy management;
- earlier defense response;
- smarter retreat.

Difficulty should improve decisions, not cheat with hidden damage multipliers.

## Fill logic

When a team lacks human players:
- spawn bot commander;
- assign starting territory;
- grant the same economy rules;
- use the same army service as humans.

## Definition of Done

One human can play a full match with meaningful opposition.

Two bots cannot repeatedly choose the same failed attack without adaptation.
