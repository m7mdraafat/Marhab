# Marhab live room capture - 2026-05-28

Sanitized browser capture performed from `https://play.ragegames.net/play/?i=ar` after login.

## Confirmed transport

- WebSocket endpoint: `wss://marhab-sfs.rage-world.net:8443/BlueBox/websocket`
- Protocol: SmartFoxServer binary protocol over BlueBox WebSocket
- The page-level WebSocket hook sees raw SFS packets after TLS but before the Haxe/SmartFox client decrypts app-level encrypted frames.

## Capture counts

- Total captured relevant events: 30
- Decoded relevant events: 22
- Encrypted inbound frames: 7
- Relevant resources observed: ~220

## Important observation

The main inbound room-state responses are marked with the SmartFox encrypted packet flag at the WebSocket payload layer. The browser hook can decode outbound extension requests and some unencrypted inbound user-variable updates, but not encrypted inbound room state directly.

Encrypted inbound frame sizes observed:

- 3258 bytes
- 1362 bytes
- 2843 bytes
- 1839 bytes
- 1596 bytes
- 874 bytes
- 1212 bytes

These likely include login/init/config/room-state payloads after SmartFox app-level encryption is enabled.

## Decoded examples

Outbound extension request:

```json
{
  "controller": 1,
  "action": 13,
  "extension": "init",
  "payload": {
    "sn": "init",
    "data": {},
    "ts": -5,
    "rid": 1
  }
}
```

Inbound unencrypted user-variable update:

```json
{
  "controller": 0,
  "action": 12,
  "variables": [
    ["status", 4, "i", false],
    ["position", 4, "5,19", false],
    ["direction", 2, 1, false]
  ]
}
```

This proves the live server uses the user variable `position` for avatar placement, and an observed live street position was `5,19` with direction `1`.

## Room assets loaded by browser client

The live Haxe client loads `st01.1` assets from CDN. These are art atlases, not the authoritative placement state.

```text
global-haxe/dynamic/ceilings/st01.1.json
global-haxe/dynamic/ceilings/st01.1.png
global-haxe/dynamic/rooms/st01.1.png
global-haxe/dynamic/rooms/st01.1/mcSign_19.json/png
global-haxe/dynamic/rooms/st01.1/bank_05_a.json/png
global-haxe/dynamic/rooms/st01.1/bank_05_b.json/png
global-haxe/dynamic/rooms/st01.1/cadde_bank1_5.json/png
global-haxe/dynamic/rooms/st01.1/cadde_bank_5.json/png
global-haxe/dynamic/rooms/st01.1/cadde_bank2_5.json/png
global-haxe/dynamic/rooms/st01.1/cadde_semsiye.json/png
global-haxe/dynamic/rooms/st01.1/cadde_sezlong.json/png
global-haxe/dynamic/rooms/st01.1/cadde_sezlong_01.json/png
global-haxe/dynamic/rooms/st01.1/cadde_sezlong_02.json/png
global-haxe/dynamic/rooms/st01.1/cadde_sezlong_03.json/png
global-haxe/dynamic/rooms/st01.1/CdTabela2.json/png
global-haxe/dynamic/rooms/st01.1/bitki_duvar_1.json/png
global-haxe/dynamic/rooms/st01.1/bitki_duvar_2.json/png
global-haxe/dynamic/rooms/st01.1/bitki_duvar_3.json/png
global-haxe/dynamic/rooms/st01.1/bitki_duvar_4.json/png
global-haxe/dynamic/rooms/st01.1/iskele.json/png
global-haxe/dynamic/rooms/st01.1/dalga.zip
global-haxe/dynamic/rooms/st01.1/kugu.zip
```

Bots/art loaded:

```text
global-haxe/static/bots/beggars.json/png
global-haxe/static/bots/tahsin.json/png
global-haxe/static/bots/baloncuBengu.json/png
global-haxe/static/bots/sanalikaxKapiBot.json/png
global-haxe/static/bots/guvenlik2.json/png
global-haxe/static/bots/airportBillboardSmall.json/png
global-haxe/static/bots/newspaperStand3.json/png
global-haxe/static/bots/ramadanStars_3.json/png
global-haxe/static/bots/ramadanStars_5.json/png
global-haxe/static/bots/ramadanPurpleLamp*.json/png
```

## Implication for our implementation

A WebSocket-only hook is not enough for full room state because room payloads are SmartFox-encrypted before they reach page-level WebSocket message handlers.

Next viable hook point is inside the Haxe/SmartFox runtime after decryption and before model application, or a reconstructed server-side room-state model based on recovered client expectations.

For the AIR client, the correct source model remains:

- SmartFox room variables: `roomKey`, `width`, `height`, `grid`, `doors`, `bots`, `extensions`
- Init response: `roomData.room.map`, `roomData.room.doorKey`
- User variables: `position`, `direction`, `target`, `status`, `clothes`, `gender`, `avatarName`
- Server validates `walkrequest` against the authoritative grid and object occupancy, then updates user variables.
