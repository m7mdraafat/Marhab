# SFS Client Capture Plan

Use this before finalizing the production SFS server architecture. The probe server is not source of truth; the recovered client running against the real remote server is.

## What We Need To Capture

- Every decoded inbound and outbound SFS packet: controller, action, params, and packet body.
- Every extension command request/response: command name and payload.
- Every SmartFox event dispatched to the client: login, room join, user enter/exit, room variables, user variables, public/private/object messages, extension responses.
- Room bootstrap payloads: room key, room id, room variables, map, grid, doors, bots, owner, source, type, and spawn/door key.
- Door behavior: door keys, target cells, target directions, door property type, transition command, and response room payload.
- Walkability behavior: initial grid, map-driven grid mutations, `setCellValue` changes from dynamic objects/bots/assets, and later room variable updates that replace map/grid state.

## Capture Build

The capture build is generated from `client/recovered/game-src`; it does not edit recovered sources in place.

Validate hook anchors only:

```powershell
client/tools/build-capture-game.ps1 -ValidateOnly
```

Generate an instrumented source tree without compiling:

```powershell
client/tools/build-capture-game.ps1
```

Build the instrumented inner game SWF:

```powershell
$airSdk = "C:\replace\with\actual\AIRSDK"
Test-Path "$airSdk\lib\mxmlc.jar"
client/tools/build-capture-game.ps1 -Compile -SdkHome $airSdk
```

Build and replace `client/runtime/snl.780.swf` for the launcher run:

```powershell
$airSdk = "C:\replace\with\actual\AIRSDK"
Test-Path "$airSdk\lib\mxmlc.jar"
client/tools/build-capture-game.ps1 -Compile -PromoteToRuntime -SdkHome $airSdk
```

The path must be the AIR/Flex SDK root that contains `lib/mxmlc.jar`. The installed Adobe AIR runtime is not enough, and you do not need to run AIR before compiling.

`-PromoteToRuntime` creates `client/runtime/snl.780.swf.before-capture` once before replacing the runtime SWF.

## Log Location

The instrumented client writes JSON Lines to AIR application storage:

```text
captures/sfs-capture-<timestamp>.jsonl
```

The first `[CAPTURE]` trace line prints the exact native path.

Each line has this shape:

```json
{"seq":1,"time":1780000000000,"kind":"sfs.in","payload":{}}
```

Important `kind` values:

- `sfs.in` / `sfs.out`: decoded SFS packet boundary.
- `sfs.event`: SmartFox event after the SDK controller processed a packet.
- `extension.out` / `extension.in`: game service command boundary.
- `room.checkMap`: complete room payload passed into `RoomModel.checkMap`.
- `room.map`: Base64 map plus decoded XML.
- `door.loadJSON` / `door.load`: server-authored door array consumed by the client.
- `door.useDoorByKey` / `door.useHouseDoor`: door transition attempts.
- `grid.load.raw` / `grid.load`: initial grid payload and parsed cells.
- `grid.setCellValue`: runtime walkability mutations.
- `roomVariablesUpdate` / `userVariablesUpdate`: variable changes after room load.

## Capture Session Checklist

1. Start with a new capture run and note the `[CAPTURE]` JSONL path printed by the client.
2. Run the launcher against the remote/prod server URL and token you want to observe.
3. Login and wait until the first room fully renders.
4. For each street/room, record the visible room name and perform these actions:
   - stand still after entry,
   - hover every visible door/exit,
   - click every visible door/exit,
   - walk across obvious blocked/open areas,
   - trigger interactive objects, bots, furniture, chairs, shops, chat, inventory, profile, and teleport/admin paths if available.
5. After the run, keep the JSONL file and any notes that map visual actions to room names and door labels.

## Design Rule

The production server schema should be derived from these captures first, then reconciled with the recovered client source and CDN assets. The probe server can help compare packet encoding, but it should not decide game behavior.