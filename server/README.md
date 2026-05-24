# server/

This is where **your own backend** lives. Right now it's just a scaffold —
a tiny Java SFS extension stub + helper scripts. Once you install
SmartFoxServer 2X you can drop this in and grow it.

Status today: **not deployable yet**. You still need:

1. SmartFoxServer 2X Community Edition installed (Windows: ZIP from
   <https://www.smartfoxserver.com/download/>). Listens on `:9933` (admin),
   `:8080` (HTTP/WebSocket / BlueBox), `:9933` (TCP).
2. Java 8+ on the server machine (already have Java 25 here).
3. (For friends-mode) a reachable hostname pointing at the host.

## Layout

```
server/
  README.md                ← this file
  build.ps1                ← compiles MyGameExtension.jar with plain javac
  run-local.ps1            ← copies the jar into SFS, restarts SFS Service
  src/
    com/mygame/extension/
      MyGameExtension.java ← stub: subclasses BaseServerEventHandler
      LoginHandler.java    ← accepts any user/pass, sets a fake "marhab" zone
      RequestDataHandler.java
                           ← responds to "requestData" with a minimal config
  lib/
    (empty -- drop SFS's sfs2x.jar + sfs2x-core.jar here when SFS is installed)
```

## Workflow once SFS 2X is installed

1. Copy `SFS2X/lib/sfs2x.jar` and `SFS2X/lib/sfs2x-core.jar` into `server/lib/`.
2. `.\build.ps1` → produces `server/dist/MyGameExtension.jar`.
3. `.\run-local.ps1` (admin) → copies jar into `SFS2X/extensions/MyGameExtension/`
   and restarts the SmartFoxServer 2X service.
4. Edit a Zone in SFS Admin (default web UI at <http://localhost:8080/admin>):
   - Create Zone `marhab` (the name our client sends after the hosts redirect)
   - Set extension class to `com.mygame.extension.MyGameExtension`
5. Add a hosts-file entry so MyGame client thinks it's hitting Marhab:
   `127.0.0.1   marhab-sfs.rage-world.net`
   (You can use the unpatched snl.780.swf and your local SFS will answer.)
6. Run MyGame.exe. The trace should show `sfs connected` and the connection
   should land in your `LoginHandler.handleClientRequest`.

## Protocol notes (captured from a real Marhab session)

The first traces from the running game showed:
- `sfs connected`
- `sfs logged in`
- `## ServiceModel ## -> requestData : config sent. (type : requestData) ## ->{}`
- Server responded with a giant JSON describing language, fileServer, webServer,
  moods (32 entries), masterRoles (52 entries), chatBaloons (9 entries),
  diamondExchangeRate, etc. See `MyGame/rebuild/inventory/snl_780.strings.txt`
  for the full menu of role names and the field shapes.

The captured JSON shape is the starting template for `RequestDataHandler`.

## What this stub IS NOT

- Not a full game server. No room state, no avatar movement, no chat, no items.
- Not authenticated. Accepts any login (so you and friends can poke at it).
- Not persistent. No database. Restart = state lost.

The point right now is to:
- Let the MyGame client successfully complete its `sfs login` handshake
- Reply to `requestData config` with enough valid-looking JSON that the
  client's `## ServiceModel ##` stops blocking

Past that, every game feature (rooms, walking, chat, currency, "give me coins")
is its own handler you add later.
