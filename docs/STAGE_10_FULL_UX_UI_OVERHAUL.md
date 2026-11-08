# Stage 10 — Full UX/UI Interaction Overhaul
## Execution Specification

### 1. Purpose

Stage 10 is a complete UX/UI audit and redesign of Kingdoms Conquest.

The objective is not to “make the UI prettier.”

The objective is:

> Make the entire game easier to understand, faster to control, more interactive, more satisfying, and more readable on both desktop and mobile.

The battlefield remains the primary experience. UI must explain the battlefield rather than cover it.

Stage 10 may restructure existing UI systems, but it must not silently change core combat/economy/match rules.

---

## 2. UX North Star

A new player should be able to:

1. enter a match;
2. understand what their army is;
3. move it;
4. identify a target;
5. capture a castle;
6. understand why capture succeeds/fails;
7. understand what resources are doing;
8. make another meaningful decision;

without reading a large manual.

The interface must teach through interaction.

---

## 3. Full Player Journey Audit

Audit the complete funnel:

**Launch → Lobby → Map Selection → Team Selection → Party → Queue → Match Loading → Spawn → First Command → First Capture → First Enemy Contact → Castle Defense → Victory/Defeat → Results → Rewards → Rematch/Profile**

For every step document:

- player goal;
- available actions;
- current information;
- missing information;
- confusion risks;
- feedback;
- error state;
- mobile behavior;
- accessibility/localization behavior.

Do not redesign isolated screens without checking the full journey.

---

## 4. Information Architecture

Use four information tiers.

### Tier 1 — Immediate battlefield
- current objective;
- army location;
- enemy threat;
- capture state.

### Tier 2 — Tactical
- selected army;
- formation;
- order;
- nearby castle;
- route;
- teammate status.

### Tier 3 — Strategic
- territory;
- income;
- resources;
- map;
- team score.

### Tier 4 — Meta
- profile;
- progression;
- season;
- achievements;
- settings.

Tier 4 should never compete visually with Tier 1.

---

## 5. New HUD Model

Replace the current “many permanent panels” approach with a **contextual HUD**.

Persistent:

Top:
- team control;
- timer;
- match state;
- high-level objective.

Right/top-right:
- compact tactical map.

Bottom-center:
- selected army controls.

Bottom-left:
- supplies/army summary.

Contextual:
- castle card;
- enemy warning;
- capture state;
- route information;
- reinforcement information.

A contextual panel only appears when relevant.

---

## 6. Army Interaction Model

Army selection should feel responsive.

When the player selects an army:

Show:

- selected outline;
- army banner;
- unit composition;
- formation;
- health/readiness;
- current order;
- destination;
- attack state.

The command bar should adapt to the selected army.

Example:

Move mode:
- Move
- Waypoint
- Hold
- Cancel

Enemy selected:
- Attack
- Focus
- Hold Position
- Retreat

Castle selected:
- Capture/Assault information
- Defend
- Move
- View territory

Do not display ten irrelevant buttons.

---

## 7. Interaction Feedback

Every meaningful action needs immediate feedback.

### Command feedback

On Move:
- route marker;
- destination marker;
- brief confirmation.

On Attack:
- target highlight;
- attack indicator;
- acknowledgement.

On Hold:
- defensive marker.

On Formation:
- formation preview;
- confirmation;
- readable icon.

On invalid action:
- explain why;
- never silently fail.

---

## 8. Castle Interaction

Castle interaction becomes one of the strongest UI moments.

When entering/selecting a castle, show:

- city name;
- owner;
- capital/major/regional tier;
- capture progress;
- contested state;
- income;
- nearby threat;
- your connection to the castle.

During capture:

- progress ring/bar;
- countdown;
- attacker/defender indicator;
- contested indicator;
- capture acceleration/deceleration;
- clear explanation of what stops progress.

When captured:

- banner animation;
- territory pulse;
- sound/VFX;
- income notification;
- strategic map update.

Avoid generic “+50 XP” popup as the only feedback.

The player should understand the strategic consequence.

---

## 9. Strategic Map Interaction

The minimap becomes interactive.

Allow:

- click/tap castle;
- focus camera on castle;
- inspect owner;
- inspect income;
- inspect objective;
- select route destination;
- show teammate location;
- show army location;
- show contested areas.

Map interactions must never lock the player out of the battlefield unnecessarily.

Mobile should use a full-screen map overlay rather than shrinking the battlefield into a tiny viewport.

---

## 10. Mobile UX

Mobile is not desktop squeezed into a smaller screen.

Design a dedicated mobile control layer.

### Bottom controls

Primary:
- Move
- Attack
- Hold
- Formation
- Map

Secondary actions appear contextually.

### Touch behavior

Support:

- tap army to select;
- tap destination to move;
- tap enemy to attack;
- tap castle to inspect;
- drag map;
- pinch zoom where appropriate;
- long press for contextual information where it adds value.

Prevent accidental actions.

Use generous touch targets.

---

## 11. Desktop UX

Desktop should exploit:

- mouse hover;
- click selection;
- keyboard shortcuts;
- tooltips;
- richer information density.

Suggested shortcuts:

- M = Move
- A = Attack
- H = Hold
- 1 = Line
- 2 = Wedge
- 3 = Spread
- Tab = strategic map
- Esc = cancel contextual mode

Keyboard shortcuts must not be required for basic play.

---

## 12. Onboarding Redesign

Replace passive tutorial text with **guided micro-objectives**.

First match:

### Lesson 1
“Select your army.”

### Lesson 2
“Move to the highlighted castle.”

### Lesson 3
“Hold the gate until capture completes.”

### Lesson 4
“Your castle generates supplies.”

### Lesson 5
“Choose a formation.”

### Lesson 6
“Respond to the enemy route.”

Each lesson should:

- highlight the relevant object;
- show one short instruction;
- wait for player action;
- reward completion;
- disappear after mastery.

Never block the player with a long tutorial wall of text.

---

## 13. Feedback Systems

Create a unified feedback layer.

Types:

### Micro feedback
- click;
- selection;
- hover;
- command acknowledged.

### Tactical feedback
- enemy spotted;
- castle contested;
- route blocked;
- army under attack.

### Strategic feedback
- castle captured;
- income changed;
- victory threshold reached;
- enemy controls critical region.

### Meta feedback
- XP earned;
- season progress;
- achievement;
- reward.

Each type needs a different visual/audio weight.

Do not make everything a toast notification.

---

## 14. Alerts and Notification Discipline

Notifications must have priority.

Priority 1:
- imminent defeat;
- base/capital under threat;
- victory condition;
- army destroyed.

Priority 2:
- castle contested;
- major capture;
- enemy army approaching.

Priority 3:
- XP;
- reward;
- minor progression.

Rules:

- priority 1 interrupts;
- priority 2 stays visible but does not obstruct;
- priority 3 can be subtle.

Prevent notification stacking.

---

## 15. Loading and Transition UX

Create explicit states for:

- loading;
- connecting;
- matchmaking;
- teleporting;
- reconnecting;
- preparing battlefield;
- match active;
- match ending.

Never leave the player staring at a frozen interface with no explanation.

If something fails:

- state what failed;
- show recovery action;
- preserve the player party when possible.

---

## 16. Lobby UX

The lobby must answer three questions immediately:

1. What map am I playing?
2. Which team/mode am I joining?
3. Who am I playing with?

Improve:

- map preview;
- map description;
- team count;
- party code;
- party members;
- queue state;
- cancel state;
- matchmaking feedback.

The selected map and team mode must remain visible until the match starts.

---

## 17. Results Screen

After match:

Show:

- Victory/Defeat;
- winning team;
- territories captured;
- major battles;
- army performance;
- resources generated;
- XP;
- season progress;
- achievements unlocked;
- next reward progress.

Then offer:

**Rematch**

and

**Return to World/Lobby**

The result should explain why the team won, not only announce the winner.

---

## 18. Profile and Progression UX

Profile should be a separate information layer.

Show:

- level;
- XP;
- season;
- season rewards;
- achievements;
- wins/losses;
- favorite unit;
- map performance.

Use charts sparingly.

Do not overload the match HUD with profile information.

---

## 19. Visual Interaction Language

Define one interaction language.

### Selected
Strong outline + subtle glow.

### Hover
Small elevation/color shift.

### Pressed
Immediate compression/feedback.

### Disabled
Reduced contrast + reason.

### Active
Clear state marker.

### Warning
Controlled alert style.

### Critical
Strong but restrained escalation.

Do not create a different button style in every screen.

---

## 20. Accessibility and Readability

Support:

- readable font sizes;
- high contrast;
- color + icon together;
- non-color ownership indicators;
- safe touch areas;
- reduced motion option where practical;
- Arabic RTL correctness;
- English LTR correctness;
- Arabic-friendly font fallback;
- no critical text embedded in images.

Do not depend on red/green alone to communicate state.

---

## 21. Localization

All player-facing text must come from a localization layer.

At minimum:

- English;
- Arabic.

Prepare for:

- text expansion;
- RTL layout;
- mirrored UI where appropriate;
- icon placement;
- numbers;
- city names;
- map names;
- system messages.

Do not hardcode user-facing strings inside UI construction scripts.

---

## 22. Audio UX

Audio becomes part of interaction feedback.

Use restrained categories:

- selection;
- command;
- capture progress;
- contested;
- castle captured;
- army under attack;
- victory/defeat;
- reward.

Avoid constant sound spam.

Important events must remain audible over battle ambience.

---

## 23. Microinteraction Budget

Every interaction should earn its animation.

Preferred:

- 100–250ms UI transitions;
- short map marker pulses;
- restrained banner movement;
- small territory flashes.

Avoid:

- long cinematic transitions during active combat;
- bouncing panels;
- excessive particle overlays;
- screen shaking for ordinary attacks.

---

## 24. UX Telemetry

Instrument the experience so UX changes can be measured.

Track:

- tutorial step completion;
- tutorial abandonment;
- first command time;
- first capture time;
- first enemy encounter;
- command rejection;
- repeated invalid actions;
- map-open frequency;
- castle inspection;
- rematch rate;
- match abandonment;
- UI interaction failures;
- mobile vs desktop behavior.

The goal is not to collect everything.

The goal is to identify where players hesitate or fail.

---

## 25. UX Metrics

Use measurable targets.

Examples:

### First-time player
- first army selection without assistance;
- first move without confusion;
- first castle interaction without confusion.

### Match clarity
- player can identify current objective;
- player can identify territory owner;
- player can understand why capture is contested;
- player can discover current army order.

### Retention interaction
- rematch discoverability;
- reward discoverability;
- season progress discoverability.

Metrics should be validated during playtests, not treated as guaranteed outcomes.

---

## 26. UX Research Method

Before finalizing the Stage 10 UI:

Test with at least three player types:

### New player
No prior explanation.

### Returning player
Has played one or more matches.

### Strategy/competitive player
Wants fast information and low UI friction.

Observe:

- where they look;
- what they tap;
- what they ignore;
- what they misunderstand;
- where they hesitate;
- which information they search for.

Do not ask only “Do you like the UI?”

Ask behavior questions:

- “What would you do now?”
- “Who owns this castle?”
- “Why did capture stop?”
- “Where is your army going?”
- “What would you press next?”

---

## 27. Implementation Architecture

Do not let every screen create its own notification, modal, tooltip, button style, or state logic.

Create shared UI primitives:

- Button;
- IconButton;
- Badge;
- Card;
- Tooltip;
- Toast;
- Alert;
- ProgressBar;
- ProgressRing;
- CastleInfo;
- ArmyInfo;
- MapMarker;
- CommandButton;
- Modal;
- ScreenTransition.

Create shared UI state services/modules:

- UIState;
- NotificationService;
- TooltipService;
- LocalizationService;
- InputModeService;
- SelectionService.

Use the existing server state as the source of truth.

Client UI may predict visual feedback but must not become authoritative for gameplay.

---

## 28. Migration Strategy

Do not destroy working UI and rebuild everything blindly.

Execute:

1. audit current UI;
2. identify reusable components;
3. create shared primitives;
4. create new interaction state model;
5. migrate HUD;
6. migrate castle interaction;
7. migrate minimap;
8. migrate lobby;
9. migrate results;
10. migrate profile/season;
11. migrate onboarding;
12. migrate mobile;
13. migrate localization;
14. run UX QA.

At every step:

- preserve gameplay;
- preserve server authority;
- preserve existing remotes unless compatibility requires a deliberate migration;
- remove obsolete UI only after the replacement is verified.

---

## 29. Screen-by-Screen Deliverables

### Lobby
- premium map selection;
- party clarity;
- team mode clarity;
- queue feedback;
- error recovery.

### Match HUD
- contextual;
- minimal persistent chrome;
- strong objective hierarchy.

### Army
- selection;
- commands;
- formations;
- state feedback.

### Castle
- info;
- capture;
- ownership;
- income;
- threat.

### Map
- strategic overview;
- interactive nodes;
- route/focus.

### Results
- explain outcome;
- rewards;
- rematch.

### Profile
- progression;
- season;
- achievements.

### Settings
- language;
- audio;
- graphics/performance;
- accessibility.

---

## 30. Definition of Done

Stage 10 is complete only when:

### UX
- [ ] complete player journey audited;
- [ ] major confusion points addressed;
- [ ] core actions are discoverable;
- [ ] contextual interactions replace unnecessary permanent panels;
- [ ] failure states explain themselves.

### UI
- [ ] shared component language;
- [ ] desktop layout polished;
- [ ] mobile layout purpose-built;
- [ ] interactive minimap;
- [ ] castle interaction;
- [ ] army interaction;
- [ ] onboarding;
- [ ] results;
- [ ] profile;
- [ ] settings.

### Interaction
- [ ] actions have immediate feedback;
- [ ] invalid actions explain why;
- [ ] tactical alerts have priority;
- [ ] notification stacking is controlled;
- [ ] keyboard + touch inputs coexist correctly.

### Localization/accessibility
- [ ] English;
- [ ] Arabic RTL;
- [ ] color is not the only state signal;
- [ ] touch targets are practical;
- [ ] readable contrast;
- [ ] UI scaling works on target device sizes.

### Measurement
- [ ] key UX events instrumented;
- [ ] playtest scenarios defined;
- [ ] new-player and returning-player tests run;
- [ ] before/after issues documented.

### Technical
- [ ] UI is not authoritative for game state;
- [ ] no duplicate source of truth;
- [ ] reusable UI primitives exist;
- [ ] no uncontrolled UI update loops;
- [ ] no major performance regression from interface rendering.

---

## 31. Stage 10 Execution Rule

When Stage 10 is explicitly executed:

1. inspect current UI and all player-facing flows;
2. produce an evidence-based UX audit from the actual repository;
3. implement the redesign in coherent passes;
4. test every major flow;
5. verify desktop and mobile;
6. verify Arabic and English;
7. fix regressions;
8. produce a final UX/QA report;
9. stop after Stage 10.

Do not automatically start another stage.

Stage 10 is the final **interaction and interface quality pass**, not permission to rewrite the game's gameplay rules.
