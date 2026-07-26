const fs = require("fs");
const zlib = require("zlib");

const file = process.argv[2] || "assets/cdn/global/dynamic/rooms/st01.swf";
const targetClass = "org.oyunstudyosu.sanalika.rooms.street01::bg";
const targetTrait = "init";

function readU30(state) {
  let result = 0;
  for (let shift = 0; shift < 35; shift += 7) {
    const byte = state.buffer[state.offset++];
    result |= (byte & 0x7f) << shift;
    if ((byte & 0x80) === 0) return result >>> 0;
  }
  throw new Error("Invalid U30");
}

function skipU30(state, count) {
  for (let index = 0; index < count; index++) readU30(state);
}

function readRectLength(buffer) {
  const nbits = buffer[8] >> 3;
  return Math.ceil((5 + nbits * 4) / 8);
}

function decompressSwf(original) {
  const signature = original.subarray(0, 3).toString("ascii");
  if (signature === "FWS") return { signature, swf: Buffer.from(original) };
  if (signature === "CWS") {
    return {
      signature,
      swf: Buffer.concat([Buffer.from("FWS"), original.subarray(3, 8), zlib.unzipSync(original.subarray(8))])
    };
  }
  throw new Error(`Unsupported SWF signature: ${signature}`);
}

function recompressSwf(signature, swf) {
  if (signature === "FWS") return swf;
  if (signature === "CWS") return Buffer.concat([Buffer.from("CWS"), swf.subarray(3, 8), zlib.deflateSync(swf.subarray(8))]);
  throw new Error(`Unsupported SWF signature: ${signature}`);
}

function extractAbcBlocks(swf) {
  let offset = 8 + readRectLength(swf) + 4;
  const blocks = [];
  while (offset + 2 <= swf.length) {
    const tagOffset = offset;
    const header = swf.readUInt16LE(offset);
    offset += 2;
    const code = header >> 6;
    let length = header & 0x3f;
    if (length === 0x3f) {
      length = swf.readUInt32LE(offset);
      offset += 4;
    }
    const payloadOffset = offset;
    const payload = swf.subarray(offset, offset + length);
    offset += length;
    if (code === 72 || code === 82) {
      let abcOffset = 0;
      if (code === 82) {
        abcOffset = 4;
        const nameEnd = payload.indexOf(0, abcOffset);
        abcOffset = nameEnd + 1;
      }
      blocks.push({ tagOffset, payloadOffset, abcOffset, abcStart: payloadOffset + abcOffset, abc: payload.subarray(abcOffset) });
    }
  }
  return blocks;
}

function formatMultiname(multiname) {
  if (!multiname) return "";
  if (typeof multiname.name === "object") return formatMultiname(multiname.name);
  const nsName = multiname.ns && multiname.ns.name;
  return nsName ? `${nsName}::${multiname.name}` : multiname.name || "";
}

function parseAbc(buffer) {
  const state = { buffer, offset: 0 };
  state.offset += 4;

  let count = readU30(state);
  for (let index = 1; index < count; index++) readU30(state);

  count = readU30(state);
  for (let index = 1; index < count; index++) readU30(state);

  count = readU30(state);
  for (let index = 1; index < count; index++) state.offset += 8;

  const strings = [""];
  count = readU30(state);
  for (let index = 1; index < count; index++) {
    const length = readU30(state);
    strings.push(state.buffer.subarray(state.offset, state.offset + length).toString("utf8"));
    state.offset += length;
  }

  const namespaces = [null];
  count = readU30(state);
  for (let index = 1; index < count; index++) {
    const kind = state.buffer[state.offset++];
    namespaces.push({ kind, name: strings[readU30(state)] });
  }

  const namespaceSets = [null];
  count = readU30(state);
  for (let index = 1; index < count; index++) {
    const setCount = readU30(state);
    const set = [];
    for (let setIndex = 0; setIndex < setCount; setIndex++) set.push(namespaces[readU30(state)]);
    namespaceSets.push(set);
  }

  const multinames = [null];
  count = readU30(state);
  for (let index = 1; index < count; index++) {
    const kind = state.buffer[state.offset++];
    const multiname = { kind };
    switch (kind) {
      case 0x07:
      case 0x0d:
        multiname.ns = namespaces[readU30(state)];
        multiname.name = strings[readU30(state)];
        break;
      case 0x0f:
      case 0x10:
        multiname.name = strings[readU30(state)];
        break;
      case 0x11:
      case 0x12:
        break;
      case 0x09:
      case 0x0e:
        multiname.name = strings[readU30(state)];
        multiname.nsSet = namespaceSets[readU30(state)];
        break;
      case 0x1b:
      case 0x1c:
        multiname.nsSet = namespaceSets[readU30(state)];
        break;
      case 0x1d: {
        multiname.name = multinames[readU30(state)];
        const paramCount = readU30(state);
        multiname.params = [];
        for (let paramIndex = 0; paramIndex < paramCount; paramIndex++) multiname.params.push(multinames[readU30(state)]);
        break;
      }
      default:
        throw new Error(`Unsupported multiname kind 0x${kind.toString(16)}`);
    }
    multinames.push(multiname);
  }

  const methods = [];
  count = readU30(state);
  for (let index = 0; index < count; index++) {
    const paramCount = readU30(state);
    readU30(state);
    skipU30(state, paramCount);
    const name = strings[readU30(state)];
    const flags = state.buffer[state.offset++];
    if (flags & 0x08) {
      const optionCount = readU30(state);
      for (let optionIndex = 0; optionIndex < optionCount; optionIndex++) {
        readU30(state);
        state.offset++;
      }
    }
    if (flags & 0x80) skipU30(state, paramCount);
    methods.push({ name });
  }

  count = readU30(state);
  for (let index = 0; index < count; index++) {
    readU30(state);
    const itemCount = readU30(state);
    skipU30(state, itemCount * 2);
  }

  const instances = [];
  count = readU30(state);
  for (let index = 0; index < count; index++) {
    const name = multinames[readU30(state)];
    const superName = multinames[readU30(state)];
    const flags = state.buffer[state.offset++];
    if (flags & 0x08) readU30(state);
    const interfaceCount = readU30(state);
    skipU30(state, interfaceCount);
    const iinit = readU30(state);
    const traitCount = readU30(state);
    const traits = readTraits(state, traitCount, multinames);
    instances.push({ name, superName, iinit, traits });
  }

  for (let index = 0; index < count; index++) {
    readU30(state);
    const traitCount = readU30(state);
    readTraits(state, traitCount, multinames);
  }

  count = readU30(state);
  for (let index = 0; index < count; index++) {
    readU30(state);
    const traitCount = readU30(state);
    readTraits(state, traitCount, multinames);
  }

  const bodies = [];
  count = readU30(state);
  for (let index = 0; index < count; index++) {
    const method = readU30(state);
    readU30(state);
    readU30(state);
    readU30(state);
    readU30(state);
    const codeLength = readU30(state);
    const codeStart = state.offset;
    state.offset += codeLength;
    const exceptionCount = readU30(state);
    for (let exceptionIndex = 0; exceptionIndex < exceptionCount; exceptionIndex++) skipU30(state, 5);
    const traitCount = readU30(state);
    readTraits(state, traitCount, multinames);
    bodies.push({ method, codeStart, codeLength });
  }

  return { instances, bodies, methods, multinames };
}

function readTraits(state, traitCount, multinames) {
  const traits = [];
  for (let index = 0; index < traitCount; index++) {
    const name = multinames[readU30(state)];
    const kindAndAttrs = state.buffer[state.offset++];
    const kind = kindAndAttrs & 0x0f;
    const trait = { name, kind };
    switch (kind) {
      case 0:
      case 6:
        trait.slotId = readU30(state);
        trait.typeName = multinames[readU30(state)];
        trait.vindex = readU30(state);
        if (trait.vindex !== 0) state.offset++;
        break;
      case 1:
      case 2:
      case 3:
        trait.dispId = readU30(state);
        trait.method = readU30(state);
        break;
      case 4:
        trait.slotId = readU30(state);
        trait.classIndex = readU30(state);
        break;
      case 5:
        trait.slotId = readU30(state);
        trait.functionIndex = readU30(state);
        break;
      default:
        throw new Error(`Unsupported trait kind ${kind}`);
    }
    if (kindAndAttrs & 0x40) skipU30(state, readU30(state));
    traits.push(trait);
  }
  return traits;
}

const original = fs.readFileSync(file);
const backup = `${file}.orig`;
if (!fs.existsSync(backup)) fs.copyFileSync(file, backup);

const { signature, swf } = decompressSwf(original);
const blocks = extractAbcBlocks(swf);
let patched = false;

for (const block of blocks) {
  const abc = parseAbc(block.abc);
  const instance = abc.instances.find((candidate) => formatMultiname(candidate.name) === targetClass);
  if (!instance) continue;
  const trait = instance.traits.find((candidate) => formatMultiname(candidate.name) === targetTrait);
  if (!trait) throw new Error(`Found ${targetClass} but no ${targetTrait} trait`);
  const body = abc.bodies.find((candidate) => candidate.method === trait.method);
  if (!body) throw new Error(`No method body for ${targetClass}.${targetTrait}`);

  const absoluteCodeStart = block.abcStart + body.codeStart;
  const code = swf.subarray(absoluteCodeStart, absoluteCodeStart + body.codeLength);
  code.fill(0x02);
  code[0] = 0x47;
  patched = true;
  console.log(`patched ${targetClass}.${targetTrait} method=${trait.method} codeLength=${body.codeLength}`);
}

if (!patched) throw new Error(`Did not find ${targetClass}.${targetTrait}`);
fs.writeFileSync(file, recompressSwf(signature, swf));
console.log(`backup: ${backup}`);
console.log(`wrote: ${file}`);
