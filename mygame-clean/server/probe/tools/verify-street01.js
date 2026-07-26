// Verify street01-truth.js produces correct wire payloads.
// Re-projects each door pixel via the shared iso math and asserts it matches
// the recorded tile_x/tile_y. Then dumps the encoded grid/map/doors lengths.

const room = require("../src/room-data");
const st = require("../src/street01-truth");

let failed = 0;
for (const d of st.DOORS) {
  const t = room.pixelToTile(d.pixel_x, d.pixel_y, st.X_ORIGIN, st.Y_ORIGIN);
  const ok = t.x === d.tile_x && t.y === d.tile_y;
  console.log(`${ok ? "OK " : "FAIL"} ${d.key}  pixel=(${d.pixel_x},${d.pixel_y})  expected=(${d.tile_x},${d.tile_y})  got=(${t.x},${t.y})`);
  if (!ok) failed++;
}

const grid = room.encodeGrid(st.GRID_WIDTH, st.GRID_HEIGHT, room.makeWalkableGrid(st.GRID_WIDTH, st.GRID_HEIGHT));
const doorsJson = room.buildDoorsJson(st.DOORS.map(d => ({
  key: d.key,
  targetX: d.tile_x,
  targetY: d.tile_y,
  targetDir: d.dir,
  property: { cn: "PassageProperty", roomKey: d.to }
})));
const mapXml = room.encodeMapXml([], { xOrigin: st.X_ORIGIN, yOrigin: st.Y_ORIGIN }); // street01 has no server-side interactive entries today

console.log("");
console.log(`grid     base64 bytes: ${grid.length}  (raw bytes: ${8 + st.GRID_WIDTH * st.GRID_HEIGHT})`);
console.log(`doors    json bytes:   ${doorsJson.length}  doors=${st.DOORS.length}`);
console.log(`map      base64 bytes: ${mapXml.length}  (decoded XML: "${Buffer.from(mapXml, "base64").toString("utf8")}")`);

if (failed) {
  console.error(`\n${failed} door projection mismatch(es)`);
  process.exit(1);
}
console.log("\nall door projections match recorded tiles");
