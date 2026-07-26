// Room wire-format encoders.
//
// Schemas extracted from snl_780_src decompile (see /memories/repo/air-room-metadata.md):
//   - GridModel.load/data  → Base64( BE int32 W | BE int32 H | int8[W*H] row-major )
//   - RoomModel.set map    → Base64-XML, root contains typed entries
//   - DoorModel.load       → JSON array [{ key, targetX, targetY, targetDir, property:{cn,...} }]

const TILE_PX = 18.07; // GridTileSize
const ISO_A = 0.9483255309738488;
const ISO_B = 0.31729905027145594;

// CellType (snl_780_src com.oyunstudyosu.engine.core.CellType)
const CELL = {
  EMPTY: 0,           // default walkable
  WALK_ONLY: -1,
  DISABLED: 3,        // set by MapEntry.init for non-FLOOR entries
  DIAMOND: 4,
  ADMIN: 5,
  TARGET: 6,
  FISH: 7,
  SANALIKAX: 8,
  SHORTCUT: 10,
  NPC: 11,
  STAGE: 12,
  FURNITURE_ONLY: 13
};

// Direction enum 1..8 (GridModel.directions). dir-1 indexes this vector.
const DIRECTIONS = [
  [1, 0],   // 1
  [1, -1],  // 2
  [0, -1],  // 3
  [-1, -1], // 4
  [-1, 0],  // 5
  [-1, 1],  // 6
  [0, 1],   // 7
  [1, 1]    // 8
];

/** Encode a grid as the client's GridModel expects.
 *  cells: int8 array of length width*height (row-major, y outer / x inner). */
function encodeGrid(width, height, cells) {
  if (cells.length !== width * height) {
    throw new Error(`grid size mismatch: ${cells.length} vs ${width * height}`);
  }
  const buf = Buffer.alloc(4 + 4 + width * height);
  buf.writeInt32BE(width, 0);
  buf.writeInt32BE(height, 4);
  for (let i = 0; i < cells.length; i++) buf.writeInt8(cells[i], 8 + i);
  return buf.toString("base64");
}

/** Fill an all-walkable grid of given size. */
function makeWalkableGrid(width, height) {
  return new Array(width * height).fill(CELL.EMPTY);
}

/** Encode a list of MapEntry objects as Base64-XML.
 *  Each entry: { type:"box"|"chair"|..., attrs:{x,y,z,w,h,d,def,dir,id,enabled,...}, property?:string, chairs?:[{type,x,z,dir}] } */
function encodeMapXml(entries, options = {}) {
  const rootAttrs = Object.entries({ xOrigin: options.xOrigin, yOrigin: options.yOrigin })
    .filter(([, value]) => value !== undefined && value !== null)
    .map(([key, value]) => ` ${key}="${escapeAttr(String(value))}"`)
    .join("");
  const parts = [`<map${rootAttrs}>`];
  for (const e of entries) parts.push(serializeEntry(e));
  parts.push('</map>');
  return Buffer.from(parts.join(""), "utf8").toString("base64");
}

function serializeEntry(e) {
  const attrs = Object.entries(e.attrs || {})
    .filter(([, v]) => v !== undefined && v !== null)
    .map(([k, v]) => ` ${k}="${escapeAttr(String(v))}"`)
    .join("");
  const hasChildren = (e.chairs && e.chairs.length) || e.property != null;
  if (!hasChildren) return `<${e.type}${attrs}/>`;
  const inner = [];
  if (e.chairs && e.chairs.length) {
    inner.push('<chairs>');
    for (const c of e.chairs) {
      inner.push(`<${c.type || 'chair'} x="${c.x}" z="${c.z}" dir="${c.dir}"/>`);
    }
    inner.push('</chairs>');
  }
  if (e.property != null) inner.push(escapeText(e.property));
  return `<${e.type}${attrs}>${inner.join("")}</${e.type}>`;
}

function escapeAttr(s) {
  return s.replace(/&/g, "&amp;").replace(/"/g, "&quot;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
}
function escapeText(s) {
  return s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
}

/** Build the door array DoorModel.load expects.
 *  doors: [{ key, targetX, targetY, targetDir, property:{cn,...rest} }] */
function buildDoorsJson(doors) {
  return JSON.stringify(doors.map(d => ({
    key: d.key,
    targetX: d.targetX,
    targetY: d.targetY,
    targetDir: d.targetDir,
    property: d.property
  })));
}

/** Pixel → tile, matching the iso projection used by the room SWFs.
 *  xOrigin/yOrigin are the room's iso origin in pixels (200,590 for street01). */
function pixelToTile(px, py, xOrigin, yOrigin) {
  const dx = xOrigin - px;
  const dy = yOrigin - py;
  const y3d = (dx / ISO_A + dy / ISO_B) / 2;
  const x3d = (-dy / ISO_B + dx / ISO_A) / -2;
  return { x: Math.floor(x3d / TILE_PX), y: Math.floor(y3d / TILE_PX) };
}

module.exports = {
  TILE_PX,
  ISO_A,
  ISO_B,
  CELL,
  DIRECTIONS,
  encodeGrid,
  makeWalkableGrid,
  encodeMapXml,
  buildDoorsJson,
  pixelToTile
};
