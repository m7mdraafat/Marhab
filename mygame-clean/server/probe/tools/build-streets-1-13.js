// Generate wire-format room payloads for streetNN (N=1..13).
//   - Re-projects each door pixel through the iso math; only doors whose
//     re-projection matches the recorded tile are included (the others are
//     listed under skippedDoors with the mismatch).
//   - Uses xOrigin=200, yOrigin=590 (street01 anchor). If a future street is
//     proven to use a different origin, override per-room here.
//   - Grid sized to enclose the door extents with a 10-tile margin, capped
//     at 60×60 for sanity; all cells walkable (CELL.EMPTY=0).
//   - Door targetDir / property.cn are AUTHORED (not in dump); marked
//     explicitly in the output so future captures can override.
//
// Output:  server/probe/data/streets-1-13.json

const fs = require("fs");
const path = require("path");
const room = require("../src/room-data");

const ALL_DOORS_PATH =
  "C:/Users/t-malgharib/OneDrive - Microsoft/Desktop/MyGame/rebuild/inventory/room-doors/all-doors.json";
const OUT_PATH = path.join(__dirname, "..", "data", "streets-1-13.json");

const X_ORIGIN_DEFAULT = 200;
const Y_ORIGIN_DEFAULT = 590;
const MARGIN = 10;
const MAX_DIM = 60;

const all = JSON.parse(fs.readFileSync(ALL_DOORS_PATH, "utf8"));
const streets = [];
for (let i = 1; i <= 13; i++) streets.push("street" + String(i).padStart(2, "0"));

const out = { generatedAt: new Date().toISOString(), rooms: {} };

for (const key of streets) {
  const rec = all[key];
  if (!rec) {
    out.rooms[key] = { present: false, reason: "no entry in all-doors.json" };
    continue;
  }

  const xOrigin = X_ORIGIN_DEFAULT;
  const yOrigin = Y_ORIGIN_DEFAULT;

  const usedDoors = [];
  const skippedDoors = [];
  for (const d of rec.doors) {
    const t = room.pixelToTile(d.pixel_x, d.pixel_y, xOrigin, yOrigin);
    if (t.x === d.tile_x && t.y === d.tile_y) {
      usedDoors.push(d);
    } else {
      skippedDoors.push({ ...d, computed_tile: t });
    }
  }

  // Grid extent from positive door tiles. (Negative-tile doors like
  // street01.d8 are clickable ceiling decorations, not walk targets.)
  let maxX = 0, maxY = 0;
  for (const d of usedDoors) {
    if (d.tile_x > maxX) maxX = d.tile_x;
    if (d.tile_y > maxY) maxY = d.tile_y;
  }
  const width = Math.min(MAX_DIM, Math.max(20, maxX + MARGIN));
  const height = Math.min(MAX_DIM, Math.max(20, maxY + MARGIN));

  const gridCells = room.makeWalkableGrid(width, height);
  const gridB64 = room.encodeGrid(width, height, gridCells);
  const mapEntries = [];
  const bots = [];

  // Default door property: PassageProperty routing to next-numbered street.
  // Authored, not recovered — flag in metadata.
  const doorObjects = usedDoors.map(d => ({
    key: d.key,
    targetX: d.tile_x,
    targetY: d.tile_y,
    targetDir: key === "street01" && d.key === "d1" ? 1 : 4, // authored default; street01 spawn direction is explicit
    property: { cn: "PassageProperty", roomKey: nextStreet(key) }
  }));

  // Pick a door whose target tile is inside the grid as defaultDoorKey
  // (so the avatar spawns at a valid walkable cell).
  const inside = doorObjects.filter(d =>
    d.targetX >= 0 && d.targetX < width && d.targetY >= 0 && d.targetY < height);
  const defaultDoorKey = inside.length ? inside[0].key : null;

  out.rooms[key] = {
    present: true,
    swf: rec.swf,
    ceilingSpriteId: rec.ceiling_sprite_id,
    xOrigin,
    yOrigin,
    grid: { width, height, base64: gridB64 },
    doors: doorObjects,
    skippedDoors,
    defaultDoorKey,
    mapEntries,
    mapBase64: room.encodeMapXml(mapEntries, { xOrigin, yOrigin }),
    bots,
    authoredFields: [
      "doors[*].targetDir",
      "doors[*].property",
      "grid.width",
      "grid.height"
    ],
    unrecovered: [
      "real production map entries (chairs, stuff, sound, cinema, billboard, exhibition, pool, farm, floor, youtube, cencor)",
      "real production bots (positions, definitions, movement patterns)",
      "real production chair reserved-grid offsets"
    ],
    unrecoveredReason:
      "No DefineBinaryData in room SWF; no entries in rebuild/inventory; no captured server payloads (SmartFox traffic is app-layer encrypted). The RoomDesigner extension edits owned-room furniture only and does not author public street grid/doors/bots/spawn.",
    notes: skippedDoors.length
      ? `${skippedDoors.length} door(s) did not round-trip with xOrigin=${xOrigin}, yOrigin=${yOrigin}; may use a different iso origin`
      : null
  };
}

function nextStreet(key) {
  const n = parseInt(key.replace("street", ""), 10);
  return "street" + String(n + 1).padStart(2, "0");
}

fs.mkdirSync(path.dirname(OUT_PATH), { recursive: true });
fs.writeFileSync(OUT_PATH, JSON.stringify(out, null, 2), "utf8");

// Console summary
console.log(`wrote ${OUT_PATH}`);
console.log("");
console.log("room       present  doors  used  skipped  grid       defaultDoor");
console.log("---------- -------  -----  ----  -------  ---------  -----------");
for (const key of streets) {
  const r = out.rooms[key];
  if (!r.present) {
    console.log(`${key.padEnd(10)}   NO     -      -     -        -          -`);
    continue;
  }
  console.log(
    `${key.padEnd(10)}   yes    ${String(r.doors.length + r.skippedDoors.length).padStart(2)}    ${String(r.doors.length).padStart(2)}    ${String(r.skippedDoors.length).padStart(3)}      ${String(r.grid.width).padStart(2)}x${String(r.grid.height).padEnd(2)}      ${r.defaultDoorKey || "-"}`
  );
}
