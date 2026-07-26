# New User Command Chain - 2026-05-31

Source captures:

- `server/logs/original-proxy/original-proxy-2026-05-31T14-43-35-723Z.jsonl`
- `server/logs/original-proxy/original-proxy-2026-05-31T17-09-37-832Z.jsonl`
- Cross-checks across all `server/logs/original-proxy/*.jsonl`

Client source anchors:

- `client/recovered/game-src/Sanalika.as`
- `client/recovered/game-src/com/oyunstudyosu/avatar/AvatarModel.as`
- `client/recovered/game-src/com/oyunstudyosu/commands/LoginCommand.as`
- `client/recovered/game-src/com/oyunstudyosu/service/ServiceModel.as`

## Verified Startup Chain

For a client with no access token in local storage, the first login request is still a SmartFox login request with empty username/password and no token:

1. `c=0 a=0` handshake request.
2. `c=0 a=0` handshake response with `tk`, `ct`, `ms`.
3. `c=0 a=1` login request with params such as `clientKey`, `client`, `deviceId`, and no access token.
4. `c=0 a=1` login response.
5. Extension request `config`.
6. Extension response `config`.

After config/version assets load, the recovered client opens `GuestPanel` when:

```as3
Sanalika.instance.serviceModel.sfs.mySelf.privilegeId == 0 && avatarModel.guest == false
```

If the user already has a valid session/token, this panel should not be shown. The server should return a normal logged-in identity and proceed to `init`.

## GuestPanel Branches

### Login

Target behavior: open our web login page. The exact panel button implementation is in the external `GuestPanel` module, not in recovered AS3 sources. The backend-facing completion event is verified as `externalAuthComplete`; the client stores the returned token and calls `Sanalika.instance.reset()`.

Expected completion response shape:

```json
{
  "c": "externalAuthComplete",
  "p": {
    "token": "..."
  }
}
```

### Signup

Captured behavior: signup opens a web registration page. Registration collects:

- Character Name
- Email
- Password
- Gender Type

After clicking Register, the web server creates the account and avatar before the client enters the world. The client does not show `CreateAvatarPanel` in this captured path.

Captured sequence from `original-proxy-2026-05-31T17-09-37-832Z.jsonl`:

1. No-token SmartFox login succeeds as a temporary/guest panel identity.
2. Client requests `config`.
3. `GuestPanel` opens.
4. User completes web registration.
5. Client sends extension request `ditchguestpanel` while waiting for the auth bridge.
6. Server replies with extension command `externalAuthComplete` containing `avatarID` and `token`.
7. Client stores the token and resets.
8. Client logs out with `c=0 a=2`.
9. Client logs in again with the returned token.
10. Client sends extension request `init`.
11. Server returns `init` with `createAvatar=false`, `checkAvatar=1`, `selectedAvatarID` set to the newly created avatar, default clothes, and starting room `airport`.
12. Server sends room join action `c=0 a=4` for `w1#airport`.

Captured signup completion shape:

```json
{
  "c": "externalAuthComplete",
  "p": {
    "avatarID": "101010400",
    "token": "..."
  }
}
```

Captured first `init` fields after registration:

```json
{
  "selectedAvatarID": "101010400",
  "createAvatar": false,
  "checkAvatar": 1,
  "guest": false,
  "gender": "m",
  "room": {
    "key": "airport",
    "doorKey": "d1"
  },
  "clothes": {
    "type": "CLOTH",
    "items": ["default clothes, 7 captured items"]
  },
  "wallet": [
    { "currency": "SANIL", "balance": 30000 },
    { "currency": "DIAMOND", "balance": 100 }
  ]
}
```

After leaving the airport, the server sends room join action `c=0 a=4` for `w1#street01`, followed by extension response `usedoor` with `room.key=street01` and `room.doorKey=d1`.

### Continue as Guest

This is captured and verified. It is not anonymous play in-place.

Sequence:

1. Client sends extension request `ditchguestpanel`.
2. Server replies with extension command `externalTokenComplete` containing `avatarID` and `token`.
3. Client stores the token in `avatarModel.accessToken`.
4. Client calls `Sanalika.instance.reset()`.
5. Client sends SmartFox logout `c=0 a=2`.
6. Client logs in again with the returned token.
7. Client sends extension request `init`.
8. Server sends avatar/user variables, `initQueue`, `restartServer`, `init`, then room join state.

Captured `externalTokenComplete` shape:

```json
{
  "c": "externalTokenComplete",
  "p": {
    "avatarID": "101002081",
    "token": "..."
  }
}
```

## Create Avatar Path

The web signup capture did not use `CreateAvatarPanel`; the web server created the avatar directly from the registration form. The captured `init` response contains the controlling fields:

```json
{
  "createAvatar": false,
  "checkAvatar": 1,
  "selectedAvatarID": "101002081",
  "guest": false,
  "clothes": { "type": "CLOTH", "items": [] },
  "room": { "key": "street01", "doorKey": "d1" }
}
```

For a totally new account, the likely server-controlled switch is `createAvatar: true` in the `init` payload, along with default clothes and no selected completed avatar. The exact Save command must still be captured by clearing local token/session state, taking the create-avatar path, entering a name, and clicking Save.

Current production target should model web signup as the primary new-account path:

1. Web register creates account + avatar using submitted character name and gender.
2. Auth bridge returns `externalAuthComplete` to the AIR client.
3. Token login proceeds to normal `init` with `createAvatar=false`.
4. First room is configurable. Remote currently starts new registered avatars in `airport`, then door-exits to `street01`. For our server, keep this as config so we can choose either `airport` onboarding or direct `street01` start.

## Server Implementation Order

1. `config` - done.
2. `ditchguestpanel` -> `externalTokenComplete` - done.
3. `init` with two modes:
   - existing/guest-token avatar mode: `createAvatar=false`, default room `street01`.
  - web-registered avatar mode: `createAvatar=false`, default clothes from registration, configurable first room (`airport` captured, `street01` allowed by config).
4. Web auth/register bridge:
  - register page creates user + avatar from character name, email, password, and gender.
  - SFS side sends `externalAuthComplete` with avatar ID and token once web auth completes.
5. Optional future path: only capture and implement `CreateAvatarPanel` Save if we find a product path that actually uses in-game avatar creation.
6. `roomjoincomplete`, `ping`, first room state, and airport -> street01 `usedoor`.
