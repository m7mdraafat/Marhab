#!/usr/bin/env python3
"""
decrypt-snl.py — decrypt rebuild/runtime/snl.780.swf using the algorithm
extracted from ml.21.9's extensions.MainLoader (uqpsdr_3 / oxyub63k).

This is a faithful Python port of:
    extensions.MainLoader.uqpsdr_3          (entry)
    extensions.MainLoader.oxyub63k          (decrypt step)
    extensions.MainLoader.mkb5bzk           (derive 16-byte base key)
    extensions.MainLoader.sodhvcr_          (keystream generator)
    extensions.MainLoader.fiai8             (SHA-like block)
    extensions.MainLoader.g2v__0            (encrypted-body checksum)
    extensions.MainLoader.ce50z             (decrypted-body checksum)
    extensions.MainLoader.qxzd1             (decrypted SWF header sanity)

Encrypted file layout (re-derived from MainLoader.uqpsdr_3 constants):
  off 0  : u32   magic1
  off 4  : u32   magic2          ; (magic1 ^ magic2) compared to 1838010061 (advisory)
  off 8  : u32   q9dh            ; unused for the actual decrypt
  off 12 : u32   payload_len
  off 16 : u32   checksum_enc    ; g2v__0(encrypted_body)
  off 20 : u32   checksum_dec    ; ce50z(decrypted_body)
  off 24 : 16 bytes session_key  (XOR-encoded with key from magic1+magic2)
  off 64 : payload_len bytes encrypted body
"""
from __future__ import annotations
import struct
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent
SRC = ROOT / "rebuild" / "runtime" / "snl.780.swf"
DST = ROOT / "rebuild" / "inventory" / "snl_780_decrypted.swf"

MAGIC_XOR = 0x6D8C8C0D  # 1838010061
SHA_LIKE_IV = [
    0x6A09E667, 0xBB67AE85, 0x3C6EF372, 0xA54FF53A,
    0x510E527F, 0x9B05688C, 0x1F83D9AB, 0x5BE0CD19,
]
HARDCODED_BASE_KEY = bytes([84, 55, 188, 219, 26, 138, 171, 6,
                            223, 154, 79, 220, 32, 74, 82, 117])


def mask32(x: int) -> int:
    return x & 0xFFFFFFFF


def rotl32(x: int, n: int) -> int:
    n &= 31
    x &= 0xFFFFFFFF
    return ((x << n) | (x >> (32 - n))) & 0xFFFFFFFF


def mkb5bzk() -> bytes:
    """Derive 16-byte base key by XORing the hardcoded array with (0xC6 + i*9) & 0xFF."""
    return bytes(
        (HARDCODED_BASE_KEY[i] ^ ((0xC6 + i * 9) & 0xFF)) & 0xFF
        for i in range(len(HARDCODED_BASE_KEY))
    )


def fiai8(key_material: bytes, counter: int) -> bytes:
    """SHA-like 32-byte mixer: 8 uint32 state, IV from SHA-256 constants."""
    state = list(SHA_LIKE_IV)
    n = len(key_material)
    for i in range(n):
        # state[i%8] = (state[i%8] + key[i] * (i+1) ^ state[(i+1)%8] >>> 3) & 0xFFFFFFFF
        # AS3 precedence: shift > add > xor, but key[i]*(i+1) is grouped first
        right = (state[(i + 1) % 8] >> 3) & 0xFFFFFFFF
        added = (state[i % 8] + key_material[i] * (i + 1)) & 0xFFFFFFFF
        state[i % 8] = (added ^ right) & 0xFFFFFFFF
    state[0] = (state[0] ^ counter) & 0xFFFFFFFF
    for i in range(64):
        a = state[i % 8]
        rot = ((a << 5) | (a >> 27)) & 0xFFFFFFFF
        state[i % 8] = (rot ^ state[(i + 3) % 8]) & 0xFFFFFFFF
    out = bytearray()
    for w in state:
        out.append((w >> 24) & 0xFF)
        out.append((w >> 16) & 0xFF)
        out.append((w >> 8) & 0xFF)
        out.append(w & 0xFF)
    return bytes(out)


def sodhvcr_(key_material: bytes, want_len: int) -> bytes:
    """Generate want_len bytes of keystream from key_material.

    NOTE faithful port: `counter` increments per byte consumed, not per fiai8 block.
    """
    out = bytearray()
    counter = 0
    while len(out) < want_len:
        block = fiai8(key_material, counter)
        for b in block:
            if len(out) >= want_len:
                break
            out.append(b)
            counter += 1
    return bytes(out)


def g2v__0(buf: bytes) -> int:
    """Encrypted-body checksum (1-bit rotate-left per byte)."""
    pa = [90, 255, 3, 1, 31, 24, 8]
    pb = (pa[0] << 24) | (pa[0] << 16) | (pa[0] << 8) | pa[0]
    for d in range(0, len(buf), pa[3]):
        pe = buf[d] & pa[1]
        pf = d & pa[2]
        pg = pf << pa[2]      # (d & 3) << 3
        ph = (pe << pg) & 0xFFFFFFFF
        pb = (pb ^ ph) & 0xFFFFFFFF
        pb = ((pb << pa[3]) | (pb >> pa[4])) & 0xFFFFFFFF
    return pb


def ce50z(buf: bytes) -> int:
    """Decrypted-body checksum (3-bit rotate-left per byte, step 1)."""
    qa = [165, 255, 3, 3, 29, 32, 0]
    qb = (qa[0] << 24) | (qa[0] << 16) | (qa[0] << 8) | qa[0]
    step = (qa[3] ^ 2) | 0   # 1
    for d in range(0, len(buf), step):
        qe = buf[d] & qa[1]
        qf = d & qa[2]
        qg = qf << qa[2]
        qh = (qe << qg) & 0xFFFFFFFF
        qb = (qb ^ qh) & 0xFFFFFFFF
        qb = ((qb << qa[3]) | (qb >> qa[4])) & 0xFFFFFFFF
    return qb


def decode_session_key(magic1: int, magic2: int, encoded_key: bytes) -> bytes:
    """Reverse the per-byte XOR mask applied to the 32-byte session key."""
    kb = [
        magic1 & 0xFF, (magic1 >> 8) & 0xFF, (magic1 >> 16) & 0xFF, (magic1 >> 24) & 0xFF,
        magic2 & 0xFF, (magic2 >> 8) & 0xFF, (magic2 >> 16) & 0xFF, (magic2 >> 24) & 0xFF,
    ]
    kc = 45 << 1   # 90
    out = bytearray(encoded_key)
    for d in range(len(out)):
        # ke = (kb[d&3] * (d+1) ^ kb[4 + d&3] + d ^ kc) & 0xFF
        # AS3 precedence: * > + > & > ^   so:
        # ke = (kb[d&3] * (d+1)) ^ (kb[4+(d&3)] + d) ^ kc, then & 0xFF
        a = (kb[d & 3] * (d + 1)) & 0xFFFFFFFF
        b = (kb[4 + (d & 3)] + d) & 0xFFFFFFFF
        ke = (a ^ b ^ kc) & 0xFF
        out[d] ^= ke
    return bytes(out)


def decrypt_body(body: bytes, q9dh: int, session_key32: bytes) -> bytes:
    """Reverse oxyub63k(): subtract keystream+pos, XOR with key cycle, then reverse."""
    base_key = mkb5bzk()                        # 16 bytes
    aynhog2 = base_key + session_key32          # 48 bytes
    n = len(body)
    dya68_ = sodhvcr_(aynhog2, n)               # n bytes of keystream
    buf = bytearray(body)
    # step 1: subtract keystream + position
    for i in range(n):
        buf[i] = (buf[i] - dya68_[i] - (i & 0xFF)) & 0xFF
    # step 2: XOR with aynhog2 (cycle)
    m = len(aynhog2)
    for i in range(n):
        buf[i] ^= aynhog2[i % m]
    # step 3: reverse
    buf.reverse()
    return bytes(buf)


def main() -> int:
    raw = SRC.read_bytes()
    print(f"input : {SRC.name}  {len(raw):,} bytes")
    if len(raw) < 96:
        print("  too small", file=sys.stderr)
        return 2

    magic1, magic2 = struct.unpack("<II", raw[0:8])
    xor = (magic1 ^ magic2) & 0xFFFFFFFF
    folded_xor = ((xor >> 16) ^ (xor & 0xFFFF)) & 0xFFFF
    folded_expected = ((MAGIC_XOR >> 16) ^ (MAGIC_XOR & 0xFFFF)) & 0xFFFF
    print(f"  magic1=0x{magic1:08X}  magic2=0x{magic2:08X}  xor=0x{xor:08X}  folded=0x{folded_xor:04X}")
    print(f"  magic xor    : {'OK' if xor == MAGIC_XOR else f'advisory mismatch (expected 0x{MAGIC_XOR:08X})'}")
    print(f"  folded match : {'OK' if folded_xor == folded_expected else f'advisory mismatch (expected 0x{folded_expected:04X})'}")

    q9dh = struct.unpack("<I", raw[8:12])[0]
    payload_len = struct.unpack("<I", raw[12:16])[0]
    expected_enc_sum = struct.unpack("<I", raw[16:20])[0]
    expected_dec_sum = struct.unpack("<I", raw[20:24])[0]
    encoded_session = raw[24:24 + 16]
    encrypted_body = raw[64:64 + payload_len]

    print(f"  payload={payload_len:,} q9dh={q9dh} session_key_enc={encoded_session.hex()}")
    actual_enc_sum = g2v__0(encrypted_body)
    print(f"  enc checksum: got 0x{actual_enc_sum:08X}  expected 0x{expected_enc_sum:08X}  "
          f"{'OK' if actual_enc_sum == expected_enc_sum else 'MISMATCH'}")

    session_key = decode_session_key(magic1, magic2, encoded_session)
    print(f"  session key (decoded): {session_key.hex()}")

    decrypted = decrypt_body(encrypted_body, q9dh, session_key)
    actual_dec_sum = ce50z(decrypted)
    print(f"  dec checksum: got 0x{actual_dec_sum:08X}  expected 0x{expected_dec_sum:08X}  "
          f"{'OK' if actual_dec_sum == expected_dec_sum else 'MISMATCH'}")

    print(f"  first 16 bytes of decrypted: {decrypted[:16].hex()}  "
          f"ascii={decrypted[:4]!r}")
    DST.parent.mkdir(parents=True, exist_ok=True)
    DST.write_bytes(decrypted)
    print(f"\nwrote {DST}  ({len(decrypted):,} bytes)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
