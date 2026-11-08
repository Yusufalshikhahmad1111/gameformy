# Kingdoms Conquest — Next Generation Development Roadmap
Date: 2026-11-08

## 0. Why this roadmap exists

The current project has the right core idea, but the next leap must not be another collection of isolated features.

The game is being reshaped around one promise:

> The player is the commander. Armies are visible, individual, controllable and dangerous; territory funds war; UI explains the battlefield instead of covering it; and the world looks like a deliberate premium strategy diorama.

The study document establishes the order of priorities:
- stabilize the current code before adding more features;
- move capture/combat responsibility from the player body to armies;
- add automatic combat, meaningful formations, commander bots and stronger castle warfare;
- expand the maps and terrain before decorative detail;
- make mobile-first UX and a contextual HUD the primary interface;
- treat 3D art and world readability as production work, not decoration. fileciteturn90file0L27-L46 fileciteturn90file0L65-L97 fileciteturn90file0L127-L145 fileciteturn90file0L147-L166

## 1. Product north star

### Commander fantasy

The player:
- owns a territory and economy;
- recruits armies with earned in-game resources;
- selects individual armies;
- chooses formation and order;
- watches soldiers fight, retreat and recover;
- captures castles through army presence;
- responds to enemy commanders and bots;
- wins through territory control or capital pressure.

The player character is an observer/commander, not the main source of combat damage.

### Match target

Launch baseline:
- 10–16 minute matches;
- short time to first meaningful action;
- visible territory changes;
- 2-team vertical slice first;
- bots fill empty commander slots.

The GDD already defines Move / Attack / Hold / Follow / Retreat and Line / Wedge / Column / Spread as the core order/formation vocabulary. Preserve that vocabulary while making the implementation real. fileciteturn90file0L71-L95

## 2. Development principles

1. One authoritative source of truth per system.
2. Every stage ends with a playable Studio build.
3. No stage is “done” from code review alone.
4. Every new system gets tests, runtime probes, and a visual QA pass.
5. UI never becomes authoritative for gameplay.
6. Art reads from MapService/Config and never creates a second gameplay graph.
7. Do not add content until the previous stage's core loop is playable.
8. Mobile is a first-class target.
9. 3D assets must improve readability and hierarchy.
10. Reuse existing working systems before replacing them.

## 3. Stage sequence

### Stage 11 — Stabilization & Architecture
Goal:
Create a safe production baseline before deeper gameplay work.

Deliver:
- split the monolithic gameplay script into MatchService, ArmyService, CaptureService, EconomyService and WorldBuilder responsibilities;
- establish one Network/Remotes contract;
- add Luau linting/static checks;
- add unit/integration tests for MapService, RateLimiter, capture, economy and combat primitives;
- add Studio smoke test checklist and runtime diagnostics;
- define data schemas for Army, Soldier, Province, Match and PlayerEconomy;
- make lobby and battlefield lifecycle explicit.

Exit:
- clean build;
- no duplicate state authority;
- deterministic startup;
- automated checks run on every push;
- match can start/end repeatedly in Studio.

### Stage 12 — Army System 2.0
Goal:
Make armies the primary gameplay object.

Deliver:
- Army entity with composition, formation, order, position, target and logistics state;
- individual Soldier entities inside each army;
- soldier stats: Power, Defense, Range, Speed, Health, Accuracy, Morale, Experience, Fatigue;
- deterministic personality seed per soldier;
- clear role archetypes: Spearmen, Archers, Cavalry;
- individual soldier health and morale aggregation;
- recruit, reinforce, dismiss and retreat;
- army card with composition and state;
- visible formation shapes with readable silhouettes.

New rule:
In-game Gold/Supplies, not Robux, controls recruitment volume. More earned resources can produce more soldiers, while upkeep and logistics prevent unlimited spam.

Exit:
- soldiers visually move as a formation;
- each soldier has measurable stats;
- morale changes behavior;
- recruiting and reinforcing changes the visible army.

### Stage 13 — Combat, Ranged Warfare & Castle Assault
Goal:
Turn movement into actual warfare.

Deliver:
- automatic attack acquisition;
- melee engagement;
- ranged targeting and projectile/trace feedback;
- hit chance and damage calculation;
- target priorities;
- attack cooldowns;
- formation modifiers;
- terrain modifiers;
- retreat threshold;
- casualty handling;
- castle garrison;
- wall/entry pressure;
- capture progress driven by army presence;
- defender/attacker states;
- combat feedback readable at zoomed-out distance.

Formation design:
- Line = balanced frontline;
- Wedge = stronger breakthrough/first-contact pressure;
- Column = movement and reduced ranged exposure;
- Spread = less ranged splash/vulnerability;
- terrain and morale modify the base values.

Use the study's numbers as initial tuning points, not permanent balance. fileciteturn90file0L80-L88 fileciteturn90file0L123-L124

Exit:
- two armies can fight without player avatar damage;
- archers visibly shoot;
- soldiers visibly lose strength and retreat;
- castles can be assaulted and defended;
- all combat outcomes are explainable in state/UI.

### Stage 14 — Commander Bots & Match Population
Goal:
Make every match fun with one player or a small group.

Deliver:
- Bot Commander entity;
- recruit logic;
- objective selection;
- threat assessment;
- army routing;
- defend/attack/retreat behavior;
- capital-defense priority;
- reinforcement logic;
- fallback behavior after commander death;
- difficulty profiles: Recruit, Veteran, Warlord;
- bot fill policy for empty team slots.

Bot decision loop:
1. evaluate economy;
2. evaluate owned/neutral/enemy provinces;
3. identify the highest-value reachable objective;
4. create/reinforce an army;
5. choose formation;
6. move;
7. engage;
8. retreat/reinforce;
9. reassess.

Exit:
- 1 human can start a meaningful match;
- bots do not suicide repeatedly into the same objective;
- bots create visible pressure on the map.

The study explicitly identifies commander bots as P1 so a new match can function without a full player population. fileciteturn90file0L93-L95

### Stage 15 — Economy, Recruitment & Progression
Goal:
Make territory and money create a strategic loop.

Economy layers:
- Supplies = tactical army resource;
- Gold = recruitment/upkeep economy;
- XP = commander progression;
- Season XP = meta progression.

Rules:
- castles generate income;
- connected territory generates more reliable income;
- isolated territory has reduced income;
- army upkeep scales with size;
- recruitment cost scales by troop role;
- reinforcement is cheaper than rebuilding a full army;
- losing territory hurts economy but never hard-locks recovery;
- losing teams get controlled reinforcement discounts.

Soldier economy:
- each soldier has recruit cost;
- each soldier has upkeep;
- stronger soldiers cost more;
- higher-morale veterans are valuable;
- morale recovery costs time/resources, not instant UI healing.

Do not turn progression into pay-to-win.

Exit:
- player can clearly answer “why can I afford this army?”;
- every new soldier changes economy;
- territory ownership visibly changes income;
- comeback is possible without fake damage multipliers.

The product vision explicitly rejects invisible economy rules and pay-to-win power. fileciteturn90file0L20-L24 fileciteturn90file0L14-L18

### Stage 16 — World 2.0 + 3D Art Production
Goal:
Make the battlefield look like a premium strategy world before adding more systems.

Priority order:
1. one hero Capital castle;
2. one Major castle;
3. one Regional castle;
4. final material palette;
5. roads and crossings;
6. terrain families;
7. regional props;
8. banners/heraldry;
9. city landmarks;
10. distant-detail variants.

Map rules:
- minimum spacing between major nodes;
- readable gates;
- spawn beside player's starting castle;
- no castle overlap;
- no fake roads;
- terrain influences combat;
- streaming/performance considered from the beginning.

Create three tiers:
- Capital;
- Major;
- Regional.

Create three quality layers:
- Hero detail;
- Gameplay detail;
- Distance detail.

The study explicitly recommends larger maps, real terrain instead of flat floors, handcrafted castle tiers and lower-detail distant assets. fileciteturn90file0L127-L145

Decision gate:
The current real-world regional naming is a production-risk decision. The study recommends fictional realms inspired by geography to preserve the regional feel while reducing platform sensitivity. Treat this as a deliberate product/legal/design decision before publishing the final map set. fileciteturn90file0L20-L24

Exit:
- every map has a strong visual identity;
- castles are recognizable without UI;
- soldiers are readable against terrain;
- no castle/gate geometry is merely a graybox placeholder.

### Stage 17 — UX/UI 2.0 + Mobile-First Command Center
Goal:
Turn the UI into a command system instead of a collection of panels.

Persistent zones:
- top: timer / score / supplies;
- top-right: tactical map;
- bottom-center: selected army commands;
- bottom-left: army/economy summary;
- contextual: castle, warning, route, reinforcement panels.

Army bar:
- one card per army;
- health;
- morale;
- formation;
- order;
- role icons;
- quick select.

Command model:
- Select army;
- Move;
- Attack;
- Hold;
- Follow;
- Retreat;
- Formation.

Contextual actions:
- castle selected -> capture/defend/inspect;
- enemy army selected -> attack/focus/retreat;
- route blocked -> reroute.

Mobile:
- large touch targets;
- tap army;
- tap destination;
- tap enemy;
- tap castle;
- drag/pinch tactical map;
- long press contextual information;
- full-screen strategic map when opened.

Onboarding:
- select army;
- send army;
- capture castle;
- receive income;
- choose formation;
- react to enemy.

Arabic:
- RTL;
- localization layer;
- mirrored layout where appropriate;
- no hardcoded player-facing strings.

Stage 10 already contains the detailed UX architecture and screen-by-screen contract; this stage implements that contract around the new army/economy model rather than inventing a second UI system. fileciteturn90file0L147-L166

Exit:
- new player understands the first action without external explanation;
- mobile play is not a desktop shrink;
- no panel collisions;
- every important action produces immediate readable feedback.

### Stage 18 — Presentation, Audio, VFX & Character Personality
Goal:
Create the “feel” that makes the game memorable.

Soldier personality:
- Morale reacts to wins/losses;
- veteran experience affects confidence;
- fatigue reduces effectiveness;
- bravery affects retreat threshold;
- discipline affects formation cohesion;
- aggression affects target selection;
- loyalty affects regroup speed.

Important:
Personality values must be subtle modifiers, not random chaos.

Presentation:
- army banners;
- marching dust;
- ranged projectile trails;
- shield impact;
- formation movement;
- castle capture pulse;
- territory color transition;
- combat hit feedback;
- victory/defeat presentation;
- restrained camera emphasis.

Audio:
- selection;
- command;
- bow release;
- melee impact;
- castle contested;
- castle captured;
- army destroyed;
- victory/defeat.

Exit:
- a screenshot should communicate army ownership and battle state without reading a debug panel;
- combat feels alive without visual noise.

### Stage 19 — Balance Simulation, Performance & Visual QA
Goal:
Stop balancing by intuition alone.

Deliver:
- deterministic combat simulation;
- economy simulation;
- army matchup matrix;
- formation comparison;
- bot-vs-bot simulations;
- stress tests with many soldiers;
- mobile performance checks;
- streaming checks;
- visual regression checklist;
- UX playtest scripts.

Track:
- time to first command;
- time to first capture;
- first enemy contact;
- average army lifetime;
- retreat rate;
- castle turnover;
- resource income;
- rematch rate;
- onboarding abandonment.

Every balance number remains tunable.

The study explicitly calls for balance simulation and playtesting rather than treating initial numbers as final. fileciteturn90file0L120-L124

Exit:
- no dominant army/formation;
- no runaway economy;
- bots remain competitive without feeling unfair;
- no major mobile performance collapse;
- no critical UX confusion.

### Stage 20 — Release Candidate & Live Operations
Goal:
Produce the first real launch candidate.

Deliver:
- final rules lock;
- final art lock for launch maps;
- production persistence;
- reconnect handling;
- match recovery;
- results/rewards;
- season progression;
- analytics;
- moderation/safety review;
- device matrix;
- launch checklist;
- rollback plan.

Exit:
- repeatable match lifecycle;
- stable data;
- acceptable device performance;
- no major critical gameplay bugs;
- documented launch build.

## 4. Global stage gate

Every stage must publish:
- implementation summary;
- files changed;
- automated test result;
- Studio smoke test result;
- known limitations;
- 3–5 screenshots;
- next-stage dependencies.

A stage is not complete only because code compiles.

## 5. Dependency graph

Stage 11
  ↓
Stage 12 ─────┐
  ↓           │
Stage 13 ←────┘
  ↓
Stage 14
  ↓
Stage 15
  ↓
Stage 16 ─────┐
  ↓           │
Stage 17 ←────┘
  ↓
Stage 18
  ↓
Stage 19
  ↓
Stage 20

Gameplay-critical path:
11 → 12 → 13 → 14 → 15

Presentation-critical path:
11 → 16 → 17 → 18

Release path:
13 + 15 + 17 + 18 → 19 → 20

## 6. Non-negotiable priorities

P0:
- runtime stability;
- army authority;
- combat readability;
- capture logic;
- bots;
- mobile command usability.

P1:
- economy depth;
- hero castle art;
- map scale;
- formations;
- ranged warfare.

P2:
- personality depth;
- advanced abilities;
- additional troop classes;
- fog of war;
- larger content library.

## 7. What this roadmap intentionally prevents

- adding more maps before the core army loop is fun;
- adding more UI panels to solve missing gameplay feedback;
- generating more graybox castles instead of producing hero assets;
- adding bot labels without bot decision quality;
- adding resources without clear economic purpose;
- implementing “personality” as cosmetic random numbers;
- changing combat values without simulation;
- calling a stage complete without a Studio runtime gate.
