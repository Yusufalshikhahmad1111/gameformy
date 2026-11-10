# Stage 12 — Army & Soldier System 2.0 Implementation Report

Date: 2026-11-10

## Status

**IMPLEMENTED — code/repository gate complete; Roblox Studio runtime gate pending.**

Stage 12 changes the game from:
`Army = one health number + eight fixed visual parts`

to:
`Army = stateful formation + individual Soldier entities + aggregate combat state`.

## Implemented

### Individual soldiers

Every recruited soldier now has:
- Id
- ArmyId
- Role
- Level
- Health / MaxHealth
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

Individual stats receive small deterministic variance from a per-soldier seed so soldiers are not identical clones.

### Army aggregation

Army state now derives from its living soldiers:
- SoldierCount
- Health / MaxHealth
- Power
- Defense
- Morale
- Fatigue
- Experience

This means casualties change the actual formation size and the army's effective strength.

### Recruitment economy

Recruitment now uses per-soldier cost.

Default initial batch:
- Spearmen: 4 soldiers, 5 Supplies per soldier
- Archers: 4 soldiers, 6 Supplies per soldier
- Cavalry: 4 soldiers, 8 Supplies per soldier

A new army purchases the largest initial batch affordable up to its configured initial size.

After the army exists:
- `RecruitSoldier` adds exactly one soldier;
- the soldier costs the role's per-soldier price;
- army size is capped by MaxSoldiers.

This makes military size directly dependent on earned in-game resources.

### Visible formations

The old eight-fixed-piece army visual has been replaced with individual soldier models.

Each visible soldier:
- has a role-specific silhouette;
- carries role equipment;
- has its own health bar;
- inherits the army owner color;
- occupies a formation slot.

Implemented formations:
- Line
- Wedge
- Column
- Spread

Formation spacing is calculated from the actual soldier count.

### Casualties

Combat damage is now resolved against individual soldiers.

A hit:
1. selects a living defender;
2. applies damage to that soldier;
3. can kill that individual;
4. changes the defender's morale;
5. increases attacker experience;
6. increases attacker fatigue;
7. rebuilds the visible formation when a casualty occurs.

When all soldiers die, the army is removed.

### Fatigue and recovery

Moving/engaging armies accumulate fatigue.

Idle armies recover:
- fatigue;
- morale.

Fatigue and morale now influence:
- movement speed;
- attack cooldown;
- effective combat power.

### HUD

The existing HUD now exposes for the selected army:
- soldier count;
- HP;
- morale;
- fatigue;
- power;
- formation;
- current order.

Recruit buttons now show per-soldier cost.

When the selected army matches the clicked troop type, clicking the troop button recruits one additional soldier instead of silently creating another identical army.

### Architecture

Added/extended:
- `SoldierService.lua`
- `ArmyService.lua`
- `StateSchemas.lua`
- `Config.lua`
- `KingdomsConquestStage1.server.lua`
- `KingdomsConquestHUD.client.lua`

Added:
- `Stage12ArmySystem.server.lua`

## Intentionally deferred to Stage 13

Stage 12 does not pretend to be the complete warfare system.

Still scheduled for Stage 13:
- true ranged projectile behavior;
- ranged target priority;
- terrain combat modifiers;
- siege/garrison logic;
- castle assault states;
- advanced combat resolution;
- retreat thresholds and combat disengagement rules.

Still scheduled later:
- Bot commanders: Stage 14
- Economy expansion: Stage 15
- final 3D art: Stage 16
- full UX overhaul: Stage 17
- deeper personality behavior/audio/VFX: Stage 18

## Verification

Repository inspection confirms:
- Stage 12 service files exist;
- Config contains per-soldier costs and caps;
- command schema accepts `RecruitSoldier`;
- army state contains soldier aggregates;
- HUD consumes the new army state;
- no TODO/FIXME markers were introduced in the Stage 12 files.

Roblox Studio execution was not available in this turn, so:
- actual Rojo build;
- Studio runtime;
- physical collision;
- visual quality;
- mobile rendering

remain to be verified when the project is opened locally.

## Exit gate

Stage 12 should be considered fully closed after:
1. clean Rojo build;
2. match starts;
3. first army spawns with multiple visible soldiers;
4. purchasing one soldier increases formation size by one;
5. a casualty removes exactly one visible soldier;
6. morale/fatigue change visibly in the selected-army panel;
7. formation switching works with variable soldier counts.
