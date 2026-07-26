# 2. Bootstrap & connection lifecycle

[← Architecture](01-architecture.md)  ·  [Index](README.md)  ·  [Next: Protocol catalog →](03-protocol-catalog.md)

Source: [../rebuild/inventory/snl_780_src/scripts/Sanalika.as](../rebuild/inventory/snl_780_src/scripts/Sanalika.as)
+ [../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/commands/](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/commands).

## 2.1 The fixed `SerialCommand` chain (must run in this order)

```
onAddedToStage()   →   init()
  └── SerialCommand:
        InitParamsCommand          # parse loaderInfo (token, fileServer, etc.)
     →  SetErrorMessagesCommand    # bind SFS error codes 4, 10000, 10001, 10002
     →  ConnectCommand             # WS connect to chatServer:8080
     →  LoginCommand               # SFS LoginRequest (token, fbToken, location, …)
     →  ConfigCommand              # extension "config" → moods, fileServer, item/version paths
     →  LocalizationCommand        # download .mo language file
     →  DetectOldClientCommand     # if Mac/Win player < min version → exit
     └── on COMPLETE → initCommandsCompleted()
            ├── instantiate 22 controllers (AvatarController, ChatController, …)
            ├── layerModel.loadBackground()
            ├── new HudModel, new PanelModel, new IsoEngine, new AdModel
            ├── load itemInfoFile → wait ITEM_INFO_FILE_LOADED
            ├── load versionFile  → wait VERSION_FILE_LOADED
            ├── if (mySelf.privilegeId == 0 && !guest) → open GuestPanel
            └── else → initialize() → requestData("init", {}, onInited)
```

## 2.2 Why this order

| Step | Why it must come before next |
|---|---|
| `InitParams` first | Other steps need `chatServer`, `fileServer`, `accessToken`, `avatarId` parsed from loaderInfo |
| `Connect` before `Login` | SFS API contract — can't login on a disconnected socket |
| `Login` before `Config` | `config` is an extension request; SFS rejects extension calls before login |
| `Config` before `Localization` | `langFile` path is one of the keys returned by `config` |
| `Config` before `init` | `init` callback references `gameModel.fileServer` for downstream panels |
| `ITEM_INFO_FILE_LOADED` before `VERSION_FILE_LOADED` | `VersionModel` resolves item asset paths via `ItemModel` |
| `VERSION_FILE_LOADED` before `initialize()` | `RoomController` constructed here uses `versionModel` to resolve room SWFs |
| `init` last | Returns full player state (selectedAvatarID, wallet, settings, banData, deactivationReason, checkAvatar) which can short-circuit later UI flows |

## 2.3 Exact wire shape of the bootstrap

| # | Direction | Name | Payload (sent) | Response (server must produce) |
|---|---|---|---|---|
| 1 | C → S (SFS) | `LoginRequest` | `room=serverName, data={ token, fbToken, location, platform ("android"\|"app"\|"web"), client ("web"\|"desktop"\|"mobile"), agent, clientKey="MARHAB_V2_SSAAASCVVVAAA", deviceId }` | SFS `login` event + privilegeId set on `sfs.mySelf` |
| 2 | C → S (ext) | `config` | `{}` | `{ moods:[{id,label}], chatBaloons:[{id,…}], itemFile:"/static/data/ifile.19910", versionFile:"/static/data/vf.19910", langFile:"/static/lang/en.mo", fileServer:[ "https://cdn1.example.com", … ], webServer:"…", language:"tr", farmCleaningCost:5, farmMaxPlantedItemSize:9, order:{avatarOrderLifeTime, orderLifeTime, prepareLifeTime}, masterRoles:[ … ] }` |
| 3 | S → C (push) | `initQueue` | — | `{ ts, p: 0..100 }` (queue position progress) |
| 4 | C → S (ext) | `init` | `{}` | See §2.4 below |
| 5 | C → S (ext) | `teleport` | `{ roomKey:"testStreet" }` | Server fires SFS JoinRoom on the configured room |

## 2.4 Exact `init` reply contract — every field `onInited()` reads

[Sanalika.as:L557-L745](../rebuild/inventory/snl_780_src/scripts/Sanalika.as).

| Field | Type | Required? | What it controls |
|---|---|---|---|
| `ts` | int64 (ms) | ✓ | Sets `SyncTimer` server time offset |
| `selectedAvatarID` | int | ✓ | Player's active avatar |
| `email` | string | ✓ | `avatarModel.email` |
| `deactivationReason` | string | optional | If set → CellPhonePanel + alert; **halt init** |
| `banData` | `{endDate:long, reason:string}` | optional | If set → CellPhonePanel + alert; **halt init** |
| `extensionInfo` | `Array<{id,name,…}>` | ✓ | Dynamically-loaded SWF extensions |
| `settings` | object — see below | ✓ | Player preferences (any may be undefined → default kept) |
| `campaigns` | `Array<{id,…}>` | optional | DailyGiftPanel trigger if length > 0 |
| `bans` | `Array` | optional | `banModel.configBans()` (rooms / players this user banned) |
| `orderRequest` | object | optional | Pending café order |
| `gender` | "m"\|"f" | ✓ | Avatar gender |
| `guest` | bool | ✓ | Guest flag |
| `completedAchievementsCount` | int | ✓ | Achievement badge count |
| `checkAvatar` | int | ✓ | `0` → force AvatarCreatePanel("BaseCloth") and **halt** |
| `createAvatar` | bool | ✓ | `true` → AvatarCreatePanel({}) and **halt** |
| `roomData` / `roomKey` | object | ✓ | Initial map; `roomModel.checkMap()` |
| `wallet` | `{sanil:int, diamond:int, pepsicoin:int}` | ✓ | HUD currency |
| `clothes.items` | `Array<ClothVO>` | ✓ | Avatar wardrobe |

`settings` keys (each `!== undefined` checked individually): `wideMode`,
`showInvitations`, `transferRequests`, `incomingMessages`, `tradeRequests`,
`whisperMessage`, `flatNotifications`, `onlyBuddyWhisper`, `verifySession`.

## 2.5 Error envelope (server → client extension response)

Every extension response may carry an error instead of payload. Shape consumed
by [ServiceModel.as:L286-L340](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/service/ServiceModel.as):

```jsonc
{
  "errorCode": "FLOOD" | "INSUFFICIENT_ROLE" | "MISSING_ITEM" | "GUEST_NOT_ALLOWED" | "WRONG_ITEM" | "<numeric>",
  "message":   "<role list | item name | localized key>",
  "nextRequest": <ms, only on FLOOD>
}
```

Client behavior on each:

- `FLOOD` → registers per-service `ServiceRequestRate` and waits `nextRequest` ms
- `INSUFFICIENT_ROLE` → looks up roles in comma-list, alerts the user
- `MISSING_ITEM` → appends item name to a generic alert
- `GUEST_NOT_ALLOWED` → opens GuestPanel instead of alert
- numeric → looked up in `ServiceErrorCode` table (see [05-enums-and-types.md](05-enums-and-types.md#55-serviceerrorcode-must-match-exactly))

## 2.6 Every command class in `commands/` tree

| Class | Sends | Response | Side effect |
|---|---|---|---|
| `Command` | — | — | Abstract base; `execute()`/`dispose()`/`complete()` lifecycle |
| `SerialCommand` | — | — | Executes child commands sequentially; waits for `Event.COMPLETE` on each |
| `ParallelCommand` | — | — | Executes child commands in parallel |
| `ConnectCommand` | SFS `connect(chatServer, port)` | SFSEvent `connection {success}` | WebSocket TCP connect; dispatches `OSProgressEvent.CONNECTED` |
| `LoginCommand` | SFS `LoginRequest(...)` (payload in §2.3 row 1) | SFSEvent `login` / `loginError` | Joins room; sets `sfs.mySelf` + privileges |
| `LocalizationCommand` | loads `gameModel.languageFileVersion` `.mo` file | `LOCALIZATION_DATA_READY` event | Initializes `LocalizationModel` |
| `ConfigCommand` | extension `config` `{}` | row 2 of §2.3 | Sets `gameModel.*`; `ServiceErrorCode.setData(masterRoles)`; dispatches `CONFIG_READY` |
| `InitParamsCommand` | reads `loaderInfo.parameters` | Parsed JSON | Sets `gameModel.server*`, `avatarModel.accessToken/avatarId/playerId/platform`; dispatches `INITCOMMAND` |
| `SetErrorMessagesCommand` | SFS `SFSErrorCodes.setErrorMessage(...)` | — | Binds error codes 4, 10000, 10001, 10002 to localized strings |
| `DetectOldClientCommand` | reads `Capabilities.version` | — | If Mac version < 50: alert + exit |
| `CheckSessionCommand` | `ExternalInterface.call("cs")` | — | If session invalid: send `LogoutRequest` |
| `CheckDailyGiftCommand` | listens for `SCENE_LOADED` | reads `campaigns` from `onInited` | If campaigns.length > 0 and not in tutorial: open DailyGiftPanel |
| `OpenSecurityCaptchaCommand` | — | data from server `securitycaptcha` | Opens CaptchaPanel |
| `OpenSecurityKeyCommand` | — | data from server `securitykey` | Opens SecurityKeyPanel (2FA) |
| `UserFlatEnteredCommand` | — | `{avatarName, flatName}` | Tooltip alert if `settings.flatNotifications` |
| `VipPurchaseDiscountCommand`, `HandItemCommand`, `HideCommand`, `FindMeCommand`, `SceneResolutionCommand`, `OpenRoomChangePasswordCommand` | various small panels/effects | | |

## 2.7 `ServiceModel` public API surface

[ServiceModel.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/service/ServiceModel.as).

```typescript
// Send extension request with one-shot callback
requestData(serviceName: String, params: Object, callback: Function, room: Room = null): void
removeRequestData(serviceName: String, callback: Function): void

// Persistent listener for server-pushed extension responses
listenExtension(serviceName: String, handler: Function): void
removeExtension(serviceName: String, handler: Function): void

// RoomVariable sync
setRoomVariable(keys: Array<String>, values: Array): void
listenRoomVariable(varName: String, handler: Function): void
removeRoomVariable(varName: String, handler: Function): void

// UserVariable sync
setUserVariable(keys: Array<String>, values: Array): void
listenUserVariable(varName: String, handler: Function): void
removeUserVariable(varName: String, handler: Function): void
getVariableByUserId(varName: String, userId: String): UserVariable

// Lifecycle
activate(): void   // subscribes to SFSEvents: userVariablesUpdate, roomVariablesUpdate, extensionResponse
deactivate(): void
```

Internal dispatch order on every extension response:

1. `dataList[serviceName][]` — one-shot callbacks from `requestData(...)`
2. `extensionList[serviceName][]` — legacy
3. `extListenerList[serviceName][]` — persistent listeners from `listenExtension(...)`

Rate-limited per service name by `ServiceRequestRate.check(serviceName)`; on
exceed or `extensionIdle`, the callback fires immediately with an error envelope.

---

[← Architecture](01-architecture.md)  ·  [Index](README.md)  ·  [Next: Protocol catalog →](03-protocol-catalog.md)
