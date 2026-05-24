# AGENT_GUIDE.md

Onboarding for any AI agent (or new human) opening this workspace cold.
Read this once, then jump to the linked deep-dive docs.

---

## 1. The 60-second pitch

**Marhab / Sanalika** was a 2D Flash MMO (≈2012–2018, Turkish/Arabic markets) where
players walked around a virtual city, owned apartments/cafes/shops, dressed up
avatars, chatted, played mini-games. The studio shut the servers down. The game
binary still exists — the server does not.

**Our goal:** bring the game back online by **rebuilding the server from scratch**,
using the original (now-decrypted) client as our spec.

That's it. Everything in this repo serves that one goal.

---

## 2. What we have vs. what we're building

| Side       | Status                             | Where                                   |
|------------|------------------------------------|-----------------------------------------|
| **Client** | Original, decrypted, lightly patched | [rebuild/runtime/snl.780.swf](rebuild/runtime/snl.780.swf) |
| **Client source (read-only spec)** | Fully decompiled AS3 | [rebuild/inventory/snl_780_src/](rebuild/inventory/snl_780_src) |
| **Launcher** | Adobe AIR app we built | [rebuild/application.xml](rebuild/application.xml) + [rebuild/runtime/](rebuild/runtime) |
| **Server** | **Being built** (SFS2X + Java extension) | [server/](server) |
| **Assets** | Re-served from SFS Tomcat (mirrored from CDN cache) | `SFS2X/www/ROOT/global/...` |

The client is **the contract**. The server's only job is to answer the messages
the client sends, in the exact shape the client expects.

---

## 3. The five things you must understand before touching code

### 3.1 The client is a Flash `.swf`, run by Adobe AIR
- `.swf` = Adobe Flash file (dead tech, lives on inside AIR runtime `adl.exe`).
- We use [rebuild/runtime/adl.exe](rebuild/runtime) to launch the game as a desktop app.
- The client connects to a backend over **WebSocket** (SmartFoxServer 2X protocol).

### 3.2 The backend protocol is SmartFoxServer 2X (SFS2X)
- Open-source Java game server framework. Handles socket, login, rooms, users
  out of the box. Our Java **extension JAR** plugs into it.
- Extension entry will point: [server/src/com/hara/extension/HaraExtension.java](server/src/com/mygame/extension/MyGameExtension.java).
- Every game-specific message the client sends becomes one
  `addRequestHandler("<name>", <Class>)` line in `init()`.

### 3.3 The client talks to the server in two ways
| Mechanism | Used for | How to handle on server |
|---|---|---|
| **Extension requests** (`serviceModel.requestData("name", params, cb)`) | Game logic: login, init, teleport, buy, save | Write a `BaseClientRequestHandler` |
| **User/Room variables** (SFS built-in) | High-frequency state: avatar position, chat, online status | Use SFS built-in events, rarely need extension code |

### 3.4 The server must mirror client constants **exactly**
String values, key names, enum casing — drift = silent breakage. Source of truth:
- [com/oyunstudyosu/enums/](rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/enums)
  (`UserRoomTypes`, `ItemType`, `BalanceType`, `Privilege`, `RequestDataKey`, …)
- [com/smartfoxserver/v2/entities/](rebuild/inventory/snl_780_src/scripts/com/smartfoxserver/v2/entities)
  (SFS protocol constants — these are SDK, do not modify)

### 3.5 There is no DB dump and no original server code
Every economy rule, every price, every drop rate, every login hash — we are
**reinventing** these. The client only cares about the *shape* of replies.

---

## 4. The asset & cache pipeline (don't skip — this trips everyone)

```
xo.newmarhab.net  (dead CDN (existing but we need to invent our one))
    │
    ├── /global/static/data/vf.19910      ← place catalog (209 rooms)
    ├── /global/static/data/ifile.*       ← item catalog (clothes etc.)
    ├── /global/static/items/clothes/*.swf ← per-item SWFs
    ├── /global/dynamic/panels/*.swf      ← UI panels loaded on demand
    └── /global/dynamic/rooms/*.swf       ← per-room scene SWFs
```

The launcher caches everything under
`%APPDATA%\com.mygame.standalone\Local Store\asset-cache\xo.newmarhab.net\...`

**Two layers of indirection you must respect:**
1. Client asks server for `"teleport" {roomKey:"street01"}` → server replies
   with `buildingData.roomKey` → client looks up `vf.19910` to get the SWF path
   → client downloads SWF from configured CDN host.
2. CDN host comes from server's `config` response. We point it at our own
   Tomcat (`marhab-sfs.mygame-test.cc`, hosts-file mapped to 127.0.0.1).

**See:** [/memories/repo/mygame-asset-cache.md](#) for the warming workflow.

I'm not sure what is the best here yet.
---

## 5. Repo layout (what lives where)

```
MyGame/
├── AGENT_GUIDE.md                ← you are here
├── docs/
│   ├── NEXT-STEPS.md             ← current ceiling: library SWFs blocking gameplay
│   └── SHIPPING-REVERTS.md       ← TEMP patches that must come out before release
├── rebuild/                      ← client-side toolchain
│   ├── runtime/                  ← AIR launcher + snl.780.swf (the live client)
│   ├── inventory/
│   │   ├── snl_780_src/          ← DECOMPILED CLIENT — read-only spec
│   │   ├── snl_780_patch/        ← FFDec importScript patches (small diffs)
│   │   ├── *.swf (proxy_v1..v9)  ← iterative patched builds
│   │   └── <panel>_src/          ← decompiled panel sources (on demand)
│   ├── decrypt-snl.py            ← unwraps the encrypted SWF
│   ├── pack-snl.py               ← repacks FWS → ZWS for shipping
│   ├── dev-loop.ps1              ← build patch → repack → launch AIR
│   ├── warm-cache.ps1            ← prefetches assets into local cache
│   └── tools/ffdec/              ← JPEXS FFDec CLI (decompiler/recompiler)
├── server/                       ← THE SERVER (what we're building)
│   ├── src/com/hara/extension/
│   │   └── ...                   ← one file per real handler
│   ├── build.ps1                 ← compiles JAR
│   └── restart-sfs.ps1           ← taskkill SFS → deploy JAR → start → verify ports
└── (binaryData/ fonts/ images/ frames/ shapes/ sprites/ etc.)
                                 ← FFDec asset dumps (rarely touched directly)
```

---

## 6. The 4 documents you must read in order

1. **This file** — orientation.
2. **[docs/NEXT-STEPS.md](docs/NEXT-STEPS.md)** — the realistic project ceiling
   (library SWFs blocking past-init gameplay).
3. **[docs/SHIPPING-REVERTS.md](docs/SHIPPING-REVERTS.md)** — temporary patches in
   the client that must be reverted before any public release.
4. **Repo memory:** `/memories/repo/mygame-*.md` — bootstrap, handler playbook,
   places registry, clothes pipeline, asset cache, build workflow. Already
   indexed in your context.

---

## 7. Core domain concepts (the vocabulary)

| Term | Meaning |
|---|---|
| **Place / room** | A scene in the world (`street01`, `cafeMarina`, `hospital01`). 209 total. Game-owned by default. |
| **roomKey** | The string the client uses to teleport (`"testStreet"`). Mapped to a `.swf` via `vf.19910`. |
| **User-owned room** | A room where `ownerID` RoomVariable == an avatar's id. 6 types: `HOUSE CAFE GARAGE HOSPITAL LAND OFFICE`. |
| **Avatar** | A player's character: id, name, gender, privilege, balances, equipped clothes. |
| **Privilege** | 0=guest, 1=standard, 2=mod, 3=admin, 4=owner. Gates many UI panels. |
| **Balance** | In-game currencies: `SANIL` (primary), `DIAMOND` (premium), credit values. |
| **Extension request** | A message client sends with a name + SFSObject payload, expecting a callback. |
| **RoomVariable / UserVariable** | Server-pushed state on rooms/users (chat, position, ownership). |
| **Panel** | A UI window. Each is a separate `.swf` downloaded on demand from `/dynamic/panels/`. |
| **InfoFile (`ifile.*`)** | Encoded item catalog: `id|type|flags|...`. |
| **VersionFile (`vf.*`)** | Master index of asset versions + room keys. |

---

## 8. Workflow patterns (use these, don't invent new ones)

### When the client errors with `Request handler not found: 'X'`
Follow the **handler playbook** in repo memory (`mygame-handler-playbook.md`):
1. Grep `snl_780_src` for the call site → find the callback.
2. Read the callback → list every field it reads from the response.
3. Add a handler to `ListHandler` (if static) or new `XHandler.java` (if per-user).
4. `cd server; .\build.ps1; .\restart-sfs.ps1`
5. `cd ..; .\rebuild\dev-loop.ps1 -WaitSeconds 50`
6. Grep `adl.err` for residual errors.

### When the client errors `#1009` / `#1010`
Missing or wrong-typed field in your response. Add/fix per the SFS data-type
mapping in the handler playbook.

### When you need to change client behavior
1. Edit the relevant `.as` in `rebuild/inventory/snl_780_patch/` (NOT in `snl_780_src/`).
2. Run `rebuild/dev-loop.ps1` — it'll FFDec-importScript, repack, relaunch.
3. Log temp patches in `docs/SHIPPING-REVERTS.md`.

### When you need a new asset that isn't cached
1. Try `rebuild/warm-cache.ps1` first (pulls from live CDN if still reachable).
2. If 404, the asset is gone forever — author a replacement or stub it out.

---

## 9. Hard rules (do not violate)

1. **Never edit `rebuild/inventory/snl_780_src/`.** It's a decompiled snapshot,
   not source. Edits go in `snl_780_patch/`.
2. **Never trust the client.** Validate all incoming SFSObject fields server-side.
3. **One handler = one request name.** No mega-routers in the extension.
4. **Match client strings verbatim.** Case-sensitive. No "improvements" to enum names.
5. **Restart SFS via `restart-sfs.ps1`, never inline.** It kills all stale Java
   instances first; ad-hoc `Stop-Process` leaves zombies holding port 9933.
6. **Build artifacts (`*.jar`, `dist/`, `rebuild/runtime/snl.780.swf`) are
   regeneratable — never check in patches against them.**
7. **No destructive operations without explicit user confirmation.** Especially:
   `taskkill`, deleting cache, force-pushes, schema drops.

---

## 10. Where the project stands today (snapshot)

- ✅ Decryption pipeline working (custom Python + FFDec).
- ✅ Custom AIR launcher boots, loads patched SWF.
- ✅ Asset proxy: inner SWF fetches via launcher's `MyGameAssetProxy`.
- ✅ Server boots, handles `config` → `login` → `init` → 4 list stubs + 58 OK stubs.
- ✅ Login through avatar-creation flow works for guest accounts.
- ⏸️ **Blocked at `Sanalika.process()`** — instantiates `Hud`, `AvatarView`,
  `BalanceView`, `IsoScene` from authored library SWFs we don't have.
  Throws `#1081` (class not found) ~7×. Documented in [docs/NEXT-STEPS.md](docs/NEXT-STEPS.md).
- ⏳ Server is intentionally minimal — no point fleshing out handlers we can't
  reach until the UI ceiling is solved.

---

## 11. Decision-making compass

When in doubt, pick the option that:
1. Keeps the **client unmodified** (patches are debt).
2. Adds **server-side flexibility** (we own the server, so push complexity there).
3. **Documents the choice** (memory file or `docs/`).
4. **Survives a restart** (state goes in DB or `UserStateRegistry`, not in-memory
   keyed on session ids).
5. Can be **reverted in one commit**.

---

## 12. The one-line mission statement

> Resurrect an abandoned Flash MMO by rebuilding its server from the decompiled
> client, faithfully enough to play, modestly enough to maintain.

That's the bar. Don't over-engineer past it.
