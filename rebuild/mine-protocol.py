#!/usr/bin/env python3
"""
mine-protocol.py - scan decompiled snl.780.swf for the SFS extension command
catalog (what commands the client sends to the server).

Looks for several common AS3 SFS client patterns:
  - new ExtensionRequest("<cmd>", ...)
  - sendExtensionRequest("<cmd>", ...)
  - send("<cmd>", ...)
  - "<cmd>" as a string literal near "ExtensionRequest" mentions
"""
from __future__ import annotations
import re
import sys
import json
from collections import Counter, defaultdict
from pathlib import Path

HERE = Path(__file__).resolve().parent
SRC = HERE.parent / "rebuild" / "inventory" / "snl_780_src"
OUT_DIR = HERE.parent / "rebuild" / "inventory"

PATTERNS = [
    ("ExtensionRequest(\"X\"...)", re.compile(rb'ExtensionRequest\s*\(\s*"([^"]+)"')),
    ('sendRequest("X"...)',         re.compile(rb'sendRequest\s*\(\s*"([^"]+)"')),
    ('sendExtensionRequest',        re.compile(rb'sendExtensionRequest\s*\(\s*"([^"]+)"')),
    ('SetExtensionId',              re.compile(rb'setExtId\s*\(\s*"([^"]+)"')),
]

def main() -> int:
    if not SRC.exists():
        print(f"missing: {SRC}", file=sys.stderr)
        return 2
    counts = defaultdict(Counter)            # pattern_name -> Counter(cmd_name)
    file_index = defaultdict(set)            # cmd_name -> set(file paths)
    files_scanned = 0
    for f in SRC.rglob("*.as"):
        files_scanned += 1
        try:
            raw = f.read_bytes()
        except OSError:
            continue
        for label, rx in PATTERNS:
            for m in rx.finditer(raw):
                cmd = m.group(1).decode("latin-1", errors="replace")
                counts[label][cmd] += 1
                file_index[cmd].add(str(f.relative_to(SRC)))

    print(f"scanned {files_scanned} .as files")
    print()
    for label, c in counts.items():
        if not c:
            continue
        print(f"=== pattern: {label} ===  total hits={sum(c.values())}  unique cmds={len(c)}")
        for cmd, n in c.most_common(60):
            print(f"  {n:>4}  {cmd}")
        print()

    # Save full catalog
    catalog = {
        "files_scanned": files_scanned,
        "by_pattern": {label: dict(c) for label, c in counts.items()},
        "commands": {
            cmd: {"count": sum(c[cmd] for c in counts.values()), "files": sorted(file_index[cmd])[:5]}
            for cmd in sorted(file_index)
        },
    }
    out = OUT_DIR / "protocol_catalog.json"
    out.write_text(json.dumps(catalog, indent=2, sort_keys=True))
    print(f"\nwrote: {out}  ({out.stat().st_size:,} bytes)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
