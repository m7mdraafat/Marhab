#!/usr/bin/env python3
"""
summarize-sniff.py -- digest rebuild.log [SNIFF->] / [SNIFF<-] lines into a
markdown protocol catalog.

For every distinct extension command (and every SFS event type) it records:
  - direction (->, <-, or both)
  - call count
  - unique JSON shape signatures (keys-only, recursive) with a sample payload
  - which other commands typically follow within the next 5 lines (rough
    request -> response chains)

Usage:
  python rebuild/summarize-sniff.py [--log <path>] [--out <path>]

Defaults:
  --log  %APPDATA%/com.mygame.standalone/Local Store/rebuild.log
  --out  docs/protocol-sniffed.md
"""
from __future__ import annotations

import argparse
import json
import os
import re
from collections import Counter, defaultdict
from pathlib import Path
from typing import Any

LINE_RE = re.compile(
    r"^[A-Z][a-z]{2} [A-Z][a-z]{2} +\d+ \d+:\d+:\d+ [^ ]+ \d+ "
    r"(?P<tag>\[SNIFF(?:->|<-)\]) (?P<body>.*)$"
)
OUT_RE = re.compile(r"^rid=(?P<rid>\d+) cmd=(?P<cmd>\S+) room=\S+ hasCb=\S+ params=(?P<params>.*)$")
IN_EXT_RE = re.compile(r"^ext cmd=(?P<cmd>\S+) params=(?P<params>.*)$")
IN_EVT_RE = re.compile(r"^(?P<evt>roomJoin|roomJoinError|userEnterRoom|userExitRoom|userVarUpd|roomVarUpd|connection|connectionLost|login|loginError|publicMsg|privateMsg|objMsg|modMsg|adminMsg)(?: |$)(?P<rest>.*)$")
TRUNC_RE = re.compile(r"\.\.\.\(\+\d+\)$")


def shape(o: Any, depth: int = 0) -> str:
    """Return a JSON-keys-only signature, eliding values."""
    if depth > 4:
        return "..."
    if isinstance(o, dict):
        parts = [f"{k}:{shape(v, depth+1)}" for k, v in sorted(o.items())]
        return "{" + ",".join(parts) + "}"
    if isinstance(o, list):
        if not o:
            return "[]"
        return "[" + shape(o[0], depth + 1) + (",..." if len(o) > 1 else "") + "]"
    if isinstance(o, bool):
        return "bool"
    if isinstance(o, int):
        return "int"
    if isinstance(o, float):
        return "num"
    if isinstance(o, str):
        return "str"
    if o is None:
        return "null"
    return type(o).__name__


def try_parse(payload: str) -> Any:
    payload = TRUNC_RE.sub("", payload).strip()
    if not payload or payload == "null":
        return None
    try:
        return json.loads(payload)
    except Exception:
        return payload  # keep raw for shape="<raw>"


def main() -> int:
    default_log = Path(os.environ["APPDATA"]) / "com.mygame.standalone" / "Local Store" / "rebuild.log"
    default_out = Path(__file__).resolve().parent.parent / "docs" / "protocol-sniffed.md"
    ap = argparse.ArgumentParser()
    ap.add_argument("--log", type=Path, default=default_log)
    ap.add_argument("--out", type=Path, default=default_out)
    args = ap.parse_args()

    if not args.log.exists():
        print(f"log not found: {args.log}")
        return 2

    # cmd -> direction -> (count, shapes Counter, sample payload per shape)
    catalog: dict[str, dict[str, dict]] = defaultdict(lambda: defaultdict(lambda: {"count": 0, "shapes": Counter(), "samples": {}}))
    # event -> count
    events: Counter = Counter()
    # ordered timeline of (i, kind, cmd) to compute follow-up chains
    timeline: list[tuple[int, str, str]] = []
    # rid -> (out_cmd, line_idx)
    open_rids: dict[int, tuple[str, int]] = {}
    # out cmd -> Counter[next-inbound cmd]
    follow_ups: dict[str, Counter] = defaultdict(Counter)

    raw = args.log.read_text(encoding="utf-8", errors="replace").splitlines()
    for i, line in enumerate(raw):
        m = LINE_RE.match(line)
        if not m:
            continue
        tag = m.group("tag")
        body = m.group("body")

        if tag == "[SNIFF->]":
            mo = OUT_RE.match(body)
            if not mo:
                continue
            cmd = mo.group("cmd")
            rid = int(mo.group("rid"))
            parsed = try_parse(mo.group("params"))
            sig = shape(parsed) if parsed is not None else "null"
            slot = catalog[cmd]["out"]
            slot["count"] += 1
            slot["shapes"][sig] += 1
            slot["samples"].setdefault(sig, mo.group("params")[:200])
            open_rids[rid] = (cmd, i)
            timeline.append((i, "out", cmd))
            continue

        # [SNIFF<-]
        mi = IN_EXT_RE.match(body)
        if mi:
            cmd = mi.group("cmd")
            parsed = try_parse(mi.group("params"))
            sig = shape(parsed) if parsed is not None else "null"
            slot = catalog[cmd]["in"]
            slot["count"] += 1
            slot["shapes"][sig] += 1
            slot["samples"].setdefault(sig, mi.group("params")[:200])
            timeline.append((i, "in", cmd))
            # match to most recent open rid with same cmd (rough heuristic)
            for rid in list(open_rids.keys()):
                if open_rids[rid][0] == cmd:
                    follow_ups[cmd][cmd] += 1
                    open_rids.pop(rid)
                    break
            continue

        me = IN_EVT_RE.match(body)
        if me:
            events[me.group("evt")] += 1
            timeline.append((i, "evt", me.group("evt")))
            continue

    # compute follow-up chains: for each outbound cmd, what inbound cmd
    # tends to arrive within 5 lines after it
    for idx, (i, kind, name) in enumerate(timeline):
        if kind != "out":
            continue
        for j in range(idx + 1, min(idx + 6, len(timeline))):
            i2, k2, n2 = timeline[j]
            if k2 == "in":
                follow_ups[name][n2] += 1

    # ---- emit markdown ----
    args.out.parent.mkdir(parents=True, exist_ok=True)
    lines: list[str] = []
    lines.append("# Sniffed Protocol Catalog")
    lines.append("")
    lines.append(f"Source: `{args.log}`")
    lines.append(f"Total log lines: {len(raw):,}")
    lines.append(f"Distinct extension commands: {len(catalog)}")
    lines.append("")
    lines.append("## Extension commands")
    lines.append("")
    lines.append("| cmd | out | in | shapes |")
    lines.append("|-----|----:|---:|-------:|")
    for cmd in sorted(catalog.keys()):
        out_c = catalog[cmd]["out"]["count"]
        in_c = catalog[cmd]["in"]["count"]
        shapes_n = len(catalog[cmd]["out"]["shapes"]) + len(catalog[cmd]["in"]["shapes"])
        lines.append(f"| `{cmd}` | {out_c} | {in_c} | {shapes_n} |")
    lines.append("")
    lines.append("## SFS events")
    lines.append("")
    lines.append("| event | count |")
    lines.append("|-------|------:|")
    for evt, c in events.most_common():
        lines.append(f"| `{evt}` | {c} |")
    lines.append("")
    lines.append("## Command details")
    lines.append("")
    for cmd in sorted(catalog.keys()):
        lines.append(f"### `{cmd}`")
        lines.append("")
        for direction in ("out", "in"):
            slot = catalog[cmd][direction]
            if slot["count"] == 0:
                continue
            arrow = "→ (client → server request)" if direction == "out" else "← (server → client push/response)"
            lines.append(f"**{arrow}** — {slot['count']} call(s)")
            lines.append("")
            for sig, n in slot["shapes"].most_common():
                sample = slot["samples"].get(sig, "")
                lines.append(f"- shape `{sig}` ×{n}")
                if sample:
                    lines.append(f"  - sample: `{sample}`")
            lines.append("")
        # follow-ups
        fu = follow_ups.get(cmd)
        if fu:
            top = fu.most_common(5)
            lines.append("**Typical follow-ups within 5 lines:**")
            for n, c in top:
                lines.append(f"- `{n}` ×{c}")
            lines.append("")

    args.out.write_text("\n".join(lines), encoding="utf-8")
    print(f"wrote {args.out} ({len(lines):,} lines, {len(catalog)} cmds, {sum(events.values())} sfs events)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
