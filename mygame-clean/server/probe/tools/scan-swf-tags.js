// Scan a SWF for DefineBinaryData (87), DefineSymbolClass (76) and tag histogram.
// Dumps Base64 of each DefineBinaryData payload (and a UTF-8 preview).
const fs = require("fs");
const zlib = require("zlib");

const file = process.argv[2];
if (!file) { console.error("usage: node scan-swf-tags.js <file.swf>"); process.exit(1); }

function loadSwf(p) {
  const b = fs.readFileSync(p);
  const sig = b.subarray(0, 3).toString("ascii");
  if (sig === "FWS") return b;
  if (sig === "CWS") return Buffer.concat([Buffer.from("FWS"), b.subarray(3, 8), zlib.unzipSync(b.subarray(8))]);
  if (sig === "ZWS") { console.error("LZMA SWFs not supported"); process.exit(2); }
  throw new Error("Unknown sig: " + sig);
}
function readRectLen(b) { const n = b[8] >> 3; return Math.ceil((5 + n * 4) / 8); }

const swf = loadSwf(file);
let off = 8 + readRectLen(swf) + 4;

const symbolClass = []; // [{id,name}]
const binaryData = []; // [{id,len,b64,preview}]
const hist = new Map();

while (off + 2 <= swf.length) {
  const h = swf.readUInt16LE(off); off += 2;
  const code = h >> 6;
  let len = h & 0x3f;
  if (len === 0x3f) { len = swf.readUInt32LE(off); off += 4; }
  const payload = swf.subarray(off, off + len);
  off += len;
  hist.set(code, (hist.get(code) || 0) + 1);

  if (code === 76) {
    // DefineSymbolClass: u16 count, then count*(u16 tag, string name\0)
    let p = 0;
    const count = payload.readUInt16LE(p); p += 2;
    for (let i = 0; i < count; i++) {
      const id = payload.readUInt16LE(p); p += 2;
      const end = payload.indexOf(0, p);
      const name = payload.subarray(p, end).toString("utf8");
      p = end + 1;
      symbolClass.push({ id, name });
    }
  }
  if (code === 87) {
    // DefineBinaryData: u16 id, u32 reserved, data
    const id = payload.readUInt16LE(0);
    const data = payload.subarray(6);
    const utf = data.toString("utf8");
    const printable = utf.replace(/[^\x20-\x7E\n\r\t]/g, ".");
    binaryData.push({ id, len: data.length, b64: data.toString("base64"), preview: printable.slice(0, 200) });
  }
  if (code === 0) break; // End
}

const symMap = new Map(symbolClass.map(s => [s.id, s.name]));

console.log("=== Tag histogram ===");
[...hist.entries()].sort((a, b) => a[0] - b[0]).forEach(([k, v]) => console.log(`tag ${k} count=${v}`));

console.log("\n=== DefineSymbolClass (" + symbolClass.length + ") ===");
symbolClass.forEach(s => console.log(`  id=${s.id}  ${s.name}`));

console.log("\n=== DefineBinaryData (" + binaryData.length + ") ===");
binaryData.forEach(b => {
  const name = symMap.get(b.id) || "(no symbol class)";
  console.log(`\n--- id=${b.id} class="${name}" bytes=${b.len}`);
  console.log(`preview: ${b.preview}`);
  if (b.len <= 4096) console.log(`base64:  ${b.b64}`);
  else console.log(`base64(head): ${b.b64.slice(0, 200)}...`);
});
