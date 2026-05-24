#!/usr/bin/env python3
"""
inventory-swfs.py
-----------------
Decompress + scan the runtime SWFs for URLs, hostnames, and other juicy strings.

  - rebuild/runtime/ml.21.9          (ZWS = LZMA-compressed SWF loader stub)
  - rebuild/runtime/snl.780.swf      (encrypted / wrapped game payload)

Decompresses what we can (ZWS), then dumps:
    rebuild/inventory/<base>.uncompressed.bin
    rebuild/inventory/<base>.strings.txt
    rebuild/inventory/<base>.urls.txt
"""

from __future__ import annotations
import os
import re
import sys
import struct
import lzma
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent
RUNTIME = ROOT / "rebuild" / "runtime"
OUTDIR = ROOT / "rebuild" / "inventory"
OUTDIR.mkdir(parents=True, exist_ok=True)

PRINTABLE_RE = re.compile(rb"[\x20-\x7e]{6,}")

URL_RE = re.compile(
    rb"(?:https?|wss?|ftp)://[A-Za-z0-9._~%/?#@!$&'()*+,;=:\[\]-]+",
    re.IGNORECASE,
)
HOST_RE = re.compile(
    rb"\b(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+"
    rb"(?:com|net|org|io|tv|info|me|gg|sanalika|world|games|local|cloud|app)\b",
    re.IGNORECASE,
)
PORT_RE = re.compile(rb"\b\d{2,5}\b/?\s*BlueBox|:\d{2,5}/[A-Za-z]", re.IGNORECASE)


def decompress_zws(buf: bytes) -> bytes | None:
    """Convert a ZWS (LZMA-compressed) SWF into an FWS (uncompressed) SWF body.

    Adobe SWF LZMA layout:
       [0..2]   ZWS magic
       [3]      SWF version
       [4..7]   uncompressed file length (LE, full SWF size as if uncompressed)
       [8..11]  compressed-data length (LE, bytes that follow the props)
       [12..16] LZMA properties (5 bytes: 0x5D + 4-byte dict size)
       [17..]   raw LZMA-Alone compressed stream (no embedded uncompressed-size)
    """
    if buf[:3] != b"ZWS":
        return None
    version = buf[3]
    file_length = struct.unpack("<I", buf[4:8])[0]
    # buf[8:12] = compressed payload size; we don't need it explicitly.
    props = buf[12:17]
    body = buf[17:]

    # Reconstruct an LZMA-Alone stream: props + 8-byte unknown-size sentinel + body.
    alone = props + struct.pack("<Q", 0xFFFFFFFFFFFFFFFF) + body
    try:
        decompressed = lzma.decompress(alone, format=lzma.FORMAT_ALONE)
    except lzma.LZMAError as e:
        print(f"  ! LZMA decode failed: {e}", file=sys.stderr)
        return None

    # Rebuild as uncompressed FWS: 8-byte signature + uncompressed body.
    fws_header = b"FWS" + bytes([version]) + struct.pack("<I", file_length)
    return fws_header + decompressed


def decompress_cws(buf: bytes) -> bytes | None:
    """Convert a CWS (zlib-compressed) SWF into FWS."""
    if buf[:3] != b"CWS":
        return None
    import zlib

    version = buf[3]
    file_length = struct.unpack("<I", buf[4:8])[0]
    body = zlib.decompress(buf[8:])
    return b"FWS" + bytes([version]) + struct.pack("<I", file_length) + body


def normalize(raw: bytes) -> bytes:
    """Best-effort: turn whatever bytes we have into something string-scannable."""
    if raw[:3] == b"ZWS":
        out = decompress_zws(raw)
        return out if out is not None else raw
    if raw[:3] == b"CWS":
        out = decompress_cws(raw)
        return out if out is not None else raw
    if raw[:3] == b"FWS":
        return raw
    # Unknown / encrypted: try XOR with a few common single-byte keys looking for SWF magic
    candidate_keys = list(range(1, 256))
    for k in candidate_keys:
        if bytes(b ^ k for b in raw[:3]) in (b"FWS", b"CWS", b"ZWS"):
            print(f"  ! looks XOR-keyed with 0x{k:02X}; emitting xored copy")
            return bytes(b ^ k for b in raw)
    print("  ! unknown / encrypted format; scanning raw bytes")
    return raw


def extract_strings(buf: bytes, min_len: int = 6) -> list[str]:
    seen = set()
    out = []
    for m in PRINTABLE_RE.finditer(buf):
        s = m.group(0).decode("latin-1", errors="replace")
        if s in seen:
            continue
        seen.add(s)
        out.append(s)
    return out


def grep_urls(buf: bytes) -> list[str]:
    seen = set()
    out = []
    for m in URL_RE.finditer(buf):
        s = m.group(0).decode("latin-1", errors="replace").rstrip(".,;)\"'")
        if s in seen:
            continue
        seen.add(s)
        out.append(s)
    for m in HOST_RE.finditer(buf):
        s = m.group(0).decode("latin-1", errors="replace")
        if s in seen:
            continue
        seen.add(s)
        out.append(s)
    return out


def process(path: Path) -> None:
    if not path.exists():
        print(f"[skip] {path} not found")
        return
    raw = path.read_bytes()
    print(f"[{path.name}] {len(raw):,} bytes  magic={raw[:3]!r}")
    body = normalize(raw)
    base = OUTDIR / path.name.replace(".", "_")
    (base.with_suffix(".uncompressed.bin")).write_bytes(body)
    strings = extract_strings(body)
    urls = grep_urls(body)
    (base.with_suffix(".strings.txt")).write_text("\n".join(strings), encoding="utf-8")
    (base.with_suffix(".urls.txt")).write_text("\n".join(urls), encoding="utf-8")
    print(f"  uncompressed: {len(body):,} bytes")
    print(f"  unique strings: {len(strings)}")
    print(f"  URLs / hosts:   {len(urls)}")
    if urls:
        print("  --- urls ---")
        for u in urls[:60]:
            print(f"    {u}")
        if len(urls) > 60:
            print(f"    ... +{len(urls) - 60} more")


if __name__ == "__main__":
    process(RUNTIME / "ml.21.9")
    process(RUNTIME / "snl.780.swf")
    print(f"\nWrote: {OUTDIR}")
