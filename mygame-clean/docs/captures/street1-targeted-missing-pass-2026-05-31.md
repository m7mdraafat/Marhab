# Street1 Targeted Missing Pass - 2026-05-31

Source: `server/logs/original-proxy/original-proxy-2026-05-31T14-37-44-815Z.jsonl`

## Capture Health

| Metric | Value |
| --- | ---: |
| Events | 577 |
| Frames | 569 |
| Decoded frames | 569 |
| Undecoded frames | 0 |

## Previous Gaps Now Covered

| Command | Client -> Server | Server -> Client | Notes |
| --- | ---: | ---: | --- |
| `profile` | 2 | 2 | Profile response includes cards, mood, skin, social counts/details. |
| `orderlist` | 3 | 3 | Returned empty `orders` arrays in this pass. |
| `musicList` | 1 | 1 | Returned empty `songs` array. |
| `usechatballoon` | 5 | 5 | Chat balloon selection/update flow captured. |
| `roommessage` | 1 | 1 | Room message send and echo/response captured. |
| `removeavatarrestriction` | 1 | 1 | List command captured. |
| `usehousedoor` | 2 | 2 | Concrete house/cafe entry response captured. |
| `questaccept` | 1 | 1 | Mission accept request/response captured. |
| `queststepcomplete` | 0 | 1 | Server-side quest step completion push captured. |

## Still Missing

- None from the previous gap list after the follow-up avatar-list capture.

## Avatar List Follow-Up

Source: `server/logs/original-proxy/original-proxy-2026-05-31T14-43-35-723Z.jsonl`

| Command | Client -> Server | Server -> Client | Notes |
| --- | ---: | ---: | --- |
| `avatarlist` | 1 | 1 | Avatar selection/list panel captured. |

Request shape:

```json
{"r":-1,"p":{"data":{},"sn":"avatarlist","rid":6},"c":"avatarlist"}
```

Response shape:

```json
{
	"p": {
		"avatarList": [
			{
				"avatarID": "101002081",
				"avatarName": "M7MED",
				"gender": "m",
				"mood": 0,
				"sanil": 225931,
				"diamond": 148,
				"like": 42,
				"dislike": 0,
				"createdAt": "2025-05-23",
				"lastLoginDate": "0",
				"loginCount": 0,
				"lastRoom": "w1#street01",
				"lastUniverse": "w1"
			}
		],
		"rid": 257,
		"nextRequest": 1000
	},
	"c": "avatarlist"
}
```

## Additional Room/House Editing Coverage

| Command | Client -> Server | Server -> Client | Notes |
| --- | ---: | ---: | --- |
| `flatinfo` | 1 | 1 | Flat metadata/details captured. |
| `flatsettings` | 1 | 1 | Flat settings request/response captured. |
| `loadroomdesign` | 1 | 1 | Room design load captured. |
| `saveroomdesign` | 1 | 1 | Room design save captured. |
| `flatlist` | 2 | 2 | Building flat list captured. |
| `usedoor` | 1 | 3 | Door transition responses captured. |

## Interpretation

The combined session set now covers the street1 room graph, direct streets/rooms, UI panels, quest accept, house entry, room design commands, and avatar list. No known gap from the previous checklist remains.