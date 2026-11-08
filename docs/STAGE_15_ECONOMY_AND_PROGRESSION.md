# Stage 15 — Economy, Recruitment & Progression
## Objective

Create a readable economic loop where territory directly funds war.

## Resource model

Supplies:
tactical army operations.

Gold:
recruitment and upkeep.

Commander XP:
account progression.

Season XP:
season progression.

## Territory income

Income =
BaseProvinceIncome
× OwnershipModifier
× ConnectionModifier
× StabilizationModifier

Connected to capital:
100% income.

Disconnected:
reduced income.

Recently captured:
temporary stabilization period.

## Army economy

Recruitment:
- each soldier has a cost;
- cost varies by role;
- stronger tiers cost more.

Upkeep:
- army pays based on soldier count;
- larger armies consume more resources.

Reinforcement:
- cheaper than creating a new army from zero.

## Comeback

Losing side:
- modest recruitment discount;
- shorter reinforcement travel;
- more useful neutral route opportunities.

Do not grant raw combat damage multipliers.

## Player progression

Account:
- level;
- XP;
- cosmetics;
- titles.

Match:
- supplies;
- gold;
- armies;
- territory.

Season:
- season XP;
- rank;
- rewards.

## Definition of Done

The player can visually understand:
- where income comes from;
- why an army costs what it costs;
- why upkeep is rising;
- what happens when a castle is lost;
- how to recover after losing ground.
