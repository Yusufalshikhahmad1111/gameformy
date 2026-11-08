# Stage 8 — World Map Architecture

## Goal
Transform Kingdoms Conquest from a single-battlefield prototype into a reusable world-map strategy platform.

## Delivered
- Config.MapPacks world-map registry.
- Four selectable world maps: Syria, Saudi Arabia, Palestine, Europe.
- Each map contains named city/castle nodes, region metadata, strategic/capital flags, income, spawn positions, road connections, and a default team count.
- MapService converts map packs into the runtime castle/province model.
- Each participating team starts at one home castle; remaining castles are neutral.
- Lobby map selection.
- Lobby team-count selection for 2, 3, or 4 teams.
- Matchmaking isolation by MapId and TeamCount.
- Selected map and team mode travel through TeleportData.
- Stage 7 bootstrap validates and applies the selected map before battlefield initialization.
- Stage 1 world generation consumes the selected map registry.
- Tactical minimap displays map identity, castle nodes, roads, ownership colors, capital emphasis, player's team ring, and controlled/total castle count.
- Main HUD supports dynamic castle counts and four team identities.

## Design rule
The world maps are strategic game maps, not literal 1:1 geographic simulations. City positions and connections are compressed so travel and combat remain fast. Geographic identity is preserved while the playable topology is tuned for PvP.

## Map philosophy
A castle is the strategic unit. A city is represented by a handcrafted castle/fort scene in the 3D world. Capturing the castle captures the corresponding city node and its income.

## Next production direction
Stage 9 should focus on World Map Art and Castle Content:
- handcrafted castle kits per region;
- terrain and biome language per map;
- roads, rivers and landmarks;
- city labels and banners;
- polished map-selection screen;
- minimap visual polish;
- performance and streaming for the largest Europe map.

## Release note
Stage 8 is structurally implemented. Real Roblox Studio testing remains required for TeleportData, mobile layout, multi-server matchmaking and visual placement.
