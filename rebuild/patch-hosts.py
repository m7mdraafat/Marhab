#!/usr/bin/env python3
"""
patch-hosts.py — patch hardcoded backend hostnames inside the decrypted
snl_780_uncompressed.swf (FWS body), keeping byte-length identical so SWF
tag/string offsets stay valid.

Then run `pack-snl.py` on the patched FWS to get a deployable snl.780.swf.

Configure REPLACEMENTS below. Each pair must have EXACTLY the same byte length
on both sides; otherwise the SWF string-table widths break.

Strings observed in the original game binary (length in parens):
    sfs.sanalika.com       (16)        \\__ original Sanalika SFS
    fs.sanalika.com        (15)            original Sanalika file CDN
    sfs.newmarhab.com      (17)        \\__ Marhab's branded patches
    sfs.newmarhab.net      (17)
    xo.newmarhab.net       (16)            Marhab file CDN
    sfs.rage-world.org     (18)        \\__ Marhab's deployed SFS hosts
    sfs.rage-world.net     (18)
    rage-world             (10)            base of `<instance>-sfs.rage-world.net`

For "friends mode" you typically only need to redirect the SFS host. The
file-CDN can keep its name as long as the assets are reachable (or the AIR
app's runtime/ folder is used).
"""
from __future__ import annotations
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent
SRC = ROOT / "rebuild" / "inventory" / "snl_780_uncompressed.swf"
DST = ROOT / "rebuild" / "inventory" / "snl_780_patched.swf"

# EDIT THESE -- each old/new pair must be the SAME byte length.
# Default below is a SMOKE-TEST patch: redirects all backend hosts to fake
# placeholders so we can prove that (a) our patch reaches the running AIR
# runtime and (b) the game actually tries to use the patched names.
# Replace with your real domain before deploying to friends.
REPLACEMENTS: list[tuple[bytes, bytes]] = [
    # SFS hosts -- swap the brand part, keep <instance>-sfs.<brand>.<tld> shape
    (b"sfs.rage-world.net",  b"sfs.mygame-test.cc"),  # 18 == 18
    (b"sfs.rage-world.org",  b"sfs.mygame-test.cc"),  # 18 == 18
    (b"sfs.newmarhab.net",   b"sfs.mygame-test.io"),  # 17 == 17
    (b"sfs.newmarhab.com",   b"sfs.mygame-test.io"),  # 17 == 17
    # File CDN -- keep similar shape
    (b"xo.newmarhab.net",    b"cdn.mygametest.io"),   # 16 == 16
    # Leave original Sanalika hosts as-is for now (Marhab kept them as fallbacks)
    # (b"sfs.sanalika.com",    b"sfs.your-host.cc"),   # 16 == 16
    # (b"fs.sanalika.com",     b"cdn.your-host.cc"),   # 15 == 15
]


def main() -> int:
    if not SRC.exists():
        print(f"missing: {SRC}", file=sys.stderr)
        print("Run rebuild/decrypt-snl.py and rebuild/inspect-snl.py first.", file=sys.stderr)
        return 2

    raw = bytearray(SRC.read_bytes())
    print(f"input: {SRC.name}  {len(raw):,} bytes")

    if not REPLACEMENTS:
        print("\nNo REPLACEMENTS configured -- edit this file's REPLACEMENTS list.")
        print("Showing detected hardcoded backend hosts in the SWF:\n")
        targets = [b"sfs.rage-world.net", b"sfs.rage-world.org",
                   b"sfs.newmarhab.net", b"sfs.newmarhab.com",
                   b"xo.newmarhab.net", b"sfs.sanalika.com", b"fs.sanalika.com"]
        for t in targets:
            count = raw.count(t)
            print(f"  {t.decode():<22}  ({len(t):2} bytes)  x{count}")
        return 0

    total = 0
    for old, new in REPLACEMENTS:
        if len(old) != len(new):
            print(f"  SKIP {old!r} -> {new!r}  (length mismatch: {len(old)} vs {len(new)})",
                  file=sys.stderr)
            continue
        n = raw.count(old)
        if n == 0:
            print(f"  (not present) {old!r}")
            continue
        raw = bytearray(bytes(raw).replace(old, new))
        total += n
        print(f"  replaced {n}x  {old!r} -> {new!r}")
    print(f"\ntotal replacements: {total}")

    DST.write_bytes(bytes(raw))
    print(f"wrote {DST}")
    print(f"next:  python rebuild/pack-snl.py {DST}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
