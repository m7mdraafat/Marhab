# 9. Server structure & implementation order

[← Database schema](08-database-schema.md)  ·  [Index](README.md)  ·  [Next: Gaps & blockers →](10-gaps-and-blockers.md)

This expands the high-level plan in [../PLAN.md](../PLAN.md) into a concrete
package layout and a wave-by-wave order that yields a playable milestone at
each step.

## 9.1 Package layout (cleaned, follows the existing intent in PLAN.md)

```
server/src/com/hara/
├── extension/
│   ├── HaraExtension.java                  ← addRequestHandler() registrations only
│   └── events/UserLifecycleHandler.java
├── protocol/
│   ├── framework/                          ← shared base + DTO helpers
│   │   ├── HandlerBase.java                ← error envelope + timing + logging
│   │   ├── ResponseBuilder.java            ← fluent SFSObject builder
│   │   ├── SfsObjectMapper.java            ← typed required*/optional* accessors
│   │   ├── ServiceErrorCode.java           ← mirrors client ServiceErrorCode.as exactly
│   │   └── BadRequestException.java
│   └── handlers/
│       ├── auth/      ConfigHandler, LoginEventHandler
│       ├── boot/      InitHandler, ListHandler (clothlist/baseclothlist/etc.)
│       ├── avatar/    AvatarSaveHandler, ChangeSettingsHandler, ChangeClothesHandler,
│       │              ChangeSmileyHandler, UseChatBalloonHandler, UseStickerHandler,
│       │              ChangeUniverseHandler
│       ├── room/      TeleportHandler, UseDoorHandler, UseHouseDoorHandler,
│       │              UseObjectDoorHandler, LoadRoomDesignHandler, SaveRoomDesignHandler,
│       │              ChangeObjectFrameHandler, ChangeObjectLockHandler,
│       │              RoomJoinCompleteHandler
│       ├── walk/      WalkRequestHandler, WalkFinalRequestHandler
│       ├── shop/      PurchaseHandler, FlatPurchaseHandler, FlatSponsorHandler,
│       │              AvatarSalesCollectHandler, ShopProductListHandler,
│       │              ExchangeDiamondHandler
│       ├── flat/      FlatListHandler, FlatSearchHandler, FlatInfoHandler,
│       │              FlatFavoriteHandler, ChangeFlatInfoHandler
│       ├── inventory/ ListExpirablesHandler, ExpireSweepJob, AddExpirablesPusher,
│       │              HandItemListHandler, SpecialItemListHandler, UseHandItemHandler
│       ├── social/    BuddyListHandler, AddBuddyHandler, RemoveBuddyHandler,
│       │              BuddyLocateHandler, ChangeMoodHandler, ChangeStatusMessageHandler,
│       │              DiamondTransferHandlers, ChangeBuddyRatingHandler
│       ├── chat/      WhisperHandler, GroupWhisperHandler
│       ├── pm/        PrivateChatListHandler, MessageDetailsHandler,
│       │              PrivateChatDeleteGroupHandler, PrivateMessagePusher
│       ├── transfer/  TransferRequestHandler, TransferResponseHandler,
│       │              GiftCheckExchangeHandler
│       ├── barter/    BarterRequestHandler, BarterResponseHandler, BarterCancelHandler
│       ├── quest/     QuestListHandler, QuestActionHandler, QuestListRoomPusher,
│       │              QuestProgressPusher
│       ├── achievement/ AchievementUpdatePusher
│       ├── drop/      DropHandler, DropThrowActionHandler, DropPushers
│       ├── farm/      FarmItemListHandler, FarmImplantationHandler,
│       │              FarmGatherHandler, FarmCleanHandler
│       ├── gathering/ GatherItemSearchHandler, GatherItemCollectHandler
│       ├── order/     OrderListHandler, OrderDetailHandler, OrderCancelHandler,
│       │              OrderPrepareHandler, OrderRequestHandler
│       ├── profile/   ProfileHandler, ProfileLikeHandler, ProfileImproperHandler
│       ├── report/    PreReportHandler, ReportHandler
│       └── debug/     DebugCommandHandler, PingHandler
├── service/                                ← domain services (the “use case” layer)
│   ├── auth/         AccountService, TokenService
│   ├── avatar/       AvatarService, BalanceService, BanService, SettingsService
│   ├── inventory/    InventoryService, ClothService, ExpirableService
│   ├── room/         RoomService, FlatService, RoomDesignService, RoomVarPublisher
│   ├── walk/         WalkSessionRegistry, WalkValidator (server-side grid check)
│   ├── shop/         PurchaseService, PricingService
│   ├── social/       BuddyService, ChatService, PrivateChatService
│   ├── economy/      TransferService, BarterService, DiamondQuotaService
│   ├── progress/     QuestService, AchievementService, MissionService
│   ├── world/        SceneObjectService, FarmService, GatheringService, CafeOrderService
│   ├── moderation/   ReportService, RoleService, AuditLog
│   └── catalog/      CatalogService, MoodCatalog, BalloonCatalog
├── domain/                                  ← entities, VOs, enums (mirror client)
│   ├── identity, avatar, room, item, cloth, social, quest, …
├── persistence/
│   ├── dao/         <one DAO per aggregate>
│   ├── schema/      schema.sql + migrations
│   └── DataSourceConfig.java               ← HikariCP
├── infra/
│   ├── config/      HaraConfig (record), ConfigLoader
│   ├── ratelimit/   PerServiceRateLimiter   ← mirrors ServiceRequestRate.check()
│   ├── metrics/     Micrometer + JMX
│   └── audit/       AuditAppender
└── catalog/                                  ← static catalog seeders (ifile/vf builders)
```

One handler = one named request. No mega-routers (matches rule #3 in
[../AGENT_GUIDE.md](../AGENT_GUIDE.md)).

## 9.2 The exact order to implement handlers (and why)

Implement in waves. Each wave is a working playable milestone.

### Wave 0 — Cleanup (from PLAN.md Phase 0)

1. Delete `server/run-local.ps1` (duplicate of `restart-sfs.ps1`)
2. Fix `LoginHandler.usersFile()` to point at the right path
3. Replace `MyGameExtension` strings everywhere with `HaraExtension`

### Wave 1 — Boot the splash and clear "Connecting"

*No DB yet, properties file is fine.*

1. SFS `LoginEventHandler` — accept token from `data.token`, set `privilegeId`
2. `config` — minimal: `fileServer[]`, `itemFile`, `versionFile`, `langFile`,
   `moods`, `chatBaloons`, `masterRoles`
3. `init` — minimal: `ts`, `selectedAvatarID`, `email`, `gender`, `guest`,
   `wallet`, empty `extensionInfo`, default `settings`, `checkAvatar` based on
   whether avatar exists, `clothes.items:[]`, `roomKey:"lobby"`, `roomData`
4. `initQueue` push (single `{ts, p:100}` is fine to start)

**Why first**: nothing else can be tested until the client clears `INIT_READY`.

### Wave 2 — Avatar create / dress / lobby idle

*DB introduced: `auth.accounts`, `avatar.avatars`, `avatar.settings`,
`avatar.balances`, `inventory.product_catalog`, `inventory.user_items`.*

5. `baseclothlist` — return all `is_base=true` user_items
6. `clothlist` — return wardrobe (default outfit + owned)
7. `savebaseclothes` — atomic UPDATE
8. `changeclothes` — atomic UPDATE; enforce `ClothType` bit conflicts (see
   [05 §5.3](05-enums-and-types.md#53-cloth-layer-slots-critical-for-outfit-conflict-checks))
9. AvatarCreatePanel save flow (`avatarcreate` request — listed in PLAN.md)
10. Auto-join SFS room `lobby` after `init`; set RoomVariables
    (`width`/`height`/`grid`/`doors`) for a hand-crafted lobby room

**Why next**: the splash unlocks but the user is stuck unless they have an
avatar in a room.

### Wave 3 — Walking and chat (the moment the game feels alive)

11. SFS auto-broadcasting of UserVariables (built-in — ensure the SFS room is
    configured to allow user-var sync)
12. `walkrequest` — validate (server-side reachability against the room's
    grid), compute `delay`, reply via extension `walkrequest`, register
    `WalkSession`
13. `walkfinalrequest` — commit `position`/`direction` UserVariables;
    broadcast happens automatically
14. SFS `publicMessage` event handler — broadcast chat
15. `whisper`, `groupwhisper`
16. `usechatballoon`, `changesmiley`

**Why third**: with walking + chat working, two players can hang out in a
room. This is the smallest "playable MMO" milestone.

### Wave 4 — Doors and room transitions

17. `teleport` — public street → public street
18. `usedoor` — adjacent passage
19. `usehousedoor` — into a flat
20. `useobjectdoor` — interior of placed object
21. `roomjoincomplete` request handler (responds with push of same name so
    client unlocks UI)

### Wave 5 — Inventory + economy basics

22. `listexpirables`, `expire` sweep job, `addExpirables` push
23. `purchase`, `flatpurchase`, `shopproductlist`
24. `usehanditem`, `handitemlist`, `specialitemlist`, `handItemProperty`
25. `updateWallet` push after every balance change

### Wave 6 — Social presence

26. `buddylist`, `addbuddy`, `addbuddyresponse`, `removebuddy`
27. `buddyOnlineStatus` push on login/logout
28. `changemood`, `changestatusmessage`, `changebuddyrating`
29. `buddylocate`, `buddyinvitelocation`, `buddyrespondinvitelocation`
30. `diamondtransferrequest`/`response` + `diamondTransferDailyLimitExceeded` push
31. `privatechatlist`, `messagedetails`, `privatechatdeletegroup`,
    `privatemessagereceived` push

### Wave 7 — Flats (user-owned rooms)

32. `flatlist`, `flatsearch`, `flatinfo`, `flatfavorite`, `changeflatinfo`
33. `loadroomdesign`, `saveroomdesign`
34. `changeobjectframe`, `changeobjectlock`
35. `flatsponsor`, `avatarsalescollect`

### Wave 8 — Transfer / barter

36. `transferrequest`/`response`/`cancel` (with `respondTransferRequest`,
    `transferResult`, `transferCancelled` pushes)
37. `giftcheckexchange`
38. `barterrequest`/`response`/`cancel` (with `respondBarterRequest`,
    `barterStarted` pushes)

### Wave 9 — Quests / achievements / missions

39. `questlist`, `questaction`
40. `questlistroom` push (on room enter for active quests)
41. `queststepcomplete`, `questcomplete` pushes
42. `achievementupdate` push (server-driven detection)
43. Mission step pushers per campaign

### Wave 10 — Farm / gathering / café orders / drop

44. `farmitemlist`, `farmimplantation`, `farmgather`, `farmclean`
45. `gatheritemsearch`, `gatheritemcollect`
46. `orderlist`, `orderdetail`, `orderrequest`, `orderprepare`, `ordercancel`
47. `dropItem`/`dropRemoveItem` pushes + `drop` collect handler

### Wave 11 — Mod / reporting / admin

48. `prereport`, `report`
49. `removeavatarrestriction`, ban enforcement,
    `banned`/`unbanned`/`banExpired` pushes
50. `moderatorNotice`, `roles` pushes

### Wave 12 — Games / extras

51. `partyIsland.*`
52. `fortunewheel`, `randomwheel`
53. `matchmakingStart`/`Cancel`
54. `startextension`/`stopextension` (per-room mini-games)

## 9.3 Cross-cutting infrastructure to build alongside

| Concern | Where | Notes |
|---|---|---|
| Rate limiting | `infra/ratelimit/PerServiceRateLimiter` | Mirror client `ServiceRequestRate.check()`. Return `errorCode:"FLOOD"` + `nextRequest` |
| Error envelope | `protocol/framework/HandlerBase` | Always reply `{errorCode, message, nextRequest?}` on failure; success = arbitrary payload |
| Role gating | `service/moderation/RoleService` | Decorate handlers with `@RequireRole("MODERATOR")`. On failure return `INSUFFICIENT_ROLE` + role csv |
| Audit log | `infra/audit/AuditAppender` | One row per state-changing handler (transfers, purchases, bans, room edits) |
| Tx boundary | `persistence/UnitOfWork` | One DB transaction per handler. Idempotency keys on transfers and purchases |
| Server-time sync | `service/avatar/SyncTime` | Every response carries `ts` (epoch ms). Client uses it for `SyncTimer` |
| Variable publisher | `service/room/RoomVarPublisher` | Batches `SetRoomVariables` to avoid N×1 broadcasts |
| WalkSession registry | `service/walk/WalkSessionRegistry` | TTL map keyed by `(roomId, userId)`. Validates `walkfinalrequest` |
| Catalog seeders | `catalog/` | Build `ifile.<version>` and `vf.<version>` from DB on startup; serve over Tomcat |

## 9.4 Why this ordering matters

- **Boot before gameplay**: every later handler depends on `init` returning a coherent player state.
- **State (walk/chat) before commerce**: testing economy without two avatars in a room is impossible.
- **Doors before flats**: flats require door handlers to be entered at all.
- **Inventory before transfer/barter**: transfers move inventory items — you need an inventory model first.
- **Buddies before private chat**: private chat groups largely overlap with buddies.
- **Quests before achievements**: the achievement push depends on quest-completion hooks.
- **Mod/audit last**: you want real activity to moderate before building mod tools.

---

[← Database schema](08-database-schema.md)  ·  [Index](README.md)  ·  [Next: Gaps & blockers →](10-gaps-and-blockers.md)
