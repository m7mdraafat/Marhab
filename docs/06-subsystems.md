# 6. Subsystems

[← Enums & types](05-enums-and-types.md)  ·  [Index](README.md)  ·  [Next: Asset pipeline →](07-asset-pipeline.md)

## 6.1 Items, inventory, cloth

### Item catalog (`ifile.*`)

Base64-encoded, pipe-delimited file loaded by
[InfoFileParser.as:L119-L160](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/item/InfoFileParser.as).
Two row formats:

- Inventory item: `id|width|height|layers` → expanded into `m_<id>` / `f_<id>` per gender
- Cloth: `clipName|bitPositions(csv)|colorChannel|quantity|lifeTime|timeLeft|subType`

### Cloth list vs base cloth list

| Command | Endpoint | Purpose |
|---|---|---|
| `clothlist` | `requestData("clothlist", {}, cb)` | current full wardrobe |
| `baseclothlist` | `requestData("baseclothlist", {}, cb)` | the outfit auto-equipped on login |
| `changeclothes` | `requestData("changeclothes", {itemIDs:[]}, cb)` | swap-now (transient) |
| `savebaseclothes` | `requestData("savebaseclothes", {itemIDs:[]}, cb)` | update the default |

`CharPreviewManager`
([cloth/CharPreviewManager.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/cloth/CharPreviewManager.as))
tracks all active preview renderers to prevent slot conflicts in the
dressing room.

Slot conflict rules — see [05 §5.3](05-enums-and-types.md#53-cloth-layer-slots-critical-for-outfit-conflict-checks).

## 6.2 Expirables / drop

| Cmd | Direction | Purpose |
|---|---|---|
| `listexpirables` | C→S | inventory items with `timeLeft > 0` |
| `addExpirables` | S→C push | new expiring item added (daily gift, event reward) |
| `expire` | S→C push | item ran out, client removes from inventory |
| `dropItem` / `dropRemoveItem` | S→C push | ground drop appeared/cleared |
| `drop` | C→S | `{type:"COLLECT"}` confirms collection |

Server must run a per-second sweep over expiring items and emit `expire` pushes.

Expiration constants ([inventory/Item.as:L5-L6](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/inventory/Item.as)):
`EXPIRATIONTYPE_NONE=0`, `EXPIRATIONTYPE_EXPIRE=1` (countdown updates per
second via `TIMER_1S` group).

## 6.3 Chat & private chat

- **Public chat**: SFS native `publicMessage` event (sender = `User` object).
  No extension call required for sending; client uses `roommessage`
  RoomVariable to broadcast chat-bubble events.
- **Whisper**: `whisper` extension → server pushes `whisper` push to target only.
- **Group whisper**: `groupwhisper` payload has `targetList:string[]`;
  server pushes `whispernotify` to bystanders so they see "whispering" balloon.
- **Private chat (DM threads)**: grouped by `groupID`.
  - `privatechatlist` → thread summaries with `unreadMessageCount`
  - `messagedetails` → full history for a group
  - `privatechatdeletegroup` → removes thread
  - Inbound: `privatemessagereceived` push
  - Rate limit: `privateChatLimitExceeded` push

Citations:
- [ChatController.as:L65-L156](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/chat/ChatController.as)
- [ChatModel.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/chat/ChatModel.as)
- [PrivateChatController.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/privatechat/PrivateChatController.as)

## 6.4 Buddy

All commands listed in [03 §3.1](03-protocol-catalog.md#buddy--private-chat--chat).

- Online presence and mood are pushes (`buddyOnlineStatus`, `buddy.moodchanged`)
- Diamond gifting is a 3-step flow:
  `diamondtransferrequest` → `respondDiamondTransferRequest` push to target →
  target sends `diamondtransferresponse` → `diamondTransferResult` push to sender
- Buddy goes offline → server cancels any active barter via
  `BarterEvent.BARTER_CANCEL` dispatch
- Friend request full → push `BUDDY_REQUEST_FULL_REQUESTER` error
- Buddy locate: returns `{location}` showing the buddy's current universe/room/flat

Citations:
- [BuddyController.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/buddy/BuddyController.as)
- [BuddyModel.as:L73-L95](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/buddy/BuddyModel.as)

## 6.5 Purchase / shop / flat

Purchase payload:
```jsonc
{ "shopID": 12, "objectID": 34, "items": [{ "shopProductID": 56, "quantity": 1, "color": 7 }] }
```

Response `itemPurchaseResponse.items[i]`:
```jsonc
{ "type": "<ProductType>", "items": [...], "cost": { "SANIL": 100, "DIAMOND": 0 } }
```

Client dispatches type-specific events:
`HAIR_PURCHASE_COMPLETED`, `CLOTH_PURCHASE_COMPLETED`,
`FURNITURE_PURCHASE_COMPLETED`, `HAND_ITEM_PURCHASE_COMPLETED`,
`FLAT_PURCHASE_COMPLETED`.

**Flat ownership**: rooms with `ownerID == self` show owner-only options
(room editor `loadroomdesign`/`saveroomdesign`, sponsor revenue
`avatarsalescollect`, frame/lock toggles).

## 6.6 Transfer & barter

### Transfer (gift an item)

1. Drag start → `TransferEvent.START_DRAGGING`
2. Drop on avatar → `checkAvailability()`
3. `transferrequest{avatarID, itemID, quantity}` → server checks transferability + roles
4. Server pushes `respondTransferRequest` to target
5. Target sends `transferresponse{senderID, transferID, response}` (ACCEPTED/REJECTED)
6. Server pushes `transferResult` to sender + (if accepted) updates both inventories

Special items:
- `clip == "ckt7RFNK"` (Yupo/pet gift) → triggers `"Yupo hediye ettin!"` + `avatarModel.giftCount++`
- `CHECK` subType → requires matching hand item to use; blocked with `itemRequired()` alert

### Barter (live 2-party trade session)

- `barterrequest` → `barterStarted` push → `BarterPanel` opens
- `bartercancel` aborts
- `BarterModel.isBusy` blocks concurrent barters

Citations:
- [TransferController.as:L1-L140](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/transfer/TransferController.as)
- [BarterController.as:L1-L90](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/barter/BarterController.as)

## 6.7 Quest

[quest/](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/quest)

| Step | Direction | Detail |
|---|---|---|
| 1. Boot | C → S | `questlist({showDetail:false})` once per session — cached |
| 2. Enter room | S → C push | `questlistroom` with `quests[]` active in that room → client attaches icons / spawns auto-collectible items |
| 3. Pick up item | C → S | `questaction({id})` → server replies `{curVal, reqVal}` |
| 4. Step done | S → C push | `queststepcomplete{id, metaKey, nextRoom}` → client removes icon, shows next-room hint |
| 5. Done | S → C push | `questcomplete{id, metaKey}` |

Quest types ([QuestType.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/quest)):
`ADVENTURE`, `PERIODIC`, `ACHIVEMENT` *(sic)*.

VOs:
- `IQuest` — `id, questType, questID, questName, questDescription, detailData, active`
- `IQuestBotVo` — `questID, questStep, botKey, posX, posY`
- `IQuestModel` — `questlistroom` (Dictionary) + `questlist` (Object)

## 6.8 Achievement

[achievement/](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/achievement)

Entirely **server-driven push** (`achievementupdate`). Client only tracks
`rewardCount`. There is **no client-initiated achievement request**.

Flow:
1. Server detects condition (e.g., level-up, item acquisition)
2. Server pushes `achievementupdate` → client increments `rewardCount`
3. UI dispatches `AchievementEvent.REWARD_COUNT_UPDATED`; typically shows
   badge/notification

## 6.9 Mission (seasonal campaigns)

[mission/](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/mission)

Hard-coded event classes for sponsorship campaigns (Bosch, Basf, Rice Day,
August 2018). Each defines named step constants:

| File | Campaign | Step constants |
|---|---|---|
| `AugustMissionEvent.as` | August 2018 | EYLUL(1) → GAZI(10) → KENAN(20) → COMPLETE_MISSION(30) |
| `BasfMissionEvent.as` | Basf | EROL(1) → RUZGARTURBINI(10) → USTA(20) → COPPOSETI(30) → ARITMAMAKINASI(40) → COMPLETE_MISSION(50) |
| `BoschOctoberMissionEvent.as` | Bosch | DURU(1) → ORCUN(10) → KLIMAFIRST(20) → KLIMASECOND(30) → KLIMATHIRD(40) → MELIS(50) → COMPLETE_MISSION(60) |
| `RiceDayMissionEvent.as` | Rice Day | ASCI(1) → ULUBILGE(10) → KUAFOR(20) → KOSTUMCU(30) → CICEKCI(40) → SEVGI(50) → COMPLETE_MISSION(60) |

Each carries a `step:int` property dispatched via the `CHANGE_STEP` event.

UI-only — server must manage step progression and broadcast via
`queststepcomplete` or `infoMessage` pushes. The actual controller isn't in
the inventory.

## 6.10 Property pattern (the magic that powers interactive objects)

### Architecture

Every interactive map object carries a `property` JSON `{cn:"<ClassName>", …data}`.
[EntryVo.setProperty()](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/interactive/EntryVo.as)
(L349-L365) dynamically instantiates `com.oyunstudyosu.property.<ClassName>`:

```as3
_loc2_ = getDefinitionByName("com.oyunstudyosu.property." + param1.cn) as Class;
_property = new _loc2_();
_property.data = param1;
```

On click, `property.execute(objectId)` runs.

### Catalog of properties

| Property | Trigger | Sends | Opens panel |
|---|---|---|---|
| `FrameProperty` | owner click | `changeobjectframe{id}` | — |
| `GridSealingProperty` | owner click | `changeobjectframe{id}` (toggles wall sealing → repath grid) | — |
| `TeleportProperty` | click | `teleport{roomKey}` | — |
| `FlatExitProperty` / `PassageProperty` | click | `usedoor{key,type}` | — |
| `FlatEnterProperty` | click | `useobjectdoor{id}` | — |
| `FarmProperty` | owner click | `farmgather{id}` / `farmclean{id}` (frame state PLANTED→SEEDLING→PRODUCT→DRY) | — |
| `GatheringProperty` | click | `gatheritemsearch{id}` → 12s timer → `gatheritemcollect{}` | — |
| `ExchangeProperty` | any | `exchangediamond{diamondQuantity}` | ExChange |
| `FlatSponsorPanelProperty` | click | `avatarsalescollect{id}` (owner) | FlatSponsorPanel |
| `NickChangePanelProperty` | click | `avatarsalescollect{id}` (owner) | NickChangePanel |
| `ShopPanelProperty` | click | `avatarsalescollect{id}` (owner) | ShopPanel |
| `GiftOnceProperty` | once-per-user | `campaignquest{id}` | Info panel |
| `YoutubeScreenProperty` | click | `startroomvideo{videoUrl}` | — |

Server-side, each property maps to one handler. The class name in `cn` is
the contract.

## 6.11 Avatar actions & user variables

[AvatarController.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/avatar/AvatarController.as):

| UserVariable monitored | Effect |
|---|---|
| `smiley` | face/emoticon update |
| `clothes` | outfit change broadcast |
| `hand` | hand item sync |
| `position`, `direction`, `speed` | movement |
| `avatarName`, `gender`, `avatarSize` | appearance |
| `tp` (typing) | chat indicator |

Hand item: `usehanditem({id})` → may trigger property action via
`property: {cn: String}` in the response.

## 6.12 Bots (`bot/` package)

[BotModel.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/bot/BotModel.as),
[BotVO.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/bot/BotVO.as).

A bot is a room-scoped, server-defined NPC. Loaded from the `bots`
RoomVariable as a JSON array; one entry per bot. On change the room
reloads its scene (see `botVariableUpdate` in `RoomController`).

### `bots` RoomVariable JSON shape

```jsonc
[
  {
    "key":            "string",     // unique metaKey of the bot inside this room
    "posX":           0,            // tile col
    "posY":           0,            // tile row
    "width":          1,
    "height":         1,
    "length":         1,            // depth-along-z; used for click footprint
    "ver":            0,            // asset version (URL: <key>.<ver>.swf)
    "property":       { "cn": "<PropertyClass>", ...data },  // optional — fires on bot click
    "speechProperty": { "cn": "<PropertyClass>", ...data }   // optional — fires on hover/idle bubble
  }
]
```

`BotModel.load` maps server fields onto `BotVO`:
- `key  → metaKey` (also used as the SWF clip name and as the dictionary key)
- `nick = $(key)`  — display name comes from the locale file, not the wire
- both `property` and `speechProperty` are instantiated via
  `getDefinitionByName("com.oyunstudyosu.property." + cn)` — same property
  class catalog as doors (see [04 §4.5](04-rooms-and-walking.md#45-door--portal-system)).

### Bot speech contract

`speechProperty.cn` is typically `SimpleBotMessageProperty` for canned
greetings. The text key sent in `data` is keyed by `BotSpeechTypes`
(see [05 §5.4](05-enums-and-types.md#54-protocol-enums)): `welcome`,
`goodbye`, `casual`, `shop-purchase`, `shop-cancel`.

### Adding a bot live

The server may emit `addQuestBot` (push, payload mirrors a single `bots`
entry) when a quest spawns a temporary bot — the client patches it into
the scene without a full room reload. This is the only path that bypasses
the `bots` RoomVariable reload.

### `CharacterType` (also covers bots)

[CharacterType.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/enums/CharacterType.as):
`NORMAL=0`, `BOT=1`, `ADBOT=2`, `CUSTOMBOT=3`. The numeric type controls
which AS3 class the engine instantiates (`Character`, `Bot`, ad bot, or
custom bot from `displayAd/AdBot`). `ADBOT` is reserved for display-ad
bots (see §6.18) and must not be sent for content bots.

## 6.13 Interactive entries — the `objectXchanged` push family

[EntryModel.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/interactive/EntryModel.as),
[EntryVo.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/interactive/EntryVo.as),
[RoomController.as L113-L300](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/room/RoomController.as).

The runtime client builds one `EntryVo` per `<box>`/`<chair>`/`<stuff>`/…
entry it sees in the room map XML (§4.3). The `EntryModel` dictionary is
keyed by integer `id` and stays mutable for the lifetime of the room —
five extension pushes mutate it on the wire.

### `EntryVo` runtime fields (server stamp these on the map XML)

| Field | XML attr | Meaning |
|---|---|---|
| `id` | `id` | entry primary key |
| `definition` / `clip` | `def` | furniture clip name |
| `x`, `y`, `z` | `x`,`y`,`z` | tile col, height tier, tile row |
| `width`, `height`, `depth` | `w`,`h`,`d` | footprint |
| `f` | `f` | current frame index (1-based) |
| `s` | `s` | "state" — 0 = none, 1 = coin overlay, 2 = diamond overlay |
| `fx` | `fx` | flip-x flag |
| `lc` | `lc` | lock count (0 unlocked, >0 shows padlock icon) |
| `st` | `st` | stock total |
| `sv` | `sv` | stock current — `setIndicator()` shows `sv/st` % |
| `property` | CDATA JSON | `{cn:…, …data}` (see §6.10) |

### Server-push payload shapes

All five pushes are room-scoped (delivered to every user in the room).

| Push name | Payload | Client effect |
|---|---|---|
| `objectframechanged` | `{ id, frame }` | `EntryVo.gotoFrame(frame)`; for `GridSealingProperty` entries, also flips walkability for every covered cell to `frame == 1 ? walkable : blocked` |
| `objectstatechanged` | `{ id, state }` | Sets `EntryVo.s`. `0` removes the overlay; `1` adds a `Coin` overlay; `2` adds a `DiamondR` overlay |
| `objectlockchanged` | `{ id, locked }` | Sets `EntryVo.lc`; calls `lockState()` to update the lock icon |
| `objectstockchanged` | `{ id, stock }` | Sets `EntryVo.sv`; calls `setIndicator()` and shows a `GatheringStockChanged` toast |
| `objectremoved` | `{ id }` | Walks `width × depth` cells back to walkable, removes from `EntryModel`, hides the clip |
| `farmstatuschanged` | `{ id, status, property:{cn:"FarmProperty", item:{clip,…}, status:{state,…}} }` | Re-binds the property; jumps to frame `1` for `CLEANED`/`HARVESTED`, otherwise `gotoFrameLabel(item.clip + status.state)`. Valid `status` values: `PLANTED`, `SEEDLING`, `PRODUCT`, `DRY`, `HARVESTED`, `CLEANED` |

### Client-initiated entry mutations

| Request | Payload | Server contract |
|---|---|---|
| `changeobjectframe` | `{ id }` | Toggle frame (open/close door, seal/unseal wall) → broadcast `objectframechanged` |
| `changeobjectlock` | `{ id }` | Toggle lock state → broadcast `objectlockchanged` |
| `farmimplantation` | `{ id, itemID }` | Plant a seed in a farm cell → reply OK + broadcast `farmstatuschanged` |
| `farmgather` / `farmclean` | `{ id }` | Harvest / clean a farm cell |
| `gatheritemsearch` / `gatheritemcollect` | `{ id }` / `{}` | Two-phase resource-gather flow (§6.10 `GatheringProperty`) |

> Server invariant: `EntryVo.s` and `EntryVo.lc` must NEVER mutate without
> the matching push — the visible coin/diamond/lock overlays are driven
> entirely by `state`/`locked` push values, not by a poll.

## 6.14 Room extensions (`extension/` + the `cmd2user`/`cmd2All` bus)

[ExtensionController.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/controller/ExtensionController.as),
[BaseExtension.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/extension/BaseExtension.as).

A "room extension" is a SWF that the server tells the client to load on
top of the current room — typically a mini-game (tombala, pirate, fishing)
or a seasonal overlay. It runs inside the room's iso scene as a
`BaseExtension` MovieClip.

### Lifecycle pushes

| Push | Payload | Client effect |
|---|---|---|
| `startextension` | `{ key:string, property:object }` | If an extension with `key` is already loaded, dispose it; then call `extensionModel.loadExtension(key, property, 0)` which fetches the SWF via `ModuleType.EXTENSION` and instantiates `BaseExtension.init(property)` |
| `stopextension` | `{ key:string }` | `extensionModel.removeExtension(key)` — disposes + removes from scene |

### Static (room-bound) extensions

The `extensions` RoomVariable is a JSON array of
`{ key, property? }` entries that should be auto-loaded the moment the
room is entered. The server should stamp this at room-create time
alongside `grid`/`doors`/`bots` so the client never sees a
`startextension` race during scene load.

### The generic command bus (`cmd2user` / `cmd2All`)

[GameRequest.MESSAGE = "cmd2user"](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/enums/GameRequest.as)
and [GameResponse.CMD2ALL = "cmd2All"](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/enums/GameResponse.as)
are the catch-all command channels that room extensions use to broadcast
without registering their own named extension request. Wire shape:

```jsonc
// client → server: targeted to one user
{ "command": "cmd2user", "to": "<avatarID>", "payload": { ... } }

// server → client (push): broadcast to room
{ "command": "cmd2All", "from": "<avatarID>", "payload": { ... } }
```

Routing is opaque to the SFS extension — it just relays the `payload`
blob. Each room extension SWF defines its own `payload.type` codes and
parses them inside `BaseExtension.init`. The server should:
1. Accept `cmd2user` and forward `{ from:senderID, payload }` to the
   addressed user only.
2. Accept `cmd2All` and forward the same envelope to every user in the
   sender's room (sender included is the original behaviour — confirm per
   extension).
3. Never inspect `payload`; if the payload references game state the
   server owns (e.g. tombala numbers), implement a dedicated named
   request instead.

## 6.15 Party Island & joystick (`game/` package)

[PartyIslandController.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/game/partyisland/PartyIslandController.as),
[IslandServiceComponent.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/game/partyisland/components/IslandServiceComponent.as),
[IslandLobbyComponent.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/game/partyisland/components/IslandLobbyComponent.as),
[JoystickController.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/game/JoystickController.as).

Party Island is a turn-based dice-board minigame attached to its own SFS
room (`Sanalika.roomModel.interactiveRoom`). All `partyIsland.*` traffic
is scoped to that room — the client passes
`Sanalika.instance.roomModel.interactiveRoom` as the 4th `requestData`
argument so the server can route by room id.

### Request payloads (C → S)

| Request | Payload |
|---|---|
| `partyIsland.rollDice` | `{}` (sent on the user's turn) |
| `partyIsland.leave` | `{}` |
| `matchmakingCancel` | `{}` |

### Server push payloads (S → C)

| Push | Payload |
|---|---|
| `partyIsland.startGameTimer` | `{ timeout:int (ms) }` — lobby countdown |
| `partyIsland.turn` | `{ avatarId:string, timeout:int (ms), lastTurnAt:long }` |
| `partyIsland.dice` | `{ dice1:int, dice2:int }` |
| `partyIsland.gameState` | `{ pool:object, players:[{ avatarId, finishedAt, lastTurnAt, turnIndex, balances:[{balance:long, ...}] }] }` |
| `partyIsland.joinStatus` | `{ players:[{ avatarId, isJoinComplete:bool }] }` |
| `partyIsland.property` | `{ avatarId, property:string, data:object }` — `property` keys a class in `PartyPropertyList`; client instantiates and runs `execute(avatarId, data)` |
| `partyIsland.gameCanceled` | `{ reason:string }` — localized via `localizationModel.translate` |
| `continuePartyIslandGame` | `{ ... }` — fired when reconnecting mid-match (handled by `PartyIslandController`) |

The room ends via the SFS RoomVariable `isGameEnded:bool` (also `isGameStarted`,
`startPoint`, `finishPoint`).

### Joystick (mobile drop-throw)

[JoystickController.as L60-L100](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/game/JoystickController.as)
sends `dropthrowaction { type:"throw", xTarget:int, yTarget:int }` when
the player drag-releases onto another character. Server should mirror
the desktop `dropthrowaction { targetAvatarID }` flow but accept this
tile-coord variant (server resolves the character at `(xTarget, yTarget)`).

## 6.16 Farm, café orders, provision (the `model/` push family)

[FarmModel.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/model/FarmModel.as),
[OrderModel.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/model/OrderModel.as).

### Farm

| Direction | Name | Payload | Notes |
|---|---|---|---|
| C→S | `farmitemlist` | `{}` | Returns plantable seeds for this user |
| C→S | `farmimplantation` | `{ id:int, itemID:int }` | Plant `itemID` in farm cell entry `id`; reply `{ errorCode? }` |
| C→S | `farmgather` | `{ id }` | Harvest |
| C→S | `farmclean` | `{ id }` | Clean dried-out farm cell |
| S→C push | `farmstatuschanged` | see §6.13 | Drives the in-room frame label swap |

Farm-state machine on the entry's `property.status.state`:
`PLANTED → SEEDLING → PRODUCT → DRY` (auto-progression server-side,
each transition emits `farmstatuschanged`). `HARVESTED` and `CLEANED` are
the user-triggered terminals.

### Café orders

| Direction | Name | Payload | Notes |
|---|---|---|---|
| C→S | `orderrequest` | `{ items[], cafeID }` | Customer places order |
| C→S | `orderprepare` | `{ orderID }` | Owner accepts |
| C→S | `ordercancel` | `{ orderID }` | Either party cancels |
| C→S | `orderlist` / `orderdetail` | `{}` / `{ orderID }` | Inbox views |
| S→C push | `neworder` | `<order>` | Pushed to owner — adds to `orderList`, fires `OrderEvent.NEW_ORDER`, toast `orderRECEIVED` |
| S→C push | `orderpreparing` | `{ id }` | Pushed to customer — flips local `orderRequest.status = "PREPARING"` |
| S→C push | `orderdelivered` | `{ id }` | Owner removes from `orderList`; customer sees `"DELIVERED"` |
| S→C push | `ordercancelled` | `{ id }` | Owner removes; customer sees `"CANCELLED"` |
| S→C push | `ordertimedout` | `{ id }` | Same delivery logic as cancelled but fires `OrderEvent.TIMEDOUT` |

> **Distinction:** the **owner** of the café sees `orderList` (a queue of
> incoming orders) while the **customer** sees a single `orderRequest`
> with rolling status. The server must publish each event to the right
> side: `neworder`→owner, `orderpreparing`/`orderdelivered`→customer,
> `ordercancelled`/`ordertimedout`→both.

### Café provision

`provisionrequest` / `provisionapprove` (see [03 §3.1](03-protocol-catalog.md))
let café staff request restocks from the owner. Payload shapes were not
traced — handle them as opaque pass-through for now and log received
fields server-side.

## 6.17 Permission encoding (`auth/` package)

[Permission.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/auth/Permission.as),
[PermissionUtils.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/auth/PermissionUtils.as).

The numeric `AvatarPermission` constants in [05 §5.1](05-enums-and-types.md#avatarpermission-enumsavatarpermissionas)
(values `2`…`50`) are bit indices into a **little-endian** ByteArray
serialized as base64. Every permission check the client makes
(`Cell.isWalkable`, door visibility, VIP UI gates, …) goes through
`permission.check(index)`.

### Wire format

- Carrier: the `roles` UserVariable (per character) and `init.roles` (for
  self at boot). The string is a base64-encoded little-endian ByteArray;
  empty string means "no permissions".
- Bit layout: permission index `N` is encoded at:
  - `byteIndex = ceil(N/8) - 1`
  - within-byte `bit = (N % 8 == 0) ? 7 : (N % 8) - 1`

  i.e. indexes `1..7` live in byte 0 as `1<<0`…`1<<6`, index `8` is
  `1<<7` of byte 0, index `9` is `1<<0` of byte 1, and so on.

### Server-side encoding pseudocode

```python
def encode_permissions(indexes: list[int]) -> str:
    needed = (max(indexes) + 7) // 8
    buf = bytearray(needed)
    for n in indexes:
        byte_idx = (n + 7) // 8 - 1
        bit = 7 if n % 8 == 0 else (n % 8) - 1
        buf[byte_idx] |= 1 << bit
    return base64.b64encode(bytes(buf)).decode()
```

`PermissionUtils.atLeastOne(a, b)` and `allOfThem(a, b)` are bulk
comparisons used for role-gated rooms and rules. `Permission.grant(n)`,
`deny(n)`, `check(n)` operate on the live ByteArray in place. Decoding:
`PermissionUtils.grantedIndexes(base64String)` returns the `int[]` of
granted indexes.

### When to update

- **Initial value**: `avatarModel.permission.value` is set from the init
  reply (`data.roles`) before `engine.start()`.
- **Live update**: `AvatarController` re-reads `roles` from the user-var
  delta and assigns `permission.value` whenever the string changes. Per-
  character permissions on other users are updated the same way in
  `Character` via the `roles` UserVariable.
- The server MUST emit a new base64 string the moment a role is granted
  or revoked (e.g. VIP purchase, ban, moderator promotion). The client
  never derives permissions from anything else.

## 6.18 Restricted users, kick, tutorial, display ads

### Restricted users (`restricted/`)

A "restricted" relationship is a privacy block (similar to a buddy block).

| Direction | Name | Payload | Notes |
|---|---|---|---|
| C→S | `removeavatarrestriction` | `{ cmd:"remove", avatarID }` | Unblock |
| S→C push | `avatarRestrictionRemoved` | `<vo>` | Server confirms; `RestrictedModel.removeFromRestricted` drops the entry |

The `RestrictedRequestTypes` / `RestrictedResponseTypes` enums define the
client-side action strings but no other commands are wired in this build.

### Kick (`roomkick/`)

[KickData.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/roomkick/KickData.as)
is a UI catalogue mapping a kick option to its duration in seconds:

| Label key | Seconds |
|---|---|
| `kickOnce` | -1 (one-shot, no ban) |
| `kickOneHour` | 3600 |
| `kickSixHour` | 21600 |
| `kickOneDay` | 86400 |
| `kickOneWeek` | 604800 |
| `kickOneMonth` | 2592000 |
| `kickUnLimited` | 0 (perma) |

Wire:

| Direction | Name | Payload |
|---|---|---|
| C→S | `kickAvatarFromRoom` | `{ avatarID, seconds:int }` — `seconds` matches the KickData value (use `0` for unlimited, `-1` for one-shot) |
| S→C push | `kickedAvatarFromRoom` | full room-join payload (same shape as `usedoor` reply) — the kicked user is auto-relocated, the client also pops a `kickedFromHomeByOwner` toast |

`DoorModel.kickedFromRoom` calls `roomModel.checkMap(payload)` on the
push payload, so the server must include `room:{map, doorKey}` exactly
like a teleport reply.

### Tutorial (`tutorial/`)

[TutorialEvent.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/tutorial/TutorialEvent.as)
defines the step constants (client-side state only):

| Step | Const |
|---|---|
| 0 | `WELCOME` |
| 1 | `REAL_ESTATE` |
| 2 | `BACK_TO_STREET` |
| 3 | `USER_ROOM` |
| 4 | `FISHING_STEP` |
| 5 | `JOIN_GAME` |

Wire:

| Direction | Name | Payload |
|---|---|---|
| C→S | `tutorialupdated` | `{ step:int }` — client persists the user's current tutorial step |
| (events only) | `TutorialEvent.CHANGE_STEP` / `SHOW_TUTORIAL_BUTTON` / `EXIT_TUTORIAL` | UI-local |

The server stores the latest `step` (so it survives reconnect) and may
echo it back via the next `init` reply.

### Display ads (`displayAd/`)

[AdModel.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/displayAd/AdModel.as)
listens for one push and dispatches by `ads[i].type`.

`displayAd` push payload:

```jsonc
{
  "ads": [
    {
      "type":     "VIDEO" | "VIPVIDEO" | "BOT" | "BILLBOARD"
                | "PANEL" | "AIRSHIP" | "DAVULCU" | "PAYMENTPANEL",
      "alias":    "string",      // dedupe key (also used as cookie key "ad_<alias>")
      "repeat":   int,           // max times this user should see it; 0 = unlimited
      "id":       int,
      "assetUrl": "string",      // CDN URL for the SWF / video
      "length":   int,           // seconds (videos)
      "clickUrl": "string",      // optional click-through URL
      "skipSecond": int,         // when the skip button unlocks (videos)
      ...                        // type-specific extras consumed by AdBot/AdBillboard/AdAirship/AdSkin/NpcBot/Davulcu/VideoPanel
    }
  ]
}
```

Behaviour gates:
- `VIDEO` ads are skipped entirely for users whose `permission.check(4)` is
  true (VIP) — server should NOT bother sending videos to VIPs.
- A per-user cookie `ad_<alias>` tracks how many times each ad ran; the
  client refuses to display once `cookieCount >= repeat` (unless
  `repeat == 0`).
- `PANEL` and `PAYMENTPANEL` are random-delayed by `5 + Math.random()*10` s
  before opening to avoid login-storm pop-ups.
- `BILLBOARD`, `AIRSHIP`, `BOT`, `DAVULCU` spawn iso-scene objects via
  `AdBillboard`, `AdAirship`, `AdBot`, `Davulcu` respectively — these use
  `ModuleType.AD_BILLBOARD`, `AD_AIRSHIP`, `AD_BOT`, `AD_SKIN` for asset
  paths.

The server is the source of truth for which ads a room should run; it
pushes `displayAd` on `roomjoincomplete` (and may push again mid-session
when ad rotation changes).

### Concert / mediaevent (`concert/`)

[ConcertModel.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/concert/ConcertModel.as).

Single push `mediaevent` drives the in-room music/sound streaming:

```jsonc
{
  "status": 1 | 0,           // 1 = play, anything else = stop
  "path": {
    "stream_path": "https://.../track.mp3",
    "groupID":     "string"  // optional; if set, the client loads the matching
                             // ModuleType.CONCERT_SWF visual on top
  }
}
```

Behaviour: client opens an HTTP `Sound` stream, optionally loads a SWF
visual (concert stage, DJ booth, …) and starts playback. Stopping is just
`status != 1`. Cinema (`startroomvideo`) is the YouTube/video counterpart
and is server-pushed the same way.

### Discord rich-presence (`discord/`)

`RoomController.startload` writes Discord state from the room data:
`setDetails(universe)`, `setState(title)`, `setSecrets({roomID, type})`,
`setParty(currentRoom.id, userCount, capacity)`. Server impact: zero —
all driven by RoomVariables the server already publishes (`roomID`,
`type`, room name). Mentioned here only so contributors don't search for
a missing wire push.

---

[← Enums & types](05-enums-and-types.md)  ·  [Index](README.md)  ·  [Next: Asset pipeline →](07-asset-pipeline.md)
