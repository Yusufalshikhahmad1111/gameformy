# 07 — UI/UX Specification

## UX north star
**The player should look at the battlefield, not the interface.**

## Desktop layout
Top:
- match timer;
- team score/control;
- objective alert.

Top-right:
- province ownership summary;
- income rate.

Bottom-center:
- selected army;
- formation;
- order controls.

Bottom-left:
- commander state;
- supplies;
- reinforcement status.

Minimap:
- compact;
- territory colors;
- objectives;
- army pips.

## Mobile layout
Bottom:
- Move
- Attack
- Formation
- Army
- Map

Contextual actions should appear near the selected object.

## Capture UI
When entering a castle:
- objective name;
- current owner;
- progress ring;
- contested indicator;
- time remaining.

Never hide the reason capture is paused.

## Visual hierarchy
Tier 1:
battlefield + current objective.

Tier 2:
army state + territory.

Tier 3:
resources.

Tier 4:
secondary information.

## UI style
Recommended:
military cartography + premium strategy game.

Use:
- dark slate;
- parchment/map surfaces;
- restrained brass;
- team heraldic colors;
- crisp iconography.

Avoid:
- excessive glassmorphism;
- neon gradients;
- giant floating cards;
- generic AI-generated fantasy borders;
- inconsistent corner radii.

## Interaction rules
- Primary buttons have one clear verb.
- Disabled actions explain why.
- Confirmation is used only for irreversible actions.
- Notifications do not stack endlessly.
- Map interactions should not be blocked by HUD.

## Onboarding
First match:
1. “Move your army.”
2. “Capture the castle.”
3. “Your castle generates supplies.”
4. “Choose a formation.”
5. “Watch the enemy route.”

No 20-page tutorial.