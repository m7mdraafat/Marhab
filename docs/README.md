# Marhab / Sanalika — Client Analysis & Server Build Plan

Comprehensive read-only analysis of the decompiled AS3 client at
[../rebuild/inventory/snl_780_src/scripts/](../rebuild/inventory/snl_780_src/scripts)
and a step-by-step plan to rebuild the server.

Everything below is grounded in source citations. File:line references use
workspace-relative paths from the repo root.

## Index

| # | File | What's inside |
|---|---|---|
| 1 | [01-architecture.md](01-architecture.md) | System architecture (one-page mental model) |
| 2 | [02-bootstrap.md](02-bootstrap.md) | Bootstrap & connection lifecycle — what runs first, and why |
| 3 | [03-protocol-catalog.md](03-protocol-catalog.md) | Complete protocol catalog (~70 requests, ~80 pushes, RoomVariables, UserVariables) |
| 4 | [04-rooms-and-walking.md](04-rooms-and-walking.md) | Rooms, streets, walking, doors — the deep dive |
| 5 | [05-enums-and-types.md](05-enums-and-types.md) | Enums, types, value objects |
| 6 | [06-subsystems.md](06-subsystems.md) | Items, cloth, buddy, chat, purchase, flat, transfer/barter, quest, achievement, mission, property |
| 7 | [07-asset-pipeline.md](07-asset-pipeline.md) | sprites / shapes / symbolClass / morphshapes / frames / binaryData / fonts / images |
| 8 | [08-database-schema.md](08-database-schema.md) | Proposed PostgreSQL schema (modular monolith) |
| 9 | [09-server-build-plan.md](09-server-build-plan.md) | Suggested server structure & exact order to implement handlers |
| 10 | [10-gaps-and-blockers.md](10-gaps-and-blockers.md) | Open gaps + verified shipping-blockers + cheat sheet |
| 11 | [11-first-time-flow.md](11-first-time-flow.md) | Definitive new-player flow: AvatarCreatePanel → cloth pick → first room |
| 12 | [12-our-own-cdn.md](12-our-own-cdn.md) | Building our own CDN from cached `ifile`/`vf` + `rebuild/` assets |

## How to use this

- New to the project? Read [01](01-architecture.md) → [02](02-bootstrap.md) → [11](11-first-time-flow.md) → [09](09-server-build-plan.md) in that order.
- Implementing a handler? Find it in [03](03-protocol-catalog.md), look up types in [05](05-enums-and-types.md), find DB tables in [08](08-database-schema.md).
- Hunting a bug in walking / room load? [04](04-rooms-and-walking.md) — the deep-dive with map format + grid encoding + A* + isometric math.
- Wondering why an asset 404s? [07](07-asset-pipeline.md), then [12](12-our-own-cdn.md) for our own-CDN strategy.
- Wiring up the first-time experience? [11](11-first-time-flow.md).
- Stuck? Check [10](10-gaps-and-blockers.md) — it lists known ceilings.

## Source-of-truth rule

The decompiled client at [../rebuild/inventory/snl_780_src/](../rebuild/inventory/snl_780_src)
is the contract. Server replies must match the **exact** field names, string
values, and ints the client reads. Constants live in
[../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/enums/](../rebuild/inventory/snl_780_src/scripts/com/oyunstudyosu/enums).

Never edit `rebuild/inventory/snl_780_src/` — it's a snapshot, not source.
Client-side patches go in `rebuild/inventory/snl_780_patch/`.

See also: [../AGENT_GUIDE.md](../AGENT_GUIDE.md), [../PLAN.md](../PLAN.md).
