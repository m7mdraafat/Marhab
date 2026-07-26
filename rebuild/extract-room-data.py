#!/usr/bin/env python3
"""
extract-room-data.py -- parse rebuild.log for [SNIFF<-] roomVars lines and
emit per-room data files (grid bytes, doors JSON, bots JSON) under
server/www/rooms/<roomKey>/ for the HaraExtension to load at runtime.

Output layout:
  server/www/rooms/<roomKey>/grid.bin     (raw bytes: int32 BE w, int32 BE h, w*h bytes)
  server/www/rooms/<roomKey>/doors.json   (the doors RoomVariable value, verbatim)
  server/www/rooms/<roomKey>/bots.json    (the bots RoomVariable value, verbatim)
  server/www/rooms/<roomKey>/meta.json    ({sourceRoomName, capturedAt, capturedFromUser})

The roomKey is parsed from the SFS room name `{universe}#{roomKey}` (e.g.
`w1#street01` -> `street01`).

Usage:
  python rebuild/extract-room-data.py [--log <path>] [--out <dir>]
"""
from __future__ import annotations

import argparse
import base64
import json
import os
import re
import struct
import time
from pathlib import Path

ROOM_VARS_RE = re.compile(
    r"\[SNIFF<-\] roomVars room=(?P<room>\S+) vars=(?P<json>\{.*)$"
)
# init/usedoor/teleport/usehousedoor responses all carry room.{key, map, doorKey, ...}.
EXT_RESP_RE = re.compile(
    r"\[SNIFF<-\] ext cmd=(?P<cmd>init|usedoor|teleport|usehousedoor) params=(?P<json>\{.*)$"
)


def parse_room_key(sfs_room_name: str) -> str:
    """Extract the bare room key from `w1#street01` style names."""
    if "#" not in sfs_room_name:
        return sfs_room_name
    parts = sfs_room_name.split("#")
    # Drop universe prefix and sub-game suffix; keep middle (or last for 2-part).
    return parts[1] if len(parts) >= 2 else sfs_room_name


def decode_grid_b64(grid_b64: str) -> tuple[int, int, bytes] | None:
    """Decode the base64 grid blob into (w, h, raw_bytes)."""
    if not isinstance(grid_b64, str) or not grid_b64:
        return None
    try:
        raw = base64.b64decode(grid_b64, validate=False)
    except Exception:
        return None
    if len(raw) < 8:
        return None
    w = struct.unpack(">i", raw[0:4])[0]
    h = struct.unpack(">i", raw[4:8])[0]
    cells = raw[8:]
    if len(cells) != w * h:
        # try little-endian — some clients used it
        w = struct.unpack("<i", raw[0:4])[0]
        h = struct.unpack("<i", raw[4:8])[0]
        if len(cells) != w * h:
            return None
    return (w, h, cells)


def main() -> int:
    default_log = Path(os.environ["APPDATA"]) / "com.mygame.standalone" / "Local Store" / "rebuild.log"
    repo_root = Path(__file__).resolve().parent.parent
    default_out = repo_root / "server" / "www" / "rooms"

    ap = argparse.ArgumentParser()
    ap.add_argument("--log", type=Path, default=default_log)
    ap.add_argument("--out", type=Path, default=default_out)
    args = ap.parse_args()

    if not args.log.exists():
        print(f"log not found: {args.log}")
        return 2

    extracted: dict[str, dict] = {}
    # roomKey -> base64 map XML (latest wins)
    map_b64: dict[str, str] = {}

    for line in args.log.read_text(encoding="utf-8", errors="replace").splitlines():
        m = ROOM_VARS_RE.search(line)
        if m:
            room_name = m.group("room")
            room_key = parse_room_key(room_name)
            try:
                vars_obj = json.loads(m.group("json"))
            except json.JSONDecodeError:
                continue
            extracted[room_key] = {"sourceRoomName": room_name, "vars": vars_obj}
            continue

        me = EXT_RESP_RE.search(line)
        if me:
            try:
                resp = json.loads(me.group("json"))
            except json.JSONDecodeError:
                continue
            room = resp.get("room") if isinstance(resp, dict) else None
            if not isinstance(room, dict):
                continue
            rk = room.get("key")
            mp = room.get("map")
            if isinstance(rk, str) and isinstance(mp, str) and mp:
                map_b64[rk] = mp

    if not extracted and not map_b64:
        print("no [SNIFF<-] roomVars or ext-response map data found")
        return 1

    # union: any room with either roomVars or map data
    all_keys = set(extracted.keys()) | set(map_b64.keys())

    args.out.mkdir(parents=True, exist_ok=True)
    summary: list[str] = []
    for room_key in sorted(all_keys):
        payload = extracted.get(room_key, {"sourceRoomName": room_key, "vars": {}})
        room_dir = args.out / room_key
        room_dir.mkdir(parents=True, exist_ok=True)
        vars_obj = payload["vars"]

        # grid
        grid_info = decode_grid_b64(vars_obj.get("grid"))
        if grid_info:
            w, h, cells = grid_info
            grid_bytes = struct.pack(">i", w) + struct.pack(">i", h) + cells
            (room_dir / "grid.bin").write_bytes(grid_bytes)
            summary.append(f"  {room_key}: grid {w}x{h} ({len(cells)} bytes)")
        else:
            summary.append(f"  {room_key}: grid MISSING")

        # doors (verbatim JSON string)
        doors = vars_obj.get("doors")
        if isinstance(doors, str) and doors:
            (room_dir / "doors.json").write_text(doors, encoding="utf-8")

        # bots (verbatim JSON string)
        bots = vars_obj.get("bots")
        if isinstance(bots, str) and bots:
            (room_dir / "bots.json").write_text(bots, encoding="utf-8")

        # map XML (from init/usedoor responses, decoded for readability)
        if room_key in map_b64:
            try:
                xml = base64.b64decode(map_b64[room_key]).decode("utf-8", errors="replace")
                (room_dir / "map.xml").write_text(xml, encoding="utf-8")
                summary[-1] += "; map.xml " + str(len(xml)) + " chars"
            except Exception as ex:
                summary[-1] += f"; map.xml DECODE FAILED ({ex})"

        # meta
        meta = {
            "sourceRoomName": payload["sourceRoomName"],
            "capturedAt": int(time.time()),
            "varKeys": sorted(vars_obj.keys()) if isinstance(vars_obj, dict) else [],
            "hasMapXml": room_key in map_b64,
        }
        (room_dir / "meta.json").write_text(json.dumps(meta, indent=2), encoding="utf-8")

    print(f"wrote {len(all_keys)} room(s) to {args.out}")
    print("\n".join(summary))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
