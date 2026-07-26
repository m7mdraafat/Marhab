# Street Join Network Analysis (st01)

Goal: Capture and document the real Marhab/Sanalika traffic when a user joins a street room (st01) — focusing on room join, spawn position, and walkability data.

## Plan
- [ ] Open https://www.sanalika.com/eg/play in Playwright browser
- [ ] Login (m7mdraafat2003@gmail.com)
- [ ] Wait for game to load (Flash SWF)
- [ ] Clear network log, then trigger join street st01
- [ ] Capture HTTP requests during join (manifests, JSON tiles, sprite atlases, room defs)
- [ ] Capture WebSocket frames (room handshake, spawn pos, walk packets)
- [ ] Document structure: ceilings JSON, ground/walkability data, spawn position payload
- [ ] Save findings to docs/

## Output
- `docs/street-join-trace.md` — annotated trace
- `assets/reports/street-st01/*.json` — raw captures
