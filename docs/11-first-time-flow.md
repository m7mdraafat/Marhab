# 11. First-time player flow (definitive)

[← Gaps](10-gaps-and-blockers.md)  ·  [Index](README.md)  ·  [Next: Our own CDN →](12-our-own-cdn.md)

This chapter documents the **complete sequence** from a brand-new player
launching the game for the first time to walking inside the first room.
It supersedes the partial gap noted in §10 about `checkAvatar` /
`avatarcreate` — that flow is now fully traced.

## 11.1 The full ten-step sequence

```
1.  Client boots ── SerialCommand chain (see 02-bootstrap.md §2.1)
2.  Splash hits INIT_READY-1 ── controllers + models built
3.  initialize() ──→  requestData("init", {}, onInited)         ─── C → S
4.                                                              ←── S → C  (init response)
5.  onInited() ── store data, check ban/deactivation
6.  EXTENSIONS_LOADED ── process()
7.  process() examines `data.checkAvatar` / `data.createAvatar`:
       checkAvatar == 0    →  AvatarCreatePanel(type="BaseCloth")  ── HALT
       createAvatar == true →  AvatarCreatePanel(params={})         ── HALT
       neither              →  go straight to step 9
8.  AvatarCreatePanel:
       requestData("baseclothes", {}, onListResponse)              ─── C → S
       …user picks clothes + name…
       requestData("savebaseclothes" | "avatarcreate", {…}, cb)    ─── C → S
                                                                   ←── S → C  ({avatarID,…})
       Connectr.reset() ─────────────────────────────────► back to step 3 with avatarId set
9.  Second init response now has checkAvatar != 0 and includes wallet, clothes, room
       process() runs to completion:
         roomModel.checkMap(data)          ─ stores base64-XML room map + doorKey
         avatarModel.updateWallet(...)
         clothModel.load(data.clothes.items)
         engine.start()
         dispatch INIT_READY
10. SFS auto-joins the room set by the server
       → RoomController.onJoinRoom → startload → IsoEngine.changeScene
       → SceneProcessDataComponent.load downloads room SWF
       → processSceneData spawns the avatar at UserVariable position+direction
       → requestData("roomjoincomplete", {}, null)                 ─── C → S
                                                                   ←── S → C  (roomjoincomplete push)
       → IsoScene.onRoomJoinComplete sets sceneLoaded = true
       → RoomController.onSceneLoaded → engine.showScene() → walking enabled
```

Cite [Sanalika.as](../rebuild/inventory/snl_780_src/scripts/Sanalika.as) L551–L757 and
[AvatarCreatePanel.as](../rebuild/inventory/avatar_create_panel_src/scripts/org/oyunstudyosu/sanalika/panels/avatarCreate/AvatarCreatePanel.as) L122–L499 for everything in steps 7–9.

## 11.2 The `process()` decision tree (exact code)

[Sanalika.as L705-L757](../rebuild/inventory/snl_780_src/scripts/Sanalika.as):

```as3
private function process(param1:GameEvent):void
{
   Dispatcher.removeEventListener("EXTENSIONS_LOADED", process);
   serviceModel.removeRequestData("init", onInited);
   avatarModel.gender = data.gender;
   avatarModel.guest  = data.guest;
   achievementModel.rewardCount = data.completedAchievementsCount;

   // ── HALT PATH 1: first-ever guest, must pick a base outfit ──
   if (data.checkAvatar == 0)
   {
      Dispatcher.dispatchEvent(new OSProgressEvent("INIT_PROGRESS", ProgressVo.PROGRESS_FULL));
      panelVo = new PanelVO();
      panelVo.name = "AvatarCreatePanel";
      panelVo.type = "BaseCloth";          // restricted mode
      panelModel.openPanel(panelVo);
      return;
   }

   avatarModel.isBaseClothSelected = true;

   // ── HALT PATH 2: registered but needs full avatar creation ──
   if (data.createAvatar)
   {
      Dispatcher.dispatchEvent(new OSProgressEvent("INIT_PROGRESS", ProgressVo.PROGRESS_FULL));
      vo = new PanelVO();
      vo.name   = "AvatarCreatePanel";
      vo.params = {};                       // full create mode
      panelModel.openPanel(vo);
      return;
   }

   // ── NORMAL PATH: load room, wallet, clothes, then start engine ──
   roomModel.checkMap(data);
   avatarModel.updateWallet(data.wallet);
   clothModel.load(data.clothes.items);
   avatarModel.holdedItem = null;
   avatarModel.lastHoldedItem = null;
   hudModel.init();
   controllerList[BuddyController] = new BuddyController();
   engine.start();
   Dispatcher.dispatchEvent(new OSProgressEvent("INIT_PROGRESS", ProgressVo.INIT_READY));
   cookieModel.startCheck();
   data = null;
}
```

### When does the server set `checkAvatar` / `createAvatar`?

| Account state | `checkAvatar` | `createAvatar` | Panel mode |
|---|---|---|---|
| Brand-new guest, no avatar at all | `0` | (any) | **BaseCloth** (skin/hair/body only) |
| Email account, finished signup, no avatar yet | `!= 0` | `true` | **Full create** (name + clothes + gender) |
| Returning player | `!= 0` | `false` / missing | none — go straight to room |

## 11.3 AvatarCreatePanel — exact wire contract

### Step A — Panel fetches available base clothes

[AvatarCreatePanel.as L122-L165](../rebuild/inventory/avatar_create_panel_src/scripts/org/oyunstudyosu/sanalika/panels/avatarCreate/AvatarCreatePanel.as):

```as3
Connectr.instance.serviceModel.requestData(
    RequestDataKey.BASE_CLOTHES,   // = "baseclothes"
    {},
    this.onListResponse
);
```

**Server reply shape** (consumed by `initList()`):

```jsonc
{
  "f": [                                  // female outfits
    { "placeBit": 0,  "clip": "f_body_001",  "colors": [1,2,8,12] },
    { "placeBit": 1,  "clip": "f_shirt_002", "colors": [3,4]      },
    { "placeBit": 17, "clip": "f_hair_005",  "colors": [9]        }
  ],
  "m": [                                  // male outfits
    { "placeBit": 0,  "clip": "m_body_001",  "colors": [1,2,8,12] },
    …
  ]
}
```

`placeBit` is the bit index in the ClothType bitset
(see [05 §5.3](05-enums-and-types.md#53-cloth-layer-slots-critical-for-outfit-conflict-checks))
— body, leg, hair, hat, etc. `colors` is optional; if missing the cloth has no color variants.

### Step B — Confirm sends one of two requests

[AvatarCreatePanel.as L419-L480](../rebuild/inventory/avatar_create_panel_src/scripts/org/oyunstudyosu/sanalika/panels/avatarCreate/AvatarCreatePanel.as):

```as3
if (data.type == "BaseCloth")
{
   Connectr.instance.serviceModel.requestData(
      RequestDataKey.SAVE_BASE_CLOTHES,     // = "savebaseclothes"
      { clothes: _loc2_, gender: this.gender, avatarName: this.nInpAvatarName.text },
      this.saveResponseFunction
   );
}
else
{
   Connectr.instance.serviceModel.requestData(
      RequestDataKey.AVATAR_CREATE,         // = "avatarcreate"
      { clothes: _loc2_,
        avatarName: this.nInpAvatarName.text,
        gender: this.gender,
        token: Connectr.instance.avatarModel.accessToken },
      this.saveResponseFunction
   );
}
```

`_loc2_` is an array of `{ clip: string, color?: int }` (color omitted when the
chosen cloth defines no color variants).

### Step C — Server replies and client kicks itself

[AvatarCreatePanel.as L485-L499](../rebuild/inventory/avatar_create_panel_src/scripts/org/oyunstudyosu/sanalika/panels/avatarCreate/AvatarCreatePanel.as):

```as3
if (param1.errorCode != null) { /* show message, re-enable */ return; }
Connectr.instance.avatarModel.data.saveAvatarImage = true;
Connectr.instance.avatarModel.isBaseClothSelected  = true;
Connectr.instance.avatarModel.avatarId             = param1.avatarID;
close();
Connectr.instance.reset();   // ← restarts the bootstrap from LoginCommand
```

`Connectr.reset()` is [Sanalika.as L161-L168](../rebuild/inventory/snl_780_src/scripts/Sanalika.as):
sends `LogoutRequest` and on `LOGOUT_COMPLETE` re-runs `LoginCommand`. The
second pass through `init` now returns `checkAvatar != 0`, the panel doesn't
re-open, and `process()` falls through to the normal room-load path.

### Server contract summary

| Request | Required reply fields | Side effects on success |
|---|---|---|
| `baseclothes` | `{ f:[…], m:[…] }` arrays of `{placeBit, clip, colors?[]}` | none |
| `savebaseclothes` | `{ avatarID:int }` or `{ errorCode, message }` | persist outfit as base, create avatar row |
| `avatarcreate` | same | persist outfit + name, create avatar row |

Both `savebaseclothes` and `avatarcreate` must return an `errorCode` on
failure so the panel re-enables the confirm button.

## 11.4 The first room — recommendation

The server is **fully authoritative** on which room a new avatar enters
first. The client has no hard-coded fallback.

After `Connectr.reset()` triggers a fresh `init`, the server includes a
`data.room` object (handled by `roomModel.checkMap()`,
[RoomModel.as L306-L312](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/room/RoomModel.as)).
SFS then auto-joins the room and the client renders.

**Recommended first room**: `street01` → SWF `st01-dark3.swf`
(per `vf.19910`). Reasoning:

1. It is referenced everywhere in the strings dump.
2. It's a `STREET` (public, no flat owner) — no ownership permissions to
   resolve on first login.
3. Its SWF was the most-requested room in the original telemetry.
4. The existing test path
   [Sanalika.testStreet()](../rebuild/inventory/snl_780_src/scripts/Sanalika.as) (L547)
   already uses `testStreet` as a debug roomKey — production should use
   `street01`.

> **Note on the user's mental shorthand:** the client refers to this room as
> `street01`, not `st01`. The `st01-dark3.swf` filename is just what the
> version catalog (`vf.19910`) resolves `street01` to. Always use
> `roomKey="street01"` in handler responses; the catalog handles the rest.
> See [07 §7.4](07-asset-pipeline.md#74-asset-loading-model-at-runtime--the-two-layer-indirection).

## 11.5 Spawn position — exactly where the avatar appears

The avatar's first-room spawn comes from **the user's own UserVariables**,
which the server must set before the SFS room-join completes:

| UserVariable | Value the server sets at spawn |
|---|---|
| `position` | `"{targetX},{targetY}"` from the room's first door (or any explicit spawn point) |
| `direction` | `targetDir` (Direction enum 1–8) of the chosen spawn door |
| `speed` | account's walk speed (1.0 default, 1.5 VIP, etc.) |
| `status` | `"i"` (idle) |
| `clothes`, `gender`, `avatarName`, `avatarSize`, `smiley`, `hand` | per the avatar's saved state |

The client reads them in [RoomController.startload() L383-L385](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/room/RoomController.as):

```as3
Sanalika.instance.avatarModel.position  = sfs.mySelf.getVariable("position").getStringValue();
Sanalika.instance.avatarModel.direction = sfs.mySelf.getVariable("direction").getIntValue();
```

…and [SceneProcessDataComponent.processSceneData() L178-L210](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/engine/scene/components/SceneProcessDataComponent.as):

```as3
var _loc7_:Array = Sanalika.instance.avatarModel.position.split(",");
_loc3_ = int(parseInt(_loc7_[0]));
_loc2_ = int(parseInt(_loc7_[1]));
if (!_loc15_.isSpectator)
{
   _loc15_.reLocate(_loc3_, _loc2_, Sanalika.instance.avatarModel.direction);
}
```

[RoomModel.getDefaultPosition() L375-L387](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/room/RoomModel.as)
is the client-side helper that picks "first door" if no specific spawn was
provided:

```as3
public function getDefaultPosition():Point
{
   var _loc1_:Array = doorModel.keyList;
   if (_loc1_.length > 0)
   {
      var key:String = doorModel.keyList[0];
      var door:IDoorVO = doorModel.getDoorById(key);
      return new Point(door.x, door.y);    // first door's targetX/targetY
   }
   return new Point();   // (0,0) fallback
}
```

The server should mirror the same logic when no explicit spawn is configured:
**spawn = first entry in `doors` JSON, position = `(targetX, targetY)`,
direction = `targetDir`**.

## 11.6 Server checklist for the first-time flow

Implementation order maps directly to [09 Wave 1-3](09-server-build-plan.md):

1. **Wave 1 — `LoginEventHandler` + `config` + `init`** must return `checkAvatar=0` for any new account with no avatar row.
2. **Wave 2 — `baseclothes` + `savebaseclothes` + `avatarcreate`** must persist the avatar, return `{avatarID}`, and accept the panel's `clothes:[{clip,color}]` shape.
3. **Wave 2 — after avatar exists**, the next `init` must:
   - return `checkAvatar != 0`, `createAvatar:false`,
   - include `wallet:{sanil, diamond}`, `clothes:{items:[…]}`,
   - include `room:{ map: base64-xml, doorKey:"d1" }`,
   - set up the SFS room `street01` with all RoomVariables in §11.5,
   - set the user's `position`/`direction` to the spawn before the SFS auto-join.
4. **Wave 3 — walking + chat** unlocks the rest of the experience.

The flow is **fully implementable today** with the data already in the
rebuild folder — see [12-our-own-cdn.md](12-our-own-cdn.md) for sourcing the
catalogs and per-asset URLs.

---

[← Gaps](10-gaps-and-blockers.md)  ·  [Index](README.md)  ·  [Next: Our own CDN →](12-our-own-cdn.md)
