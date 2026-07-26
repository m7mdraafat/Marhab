# Street1 Interaction Capture Analysis - 2026-05-31

Source: `C:\Users\t-malgharib\OneDrive - Microsoft\Desktop\MyGame\mygame-clean\server\logs\original-proxy\original-proxy-2026-05-31T13-00-25-656Z.jsonl`

## Capture Health

| metric | value |
| --- | --- |
| events | 2095 |
| frames | 2088 |
| decoded frames | 2018 |
| undecoded encrypted/compressed frames | 70 |
| client -> server frames | 177 |
| server -> client frames | 1911 |
| login-zone rewrites | 2 |

Notes:
- The proxy is self-contained and does not import `server/probe`.
- `serverName=local` is used only to route the original client to `127.0.0.1:8080`; the proxy rewrites login zone `local` to `marhab` before forwarding.
- Undecoded frames are not fake-decoded. They are marked encrypted/compressed and must be captured later from an in-client decrypted hook if we need full room payloads.

## Top Extension Commands

| command | count |
| --- | --- |
| fishing.leftGame | 470 |
| fishing.update | 283 |
| walkrequest | 59 |
| whispernotify | 59 |
| walkfinalrequest | 46 |
| roomjoincomplete | 42 |
| ping | 30 |
| roles | 21 |
| fishing.list | 18 |
| orderlist | 16 |
| mediaevent | 10 |
| flatlist | 8 |
| displayAd | 7 |
| usehousedoor | 7 |
| cardlist | 6 |
| buddyOnlineStatus | 5 |
| handitemlist | 5 |
| musicList | 4 |
| usehanditem | 4 |
| loadroomdesign | 3 |
| questlistroom | 3 |
| avatarlist | 2 |
| fishing.joinGame | 2 |
| fishing.start | 2 |
| globalchat.leave | 2 |
| questaccept | 2 |
| removeavatarrestriction | 2 |
| roommessage | 2 |
| universelist | 2 |
| usechatballoon | 2 |
| achievementlist | 1 |
| buddylist | 1 |
| clothlist | 1 |
| config | 1 |
| ditchguestpanel | 1 |

## Direction Split

Client -> server:

| command | count |
| --- | --- |
| walkrequest | 31 |
| walkfinalrequest | 23 |
| roomjoincomplete | 21 |
| ping | 15 |
| orderlist | 8 |
| flatlist | 7 |
| handitemlist | 5 |
| usehousedoor | 4 |
| cardlist | 3 |
| loadroomdesign | 3 |
| fishing.start | 2 |
| musicList | 2 |
| usehanditem | 2 |
| achievementlist | 1 |
| avatarlist | 1 |
| buddylist | 1 |
| clothlist | 1 |
| config | 1 |
| ditchguestpanel | 1 |
| globalchat.leave | 1 |
| init | 1 |
| profile | 1 |
| questaccept | 1 |
| questlist | 1 |
| removeavatarrestriction | 1 |
| roommessage | 1 |
| saveroomdesign | 1 |
| smileylist | 1 |
| universelist | 1 |
| usechatballoon | 1 |

Server -> client:

| command | count |
| --- | --- |
| fishing.leftGame | 470 |
| fishing.update | 283 |
| whispernotify | 59 |
| walkrequest | 28 |
| walkfinalrequest | 23 |
| roles | 21 |
| roomjoincomplete | 21 |
| fishing.list | 18 |
| ping | 15 |
| mediaevent | 10 |
| orderlist | 8 |
| displayAd | 7 |
| buddyOnlineStatus | 5 |
| cardlist | 3 |
| questlistroom | 3 |
| usehousedoor | 3 |
| fishing.joinGame | 2 |
| musicList | 2 |
| usehanditem | 2 |
| avatarlist | 1 |
| externalTokenComplete | 1 |
| flatlist | 1 |
| globalchat.leave | 1 |
| initQueue | 1 |
| questaccept | 1 |
| queststepcomplete | 1 |
| removeavatarrestriction | 1 |
| restartServer | 1 |
| roommessage | 1 |
| stickerShow | 1 |
| universelist | 1 |
| updateInventory | 1 |
| usechatballoon | 1 |

## System Actions

| action | count |
| --- | --- |
| c=1 a=13 | 1140 |
| c=0 a=12 | 487 |
| c=0 a=1001 | 275 |
| c=0 a=1004 | 53 |
| c=0 a=1000 | 38 |
| c=0 a=7 | 9 |
| c=0 a=6 | 7 |
| c=0 a=1002 | 3 |
| c=0 a=0 | 2 |
| c=0 a=1 | 2 |
| c=0 a=2 | 2 |

## Feature Interpretation

| area | commands | meaning |
| --- | --- | --- |
| Bootstrap/auth | config, ditchguestpanel, externalTokenComplete, init, initQueue, roles | Client performs launcher config, guest panel dismissal/auth, then init queue. Login zone is rewritten local -> marhab by proxy. |
| Movement/doors | walkrequest, walkfinalrequest, roomjoincomplete | Door walks carry x/y plus door=true; server returns delay and door coords. Client then sends walkfinalrequest and roomjoincomplete. Some room payloads are encrypted frames. |
| Public room/building lists | flatlist, usehousedoor, orderlist, loadroomdesign | Building panel requests flatlist(buildingID). Entering public/private interior uses usehousedoor with flatID/avatarID/password redacted and returns room map/name/type/key/buildingID when unencrypted. |
| Missions/quests | questlist, questlistroom, questaccept, queststepcomplete, updateInventory | Room-specific quest lists arrived for street05, street03, pier. Accepted quest id 7305940 (dondurma). Server immediately sent queststepcomplete then questaccept progress curVal=reqVal=1. |
| Inventory/cards/items | cardlist, handitemlist, usehanditem, clothlist | Panels request paged handitemlist and cardlist. usehanditem id=4055317 equips, id=0 removes; server returns success messages. |
| Shop/panels | displayAd, musicList, avatarlist, removeavatarrestriction, smileylist, achievementlist | Display ads are server pushed by room. Music/avatar/restriction/smiley/achievement panels use their own extension commands. Shop product list was not present in this finalized capture file. |
| Chat/social | roommessage, usechatballoon, buddylist, buddyOnlineStatus, whispernotify, profile | Room message payload contains text; usechatballoon sets id; buddy status and whispers are pushed. Profile request uses avatarID. |
| Ambient/live room | fishing.update, fishing.leftGame, user variables, user enter/exit/count | Large amount of live room noise. These are background server events to model, but not necessarily user-triggered actions. |

## Important Samples

| sample | payload |
| --- | --- |
| questlistroom | {"p":{"quests":[{"currentStep":1,"isInCurrentRoom":true,"totalStep":6,"metaKey":"flower","step":{"curVal":0,"botKey":"florist01","cn":"BotQuestProperty","items":[{"quantity":-1,"countDownType":"NOW","lifeTime":-1,"clip":"0"}],"reqVal":1},"id":6247908,"roomKey":"street05","rewardMultiplier":1,"rewards":[{"data":{"amount":250},"type":"SANIL"}],"status":"NEW"},{"currentStep":1,"isInCurrentRoom":true,"totalStep":3,"metaKey":"recycle","step":{"curVal":0,"botKey":"eylul","cn":"BotQuestProperty","reqVal":1},"id":5825611,"roomKey":"street05","rewardMul... |
| questaccept request | {"r":-1,"p":{"data":{"id":"7305940"},"sn":"questaccept","ts":1780232621,"rid":60},"c":"questaccept"} |
| questaccept response | {"p":{"curVal":1,"id":7305940,"rid":60,"nextRequest":1000,"reqVal":1,"ts":1780232621},"c":"questaccept"} |
| walkrequest door | {"r":-1,"p":{"data":{"y":0,"door":true,"x":4},"sn":"walkrequest","ts":1780232507,"rid":6},"c":"walkrequest"} |
| walkrequest blocked | {"p":{"message":"The target position is not walkable.","status":"error"},"c":"walkrequest"} |
| usehousedoor request | {"r":-1,"p":{"data":{"avatarID":"101002081","flatID":"1000824","password":"[REDACTED]"},"sn":"usehousedoor","ts":1780232740,"rid":91},"c":"usehousedoor"} |
| usehousedoor response | {"p":{"rid":91,"nextRequest":1000,"room":{"dv":0,"pv":0,"doorKey":"d1","map":"PG1hcCB4T3JpZ2luPSc0MjYnIHlPcmlnaW49JzU2Myc+PGNoYWlyIGludGVyYWN0aXZlPSdmYWxzZScgZGVmPSdkNnU5aVhXS181JyBleHQ9JzEnIHY9JzAnIGlkPScyNjgxOTM3MicgZGlyPSc1JyB4PScxNicgeT0nMCcgej0nMjQnIHc9JzEnIGg9JzAuNScgZD0nMScgc3R1ZmZUeXBlPScxJyBzPScwJyBmPScwJyBmeD0nMCcgbGM9JzAnIHN0PScwJyBzdj0nMCc+PC9jaGFpcj4gPC9tYXA+","roomName":"Cafe of M7MED","roomType":"cafe01","key":"cafe01","buildingID":3},"ts":1780232740},"c":"usehousedoor"} |
| usehanditem equip | {"r":-1,"p":{"data":{"id":4055317},"sn":"usehanditem","ts":1780232648,"rid":78},"c":"usehanditem"} |
| roommessage | {"r":-1,"p":{"data":{"message":"test\n"},"sn":"roommessage","ts":1780232769,"rid":99},"c":"roommessage"} |

## Public Room / Street Movement Observations

- Door/path clicks are first `walkrequest` with `data: { x, y, door }`.
- Server returns `walkrequest` with `delay`; for doors it includes `isDoor: true, doorX, doorY`.
- Client follows with `walkfinalrequest` and then `roomjoincomplete`.
- Building/public-room panels use `flatlist` with `buildingID`.
- Entering rooms uses `usehousedoor` with `avatarID`, `flatID`, and optional `password`; response includes `room.map`, `roomName`, `roomType`, `key`, and `buildingID` when not encrypted.

## Mission Observations

- Initial quest list request: `questlist` with `showDetail:false`.
- Room-specific quest pushes: `questlistroom`.
- Captured room quest sets:
  - `street05`: `flower`, `recycle`.
  - `street03`: `sapling_task`.
  - `pier`: `batteryGathering`, `dondurma`.
- Accepted mission: `questaccept` with id `7305940` (`dondurma`). Server sent `queststepcomplete` and then `questaccept` with `curVal:1`, `reqVal:1`, `nextRequest:1000`.
- `updateInventory` was pushed after the quest interaction, likely reward/item state refresh.

## Panel Observations

- Bottom/inventory-like panels call `cardlist`, `handitemlist`, `clothlist`, `smileylist`, `achievementlist`.
- `handitemlist` is paged: `{ sort:'created_desc', search:'', page:n }`.
- `usehanditem` supports equip by item id and removal with id `0`.
- This finalized capture file did not include a decoded `shopproductlist` exchange; capture shop again with an explicit marker/action pass.
- Music panel calls `musicList` and currently returned empty `songs:[]`.
- Orders panel calls `orderlist` and returned empty `orders:[]`.
- Chat balloon selection calls `usechatballoon` with an item id.

## Known Gaps

- 70 encrypted/compressed frames were seen. Several large room/shop payloads are in this class. The proxy records size/flags/hex but cannot decode them at WebSocket level.
- To fully reconstruct room maps/user lists for encrypted frames, the next hook must be inside the original client after SmartFox decrypt/decompress, or we must reproduce SmartFox encryption/decompression.
- Live background traffic is noisy: `fishing.leftGame`, `fishing.update`, `whispernotify`, user-variable updates, user enter/exit/count. Treat these separately from deliberate user actions.

## Next Analysis Step

Build a small report generator that groups frames into workflows by request id and time windows, then label each action you perform in the client with a manual marker event. That will make future captures easier to map to UI actions.
