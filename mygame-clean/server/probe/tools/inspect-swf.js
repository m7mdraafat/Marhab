const fs = require("fs");
const zlib = require("zlib");

const file = process.argv[2];
const needle = process.argv[3] || "street01";

if (!file) {
  console.error("usage: node inspect-swf.js <file.swf> [needle]");
  process.exit(1);
}

function readU30(state) {
  let result = 0;
  for (let shift = 0; shift < 35; shift += 7) {
    const byte = state.buffer[state.offset++];
    result |= (byte & 0x7f) << shift;
    if ((byte & 0x80) === 0) {
      return result >>> 0;
    }
  }
  throw new Error("Invalid U30");
}

function skipU30(state, count) {
  for (let index = 0; index < count; index++) {
    readU30(state);
  }
}

function readRectLength(buffer) {
  const nbits = buffer[8] >> 3;
  return Math.ceil((5 + nbits * 4) / 8);
}

function loadSwf(path) {
  const original = fs.readFileSync(path);
  const signature = original.subarray(0, 3).toString("ascii");
  if (signature === "FWS") {
    return original;
  }
  if (signature === "CWS") {
    return Buffer.concat([Buffer.from("FWS"), original.subarray(3, 8), zlib.unzipSync(original.subarray(8))]);
  }
  throw new Error(`Unsupported SWF signature: ${signature}`);
}

function extractAbcBlocks(swf) {
  let offset = 8 + readRectLength(swf) + 4;
  const blocks = [];

  while (offset + 2 <= swf.length) {
    const header = swf.readUInt16LE(offset);
    offset += 2;
    const code = header >> 6;
    let length = header & 0x3f;
    if (length === 0x3f) {
      length = swf.readUInt32LE(offset);
      offset += 4;
    }
    const payload = swf.subarray(offset, offset + length);
    offset += length;

    if (code === 72 || code === 82) {
      let abcOffset = 0;
      let name = "";
      if (code === 82) {
        abcOffset = 4;
        const nameEnd = payload.indexOf(0, abcOffset);
        name = payload.subarray(abcOffset, nameEnd).toString("utf8");
        abcOffset = nameEnd + 1;
      }
      blocks.push({ code, name, abc: payload.subarray(abcOffset) });
    }
  }

  return blocks;
}

function parseAbc(buffer) {
  const state = { buffer, offset: 0 };
  state.offset += 4;

  const ints = [0];
  let count = readU30(state);
  for (let index = 1; index < count; index++) {
    ints.push(readU30(state));
  }

  const uints = [0];
  count = readU30(state);
  for (let index = 1; index < count; index++) {
    uints.push(readU30(state));
  }

  const doubles = [NaN];
  count = readU30(state);
  for (let index = 1; index < count; index++) {
    doubles.push(state.buffer.readDoubleLE(state.offset));
    state.offset += 8;
  }

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
    for (let setIndex = 0; setIndex < setCount; setIndex++) {
      set.push(namespaces[readU30(state)]);
    }
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
        for (let paramIndex = 0; paramIndex < paramCount; paramIndex++) {
          multiname.params.push(multinames[readU30(state)]);
        }
        break;
      }
      default:
        throw new Error(`Unsupported multiname kind 0x${kind.toString(16)} at ${index}`);
    }
    multinames.push(multiname);
  }

  const methods = [];
  count = readU30(state);
  for (let index = 0; index < count; index++) {
    const paramCount = readU30(state);
    const returnType = readU30(state);
    const params = [];
    for (let paramIndex = 0; paramIndex < paramCount; paramIndex++) {
      params.push(readU30(state));
    }
    const name = strings[readU30(state)];
    const flags = state.buffer[state.offset++];
    if (flags & 0x08) {
      const optionCount = readU30(state);
      for (let optionIndex = 0; optionIndex < optionCount; optionIndex++) {
        readU30(state);
        state.offset++;
      }
    }
    if (flags & 0x80) {
      skipU30(state, paramCount);
    }
    methods.push({ name, params, returnType });
  }

  count = readU30(state);
  for (let index = 0; index < count; index++) {
    readU30(state);
    const itemCount = readU30(state);
    for (let itemIndex = 0; itemIndex < itemCount; itemIndex++) {
      readU30(state);
      readU30(state);
    }
  }

  const instances = [];
  count = readU30(state);
  for (let index = 0; index < count; index++) {
    const nameIndex = readU30(state);
    const superIndex = readU30(state);
    const flags = state.buffer[state.offset++];
    if (flags & 0x08) {
      readU30(state);
    }
    const interfaceCount = readU30(state);
    skipU30(state, interfaceCount);
    const iinit = readU30(state);
    const traitCount = readU30(state);
    const traits = readTraits(state, traitCount);
    instances.push({ name: multinames[nameIndex], superName: multinames[superIndex], iinit, traits });
  }

  const classes = [];
  for (let index = 0; index < count; index++) {
    const cinit = readU30(state);
    const traitCount = readU30(state);
    const traits = readTraits(state, traitCount);
    classes.push({ instance: instances[index], cinit, traits });
  }

  count = readU30(state);
  for (let index = 0; index < count; index++) {
    readU30(state);
    const traitCount = readU30(state);
    readTraits(state, traitCount);
  }

  const bodies = [];
  count = readU30(state);
  for (let index = 0; index < count; index++) {
    const method = readU30(state);
    const maxStack = readU30(state);
    const localCount = readU30(state);
    const initScopeDepth = readU30(state);
    const maxScopeDepth = readU30(state);
    const codeLength = readU30(state);
    const code = state.buffer.subarray(state.offset, state.offset + codeLength);
    state.offset += codeLength;
    const exceptionCount = readU30(state);
    for (let exceptionIndex = 0; exceptionIndex < exceptionCount; exceptionIndex++) {
      readU30(state);
      readU30(state);
      readU30(state);
      readU30(state);
      readU30(state);
    }
    const traitCount = readU30(state);
    readTraits(state, traitCount);
    bodies.push({ method, methodName: methods[method] && methods[method].name, maxStack, localCount, initScopeDepth, maxScopeDepth, code });
  }

  return { classes, methods, bodies, multinames, namespaces, strings };

  function readTraits(innerState, traitCount) {
    const traits = [];
    for (let traitIndex = 0; traitIndex < traitCount; traitIndex++) {
      const name = multinames[readU30(innerState)];
      const kindAndAttrs = innerState.buffer[innerState.offset++];
      const kind = kindAndAttrs & 0x0f;
      const trait = { name, kind };
      switch (kind) {
        case 0:
        case 6:
          trait.slotId = readU30(innerState);
          trait.typeName = multinames[readU30(innerState)];
          trait.vindex = readU30(innerState);
          if (trait.vindex !== 0) {
            innerState.offset++;
          }
          break;
        case 1:
        case 2:
        case 3:
          trait.dispId = readU30(innerState);
          trait.method = readU30(innerState);
          break;
        case 4:
          trait.slotId = readU30(innerState);
          trait.classIndex = readU30(innerState);
          break;
        case 5:
          trait.slotId = readU30(innerState);
          trait.functionIndex = readU30(innerState);
          break;
        default:
          throw new Error(`Unsupported trait kind ${kind}`);
      }
      if (kindAndAttrs & 0x40) {
        const metadataCount = readU30(innerState);
        skipU30(innerState, metadataCount);
      }
      traits.push(trait);
    }
    return traits;
  }
}

function formatMultiname(multiname) {
  if (!multiname) return "";
  if (typeof multiname.name === "object") return formatMultiname(multiname.name);
  const nsName = multiname.ns && multiname.ns.name;
  return nsName ? `${nsName}::${multiname.name}` : multiname.name || "";
}

function extractU30(buffer, offset) {
  const state = { buffer, offset };
  const value = readU30(state);
  return { value, offset: state.offset };
}

const operandU30 = new Set([0x5d, 0x60, 0x61, 0x66, 0x68, 0x6a, 0x6c, 0x6d, 0x46, 0x4f, 0x40, 0x41]);

function referencedMultinames(body, multinames) {
  const refs = [];
  let offset = 0;
  while (offset < body.code.length) {
    const opcodeOffset = offset;
    const opcode = body.code[offset++];
    if (operandU30.has(opcode)) {
      const read = extractU30(body.code, offset);
      offset = read.offset;
      refs.push({ opcode, offset: opcodeOffset, name: formatMultiname(multinames[read.value]) });
    } else {
      offset += fixedOperandLength(opcode, body.code, offset);
    }
  }
  return refs.filter((ref) => ref.name);
}

function disassemble(body, multinames) {
  const lines = [];
  let offset = 0;
  while (offset < body.code.length) {
    const opcodeOffset = offset;
    const opcode = body.code[offset++];
    const name = opcodeName(opcode);
    const operands = [];

    if (operandU30.has(opcode)) {
      const read = extractU30(body.code, offset);
      offset = read.offset;
      operands.push(read.value);
      operands.push(formatMultiname(multinames[read.value]));
      if ([0x46, 0x4f, 0x40, 0x41].includes(opcode)) {
        const argc = extractU30(body.code, offset);
        offset = argc.offset;
        operands.push(`argc=${argc.value}`);
      }
    } else {
      const length = fixedOperandLength(opcode, body.code, offset);
      if (length > 0) {
        operands.push(body.code.subarray(offset, offset + length).toString("hex"));
      }
      offset += length;
    }

    lines.push(`${opcodeOffset.toString().padStart(4, "0")} 0x${opcode.toString(16).padStart(2, "0")} ${name} ${operands.join(" ")}`.trimEnd());
  }
  return lines;
}

function opcodeName(opcode) {
  return {
    0x02: "nop",
    0x03: "throw",
    0x04: "getsuper",
    0x05: "setsuper",
    0x06: "dxns",
    0x07: "dxnslate",
    0x08: "kill",
    0x09: "label",
    0x0c: "ifnlt",
    0x0d: "ifnle",
    0x0e: "ifngt",
    0x0f: "ifnge",
    0x10: "jump",
    0x11: "iftrue",
    0x12: "iffalse",
    0x13: "ifeq",
    0x14: "ifne",
    0x15: "iflt",
    0x16: "ifle",
    0x17: "ifgt",
    0x18: "ifge",
    0x19: "ifstricteq",
    0x1a: "ifstrictne",
    0x1b: "lookupswitch",
    0x1c: "pushwith",
    0x1d: "popscope",
    0x20: "pushnull",
    0x21: "pushundefined",
    0x24: "pushbyte",
    0x25: "pushshort",
    0x26: "pushtrue",
    0x27: "pushfalse",
    0x28: "pushnan",
    0x29: "pop",
    0x2a: "dup",
    0x2b: "swap",
    0x2c: "pushstring",
    0x2d: "pushint",
    0x2e: "pushuint",
    0x2f: "pushdouble",
    0x30: "pushscope",
    0x31: "pushnamespace",
    0x32: "hasnext2",
    0x40: "newfunction",
    0x41: "call",
    0x42: "construct",
    0x46: "callproperty",
    0x47: "returnvoid",
    0x48: "returnvalue",
    0x49: "constructsuper",
    0x4a: "constructprop",
    0x4c: "callproplex",
    0x4e: "callsupervoid",
    0x4f: "callpropvoid",
    0x55: "newobject",
    0x56: "newarray",
    0x58: "newclass",
    0x59: "getdescendants",
    0x5d: "findpropstrict",
    0x5e: "findproperty",
    0x60: "getlex",
    0x61: "setproperty",
    0x62: "getlocal",
    0x63: "setlocal",
    0x64: "getglobalscope",
    0x65: "getscopeobject",
    0x66: "getproperty",
    0x68: "initproperty",
    0x6a: "deleteproperty",
    0x6c: "getslot",
    0x6d: "setslot",
    0x70: "convert_s",
    0x73: "convert_i",
    0x74: "convert_u",
    0x75: "convert_d",
    0x76: "convert_b",
    0x80: "coerce",
    0x82: "coerce_a",
    0x85: "coerce_s",
    0x91: "increment",
    0x93: "decrement",
    0x96: "not",
    0x97: "bitnot",
    0xa0: "add",
    0xa1: "subtract",
    0xa2: "multiply",
    0xa3: "divide",
    0xa4: "modulo",
    0xab: "equals",
    0xac: "strictequals",
    0xd0: "getlocal0",
    0xd1: "getlocal1",
    0xd2: "getlocal2",
    0xd3: "getlocal3",
    0xd4: "setlocal0",
    0xd5: "setlocal1",
    0xd6: "setlocal2",
    0xd7: "setlocal3"
  }[opcode] || "op";
}

function fixedOperandLength(opcode, code, offset) {
  switch (opcode) {
    case 0x08:
    case 0x09:
    case 0x1d:
    case 0x24:
    case 0x25:
    case 0x2c:
    case 0x2d:
    case 0x2e:
    case 0x2f:
    case 0x30:
    case 0x31:
    case 0x32:
    case 0x49:
    case 0x4a:
    case 0x4c:
    case 0x4e:
    case 0x55:
    case 0x56:
    case 0xef:
      return 1;
    case 0x09:
      return 1;
    case 0x10:
    case 0x11:
    case 0x12:
    case 0x13:
    case 0x14:
    case 0x15:
    case 0x16:
    case 0x17:
    case 0x18:
      return 3;
    case 0x1b:
      return 4;
    case 0x47:
    case 0x48:
    case 0x0c:
    case 0x0d:
    case 0x0e:
    case 0x0f:
      return 0;
    case 0x27:
    case 0x28:
    case 0x29:
    case 0x2a:
    case 0x2b:
    case 0xd0:
    case 0xd1:
    case 0xd2:
    case 0xd3:
    case 0xd4:
    case 0xd5:
    case 0xd6:
    case 0xd7:
      return 0;
    default:
      return 0;
  }
}

const swf = loadSwf(file);
const blocks = extractAbcBlocks(swf);
console.log(`ABC blocks: ${blocks.length}`);

for (const [blockIndex, block] of blocks.entries()) {
  const abc = parseAbc(block.abc);
  const strings = abc.strings.filter((value) => value && value.toLowerCase().includes(needle.toLowerCase()));
  const classes = abc.classes.filter((klass) => formatMultiname(klass.instance.name).toLowerCase().includes(needle.toLowerCase()));
  if (strings.length || classes.length) {
    console.log(`\nABC[${blockIndex}] ${block.name || "<unnamed>"}`);
    console.log("strings", strings.slice(0, 50));
    for (const klass of classes) {
      const className = formatMultiname(klass.instance.name);
      console.log(`class ${className} super=${formatMultiname(klass.instance.superName)} iinit=${klass.instance.iinit}`);
      const traitMethods = klass.instance.traits
        .filter((trait) => [1, 2, 3].includes(trait.kind))
        .map((trait) => ({ traitName: formatMultiname(trait.name), method: trait.method }));
      for (const trait of traitMethods) {
        console.log(`  trait ${trait.traitName} method=${trait.method} methodName=${abc.methods[trait.method] && abc.methods[trait.method].name}`);
      }
      const interestingMethods = new Set([klass.instance.iinit]);
      for (const trait of traitMethods) {
        if (trait.traitName === "init" || trait.traitName.endsWith("::init") || className.endsWith("::bg")) {
          interestingMethods.add(trait.method);
        }
      }
      for (const body of abc.bodies.filter((candidate) => interestingMethods.has(candidate.method))) {
        console.log(`  body method=${body.method} name=${body.methodName || "<anon>"} code=${body.code.length}`);
        for (const ref of referencedMultinames(body, abc.multinames).slice(0, 200)) {
          console.log(`    @${ref.offset} op=0x${ref.opcode.toString(16)} ${ref.name}`);
        }
        if (className.endsWith("::bg") && (body.methodName === "" || body.methodName === "init" || body.method !== klass.instance.iinit)) {
          for (const line of disassemble(body, abc.multinames)) {
            console.log(`      ${line}`);
          }
        }
      }
    }
  }
}