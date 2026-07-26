# Server

Production server implementation starts here.

The temporary protocol probe stays in `server/probe` for now. It is useful as a capture harness and reference implementation, but production code belongs in `server/src`.

Architecture: [ARCHITECTURE.md](ARCHITECTURE.md)

Initial production milestone:

1. Listen on `127.0.0.1:8080` for the recovered client's local SmartFox/WebSocket flow.
2. Accept WebSocket upgrades and decode SmartFoxServer 2X binary packets.
3. Accept login and create a server-owned player session.
4. Implement extension responses for `config`, `init`, and `ping`.
5. Serve enough catalog/CDN, avatar, and first-room values for the client to clear bootstrap.

Keep recovered client code out of `server/src`; use it only as a protocol reference.