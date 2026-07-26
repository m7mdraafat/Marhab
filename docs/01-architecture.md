# 1. System architecture

[← Index](README.md)  ·  [Next: Bootstrap →](02-bootstrap.md)

## One-page mental model

```
┌─────────────────────────────────────────────────────────────────────────┐
│ Adobe AIR (adl.exe)  →  snl.780.swf  →  Sanalika.as (entry point)        │
│  ├── 60+ Models (RoomModel, AvatarModel, ItemModel, ClothModel, …)       │
│  ├── 22 Controllers (RoomController, ChatController, BuddyController, …) │
│  ├── IsoEngine  (isometric scene; client-side A* pathfinding)            │
│  └── ServiceModel → SmartFoxServer 2X client                             │
│                       │                                                   │
│                       ▼  WebSocket (port 8080 / 8443)                     │
│ ┌────────────────────────────────────────────────────────────────────┐    │
│ │ SmartFoxServer 2X  +  HaraExtension.jar                            │    │
│ │  ├── Built-in: rooms, users, RoomVars, UserVars, Login/Join        │    │
│ │  └── Extension handlers (~70 named requests, server pushes)        │    │
│ └────────────────────────────────────────────────────────────────────┘    │
│                       │                                                   │
│                       ▼  JDBC / DAOs                                      │
│ ┌────────────────────────────────────────────────────────────────────┐    │
│ │ PostgreSQL  (avatars, flats, items, cloths, quests, ban, chat…)   │    │
│ └────────────────────────────────────────────────────────────────────┘    │
│                                                                            │
│ Asset CDN (Tomcat / static)                                                │
│   /static/data/vf.* + ifile.*  (catalogs)                                  │
│   /static/items-2x/clothes|smileys|inventory/…                             │
│   /dynamic/rooms-2x/{roomKey}.swf                                          │
│   /dynamic/panels-2x/{panelName}.swf                                       │
└─────────────────────────────────────────────────────────────────────────┘
```

## Two channels the client uses

| Channel | Used for | Server handles via |
|---|---|---|
| **SFS Extension requests** (`serviceModel.requestData("name", payload, cb)`) | Game logic (login, init, teleport, buy, save) | `BaseClientRequestHandler` per name |
| **RoomVariables / UserVariables** | Per-tick state (position, direction, clothes, mood, chat) | `SetRoomVariablesRequest` / `SetUserVariablesRequest` + SFS auto-broadcast |

The client treats the server as the source of truth for *everything except
path computation* — pathfinding is client-side A* over the room grid sent by
the server (see [04-rooms-and-walking.md](04-rooms-and-walking.md)).

## The three layers you must mentally separate

1. **SmartFoxServer 2X** — the framework. Owns sockets, login, rooms, user/room
   variables, basic chat. You don't change this; you write an extension JAR
   that plugs into it.
2. **`HaraExtension.jar`** — your code. Registers one handler per named
   extension request, listens for SFS events, and updates state.
3. **Persistence + assets** — PostgreSQL behind JDBC + static asset CDN.
   The extension never serves SWFs over the SFS socket; the client downloads
   them over HTTP from the `fileServer` URL returned in `config`.

## Where the source lives

| Area | Path |
|---|---|
| Client source (read-only spec) | [../rebuild/inventory/snl_780_src/](../rebuild/inventory/snl_780_src) |
| Client launcher (Adobe AIR) | [../rebuild/runtime/](../rebuild/runtime) |
| Server scaffold | [../server/](../server) |
| Build & dev workflow scripts | [../rebuild/](../rebuild) (`build.ps1`, `dev-loop.ps1`, `warm-cache.ps1`) |
| Top-level FFDec asset dumps | `binaryData/`, `fonts/`, `frames/`, `images/`, `morphshapes/`, `shapes/`, `sprites/`, `symbolClass/` at repo root — see [07-asset-pipeline.md](07-asset-pipeline.md) |

---

[← Index](README.md)  ·  [Next: Bootstrap →](02-bootstrap.md)
