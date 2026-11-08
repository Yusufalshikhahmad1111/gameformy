# Stage 17 — UX/UI 2.0 & Mobile Command Center
## Objective

Implement the Stage 10 interaction architecture around the new army/economy/combat systems.

The Stage 10 specification already defines the information tiers, contextual HUD, army cards, interactive map, onboarding, Arabic RTL and mobile-first controls. fileciteturn90file0L147-L166

## Permanent HUD

Top:
- score;
- timer;
- supplies.

Top-right:
- tactical map.

Bottom-center:
- selected army command bar.

Bottom-left:
- compact army/economy state.

## Army card

Show:
- role;
- soldier count;
- health;
- morale;
- formation;
- order;
- destination.

Tap/click selects the army.

## Command bar

Base:
- Move;
- Attack;
- Hold;
- Follow;
- Retreat.

Context:
- castle;
- enemy army;
- route blocked;
- reinforcement.

## Tactical map

Tap castle:
- inspect;
- focus;
- route;
- objective.

Tap army:
- select.

Tap enemy:
- attack.

## Mobile

Use dedicated mobile controls:
- touch-safe buttons;
- contextual actions;
- drag/pinch strategic map;
- no desktop panel stacking.

## Onboarding

First 90 seconds:
1. select army;
2. send army;
3. capture castle;
4. collect income;
5. choose formation.

## Feedback

Every important action has:
- visual acknowledgment;
- state change;
- sound where useful;
- reason on failure.

## Localization

All player-facing text:
- LocalizationService;
- Arabic RTL;
- English LTR;
- no hardcoded text.

## Definition of Done

A new player can complete the first meaningful military loop without reading a manual.
