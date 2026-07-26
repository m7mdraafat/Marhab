# 10. Open gaps & verified shipping-blockers

[← Server build plan](09-server-build-plan.md)  ·  [Index](README.md)  ·  [Next: First-time flow →](11-first-time-flow.md)

## 10.1 Known gaps & blockers

> **Recently closed gaps** (resolved by [11-first-time-flow.md](11-first-time-flow.md),
> [12-our-own-cdn.md](12-our-own-cdn.md), and the rewrite of
> [04-rooms-and-walking.md](04-rooms-and-walking.md) §4.3–4.4):
>
> - ✅ `init.checkAvatar` / `init.createAvatar` flow — full wire contract in [11 §11.3](11-first-time-flow.md#113-avatarcreatepanel--exact-wire-contract). Requests: `baseclothes`, `savebaseclothes`, `avatarcreate`.
> - ✅ AvatarCreatePanel response shape — `{ avatarID }` on success, `{errorCode, message}` on failure ([11 §11.3 Step C](11-first-time-flow.md#step-c--server-replies-and-client-kicks-itself)).
> - ✅ Default first-room recommendation — `street01` (resolves to `rooms/st01-dark3.swf` via `vf.19910`) ([11 §11.4](11-first-time-flow.md#114-the-first-room--recommendation)).
> - ✅ Spawn-position computation — first door's `targetX/Y/Dir` ([11 §11.5](11-first-time-flow.md#115-spawn-position--exactly-where-the-avatar-appears)).
> - ✅ Room map XML schema (8 entry types, all attributes) — [04 §4.3](04-rooms-and-walking.md#43-the-room-map-xml--exact-schema).
> - ✅ Walkability-grid binary format — [04 §4.4](04-rooms-and-walking.md#44-the-walkability-grid-grid-roomvariable).
> - ✅ Isometric coordinate math (tile size, cos/sin, screen↔grid) — [04 §4.6](04-rooms-and-walking.md#46-isometric-coordinate-system--exact-math).
> - ✅ Walk delay formula derivation — [04 §4.8](04-rooms-and-walking.md#48-character-walk-loop--exact-timing).
> - ✅ CDN strategy — confirmed `ifile.2013` + `vf.19910` in cache + 51,393-URL inventory in `rebuild/` are the source of truth; full mirror plan in [12](12-our-own-cdn.md).

| Gap | Severity | Notes |
|---|---|---|
| 253 room SWFs + 70 panel SWFs not in cache | **Critical (REL)** | The two-layer indirection works, the catalogs are decoded, but the actual `dynamic/rooms/*.swf` files were never proxied. Three options outlined in [12 §12.6 Stage 3](12-our-own-cdn.md#stage-3--re-author-the-long-tail): find archives, re-author from FFDec dumps, or ship stub-rooms with valid grids. Wave 1–3 MVP can ship with a single hand-authored `street01.swf`. |
| `partyIsland.*` payloads partially traced — `turnData`, `propertyData`, `gameState` field shapes unknown | Medium | Defer until the mini-game is in scope (Wave 12). |
| `musicList`, `skipMusic`, `CAFEADSMARHAB`, `addMusic` — cafe music subsystem incompletely traced | Medium | Mine `BusinessMusic.as` next. |
| `cmd2user` / `cmd2All` (from `GameRequest`/`GameResponse` enums) — generic bus for per-game extensions | Medium | These look like wrappers used by room-level extensions (`startextension`/`stopextension`). |
| No client-initiated achievement request seen | Low | Achievements are push-only; treat as expected (server-side rule engine fires `achievementupdate`). |
| `walkrequest` server-side path validation is not in client code | Low (SEC) | But you *should* re-validate server-side — client-side A* would otherwise let cheaters teleport. Walk the cells, reject if any is blocked or move exceeds 1 tile per tick. |
| No DB dump survives | Critical (REL) | You're reinventing every catalog row. Treat `ifile`/`vf` as build outputs of seed scripts under `catalog/`. |
| `crossdomain.xml` policy | Medium (SEC) | Don't ship a wildcard `<allow-access-from domain="*"/>`. Lock to your Flash client domain. |
| `walkrequest` rate limit | Medium (SEC/PERF) | Without it a single client can DoS chat/render in shared rooms. Cap to ≈ 2/s per user. |
| Public chat content not stored (only audit?) | Medium (REL) | Decide: if you need cross-session history for mod review, log to `social.chat_history` (already partitioned in [08 §8.5](08-database-schema.md#85-social)). |
| `decrypt-snl.py` produces the working SWF (decrypted) → `pack-snl.py` repacks. The patches you ship to clients must not include the decryption helper. | High (SEC) | Track per `docs/SHIPPING-REVERTS.md`. |

## 10.2 Quick "where do I look up X?" cheat sheet

| Question | File |
|---|---|
| Names, ints, strings | [enums/](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/enums) — also [05-enums-and-types.md](05-enums-and-types.md) |
| Error codes the server may return | [service/ServiceErrorCode.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/service/ServiceErrorCode.as) — also [05 §5.5](05-enums-and-types.md#55-serviceerrorcode-must-match-exactly) |
| Bootstrap order | [Sanalika.as](../rebuild/inventory/snl_780_src/scripts/Sanalika.as) — also [02-bootstrap.md](02-bootstrap.md) |
| "What does the client send?" | grep `serviceModel.requestData(` under `rebuild/inventory/snl_780_src/scripts/` — table in [03 §3.1](03-protocol-catalog.md#31-client--server-extension-requests-70-commands) |
| "What does the client listen for?" | grep `listenExtension(` and `addEventListener("ext_` — table in [03 §3.2](03-protocol-catalog.md#32-server--client-push-events-80) |
| "Where does walking happen?" | [engine/character/Character.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/engine/character/Character.as) (`walkRequest`) + [model/WalkModel.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/model/WalkModel.as) — also [04 §4.3](04-rooms-and-walking.md#43-the-walk-packet-the-most-performance-critical-handler) |
| "What does a room scene look like?" | [room/RoomController.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/room/RoomController.as) + [engine/scene/components/SceneProcessDataComponent.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/engine/scene/components/SceneProcessDataComponent.as) — also [04 §4.2](04-rooms-and-walking.md#42-the-complete-join-a-room-timeline) |
| "What's a Property?" | [interactive/EntryVo.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/interactive/EntryVo.as) + everything under [property/](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/property) — also [06 §6.10](06-subsystems.md#610-property-pattern-the-magic-that-powers-interactive-objects) |
| DB schema | [08-database-schema.md](08-database-schema.md) |
| Server packaging + handler order | [09-server-build-plan.md](09-server-build-plan.md) |

## 10.3 Suggested first steps after reading this

1. Confirm the DB schema in [08](08-database-schema.md) (or amend it).
2. Land [09 Wave 0 cleanup](09-server-build-plan.md#wave-0--cleanup-from-planmd-phase-0).
3. Robocopy the AIR launcher cache into your own CDN root (`docs/cdn/...`) per [12 §12.6 Stage 1](12-our-own-cdn.md#stage-1--phase-boot-minimum-to-clear-init_ready).
4. Implement [09 Wave 1](09-server-build-plan.md#wave-1--boot-the-splash-and-clear-connecting) + the first-time flow handlers from [11 §11.6](11-first-time-flow.md#116-server-checklist-for-the-first-time-flow): minimal `config` + `init` + `LoginEventHandler` + `baseclothes` + `savebaseclothes` against the schema, so the avatar create panel completes against our own CDN.
5. Drop the schema into `docs/db/schema.sql` and write the corresponding DAO scaffolding.
6. Re-author a placeholder `street01.swf` so a brand-new avatar lands in a walkable room.

---

[← Server build plan](09-server-build-plan.md)  ·  [Index](README.md)  ·  [Next: First-time flow →](11-first-time-flow.md)
