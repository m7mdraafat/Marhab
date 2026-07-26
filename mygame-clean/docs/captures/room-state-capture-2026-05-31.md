# Room State Capture Analysis - 2026-05-31

Source: `C:\Users\t-malgharib\OneDrive - Microsoft\Desktop\MyGame\mygame-clean\server\logs\original-proxy\original-proxy-2026-05-31T13-42-46-038Z.jsonl`

## Capture Health

| metric | value |
| --- | --- |
| events | 1491 |
| frames | 1483 |
| decoded | 1483 |
| undecoded | 0 |
| client -> server | 122 |
| server -> client | 1361 |

## Top Commands

| command | count |
| --- | --- |
| fishing.leftGame | 265 |
| fishing.update | 214 |
| whispernotify | 60 |
| walkrequest | 58 |
| walkfinalrequest | 42 |
| roomjoincomplete | 36 |
| fishing.list | 22 |
| roles | 18 |
| usedoor | 17 |
| ping | 10 |
| displayAd | 9 |
| flatlist | 8 |
| mediaevent | 6 |
| shopproductlist | 6 |
| usechatballoon | 6 |
| questlistroom | 3 |
| achievementlist | 2 |
| buddylist | 2 |
| cardlist | 2 |
| clothlist | 2 |
| config | 2 |
| globalchat.leave | 2 |
| handitemlist | 2 |
| init | 2 |
| loadroomdesign | 2 |
| orderlist | 2 |
| questlist | 2 |
| smileylist | 2 |
| universelist | 2 |
| usehousedoor | 2 |
| ditchguestpanel | 1 |
| externalTokenComplete | 1 |
| initQueue | 1 |
| restartServer | 1 |

## System Actions

| action | count |
| --- | --- |
| c=1 a=13 | 812 |
| c=0 a=12 | 441 |
| c=0 a=1001 | 89 |
| c=0 a=1004 | 50 |
| c=0 a=1000 | 35 |
| c=0 a=4 | 29 |
| c=0 a=7 | 15 |
| c=0 a=1 | 4 |
| c=0 a=0 | 2 |
| c=0 a=1002 | 2 |
| c=0 a=2 | 2 |
| c=0 a=6 | 2 |

## Room Ids Seen

| roomId | count |
| --- | --- |
| 51 | 190 |
| -1 | 100 |
| 0 | 48 |
| 5 | 38 |
| 4 | 36 |
| 190 | 32 |
| 50 | 27 |
| 59 | 27 |
| 67 | 25 |
| 21 | 12 |
| 30 | 11 |
| 1 | 8 |
| 29 | 5 |
| 3849 | 5 |
| 31 | 4 |
| 74 | 4 |
| 75 | 4 |
| 25 | 3 |
| 33 | 3 |
| 4106 | 3 |
| 4355 | 3 |
| 49 | 3 |
| 60 | 3 |
| 107 | 2 |
| 118 | 2 |
| 237 | 2 |
| 32 | 2 |
| 42 | 2 |
| 4807 | 2 |
| 4808 | 2 |
| 76 | 2 |
| 77 | 2 |
| 78 | 2 |
| 86 | 2 |
| 87 | 2 |
| 10 | 1 |
| 2 | 1 |
| 243 | 1 |
| 3 | 1 |
| 47 | 1 |

## Room Tuple Shape

System action `6` and some action `4` payloads carry room tuples:

`[id, name, group, passwordProtected, game, hidden, userCount, maxUsers, variables]`

Examples:

| seq | room tuple |
| --- | --- |
| 560 | {"id":4807,"name":"21#3#100998740#cafe04","group":"default","passwordProtected":false,"game":false,"hidden":false,"userCount":0,"maxUsers":150,"variables":[]} |
| 640 | {"id":4808,"name":"21#3#101003555#cafe04","group":"default","passwordProtected":false,"game":false,"hidden":false,"userCount":0,"maxUsers":150,"variables":[]} |

## Room Join / Street State

Action `4` is the large room-join state path. It can contain a room tuple plus room/user variables, depending on join type.

| seq | payload |
| --- | --- |
| 38 | {"id":0,"name":"w1#street01","group":"OUTDOOR","passwordProtected":false,"game":false,"hidden":false,"userCount":13,"maxUsers":300,"variables":[["doors",4,"[{\"key\":\"d2\",\"targetDir\":1,\"targetX\":36,\"targetY\":42,\"property\":{\"doorKey\":\"d3\",\"roles\":\"AA==\",\"roomKey\":\"nriettaLobby\",\"cn\":\"PassageProperty\"},\"primary\":false},{\"key\":\"d3\",\"targetDir\":7,\"targetX\":37,\"targetY\":23,\"property\":{\"buildingID\":\"3\",\"theme\":\"standard\",\"roomType\":\"CAFE\",\"cn\":\"RoomPanelProperty\"},\"primary\":false},{\"key\":\"d4\",\"targetDir\":7,\"targetX\":50,\"targetY\":23,\"property\":{\"doorKey\":\"d1\",\"roles\":\"\",\"roomKey\":\"realEstate\",\"cn\":\"PassageProperty\... |
| 51 | {"id":51,"name":"w1#street01#fishing","group":"street01","passwordProtected":false,"game":false,"hidden":false,"userCount":13,"maxUsers":300,"variables":[["isInteractiveRoom",1,false,false,false],["grid",4,"AAAAOgAAAC8BAQEBAQEBAQEBAQEBAQEBAQEBAQcHBwcHBwcHAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQcHBwcHBwcHBwcBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQcHBwcHBwcHBwcHBwEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQcHBwcHBwcHBwcHBwcHAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQcHBwcHBwcHBwcHBwcHBwcBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQcHBwcHBwcHBwcHBwcHBwcHBwEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBA... |
| 462 | {"id":25,"name":"w1#nriettaLobby","group":"default","passwordProtected":false,"game":false,"hidden":false,"userCount":1,"maxUsers":300,"variables":[["doors",4,"[{\"key\":\"d3\",\"targetDir\":5,\"targetX\":19,\"targetY\":44,\"property\":{\"doorKey\":\"d2\",\"roles\":\"\",\"roomKey\":\"street01\",\"cn\":\"PassageProperty\"},\"primary\":false},{\"key\":\"d1\",\"targetDir\":7,\"targetX\":27,\"targetY\":48,\"property\":{\"buildingID\":\"2\",\"theme\":\"basic\",\"roomType\":\"HOUSE\",\"cn\":\"RoomPanelProperty\"},\"primary\":true}]",false,false],["extensions",4,"[]",false,false],["bots",4,"[{\"key\":\"luna\",\"height\":1,\"width\":1,\"length\":90,\"posX\":38,\"posY\":48,\"ver\":0,\"atlas\":0,\"pro... |
| 497 | {"id":0,"name":"w1#street01","group":"OUTDOOR","passwordProtected":false,"game":false,"hidden":false,"userCount":18,"maxUsers":300,"variables":[["doors",4,"[{\"key\":\"d2\",\"targetDir\":1,\"targetX\":36,\"targetY\":42,\"property\":{\"doorKey\":\"d3\",\"roles\":\"AA==\",\"roomKey\":\"nriettaLobby\",\"cn\":\"PassageProperty\"},\"primary\":false},{\"key\":\"d3\",\"targetDir\":7,\"targetX\":37,\"targetY\":23,\"property\":{\"buildingID\":\"3\",\"theme\":\"standard\",\"roomType\":\"CAFE\",\"cn\":\"RoomPanelProperty\"},\"primary\":false},{\"key\":\"d4\",\"targetDir\":7,\"targetX\":50,\"targetY\":23,\"property\":{\"doorKey\":\"d1\",\"roles\":\"\",\"roomKey\":\"realEstate\",\"cn\":\"PassageProperty\... |
| 503 | {"id":51,"name":"w1#street01#fishing","group":"street01","passwordProtected":false,"game":false,"hidden":false,"userCount":16,"maxUsers":300,"variables":[["isInteractiveRoom",1,false,false,false],["grid",4,"AAAAOgAAAC8BAQEBAQEBAQEBAQEBAQEBAQEBAQcHBwcHBwcHAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQcHBwcHBwcHBwcBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQcHBwcHBwcHBwcHBwEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQcHBwcHBwcHBwcHBwcHAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQcHBwcHBwcHBwcHBwcHBwcBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQcHBwcHBwcHBwcHBwcHBwcHBwEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBA... |
| 627 | {"id":49,"name":"w1#realEstate","group":"default","passwordProtected":false,"game":false,"hidden":false,"userCount":1,"maxUsers":300,"variables":[["doors",4,"[{\"key\":\"d1\",\"targetDir\":3,\"targetX\":4,\"targetY\":0,\"property\":{\"doorKey\":\"d4\",\"roomKey\":\"street01\",\"cn\":\"PassageProperty\"},\"primary\":true}]",false,false],["extensions",4,"[]",false,false],["bots",4,"[{\"key\":\"burcu\",\"height\":1,\"width\":1,\"length\":90,\"posX\":18,\"posY\":21,\"ver\":0,\"atlas\":0,\"property\":{\"cn\":\"RoomShopPanelProperty\",\"shopID\":1002},\"speechProperty\":{\"cn\":\"SpeechProperty\",\"list\":[{\"event\":\"casual\",\"message\":\"لم تحصل على منزل بعد ؟ تعال هيا! للحصول على المنازل من ه... |
| 658 | {"id":0,"name":"w1#street01","group":"OUTDOOR","passwordProtected":false,"game":false,"hidden":false,"userCount":13,"maxUsers":300,"variables":[["doors",4,"[{\"key\":\"d2\",\"targetDir\":1,\"targetX\":36,\"targetY\":42,\"property\":{\"doorKey\":\"d3\",\"roles\":\"AA==\",\"roomKey\":\"nriettaLobby\",\"cn\":\"PassageProperty\"},\"primary\":false},{\"key\":\"d3\",\"targetDir\":7,\"targetX\":37,\"targetY\":23,\"property\":{\"buildingID\":\"3\",\"theme\":\"standard\",\"roomType\":\"CAFE\",\"cn\":\"RoomPanelProperty\"},\"primary\":false},{\"key\":\"d4\",\"targetDir\":7,\"targetX\":50,\"targetY\":23,\"property\":{\"doorKey\":\"d1\",\"roles\":\"\",\"roomKey\":\"realEstate\",\"cn\":\"PassageProperty\... |
| 666 | {"id":51,"name":"w1#street01#fishing","group":"street01","passwordProtected":false,"game":false,"hidden":false,"userCount":13,"maxUsers":300,"variables":[["isInteractiveRoom",1,false,false,false],["grid",4,"AAAAOgAAAC8BAQEBAQEBAQEBAQEBAQEBAQEBAQcHBwcHBwcHAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQcHBwcHBwcHBwcBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQcHBwcHBwcHBwcHBwEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQcHBwcHBwcHBwcHBwcHAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQcHBwcHBwcHBwcHBwcHBwcBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQcHBwcHBwcHBwcHBwcHBwcHBwEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBA... |

## Door / Map Payloads

`usedoor` / `usehousedoor` responses can include room map data. `room.map` is Base64 XML, not hex.

| seq | cmd | key | roomType | roomName | doorKey | mapXmlLength | mapTags |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1427 | usehousedoor | cafe01 | cafe01 | Cafe of M7MED | d1 | 222 | {"chair":1} |
| 464 | usedoor | nriettaLobby |  |  | d1 | 5429 | {"box":38,"chair":39} |
| 498 | usedoor | street01 |  |  | d1 | 3872 | {"billboard":1,"floor":4,"chair":24,"box":24} |
| 629 | usedoor | realEstate |  |  | d1 | 1628 | {"box":9,"chair":12} |
| 659 | usedoor | street01 |  |  | d1 | 3872 | {"billboard":1,"floor":4,"chair":24,"box":24} |
| 713 | usedoor | street02 |  |  | d1 | 5097 | {"box":31,"floor":2,"billboard":1,"chair":33} |
| 768 | usedoor | street01 |  |  | d1 | 3872 | {"billboard":1,"floor":4,"chair":24,"box":24} |
| 838 | usedoor | pier |  |  | d1 | 1951 | {"box":4,"chair":20} |
| 859 | usedoor | street01 |  |  | d1 | 3872 | {"billboard":1,"floor":4,"chair":24,"box":24} |
| 905 | usedoor | sanalikaXTransfer |  |  | d1 | 40 | {} |
| 922 | usedoor | street01 |  |  | d1 | 3872 | {"billboard":1,"floor":4,"chair":24,"box":24} |
| 985 | usedoor | street03 |  |  | d1 | 4509 | {"floor":3,"box":32,"chair":24} |

## User Variable Schema

User enter action `1000` and user variable action `12` use the same variable tuple shape:

`[name, typeId, value, isPrivate]`

| name | count | typeIds | examples |
| --- | --- | --- | --- |
| tp | 229 | 2 | 1; 0 |
| position | 110 | 4 | 5,19; 4,18; 47,23; 45,18 |
| direction | 110 | 2 | 1; 5; 6; 8 |
| target | 104 | 4,0 | 4,18; null; 22,21; 31,43 |
| chatBalloon | 43 | 4 | 1; 3; 23; 26 |
| speed | 42 | 3 | 1; 100; 3.5; 4 |
| avatarName | 38 | 4 | M7MED; V£NOM; Doma; Ahmed9752 |
| gender | 38 | 4 | m; f |
| roles | 38 | 4 | ACA=; ACAAAAAAAg==; AA== |
| playerID | 37 | 2 | 1111111 |
| universeKey | 37 | 4 | w1 |
| imgPath | 37 | 2 | 1728065974 |
| mood | 37 | 2 | 0; 23; 1; 18 |
| platform | 37 | 4 | browser |
| statusMessage | 37 | 4 | Sanalika |
| avatarSize | 37 | 3 | 1 |
| clothes | 37 | 4 | ["A_2","B_2","C_2","HTuzKoEs_7","f4ddDcs3_10","roRTN78_3","n8MPy6Cv_2","2b42umx_2"]; ["A_2","B_2","C_2","33_9","ptnxfz8p_7","kJzpuOxc_9","ykbj593v_8","vg9fek4R_10","pl5t21f4_9","tym8qkh4_9"]; ["A_2","B_2","C_2","Tam0PGv9_9","mgd5f4c1_9","wYrWt7kD_9","HxvxM1pG_10","it5Tr3Ed_10"]; ["m6lYK8VV_9","fj187sm0_9"] |
| optimizedAssetKey | 37 | 2 | 1759204398; 1199191795; 834464450; 722083675 |
| status | 36 | 4 | i |
| hand | 31 | 4 | pfl45Trf; g9iTgFg3; OSbGeVHi; 0 |
| smiley | 12 | 4 | knight1; director; visitor |
| nameColor | 10 | 4 | 0066FF; CC00FF; 8B4513 |
| forceSmiley | 4 | 1 | true |

## Current Understanding

- The data that looked like “hex” was SmartFox binary framing. Room maps themselves are Base64 XML in fields such as `room.map`.
- SmartFox header flags are: `0x40 encrypted`, `0x20 compressed`, `0x10 blueBoxed`, `0x08 bigSized`.
- The latest fixed proxy decodes the currently captured room/user-state frames. If future true encrypted frames appear, CryptoManager support is already wired and key/IV order now matches the recovered client.
- To build our server, the critical room contracts are: room tuple shape, room variable/user variable tuple shape, door response `room` object, `walkrequest`/`walkfinalrequest`, and room join action `4`.
