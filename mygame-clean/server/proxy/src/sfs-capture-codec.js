const TYPE_NULL = 0;
const TYPE_BOOL = 1;
const TYPE_BYTE = 2;
const TYPE_SHORT = 3;
const TYPE_INT = 4;
const TYPE_LONG = 5;
const TYPE_DOUBLE = 7;
const TYPE_UTF_STRING = 8;
const TYPE_UTF_STRING_ARRAY = 16;
const TYPE_SFS_ARRAY = 17;
const TYPE_SFS_OBJECT = 18;

const zlib = require("zlib");

const SENSITIVE_KEYS = new Set(["at", "auth", "fbtoken", "password", "pw", "secret", "token"]);

function decodePacket(frame) {
  if (!Buffer.isBuffer(frame)) {
    throw new Error("SFS packet must be a Buffer");
  }
  if (frame.length < 3) {
    throw new Error(`SFS packet too short: ${frame.length}`);
  }

  const header = frame[0];
  if ((header & 0x80) === 0) {
    throw new Error(`Invalid SFS packet header: 0x${header.toString(16)}`);
  }

  const flags = {
    bigSized: (header & 0x08) !== 0,
    blueBoxed: (header & 0x10) !== 0,
    compressed: (header & 0x20) !== 0,
    encrypted: (header & 0x40) !== 0
  };

  let offset;
  let length;
  if (flags.bigSized) {
    if (frame.length < 5) throw new Error("Big-sized SFS packet missing length");
    length = frame.readUInt32BE(1);
    offset = 5;
  } else {
    length = frame.readUInt16BE(1);
    offset = 3;
  }

  let payload = frame.subarray(offset, offset + length);
  if (payload.length !== length) {
    throw new Error(`SFS packet length mismatch expected=${length} actual=${payload.length}`);
  }

  if (flags.encrypted) {
    return { header, flags, length, payload, encrypted: true, compressed: flags.compressed, typed: null, value: null };
  }

  if (flags.compressed) {
    payload = zlib.unzipSync(payload);
  }

  const decoded = decodeSfsObject(payload, 0);
  if (decoded.offset !== payload.length) {
    throw new Error(`SFS payload has trailing bytes offset=${decoded.offset} length=${payload.length}`);
  }

  return { header, flags, length, payload, encrypted: false, compressed: false, originalCompressed: flags.compressed, typed: decoded.typed, value: toPlain(decoded.typed) };
}

function encodePacket(typedRoot) {
  const payload = encodeSfsObject(typedRoot.value);
  if (payload.length > 0xffff) {
    const header = Buffer.from([0x88]);
    const size = Buffer.alloc(4);
    size.writeUInt32BE(payload.length, 0);
    return Buffer.concat([header, size, payload]);
  }

  const header = Buffer.from([0x80]);
  const size = Buffer.alloc(2);
  size.writeUInt16BE(payload.length, 0);
  return Buffer.concat([header, size, payload]);
}

function packetSummary(packet) {
  if (packet.encrypted) {
    return {
      ok: false,
      encrypted: packet.encrypted,
      compressed: packet.compressed,
      length: packet.length,
      error: `Unsupported SFS packet flags encrypted=${packet.encrypted} compressed=${packet.compressed}`
    };
  }

  const root = packet.value || {};
  const params = root.p || {};
  return {
    ok: true,
    controller: root.c,
    action: root.a,
    extensionCommand: params.c,
    requestId: params.rid,
    roomId: params.r,
    compressed: packet.originalCompressed || false,
    params: redact(params)
  };
}

function rewriteLoginZone(frame, remoteZone) {
  if (!remoteZone) {
    return { changed: false, frame };
  }

  let packet;
  try {
    packet = decodePacket(frame);
  } catch (error) {
    return { changed: false, frame, error: error.message };
  }

  if (packet.encrypted || packet.compressed || !packet.typed) {
    return { changed: false, frame };
  }

  const value = packet.value || {};
  if (value.c !== 0 || value.a !== 1 || !value.p || value.p.zn !== "local") {
    return { changed: false, frame, packet };
  }

  const rootFields = packet.typed.value;
  const paramsField = rootFields.p;
  if (!paramsField || paramsField.type !== "sfsObject" || !paramsField.value.zn) {
    return { changed: false, frame, packet };
  }

  paramsField.value.zn = typedUtf(remoteZone);
  const rewritten = encodePacket(packet.typed);
  return { changed: true, frame: rewritten, packet, rewrittenPacket: decodePacket(rewritten), from: "local", to: remoteZone };
}

function decodeSfsObject(buffer, startOffset) {
  let offset = startOffset;
  const type = buffer[offset++];
  if (type !== TYPE_SFS_OBJECT) {
    throw new Error(`Expected SFS_OBJECT type 18, got ${type} at offset ${offset - 1}`);
  }

  const fieldCount = readUInt16(buffer, offset);
  offset += 2;
  const value = {};

  for (let index = 0; index < fieldCount; index++) {
    const keyLength = readUInt16(buffer, offset);
    offset += 2;
    ensureAvailable(buffer, offset, keyLength, "SFS object key");
    const key = buffer.subarray(offset, offset + keyLength).toString("utf8");
    offset += keyLength;

    const decoded = decodeTypedValue(buffer, offset);
    offset = decoded.offset;
    value[key] = decoded.typed;
  }

  return { typed: { type: "sfsObject", value }, offset };
}

function decodeSfsArray(buffer, startOffset) {
  let offset = startOffset;
  const type = buffer[offset++];
  if (type !== TYPE_SFS_ARRAY) {
    throw new Error(`Expected SFS_ARRAY type 17, got ${type} at offset ${offset - 1}`);
  }

  const itemCount = readUInt16(buffer, offset);
  offset += 2;
  const value = [];

  for (let index = 0; index < itemCount; index++) {
    const decoded = decodeTypedValue(buffer, offset);
    offset = decoded.offset;
    value.push(decoded.typed);
  }

  return { typed: { type: "sfsArray", value }, offset };
}

function decodeTypedValue(buffer, offset) {
  ensureAvailable(buffer, offset, 1, "typed value tag");
  const type = buffer[offset++];

  switch (type) {
    case TYPE_NULL:
      return { typed: { type: "null", value: null }, offset };
    case TYPE_BOOL:
      ensureAvailable(buffer, offset, 1, "bool");
      return { typed: { type: "bool", value: buffer[offset++] !== 0 }, offset };
    case TYPE_BYTE:
      ensureAvailable(buffer, offset, 1, "byte");
      return { typed: { type: "byte", value: buffer.readInt8(offset) }, offset: offset + 1 };
    case TYPE_SHORT:
      ensureAvailable(buffer, offset, 2, "short");
      return { typed: { type: "short", value: buffer.readInt16BE(offset) }, offset: offset + 2 };
    case TYPE_INT:
      ensureAvailable(buffer, offset, 4, "int");
      return { typed: { type: "int", value: buffer.readInt32BE(offset) }, offset: offset + 4 };
    case TYPE_LONG:
      ensureAvailable(buffer, offset, 8, "long");
      return { typed: { type: "long", value: Number(buffer.readBigInt64BE(offset)) }, offset: offset + 8 };
    case TYPE_DOUBLE:
      ensureAvailable(buffer, offset, 8, "double");
      return { typed: { type: "double", value: buffer.readDoubleBE(offset) }, offset: offset + 8 };
    case TYPE_UTF_STRING: {
      const length = readUInt16(buffer, offset);
      offset += 2;
      ensureAvailable(buffer, offset, length, "utf string");
      const value = buffer.subarray(offset, offset + length).toString("utf8");
      return { typed: typedUtf(value), offset: offset + length };
    }
    case TYPE_UTF_STRING_ARRAY: {
      const count = readUInt16(buffer, offset);
      offset += 2;
      const value = [];
      for (let index = 0; index < count; index++) {
        const length = readUInt16(buffer, offset);
        offset += 2;
        ensureAvailable(buffer, offset, length, "utf array item");
        value.push(buffer.subarray(offset, offset + length).toString("utf8"));
        offset += length;
      }
      return { typed: { type: "utfArray", value }, offset };
    }
    case TYPE_SFS_OBJECT:
      return decodeSfsObject(buffer, offset - 1);
    case TYPE_SFS_ARRAY:
      return decodeSfsArray(buffer, offset - 1);
    default:
      throw new Error(`Unsupported SFS type ${type} at offset ${offset - 1}`);
  }
}

function encodeSfsObject(fields) {
  const entries = Object.entries(fields || {});
  const parts = [Buffer.from([TYPE_SFS_OBJECT]), uint16(entries.length)];

  for (const [key, typed] of entries) {
    const keyBuffer = Buffer.from(key, "utf8");
    parts.push(uint16(keyBuffer.length), keyBuffer, encodeTypedValue(typed));
  }

  return Buffer.concat(parts);
}

function encodeSfsArray(items) {
  const parts = [Buffer.from([TYPE_SFS_ARRAY]), uint16((items || []).length)];
  for (const item of items || []) {
    parts.push(encodeTypedValue(item));
  }
  return Buffer.concat(parts);
}

function encodeTypedValue(typed) {
  if (!typed || typeof typed.type !== "string") {
    throw new Error("Cannot encode untyped SFS value");
  }

  switch (typed.type) {
    case "null":
      return Buffer.from([TYPE_NULL]);
    case "bool":
      return Buffer.from([TYPE_BOOL, typed.value ? 1 : 0]);
    case "byte":
      return Buffer.from([TYPE_BYTE, typed.value & 0xff]);
    case "short": {
      const buffer = Buffer.alloc(3);
      buffer[0] = TYPE_SHORT;
      buffer.writeInt16BE(typed.value, 1);
      return buffer;
    }
    case "int": {
      const buffer = Buffer.alloc(5);
      buffer[0] = TYPE_INT;
      buffer.writeInt32BE(typed.value, 1);
      return buffer;
    }
    case "long": {
      const buffer = Buffer.alloc(9);
      buffer[0] = TYPE_LONG;
      buffer.writeBigInt64BE(BigInt(typed.value), 1);
      return buffer;
    }
    case "double": {
      const buffer = Buffer.alloc(9);
      buffer[0] = TYPE_DOUBLE;
      buffer.writeDoubleBE(typed.value, 1);
      return buffer;
    }
    case "utf": {
      const value = Buffer.from(String(typed.value), "utf8");
      return Buffer.concat([Buffer.from([TYPE_UTF_STRING]), uint16(value.length), value]);
    }
    case "utfArray": {
      const parts = [Buffer.from([TYPE_UTF_STRING_ARRAY]), uint16((typed.value || []).length)];
      for (const item of typed.value || []) {
        const value = Buffer.from(String(item), "utf8");
        parts.push(uint16(value.length), value);
      }
      return Buffer.concat(parts);
    }
    case "sfsObject":
      return encodeSfsObject(typed.value);
    case "sfsArray":
      return encodeSfsArray(typed.value);
    default:
      throw new Error(`Unsupported SFS encode type: ${typed.type}`);
  }
}

function toPlain(typed) {
  if (!typed) return null;
  if (typed.type === "sfsObject") {
    const output = {};
    for (const [key, value] of Object.entries(typed.value || {})) {
      output[key] = toPlain(value);
    }
    return output;
  }
  if (typed.type === "sfsArray") {
    return (typed.value || []).map(toPlain);
  }
  return typed.value;
}

function redact(value, keyHint = null) {
  if (keyHint != null && isSensitiveKey(keyHint)) {
    return "[REDACTED]";
  }
  if (Array.isArray(value)) {
    return value.map((item) => redact(item));
  }
  if (value && typeof value === "object") {
    const output = {};
    for (const [key, child] of Object.entries(value)) {
      output[key] = redact(child, key);
    }
    return output;
  }
  return value;
}

function isSensitiveKey(key) {
  return SENSITIVE_KEYS.has(String(key).toLowerCase());
}

function typedUtf(value) {
  return { type: "utf", value: String(value) };
}

function readUInt16(buffer, offset) {
  ensureAvailable(buffer, offset, 2, "uint16");
  return buffer.readUInt16BE(offset);
}

function ensureAvailable(buffer, offset, length, label) {
  if (offset + length > buffer.length) {
    throw new Error(`${label} exceeds buffer length offset=${offset} length=${length} buffer=${buffer.length}`);
  }
}

function uint16(value) {
  const buffer = Buffer.alloc(2);
  buffer.writeUInt16BE(value, 0);
  return buffer;
}

module.exports = {
  decodePacket,
  encodePacket,
  packetSummary,
  redact,
  rewriteLoginZone,
  toPlain
};
