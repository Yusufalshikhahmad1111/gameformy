# Stage 12 — Army & Soldier System 2.0
## Objective

Turn the army from a visual marker into the game's primary controllable entity.

## Army model

Army:
- Id
- Team
- Owner
- Commander
- Position
- Formation
- Order
- Target
- Supplies
- Morale
- Cohesion
- Health
- MaxHealth
- Fatigue
- Experience
- Soldiers

## Soldier model

Each soldier has:
- Role
- Level
- Health
- MaxHealth
- Power
- Defense
- Range
- Accuracy
- Speed
- Morale
- Discipline
- Fatigue
- Experience
- PersonalitySeed

## Personality

Do not make personalities cosmetic.

Useful dimensions:
- Courage
- Aggression
- Discipline
- Loyalty

These values produce small bounded effects:
- retreat threshold;
- target selection;
- formation cohesion;
- regroup speed.

## Troops

### Spearmen
Role:
frontline / anti-cavalry.

### Archers
Role:
ranged pressure / support.

### Cavalry
Role:
mobility / flank / anti-archer.

## Recruitment

Recruitment uses in-game resources only.

Suggested formula:

RecruitCost =
BaseCost × RoleMultiplier × TierMultiplier

Upkeep =
BaseUpkeep × ArmySizeFactor

ReinforceCost =
RecruitCost × ReinforcementFactor

Do not tie combat power to Robux.

## Visual requirements

Each army must visibly communicate:
- role;
- banner;
- formation;
- strength;
- current order.

Soldiers must be recognizable as individual units while remaining performant.

## Definition of Done

- individual soldier state exists;
- army aggregates soldier state;
- morale and fatigue affect behavior;
- recruitment changes visible formation size;
- reinforcement visibly adds soldiers;
- retreat visibly removes soldiers from danger;
- army selection UX reads the complete state.
