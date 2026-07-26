"""
Batch-run extract-room-doors.py against every *.swf in rooms/ and produce
a single CSV + JSON report with door tile coords for each room.

Each room uses a default xOrigin/yOrigin calibration; the actual tile coords
should be re-extracted per-room after each room's xOrigin/yOrigin is tuned
visually. This batch run is useful for:
  - finding which rooms have how many doors
  - seeing the pixel positions for each door clip
  - getting a starting point for per-room PlaceCatalog entries

Output:
  rebuild/inventory/room-doors/all-doors.json  (master JSON)
  rebuild/inventory/room-doors/all-doors.csv   (flat CSV for quick scanning)
"""

from __future__ import annotations
import csv, json, math, re, subprocess, sys, tempfile
from pathlib import Path
from xml.etree import ElementTree as ET

COS = 0.9483255309738488
SIN = 0.31729905027145594
TILE_WIDTH = 18.07
TWIPS_PER_PX = 20.0
FFDEC_CLI = Path(__file__).resolve().parent / "tools" / "ffdec" / "ffdec-cli.exe"

DEFAULT_X_ORIGIN = 200
DEFAULT_Y_ORIGIN = 590

ROOMS_DIR = Path("c:/Users/t-malgharib/OneDrive - Microsoft/Desktop/MyGame/assets/cdn-mirror/global/dynamic/rooms")
OUT_DIR   = Path("c:/Users/t-malgharib/OneDrive - Microsoft/Desktop/MyGame/rebuild/inventory/room-doors")
OUT_DIR.mkdir(parents=True, exist_ok=True)

VF_PATH = Path("c:/Users/t-malgharib/OneDrive - Microsoft/Desktop/MyGame/assets/cdn-mirror/global/static/data/vf.403")

DOOR_NAME_RE = re.compile(r"^d\d+$")


def vf_room_keys():
    """Parse vf.403 to map filename (no extension) -> roomKey."""
    import base64
    decoded = base64.b64decode(VF_PATH.read_text()).decode("utf-8", errors="replace")
    out = {}
    for token in decoded.split("|"):
        if "=rooms/" not in token:
            continue
        key, path = token.split("=", 1)
        filename = path.split("/", 1)[1]  # strip "rooms/"
        out[filename] = key
    return out


def door_clips_in_sprite(sprite):
    doors = []
    for child in sprite:
        if child.tag != "subTags":
            continue
        for place in child:
            if place.get("type") != "PlaceObject2Tag":
                continue
            name = place.get("name") or ""
            if not DOOR_NAME_RE.match(name):
                continue
            tx, ty = 0, 0
            for m in place:
                if m.tag.endswith("matrix"):
                    tx = int(m.get("translateX") or "0")
                    ty = int(m.get("translateY") or "0")
                    break
            doors.append((name, tx / TWIPS_PER_PX, ty / TWIPS_PER_PX))
    return doors


def find_ceiling(root):
    best, best_count = None, 0
    for sprite in root.iter("item"):
        if sprite.get("type") != "DefineSpriteTag":
            continue
        d = door_clips_in_sprite(sprite)
        if len(d) > best_count:
            best_count = len(d)
            best = (sprite, d)
    return best


def pixel_to_tile(sx, sy, xo, yo):
    dx, dy = xo - sx, yo - sy
    loc4 = (dx / COS + dy / SIN) / 2.0
    loc5 = (-dy / SIN + dx / COS) / -2.0
    return math.floor(loc5 / TILE_WIDTH), math.floor(loc4 / TILE_WIDTH)


def extract_one(swf_path):
    with tempfile.TemporaryDirectory() as td:
        xml_path = Path(td) / "swf.xml"
        try:
            subprocess.run(
                [str(FFDEC_CLI), "-swf2xml", str(swf_path), str(xml_path)],
                check=True, capture_output=True, timeout=60,
            )
        except (subprocess.CalledProcessError, subprocess.TimeoutExpired) as exc:
            return {"error": f"ffdec failed: {exc}"}
        try:
            tree = ET.parse(xml_path)
        except ET.ParseError as exc:
            return {"error": f"xml parse: {exc}"}
    root = tree.getroot()
    found = find_ceiling(root)
    if not found:
        return {"doors": []}
    sprite, doors = found
    doors.sort(key=lambda r: int(r[0][1:]))
    out_doors = []
    for name, tx, ty in doors:
        tile_x, tile_y = pixel_to_tile(tx, ty, DEFAULT_X_ORIGIN, DEFAULT_Y_ORIGIN)
        out_doors.append({
            "key": name,
            "pixel_x": round(tx, 2),
            "pixel_y": round(ty, 2),
            "tile_x": tile_x,
            "tile_y": tile_y,
        })
    return {"ceiling_sprite_id": sprite.get("spriteId"), "doors": out_doors}


def main():
    keys = vf_room_keys()
    swfs = sorted(ROOMS_DIR.glob("*.swf"))
    print(f"scanning {len(swfs)} room SWFs against {len(keys)} vf.403 keys")
    results = {}
    flat_rows = []
    for i, swf in enumerate(swfs, 1):
        filename = swf.name
        stem = swf.stem
        room_key = keys.get(stem) or keys.get(filename) or stem
        print(f"[{i:3}/{len(swfs)}] {filename} -> {room_key}")
        result = extract_one(swf)
        result["roomKey"] = room_key
        result["swf"] = filename
        results[room_key] = result
        for d in result.get("doors", []):
            flat_rows.append({
                "roomKey": room_key,
                "swf": filename,
                **d,
                "xOrigin": DEFAULT_X_ORIGIN,
                "yOrigin": DEFAULT_Y_ORIGIN,
            })
    out_json = OUT_DIR / "all-doors.json"
    out_json.write_text(json.dumps(results, indent=2, ensure_ascii=False), encoding="utf-8")
    out_csv = OUT_DIR / "all-doors.csv"
    with out_csv.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=["roomKey", "swf", "key", "pixel_x", "pixel_y", "tile_x", "tile_y", "xOrigin", "yOrigin"])
        writer.writeheader()
        for row in flat_rows:
            writer.writerow(row)
    # Summary
    rooms_with_doors = sum(1 for r in results.values() if r.get("doors"))
    total_doors = sum(len(r.get("doors", [])) for r in results.values())
    print()
    print(f"wrote {out_json}")
    print(f"wrote {out_csv}")
    print(f"summary: {rooms_with_doors}/{len(swfs)} rooms have doors, {total_doors} doors total")


if __name__ == "__main__":
    main()
