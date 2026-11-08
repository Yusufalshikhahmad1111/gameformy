# Stage 9 — World Map Art & Castle Content
## Execution Specification

### 1. Purpose

Stage 8 made the world-map architecture data-driven. Stage 9 turns that architecture into a **coherent, handcrafted, premium playable world**.

The target is not “add more decorative parts.” The target is:

> Every map must immediately communicate where the player is, what each castle means, where armies should travel, and which territory belongs to whom.

Stage 9 is the **art/content production layer** on top of the existing map graph.

Do not rewrite the combat model, economy rules, matchmaking architecture, or world-map registry unless a small compatibility change is strictly required.

---

## 2. Design North Star

The game should read like a premium tabletop/medieval strategy diorama brought into a real-time multiplayer battlefield.

Visual hierarchy:

1. Castle / current objective
2. Army and route
3. Territory ownership
4. Terrain and landmarks
5. Decorative detail

A player zoomed out must still understand:

- where the important castles are;
- which team owns them;
- where roads lead;
- where the river or terrain blocks movement;
- which direction the battle is developing.

Art must improve readability, not compete with gameplay.

---

## 3. World Art Architecture

Implement a reusable **World Art Kit** rather than unique unstructured geometry.

### Core modular pieces

Create/reuse modular pieces for:

- castle wall;
- gatehouse;
- gate;
- watch tower;
- corner tower;
- courtyard;
- bridge;
- stair;
- battlement;
- banner pole;
- team banner;
- road segment;
- road junction;
- stone path;
- wooden fence;
- market/yard prop;
- trees;
- rocks;
- terrain decals;
- river bank;
- small bridge;
- city sign;
- neutral marker;
- capture marker.

The castle system must allow one kit to generate many visually different castles.

Do not duplicate giant models for every city when a modular kit can accomplish the same result.

---

## 4. Castle Language

### 4.1 Castle tiers

Every map should support:

**Capital**
- larger silhouette;
- stronger walls;
- more towers;
- prominent banner;
- unique landmark element;
- higher visual importance.

**Major city**
- medium fortress;
- one dominant gate;
- 2–4 supporting towers/structures.

**Regional castle**
- compact fortress;
- one gate complex;
- small courtyard;
- readable from the strategic camera.

### 4.2 Gameplay readability

Every castle must visibly communicate:

- entrance/capture approaches;
- ownership;
- current capture state;
- strategic importance.

Do not hide capture gates behind decoration.

---

## 5. Regional Visual Profiles

Each map gets a controlled visual identity.

### Syria

Visual vocabulary:
- warm limestone/plaster;
- dry Mediterranean/Levantine earth;
- olive/cypress vegetation;
- stone roads;
- dry hills;
- restrained blue/green water;
- Syrian/Levantine architectural cues without reproducing protected real-world buildings 1:1.

Palette logic:
- warm stone;
- dusty earth;
- olive greens;
- muted cloth.

### Saudi Arabia

Visual vocabulary:
- arid desert terrain;
- sandstone;
- dunes/rock formations;
- palm clusters;
- fortified urban compounds;
- long dry roads;
- sparse vegetation.

Use terrain variation so the map does not become a flat yellow plane.

### Palestine

Visual vocabulary:
- Mediterranean stone;
- terraced hills;
- olive trees;
- dry grass;
- dense settlement clusters;
- limestone fort/castle language.

Avoid turning the visual identity into a political symbol set. Keep it a strategic geography presentation.

### Europe

Europe is the largest content challenge.

Use a **broad stylized European medieval language**, then apply regional accents through:

- roof shapes;
- stone colors;
- vegetation;
- terrain;
- towers;
- banners;
- city silhouettes.

Do not attempt literal 1:1 architectural simulation of sixteen countries inside the first production pass.

---

## 6. City Identity

Every map node should receive:

- city name;
- province/region name;
- castle tier;
- banner;
- small landmark;
- terrain context;
- visual color/material accent where appropriate.

City identity should be visible both:

1. in-world;
2. in the strategic map.

Use the current MapService node IDs as the source of truth.

Do not create a second incompatible city database.

---

## 7. Roads, Rivers and Strategic Geography

Roads must communicate the same graph used by MapService.

Rule:

**Map graph = gameplay graph = strategic visual graph**

Every important MapService edge should have a corresponding visual route.

Roads should:

- have readable intersections;
- avoid awkward clipping through castles;
- provide visual direction;
- remain wider than decorative paths;
- use terrain bends where possible.

Rivers should:

- visually explain movement constraints;
- have obvious crossing points;
- avoid blocking castle capture spaces;
- remain visually readable from the tactical camera.

Do not add purely decorative roads that imply a route which does not exist in gameplay.

---

## 8. Terrain System

Create reusable terrain families:

- plains;
- dry grass;
- rocky ground;
- hill;
- mountain edge;
- riverbank;
- urban/castle ground.

Terrain must support large-scale readability first.

Avoid:

- noisy micro-detail everywhere;
- excessive grass clutter around armies;
- strong color variation that hides units;
- decorative objects inside movement-critical spaces.

---

## 9. Team Heraldry

Team identity belongs primarily to:

- banners;
- pennants;
- capture markers;
- subtle trim;
- UI;
- VFX.

Do not repaint entire castles in team colors.

Use the existing four-team identities:

- Crimson
- Azure
- Emerald
- Amber

The same color must communicate the same owner everywhere.

---

## 10. Map Selection Presentation

Upgrade the Stage 8 map selector into a premium **World Map Selection** experience.

For each map show:

- map name;
- region;
- castle count;
- recommended team count;
- short strategic description;
- visual preview;
- difficulty/complexity descriptor;
- confirmation state.

Interaction flow:

Map → Team Count → Preview → Confirm → Queue

Do not hide the current selection.

The player should always know what battlefield they are entering.

---

## 11. Tactical Minimap Art

The Stage 8 minimap becomes a presentation system.

Add:

- cleaner road rendering;
- stronger castle hierarchy;
- capital iconography;
- player army marker;
- teammate army markers where available;
- objective marker;
- capture/contested indicator;
- territory grouping;
- readable labels;
- selected-castle emphasis.

Minimap rules:

- owner color is obvious;
- neutral is visually distinct;
- current objective wins attention;
- roads remain visible under territory colors;
- labels do not cover critical nodes.

---

## 12. Camera and Composition

Review the strategic camera so the world reads as a coherent diorama.

Target:

- enough height to understand territory;
- enough proximity to read castles;
- smooth focus on selected army/objective;
- no violent camera jumps;
- sensible zoom limits;
- mobile-safe framing.

Camera movement should reinforce tactical decisions.

---

## 13. Lighting

Use one controlled lighting profile.

Must support:

- castle readability;
- team banners;
- terrain separation;
- night/dark mode only if explicitly designed later.

Avoid:

- per-object fake glow;
- bloom hiding silhouettes;
- excessive fog;
- high-contrast lighting that changes team colors.

---

## 14. Performance Rules

Art cannot destroy multiplayer performance.

Apply:

- modular reuse;
- anchored/static geometry where possible;
- sensible collision groups;
- low-cost decorative props;
- distance-based detail;
- limited particles;
- object pooling where runtime objects repeat;
- StreamingEnabled compatibility for large maps.

Europe is the stress case.

Performance targets:

- no major frame-time spike when entering a dense castle;
- no mass replication of decorative objects;
- army readability maintained with many units;
- minimap update rate separated from high-frequency combat state where appropriate.

---

## 15. Production Order

Execute in this order:

### Phase A — Art foundation
1. inspect current Stage 3 castle/terrain code;
2. inspect all existing generated world objects;
3. identify what can be reused;
4. establish modular castle pieces;
5. establish reusable material vocabulary.

### Phase B — Hero quality
6. produce one excellent capital castle;
7. produce one major city castle;
8. produce one regional castle;
9. establish the final visual language.

### Phase C — Map kits
10. Syria art pass;
11. Saudi Arabia art pass;
12. Palestine art pass;
13. Europe art pass.

### Phase D — Strategic readability
14. roads;
15. rivers/crossings;
16. city labels;
17. banners;
18. ownership markers;
19. minimap polish.

### Phase E — Presentation
20. map selection screen;
21. camera framing;
22. lighting;
23. VFX polish;
24. mobile-safe composition.

### Phase F — Performance and QA
25. dense-castle test;
26. large-map test;
27. multi-army test;
28. mobile UI/render test;
29. streaming test;
30. visual consistency audit.

---

## 16. Do Not

Do not:

- replace the world with a giant imported map asset;
- use copyrighted real-world game assets;
- copy another game's exact UI/map/art;
- turn team colors into full-building paint;
- add decorative roads that imply fake gameplay routes;
- rebuild the MapService graph inside art scripts;
- hardcode castle ownership in visual code;
- add effects that obscure armies;
- sacrifice performance for decoration;
- introduce random fantasy assets that break the art language.

---

## 17. Definition of Done

Stage 9 is complete only when:

### Content
- [ ] all four map packs have a coherent visual identity;
- [ ] capital/major/regional castle tiers exist;
- [ ] cities visibly match MapService nodes;
- [ ] roads correspond to gameplay edges;
- [ ] rivers/crossings are readable;
- [ ] banners use the four team identities.

### Presentation
- [ ] map selection looks like a real game screen;
- [ ] minimap is readable at a glance;
- [ ] current objective is visually dominant;
- [ ] camera composition supports the battlefield;
- [ ] lighting is consistent.

### Technical
- [ ] no duplicate world-state authority was introduced;
- [ ] art reads data from MapService/Config;
- [ ] large map does not produce obvious performance regressions;
- [ ] static and runtime objects are separated cleanly.

### QA
- [ ] Studio visual test on every map;
- [ ] test 2/3/4-team colors;
- [ ] test neutral/owned/contested castle states;
- [ ] test mobile aspect ratios;
- [ ] test zoom levels;
- [ ] test dense army scenes.

---

## 18. Handoff Rule

When Stage 9 is executed:

1. inspect the existing repository before modifying it;
2. reuse working systems;
3. implement the stage end-to-end;
4. test/fix what can be tested;
5. report exactly what was verified;
6. stop at Stage 9.

Do not start Stage 10 automatically.

Stage 10 is a separate UX/UI overhaul and must be implemented only when explicitly requested.
