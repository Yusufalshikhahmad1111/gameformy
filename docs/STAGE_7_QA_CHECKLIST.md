# Stage 7 — Launch Hardening QA & Release Checklist

## Runtime
- [ ] Publish experience and enable required API services before persistence tests.
- [ ] Start an empty lobby server and verify MatchActive remains false.
- [ ] Join through matchmaking with a selected MapId and TeamCount.
- [ ] Verify reserved server receives TeleportData before Stage 1 world construction.
- [ ] Verify 2, 3 and 4 team modes separately.
- [ ] Verify Heartland and Riverlands separately.
- [ ] Verify disconnect/reconnect does not duplicate progression.
- [ ] Verify match result awards only the winning team.

## Security
- [ ] Spam queue/party/profile remotes and verify server-side rate limiting.
- [ ] Send invalid formation, position, province and army payloads.
- [ ] Attempt to claim daily reward repeatedly.
- [ ] Attempt to award client-side XP/Coins.
- [ ] Attempt cross-team capture commands.
- [ ] Verify all authoritative changes remain server-side.

## Data
- [ ] New profile creates schema version 2.
- [ ] Existing version 1 profile migrates without losing old fields.
- [ ] SeasonId/SeasonXP/SeasonRewardClaims survive rejoin.
- [ ] Forced DataStore failure does not crash the server.
- [ ] Autosave and BindToClose complete before shutdown timeout.

## Performance
- [ ] Test 2/4/8/12/16 players.
- [ ] Watch server heartbeat and client frame time.
- [ ] Verify no per-frame unbounded table creation.
- [ ] Verify army/projectile/effect counts remain bounded.
- [ ] Verify StreamingEnabled is enabled for the published place if the map grows beyond the MVP footprint.

## Mobile
- [ ] Test touch navigation.
- [ ] Test command buttons at 16:9 and tall phone aspect ratios.
- [ ] Confirm UI does not cover the capture feedback.
- [ ] Confirm profile/season panels can be opened and closed without keyboard.

## Release gate
A build is RC-ready only when the Studio runtime checklist passes. GitHub static checks are complete, but no source-only review can truthfully replace the final Roblox Studio multiplayer test.
