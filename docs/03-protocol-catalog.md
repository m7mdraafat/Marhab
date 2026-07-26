# 3. Complete protocol catalog

[← Bootstrap](02-bootstrap.md)  ·  [Index](README.md)  ·  [Next: Rooms & walking →](04-rooms-and-walking.md)

Mined from every `serviceModel.requestData(...)` call site, every
`listenExtension(...)` registration, and every `SFSEvent` RoomVariable /
UserVariable read across [../rebuild/inventory/snl_780_src/scripts/](../rebuild/inventory/snl_780_src/scripts).

Constant names mirror
[enums/RequestDataKey.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/enums/RequestDataKey.as).
Some commands listed below appear only as `RequestDataKey` constants
(call-site exists in the patched/legacy code paths but the helper function
that fires them is rarely exercised); they are still part of the contract
the server must understand.

## 3.1 Client → server extension requests (~110+ commands)

### Auth / bootstrap

| Cmd | Payload | Callback | Reads from response |
|---|---|---|---|
| `config` | `{}` | `ConfigCommand.responseFunction` | `moods, chatBaloons, itemFile, versionFile, langFile, fileServer[], webServer, language, farmCleaningCost, farmMaxPlantedItemSize, order, masterRoles` |
| `init` | `{}` | `Sanalika.onInited` | see [02-bootstrap.md §2.4](02-bootstrap.md#24-exact-init-reply-contract--every-field-oninited-reads) |
| `ping` | `{}` | none | keepalive |
| `emailActivation` | `{ email }` | `AvatarModel.onEmailActivation` | `success` |

### Walk / room / door

| Cmd | Payload | Callback | Reads |
|---|---|---|---|
| `walkrequest` | `{ x:int, y:int, door:bool }` | listener (`WalkModel.onWalkStart`) | `delay:int (ms)` |
| `walkfinalrequest` | `{}` | none | — |
| `roomjoincomplete` | `{}` | none | — (server may broadcast `roomjoincomplete` push) |
| `teleport` | `{ roomKey:string }` | none | SFS join + room map push |
| `usedoor` | `{ key:string, type:string }` | none | room change. `type` is whatever the property's `data.type` is — for door-loaded properties `DoorVO.setProperty` always overwrites it with `"door"`, so the server should treat this field as advisory only |
| `usehousedoor` | `{ flatID:string, password:string, avatarID:string }` | `DoorModel.onUseHouseDoorResponse` | building data |
| `useobjectdoor` | `{ id:string }` | `FlatEnterProperty.onChange` | building data |
| `loadroomdesign` | `{}` | callback | `{ roomKey, areas[], inventory[], furnitures[] }` — see [room-designer-contract.md](../rebuild/) in repo memory for the exact field-level shape |
| `saveroomdesign` | `{ design:[{id,clip,dir,x,y,z}] }` | callback | `{ room:{ map:<base64>, doorKey } }` |
| `changeobjectframe` | `{ id }` | `onFrameChange` | `{ frameSet }` |
| `changeobjectlock` | `{ id }` | `onLockChange` | lock state |
| `master.addroom` | master-room edit payload | callback | OK |
| `master.updateroom` | master-room edit payload | callback | OK |
| `flatpassword` | `{ flatID, password }` | callback | OK |
| `flatsettings` | `{ flatID, settings }` | callback | OK |

### Cloth / avatar

| Cmd | Payload | Callback | Reads |
|---|---|---|---|
| `clothlist` | `{}` | callback | `items[]` |
| `baseclothlist` | `{}` | callback | `items[]` (default outfit) |
| `changeclothes` | `{ itemIDs:int[] }` | callback | echo |
| `savebaseclothes` | `{ itemIDs:int[] }` | callback | OK |
| `changesettings` | `{ key, value }` | callback | OK |
| `changesmiley` | `{ id }` | callback | OK |
| `changeuniverse` | `{ universeKey }` | callback | OK |
| `universelist` | `{}` | callback | `universes[]` |
| `usesticker` | `{ id }` | none | — |
| `stickerlist` | `{}` | none | `stickers[]` |
| `usechatballoon` | `{ id:int }` | `changeChatColorResponse` | OK |
| `usehanditem` | `{ id:int }` | `useHandItemResponse` | OK |
| `handitemlist` | `{}` | callback | `items[]` |
| `specialitemlist` | `{}` | callback | `items[]` |
| `handItemProperty` | `{ id }` | callback | `{ property }` |

### Profile / shop / economy

| Cmd | Payload | Callback | Reads |
|---|---|---|---|
| `profile` | `{ avatarID }` | callback | profile object |
| `profilelike` | `{ avatarID }` | callback | OK |
| `profileimproper` | `{ avatarID, reason }` | callback | OK |
| `purchase` | `{ shopID:int, objectID:int, items:[{shopProductID,quantity,color?}] }` | `itemPurchaseResponse` | `{ items:[{type, items, cost}] }` |
| `flatpurchase` | same as purchase | same | as above |
| `flatsponsor` | `{ flatID, sponsorshipMonths }` | callback | OK |
| `avatarsalescollect` | `{ id }` | `onStateChange` | `{ gains:[{amount, currency}] }` |
| `shopproductlist` | `{ shopID }` | callback | `products[]` |
| `exchangediamond` | `{ diamondQuantity }` | callback | `{ exchangedAmount }` |

### Flats (user-owned rooms)

| Cmd | Payload | Callback | Reads |
|---|---|---|---|
| `flatlist` | `{}` | callback | `flats[]` |
| `flatsearch` | `{ query, page }` | callback | `results[]` |
| `flatinfo` | `{ flatID }` | callback | `{ flatData, owner, furniture[] }` |
| `flatfavorite` | `{ flatID, isFavorite }` | callback | echo |
| `changeflatinfo` | `{ flatID, name, description }` | callback | OK |

### Inventory / expirables / drop

| Cmd | Payload | Callback | Reads |
|---|---|---|---|
| `listexpirables` | `{}` | callback | `items[]` |
| `addExpirables` | `{ id, duration }` | callback | echoes item |
| `expire` | `{ id }` | callback | echoes id |
| `drop` | `{ type:"COLLECT" }` | `onDropResponse` | OK |
| `dropthrowaction` | `{ targetAvatarID }` | `onThrowResponse` | OK |

### Buddy / private chat / chat

| Cmd | Payload | Callback | Reads |
|---|---|---|---|
| `buddylist` | `{}` | `friendListResponse` | `buddies[]` |
| `addbuddy` | `{ avatarID }` | none | — |
| `addbuddyresponse` | `{ avatarID, accepted:bool }` | callback | — |
| `removebuddy` | `{ avatarID }` | none | — |
| `buddylocate` | `{ avatarID }` | callback | `{ location }` |
| `buddyinvitelocation` | `{ avatarID, location, roomKey? }` | none | — |
| `buddyrespondinvitelocation` | `{ avatarID, accepted, roomKey }` | none | — |
| `buddyacceptinvitegame` | `{ avatarID, game }` | none | — |
| `changebuddyrating` | `{ avatarID, rating }` | none | — |
| `changemood` | `{ mood:int }` | none | — |
| `changestatusmessage` | `{ message }` | none | — |
| `diamondtransferrequest` | `{ targetAvatarID, amount }` | none | — |
| `diamondtransferresponse` | `{ targetAvatarID, accepted }` | none | — |
| `whisper` | `{ targetAvatarID, message }` | none | — |
| `groupwhisper` | `{ targetList[], message }` | none | — |
| `privatechatlist` | `{}` | `privateChatListResponse` | `groups[]` |
| `messagedetails` | `{ groupID }` | `chatDetailsResponse` | messages |
| `privatechatdeletegroup` | `{ groupID }` | none | — |

### Transfer / barter

| Cmd | Payload | Callback | Reads |
|---|---|---|---|
| `transferrequest` | `{ targetAvatarID, itemID, quantity? }` | none | — |
| `transferresponse` | `{ senderID, transferID, response:"ACCEPTED"\|"REJECTED" }` | none | — |
| `giftcheckexchange` | `{ id }` | `checkServiceResponse` | OK |
| `barterrequest` | `{ avatarID }` | none | — |
| `barterresponse` | `{ barterID, response }` | `onBarterResponse` | — |
| `bartercancel` | `{ barterID }` | none | — |

### Quest / achievement / report

| Cmd | Payload | Callback | Reads |
|---|---|---|---|
| `questlist` | `{ showDetail:bool }` | `onQuestList` | `quests[]` |
| `questaction` | `{ id }` | `onOngoingResponse` | `{ curVal, reqVal }` |
| `campaignquest` | `{ id }` | `giftOnceResponse` | OK |
| `randomwheel` | `{ action }` | `campaignGiftResponse` | reward |
| `fortunewheel` | `{ action }` | callback | reward |
| `gamescoretoplist` | `{ game }` | callback | `top[]` |
| `prereport` | `{ avatarID }` | callback | OK |
| `report` | `{ avatarID, reason }` | callback | OK |
| `livemessage` | `{ message }` | callback | OK |
| `removeavatarrestriction` | `{ emailCode, smsCode }` | none | — |

### Farm / business / orders / café

| Cmd | Payload | Callback | Reads |
|---|---|---|---|
| `farmitemlist` | `{}` | callback | `items[]` |
| `farmimplantation` | `{ id, cropID }` | `onImplantResponse` | OK |
| `farmgather` | `{ id }` | `onHarvestStart` | OK |
| `farmclean` | `{ id }` | `onCleanStart` | OK |
| `gatheritemsearch` | `{ id }` | `onSearchStart` | OK |
| `gatheritemcollect` | `{}` | `onItemCollect` | `items[]` |
| `orderlist` | `{}` | `onListResponse` | `orders[]` |
| `orderdetail` | `{ orderID }` | callback | order |
| `ordercancel` | `{ orderID }` | callback | OK |
| `orderprepare` | `{ orderID }` | callback | OK |
| `orderrequest` | `{ items[], cafeID }` | callback | OK |
| `startroomvideo` | `{ videoUrl }` | none | — |

### Misc

| Cmd | Payload | Callback |
|---|---|---|
| `debugcommand` | `{ params }` | none |
| `matchmakingCancel` | `{}` | none |
| `partyIsland.leave` | `{}` | none |
| `partyIsland.rollDice` | `{}` | none |

### Sale / mini-games / craft / support / profile (verified in RequestDataKey but not always hand-documented above)

The following constants appear in
[enums/RequestDataKey.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/enums/RequestDataKey.as)
— the server must accept them with the same name even though their full
payload shape is best discovered by following the constant back to its
unique call site.

| Cmd | Constant | What the client uses it for |
|---|---|---|
| `provisionrequest` | `PROVISION_REQUEST` | café provision order |
| `provisionapprove` | `PROVISION_APPROVE` | café provision approval |
| `saleproductlist` | `SALEPRODUCT_LIST` | list user-listed items for sale |
| `saleproductpurchase` | `SALEPRODUCT_PURCHASE` | buy listed item |
| `sellableitems` | `SALE_ITEM_START` | start sell flow (list which inventory items qualify) |
| `sellitems` | `SALE_ITEM_COMPLETE` | commit sale |
| `changeskincolor` | `SOLARIUM` | solarium tan (SolariumPanelProperty) |
| `nickChange` | `NICKCHANGE` | rename avatar (NickChangePanelProperty) |
| `fishing.start` | `FISHING_START_GAME` | start fishing minigame |
| `ship.startjourney` / `ship.listjourney` / `ship.selectmemorycard` | `SHIP_*` | sea-journey minigame |
| `snowball.join` / `snowball.throw` | `SNOWBALL_*` | snowball event |
| `funwin` / `funwinadd` / `funwinanswer` / `funwintoplist` | `FUNWIN*` | quiz minigame |
| `funbid.join` / `funbid.bid` | `FUNBID_*` | live-auction minigame |
| `runwinjointeam` / `runwinnewteam` / `runwinstatus` / `runwinteamlist` | `RUNWIN_*` | racing minigame |
| `craftItem` / `craftItemQuery` / `craftItemList` | `CRAFT_*` | crafting workflow |
| `emailValidate` | `EMAIL_VALIDATE` | confirm email by code |
| `profileskinlist` / `useprofileskinwithclip` | `PROFILE_SKIN_LIST`, `USE_PROFILE_SKIN_WITH_CLIP` | profile theme skinning |
| `supportticketget` / `supportticketmessagesget` / `supportticketadd` / `supportticketmessageadd` / `supportsubjects` | `SUPPORT_TICKET_*`, `SUPPORT_SUBJECTS` | support inbox |
| `pubContentList` / `pubContentDetailLike` | `PUB_LIST`, `PUB_LIKE` | in-game noticeboard |
| `newslist` / `banlist` / `complaintlist` / `complaintaction` / `mediaevent` | `NEWS_LIST`, `BAN_LIST`, `COMPLAINT_*`, `MEDIA_EVENT` | admin / mod views |
| `guidelist` / `guideaction` / `guidemessage` / `guiderequest` | `GUIDE_*` | guide (mentor) workflow |
| `addQuestBot` | `ADD_QUEST_BOT` | room-scoped quest bot insertion |
| `questaccept` / `questdetail` / `questupdate` | `QUEST_*` | quest interactions beyond `questlist` / `questaction` / `campaignquest` |
| `achievementgivereward` / `achievementlist` / `exhibitionlist` / `jobinfo` | `ACHIEVEMENT_*`, `EXHIBITION_LIST`, `JOB_LIST` | profile-side lists |
| `kickAvatarFromRoom` | `KICK_AVATAR_FROM_ROOM` | moderator boot |
| `sendprivatemessage` / `leaveprivatechatgroup` / `addmessagetoprivatechatgroup` / `loadmoremessagetoprivatechatgroup` / `removemessagetoprivatechatgroup` / `setactivegroup` | `*PRIVATE_CHAT_*` | private-chat group management |
| `roommessage` | `ROOM_MESSAGE` | public chat fan-out (the equivalent of an SFS `publicMessage` but routed through the extension) |
| `smileylist` / `smiliesUpdated` | `SMILEY_LIST`, `SMILEY_UPDATE` | smiley catalog refresh |
| `changeavatarsize` / `baninfo` / `avatarlist` / `avatarswitch` / `avatarcreate` / `baseclothes` | `CHANGE_SIZE`, `AVATAR_BANINFO`, `AVATAR_LIST`, `AVATAR_SWITCH`, `AVATAR_CREATE`, `BASE_CLOTHES` | avatar account ops |
| `tutorialupdated` | `TUTORIAL_UPDATED` | client-driven tutorial progress |
| `openpackage` / `sendPepsiCode` | `OPEN_PACKAGE`, `SEND_PEPSI_CODE` | redeemables |
| `ingamereport` | `SECURITY_ACTION` | client-triggered security action (cheat detect) |
| `livemessage` | `LIVE_MESSAGE` | broadcast message (admins) |
| `gamescoretoplist` | `GET_TOP_LIST` | leaderboard query |
| `farmclean` / `farmgather` | (legacy farm gather/clean — server may keep alias) | farm interactions |

> **Convention** — when a constant ends in `_RESPONSE`, `_RESULT`,
> `_CANCELLED`, `_UPDATED`, `_RESPOND`, it is the **server push** name for
> the corresponding client request. Server should listen for the request
> name (without suffix) and emit the suffixed name back to the user (and,
> for `*_RESULT` / `*_CANCELLED`, to the counter-party).

## 3.2 Server → client push events (~80)

Registered via `serviceModel.listenExtension(name, handler)`. Grouped:

### Init / lifecycle / errors

- `initQueue` → `Sanalika.onInitQueueData` (ts, p)
- `coreOldVersion` → force update
- `disconnect`, `reloadStart`, `reloadSuccess`, `requestTimeout`, `restartServer`
  ([ServiceController.as:L41-L46](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/service/ServiceController.as))
- `langData` (delta language strings)
- `infoMessage`, `publicMessageLimitExceeded`
- `securitycaptcha` (challenge), `securitykey` (2FA setup)
- `banned`, `banExpired`, `unbanned`
  ([BanModel.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/ban/BanModel.as))
- `kickedAvatarFromRoom` ([DoorModel.as:L26](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/door/DoorModel.as))

### Avatar / wallet / roles

- `updateWallet` `{ gold, diamonds }`
  ([AvatarController.as:L66](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/avatar/AvatarController.as))
- `avatarLikeUpdated`, `roles`, `moderatorNotice`
- `teleport` (server-initiated relocation)
- `usehanditem`, `throwItem`, `throwHit`, `treasure`, `reLocate`, `stickerShow`, `stickerlist`
- `userFlatEntered` `{ avatarName, flatName }`

### Room state (RoomController listeners)

- `roomDesignUpdated`, `joinError`, `masterRoomUpdated`
- `objectframechanged`, `objectstatechanged`, `objectlockchanged`,
  `objectstockchanged`, `objectremoved`
- `farmstatuschanged`
- `usedoor` (forwarded transition), `recommendeduniverse`, `removeRoomClient`
- `roomjoincomplete` (handshake response)

### Quest / achievement / drop / chat

- `questlistroom`, `queststepcomplete`, `questcomplete`
- `achievementupdate`
- `dropItem`, `dropRemoveItem`
- `whisper`, `whispernotify`
- `privatemessagereceived`, `privateChatLimitExceeded`

### Buddy / transfer / barter

- `buddyAdded`, `buddyRemoved`, `buddyRelationUpdated`, `respondBuddyRequest`,
  `buddy.moodchanged`, `buddyOnlineStatus`, `buddy.changestatusmessage`,
  `buddyrequestfulladded`, `buddyInviteLocation`, `buddyInviteLocationRespond`,
  `buddyInviteGame`
- `respondDiamondTransferRequest`, `diamondTransferResult`,
  `diamondTransferCancelled`, `diamondTransferDailyLimitExceeded`
- `respondTransferRequest`, `transferResult`, `transferCancelled`
- `respondBarterRequest`, `barterStarted`

### Games / matchmaking / ads

- `matchmakingStart`, `matchmakingCancel`
- `startextension`, `stopextension` (room extensions)
- `displayAd`
- `funShake` (screen shake)
- Party Island: `partyIsland.startGameTimer`, `partyIsland.turn`,
  `partyIsland.dice`, `partyIsland.gameState`, `partyIsland.joinStatus`,
  `partyIsland.property`, `partyIsland.gameCanceled`

## 3.3 RoomVariables (server-set, client read-only)

> **Note** — only `TYPE`, `KEY`, `TITLE`, `WIDTH`, `HEIGHT` (and the
> `OUTDOOR`/`INDOOR`/`BUSINESS` value strings) are exposed as constants in
> [enums/RoomVariable.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/enums/RoomVariable.as).
> Every other variable below is referenced as a raw string literal by
> [RoomController.startload](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/room/RoomController.as)
> and friends. The server contract is the **string**, not the enum slot.

| Var | Type | Purpose |
|---|---|---|
| `roomKey` | string | unique room identifier |
| `type` | string | room type (`OUTDOOR`, `INDOOR`, `BUSINESS`) |
| `title` / `roomTitle` | string | display name (`roomTitle` wins when both present) |
| `width`, `height` | int | grid dimensions in **cells** (not pixels — RoomController reads `getIntValue()` straight into `gridModel`) |
| `grid` | string (base64 ByteArray) | walkability bytes parsed by `GridModel.load` |
| `doors` | JSON string | door/passage list (see [04-rooms-and-walking.md §4.5](04-rooms-and-walking.md#45-door--portal-system)) |
| `bots` | JSON string | NPC spawn list |
| `extensions` | JSON string | per-room extension scripts list |
| `ownerID`, `ownerName` | string | user-owned flat owner (cleared if `isInteractiveRoom`) |
| `flatID` | string | flat unique ID |
| `roomID` | int | numeric ID (Discord rich-presence, analytics) |
| `isInteractiveRoom` | bool | marks the avatar-editor staging room (`RoomController.onJoinRoom` early-returns when `false` for this var) |
| `source` | string | extra source data (used by `RoomModel.source`) |
| `scene` | string | scene class name (used by IsoEngine — optional) |
| `drop` | SFSArray | currently-dropped items |
| `roomVideoData` | object | YouTube/player overlay |
| `poolVars` | string (JSON) | game-pool scratch |
| `startPoint`, `finishPoint`, `isGameStarted`, `isGameEnded` | game-mode vars | Party Island |

## 3.4 UserVariables (CharacterVariable enum)

[CharacterVariable.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/enums/CharacterVariable.as).

| Var | Type | Purpose |
|---|---|---|
| `position` | string `"x,y"` | grid coord (updated on `walkfinal`) |
| `direction` | int 1–8 | facing (Direction enum) |
| `target` | string `"x,y"` | client-pathfinding goal |
| `speed` | double | walk speed multiplier |
| `status` | string | `i`/`w`/`s`/`d`/`a1`/`gm`/`gi`/`ga`/`ac` (CharacterState) |
| `clothes` | JSON | equipped items |
| `gender` | "m"/"f" | |
| `avatarName` | string | display name |
| `avatarSize` | double | VIP scale |
| `nameColor` | int | admin override |
| `chatBalloon` | int | bubble color |
| `smiley` | string | active emote |
| `hand` | string | hand item id |
| `mood`, `statusMessage` | string | profile state |
| `roles` | string (csv) | RBAC |
| `vip`, `npc`, `tp` (typing), `fbPermissions` | flags | |
| `platform` | string | client kind |
| `universeKey`, `roomGroup`, `playerID`, `gameZoneID`, `poolVars` | | session data |

## 3.5 Coverage gaps

Items observed but incompletely traced — see
[10-gaps-and-blockers.md](10-gaps-and-blockers.md).

- Music subsystem (`musicList`, `skipMusic`, `addMusic`, `CAFEADSMARHAB`)
- `partyIsland.*` complex nested payloads (`turnData`, `propertyData`)
- Marketplace/order response shapes for café orders
- `cmd2user` / `cmd2All` generic bus (used by room extensions)

---

[← Bootstrap](02-bootstrap.md)  ·  [Index](README.md)  ·  [Next: Rooms & walking →](04-rooms-and-walking.md)
