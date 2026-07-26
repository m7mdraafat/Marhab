# 7. Asset pipeline

[← Subsystems](06-subsystems.md)  ·  [Index](README.md)  ·  [Next: Database schema →](08-database-schema.md)

## 7.1 The FFDec dump folders at the workspace root

Unpacked contents of `snl.780.swf` (~9 MB total on disk; this is the
baked-in UI/engine assets compiled into the client itself, NOT the
run-time CDN assets — those are covered in §7.4 and [12](12-our-own-cdn.md)).

| Folder | Files on disk | Size | Runtime consumer |
|---|---|---|---|
| [`../binaryData/`](../binaryData) | 13 | 0.3 MB | Embedded JSON manifests + shader bytecode; loaded as `__ASSET__*.as` classes |
| [`../fonts/`](../fonts) | 4 | 1.6 MB | TTF fonts (CoText Bold/Regular/Light); used by `TextFormat` in HUD/chat |
| [`../frames/`](../frames) | 1 | <0.1 MB | Single residual PNG; sprite frames actually live under `sprites/` |
| [`../images/`](../images) | 109 | 0.2 MB | UI chrome, buttons, icons (one PNG per DefineImage symbol) |
| [`../morphshapes/`](../morphshapes) | 4 | <0.1 MB | SVG morph keyframes (rarely consumed; vector tweens stay inside the SWF) |
| [`../movies/`](../movies) | **0** | 0 | Empty — folder created by FFDec but no DefineVideoStream symbols in the SWF |
| [`../shapes/`](../shapes) | 114 | 0.6 MB | HTML/canvas DefineShape renderings — **FFDec debug only, never used at runtime** |
| [`../sprites/`](../sprites) | 1,439 | 6.2 MB | One folder per DefineSprite with per-frame PNGs; resolved by `applicationDomain.getDefinition()` for engine clips (door icons, loading spinners, splash, embedded ad bots, …) |
| [`../symbolClass/symbols.csv`](../symbolClass) | 1 | <0.1 MB | `<FFDec ID>;"<AS3 class>"` map — the bridge from numeric SWF symbol IDs to AS3 class names |
| [`../texts/`](../texts) | **0** | 0 | Empty — folder created by FFDec but no DefineEditText / static text symbols dumped here for this SWF |
| [`../scripts/__ASSET__*.as`](../scripts) | many | — | One stub per embedded asset (`[Embed]` metadata); the compiler injects bitmap data into the SWF |

## 7.2 The symbol linkage explained

A `.swf` stores assets as numbered binary symbols (e.g., `DefineSprite 291`).
The `SymbolClass` tag inside the SWF binds those numeric IDs to AS3 class
names. FFDec exports that table to `symbolClass/symbols.csv`. At runtime the
client looks up an asset like this:

```as3
var DoorClass:Class = appDomain.getDefinition("org.oyunstudyosu.assets.clips.DoorIcon");
var door:MovieClip = new DoorClass();
```

CSV format:

```
1007;"__ASSET__assets_background_png"
1017;"__ASSET__assets_hud_redpanelheader_png"
291;"org.oyunstudyosu.assets.clips.ProgressUI"
287;"sanalika_ui_fla.okcu_ceri_415"
```

Important symbols in this SWF:

- `__ASSET__assets_background_png` — splash background
- `__ASSET__assets_hud_redpanelheader_png`, `…_yellowpanelheader_png` — HUD chrome
- `__ASSET__assets_components_buttons_*` — UI button states
- `__ASSET__assets_fonts_co_text_*` — embedded fonts
- `__ASSET__lib_sanalikaairui_json` — main UI library asset manifest
- `org.oyunstudyosu.assets.clips.ProgressUI`, `.LoadingAnimationSmall/Big`, `.DoorIcon` — engine clips
- `mx.graphics.shaderClasses.*Shader` — visual effects (Saturation, ColorDodge, Luminosity)

## 7.3 What each FFDec asset type actually is

For someone rebuilding the asset pipeline:

| Type | What it is | How FFDec extracts it | How client uses it | Pipeline action |
|---|---|---|---|---|
| **Frames** | Individual PNG frames from sprite animation timelines | Exports each keyframe as `Frame_<ID>.png` | Assembled back into DefineSprite for playback by Flash renderer | Re-pack frames into SWF sprites; versioned by `ModuleModel` path + `?v<version>` |
| **MorphShapes** | Vector shape morphs (shape tweens) | Exports morph keyframes as SVG (binary morph data stays in `.swf`) | Flash renderer interpolates between morph shapes at runtime | Rarely modified; leave in compiled SWF |
| **Shapes** | HTML+Canvas visualization of DefineShape vector outlines | Renders each shape as HTML5 canvas for inspection | **None** — FFDec debug only | Delete or ignore |
| **Sprites** | DefineSprite = MovieClip timelines | Exports as `DefineSprite_<ID>/` folder with per-frame PNGs + manifest | Client downloads SWF, looks up by class name via `applicationDomain.getDefinition()`, instantiates & plays timeline | Re-compress PNG frames; rebuild SWF with frame durations & linkage metadata |
| **BinaryData** | Compiled binary assets: shader code, JSON manifest indexes, template HTMLs | Exports as `.bin`; FFDec decompiles what it can | `__ASSET__manifest_*.as` classes extend `ByteArray` and are embedded in main SWF; parsed by manifest loader | Leave in SWF unless recompiling shaders |
| **Fonts** | TrueType font files | Exports `.ttf` from DefineFont/DefineFont2 | `[Embed]` metadata in `__ASSET__*.as`; Flash embeds; `TextFormat` uses by name | Substitute fonts by replacing `.ttf`; recompile SWF |
| **Images** | Individual PNGs from DefineImage symbols | One PNG per image symbol, numbered by FFDec export ID | Either embedded directly in SWF (`[Embed]`) or downloaded on-demand as `.swf` (clothes, item icons) | Static UI: recompress PNGs, update `[Embed]` paths. Dynamic items: host `.swf` on CDN; client requests via `ModuleModel.getPath(itemKey, "ModuleType.CLOTH")` |

## 7.4 Asset loading model at runtime — the two-layer indirection

```
Server "config" response  →  fileServer URL  +  itemFile path  +  versionFile path
                                                       │
                ┌──────────────────────────────────────┴───────────────────────────────┐
                ▼                                                                      ▼
        ItemModel loads ifile.* (Base64)                              VersionModel loads vf.* (Base64)
        → InventoryItem/ClothData catalog                             → ModuleModel.map populated
                                                                              │
                                                                              ▼
                                       full URL =
                                         fileServer +
                                         (template per ModuleType, with {quality} = "" or "-2x") +
                                         (vf-resolved path  OR  literal {key} from the staticList)
                                                                              │
                                                                              ▼
                            AssetModel.request(url) → CacheModel checks AIR FS cache → URLLoader download
```

Full URL-template table lives in [12 §12.4](12-our-own-cdn.md#124-where-every-asset-class-lives-in-the-url-space)
(verified verbatim against `ModuleModel.as` L40-L57). Summary:

- **Catalog-resolved kinds** (room, panel, extension, furniture) go through `vf[key]` → `fileServer + /dynamic/<kind>{quality}/<vf[key]>.swf` (extension uses `/{vf[key]}.swf` only).
- **Static-list kinds** (cloth, inventory, smiley, quest, bot, concert, profileskin) bypass the `vf` catalog and use a literal template: `fileServer + /static/<kind>{quality}/<key>`.
- `{quality}` is `""` for SD or `"-2x"` for HD, controlled by `gameModel.quality`
  ([model/ModuleModel.as L30](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/model/ModuleModel.as)).
- Per-asset version suffix (e.g. `.7` in `m_C_1.7.swf`) is appended from the `ifile.*` row's last column when present; `0` means no suffix.

### Per-asset resolution table

| Asset kind | Catalog source | Path pattern | Loader class | Network timing |
|---|---|---|---|---|
| Room scene | `ModuleModel.map["roomKey"]` → `/dynamic/rooms/{id}.swf` | `fileServer + patternMap + .swf` | [RoomModel](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/room/RoomModel.as) + `AssetModel.request()` | On teleport (`roomModel.checkMap()`) |
| Item cloth SWF | `ItemModel.itemFileDataDict[clothId]` → filename from `ifile.*` | `fileServer + "/static/items-2x/clothes/{key}"` | [ItemModel.swfTaskList](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/item/ItemModel.as) → `SwfRequest` → `AssetModel` | On avatar dress / inventory refresh |
| Item PNG (clothing render) | Same ItemModel catalog, `r_`-prefixed key | `fileServer + "/static/items-2x/clothes/r_{key}"` | `ItemModel.pngTaskList` → `PngAssetVO` | Avatar preview / shopping UI |
| Smiley | `SmileyModel.smileyDataDict` | `fileServer + "/static/items-2x/smileys/{key}"` | `AssetModel` + chat bubble render | On chat / balloon show |
| Balloon | `ChatBalloonModel` | (internal SWF library or CDN URL) | Speech bubble renderer | On player chat |
| Panel UI | `PanelModel.openPanel()` | `fileServer + "/dynamic/panels-2x/{panelKey}.swf"` | `AssetModel` via `PanelVO.name` lookup | On menu open (shop, profile, settings) |
| Bot NPC | `BotEntry.init()` → `moduleModel.getPath(botKey, "ModuleType.BOT")` | `fileServer + "/static/bots-2x/{botId}.swf"` | `AssetModel.request()` | On NPC spawn in room |

## 7.5 The shipping ceiling — much smaller than originally documented

Earlier drafts of [../PLAN.md](../PLAN.md) and this chapter claimed that past `INIT_READY`
the original CDN (`xo.newmarhab.net`) being dead would force us to re-author
rooms/panels/clothes by hand. The on-disk inventory contradicts that:

| Asset class | Files in `rebuild/inventory/` | Size |
|---|---|---|
| Rooms (`room-assets/files/.../rooms/*.swf`) | **254 SWFs** | 152 MB |
| Panels + extensions + core SWFs (`vf-assets/files/...`) | **85 SWFs** | 24 MB |
| Items per `ifile.1366` (`item-assets-ifile1366/files/`) | **7,190 SWFs + 7,042 PNGs** | 364 MB |
| Probe / curated item subset (`item-assets/files/`) | 73 SWFs + 5 PNGs | 6.6 MB |

So the real ceiling is not "author the assets" — it is **promote them into the
CDN mirror and serve them**:

1. [`rebuild/promote-cdn-mirror.ps1`](../rebuild/promote-cdn-mirror.ps1) copies the three `files/` trees above into [`../assets/cdn-mirror/global/`](../assets/cdn-mirror) (today an empty skeleton with the right shape).
2. [`../server/serve-cdn.ps1`](../server/serve-cdn.ps1) starts an `HttpListener` on `127.0.0.1:8081` and serves that mirror as the runtime CDN.
3. The server's `config` response points `fileServer` at `127.0.0.1:8081` (with `/global` appended client-side).

Residual gaps that DO require re-authoring:

- Any room key in `vf.403`/`vf.19910` whose mapped path is missing from `room-assets/files/`. [`rebuild/inventory/room-assets/missing-room-keys.txt`](../rebuild/inventory/room-assets/missing-room-keys.txt) tracks them.
- Localisation `.mo` files past Arabic — only `ar.mo` is generated locally by [`rebuild/write-local-locale.ps1`](../rebuild/write-local-locale.ps1).
- Anything referenced from a newer `ifile.2013` catalog that the AIR launcher cached but is not in `ifile.1366` — see the version discussion in [12 §12.3](12-our-own-cdn.md#123-decoded-ifile2013--the-itemcloth-catalog).

## 7.6 Server's job re: assets

Server **must** send these in the `config` response:

| Key | Value used today | Purpose |
|---|---|---|
| `fileServer` | `["127.0.0.1:8081"]` (array; client prepends `http://` and appends `/global`) | Base URL for all asset downloads |
| `itemFile` / `itemInfoFile` | `"/static/data/ifile.1366"` | Path to Base64-encoded item catalog (clothes/inventory/smileys/quests) |
| `versionFile` | `"/static/data/vf.403"` | Path to Base64-encoded version catalog (rooms/panels/extensions/core SWFs/locale) |
| `langFile` | `"/static/locale/ar.mo"` (or `en_UK.74.mo` etc.) | Locale file |
| `quality` | `"sd"` (or `"hd"` for `-2x` paths) | Determines `-2x` suffix in asset paths |
| `protocol` | `"http://"` (local dev) or `"https://"` | Protocol for constructing full URLs |

> **Catalog versioning note** — the workspace currently ships `ifile.1366`
> (273 KB, in [rebuild/inventory/vf-assets/files/global/static/data/ifile.1366](../rebuild/inventory/vf-assets/files/global/static/data/ifile.1366))
> and `vf.403` (16,152 B, same folder). A newer `ifile.2013` exists only in
> the AIR launcher cache and a separate `vf.19910` (16,156 B) lives at
> [rebuild/inventory/room-assets/vf.19910](../rebuild/inventory/room-assets/vf.19910).
> Pick **one** pair per environment; `ifile.1366 + vf.403` is the one with a
> matching asset cache on disk.

### Version-catalog format

Both `vf.*` and `ifile.*` are **Base64-encoded strings** of pipe-separated
key=value pairs:

```
roomKey01=/dynamic/rooms/room_01|
roomKey02=/dynamic/rooms/room_02|
...
```

Decoded and loaded by
[VersionModel](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/model/VersionModel.as)
→ populated into
[ModuleModel.map](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/model/ModuleModel.as).

### HTTP file server requirements (today: `server/serve-cdn.ps1`)

The runtime CDN is **not** Tomcat — it is
[`server/serve-cdn.ps1`](../server/serve-cdn.ps1), a PowerShell
`HttpListener` that binds `http://127.0.0.1:8081/` and serves
[`../assets/cdn-mirror/`](../assets/cdn-mirror) as the document root
(the URL `http://127.0.0.1:8081/global/...` resolves to
`assets/cdn-mirror/global/...`).

- MIME table covers `.swf`, `.png`, `.jpg`, `.gif`, `.json`, `.txt`, `.xml`, `.mo`
- Sends `Access-Control-Allow-Origin: *` and `Cache-Control: public, max-age=31536000` on every response
- **No `crossdomain.xml`** is shipped today; if you later move to a non-localhost host you'll need one. The recommended locked-down policy lives in [12 §12.9](12-our-own-cdn.md#129-crossdomain--security-notes); the wildcard CORS is fine for `127.0.0.1` dev but should be tightened before any public deploy.

---

[← Subsystems](06-subsystems.md)  ·  [Index](README.md)  ·  [Next: Database schema →](08-database-schema.md)
