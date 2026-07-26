# 12. Building our own CDN (from the rebuild folder)

[← First-time flow](11-first-time-flow.md)  ·  [Index](README.md)

> **Premise (user-confirmed):** `ifile.*`, `vf.*`, and every cached asset
> already in `rebuild/` (and in the AIR launcher's local cache) **are the
> source of truth**. We do not need the dead `xo.newmarhab.net` to ship —
> we build our own CDN by mirroring those bits onto our own static host.

This chapter inventories what we *already* have, what shape it's in, and the
exact mapping needed to serve it from our own URL.

## 12.1 What we already possess (verified inventory)

There are **three tiers** of cached assets on disk, in order from the most
authoritative (committed to the repo) to the most ephemeral (live AIR run).
Earlier drafts of this chapter only documented the third tier and called the
first tier "empty" — in fact it's hundreds of megabytes of ready-to-serve
SWFs.

### Tier 1 — `rebuild/inventory/` (the canonical, committed source)

This is what [`rebuild/promote-cdn-mirror.ps1`](../rebuild/promote-cdn-mirror.ps1)
reads to build the runtime CDN. Three `files/` sub-trees, each laid out as
`global/<rest>` so they merge cleanly into one mirror.

| Source tree | Contents | Size |
|---|---|---|
| [`../rebuild/inventory/room-assets/files/`](../rebuild/inventory/room-assets) | **254 room SWFs** (`global/dynamic/rooms/*.swf`) | 152 MB |
| [`../rebuild/inventory/vf-assets/files/`](../rebuild/inventory/vf-assets) | **85 SWFs** (panels, extensions, core SWFs) + `global/static/data/{ifile.1366, vf.403}` | 24 MB |
| [`../rebuild/inventory/item-assets-ifile1366/files/`](../rebuild/inventory/item-assets-ifile1366) | **7,190 item SWFs + 7,042 PNGs** (clothes, inventory, smileys, quests — every entry referenced by `ifile.1366`) | 364 MB |
| [`../rebuild/inventory/item-assets/files/`](../rebuild/inventory/item-assets) | Curated probe subset (73 SWFs + 5 PNGs) | 6.6 MB |

Supporting metadata in the same tree (not assets per se, but the audit
trail that proves what's covered):

| Path | What it is |
|---|---|
| [`../rebuild/inventory/room-assets/{present,missing}-room-keys.txt`](../rebuild/inventory/room-assets) | Coverage diff against `vf.19910` |
| [`../rebuild/inventory/room-assets/room-catalog.seed.{csv,json}`](../rebuild/inventory/room-assets) | Per-room metadata seed |
| [`../rebuild/inventory/vf-assets/{ifile.1366.decoded.txt,vf-assets.report.{csv,json}}`](../rebuild/inventory/vf-assets) | Decoded item catalog + per-asset HEAD probe results |
| [`../rebuild/inventory/url-catalog/{all,cloth,inv,smiley}.urls.txt`](../rebuild/inventory/url-catalog) | URL telemetry mined from the live CDN (51,393 URLs) |
| [`../rebuild/inventory/url-catalog-ifile1366/`](../rebuild/inventory/url-catalog-ifile1366) | Same telemetry re-keyed to the older `ifile.1366` catalog |
| [`../rebuild/inventory/asset_catalog.json`](../rebuild/inventory/asset_catalog.json) | Machine-readable map of panel/room/extension keys |
| [`../rebuild/inventory/protocol_catalog.json`](../rebuild/inventory/protocol_catalog.json) | Mined wire-protocol catalog |

### Tier 2 — `assets/cdn-mirror/` (the served root)

[`../assets/cdn-mirror/`](../assets/cdn-mirror) is the document root that
[`../server/serve-cdn.ps1`](../server/serve-cdn.ps1) exposes on
`http://127.0.0.1:8081/`. It is populated by `promote-cdn-mirror.ps1` from
Tier 1.

Current state: **folder skeleton only** (empty leaf folders for
`global/dynamic/{core,extensions,panels,rooms}` and
`global/static/{assets,data,items/{clothes,inventory},locale}`). Run the
promote script to populate it.

Sibling [`../assets/reports/`](../assets/reports) holds the JSON
promotion reports.

### Tier 3 — the AIR launcher's live cache

While the client runs it writes everything it downloads into
`%APPDATA%\com.mygame.standalone\Local Store\asset-cache\<host>_<port>\`.
Today two hosts have entries:

| Sub-host | Contents | Size |
|---|---|---|
| `127.0.0.1_8081\global\` | 1 room + 9 panels + 1 extension + 224 cloth SWFs + 1 data file + 2 static assets | ~12 MB |
| `xo.newmarhab.net\global\` | 71 cloth SWFs + 2 data files + 2 static assets (relic from when the original CDN was alive) | ~4 MB |

Useful for debugging ("did the client actually fetch this?") but **NOT** an
input to the build pipeline.

### Decompiled source bundles

For completeness — these are AS3 sources reconstructed from SWFs, not
run-time assets:

| Bundle | Files |
|---|---|
| [`../rebuild/inventory/snl_780_src/`](../rebuild/inventory/snl_780_src) | 1,693 (~7.6 MB) — the main client |
| [`../rebuild/inventory/avatar_create_panel_src/`](../rebuild/inventory/avatar_create_panel_src) | 45 |
| [`../rebuild/inventory/ml_21_9_src/`](../rebuild/inventory/ml_21_9_src) | 60 (MainLoader) |
| [`../rebuild/inventory/snl_780_patch/`](../rebuild/inventory/snl_780_patch) | 3 (our client patches) |
| [`../rebuild/inventory/room_designer_ffdec/`](../rebuild/inventory/room_designer_ffdec) | 357 — the in-game RoomDesigner extension |
| [`../rebuild/inventory/street01_ffdec/`](../rebuild/inventory/street01_ffdec), [`st01_day_ffdec/`](../rebuild/inventory/st01_day_ffdec) | per-room AS3 dumps |

Packed client itself: [`../rebuild/runtime/snl.780.swf`](../rebuild/runtime/snl.780.swf)
(plus a `.original` baseline and a `.working-baseline` snapshot).

## 12.2 Decoded version catalogs — `vf.403` (served) and `vf.19910`

**Two version catalogs exist on disk; only ONE is shipped per environment.**
Memory note [/memories/repo/mygame-server-runtime.md](memory) confirms
`vf.403` is the one currently served by `serve-cdn.ps1` (it's the file
inside `rebuild/inventory/vf-assets/files/global/static/data/vf.403`, the
same `files/` tree the promote script copies).

| File | Size | Where on disk | Notes |
|---|---|---|---|
| `vf.403` | 16,152 B | [`rebuild/inventory/vf-assets/files/global/static/data/vf.403`](../rebuild/inventory/vf-assets/files/global/static/data/vf.403) | The **currently-served** catalog. 252 room entries. Maps `street01=rooms/st01` for day; `st01-dark3.swf` is the night variant. |
| `vf.19910` | 16,156 B | [`rebuild/inventory/room-assets/vf.19910`](../rebuild/inventory/room-assets/vf.19910) | An alternate snapshot used by `room-assets.report.*`. 253 room + 70 panel + 17 extension + 12 locale + 5 core + 2 data entries. Decoded text alongside as `vf.19910.decoded.txt`. |

### Format (identical for both)

Pipe-separated `key=path` lines, base64-wrapped:

```
info_file=data/ifile.1366
lang_ar=locale/ar_AR.585
lang_en=locale/en_UK.74
MainLoader=core/ml.2
Sanalika=core/snl.716
AdminExtension=extensions/1434383207541-8.1
…
street01=rooms/st01-dark3
street02=rooms/st2-dark2
academy=rooms/1447849759355-13.1
cafe01=rooms/1422640346856-57
cinema=rooms/RMCNM.5
…
```

Each row maps a **logical key** the server uses (e.g., `street01`) to a
**physical filename** (e.g., `rooms/st01-dark3`). The client appends `.swf`
for room/panel/extension/furniture types via
[ModuleModel.getPath()](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/model/ModuleModel.as).

### Decoding it ourselves (PowerShell one-liner)

```powershell
$b64 = (Get-Content vf.403 -Raw).Trim()
$txt = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($b64))
$entries = ($txt -split "[\r\n|]") | Where-Object { $_ -match '=' } |
    ForEach-Object { $p = $_ -split '='; [pscustomobject]@{ key = $p[0]; path = $p[1] } }
$entries | Group-Object { ($_.path -split '/')[0] } | Format-Table Count, Name
```

## 12.3 Decoded `ifile.1366` (active) and `ifile.2013` (AIR-cache only) — the item/cloth catalog

[ItemModel.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/item/ItemModel.as) +
[item/InfoFileParser.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/item/InfoFileParser.as) L119-L160
parse it. Two `ifile.*` versions exist on disk:

| File | Size | Where | Notes |
|---|---|---|---|
| `ifile.1366` | 273,232 B | [`rebuild/inventory/vf-assets/files/global/static/data/ifile.1366`](../rebuild/inventory/vf-assets/files/global/static/data/ifile.1366) | The catalog whose assets we have mirrored in [`item-assets-ifile1366/`](../rebuild/inventory/item-assets-ifile1366). Pair it with `vf.403`. Decoded plaintext sits alongside as `ifile.1366.decoded.txt`. |
| `ifile.2013` | ~308 KB | AIR launcher cache (`xo.newmarhab.net\…\global\static\data\ifile.2013`) | Newer revision the live client once downloaded. **No matching asset cache** in `rebuild/inventory/` — don't ship it until items are re-fetched. |

Row shapes (newline-separated, pipe-internal):

| Shape | Fields | Used for |
|---|---|---|
| 4 fields | `id\|width\|height\|layers` | Inventory items (auto-expanded into `m_<id>` and `f_<id>` gender variants) |
| 7 fields | `clipName\|bitPositions(csv)\|colorChannel\|quantity\|lifeTime\|timeLeft\|subType` | Clothes |
| ≥7 fields, last = version int | `…\|<version>` | Append `.<version>.swf` (e.g., `m_C_1.7.swf`); `0` means no suffix |

`warm-cache.ps1` already implements this logic for the cloth subset
([../rebuild/warm-cache.ps1](../rebuild/warm-cache.ps1)).

## 12.4 Where every asset class lives in the URL space

From [ModuleModel.as L40-L57](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/model/ModuleModel.as)
(verbatim, after `init(vfText)` has populated `map`):

| Asset kind | Lookup | URL template |
|---|---|---|
| Room SWF | `vf` catalog | `{fileServer}/dynamic/rooms{quality}/<vf[key]>.swf` |
| Panel SWF | `vf` catalog | `{fileServer}/dynamic/panels{quality}/<vf[key]>.swf` |
| Extension SWF | `vf` catalog | `{fileServer}/{vf[key]}.swf` |
| Furniture SWF | `vf` catalog | `{fileServer}/static/items/furnitures{quality}/<vf[key]>.swf` |
| Cloth SWF | static template | `{fileServer}/static/items{quality}/clothes/{key}` |
| Cloth PNG render | static template | `{fileServer}/static/items{quality}/clothes/r_{key}` |
| Inventory item | static template | `{fileServer}/static/items{quality}/inventory/{key}` |
| Smiley | static template | `{fileServer}/static/items{quality}/smileys/{key}` |
| Quest icon | static template | `{fileServer}/static/items{quality}/quests/{key}` |
| Bot SWF | static template | `{fileServer}/static/bots{quality}/{key}.swf` |
| Concert SWF | static template | `{fileServer}/static/bots{quality}/{key}.swf` |
| Profile skin | static template | `{fileServer}/static/items/profileskins{quality}/{key}` |

`{quality}` = `""` for SD, `"-2x"` for HD (controlled by `gameModel.quality`).

> The `staticList` array (`ModuleType.CLOTH`, `INVENTORY`, `SMILEY`,
> `CONCERT_SWF`, `BOT`, `FURNITURE`, `PROFILE_SKIN`) bypasses the `vf`
> catalog entirely — those assets resolve straight from the template.

## 12.5 Our own CDN — actual on-disk layout

The runtime CDN root is **[`assets/cdn-mirror/`](../assets/cdn-mirror)**
(not `server/www/` as earlier drafts implied) and is served by
[`server/serve-cdn.ps1`](../server/serve-cdn.ps1) on `http://127.0.0.1:8081/`
during development. The mirror must contain a `global/` directory or the
script refuses to start.

Folder skeleton on disk today (leaves empty until
[`promote-cdn-mirror.ps1`](../rebuild/promote-cdn-mirror.ps1) runs):

```
assets/
├── cdn-mirror/
│   └── global/
│       ├── dynamic/
│       │   ├── core/         ← MainLoader, Sanalika, … (from rebuild/inventory/vf-assets/files/global/dynamic/core)
│       │   ├── extensions/   ← admin, room-designer, mini-games
│       │   ├── panels/       ← *.swf  (~70 entries per vf catalog)
│       │   └── rooms/        ← 254 *.swf (from room-assets/files)
│       └── static/
│           ├── assets/       ← misc bg / loader graphics
│           ├── data/         ← ifile.1366, vf.403, (optional) crossdomain.xml
│           ├── items/
│           │   ├── clothes/  ← {m_,f_,r_m_,r_f_}<clip>[_<color>][.<ver>].{swf,png}
│           │   └── inventory/ ← <id>[.<ver>].swf  (→ 7,190 SWFs once promoted)
│           └── locale/       ← <lang>_<region>[.<ver>].mo (today: ar.mo via write-local-locale.ps1)
└── reports/                  ← cdn-mirror-promotion.report.json (run output)
```

> Future-only categories not yet promoted: `static/items/smileys/`,
> `static/items/quests/`, `static/items/furnitures/`, `static/bots/`,
> `static/items/profileskins/`, and the `-2x` HD parallel tree. Their
> source files exist in `item-assets-ifile1366/files/`; the promote
> script just doesn't copy them yet because nothing in the current
> server response asks for them.

Server's `config` response then sets (today's local-dev values):

```jsonc
{
  "fileServer":  ["127.0.0.1:8081"],          // array; client prepends http:// and appends /global
  "itemFile":    "/static/data/ifile.1366",   // version actually mirrored
  "versionFile": "/static/data/vf.403",
  "langFile":    "/static/locale/ar.mo",      // generated locally by write-local-locale.ps1
  "quality":     "sd"
}
```

A production deploy would swap `127.0.0.1:8081` for the public host and
flip `quality` to `"hd"` (which mutates every URL to `*-2x/*`).

## 12.6 Bootstrap plan — three-stage migration

The point: don't try to mirror 51,393 URLs all at once. Stage it.

### Stage 1 — "Phase boot" (minimum to clear INIT_READY)

Mirror only the assets the splash actually needs:

- `data/ifile.<x>` and `data/vf.<x>` (the two catalogs we already have)
- One locale file (`en_UK.74`)
- One starter room SWF (`rooms/st01-dark3.swf`) for `street01`
- The five core SWFs from `vf` (`MainLoader`, `Sanalika`, etc.) — though if
  we're shipping our own `snl.780.swf`, only the room SWF is strictly needed
- A handful of base-cloth SWFs from the cached 71 to satisfy `baseclothes`
  and `clothlist`

These all already exist in the AIR launcher cache. Copy them out:

```powershell
$src = "$env:APPDATA\com.mygame.standalone\Local Store\asset-cache\xo.newmarhab.net"
$dst = "C:\path\to\our-cdn\global"
robocopy $src $dst /E /XO
```

That single command already gives you a **playable CDN** for the first-time
flow in [11-first-time-flow.md](11-first-time-flow.md).

### Stage 2 — "Fill the warm catalog"

Run [../rebuild/warm-cache.ps1](../rebuild/warm-cache.ps1) once more
(captures any clothes the AvatarCreatePanel needs but we haven't seen yet),
then mirror to the CDN.

For everything else, parse `all.urls.txt`:

```powershell
$all = Get-Content "rebuild/inventory/url-catalog/all.urls.txt"
$cloth   = $all | Where-Object { $_ -match '/clothes/'   }   # ~known
$inv     = $all | Where-Object { $_ -match '/inventory/' }
$smiley  = $all | Where-Object { $_ -match '/smileys/'   }
# 51393 entries total — sample a few and mirror the ones the live CDN still serves
```

Note: most of these URLs were captured from the dead CDN — the live server is
gone, so download attempts on `xo.newmarhab.net` will fail. The list is
useful as a **manifest of what we need to recreate** (filename, version
suffix, gender/color permutation), not as a download source.

### Stage 3 — fill the long tail

What's still missing once the three `files/` trees are promoted:

1. Rooms listed in [`rebuild/inventory/room-assets/missing-room-keys.txt`](../rebuild/inventory/room-assets/missing-room-keys.txt) (the keys present in `vf.19910` whose SWF was not in any cache when the mining scripts ran).
2. Asset categories no current handler requests: `static/items/{smileys,quests,furnitures}/`, `static/bots/`, `static/items/profileskins/`, and the entire `-2x` HD parallel tree. Sources exist in `item-assets-ifile1366/files/` but `promote-cdn-mirror.ps1` doesn't copy them today.
3. Localisation `.mo` files past Arabic — only `ar.mo` is generated locally by [`rebuild/write-local-locale.ps1`](../rebuild/write-local-locale.ps1).
4. Any `ifile.2013`-only items (the AIR cache has `ifile.2013` but not its assets in `rebuild/inventory/`; either stay on `ifile.1366` or re-fetch the new items).

For each genuinely missing room SWF we have three options, in order of effort:

1. **Find it elsewhere** — community archives, the Internet Archive, old YouTube tutorials with frame captures.
2. **Re-author from FFDec dumps** — repack frames+symbols+symbolClass into a new SWF that satisfies the same class linkages the client expects (see [07 §7](07-asset-pipeline.md)).
3. **Stub-render** — a placeholder room SWF with valid linkages but empty geometry, enough that the client successfully loads it and the server's walkability grid is what actually drives gameplay.

Track each room's status in a checklist under `docs/rooms-status.md` (future
work).

## 12.7 Versioning convention

Our own catalogs need a version number we control. Suggestion:

- `ifile.<YYYYMMDD>` and `vf.<YYYYMMDD>` (e.g., `ifile.20260601`)
- Bump on every catalog change; client URLs include the version as part of
  the filename, so cache invalidation is automatic.
- The `?v<n>` query param the client adds is on top of that — it changes
  per-asset version inside the catalog, not per-catalog version.

## 12.8 Concrete first commit (already partially done)

Most of the scaffolding is already in place. What remains:

```text
assets/
  cdn-mirror/global/…         # ✅ folder skeleton exists; run promote-cdn-mirror.ps1 to fill
    crossdomain.xml           # ❌ TODO once we move off 127.0.0.1
rebuild/
  promote-cdn-mirror.ps1      # ✅ source: room-assets, vf-assets, item-assets-ifile1366
server/
  serve-cdn.ps1               # ✅ PowerShell HttpListener on 127.0.0.1:8081, CORS *
  src/com/hara/
    catalog/
      CatalogService.java     # ❌ TODO: load ifile.1366 + vf.403 at boot, expose to handlers
    protocol/handlers/auth/
      ConfigHandler.java      # ✅ returns fileServer/itemFile/versionFile (today hardcoded)
```

Wire `ConfigHandler` to return (production shape):

```java
return new ResponseBuilder()
    .putArray("fileServer", List.of(config.cdnBaseUrl()))   // e.g. ["cdn.your-domain.com"]
    .putString("itemFile",    "/static/data/ifile.1366")
    .putString("versionFile", "/static/data/vf.403")
    .putString("langFile",    "/static/locale/ar.mo")
    .putString("quality",     "sd")
    .putArray("moods",        catalog.moods())
    .putArray("chatBaloons",  catalog.chatBalloons())
    .putArray("masterRoles",  catalog.masterRoles())
    .build();
```

Once these are in place, the AvatarCreatePanel flow ([11](11-first-time-flow.md))
runs against **our** CDN with **our** catalogs — no external network call
required after the initial promote.

## 12.9 Crossdomain & security notes

`crossdomain.xml` lives at the CDN root. **Don't wildcard it.**

```xml
<?xml version="1.0"?>
<!DOCTYPE cross-domain-policy SYSTEM
  "http://www.adobe.com/xml/dtds/cross-domain-policy.dtd">
<cross-domain-policy>
  <site-control permitted-cross-domain-policies="master-only"/>
  <allow-access-from domain="cdn.your-domain.com"  secure="true"/>
  <allow-access-from domain="game.your-domain.com" secure="true"/>
</cross-domain-policy>
```

Cache headers:
- Catalogs (`ifile.*`, `vf.*`): `Cache-Control: public, max-age=300` — they
  change when you ship a new version, and clients re-read on every login.
- Versioned assets: `Cache-Control: public, max-age=31536000, immutable` —
  the version suffix in the filename guarantees uniqueness.
- The client appends `?v<n>` to bust browser cache on per-asset version
  bumps.

MIME types Tomcat must serve correctly:

```text
.swf  → application/x-shockwave-flash
.png  → image/png
.ttf  → font/ttf
.mo   → application/octet-stream  (or text/plain)
```

## 12.10 Bottom line

We have:

- Both catalogs (`ifile.2013`, `vf.19910`) — enough to bootstrap.
- 71 cloth SWFs — enough for the avatar create flow.
- 51,393 URLs documented — enough to inventory the long tail.
- The full decompiled client — enough to re-author anything we can't find.
- FFDec dumps of every symbol in the main SWF — enough to rebuild from scratch.

The CDN is **not** the bottleneck. The bottleneck is the 253 room SWFs and
70 panel SWFs that were never cached. Everything else, including the
first-time-flow MVP, can ship with what's already on disk.

---

[← First-time flow](11-first-time-flow.md)  ·  [Index](README.md)
