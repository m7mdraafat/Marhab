# 4. Rooms, streets, walking, doors

[← Protocol catalog](03-protocol-catalog.md)  ·  [Index](README.md)  ·  [Next: Enums & types →](05-enums-and-types.md)

> This is **the most important chapter for the server build**. The walking
> model and the room-map format determine 90% of the wire traffic and
> 100% of whether the game *feels* right. The room SWF + grid + map are the
> source of truth; everything else fits around them.

## 4.1 Room types

[enums/UserRoomTypes.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/enums/UserRoomTypes.as):
`HOUSE`, `CAFE`, `GARAGE`, `HOSPITAL`, `LAND`, `OFFICE`.

Anything not in this enum is a **public street/room** (game-owned, no
`ownerID`). 253 rooms total live in the version catalog `vf.19910`
(see [12 §12.2](12-our-own-cdn.md#122-decoded-vf19910--the-master-version-catalog)).
User-owned rooms live in the `flats` table and address themselves by `flatID`.

## 4.2 What a "room" actually consists of at runtime

A fully-joined room is **6 synchronized systems**:

| # | System | Source | Citation |
|---|---|---|---|
| 1 | **Room SWF** (DefineSprite hierarchy) | downloaded from CDN via `ModuleType.ROOM` | [SceneProcessDataComponent.load()](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/engine/scene/components/SceneProcessDataComponent.as) L68 |
| 2 | **RoomVariables** (server-set, SFS-broadcast) | `RoomController.startload()` reads them | [RoomController.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/room/RoomController.as) L336-L430 |
| 3 | **UserVariables** of every user in the room | server-authoritative; SFS auto-broadcasts | [RoomController.startload()](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/room/RoomController.as) L383-L385 |
| 4 | **The room map XML** (base64-encoded; lives in `room.map` field of the join payload) | parsed by `RoomModel.checkMap()` → `IsoScene.processMap()` | [RoomModel.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/room/RoomModel.as) L306-L312, [IsoScene.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/engine/IsoScene.as) L601 |
| 5 | **Walkability grid** (base64 ByteArray, in the `grid` RoomVariable) | parsed by `GridModel.load()` → array of `Cell` objects | [GridModel.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/model/GridModel.as) L105-L130 |
| 6 | **Doors / portals** (in the `doors` RoomVariable as JSON) | parsed by `DoorModel.loadJSON()` → `IDoorVO[]` | [DoorModel.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/door/DoorModel.as) L70-L91 |

The IsoScene renders into a stacked container hierarchy
([IsoScene.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/engine/IsoScene.as) L120-L142):

```
scene.container (root Sprite)
├─ bgContainer        (room background bitmap)
├─ floorContainer     (floor entries, entryType=8)
├─ cursor             (the tile reticle)
├─ elementsContainer  (furniture, characters, doors)
├─ speechContainer    (chat balloons)
└─ ceilingContainer   (overlay effects)
```

Depth sorting is handled by
[GridManager.doFixedObjectOperations()](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/engine/grid/GridManager.as)
L84-L203 (backward sweep over map entries).

## 4.3 The room map XML — exact schema

The map is **base64-encoded XML** delivered in the join payload at
`data.room.map`. Parsed and stored by
[RoomModel.checkMap()](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/room/RoomModel.as) L306-L312
and processed by
[IsoScene.processMap()](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/engine/IsoScene.as) L601.

### Root

```xml
<map xOrigin="123" yOrigin="456">
  …
</map>
```

`xOrigin` / `yOrigin` are the isometric **screen-pixel offsets** for world
origin (0,0,0). They calibrate the projection (see §4.6).

### Entry elements (full type table)

The XML tag is determined by `MapEntry.entryType` →
[MapEntryType.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/engine/core/MapEntryType.as):

| entryType | Constant | XML tag emitted | Notes |
|---|---|---|---|
| 0 | `NORMAL` | `<box>` | also `<billboard>` when `arg="billboard"` |
| 1 | `CHAIR` | `<chair>` | may contain `<chairs>` sub-grid |
| 2 | `ATARI` | (in-room game cabinet) | `Cell.playable=true` |
| 3 | `USABLE` | `<stuff>` | one-shot interactive (paintings, ATM, …) |
| 4 | `POOL` | `<pool>` | non-walkable water surface |
| 5 | `POOL_ENTRY` | `<poolEntry>` | walkable swim-entry tile |
| 6 | `FARM` | `<farm>` | growable plot |
| 7 | `CENCORED_OBJECT` | `<cencor count="…">` | reserved seating cluster |
| 8 | `FLOOR_OBJECT` | `<floor>` | the **only** type that does NOT flip cells to `TYPE_DISABLED` |
| 9 | `CINEMA_DOOR` | (door variant) | enter a cinema screening |
| 10 | `CINEMA_SCREEN` | `<cinema>` | film playback surface |
| 11 | `EXHIBITION` | `<exhibition>` | uploaded user-art frame |
| 12 | `METRO` | (transport node) | street-metro stop |
| 13 | `SERVER_TIMER` | (countdown display) | shows server-side timer |
| 14 | `AIRPLANE` | (transport node) | airline boarding |
| 15 | `MONITTE_GROUND` | (mini-game ground) | mini-game pad |
| 16 | `BILLBOARD` | (`<box arg="billboard">`) | ad slot |
| 17 | `YOUTUBE_SCREEN` | `<youtube>` | YouTube playback surface |
| 18 | `VIDEO_SCREEN` | (generic video) | non-YouTube video |
| 21 | `SOUND` | `<sound>` | invisible audio emitter |

Concrete inline samples:

```xml
<box     id="0"   definition="tree_01"     x="5"  z="3"  y="0" f="1" w="1" d="1" h="20"/>
<chair   id="102" definition="chair_red"   x="10" z="8"  y="0" f="1" w="1" d="1" h="30" dir="4">
  <chairs>
    <chair x="10" z="8" dir="4" h="30"/>
  </chairs>
</chair>
<stuff   id="200" definition="painting_01" x="12" z="5"  y="0" f="1" w="1" d="1" h="10" a="paint" tc="[11, 6]"/>
<floor   id="500" definition="rug_01"      x="2"  z="2"  y="0" f="1" w="2" d="2" h="2"/>
<poolEntry id="301" x="20" z="15" y="0" w="2" d="2"/>
<pool      id="300" x="20" z="15" y="0" w="2" d="2" h="15"/>
<farm      id="400" x="30" z="20" y="0" w="1" d="1" h="5" def="wheat_stage1"/>
<cencor    id="600" x="50" z="30" y="0" w="2" d="2" count="3"/>
<cinema    id="700" definition="screen_01" x="60" z="40" y="0" w="3" d="2" h="40"/>
<youtube   .../>     <sound .../>
```

### Attribute reference (all entry types)

| Attr | Type | Meaning |
|---|---|---|
| `id` | string | unique entry id (`"0"` = no logical entry, just visual) |
| `definition` | string | furniture SWF symbol key (`"door_1"`, `"tree_oak"`, …) |
| `x`, `z` | int | grid cell coords (x = column, z = row) |
| `y` | int | height offset (usually 0 for floor objects) |
| `f` | int | starting frame (1-indexed) |
| `w`, `d`, `h` | int | width (cells), depth (cells), height (pixels) |
| `s`, `fx`, `lc`, `st`, `sv` | int | state, flip-x, lock count, stock total, stock current |
| `dir` | int | facing direction (1–8, default 4 = SOUTH) |
| `interactive` | `"true"`/`"false"` | if true, contains JSON property as CDATA |
| `ext` | int | extension version |
| `v` | int | definition version (used in URL suffix) |
| `enabled` | `"0"`/`"1"` | entry active (default 1) |
| `mask` | string | optional mask definition name |
| `a` | string | art/animation hint (used by some types) |
| `tc` | `"[r, g]"` | tint color array (used by `<stuff>`) |
| `count`, `def` | misc | per-type extras (cencor, farm) |

### Interactive properties — CDATA payload

```xml
<box id="105" interactive="true" definition="door_north" x="10" z="0" w="1" d="1" h="40" dir="2">
  <![CDATA[{
    "cn": "PassageProperty",
    "metaKey": "105",
    "roomKey": "street02",
    "type": "door"
  }]]>
</box>
```

`cn` ("class name") is the AS3 property class the client dynamically
instantiates via `getDefinitionByName("com.oyunstudyosu.property." + cn)`.
See [06 §6.10](06-subsystems.md#610-property-pattern-the-magic-that-powers-interactive-objects)
for the full property catalog.

## 4.4 The walkability grid (`grid` RoomVariable)

Format: **Base64 of a ByteArray** with header + cell payload. Parsed by
[GridModel.load()](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/model/GridModel.as) L105-L130.

### Binary layout

```
offset  bytes  meaning
0       4      int width  (big-endian, AS3 ByteArray default)
4       4      int height
8…     w×h     1 byte per cell, row-major: cell(x,y) at offset 8 + y*width + x
```

### Cell value → cell type ([CellType.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/engine/core/CellType.as))

| Byte value | Cell type | Walkable by |
|---|---|---|
| `0` | `TYPE_EMPTY` | anyone (subject to role-bit) |
| `-1` | `TYPE_WALK_ONLY` | anyone (and bit-checks are bypassed when char.bit==1) |
| `3` | `TYPE_DISABLED` | nobody |
| `4` | `TYPE_DIAMOND` | `DIAMOND_CLUB` permission |
| `5` | `TYPE_ADMIN` | `MODERATOR` permission |
| `6` | `TYPE_TARGET` | usable target (chair-like target cells; `Cell.usable=true`) |
| `7` | `TYPE_FISH` | fishing-only marker cell |
| `8` | `TYPE_SANALIKAX` | `CARD_SANALIKAX` permission |
| `10` | `TYPE_SHORTCUT` | `GAME_SHORTCUT` permission |
| `11` | `TYPE_NPC` | `NPC` permission (bots) |
| `12` | `TYPE_STAGE` | `STAGE` permission |
| `13` | `TYPE_FURNITURE_ONLY` | no avatar; reserved for furniture footprints |

> **Earlier drafts of this doc swapped `6`↔`13` and dropped `7`.** The
> source of truth is [CellType.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/engine/core/CellType.as).

### Walkability check ([Cell.isWalkable](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/engine/core/Cell.as))

The full predicate is **not** the one-liner usually quoted — it is the
bitmask check **OR** an explicit permission gate per cell type:

```as3
// either: cell role-bit is a subset of char bits AND cell is plain ground
((bit | char.bit) == char.bit || (char.bit == 1 && bit < 0))
  && (cellType == TYPE_EMPTY || cellType == TYPE_WALK_ONLY)

// or: cell is a role-gated tile and the char carries the matching permission
|| (cellType == TYPE_SANALIKAX  && permission.check(CARD_SANALIKAX))
|| (cellType == TYPE_DIAMOND    && permission.check(DIAMOND_CLUB))
|| (cellType == TYPE_ADMIN      && permission.check(MODERATOR))
|| (cellType == TYPE_SHORTCUT   && permission.check(GAME_SHORTCUT))
|| (cellType == TYPE_NPC        && permission.check(NPC))
|| (cellType == TYPE_STAGE      && permission.check(STAGE))
```

`isWalkableBit(bit)` is the AStar fast-path used when no character object is
available — it only checks the bitmask + `TYPE_EMPTY`/`TYPE_WALK_ONLY` and
does **not** unlock the role-gated cell types. AStar therefore needs to be
called with a real character whenever the user is walking through admin /
diamond / shortcut tiles, otherwise pathfinding will refuse them.

## 4.5 Door / portal system

| Door cmd | Where it lives | Payload | Server contract |
|---|---|---|---|
| `usedoor` | [FlatExitProperty.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/property/FlatExitProperty.as) (and any non-door entry whose `data.type != "door"` falls through `PassageProperty`) | `{ key:"<doorKey>", type:"<data.type>" }` — `type` is whatever was stored on the property's `data.type`; for door-loaded properties [`DoorVO.setProperty`](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/door/DoorVO.as) overwrites it with `"door"` before the property is ever executed | Resolve target room via room's `doors[key]`, switch SFS room, set spawn position to `targetX/targetY/targetDir` |
| `usehousedoor` | [DoorModel.useHouseDoor L75-L88](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/door/DoorModel.as) | `{ flatID, password, avatarID }` | Validate ban/password, load flat room, spawn at flat's entry door |
| `useobjectdoor` | [FlatEnterProperty L29](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/property/FlatEnterProperty.as) | `{ id: <metaKey of placed entry> }` | Look up placed-object metaKey in the room's furniture, switch to its linked interior (CAFE/GARAGE/…) |
| `teleport` | [Sanalika.testStreet L549](../rebuild/inventory/snl_780_src/scripts/Sanalika.as), [TeleportProperty L13](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/property/TeleportProperty.as) | `{ roomKey }` | Free teleport (admins / portals); same as join flow |

> **`PassageProperty` quirk** — its `execute()` returns early when
> `data.type == "door"`. Since `DoorVO.setProperty` ALWAYS stamps
> `data.type="door"` on door-loaded properties, `PassageProperty` is a
> no-op when fired from a door click. It only sends `usedoor` when it is
> attached to an interactive map entry (street-level passage that is NOT
> a door — e.g. an open archway), because EntryModel does not rewrite
> `type`. The server should treat `usedoor` purely as "use the door
> referenced by `key`" and ignore `type` — the field is historical
> routing information.

### Door definition shape (the `doors` RoomVariable JSON)

```jsonc
[
  {
    "key": "d1",
    "targetX": 8,
    "targetY": 10,
    "targetDir": 3,
    "property": { "cn": "PassageProperty", "roomKey": "street02" }
  },
  {
    "key": "d2",
    "targetX": 15,
    "targetY": 20,
    "targetDir": 1,
    "property": { "cn": "TeleportProperty", "roomKey": "academy" }
  }
]
```

`property.type` does NOT need to be sent — `DoorVO.setProperty` overwrites
it to `"door"` after instantiation regardless. Any other keys (`roomKey`,
`metaKey`, `flatID`, …) are passed through to the property `data` blob
and consumed by the specific property's `execute()`.

### Property class names referenced by `DoorVO.setProperty()`

[DoorVO.as L120-L160](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/door/DoorVO.as) — the
client recognises these in door payloads (resolved via
`getDefinitionByName("com.oyunstudyosu.property." + cn)`):

```
EmptyProperty          ExchangeProperty       ExternalLinkProperty
FlatEnterProperty      FlatExitProperty       FlatSponsorPanelProperty
GameProperty           GatheringProperty      GiftOnceProperty
InviteGiftProperty     JSFunctionProperty     NickChangePanelProperty
PanelProperty          PassageProperty        PaymentPanelProperty
ProfessionPanelProperty                       RoomPanelProperty
RoomShopPanelProperty  SaleItemPanelProperty  SaleProductPanelProperty
ShopPanelProperty      SimpleBotMessageProperty                SolariumPanelProperty
SpeechProperty         TableTopGameProperty   TeleportProperty
TopListProperty        VipCardPanelProperty
```

(`FarmProperty`, `FrameProperty`, `GridSealingProperty`, `ThrowProperty`
also live in the `property/` package but are attached to interactive map
entries via `EntryModel`, not loaded by `DoorVO.setProperty` directly.)

## 4.6 Isometric coordinate system — exact math

Constants ([IsoScene.as L69-L70](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/engine/IsoScene.as)):

| Constant | Value | Meaning |
|---|---|---|
| tile size | `18.07` px | Both `tileWidth` and `tileHeight` |
| `cos` | `0.9483255309738488` | ≈ cos(18.43°) — isometric tilt |
| `sin` | `0.31729905027145594` | ≈ sin(18.43°) |

### Grid cell → world 3D position

[IsoScene.getScenePositionFromTile()](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/engine/IsoScene.as) L654-L657:

```as3
new Vector3d(
  (x + 1) * 18.07 - 18.07 / 2,   // center of cell, X axis
  0,                              // ground plane
  (z + 1) * 18.07 - 18.07 / 2    // center of cell, Z axis
)
```

### World 3D → screen pixel

[IsoScene.get2dPoint(x, y, z)](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/engine/IsoScene.as) L659-L666:

```as3
screenX = (x - z) * cos + xOrigin
screenY = -(y + (x + z) * sin) + yOrigin
```

`xOrigin`/`yOrigin` come from the map XML root attributes (§4.3).

### Screen pixel → grid cell (mouse → tile)

[IsoScene.translateStageCoordsTo3DCoords()](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/engine/IsoScene.as) L825-L835:

```as3
let dx = xOrigin - screenX
let dy = yOrigin - screenY
let tileZ = (dx / cos + dy / sin) / 2
let tileX = (-dy / sin + dx / cos) / -2
```

### Direction enum from delta

[IntPoint.getDir()](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/engine/IntPoint.as) L18-L35:

```as3
let angle = Math.round(Math.atan2(dy, dx) * 180 / Math.PI / 45)
if (angle == 0) return 2   // EAST
if (angle == 1) return 1   // NORTH_EAST
return angle > 0 ? (10 - angle) : (2 - angle)
```

Mapping (8 sectors):

| Direction | Value | Cardinal |
|---|---|---|
| `NORTH_EAST` | 1 | NE ↗ |
| `EAST` | 2 | E → |
| `SOUTH_EAST` | 3 | SE ↘ |
| `SOUTH` | 4 | S ↓ |
| `SOUTH_WEST` | 5 | SW ↙ |
| `WEST` | 6 | W ← |
| `NORTH_WEST` | 7 | NW ↖ |
| `NORTH` | 8 | N ↑ |

## 4.7 Pathfinding — client-side A*

[engine/path/AStar.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/engine/path/AStar.as).

```as3
new AStar(
  map:    Vector.<Cell>,   // flattened grid (width * height)
  width:  int,
  height: int,
  start:  IntPoint,
  goal:   IntPoint,
  bit:    int              // user's role bitmask
).solve(character: ICharacter = null): Vector.<IntPoint>
```

Returns `null` if no path. Cost function:

| Move | Cost |
|---|---|
| Cardinal (N/S/E/W) | **2** |
| Diagonal (NE/SE/SW/NW) | **3** (requires both cardinals walkable) |

Walkability test uses `Cell.isWalkable(character)` if character provided, else
`Cell.isWalkableBit(bit)`. No hardcoded max-path-length cap.

**Failure path** (from
[Character.calculatePath()](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/engine/character/Character.as) L1388-L1402):
if AStar returns `null`, the client just calls `reLocate(targetX, targetY, direction)`
locally — snaps the avatar. The server should refuse the walk and not commit
position (otherwise cheaters could teleport).

## 4.8 Character walk loop — exact timing

[Character.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/engine/character/Character.as).

### The tick

```as3
UPDATE_INTERVAL      = 0.040160642570281124   // ≈ 25 ms (40 ticks/sec)
MAX_UPDATES_PER_TICK = 10                     // catch-up cap if frame stutters
```

[Character.onUpdateEvent() L274-L300](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/engine/character/Character.as):

```as3
while (now - lastTime > UPDATE_INTERVAL) {
    if (++ticks >= MAX_UPDATES_PER_TICK) { lastTime = now; break }
    update()
    lastTime += UPDATE_INTERVAL
}
```

### Steps per tile

[Character.defineSteps()](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/engine/character/Character.as) L1657-L1696:

| Move kind | Substeps per tile | Wall-clock @ speed=1.0 |
|---|---|---|
| Cardinal | `int(7 / speed)` = 7 | 7 × 25 ms = **175 ms** |
| Diagonal | `int(11 / speed)` = 11 | 11 × 25 ms = **275 ms** |

With VIP `speed=1.5`: cardinal = `int(7 / 1.5)` = 4 substeps = 100 ms/tile.

### Server walk-delay formula (recommended)

Server must compute `delay` matching this so the avatar doesn't desync.
Run A* server-side to get the path, then:

```
delay_ms =
    cardinal_tiles  * 7  * 25 / speed +
    diagonal_tiles * 11 * 25 / speed
delay_ms = max(delay_ms, MIN_DELAY_MS=100)
```

Add a small grace period (≈ 200 ms) before timing out the `WalkSession`.

### Local vs broadcast

| What | When | Channel |
|---|---|---|
| `scenePosition` (visual) | every tick, locally | none — local interpolation |
| `direction` UserVariable | immediately after walk completes locally | SFS user-variable update (broadcast) |
| `position` UserVariable (`"x,y"`) | only after `walkfinalrequest` | SFS user-variable update (broadcast) |

## 4.9 The walk request lifecycle — end-to-end

```
1. user clicks a tile
   ─ SceneMouseInteractionComponent.onMouseDown
       → myChar.walkRequest(scene.activeGrid.x, scene.activeGrid.y)

2. Character.walkRequest(x, y, doorClip?)
   ─ requestData("walkrequest", {x, y, door: doorClip != null}, fakeListener)        C → S
   ─ calculatePath() runs AStar locally; if a path exists, sets `this.path`
   ─ enterFrame handler starts; avatar visibly walks

3. server validates
   ─ user in room?
   ─ AStar(serverGrid, start, (x,y), userBit) → path?
   ─ if path null OR move not allowed → reply errorCode, ignore
   ─ compute delay (§4.8)
   ─ create WalkSession(userId, x, y, expiresAt)
   ─ push extension "walkrequest"  { delay: <ms> }                                    S → C

4. WalkModel.onWalkStart(p):
   ─ clearTimeout(walkTimeout)
   ─ walkTimeout = setTimeout(walkTimerComplete, p.delay)

5. walkTimerComplete():
   ─ requestData("walkfinalrequest", {}, null)                                        C → S

6. server commits
   ─ session = sessions[userId]; reject if missing or expired
   ─ (optional) revalidate grid still walkable
   ─ SetUserVariables(position = "x,y", direction = computeDir(...))
   ─ SFS auto-broadcasts user-var change to every other client in the room
   ─ if door:
       resolve target room via current room's doors[key]
       trigger room change → new SFS join → new room map
   ─ delete sessions[userId]
```

Citations:
[Character.walkRequest()](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/engine/character/Character.as) L1405-L1425,
[WalkModel.onWalkStart() / walkTimerComplete()](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/model/WalkModel.as) L14-L24.

## 4.10 The complete "join a room" timeline

```
1. Client initiates entry
     - teleport({roomKey})           → public street / fast travel
     - usedoor({key,type:"door"})    → street ↔ street passage
     - usehousedoor({flatID,…})      → enter another user's HOUSE
     - useobjectdoor({id})           → enter object's interior (CAFE/GARAGE/…)

2. Server selects the SFS Room (creates on demand for flats), sends SFS JoinRoom

3. SFS fires roomJoin → RoomController.onJoinRoom(event)
     - currentRoom = event.room
     - if (mapInitialized) startload() else wait for ROOM_MAP_INITIALIZED

4. Server pushes the room map → RoomModel.checkMap()
     - decodes the base64 XML (§4.3) + caches doorKey
     - dispatches ROOM_MAP_INITIALIZED

5. RoomController.startload() [L336-L430]
     - read RoomVariables (width, height, grid, doors, bots, ownerID, roomTitle, flatID, roomID, source)
     - read own UserVariables (clothes, gender, position, direction, speed, smiley, hand)
     - engine.changeScene() → IsoScene

6. IsoScene attaches components:
     SceneDoorComponent + SceneCameraComponent +
     SceneCharacterComponent + SceneProcessDataComponent
   → registers extension listener for "roomjoincomplete"

7. SceneProcessDataComponent.load()
     - moduleModel.getPath(roomKey, "ModuleType.ROOM") → /dynamic/rooms/{vf[key]}.swf
     - downloads room SWF + every furniture SWF in the map
     - processSceneData(): spawn map entries + doors + bots + background + self avatar
       - avatar.init(avatarId, scene, 0, gender, clothes)
       - avatar.reLocate(posX, posY, direction) from "position" UserVariable

8. SceneProcessDataComponent emits requestData("roomjoincomplete", {}, null)         C → S

9. Server replies via roomjoincomplete push                                          S → C
   → IsoScene.onRoomJoinComplete()
       sceneLoaded = true
       Dispatcher.dispatchEvent("SCENE_DATA_LOADED")

10. RoomController on SCENE_LOADED:
     - for every other SFS user already in the room → addChar()
     - chat input + walking handlers enabled
```

## 4.11 What the server must produce for a room join

A concrete checklist. Implementing all of this is exactly Wave 4 of
[09 Server build plan](09-server-build-plan.md#wave-4--doors-and-room-transitions).

### Mandatory RoomVariables (set atomically before SFS room-join event)

| Variable | Type | Notes |
|---|---|---|
| `roomKey` | string | unique room id (must match a `vf` catalog entry) |
| `width`, `height` | int | grid dimensions in pixels (divide by 18.07 for cell count) |
| `grid` | string | base64 of the ByteArray described in §4.4 |
| `doors` | JSON | array of `{key, targetX, targetY, targetDir, property}` (§4.5) |
| `type` | string | room type (street, house, business, …) |
| `title` / `roomTitle` | string | display name |
| `bots` | JSON | optional, NPC list |
| `extensions` | JSON | optional, room-specific extension scripts |
| `ownerID`, `ownerName`, `flatID`, `roomID` | optional | user-owned flat metadata |
| `scene`, `source` | optional | scene class override / extra data |

### Map payload (in the join response, not a RoomVariable)

```jsonc
{
  "room": {
    "map": "<base64-encoded XML per §4.3>",
    "doorKey": "d1"   // which door of the new room the user enters from
  }
}
```

### Joining user's own UserVariables (set immediately before SFS join)

| Variable | Value at spawn |
|---|---|
| `position` | `"<targetX>,<targetY>"` from the spawn door |
| `direction` | `targetDir` (1–8) |
| `speed` | account walk speed |
| `status` | `"i"` (idle) |
| `clothes`, `gender`, `avatarName`, `avatarSize`, `smiley`, `hand` | per saved avatar state |

### Handler obligations

- **`roomjoincomplete`** request handler must reply with a `roomjoincomplete`
  push (empty payload is fine) — this is the explicit "you may render" gate.
- **`walkrequest`** must respond with `{delay}` per §4.8 and register a
  `WalkSession` per §4.9.
- **`walkfinalrequest`** must commit `position`/`direction` and clear the
  session — and trigger room change if the walk targeted a door.

## 4.12 Sample concrete room — `street01`

| Step | Resolution |
|---|---|
| Client teleport | `requestData("teleport", {roomKey:"street01"}, null)` |
| Server resolves SFS room | creates / loads SFS Room with `name="street01"`, `groupId="street"` |
| Server sets `roomKey` RoomVariable | `"street01"` |
| Server provides map XML in join payload | (decoded from our `rooms/st01-dark3` repo asset, once we have it) |
| Client `vf.19910` lookup | `street01` → `rooms/st01-dark3` |
| Client URL build | `{fileServer}/dynamic/rooms/st01-dark3.swf` |
| Client downloads SWF, parses map XML, spawns avatar | per §4.10 |

> **Status today**: the `st01-dark3.swf` is **not** in the AIR launcher
> cache; the original CDN is dead; we must re-author it (see
> [12 §12.6 Stage 3](12-our-own-cdn.md#stage-3--re-author-the-long-tail)).
> For Wave 1-3 MVP a placeholder SWF + a small hand-authored grid+doors is
> sufficient to satisfy the walk loop.

## 4.13 Open questions (still unresolved)

1. **Grid ByteArray endianness** — AS3 default is big-endian; the
   `GridModel.load()` source confirms `readInt()` but the byte-order
   selection isn't shown. Default AS3 ByteArray is big-endian, so assume
   that unless the room SWF carries an explicit `endian` switch.
2. **`v` (definition version) suffix rules** — the version is appended to
   the furniture SWF URL but the exact algorithm for handling missing
   versions hasn't been traced through `getFurniturePath()`. Treat
   `v=0` as "no suffix" (matches the cloth rule in `ifile`).
3. **Map XML element types beyond the 8 listed** — the snl_780 strings dump
   may reveal more; safe to ignore unknown tags for now.

---

[← Protocol catalog](03-protocol-catalog.md)  ·  [Index](README.md)  ·  [Next: Enums & types →](05-enums-and-types.md)
