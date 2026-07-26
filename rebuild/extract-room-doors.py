from __future__ import annotations
import json, math, re, subprocess, sys, tempfile
from pathlib import Path
from xml.etree import ElementTree as ET

COS = 0.9483255309738488
SIN = 0.31729905027145594
TILE_WIDTH = 18.07
TWIPS_PER_PX = 20.0
FFDEC_CLI = Path(__file__).resolve().parent / 'tools' / 'ffdec' / 'ffdec-cli.exe'

def swf_to_xml(swf_path, xml_path):
    subprocess.run([str(FFDEC_CLI), '-swf2xml', str(swf_path), str(xml_path)], check=True, capture_output=True)

DOOR_NAME_RE = re.compile(r'^d\d+$')

def door_clips_in_sprite(sprite):
    doors = []
    for child in sprite:
        if child.tag != 'subTags':
            continue
        for place in child:
            if place.get('type') != 'PlaceObject2Tag':
                continue
            name = place.get('name') or ''
            if not DOOR_NAME_RE.match(name):
                continue
            tx_twips, ty_twips = 0, 0
            for m in place:
                if m.tag.endswith('matrix'):
                    tx_twips = int(m.get('translateX') or '0')
                    ty_twips = int(m.get('translateY') or '0')
                    break
            doors.append((name, tx_twips / TWIPS_PER_PX, ty_twips / TWIPS_PER_PX))
    return doors

def find_ceiling_sprite(root):
    best = None
    best_count = 0
    for sprite in root.iter('item'):
        if sprite.get('type') != 'DefineSpriteTag':
            continue
        d = door_clips_in_sprite(sprite)
        if len(d) > best_count:
            best_count = len(d)
            best = (sprite, d)
    return best

def pixel_to_tile(sx, sy, xo, yo):
    # Mirror of IsoScene.translateStageCoordsTo3DCoords + translateToGrid.
    # In engine: returned point.x = _loc5_ (uses -dy/sin term first), point.y = _loc4_ (uses dx/cos first).
    # We return (tile_x, tile_y) matching engine semantics.
    dx = xo - sx
    dy = yo - sy
    _loc4 = (dx / COS + dy / SIN) / 2.0       # engine: this becomes point.y -> tile.y
    _loc5 = (-dy / SIN + dx / COS) / -2.0     # engine: this becomes point.x -> tile.x
    return math.floor(_loc5 / TILE_WIDTH), math.floor(_loc4 / TILE_WIDTH)

def main(argv):
    if len(argv) < 4:
        print(f'usage: {argv[0]} <room.swf> <xOrigin> <yOrigin>', file=sys.stderr)
        return 2
    swf = Path(argv[1])
    xo = float(argv[2])
    yo = float(argv[3])
    with tempfile.TemporaryDirectory() as td:
        xml_path = Path(td) / 'swf.xml'
        swf_to_xml(swf, xml_path)
        tree = ET.parse(xml_path)
        root = tree.getroot()
    result = find_ceiling_sprite(root)
    if not result:
        print('no sprite with d* clips found', file=sys.stderr)
        return 1
    sprite, doors = result
    doors.sort(key=lambda r: int(r[0][1:]))
    out = []
    for name, tx, ty in doors:
        tx_tile, ty_tile = pixel_to_tile(tx, ty, xo, yo)
        out.append({'key': name, 'pixel_x': round(tx, 2), 'pixel_y': round(ty, 2), 'tile_x': tx_tile, 'tile_y': ty_tile, 'tile_dir': 1})
    print(f'// ceiling sprite id={sprite.get("spriteId")}, {len(doors)} doors')
    print(json.dumps(out, indent=2))
    return 0

if __name__ == '__main__':
    sys.exit(main(sys.argv))


