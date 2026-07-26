# Client Entrypoint Map

This document maps the runnable recovered client startup path. Treat `client/recovered/game-src` as read-only reference and `client/runtime/snl.780.swf` as the runnable inner client binary.

## Runtime Chain

```text
AIR descriptor
  -> client/launcher/dist/bin/MyGame.swf
  -> launcher/src/boot_338d.as
  -> launcher/src/ApplicationMain.as
  -> launcher/src/DocumentClass.as
  -> launcher/src/SanalikaClient.as
  -> launcher runtime/c.local.json
  -> runtime/ml.21.9
  -> runtime/snl.780.swf
  -> recovered/game-src/Sanalika.as
```

## Launcher Startup

1. `boot_338d` initializes the Haxe/OpenFL runtime and enters `ApplicationMain`.
2. `ApplicationMain.main()` registers and creates the OpenFL application.
3. `ApplicationMain.start(stage)` creates `DocumentClass`.
4. `DocumentClass` attaches `SanalikaClient` to the stage.
5. `SanalikaClient.onAddedToStage()` initializes launcher models and executes this command chain:

```text
ClearCredentialsCommand
RemoteConfigCommand
ProcessUpdateCommandConfig
SelectInstanceCommand
StartGameCommand
```

## Local Config

`RemoteConfigCommand` prefers `app:/runtime/c.local.json` and falls back to the old remote config URL only if the local file is missing.

Current local config keys used by the launcher:

```json
{
  "loader": "app:/runtime/ml.21.9",
  "core": "app:/runtime/snl.780.swf",
  "background": "app:/runtime/loader-bg.jpg",
  "serverName": "local",
  "protocol": "http://",
  "policyFile": "http://127.0.0.1:8080/crossdomain.xml",
  "token": "dev-token"
}
```

`SelectInstanceCommand` auto-selects `config.serverName` when `c.local.json` exists. For local development this must be `local`.

## Loader Parameters

`LoaderModel` loads `config.loader` (`ml.21.9`) and passes these parameters to it:

```text
bg         = config.background
cs         = config.core
serverName = config.serverName or selected instance
at         = config.token or stored token
fbToken    = ""
location   = ""
platform   = "app"
protocol   = config.protocol or "http://"
```

`MainLoader` reads `cs`, loads the core SWF bytes, and passes the same parameters to `snl.780.swf` with `LoaderContext.parameters`.

## Inner Game Startup

`Sanalika.as` starts at `onAddedToStage()`, constructs core models, then calls `init()`.

`init()` executes this command chain:

```text
InitParamsCommand
SetErrorMessagesCommand
ConnectCommand
LoginCommand
ConfigCommand
LocalizationCommand
DetectOldClientCommand
initCommandsCompleted()
```

## First Server-Facing Steps

### InitParamsCommand

On AIR desktop, it reads `loaderInfo.parameters` directly and sets:

```text
gameModel.serverName
gameModel.chatServer
gameModel.fileServer
gameModel.webServer
gameModel.protocol
avatarModel.accessToken
avatarModel.location
avatarModel.fbToken
avatarModel.platform
gameModel.itemInfoFile
gameModel.versionFile
gameModel.languageFileVersion
```

For local development, `serverName=local` is the key value.

### ConnectCommand

If `serverName == "local"`, it forces:

```text
chatServer = 127.0.0.1
useWebSocket = true
useSSL = false
port = 8080
```

So the first server milestone must listen on:

```text
127.0.0.1:8080
```

### LoginCommand

Sends a SmartFox `LoginRequest` with zone `serverName` and params:

```text
token
fbToken
location
platform
client
agent
clientKey = MARHAB_V2_SSAAASCVVVAAA
deviceId
```

After login success it activates `ServiceModel` and proceeds to `ConfigCommand`.

### ConfigCommand

Calls:

```text
serviceModel.requestData("config", {}, responseFunction)
```

`ServiceModel` wraps extension requests as:

```text
ExtensionRequest cmd = service name
params.sn = service name
params.data = request payload
params.ts = SyncTimer.timestamp
params.rid = incrementing request id
```

For `config`, the server response must include at least:

```text
moods
chatBaloons
itemFile
versionFile
langFile
fileServer[0]
webServer
language
farmCleaningCost
farmMaxPlantedItemSize
order.avatarOrderLifeTime
order.orderLifeTime
order.prepareLifeTime
masterRoles
```

### Init Request

After config, localization, item file, and version file loading, the client calls:

```text
serviceModel.requestData("init", {}, onInited)
```

The first server implementation should focus on returning the minimum `init` payload needed to avoid bans/deactivation, load an avatar, wallet, clothes, settings, and room data.

## What To Do Next

Build a local SmartFox-compatible protocol probe/server on `127.0.0.1:8080`.

## Probe Capture: 2026-05-28

The first probe run confirmed the client transport:

```text
GET /crossdomain.xml
WebSocket upgrade /BlueBox/websocket
```

The client sends a binary SmartFox handshake packet immediately after the WebSocket opens.

First captured frame:

```text
80 00 2d 12 00 03 00 01 61 03 00 00 00 01 70 12
00 02 00 03 61 70 69 08 00 05 31 2e 37 2e 39 00
02 63 6c 08 00 05 46 6c 61 73 68 00 01 63 02 00
```

Decoded at the packet level:

```text
packet header = 0x80
packet length = 0x002d = 45 bytes
controller c  = 0 (system controller)
action a      = 0 (handshake)
params p      = { api: "1.7.9", cl: "Flash" }
```

The client closes/reset the socket because the probe does not yet answer the SmartFox handshake.

The launcher also logs a child SWF error after the core loader starts:

```text
ReferenceError: Error #1065: Variable dya68_ is not defined.
```

This error is currently non-fatal for transport discovery: the client still opened `/BlueBox/websocket` and sent the handshake.

Immediate milestone:

1. Accept the client WebSocket/SmartFox connection.
2. Complete the SmartFox handshake.
3. Accept `LoginRequest` for zone `local`.
4. Respond to extension command `config`.
5. Serve local CDN files referenced by `config`.
6. Respond to extension command `init`.

Do not start with walking, inventory, shop, or chat. The first success condition is the client clearing bootstrap past `INIT_READY` or opening the expected first-time avatar flow.