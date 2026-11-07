# 06 — Economy and Balance

## MVP economy
Use one primary resource: **War Supplies**.

Castle income:
- home castle: 8/min
- normal province: 5/min
- strategic province: 8/min
- capital: 12/min

These are starting values for simulation, not final truth.

## Army costs
Example:
- spearmen squad: 20
- archers squad: 24
- cavalry squad: 30

Reinforcement cost scales with losses.

## Economic rule
The strongest territory should provide advantage, not certainty.

Target:
- leading team: ~15–25% economic advantage;
- losing team: still able to fund a counterattack.

## Snowball controls
1. diminishing returns above 60% control;
2. reinforcement efficiency for the losing side;
3. high-value neutral routes;
4. capital capture as an alternate win path;
5. no compounding upgrade tree during MVP.

## Balance formula
Track:
`income advantage → army availability → territory advantage → win probability`

A territory that produces 2x income should not produce 2x win probability.

## Simulation tests
Run 1000 simulated matches per mode with bots.

Track:
- first capture team;
- final control;
- comeback rate;
- average army size;
- match duration;
- resource starvation;
- stalemate frequency.

## Balance acceptance
Do not tune by feeling alone.
A balance change should state:
- problem;
- hypothesis;
- variable;
- expected result;
- observed result.