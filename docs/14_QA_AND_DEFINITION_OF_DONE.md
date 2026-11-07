# 14 — QA and Definition of Done

## Functional
- [ ] Lobby works.
- [ ] Party works.
- [ ] Match starts with correct team count.
- [ ] Province ownership is server authoritative.
- [ ] Four gates work.
- [ ] Capture requires uncontested presence.
- [ ] Capture feedback is readable.
- [ ] Income updates correctly.
- [ ] Army creation is validated.
- [ ] Formation commands work.
- [ ] Combat is deterministic enough to test.
- [ ] Victory is server decided.
- [ ] Match result is recorded.

## UX
- [ ] First action is obvious.
- [ ] No blank startup state.
- [ ] No essential UI collision.
- [ ] Mobile controls work.
- [ ] Selected army is obvious.
- [ ] Enemy threat is obvious.
- [ ] Capture reason is obvious.

## Art
- [ ] Castle silhouettes are consistent.
- [ ] Materials are consistent.
- [ ] Team colors are restrained.
- [ ] No placeholder-looking UI remains in launch-critical path.
- [ ] VFX do not obscure combat.

## Performance
- [ ] No unbounded loops.
- [ ] NPC count tested at worst case.
- [ ] Remote traffic profiled.
- [ ] Mobile test performed.
- [ ] Memory checked over a full match.

## Exploit resistance
Attempt:
- fake capture;
- fake ownership;
- fake resource;
- fake damage;
- remote spam;
- invalid target;
- command from wrong team.

All must be rejected server-side.

## Definition of Done
A stage is not done because code exists.
It is done when:
**implemented + tested + visually verified + performance checked + documented.**