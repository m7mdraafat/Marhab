// Authoritative street01 room data.
//
// Anchors (from /memories/repo/air-room-metadata.md, do not change):
//   - xOrigin=200, yOrigin=590   (iso projection origin in pixels)
//   - tileWidth=tileHeight=18.07 (GridTileSize)
//   - Door pixel positions extracted from st01.swf ceiling sprite (id=214),
//     PlaceObject2 matrices (rebuild/inventory/room-doors/all-doors.json).
//
// Open questions encoded as TODO so a future pass can refine without losing
// the proven anchors (see /memories/repo/air-room-metadata.md "Remaining unknowns"):
//   - targetDir per door is a designer choice (1..8 enum). Assigned here as
//     a reasonable inward-facing direction; refine if/when captured.
//   - property.cn per door is a routing choice; all set to PassageProperty
//     with a placeholder roomKey, which is what street→street walks use.

const ROOM_KEY = "street01";
const X_ORIGIN = 200;
const Y_ORIGIN = 590;

// Real door pixels from st01.swf ceiling layer.
// targetDir and property are AUTHORED (no recovered source); pixels and tile_x/y are PROVEN.
const DOORS = [
  { key: "d1",  pixel_x: 424.55, pixel_y: 221.10, tile_x: 38, tile_y: 25, dir: 1, to: "street02" },
  { key: "d2",  pixel_x: 168.45, pixel_y: 121.50, tile_x: 39, tile_y: 41, dir: 5, to: "street03" },
  { key: "d3",  pixel_x: 514.95, pixel_y: 229.00, tile_x: 40, tile_y: 22, dir: 4, to: "street04" },
  { key: "d4",  pixel_x: 722.45, pixel_y: 155.50, tile_x: 53, tile_y: 22, dir: 4, to: "street05" },
  { key: "d5",  pixel_x:  50.00, pixel_y: 472.95, tile_x:  5, tile_y: 14, dir: 1, to: "street06" },
  { key: "d6",  pixel_x: 762.95, pixel_y: 226.50, tile_x: 48, tile_y: 15, dir: 4, to: "street07" },
  { key: "d7",  pixel_x:  37.65, pixel_y: 156.30, tile_x: 33, tile_y: 42, dir: 5, to: "street08" },
  // d8 projects to a negative tile (tile_y=-6); decorative/ceiling-only door, leave as-is.
  { key: "d8",  pixel_x: 790.45, pixel_y: 455.90, tile_x: 28, tile_y: -6, dir: 3, to: "street09" },
  { key: "d9",  pixel_x:  52.15, pixel_y:  93.95, tile_x: 38, tile_y: 47, dir: 5, to: "street10" },
  { key: "d10", pixel_x: 346.05, pixel_y: 303.50, tile_x: 29, tile_y: 20, dir: 4, to: "street11" }
];

// Grid dimensions chosen to comfortably enclose all positive-tile doors
// (max tile_x=53 on d4, max tile_y=47 on d9). 60×60 leaves walk margin.
// All cells walkable (CELL.EMPTY=0); door props are routed via the doors
// array, not the grid.
const GRID_WIDTH = 60;
const GRID_HEIGHT = 60;

// Default spawn = d1's target tile + dir (matches the captured marhab-room
// walk session in docs/captures/marhab-room-capture-2026-05-28.md).
const DEFAULT_DOOR_KEY = "d1";

module.exports = {
  ROOM_KEY,
  X_ORIGIN,
  Y_ORIGIN,
  DOORS,
  GRID_WIDTH,
  GRID_HEIGHT,
  DEFAULT_DOOR_KEY
};
