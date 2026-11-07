# 02 — Gameplay GDD

## Match structure
Recommended launch baseline:
- 2 teams: 6–8 players total.
- 3 teams: 9–12 players total.
- 4 teams: 12–16 players total.
Start with 2 teams for vertical slice.

## Province
Each province has:
- owner;
- castle;
- gates: North/East/South/West;
- income value;
- terrain tags;
- spawn/reinforcement location;
- visual heraldry.

## Castle capture
1. Enter one of four gate approaches.
2. Enter capture zone.
3. Capture progress runs for 10 seconds while uncontested.
4. If an enemy enters, progress pauses.
5. If defenders clear the zone, progress slowly decays rather than instantly resetting.
6. On completion, ownership changes.
7. Castle banner/map province changes color.
8. Owner begins receiving income after a short stabilization delay.

This is intentionally better than a hard reset: it rewards successful defense while avoiding repetitive frustration.

## Army
An army is a formation controlled by a commander.
MVP troop classes:
- Spearmen — anti-cavalry / frontline hold.
- Archers — ranged pressure / anti-light.
- Cavalry — mobility / flank / anti-archer.

Use a readable counter triangle but allow terrain and formation to matter enough that composition alone never decides a fight.

## Orders
MVP:
- Move
- Attack
- Hold
- Follow
- Retreat

Formation presets:
- Line
- Wedge
- Column
- Spread

Advanced phase:
- Focus target
- Guard point
- Charge
- Volley
- Regroup

## Victory
Primary MVP rule:
**Reach the required territory-control score OR capture the enemy capital.**

Avoid pure 100% map domination because it can create long cleanup phases.

Suggested score:
- normal province = 1
- strategic province = 2
- capital = 4
Win at 60–70% control or capital capture.

## Comeback design
- Losing team receives slightly cheaper reinforcement logistics.
- Neutral provinces should create alternative routes.
- Spawn distance should favor the losing side modestly.
- No raw damage multiplier comeback; it feels unfair.

## Commander death
A commander may be defeated but should respawn quickly enough to preserve match tempo. The army remains under a fallback AI order for a short period.

## Camera
Default:
third-person commander camera.
Optional tactical zoom:
camera pulls back and shows formation order indicators.
Never make the game require an RTS-only camera.