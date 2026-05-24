#!/usr/bin/env python3
"""Decompress the decrypted snl.780.swf (ZWS → FWS) and extract URLs."""
from __future__ import annotations
import re
import struct
import lzma
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent
IN_PATH = ROOT / "rebuild" / "inventory" / "snl_780_decrypted.swf"
OUT_PATH = ROOT / "rebuild" / "inventory" / "snl_780_uncompressed.swf"
URL_PATH = ROOT / "rebuild" / "inventory" / "snl_780.urls.txt"
STR_PATH = ROOT / "rebuild" / "inventory" / "snl_780.strings.txt"

PRINTABLE = re.compile(rb"[\x20-\x7e]{6,}")
URL_RE = re.compile(
    rb"(?:https?|wss?|ftp)://[A-Za-z0-9._~%/?#@!$&'()*+,;=:\[\]-]+",
    re.IGNORECASE,
)
HOST_RE = re.compile(
    rb"\b(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+"
    rb"(?:com|net|org|io|tv|info|me|gg|sanalika|world|games|local|cloud|app)\b",
    re.IGNORECASE,
)
PORT_HOST = re.compile(
    rb"\b(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z]{2,12}:\d{2,5}\b",
    re.IGNORECASE,
)


def decompress_zws(buf: bytes) -> bytes:
    assert buf[:3] == b"ZWS"
    version = buf[3]
    file_length = struct.unpack("<I", buf[4:8])[0]
    props = buf[12:17]
    body = buf[17:]
    alone = props + struct.pack("<Q", 0xFFFFFFFFFFFFFFFF) + body
    decompressed = lzma.decompress(alone, format=lzma.FORMAT_ALONE)
    return b"FWS" + bytes([version]) + struct.pack("<I", file_length) + decompressed


def main() -> int:
    # Reconfigure stdout for UTF-8 if the console is cp1252/cp850 etc.
    # (avoids UnicodeEncodeError when printing strings extracted from the SWF)
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass

    raw = IN_PATH.read_bytes()
    print(f"input: {IN_PATH.name}  {len(raw):,} bytes  magic={raw[:3]!r}")
    fws = decompress_zws(raw)
    OUT_PATH.write_bytes(fws)
    print(f"decompressed: {OUT_PATH.name}  {len(fws):,} bytes")

    seen = set()
    strings = []
    for m in PRINTABLE.finditer(fws):
        s = m.group(0).decode("latin-1", errors="replace")
        if s in seen:
            continue
        seen.add(s)
        strings.append(s)
    STR_PATH.write_text("\n".join(strings), encoding="utf-8")
    print(f"strings: {len(strings)} unique → {STR_PATH.name}")

    urls_set = set()
    urls = []
    for rx in (URL_RE, HOST_RE, PORT_HOST):
        for m in rx.finditer(fws):
            s = m.group(0).decode("latin-1", errors="replace").rstrip(".,;)\"'")
            if s in urls_set:
                continue
            urls_set.add(s)
            urls.append(s)
    URL_PATH.write_text("\n".join(urls), encoding="utf-8")
    print(f"urls/hosts: {len(urls)} → {URL_PATH.name}\n")

    # Show interesting ones
    interesting_kw = ("sanalika", "marhab", "rage-world", "newmarhab", "ragegames",
                      "sfs", "BlueBox", "websocket", "8080", "8443", "snlk")
    print("--- interesting ---")
    for u in urls:
        if any(k.lower() in u.lower() for k in interesting_kw):
            print(f"  {u}")
    print("\n--- first 60 ---")
    for u in urls[:60]:
        print(f"  {u}")
    if len(urls) > 60:
        print(f"  ... +{len(urls) - 60} more")
    return 0


if __name__ == "__main__":
    sys.exit(main())
