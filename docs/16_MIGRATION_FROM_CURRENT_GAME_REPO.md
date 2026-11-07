# 16 — Migration From Current `game` Repository

The currently inspected public repository `Yusufalshikhahmad1111/game` contains an older Island Dominion turn-based grid architecture and a later real-time World PvP pivot.

## Recommendation
Do not bolt Kingdoms Conquest onto the old `GameManager` monolith.

Instead:
1. preserve the current repository history;
2. create a clean game runtime namespace;
3. reuse only proven infrastructure;
4. migrate pure utilities after tests pass;
5. remove obsolete runtime mappings only after the new vertical slice is stable.

## Reusable candidates
- Rojo project conventions;
- remote setup patterns;
- server-authority patterns;
- validation utilities;
- tests;
- documentation workflow.

## Do not blindly reuse
- old turn-based board rules;
- color-flood mechanics;
- obsolete UI;
- nuclear-strike systems;
- unrelated world-PvP economy;
- giant GameManager responsibilities.

## Target architecture
The new runtime should make it possible to delete one subsystem without breaking every other subsystem.