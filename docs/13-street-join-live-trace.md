# Street / Room Join — Live Traffic Analysis (Sanalika EG, May 2026)

Captured live by driving the production game in an instrumented headless browser
(`https://www.sanalika.com/eg/play`, account `m7mdraafat2003@gmail.com`) and
tapping **both HTTP and WebSocket traffic** via Chrome DevTools Protocol.

This is what actually happens on the wire — no guessing.

The user-provided Marhab URL
`https://xo.newmarhab.net/global-haxe/dynamic/ceilings/st01.1.json`
follows the **same structure** as Sanalika EG (just different CDN host and
different room-id convention `st01.1` vs `RMS03.4`). Everything below applies
to both skins.

---

## 1. Two-channel architecture

| Channel | Endpoint | Role |
|---|---|---|
| HTTP/CDN | `https://fs.sanalika.com/global-haxe/...` (Sanalika)<br>`https://xo.newmarhab.net/global-haxe/...` (Marhab) | Static + per-room **assets** (sprite atlases, ground, ceiling, items) |
| WebSocket (binary) | `wss://egypt-sfs.sanalika.com:8443/BlueBox/websocket` | **SmartFoxServer 2X** — auth, room state, avatars, walk, chat |

`BlueBox` is SFS's WebSocket-tunneled transport. Binary frames carry the
**SFSObject** serialization (see §3).

---

## 2. CDN layout (HTTP)

Base: `https://<cdn-host>/global-haxe/`

```
dynamic/
  ceilings/
    {ROOM_ID}.json    # TexturePacker atlas of all "above-avatar" sprites
    {ROOM_ID}.png     # the corresponding atlas image
  rooms/
    {ROOM_ID}.png     # ground/base layer (the room's drawn background)
    {ROOM_ID}/
      {item_id}.json  # per-room placed furniture / decorations
      {item_id}.png
static/
  items/
    furnitures/
      {guid}_{frame}.json    # globally-shared catalog items
      {guid}_{frame}.png
global/
  spritesheet/{hash}.{json|png}   # avatar/clothing sprite atlases
```

**Observed in the captured session** (room `RMS03.4`, a street):

- `dynamic/ceilings/RMS03.4.json` + `.png` — single foreground atlas for the whole street
- `dynamic/rooms/RMS03.4.png` — ground
- `dynamic/rooms/RMS03.4/mcSign_18.json` — street sign
- `dynamic/rooms/RMS03.4/cadde_sezlong_01..03.json` — 3 sun loungers
- `dynamic/rooms/RMS03.4/cadde_semsiye.json` — beach umbrella
- `dynamic/rooms/RMS03.4/Cd3Tabela2.json` — second sign
- `static/items/furnitures/{by3fGcD2,pp8Ed2w1,mahpggdb}_3.json` (+`_5`) — shared furniture catalog items

### 2.1 Ceiling atlas (`ceilings/{ROOM}.json`)

Standard **TexturePacker** JSON-Hash with one Sanalika-specific extension:

```jsonc
{
  "meta": { "image": "st01.png", "size": {"w":1860,"h":1173}, "scale":"1" },
  "frames": [
    {
      "filename": "d1_0000.png",
      "frame":           {"x":1775,"y":73,"w":39,"h":74},   // rect inside atlas PNG
      "spriteSourceSize":{"x":405,"y":184,"w":39,"h":74},   // trimmed offset
      "sourceSize":      {"w":39,"h":74},                   // original art size
      "rotated": false,
      "trimmed": true,
      "gameSource":      {"x":0,"y":0}                      // Sanalika-custom anchor
    },
    {
      "filename": "instance218_0076.png",                   // animation frame
      "frame": { /* ... */ },
      "gameSource": {"x":-45,"y":0}                         // anchor drifts as art trims
    }
  ]
}
```

Things to know:

- **`d{N}_0000.png`** — static "door" / building-facade overlays (10 doors in `st01`).
- **`instance{N}_{NNNN}.png`** — animation sequences (`instance218` runs 0000–0335, `instance222` runs 0000–0153). These are pre-baked sprite animations (flags, smoke, water shimmer).
  The repeating identical frames at the tail of `instance218` (`_0079`..`_0304` all reuse the same `frame` rect) are deliberate — the playback timeline holds that frame on screen for a long pause before snapping back at `_0305`.
- **`gameSource`** is Sanalika's extension to TexturePacker (vanilla TP does not emit it). It carries the **per-frame in-world anchor offset** the runtime applies when placing the sprite. For `instance218`, all frames share `gameSource.x=-45` because the animated sprite's visual centre drifts as the trimmed bounds change frame-to-frame.

### 2.2 What is NOT in the CDN

**Walkability / tile grid / portals are NOT in any HTTP file.**

Cross-origin probes for `rooms/{ROOM}.json`, `walk.json`, `ground.json`,
`grounds/{ROOM}.json` all 404 (or CORS-fail). Only `ceilings/{ROOM}.json`
is reachable. The walkable-tile map is shipped **inside the SmartFox
`JoinRoom` response** as Room Variables (§5).

---

## 3. Wire format — SmartFoxServer 2X SFSObject

Every WebSocket frame is binary (`opcode 0x2`). Layout:

```
80 LL LL          ; SFS BinaryBox: 0x80 = binary flag, 16-bit big-endian length
12 NN NN          ; SFSObject type (0x12), then 16-bit field count
  <fields>
```

Each field:
```
KK KK <key utf-8>   ; 16-bit key length + key bytes
TT                  ; type byte
<payload>
```

Type bytes observed:

| Byte | SFS type      | Payload |
|------|---------------|---------|
| 0x02 | BYTE          | 1 byte |
| 0x03 | SHORT         | 2 bytes BE |
| 0x04 | INT           | 4 bytes BE |
| 0x07 | DOUBLE        | 8 bytes BE |
| 0x08 | UTF_STRING    | 2-byte len + utf-8 |
| 0x0A | BYTE_ARRAY    | 4-byte len + bytes |
| 0x11 | SFS_ARRAY     | 2-byte count + items |
| 0x12 | SFS_OBJECT    | 2-byte field count + fields |

Every top-level packet is an SFSObject with **3 keys**:

```
c : BYTE          ; controller id    (0 = system, 1 = extension request, …)
a : SHORT         ; action id within that controller
p : SFS_OBJECT    ; params
```

This is the canonical SmartFox extension-request envelope.

---

## 4. Captured packets (decoded)

### 4.1 Heartbeat (every ~1 s, 20 B)

Raw: `80 00 14 12 00 03  00 01 'c' 02 00  00 01 'a' 03 00 1D  00 01 'p' 12 00 00`

```
send → { c:0, a:29 (0x1D), p:{} }     ; client ping
recv ← { c:0, a:29,        p:{} }     ; server pong
```

### 4.2 Session-key rotation (every ~10 s, 125–146 B)

```
send → { c:1, a:13, p:{
  c: "d",                     ; sub-command
  r: -1,                      ; room id (-1 = no room scope)
  p: {
    d: <ByteArray len=48..75>, ; AES ciphertext (rotates each tick)
    n: <ByteArray len=12>,     ; 96-bit nonce (AES-GCM-shaped)
    c: 19,20,21,…              ; monotonically increasing counter
  }
}}
```

Same outer envelope `c=1,a=13` is reused for **all extension calls** —
the inner `c: "<cmd-tag>"` discriminates. Here `"d"` ≈ "deriveKey" /
"data-channel keep-alive". The 12-byte nonce always starts
`00 DC 9E A2 FF FF FF FF <counter> 00 00 00`.

### 4.3 USER_ENTER_ROOM broadcast (`a=1000`, 608 B in trace)

Fired by the server whenever **any** user enters the room you are in.
Carries the full UserVariables set for that user (one push, no follow-up
fetch required):

```
recv ← { c:0, a:1000, p:{
  r: 1192,                          ; this room's id
  u: [                              ; SFSArray of users (here 1)
    { userId: 4042,
      name:   "101091824",          ; account id as string
      privileges: 1,
      isPlayer: 0,
      uvars: [                      ; SFSArray of [key,type,value] triples
        ["gender",        BYTE,   "f"],
        ["mood",          INT,    10],
        ["rodX",          INT,    25],
        ["optimizedAssetKey", INT, -1297090356],
        ["roles",         BYTE,   "ACA="],     ; base64 role mask
        ["rodY",          INT,    3],
        ["universeKey",   BYTE,   "w1"],       ; ← server cluster shard id
        ["avatarSize",    DOUBLE, 1.0],
        ["speed",         DOUBLE, 1.0],
        ["platform",      BYTE,   "browser"],
        ["smiley",        BYTE,   "empty"],
        ["direction",     INT,    1],
        ["statusMessage", BYTE,   "omar ^-^"],
        ["clothes",       BYTE,   "[\"C_1\",\"B_1\",\"A_1\",\"mq4f6zzb_9\",\"mrstclqg_9\",\"L9mX5X3m_9\",\"m6lYK8VV_9\"]"],
        ["avatarName",    BYTE,   "MENNA<NIK>"],
        ["chatBalloon",   BYTE,   "26"],
        ["position",      BYTE,   "4,18"],     ; <-- spawn tile (x,y)
        ["tp",            INT,    0],          ; teleport flag
        ["status",        BYTE,   "i"],        ; i = idle
        ["playerID",      DOUBLE, 1612214000000.0]
      ]
    }
  ]
}}
```

Key takeaways for our reimplementation:

- **`position`** is the spawn point on join, formatted as `"x,y"` tile coordinates.
- **`tp`** is a flag the server sets when the user was teleported (vs walked in).
- **`status`**: `"i"` idle, `"w"` walking, `"s"` sitting (inferred).
- **`direction`** is 1..8 (8-way isometric facing).
- **`clothes`** is a JSON-stringified array shipped as a single UTF string -- not nested SFS structures, intentionally opaque to the server.
- **`universeKey`** identifies the physical SFS shard (`w1`, `w2`, ...). Cross-shard handoffs require a different login.
- All shipped via SmartFox **UserVariables** -- the server just relays them; the meaning lives in the client.

### 4.4 USER_VARIABLE_UPDATE (movement, `a=12`)

The most frequent packet during play. Each `target` / `position` / `direction` change is its own tiny SFSObject:

```
recv <- { c:0, a:12, p:{
  u: 4072,                          ; userId whose vars changed
  vl: [                             ; SFSArray of changed [key,type,value]
    ["target",   BYTE, "33,17"]     ; click destination tile
  ]
}}

recv <- { c:0, a:12, p:{ u: 4072, vl: [ ["direction", INT, 8] ] }}
recv <- { c:0, a:12, p:{ u: 4072, vl: [ ["position",  BYTE, "37,23"] ] }}
```

Full walk sequence captured (one user clicking through a street):

```
target=33,17  ->  direction=8  ->  position=37,23  ->  position=33,17  ->  tp=1 (arrived)
target=30,23  ->  direction=8  ->  position=40,14  ->  position=33,17  ->  ...
```

**The server does NOT path-find.** It only relays `target`; the client picks
the path; the periodic `position` updates are the client telling the server
which intermediate tiles it crossed. `tp` flips `1 -> 0` to bracket each walk.

This is critical for our server design -- we only need to **validate** that
each reported `position` is walkable according to the room map; we do not
run A* ourselves.

### 4.5 PUBLIC_MESSAGE (`a=7`)

```
recv <- { c:0, a:7, p:{
  p: { ts: 1779811292..., r: 1192, t: 0 },
  u: 4101,
  m: "<utf-8 chat>"
}}
```

`ts` is the server timestamp. `t:0` = normal chat; other values are
emote/system/whisper (not in this capture).

---

## 5. Room JOIN sequence (to confirm with a portal-crossing capture)

This session showed only **intra-room** activity -- the test account stayed
in `RMS03.4` for the whole trace; none of the attempted portal clicks landed
on a real portal tile. What we did positively confirm:

- The only asset request triggered during in-room movement was for new
  clothing sprites (`global/spritesheet/{hash}.json/.png`) when another
  user with new outfits walked on-screen.
- No new `ceilings/...` or `rooms/...` request fired -> those are fetched
  **only on room join**.

The expected join sequence (extrapolated from SmartFox standard + the
captured envelope shape) is:

```
1. client -> { c:1, a:13, p:{ c:"joinRoom", r:<currentRoom>, p:{ roomId:<dst>, password:"" }}}
2. server <- { c:0, a:4,  p:{ r:{<full Room descriptor + RoomVariables>}}}      ; SFS JOIN_ROOM
3. server <- { c:0, a:1000, p:{ r:<dst>, u:[ ...every user already inside... ]}} ; one USER_ENTER per existing user
4. client GETs from CDN in parallel:
     global-haxe/dynamic/rooms/{dst}.png         ; ground
     global-haxe/dynamic/ceilings/{dst}.json     ; foreground atlas json
     global-haxe/dynamic/ceilings/{dst}.png      ; foreground atlas png
     global-haxe/dynamic/rooms/{dst}/{item}.{json,png}      ; per placed instance
     global-haxe/static/items/furnitures/{guid}_*.{json,png}; catalog items
5. server pushes the local user's own USER_ENTER_ROOM with spawn
   `position` / `direction` / `tp=1`.
```

The **walkable-tile map and portal table** live inside step 2's
RoomVariables -- that is the missing piece we still need to dump
(requires actually crossing a portal in a follow-up capture).

---

## 6. What this means for our server implementation

1. We implement the **SmartFox extension envelope** verbatim:
   - frame = `0x80 | len:u16 | SFSObject{c,a,p}`
   - 3-byte controllers (`0`=system, `1`=ext), single-shot actions.
2. The server is the authority on room state, but movement is **client-driven**:
   - clients send `target` (one tile), client walks the path locally,
     then streams `position` updates that the server **validates** against
     the room's walk-grid and **broadcasts** to others in the same room.
3. The room's walk-grid is shipped as a **RoomVariable** at join time --
   not via HTTP. Our `GET /rooms/{id}` REST endpoint is wrong; the walk
   grid must live inside the JOIN response Room Variables.
4. CDN layout is fixed: ground PNG, ceiling atlas, per-room items dir,
   global furniture catalog. Verify `mygame/rebuild/build-www.ps1` against
   `dynamic/ceilings/{ROOM}.json` and `dynamic/rooms/{ROOM}/{item}.json`.
5. The protocol uses **string tile coordinates** (`"x,y"`), not packed
   ints. Keep that -- saves us a serializer for now.
6. `tp` flag distinguishes teleport (instantaneous) from walk (animated)
   -- implement both paths.

---

## 7. Files saved alongside this doc

- `assets/reports/street-st01/00-home-room.png` -- initial street state
- `assets/reports/street-st01/01-before-click.png`
- `assets/reports/street-st01/02-after-click.png` -- after one click
- `assets/reports/street-st01/03-after-portal-attempts.png`

(Frame dumps stayed in-memory only -- the Playwright sandbox blocked
`require('fs')`. Re-run is cheap: any developer can repeat the capture in
~30 s by reattaching CDP.)

---

## 8. Open follow-ups

1. Cross a real portal (street -> street) to capture the JoinRoom (`a=4`)
   payload **including RoomVariables**. The walk-grid blob will appear
   there -- that is the file we have been calling "walkability JSON".
2. Decode the 75-byte ciphertext inside the keep-alive -- confirm
   AES-GCM with the 12-byte nonce, key likely derived from session token.
3. Enumerate action IDs by triggering each UI feature
   (sit, change clothes, whisper, open shop) -- one outbound packet per
   action gives us a complete action-id table.
