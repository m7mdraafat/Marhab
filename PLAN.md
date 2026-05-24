# PLAN.md — Hara server roadmap

> The 12-phase plan from the design conversation, **re-anchored to the current
> on-disk state** of `server/`. Each phase lists what already exists vs what's
> missing. Phase 0 (cleanup) added because real state diverged from intent.

Last reviewed: 2026-05-24
Server package: `com.hara` · Output jar: `dist/HaraExtension.jar`
Deploys to: `<SFS_HOME>/extensions/HaraExtension/HaraExtension.jar`

---

## Snapshot — what's on disk today

```
server/src/com/hara/
├── extension/
│   ├── HaraExtension.java                 ← entry: 3 real + 5 list + 2 avatar + 60 stub handlers
│   └── events/UserLifecycleHandler.java   ← elevates privilege on USER_LOGIN/USER_JOIN_ZONE
├── protocol/
│   ├── framework/                         ← BUILT BUT UNUSED
│   │   ├── HandlerBase.java               ← abstract base with error envelope + timing
│   │   ├── ResponseBuilder.java           ← fluent SFSObject builder
│   │   ├── SfsObjectMapper.java           ← typed req*/opt* accessors
│   │   └── BadRequestException.java
│   └── handlers/
│       ├── auth/ConfigHandler.java        ← moods, baloons, roles, fileServer
│       ├── auth/LoginHandler.java         ← users.properties-backed
│       ├── boot/InitHandler.java          ← bootstrap + auto-join lobby
│       ├── boot/ListHandler.java          ← buddylist/orderlist/.../baseclothes (with real clothes)
│       ├── avatar/AvatarSaveHandler.java  ← savebaseclothes + avatarcreate
│       ├── stubs/OkHandler.java           ← {ok:true} for 60 commands
│       ├── room/   .gitkeep only
│       ├── shop/   .gitkeep only
│       └── social/ .gitkeep only
├── service/
│   ├── RoomService.java                   ← createRoom + autoJoin + seed UserVariables
│   └── UserStateRegistry.java             ← IP-stable per-user state
├── domain/        .gitkeep only
├── catalog/       .gitkeep only
├── persistence/   .gitkeep only (dao/, schema/)
└── infra/         .gitkeep only (audit/, config/, metrics/, ratelimit/)
```

**Working today:** SFS extension boots, replies to `config` → `login` → `init`,
puts guest through AvatarCreatePanel, persists `baseClothSelected`, then
auto-joins a placeholder lobby. Splash advances past INIT_READY.
**Wall:** Library-SWF ceiling at `Sanalika.process()` (see
[docs/NEXT-STEPS.md](docs/NEXT-STEPS.md)). Server work past this phase has
diminishing returns until UI authoring is solved.

---

## Phase 0 — Cleanup & consistency (DO THIS FIRST)

Drift built up while migrating `com.mygame` → `com.hara`. Fix once, then plan.

- [ ] **Delete `server/run-local.ps1`.** Duplicate of `restart-sfs.ps1`,
      references stale `MyGameExtension.jar`. `restart-sfs.ps1` is canonical.
- [ ] **Rewrite `server/README.md`.** Currently describes `com.mygame.extension`
      classes that no longer exist (`LoginHandler.java` *was* in `com.mygame`,
      `RequestDataHandler.java` never existed). Match real layout above.
- [ ] **Fix `LoginHandler.usersFile()`** to write under
      `extensions/HaraExtension/users.properties`, not `extensions/MyGameExtension/`.
      Migration: copy the old file on first boot if present.
- [ ] **Strip `MyGameExtension` references in Javadoc:**
      - `UserLifecycleHandler.java` line 14 (`@link MyGameExtension#DEFAULT_LOBBY`)
        → `RoomService#DEFAULT_LOBBY`.
      - `ListHandler.java` line 75 comment.
- [ ] **Sync `AGENT_GUIDE.md`** (root) — replace remaining
      `com.mygame.extension.MyGameExtension` with `com.hara.extension.HaraExtension`
      and any jar-name references.
- [ ] **Reindex VS Code workspace** to clear ghost `com.mygame` entries from
      search (real files are already gone on disk).

Exit criteria: `grep -ri "mygame\|MyGameExtension" server/` returns 0 hits;
clean `build.ps1; restart-sfs.ps1; dev-loop.ps1` round-trip still passes.

---

## Phase 1 — Wire-format inventory (the spec)

The contract lives in the decompiled client; today it lives in our heads. Mine
it into machine-readable files so every future handler is one row of a table.

- [ ] Script `rebuild/mine-requests.py`:
  - walk `rebuild/inventory/snl_780_src/scripts/**/*.as`
  - find every `serviceModel.requestData("<name>", {...}, this.<callback>)`
  - extract sent keys (from the literal SFSObject) and the callback signature
  - emit `rebuild/inventory/protocol/requests.json`:
    `{ name, sentKeys[], callbackClass, callbackMethod, callSite }`
- [ ] Script `rebuild/mine-pushes.py`:
  - find every `addEventListener("<event>", ...)` for `ext_*` / SFS push events
  - emit `pushes.json`: `{ name, listenerClass, listenerMethod }`
- [ ] Script `rebuild/mine-variables.py`:
  - find every `getStringValue() / getIntValue() / getBoolValue()` on
    `RoomVariable` / `UserVariable` lookups
  - emit `variables.json`: `{ entity, key, type, readers[] }`
- [ ] Commit the 3 JSON files. They become the source of truth for what the
      server MUST handle / push / publish.

Exit criteria: 3 JSON files exist, machine-greppable, no duplicates.

---

## Phase 2 — Domain model

Today: every domain concept lives as inline strings inside handlers. Make
enums + value objects so refactors stop being find-and-replace.

- [ ] **Mirror client enums** (one Java enum per AS3 file in
      `com/oyunstudyosu/enums/`) into `com.hara.domain.enums`:
      `UserRoomType`, `ItemType`, `BalanceType`, `Gender`, `Privilege`,
      `BanType`, `CharacterState`, `RequestDataKey`. Same string values.
- [ ] **Value objects** in `com.hara.domain.model`:
      `Avatar`, `Wallet`, `Balance`, `RoomKey`, `RoomCatalogEntry`,
      `ClothesItem`, `Place(Category, key, swfPath, ownerable)`.
- [ ] **Catalog seed** in `com.hara.catalog`:
      - `PlaceCatalog` — load `vf.19910` at boot, 209 entries → `Map<roomKey, Place>`.
      - `ItemCatalog` — parse `ifile.2013` rows → `Map<itemId, ItemDef>`.

Exit criteria: every magic string in current handlers replaced with an enum
or catalog lookup; tests prove catalogs load from the asset cache.

---

## Phase 3 — Cross-cutting infrastructure (FINISH WHAT'S STARTED)

`HandlerBase`, `ResponseBuilder`, `SfsObjectMapper` exist but **zero handlers
use them**. Adoption first, new infra second.

- [ ] **Migrate existing handlers to `HandlerBase`:**
  - [ ] `ConfigHandler` → extend `HandlerBase`, `handle()` returns `ResponseBuilder` result.
  - [ ] `LoginHandler` → same; use `SfsObjectMapper.optStr(params, "password", "")`.
  - [ ] `InitHandler` → same; keep auto-join side effect.
  - [ ] `ListHandler` → same; `cmd = command()`.
  - [ ] `AvatarSaveHandler` → same.
  - [ ] `OkHandler` → same; this becomes the canonical stub.
- [ ] **Audit logger** in `com.hara.infra.audit.AuditLog`:
      append-only `audit.log` line per request:
      `ts | avatarId | cmd | durationMs | ok | errCode?`.
      Hook in `HandlerBase` `finally` block.
- [ ] **Rate limiter** in `com.hara.infra.ratelimit.TokenBucket`:
      key = `(stableUserKey, cmd)`; default 10 req/s, override per-cmd.
      Reject in `HandlerBase.preHandle()` with `{ok:false, errorCode:429}`.
- [ ] **Config loader** in `com.hara.infra.config.HaraConfig`:
      typed view over `extension.properties`. Hot-reload optional.
- [ ] **Metrics** in `com.hara.infra.metrics.HandlerMetrics`:
      per-cmd count + p50/p95/p99 latency. Dump to CSV on `destroy()`.

Exit criteria: zero handlers extend `BaseClientRequestHandler` directly;
`audit.log` grows on every request; rate limit rejection visible in trace.

---

## Phase 4 — Bootstrap handlers (DONE — keep regression-safe)

- [x] `config` — returns moods/balloons/roles/fileServer. ✅
- [x] `login` — users.properties persistence; SHA-256. ✅
      _(Phase 0 fixes directory name; Phase 9 swaps to DB.)_
- [x] `init` — checkAvatar flag flips after baseClothSelected; auto-join lobby. ✅
- [x] empty-list responders for buddylist/privatechatlist/orderlist/questlist
      via `ListHandler`. ✅
- [x] `baseclothes` — real clothes table with HEAD-verified entries. ✅
- [x] 60 commands stubbed via `OkHandler`. ✅

**Add:** `notificationlist` once first error surfaces (predicted).
**Add:** init-response cache (60s) keyed by stableUserKey to absorb reconnect storms.

---

## Phase 5 — Room subsystem

Today: one hardcoded `lobby` Room with placeholder grid. Need real teleport.

- [ ] Replace `RoomService.DEFAULT_LOBBY` hardcoding with **`PlaceCatalog` lookup**.
      First-join target = `startpoint` (the start-of-world key from `vf.19910`).
- [ ] **Real grid loader.** Replace `buildOpenGrid()` CSV stub with base64 of
      `[int32 w][int32 h][w*h bytes]` (the format the client expects). Author
      grids per room and store under `server/data/grids/<roomKey>.bin`.
- [ ] **`teleport` handler** (currently `OkHandler` stub) → real impl:
      - validate `roomKey` exists in catalog
      - `RoomService.joinByKey(user, roomKey)` (creates SFS Room on demand)
      - seed RoomVariables: `roomKey, roomID, width, height, grid, source,
        roomTitle, ownerID, ownerName, roomType, doors, bots, extensions`
      - reply with `buildingData = {roomKey, roomType, swfPath}`.
- [ ] **User-owned rooms:**
      - `buyRoom(roomType, templateKey)` → mint roomKey, write `RoomsOwnedDao`.
      - `enterMyHouse` → resolve to that user's owned `HOUSE` room.
      - `saveLayout` → persist layout blob.
      - `setRoomTitle`, `kickFromMyRoom`.
- [ ] Move room-create permission checks (privilege gate) into `RoomService`.

Exit criteria: client `teleport street01` lands in a real Room; switching
between two rooms works; user can own a house and re-enter it post-restart
(needs Phase 9 DB to be fully persistent).

---

## Phase 6 — Avatar / movement / chat (high-frequency path)

- [ ] **Movement uses SFS built-in `SetUserVariablesRequest` on `x, y, dir,
      state`** — *not* an extension call. Server only validates bounds (against
      the room grid). Currently `walkrequest` is a stub.
- [ ] **`walkrequest` / `walkfinalrequest`** → server-side path validation
      against current room's grid (block on collision/out-of-bounds), then
      `setUserVariables` to broadcast.
- [ ] **Public chat** via SFS `PublicMessageRequest`; server filter pass
      (profanity list, mute check, rate limit).
- [ ] **Whisper / privatechat** → extension command (`whisper`, `groupwhisper`),
      persistent to DB; emit `whisperRecv` push.
- [ ] **Emotes** (`changemood`, `usechatballoon`) — set UserVariable, no DB.

---

## Phase 7 — Economy (server-authoritative)

- [ ] **`BalanceService`** in `com.hara.service`:
      single mutator `mutate(avatarId, currency, delta, reason, idempKey)`.
      Emits `balanceUpdate` push. All shop/quest/gift code routes through it.
- [ ] **`TransactionDao`** with idempotency key constraint.
- [ ] **Shop handlers** (`purchase`, `flatpurchase`, `exchangediamond`):
      read item catalog → check balance → decrement → grant → push update.
      Wrap in DB transaction.
- [ ] **Inventory handlers** (`drop`, `dropthrowaction`, `gatheritemcollect`,
      `usehanditem`).
- [ ] **Gifts** (`giftcheckexchange`, `transferrequest`, `transferresponse`).
- [ ] **Diamond transfers** (`diamondtransferrequest/response`).

---

## Phase 8 — Social

- [ ] **Buddy** (`addbuddy`, `removebuddy`, `addbuddyresponse`,
      `changebuddyrating`, `buddyinvitelocation`, `buddylocate`,
      `buddyrespondinvitelocation`, `buddyacceptinvitegame`) — replace
      placeholder empty list with `BuddyDao` reads.
- [ ] **Presence** push on `USER_LOGIN` / `USER_DISCONNECT`: look up
      buddies-of-this-user, push `buddyOnline` / `buddyOffline`.
- [ ] **Notifications** — `NotifyService(avatarId, type, payload)`, persistent
      queue; flush on next login if user offline.
- [ ] **Status message / mood** (`changestatusmessage`, `changemood`).

---

## Phase 9 — Persistence (replace in-memory)

- [ ] **MySQL** (SFS's preferred DB; ships JDBC pool). Add `lib/mysql-*.jar`.
- [ ] **Flyway migrations** under `server/db/migrations/`.
- [ ] Tables: `accounts`, `avatars`, `wallets`, `inventory`, `rooms_owned`,
      `rooms_catalog` (seeded from `vf.19910`), `buddies`, `messages`,
      `transactions`, `bans`, `mutes`.
- [ ] **DAOs** under `com.hara.persistence.dao` — one per table, no SQL outside.
- [ ] **Repository façades** for handler convenience.
- [ ] Drop `UserStateRegistry` in favor of `AvatarRepository`; keep IP-stable
      lookup *only* for guest pre-creation.
- [ ] Move `users.properties` accounts into `accounts` table (one-shot
      migration on first boot).

---

## Phase 10 — Admin / moderation

- [ ] **Privilege gate annotation** read by `HandlerBase`:
      `@RequiresPrivilege(MOD)` → reject < MOD with `{errorCode:403}`.
- [ ] **Mod commands:** `kick`, `ban`, `mute`, `teleportUser`, `setVar`,
      `broadcast`. All go through `ModerationService` for audit-logging.
- [ ] **Admin web UI:** out of scope; SFS Admin Tool (8080/admin) is enough.

---

## Phase 11 — Mini-games / extensions

- [ ] Subpackages `com.hara.protocol.handlers.games.<name>`:
      - `fishing` (Start/Action/End)
      - `billiards`
      - `bowling`
      - `farm` (`farmclean`, `farmgather`, `farmimplantation`)
      - `partyIsland` (`rollDice`, `leave`)
      - `fortuneTeller` / `fortunewheel` / `randomwheel`
      - `barter` (`barterrequest/response/cancel`)
- [ ] Each owns its own `*State` object stored as RoomVariable; never
      cross-import between games.
- [ ] One integration test per game (replay a recorded session).

---

## Phase 12 — Hardening before public release

- [ ] **Integration tests** with the SFS2X **Java client SDK** — replay:
      connect → login → init → teleport → chat → purchase → logout.
      Run on every PR.
- [ ] **Trace replay** harness — feed `audit.log` through a fake client.
- [ ] **Load test** — 500 concurrent sims walking + chatting; profile hottest
      handler.
- [ ] **Backups** — nightly `mysqldump` + `asset-cache/` snapshot.
- [ ] **Health endpoint** (Tomcat side) `/health` → DB ping + extension up +
      room count.
- [ ] **Runbook** `server/docs/RUNBOOK.md` — restart, rollback jar, read
      audit log, ban a user.
- [ ] **Revert all entries in `docs/SHIPPING-REVERTS.md`** (currently: the
      `Sanalika.onVersionFileLoaded` privilege bypass).
- [ ] **Disable `LoginHandler` first-time-auto-register** — accounts must be
      created explicitly.
- [ ] **Privacy review** of `audit.log` (no plaintext passwords, no PII).

---

## Architectural guardrails (apply at every step)

1. **One handler = one request name.** No mega-routers in `HaraExtension`.
   `ListHandler` is the only allowed multiplexer because the shapes are
   structurally identical.
2. **Handlers are thin.** Parse → call a Service → format a Response.
3. **Services are pure.** DAOs do I/O; Services do rules; Handlers do protocol.
4. **`RoomService` is the only Service that imports SFS APIs.** Everything else
   stays testable without SmartFox on the classpath.
5. **Never trust the client.** Validate every key, every range, every
   ownership claim server-side.
6. **Idempotency on every mutation.** Same request twice = same outcome.
7. **Match client constants verbatim.** Case, spelling, casing. Drift = silent breakage.
8. **Per-user state always uses `stableKey(User)`** (IP for guests, username
   for accounts). Never key on `user.getId()`.

---

## Quick-reference: where each request lives

| Request | File | Status |
|---|---|---|
| `config` | [ConfigHandler.java](server/src/com/hara/protocol/handlers/auth/ConfigHandler.java) | ✅ real |
| `login`  | [LoginHandler.java](server/src/com/hara/protocol/handlers/auth/LoginHandler.java)  | ✅ real |
| `init`   | [InitHandler.java](server/src/com/hara/protocol/handlers/boot/InitHandler.java)   | ✅ real |
| `buddylist` `privatechatlist` `orderlist` `questlist` `baseclothes` | [ListHandler.java](server/src/com/hara/protocol/handlers/boot/ListHandler.java) | ✅ shape-correct |
| `savebaseclothes` `avatarcreate` | [AvatarSaveHandler.java](server/src/com/hara/protocol/handlers/avatar/AvatarSaveHandler.java) | ✅ real |
| 60 others (`teleport`, `walkrequest`, `whisper`, `purchase`, …) | [OkHandler.java](server/src/com/hara/protocol/handlers/stubs/OkHandler.java) | ⏳ `{ok:true}` stub |

---

## One-line plan summary

> Clean up the `com.mygame → com.hara` drift, **adopt the framework that's
> already built**, then mine the client into JSON contracts so every future
> handler is mechanical to write. Real gameplay (rooms, economy, social)
> waits until the library-SWF UI ceiling is solved — until then, the server
> stays minimal and correct.
