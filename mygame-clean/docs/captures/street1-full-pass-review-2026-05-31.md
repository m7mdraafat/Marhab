# Street1 Full Pass Review - 2026-05-31

Source: `server/logs/original-proxy/original-proxy-2026-05-31T14-25-36-946Z.jsonl`

## Capture Health

| Metric | Value |
| --- | ---: |
| Events | 1822 |
| Frames | 1811 |
| Decoded frames | 1811 |
| Undecoded frames | 0 |

This is a usable source-of-truth session for the street1-connected pass.

## Street1 Direct Door Coverage

All 9 direct `street01` door definitions were observed in the room-state tuple.

| Door | Type | Target |
| --- | --- | --- |
| `d2` | `PassageProperty` | `nriettaLobby` / `doorKey=d3` |
| `d3` | `RoomPanelProperty` | `buildingID=3`, `roomType=CAFE` |
| `d4` | `PassageProperty` | `realEstate` / `doorKey=d1` |
| `d5` | `PassageProperty` | `street03` / `doorKey=d1` |
| `d6` | `PassageProperty` | `street02` / `doorKey=d1` |
| `d7` | `PassageProperty` | `street05` / `doorKey=d5` |
| `d8` | `PassageProperty` | `pier` / `doorKey=d1` |
| `d9` | `PassageProperty` | `oyunika` / `doorKey=d1` |
| `d1` | `RoomPanelProperty` | `buildingID=10`, `roomType=OFFICE`, `doorKey=d1` |

## Rooms Captured Through Door Responses

| Room key | Map tags captured |
| --- | --- |
| `street01` | `billboard`, `floor`, `chair`, `box` |
| `street02` | `box`, `floor`, `billboard`, `chair` |
| `street03` | `floor`, `box`, `chair` |
| `street05` | `floor`, `box`, `chair` |
| `pier` | `box`, `chair` |
| `realEstate` | `box`, `chair` |
| `nriettaLobby` | `box`, `chair` |
| `oyunika` | `box`, `chair`, `floor` |
| `sanalikaXTransfer` | empty/minimal map |
| `sanalikaXRocket` | `chair`, `box` |
| `sanalikaXMarsTransfer` | `chair`, `box` |

## Panels Captured In This Session

| Command | Direction coverage |
| --- | --- |
| `buddylist` | request + response |
| `cardlist` | request + response |
| `handitemlist` | request + response |
| `clothlist` | request + response |
| `smileylist` | request + response |
| `achievementlist` | request + response |
| `universelist` | request + response |
| `privatechatlist` | request + response |
| `pendinglist` | request + response |
| `shopproductlist` | request + response |
| `saleproductlist` | request + response |
| `pubContentList` | request + response |
| `setactivegroup` | request + response |
| `usehanditem` | request + response |

## Missing Or Needs A Targeted Follow-Up

These did not appear in this specific session:

- `profile`
- `orderlist`
- `musicList`
- `usechatballoon`
- `roommessage`
- `avatarlist`
- `removeavatarrestriction`
- `usehousedoor` response: building lists/panels were captured, but no concrete house/cafe entry response was captured in this session.
- `questaccept`: room quest lists and inventory updates appeared, but no quest accept request/response appeared in this session.

## Quest Coverage

Captured:

- `questlist` request + response
- `questlistroom` server pushes
- `updateInventory` server pushes

Missing in this session:

- `questaccept`
- `queststepcomplete`
- quest completion/claim flow beyond the automatic room quest list/update push

## Interpretation

This session is strong for street1 room/door contracts and panel/list contracts. It is not complete for every UI workflow. The next capture should be a small targeted pass for the missing command families only, not another full street traversal.