// Roundtrip verification: feed our encoded payloads through faithful
// re-implementations of the client decoders (GridModel.load, DoorModel.load,
// MapEntry XML parsing) and compare.

const room = require("../src/room-data");
const st = require("../src/street01-truth");

let failures = 0;
function check(name, ok, detail = "") {
  console.log(`${ok ? "OK  " : "FAIL"} ${name}${detail ? "  " + detail : ""}`);
  if (!ok) failures++;
}

const ALL_AVATAR_PERMISSIONS = [
  2, 3, 4, 5, 6, 7, 8,
  9, 10, 11, 12, 13, 14, 15, 16,
  17, 18, 19, 20, 21, 22, 23, 24,
  25, 26, 27, 29, 30, 31, 32,
  40, 41, 42, 43, 45, 46, 47, 48,
  49, 50
];

function decodePermissionRoles(value) {
  const bytes = Buffer.from(value, "base64");
  const indexes = [];
  for (let byteIndex = 0; byteIndex < bytes.length; byteIndex++) {
    for (let bit = -1; bit < 7; bit++) {
      const mask = bit === -1 ? 1 << 7 : 1 << bit;
      if (bytes[byteIndex] & mask) {
        indexes.push(byteIndex * 8 + (bit === -1 ? 8 : bit + 1));
      }
    }
  }
  return indexes;
}

// -------------------------------------------------------------------------
// 1. GRID — client side (snl_780_src GridModel.load)
//    BE int32 width, BE int32 height, int8 cell × W*H, row-major (y outer).
// -------------------------------------------------------------------------
function decodeGrid(b64) {
  const buf = Buffer.from(b64, "base64");
  const width = buf.readInt32BE(0);
  const height = buf.readInt32BE(4);
  const cells = new Array(width * height);
  for (let i = 0; i < cells.length; i++) cells[i] = buf.readInt8(8 + i);
  return { width, height, cells };
}

{
  const cells = room.makeWalkableGrid(st.GRID_WIDTH, st.GRID_HEIGHT);
  // Stamp a few non-zero cells to prove signed int8 round-trips (incl. -1).
  cells[0] = room.CELL.DISABLED;
  cells[5] = room.CELL.WALK_ONLY; // -1
  cells[cells.length - 1] = room.CELL.FURNITURE_ONLY;

  const encoded = room.encodeGrid(st.GRID_WIDTH, st.GRID_HEIGHT, cells);
  const decoded = decodeGrid(encoded);

  check("grid.width round-trip",  decoded.width === st.GRID_WIDTH);
  check("grid.height round-trip", decoded.height === st.GRID_HEIGHT);
  check("grid.cells length",      decoded.cells.length === cells.length);
  let mismatches = 0;
  for (let i = 0; i < cells.length; i++) if (decoded.cells[i] !== cells[i]) mismatches++;
  check("grid.cells values",      mismatches === 0, `${mismatches} mismatch(es)`);
  check("grid signed -1 preserved", decoded.cells[5] === -1, `got ${decoded.cells[5]}`);
}

// -------------------------------------------------------------------------
// 2. DOORS — client side (DoorModel.load)
//    Reads o.key, o.targetX, o.targetY, o.targetDir, o.property.{cn,...}.
//    DoorVO.setProperty instantiates `com.oyunstudyosu.property.<cn>` and
//    sets property.data = (object with type added).
// -------------------------------------------------------------------------
const VALID_PROPERTY_CLASSES = new Set([
  "RoomPanelProperty", "PassageProperty", "TeleportProperty", "FlatExitProperty",
  "FlatEnterProperty", "GameProperty", "TopListProperty", "GatheringProperty",
  "PanelProperty", "SpeechProperty", "TableTopGameProperty", "SaleItemPanelProperty",
  "ProfessionPanelProperty", "PaymentPanelProperty", "SimpleBotMessageProperty",
  "ExternalLinkProperty", "RoomShopPanelProperty", "ShopPanelProperty",
  "SolariumPanelProperty", "NickChangePanelProperty", "FlatSponsorPanelProperty",
  "JSFunctionProperty", "VipCardPanelProperty", "ExchangeProperty",
  "GiftOnceProperty", "InviteGiftProperty", "EmptyProperty", "SaleProductPanelProperty"
]);

{
  const doors = st.DOORS.map(d => ({
    key: d.key,
    targetX: d.tile_x,
    targetY: d.tile_y,
    targetDir: d.dir,
    property: { cn: "PassageProperty", roomKey: d.to }
  }));
  const jsonStr = room.buildDoorsJson(doors);
  const parsed = JSON.parse(jsonStr); // DoorModel.loadJSON does exactly this

  check("doors is array",        Array.isArray(parsed));
  check("doors count",           parsed.length === st.DOORS.length);

  let badField = 0, badDir = 0, badClass = 0, badPropType = 0;
  for (const o of parsed) {
    if (typeof o.key !== "string") badField++;
    if (!Number.isInteger(o.targetX) || !Number.isInteger(o.targetY)) badField++;
    if (!Number.isInteger(o.targetDir) || o.targetDir < 1 || o.targetDir > 8) badDir++;
    if (!o.property || typeof o.property.cn !== "string") badPropType++;
    else if (!VALID_PROPERTY_CLASSES.has(o.property.cn)) badClass++;
  }
  check("door fields well-typed",        badField === 0,    `${badField} bad`);
  check("door targetDir in 1..8",        badDir === 0,      `${badDir} bad`);
  check("door property.cn is a string",  badPropType === 0, `${badPropType} bad`);
  check("door property.cn is a real class", badClass === 0, `${badClass} unknown`);

  // Spot-check d1 matches the documented spawn.
  const d1 = parsed.find(d => d.key === "d1");
  check("d1.targetX=38",  d1 && d1.targetX === 38);
  check("d1.targetY=25",  d1 && d1.targetY === 25);

  const joinPayload = require("../src/sfs-codec").decodePacket(require("../src/sfs-codec").buildRoomJoinResponse("street01", "d1")).object.value.p;
  const userVars = new Map(joinPayload.ul[0][4].map(v => [v[0], v[2]]));
  check("avatar clothes not empty",  JSON.parse(userVars.get("clothes")).length > 0);
  check("avatar has roles var",      userVars.has("roles"));
  const roleIndexes = decodePermissionRoles(userVars.get("roles"));
  check("avatar has all permissions", ALL_AVATAR_PERMISSIONS.every(index => roleIndexes.includes(index)), roleIndexes.join(","));
  check("avatar has speed var",      userVars.has("speed"));
  check("avatar has avatarSize var", userVars.has("avatarSize"));
  check("street01 default spawn",    userVars.get("position") === "29,16");
}

// -------------------------------------------------------------------------
// 3. MAP XML — client side (RoomModel.set map → XMLList(Base64.decode(s)))
//    We re-parse with a minimal XML parser and verify entries decode and
//    attributes round-trip (esp. quotes/entities).
// -------------------------------------------------------------------------
function decodeMapXml(b64) {
  return Buffer.from(b64, "base64").toString("utf8");
}

{
  // Build a representative set of entries the client would see.
  const entries = [
    {
      type: "chair",
      attrs: { x: 10, y: 0, z: 12, w: 1, h: 1, d: 1, def: "cadde_park_koltuk_1", dir: 4, id: "c-1", enabled: 1 }
    },
    {
      type: "stuff",
      attrs: { x: 20, y: 0, z: 15, w: 1, h: 1, d: 1, def: "magic_lamp", a: "rub", id: "s-1", interactive: "true" },
      property: '{"cn":"SpeechProperty","text":"hello \\"world\\" & <stuff>"}'
    },
    {
      type: "box",
      attrs: { x: 30, y: 0, z: 30, w: 2, h: 1, d: 2, def: "cadde_kisa_duvar_3" }
    },
    {
      // Sentinel entry: attr value contains a literal " and < to test escaping.
      type: "box",
      attrs: { x: 0, y: 0, z: 0, w: 1, h: 1, d: 1, def: 'evil "quoted" <name>' }
    }
  ];

  const encoded = room.encodeMapXml(entries);
  const xml = decodeMapXml(encoded);

  check("map XML decodes to UTF-8",            xml.startsWith("<map>") && xml.endsWith("</map>"));
  const emptyStreetMap = decodeMapXml(room.encodeMapXml([], { xOrigin: 200, yOrigin: 590 }));
  check("empty street map has xOrigin",        emptyStreetMap.includes('xOrigin="200"'));
  check("empty street map has yOrigin",        emptyStreetMap.includes('yOrigin="590"'));
  const street01 = require("../data/streets-1-13.json").rooms.street01;
  check("street01 map entries empty",          street01.mapEntries.length === 0);
  check("street01 bots empty",                 street01.bots.length === 0);
  check("map XML contains <chair> entry",      /<chair [^>]*def="cadde_park_koltuk_1"/.test(xml));
  check("map XML contains <stuff> with text",  /<stuff [^>]*a="rub"[^>]*>.*<\/stuff>/.test(xml));
  check("map XML escapes \" in attrs",         xml.includes('def="evil &quot;quoted&quot; &lt;name&gt;"'));
  check("map XML escapes < in property text",  xml.includes("&lt;stuff&gt;"));
  check("map XML escapes & in property text",  xml.includes("&amp;"));

  // Re-extract attributes from the chair entry and verify each round-trips.
  const m = xml.match(/<chair([^/]+?)\/>/);
  check("chair self-closes",                   !!m);
  if (m) {
    const attrs = {};
    for (const a of m[1].matchAll(/(\w+)="([^"]*)"/g)) attrs[a[1]] = a[2];
    check("chair attr x=10",  attrs.x === "10");
    check("chair attr def",   attrs.def === "cadde_park_koltuk_1");
    check("chair attr dir=4", attrs.dir === "4");
  }
}

// -------------------------------------------------------------------------
console.log("");
if (failures) {
  console.error(`${failures} check(s) failed`);
  process.exit(1);
}
console.log("all roundtrip checks passed");
