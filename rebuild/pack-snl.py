#!/usr/bin/env python3
"""
pack-snl.py — produce an encrypted snl.780.swf from a modified inner SWF
(typically the decompressed FWS we extracted via inspect-snl.py, after editing
host strings).

Pipeline:
   patched_fws.swf   (FWS, uncompressed; same byte length as snl_780_uncompressed.swf)
   → LZMA-compress to ZWS
   → custom-encrypt to snl.780.swf format

We REUSE the magic1/magic2/session_key/q9dh from the original snl.780.swf so
that the AS3 loader's integrity checks pass exactly as before. Only the body
and the two checksum fields change.

Usage:
    python pack-snl.py [patched.swf]
        patched.swf defaults to rebuild/inventory/snl_780_uncompressed.swf
    output → rebuild/runtime/snl.780.swf.repacked
"""
from __future__ import annotations
import struct
import sys
import lzma
from pathlib import Path

# Re-use everything from the decryptor
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
from importlib import import_module
_dec = import_module("decrypt-snl".replace("-", "_")) if False else None  # filename has a dash; load directly

import importlib.util
import subprocess
import tempfile

_spec = importlib.util.spec_from_file_location("decrypt_snl", HERE / "decrypt-snl.py")
_dec = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(_dec)


ROOT = HERE.parent
RUNTIME = ROOT / "rebuild" / "runtime"
INVENTORY = ROOT / "rebuild" / "inventory"
SRC_ENCRYPTED = RUNTIME / "snl.780.swf"
DEFAULT_INPUT = INVENTORY / "snl_780_uncompressed.swf"
OUTPUT = RUNTIME / "snl.780.swf.repacked"
FFDEC_CLI = ROOT / "rebuild" / "tools" / "ffdec" / "ffdec-cli.exe"


def lzma_compress_to_zws(fws: bytes) -> bytes:
    """Recompress an FWS SWF into a ZWS SWF using FFDec (AIR-compatible LZMA).

    Python's stdlib `lzma` and Adobe AIR's SWF LZMA decoder are not fully
    compatible at the byte level. Shelling out to FFDec produces ZWS bytes
    that are byte-identical to the original Sanalika encoder.
    """
    assert fws[:3] == b"FWS", f"expected FWS, got {fws[:3]!r}"
    if not FFDEC_CLI.exists():
        raise RuntimeError(f"FFDec not found at {FFDEC_CLI}; run setup step")
    with tempfile.TemporaryDirectory() as td:
        td = Path(td)
        in_path = td / "in.swf"
        out_path = td / "out.swf"
        in_path.write_bytes(fws)
        # ffdec-cli.exe -compress lzma <in> <out>   (this arg ORDER works,
        # despite the help text showing "-compress <in> <out> [lzma|zlib]")
        result = subprocess.run(
            [str(FFDEC_CLI), "-compress", "lzma", str(in_path), str(out_path)],
            capture_output=True,
            text=True,
            timeout=120,
        )
        if result.returncode != 0:
            raise RuntimeError(f"FFDec compress failed: {result.stderr}")
        zws = out_path.read_bytes()
    assert zws[:3] == b"ZWS", f"FFDec output is not ZWS: {zws[:3]!r}"
    return zws


def encrypt_body(plain: bytes, q9dh: int, session_key16: bytes) -> bytes:
    """Inverse of decrypt_body(): reverse, XOR cycle, then ADD keystream + pos."""
    base_key = _dec.mkb5bzk()              # 16 bytes
    aynhog2 = base_key + session_key16     # 32 bytes
    n = len(plain)
    keystream = _dec.sodhvcr_(aynhog2, n)
    buf = bytearray(plain)
    # inverse step 3: reverse first
    buf.reverse()
    # inverse step 2: XOR cycle (self-inverse)
    m = len(aynhog2)
    for i in range(n):
        buf[i] ^= aynhog2[i % m]
    # inverse step 1: ADD keystream + position
    for i in range(n):
        buf[i] = (buf[i] + keystream[i] + (i & 0xFF)) & 0xFF
    return bytes(buf)


def encode_session_key(magic1: int, magic2: int, plain_key: bytes) -> bytes:
    """Inverse of decode_session_key() -- same XOR operation, self-inverse."""
    return _dec.decode_session_key(magic1, magic2, plain_key)


def main() -> int:
    inp = Path(sys.argv[1]) if len(sys.argv) > 1 else DEFAULT_INPUT
    if not inp.exists():
        print(f"missing input: {inp}", file=sys.stderr)
        return 2
    if not SRC_ENCRYPTED.exists():
        print(f"missing reference: {SRC_ENCRYPTED}", file=sys.stderr)
        return 2

    fws = inp.read_bytes()
    print(f"input FWS : {inp.name}  {len(fws):,} bytes  magic={fws[:3]!r}")
    if fws[:3] != b"FWS":
        print("  WARN: input is not raw FWS; compress step assumes uncompressed SWF", file=sys.stderr)

    # Reuse the original file's header (magic, q9dh, encoded session key) so the
    # loader's integrity checks pass without us touching them.
    src = SRC_ENCRYPTED.read_bytes()
    magic1, magic2 = struct.unpack("<II", src[0:8])
    q9dh = struct.unpack("<I", src[8:12])[0]
    original_payload_len = struct.unpack("<I", src[12:16])[0]
    encoded_session = src[24:24 + 16]
    plain_session = _dec.decode_session_key(magic1, magic2, encoded_session)

    print(f"reuse hdr : magic1=0x{magic1:08X} magic2=0x{magic2:08X} "
          f"orig_payload={original_payload_len:,} session_key={plain_session.hex()}")

    # Recompress patched FWS → ZWS using FFDec (AIR-compatible LZMA).
    inner_swf = lzma_compress_to_zws(fws)
    print(f"inner SWF : {inner_swf[:3]!r} recompressed via FFDec ({len(inner_swf):,} bytes)")

    # Encrypt the (compressed) inner SWF
    encrypted_body = encrypt_body(inner_swf, q9dh, plain_session)
    payload_len = len(encrypted_body)
    enc_sum = _dec.g2v__0(encrypted_body)
    dec_sum = _dec.ce50z(inner_swf)
    print(f"checksums : enc=0x{enc_sum:08X}  dec=0x{dec_sum:08X}  payload_len={payload_len:,}")

    # Build output: 64-byte header + encrypted body
    header = bytearray(64)
    struct.pack_into("<II", header, 0, magic1, magic2)
    struct.pack_into("<I", header, 8, q9dh)
    struct.pack_into("<I", header, 12, payload_len)
    struct.pack_into("<I", header, 16, enc_sum)
    struct.pack_into("<I", header, 20, dec_sum)
    header[24:24 + 16] = encoded_session  # already-encoded session bytes
    # bytes 40..63 are unused/padding -- keep zeroes (original had non-zero noise; not validated)

    out = bytes(header) + encrypted_body
    OUTPUT.write_bytes(out)
    print(f"\nwrote {OUTPUT}  ({len(out):,} bytes; original was {len(src):,})")

    # Sanity round-trip: decrypt our output to confirm
    print("\n--- round-trip check ---")
    rt_buf = out
    rt_payload = rt_buf[64:]
    rt_enc_sum = _dec.g2v__0(rt_payload)
    rt_session = _dec.decode_session_key(magic1, magic2, rt_buf[24:40])
    rt_inner = _dec.decrypt_body(rt_payload, q9dh, rt_session)
    rt_dec_sum = _dec.ce50z(rt_inner)
    rt_first = rt_inner[:4]
    print(f"  encrypted-body checksum matches: {rt_enc_sum == enc_sum}")
    print(f"  decrypted-body checksum matches: {rt_dec_sum == dec_sum}")
    print(f"  first 4 bytes of decrypted body: {rt_first!r}  (FWS / ZWS / CWS)")
    if rt_first[:3] not in (b"FWS", b"ZWS", b"CWS"):
        print("  WARN: round-trip produced non-SWF magic!", file=sys.stderr)
        return 3
    print("  OK: round-trip clean")
    return 0


if __name__ == "__main__":
    sys.exit(main())
