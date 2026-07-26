# 5. Enums, types, value objects

[← Rooms & walking](04-rooms-and-walking.md)  ·  [Index](README.md)  ·  [Next: Subsystems →](06-subsystems.md)

This is the source-of-truth section. Anything below is a verbatim contract —
**the server must use these exact strings/ints**.

## 5.1 Identity & gameplay enums

### AvatarPermission ([enums/AvatarPermission.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/enums/AvatarPermission.as))

Privilege bitset slots:

| Constant | Value | Constant | Value | Constant | Value |
|---|---|---|---|---|---|
| `TRANSFER` | 2 | `BARTER` | 3 | `VIP` | 4 |
| `VIP_GOLD` | 5 | `WHISPER` | 6 | `VIP_DIAMOND` | 7 |
| `VIP_SILVER` | 8 | `AGE18` | 9 | `AGE13` | 10 |
| `VERIFIED_EMAIL` | 11 | `VERIFIED_PHONE` | 12 | `HOLIDAY_VISA_TURKEY` | 13 |
| `DIAMOND_CLUB` | 14 | `HOLIDAY_VISA_ABUDABI` | 15 | `CARD_SECURITY` | 16 |
| `HOLIDAY_VISA_SPAIN` | 17 | `CARD_JOURNALIST` | 18 | `CARD_DIRECTOR` | 19 |
| `MODERATOR` | 20 | `CARD_PHOTOGRAPHER` | 21 | `EDITOR_SECURITY` | 22 |
| `CARD_PAINTER` | 23 | `PARTY` | 24 | `SPACE_COSTUME` | 25 |
| `KEY` | 26 | `CARD_ACTOR` | 27 | `CARD_GUIDE` | 29 |
| `PLATO` | 30 | `FORUM` | 31 | `CARD_SANALIKAX` | 32 |
| `SECURITY` | 40 | `SWIM` | 41 | `SKATE` | 42 |
| `CARD_MUSIC` | 43 | `GAME_SHORTCUT` | 45 | `SHIP_LICENSE` | 46 |
| `CARD_CAPITAN` | 47 | `EVENT` | 48 | `NPC` | 49 |
| `STAGE` | 50 | | | | |

### BalanceType ([enums/BalanceType.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/enums/BalanceType.as))

`SANIL` (soft), `DIAMOND` (hard), `PEPSICOIN` (sponsor).

### BanType ([enums/BanType.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/enums/BanType.as))

`CHAT_BANNED="CHAT"`, `LOGIN_BANNED="LOGIN"`.

### CharacterState ([enums/CharacterState.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/enums/CharacterState.as))

| Constant | Value |
|---|---|
| `IDLE` | `"i"` |
| `WALK` | `"w"` |
| `SITTING` | `"s"` |
| `DANCE` | `"d"` |
| `ACTION` | `"a1"` |
| `GAME_MOVE` | `"gm"` |
| `GAME_IDLE` | `"gi"` |
| `GAME_ACTION` | `"ga"` |
| `SNOWBALL_ACTION` | `"ac"` |
| `FITNESS` | `["ac1","ac2"]` |

### CharacterType ([enums/CharacterType.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/enums/CharacterType.as))

`NORMAL=0`, `BOT=1`, `ADBOT=2`, `CUSTOMBOT=3`.

### ConnectionStatus ([enums/ConnectionStatus.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/enums/ConnectionStatus.as))

`DISCONNECTED=0`, `CONNECTED=1`, `LOGINED=2`, `JOINED=3`.

### Direction ([enums/Direction.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/enums/Direction.as))

See [04-rooms-and-walking.md §4.3](04-rooms-and-walking.md#direction-enum).

### GenderType ([enums/GenderType.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/enums/GenderType.as))

`MALE="m"`, `FEMALE="f"`.

### FramePrefix ([enums/FramePrefix.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/enums/FramePrefix.as))

Sprite-frame prefixes: `IDLE="i"`, `WALK="w"`, `SIT="s"`, `DANCE="d"`,
`HAND_ITEM="k"`.

### CharacterVariable ([enums/CharacterVariable.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/enums/CharacterVariable.as))

User-variable key names. See [03 §3.4](03-protocol-catalog.md#34-uservariables-charactervariable-enum).

### RoomVariable ([enums/RoomVariable.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/enums/RoomVariable.as))

The enum is intentionally tiny: only the value-domain constants live here.

| Constant | Value |
|---|---|
| `TYPE` | `"type"` |
| `KEY` | `"roomKey"` |
| `TITLE` | `"title"` |
| `WIDTH` | `"width"` |
| `HEIGHT` | `"height"` |
| `OUTDOOR` / `INDOOR` / `BUSINESS` | string values for `TYPE` |

> The other RoomVariable names the server must speak (`grid`, `doors`,
> `bots`, `source`, `ownerID`, `ownerName`, `roomTitle`, `flatID`,
> `roomID`, `isInteractiveRoom`, `extensions`, `scene`, `drop`,
> `roomVideoData`, `poolVars`, `startPoint`, `finishPoint`,
> `isGameStarted`, `isGameEnded`) are referenced as raw string literals by
> [RoomController.startload](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/room/RoomController.as)
> — see [03 §3.3](03-protocol-catalog.md#33-roomvariables-server-set-client-read-only)
> for the full table.

### MapEntryType ([engine/core/MapEntryType.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/engine/core/MapEntryType.as))

Drives which XML tag the room map carries for each entry (see
[04 §4.3](04-rooms-and-walking.md#entry-elements-full-type-table) for the
tag mapping).

| Value | Constant |
|---|---|
| 0 | `NORMAL` |
| 1 | `CHAIR` |
| 2 | `ATARI` |
| 3 | `USABLE` |
| 4 | `POOL` |
| 5 | `POOL_ENTRY` |
| 6 | `FARM` |
| 7 | `CENCORED_OBJECT` |
| 8 | `FLOOR_OBJECT` |
| 9 | `CINEMA_DOOR` |
| 10 | `CINEMA_SCREEN` |
| 11 | `EXHIBITION` |
| 12 | `METRO` |
| 13 | `SERVER_TIMER` |
| 14 | `AIRPLANE` |
| 15 | `MONITTE_GROUND` |
| 16 | `BILLBOARD` |
| 17 | `YOUTUBE_SCREEN` |
| 18 | `VIDEO_SCREEN` |
| 21 | `SOUND` |

Values 19–20 are intentionally absent from the enum.

### CellType ([engine/core/CellType.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/engine/core/CellType.as))

Single-byte values stored in the `grid` RoomVariable payload (see
[04 §4.4](04-rooms-and-walking.md#44-the-walkability-grid-grid-roomvariable)).

| Value | Constant |
|---|---|
| 0 | `TYPE_EMPTY` |
| -1 | `TYPE_WALK_ONLY` |
| 3 | `TYPE_DISABLED` |
| 4 | `TYPE_DIAMOND` |
| 5 | `TYPE_ADMIN` |
| 6 | `TYPE_TARGET` |
| 7 | `TYPE_FISH` |
| 8 | `TYPE_SANALIKAX` |
| 10 | `TYPE_SHORTCUT` |
| 11 | `TYPE_NPC` |
| 12 | `TYPE_STAGE` |
| 13 | `TYPE_FURNITURE_ONLY` |

## 5.2 Item, cloth, shop

### ItemType ([enums/ItemType.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/enums/ItemType.as))

Power-of-two bitmask:

| Constant | Value | Constant | Value |
|---|---|---|---|
| `TYPE_VIEWABLE` | 1 | `TYPE_QUESTITEM` | 4 |
| `TYPE_FOOD` | 8 | `TYPE_ITEMVISIBLEIDLE` | 16 |
| `TYPE_ITEMVISIBLEWALKING` | 32 | `TYPE_ITEMVISIBLESITTING` | 64 |
| `TYPE_ITEMVISIBLEDANCE` | 128 | `TYPE_HANDVISIBLEIDLE` | 256 |
| `TYPE_HANDVISIBLEWALKING` | 512 | `TYPE_HANDVISIBLESITTING` | 1024 |
| `TYPE_MAKEITEM` | 2048 | `TYPE_SWFLOADER` | 4096 |
| `TYPE_VIP` | 8192 | `TYPE_USEABLE` | 16384 |
| `TYPE_PLANT` | 32768 | `TYPE_APPLICATION` | 65536 |
| `TYPE_GROUND_OBJECT` | 131072 | `TYPE_PACKAGE` | 262144 |

Helpers: `isHandItem()`, `isWearableItem()`, `isViewable()`, `isQuestItem()`,
`isFood()`, `isItemVisibleIdle/Walking/Sitting/Dance()`,
`isHandVisibleIdle/Walking/Sitting()`, etc.

### ProductType ([enums/ProductType.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/enums/ProductType.as))

`OBJECT` (furniture), `CLOTH`, `HAND`, `FLAT`, `CARD`, `FARMING`,
`PROFILE_SKIN`.

### ProductSubType ([enums/ProductSubType.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/enums/ProductSubType.as))

`FOOD`, `TOY`, `CHECK`, `DRINK`, `PACKAGE`, `MEAT`, `TOOL`, `ROCK`, `WOOD`.

### ModuleType ([enums/ModuleType.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/enums/ModuleType.as))

Strings prefixed `ModuleType.`: `ROOM`, `EXTENSION`, `PANEL`, `CLOTH`,
`CLOTH_PNG`, `AD_AIRSHIP`, `AD_BILLBOARD`, `AD_BOT`, `AD_SKIN`, `BOT`,
`QUEST`, `INVENTORY`, `FURNITURE_EDITOR`, `FURNITURE`, `SMILEY`,
`CONCERT_SOUND`, `CONCERT_SWF`, `PNG`, `PROFILE_SKIN`.

## 5.3 Cloth layer slots (critical for outfit conflict checks)

[cloth/ClothType.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/cloth/ClothType.as) —
bitfields per slot.

| Layer | Bit | Slot | Conflicts |
|---|---|---|---|
| 0 | BIT00 | BODY_BOTTOM (pants segment) | BIT01, BIT02 |
| 1 | BIT01 | BODY_MIDDLE (torso) | BIT00, BIT02 |
| 2 | BIT02 | BODY_TOP (chest) | BIT00, BIT01 |
| 3 | BIT03 | **UNASSIGNED** | — |
| 4 | BIT04 | FOOT (shoes) | — |
| 5 | BIT05 | LEG_BOTTOM | — |
| 6 | BIT06 | LEG_TOP | BIT08 (LEG_ALL) |
| 7 | BIT07 | BOT (bottom-wear overlay) | — |
| 8 | BIT08 | LEG_ALL (full body) | BIT06 |
| 9 | BIT09 | SHIRT | — |
| 10 | BIT10 | BELT | — |
| 11 | BIT11 | TIE | — |
| 12 | BIT12 | WRISTBAND | — |
| 13 | BIT13 | JACKET | — |
| 14 | BIT14 | BACKPACK | — |
| 15 | BIT15 | NECK | — |
| 16 | BIT16 | FACIAL_HAIR | — |
| 17 | BIT17 | HAIR | BIT20 (HAT) |
| 18 | BIT18 | GLASS | — |
| 19 | BIT19 | PIPE | — |
| 20 | BIT20 | HAT | BIT17 (HAIR) |
| 21 | BIT21 | EMOTICON | — |
| 22 | BIT22 | HANDITEM | — |
| 23 | BIT23 | EFFECT_BOTTOM | — |
| 24 | BIT24 | EFFECT_MIDDLE | — |
| 25 | BIT25 | EFFECT_TOP | — |
| 26 | BIT26 | EFFECT_ALL | combine BIT23–25 |

Composite shortcut: `BIT012_BODY_FULL = BIT00 | BIT01 | BIT02`.

Mutual-exclusion category predicates in `ClothModel`:
`isMemberOfShirtCategory`, `isMemberOfFullBody`, `isMemberOfPantsCategory`,
`isMemberOfShoesCategory`, `isMemberOfHeadCategory`,
`isMemberOfAccessoryCategory`, `isMemberOfEffectCategory`,
`isMemberOfCostumeCategory`.

Per `isMemberOfFullBody`, a cloth item that occupies a body slot must
have a `placeBit` of **exactly** `BIT00`, `BIT01`, or `BIT02` — composite
masks fall out of the body category and are treated as costumes.

## 5.4 Protocol enums

### RequestDataKey ([enums/RequestDataKey.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/enums/RequestDataKey.as))

Every named extension request as a constant. See
[03 §3.1](03-protocol-catalog.md#31-client--server-extension-requests-70-commands)
for the full table.

### GameRequest ([enums/GameRequest.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/enums/GameRequest.as))

Sub-namespaced events forwarded through `cmd2user` and game systems:
`tombala.*` (lottery), `game.pirate*`, `change.cloth/vip/diamondclub/smiley/handitem`,
`buddyVar`, `prereport`, `plantingStart`, etc.

### GameResponse ([enums/GameResponse.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/enums/GameResponse.as))

Companion responses to `GameRequest` (`cmd2user`, `cmd2All`, all `tombala.*`,
all `game.pirate*`, `change.*`).

### ServiceType ([enums/ServiceType.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/enums/ServiceType.as))

`rope`, `user`, `room`, `command`.

### ExtensionType ([enums/ExtensionType.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/enums/ExtensionType.as))

`MAIN=0`, `ROOM=1`.

### UpdateGroups ([enums/UpdateGroups.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/enums/UpdateGroups.as))

Client tick groups: 60/30/10/5/2/1s, 500/200/100 ms, `ENTER_FRAME=-1`.
Server doesn't care about these.

### QuantityResponse ([enums/QuantityResponse.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/enums/QuantityResponse.as))

`CANCEL=0`, `OK=1`.

### BotSpeechTypes ([enums/BotSpeechTypes.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/enums/BotSpeechTypes.as))

`welcome`, `goodbye`, `casual`, `shop-purchase`, `shop-cancel`.

### LocalConnectionTypes ([enums/LocalConnectionTypes.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/enums/LocalConnectionTypes.as))

`grid`, `door`, `bot`, `avatar`, `cloth`.

### UserRoomTypes ([enums/UserRoomTypes.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/enums/UserRoomTypes.as))

`HOUSE`, `CAFE`, `GARAGE`, `HOSPITAL`, `LAND`, `OFFICE`.

### BuddyMoods ([enums/buddy/BuddyMoods.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/enums/buddy/BuddyMoods.as))

31 mood entries indexed 0–30 (Cheerful, Peaceful, Crazy, Run Down, Unhappy,
Nervous, Broken Heart, Pessimistic, Pensive, Energetic, Romantical,
Sensitive, Excited, Curious, Depressed, Unstable, Worried, Thoughtful,
Mysterious, Mixed, Optimistic, Confused, Sucks, Resents, Desperate, Regret,
Alone, Questionable, Lethargic, Approachable, Stressful). All labels wrapped
in `$()` for localization.

### BuddyPages ([enums/buddy/BuddyPages.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/enums/buddy/BuddyPages.as))

`BUDDY_LIST="buddy"`, `ONLINE_LIST="online"`, `REQUEST_LIST="request"`.

## 5.5 ServiceErrorCode (must match exactly)

[service/ServiceErrorCode.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/service/ServiceErrorCode.as).

### Numeric codes

| Code | Message |
|---|---|
| 0 | Service error |
| 1 | Service method does not match |
| 2 | Expire OAuth access token |
| 3 | Cannot get parameter value |
| 4 | User access token is required for this service |
| 5 | Invalid OAuth access token |
| 6 | Invalid email address |
| 7 | Emails do not match |
| 8 | This email is already registered |
| 9 | Avatar not found |
| 10 | Unauthorized person for operation |
| 11 | Wrong parameter |
| 12 | Missing parameter |
| 13 | Unauthorized client |
| 14 | Authorized client is not active |
| 16 | Person not found |
| 17 | Script error |
| 18 | Invalid item ID |
| 19 | Messaging exception |
| 20 | Json exception |
| 21 | Invalid rope request |
| 22 | Service not found |
| 2002 | Not enough diamond credits |
| 2003 | Not enough sanil credits |
| 2008 | You don't have valid item for this operation |
| 2009 | You are not in proper position |
| 2010 | You already have this item |
| 5000 | Your credits not enough |
| 5001 | Insufficient quantity |
| 5002 | Wrong item type |
| 5003 | Invalid request |
| 5004 | Already has card |
| 5005 | Clothes |

### String codes

| Code | Localized key |
|---|---|
| `USER_HAS_ITEM` | "You already have maximum count of this item" |
| `EXTENSION_IDLE` | "Please try again in a few seconds." |
| `FLOOD` | "You're doing a lot of requests, please calm down" |
| `NO_TRANSFERRABLE_ITEMS` | "Not available status for trading" |
| `NO_SELLABLE_ITEMS` | "Not available status for selling" |
| `HAS_BARTER` | "User is busy with another trade session" |
| `NOT_VIP` | "You must be VIP user for this operation" |
| `ALRADY_HAS_FLAT` *(sic)* | "You already have this place." |
| `SYSTEM_ERROR` | "You got a simple problem... report to moderators" |
| `INSUFFICIENT_ROLE` | "You don't have role for this operation." |
| `BUDDY_IS_NOT_ONLINE` | "Buddy is not online for responding." |
| `INVALID_SECURITYKEY` | "Invalid Security Key." |
| `BANNED_FROM_ROOM` | "You are banned room by owner." |
| `NOT_PACKAGE` | "Wrong item to open as package." |
| `BUDDY_REQUEST_FULL_REQUESTER` | "The avatar has a full friend request list." |
| `ROOM_PASSWORD_WRONG` | "Your password is wrong to join room." |
| `ROOM_IS_FULL` | "Room is full." |
| `FORTUNE_INSUFFICIENT_BALANCE` | "Insufficient balance." |
| `PUBLIC_MESSAGE_NOT_ALLOWED` | "Public messages disabled temporarily" |
| `VISITOR_PUBLIC_MESSAGE_NOT_ALLOWED` | "Public messages from visitors temporarily disabled" |
| `WRONG_POSITION` | "Wrong position to catch fish." |
| `WRONG_ITEM` | "Wrong hand item to catch fish." |
| `EMAIL_NOTACTIVATED` | "Activate your email first" |
| `PHONE_NOTACTIVATED` | "Activate your phone number first" |
| `ALREADY_HAS_ITEM` | "You already have this item" |
| `GUEST_NOT_ALLOWED` | → opens GuestPanel |
| `MISSING_ITEM` | "Missing item: {name}" |

**Role-based errors** are populated at runtime from `_masterRoles` (from
`config.masterRoles`). Lookup via `getRoleErrors(roleIndices:Array)`.

## 5.6 Critical Value Objects

| VO | Key fields | File |
|---|---|---|
| `AlertVo` | `alertType`, `title`, `description`, `callBack`, `data`, `minQuantity`, `maxQuantity`, `stepSize`, `panelType`, `secretSession`, `isTransfer`, `defaultInputMessage`, `sound` | [alert/AlertVo.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/alert/AlertVo.as) |
| `PanelVO` | `name`, `type`, `params`, `isPermanent` | [panel/PanelVO.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/panel/PanelVO.as) |
| `EntryVo` | `id`, `definition`, `x/y/z`, `width/height/depth`, `f` (frame), `s` (state), `fx`, `lc`, `st`, `sv`, `isBusy`, `property: IProperty` | [interactive/EntryVo.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/interactive/EntryVo.as) |
| `ProgressVo` | `percent`, `description`, `args[]` (named constants for each init step) | [progress/ProgressVo.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/progress/ProgressVo.as) |
| `Item` (inventory) | `productID`, `clip`, `quantity`, `id`, `subType`, `isTransferable`, `lifeTime`, `timeLeft`, `createdAt`, `roles[]` | [inventory/Item.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/inventory/Item.as) |
| `Cloth` | `id`, `quantity`, `on`, `base`, `key`, `clothData`, `lifeTime`, `timeLeft`, `isAccessory` | [cloth/Cloth.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/cloth/Cloth.as) |
| `BuddyVo` | `avatarID`, `avatarName`, `nick`, `imgPath`, `gender`, `isOnline`, `mood`, `status`, `myMood`, `buddyMood` | [buddy/BuddyVo.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/buddy/BuddyVo.as) |
| `PurchaseVo` | `pid`, `quantity`, `color` | [purchase/PurchaseVo.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/purchase/PurchaseVo.as) |
| `PrivateChatGroup` | `groupID`, `groupName`, `avatarID`, `messages[]`, `lastMessage`, `unreadMessageCount`, `detailsActivated` | [privatechat/PrivateChatGroup.as](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/privatechat/PrivateChatGroup.as) |

### ProgressVo init phases

| Constant | Percent | Description |
|---|---|---|
| `CONNECTING` | 0 | initial |
| `LANG_FILE_READY` | 10 | language loaded |
| `CONNECTED` | 20 | socket connected |
| `LOGINED` | 30 | authenticated |
| `CONFIG_READY` | 40 | config downloaded |
| `INFO_FILE_READY` | 50 | item list ready |
| `GAME_EXTENSIONS_LOADED` | 60 | plugins loaded |
| `INIT_READY` | 70 | game initialized |
| `GAME_READY` | 80 | assets ready, playable |
| `PROGRESS_FULL` | 100 | complete |

---

[← Rooms & walking](04-rooms-and-walking.md)  ·  [Index](README.md)  ·  [Next: Subsystems →](06-subsystems.md)
