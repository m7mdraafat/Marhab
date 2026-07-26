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

const fs = require("fs");
const path = require("path");
const streets = require("../data/streets-1-13.json");

const DEFAULT_ROOM_KEY = "street01";
const DEFAULT_ROOM_ID = 1;
const DEFAULT_ROOM_GROUP = "default";
const DEFAULT_ROOM_CAPACITY = 50;
const DEFAULT_SCREEN_WIDTH = 800;
const DEFAULT_SCREEN_HEIGHT = 515;
const ALL_AVATAR_PERMISSIONS = [
  2, 3, 4, 5, 6, 7, 8,
  9, 10, 11, 12, 13, 14, 15, 16,
  17, 18, 19, 20, 21, 22, 23, 24,
  25, 26, 27, 29, 30, 31, 32,
  40, 41, 42, 43, 45, 46, 47, 48,
  49, 50
];
const VIP_CARD_ITEMS = [
  { id: 100001, productID: 100001, clip: "vip", subType: "VIP", role: 4 },
  { id: 100002, productID: 100002, clip: "vip_gold", subType: "VIP_GOLD", role: 5 },
  { id: 100003, productID: 100003, clip: "vip_diamond", subType: "VIP_DIAMOND", role: 7 },
  { id: 100004, productID: 100004, clip: "vip_silver", subType: "VIP_SILVER", role: 8 },
  { id: 100005, productID: 100005, clip: "diamond_club", subType: "DIAMOND_CLUB", role: 14 },
  { id: 100006, productID: 100006, clip: "card_security", subType: "CARD_SECURITY", role: 16 },
  { id: 100007, productID: 100007, clip: "card_journalist", subType: "CARD_JOURNALIST", role: 18 },
  { id: 100008, productID: 100008, clip: "card_director", subType: "CARD_DIRECTOR", role: 19 },
  { id: 100009, productID: 100009, clip: "card_photographer", subType: "CARD_PHOTOGRAPHER", role: 21 },
  { id: 100010, productID: 100010, clip: "card_painter", subType: "CARD_PAINTER", role: 23 },
  { id: 100011, productID: 100011, clip: "card_actor", subType: "CARD_ACTOR", role: 27 },
  { id: 100012, productID: 100012, clip: "card_guide", subType: "CARD_GUIDE", role: 29 },
  { id: 100013, productID: 100013, clip: "card_sanalikax", subType: "CARD_SANALIKAX", role: 32 },
  { id: 100014, productID: 100014, clip: "card_music", subType: "CARD_MUSIC", role: 43 },
  { id: 100015, productID: 100015, clip: "ship_license", subType: "SHIP_LICENSE", role: 46 },
  { id: 100016, productID: 100016, clip: "card_capitan", subType: "CARD_CAPITAN", role: 47 }
];
const repoRoot = path.resolve(__dirname, "..", "..", "..");
const clothesRoot = path.join(repoRoot, "assets", "cdn", "global", "static", "items", "clothes");
let cachedClothItemsByGender = null;
let nextRid = 1;

const sfs = {
  null: () => ({ type: "null" }),
  bool: (value) => ({ type: "bool", value }),
  byte: (value) => ({ type: "byte", value }),
  short: (value) => ({ type: "short", value }),
  int: (value) => ({ type: "int", value }),
  long: (value) => ({ type: "long", value }),
  double: (value) => ({ type: "double", value }),
  utf: (value) => ({ type: "utf", value }),
  utfArray: (value) => ({ type: "utfArray", value }),
  object: (value) => ({ type: "sfsObject", value }),
  array: (value) => ({ type: "sfsArray", value })
};

const devAvatar = {
  created: true,
  id: 1,
  name: "dev-user",
  gender: "m",
  clothes: [
    { clip: "A", color: 1 },
    { clip: "B", color: 1 },
    { clip: "C", color: 1 },
    { clip: "13", color: 3 },
    { clip: "2", color: 5 },
    { clip: "6", color: 6 },
    { clip: "7", color: 1 }
  ]
};

const avatarState = {
  roomKey: DEFAULT_ROOM_KEY,
  position: "29,16",
  target: "29,16",
  direction: 1,
  status: "i"
};

const VARIABLE_TYPE_BOOL = 1;
const VARIABLE_TYPE_INT = 2;
const VARIABLE_TYPE_DOUBLE = 3;
const VARIABLE_TYPE_STRING = 4;

function objectToSfs(value) {
  if (value === null || value === undefined) {
    return sfs.null();
  }

  if (Array.isArray(value)) {
    return sfs.array(value.map(objectToSfs));
  }

  if (typeof value === "boolean") {
    return sfs.bool(value);
  }

  if (typeof value === "number") {
    if (!Number.isInteger(value)) {
        return sfs.double(value);
    }

    if (value < -2147483648 || value > 2147483647) {
        return sfs.long(value);
    }

    return sfs.int(value);
  }
  if (typeof value === "object") {
    const fields = {};
    for (const [key, child] of Object.entries(value)) {
      fields[key] = objectToSfs(child);
    }
    return sfs.object(fields);
  }

  return sfs.utf(String(value));
}


function decodePacket(frame) {
  if (frame.length < 3) {
    throw new Error(`SFS packet too short: ${frame.length}`);
  }

  const header = frame[0];
  if ((header & 0x80) === 0) {
    throw new Error(`Invalid SFS packet header: 0x${header.toString(16)}`);
  }

  const bigSized = (header & 0x08) !== 0;
  const encrypted = (header & 0x20) !== 0;
  const compressed = (header & 0x10) !== 0;

  if (encrypted || compressed) {
    throw new Error(`Unsupported SFS packet flags encrypted=${encrypted} compressed=${compressed}`);
  }

  let offset;
  let length;

  if (bigSized) {
    if (frame.length < 5) throw new Error("Big-sized SFS packet missing length");
    length = frame.readUInt32BE(1);
    offset = 5;
  } else {
    length = frame.readUInt16BE(1);
    offset = 3;
  }

  const payload = frame.subarray(offset, offset + length);
  if (payload.length !== length) {
    throw new Error(`SFS packet length mismatch expected=${length} actual=${payload.length}`);
  }

  return { header, length, payload, object: decodeSfsObject(payload) };
}

function encodePacket(object) {
  const payload = encodeSfsObject(object);
  const header = Buffer.from([0x80]);

  if (payload.length > 0xffff) {
    const size = Buffer.alloc(4);
    size.writeUInt32BE(payload.length, 0);
    header[0] |= 0x08;
    return Buffer.concat([header, size, payload]);
  }

  const size = Buffer.alloc(2);
  size.writeUInt16BE(payload.length, 0);
  return Buffer.concat([header, size, payload]);
}

function decodeSfsObject(buffer, startOffset = 0) {
  let offset = startOffset;
  const type = buffer[offset++];

  if (type !== TYPE_SFS_OBJECT) {
    throw new Error(`Expected SFS_OBJECT type 18, got ${type}`);
  }

  const fieldCount = buffer.readUInt16BE(offset);
  offset += 2;

  const value = {};

  for (let index = 0; index < fieldCount; index++) {
    const keyLength = buffer.readUInt16BE(offset);
    offset += 2;

    const key = buffer.subarray(offset, offset + keyLength).toString("utf8");
    offset += keyLength;

    const decoded = decodeTypedValue(buffer, offset);
    offset = decoded.offset;
    value[key] = decoded.value;
  }

  return { value, offset };
}

function decodeSfsArray(buffer, startOffset = 0) {
  let offset = startOffset;
  const type = buffer[offset++];

  if (type !== TYPE_SFS_ARRAY) {
    throw new Error(`Expected SFS_ARRAY type 17, got ${type}`);
  }

  const itemCount = buffer.readUInt16BE(offset);
  offset += 2;

  const value = [];

  for (let index = 0; index < itemCount; index++) {
    const decoded = decodeTypedValue(buffer, offset);
    offset = decoded.offset;
    value.push(decoded.value);
  }

  return { value, offset };
}

function decodeTypedValue(buffer, offset) {
  const type = buffer[offset++];

  switch (type) {
    case TYPE_NULL:
      return { value: null, offset };
    case TYPE_BOOL:
      return { value: buffer[offset++] !== 0, offset };
    case TYPE_BYTE:
      return { value: buffer.readInt8(offset), offset: offset + 1 };
    case TYPE_SHORT:
      return { value: buffer.readInt16BE(offset), offset: offset + 2 };
    case TYPE_INT:
      return { value: buffer.readInt32BE(offset), offset: offset + 4 };
    case TYPE_LONG: {
      const value = Number(buffer.readBigInt64BE(offset));
      return { value, offset: offset + 8 };
    }
    case TYPE_DOUBLE:
      return { value: buffer.readDoubleBE(offset), offset: offset + 8 };
    case TYPE_UTF_STRING: {
      const length = buffer.readUInt16BE(offset);
      offset += 2;
      const value = buffer.subarray(offset, offset + length).toString("utf8");
      return { value, offset: offset + length };
    }
    case TYPE_SFS_OBJECT:
      return decodeSfsObject(buffer, offset - 1);
    case TYPE_SFS_ARRAY:
      return decodeSfsArray(buffer, offset - 1);
    default:
      throw new Error(`Unsupported SFS type ${type} at offset ${offset - 1}`);
  }
}

function encodeSfsArray(items) {
  const parts = [Buffer.from([TYPE_SFS_ARRAY]), uint16(items.length)];

  for (const item of items) {
    parts.push(encodeTypedValue(item));
  }

  return Buffer.concat(parts);
}

function encodeSfsObject(fields) {
  const entries = Object.entries(fields);
  const parts = [Buffer.from([TYPE_SFS_OBJECT]), uint16(entries.length)];

  for (const [key, typed] of entries) {
    const keyBuffer = Buffer.from(key, "utf8");
    parts.push(uint16(keyBuffer.length));
    parts.push(keyBuffer);
    parts.push(encodeTypedValue(typed));
  }

  return Buffer.concat(parts);
}

function encodeTypedValue(typed) {
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
    case "utf": {
      const value = Buffer.from(String(typed.value), "utf8");
      return Buffer.concat([Buffer.from([TYPE_UTF_STRING]), uint16(value.length), value]);
    }
    case "double": {
      const buffer = Buffer.alloc(9);
      buffer[0] = TYPE_DOUBLE;
      buffer.writeDoubleBE(typed.value, 1);
      return buffer;
    }
    case "utfArray": {
      const values = typed.value || [];
      const parts = [Buffer.from([TYPE_UTF_STRING_ARRAY]), uint16(values.length)];  
      for (const value of values) {
          const text = Buffer.from(String(value), "utf8");
          parts.push(uint16(text.length));
          parts.push(text);
      }  
      return Buffer.concat(parts);
    }
    case "sfsObject":
      return encodeSfsObject(typed.value);
    case "sfsArray":
      return encodeSfsArray(typed.value || []);
    default:
      throw new Error(`Unsupported SFS encode type: ${typed.type}`);
  }
}

function uint16(value) {
  const buffer = Buffer.alloc(2);
  buffer.writeUInt16BE(value, 0);
  return buffer;
}

function packetSummary(packet) {
  const root = packet.object.value;
  return {
    controller: root.c,
    action: root.a,
    params: root.p
  };
}

function buildHandshakeResponse() {
  return encodePacket({
    c: { type: "byte", value: 0 },
    a: { type: "short", value: 0 },
    p: {
      type: "sfsObject",
      value: {
        tk: { type: "utf", value: `dev-session-${Date.now()}` },
        ct: { type: "int", value: 2000000 },
        ms: { type: "int", value: 10000 }
      }
    }
  });
}

function buildLoginResponse() {
  return encodePacket({
    c: { type: "byte", value: 0 },
    a: { type: "short", value: 1 },
    p: {
      type: "sfsObject",
      value: {
        zn: { type: "utf", value: "local" },
        un: { type: "utf", value: String(devAvatar.id) },
        id: { type: "int", value: 1 },
        pi: { type: "short", value: 1 },
        rl: { type: "sfsArray", value: [] }
      }
    }
  });
}

function buildExtensionResponse(command, payload) {
  return encodePacket({
    c: sfs.byte(1),
    a: sfs.short(13),
    p: sfs.object({
      c: sfs.utf(command),
      p: objectToSfs(payload)
    })
  });
}

function responseMeta(nextRequest = 1000) {
  return {
    ts: Math.floor(Date.now() / 1000),
    rid: nextRid++,
    nextRequest
  };
}

function roomSpec(roomKey = DEFAULT_ROOM_KEY) {
  const spec = streets.rooms[roomKey] || streets.rooms[DEFAULT_ROOM_KEY];
  if (!spec || !spec.present) {
    return streets.rooms[DEFAULT_ROOM_KEY];
  }
  return spec;
}

function specKey(spec) {
  for (const [key, value] of Object.entries(streets.rooms)) {
    if (value === spec) {
      return key;
    }
  }
  return DEFAULT_ROOM_KEY;
}

function defaultDoor(spec) {
  return spec.doors.find((door) => door.key === spec.defaultDoorKey) || spec.doors[0];
}

function defaultSpawn(roomKey = DEFAULT_ROOM_KEY) {
  if (roomKey === DEFAULT_ROOM_KEY) {
    return { position: "29,16", direction: 1 };
  }
  return null;
}

function roomEnvelope(roomKey = DEFAULT_ROOM_KEY) {
  const spec = roomSpec(roomKey);
  return {
    room: {
      map: spec.mapBase64,
      doorKey: spec.defaultDoorKey || "d1"
    }
  };
}

function currentClothesJson() {
  return JSON.stringify(toClothKeys(devAvatar.clothes));
}

function encodePermissionRoles(indexes) {
  const maxIndex = Math.max(0, ...indexes);
  const buffer = Buffer.alloc(Math.ceil(maxIndex / 8));
  for (const index of indexes) {
    const byteIndex = Math.ceil(index / 8) - 1;
    const bitIndex = index % 8 - 1;
    buffer[byteIndex] |= bitIndex === -1 ? 1 << 7 : 1 << bitIndex;
  }
  return buffer.toString("base64");
}

function buildInventoryItem({ id, productID, clip, subType = "CARD", role }) {
  return {
    id,
    productID,
    clip,
    subType,
    transferrable: false,
    lifeTime: 0,
    timeLeft: 0,
    expire: 0,
    createdAt: new Date(0).toISOString(),
    quantity: 1,
    active: 1,
    base: 0,
    color: 0,
    source: "LOCAL",
    roles: encodePermissionRoles([role])
  };
}

function toProfileCard(item) {
  return {
    clip: item.clip,
    expire: 0,
    productID: item.productID,
    quantity: 1,
    subType: item.subType
  };
}

function getAllLocalClothItems(gender = devAvatar.gender) {
  if (cachedClothItemsByGender == null) {
    cachedClothItemsByGender = {};
  }
  if (cachedClothItemsByGender[gender]) {
    return cachedClothItemsByGender[gender];
  }
  const prefix = `${gender}_`;
  let id = 1;
  const items = fs.readdirSync(clothesRoot)
    .filter((name) => name.startsWith(prefix) && name.endsWith(".swf"))
    .sort((left, right) => left.localeCompare(right, "en", { numeric: true }))
    .map((name) => ({
      id: id++,
      quantity: 1,
      active: true,
      base: false,
      clip: name.slice(prefix.length, -4)
    }));
  cachedClothItemsByGender[gender] = items;
  return items;
}

function roomVariable(name, type, value) {
  return sfs.array([
    sfs.utf(name),
    sfs.byte(type),
    value,
    sfs.bool(false),
    sfs.bool(false)
  ]);
}

function userVariable(name, type, value) {
  return sfs.array([
    sfs.utf(name),
    sfs.byte(type),
    value,
    sfs.bool(false)
  ]);
}

function buildRoomArray(spec) {
  const bots = Array.isArray(spec.bots) ? JSON.stringify(spec.bots) : "[]";
  const variables = [
    roomVariable("roomKey", VARIABLE_TYPE_STRING, sfs.utf(specKey(spec))),
    roomVariable("width", VARIABLE_TYPE_INT, sfs.int(DEFAULT_SCREEN_WIDTH)),
    roomVariable("height", VARIABLE_TYPE_INT, sfs.int(DEFAULT_SCREEN_HEIGHT)),
    roomVariable("grid", VARIABLE_TYPE_STRING, sfs.utf(spec.grid.base64)),
    roomVariable("doors", VARIABLE_TYPE_STRING, sfs.utf(JSON.stringify(spec.doors))),
    roomVariable("bots", VARIABLE_TYPE_STRING, sfs.utf(bots))
  ];

  return sfs.array([
    sfs.int(DEFAULT_ROOM_ID),
    sfs.utf(`local#${specKey(spec)}`),
    sfs.utf(DEFAULT_ROOM_GROUP),
    sfs.bool(false),
    sfs.bool(false),
    sfs.bool(false),
    sfs.short(1),
    sfs.short(DEFAULT_ROOM_CAPACITY),
    sfs.array(variables)
  ]);
}

function buildUserArray() {
  const variables = [
    userVariable("gender", VARIABLE_TYPE_STRING, sfs.utf(devAvatar.gender)),
    userVariable("clothes", VARIABLE_TYPE_STRING, sfs.utf(currentClothesJson())),
    userVariable("roles", VARIABLE_TYPE_STRING, sfs.utf(encodePermissionRoles(ALL_AVATAR_PERMISSIONS))),
    userVariable("speed", VARIABLE_TYPE_DOUBLE, sfs.double(5)),
    userVariable("avatarSize", VARIABLE_TYPE_DOUBLE, sfs.double(1)),
    userVariable("position", VARIABLE_TYPE_STRING, sfs.utf(avatarState.position)),
    userVariable("target", VARIABLE_TYPE_STRING, sfs.utf(avatarState.target)),
    userVariable("direction", VARIABLE_TYPE_INT, sfs.int(avatarState.direction)),
    userVariable("status", VARIABLE_TYPE_STRING, sfs.utf(avatarState.status))
  ];

  return sfs.array([
    sfs.int(devAvatar.id),
    sfs.utf(String(devAvatar.id)),
    sfs.short(1),
    sfs.short(1),
    sfs.array(variables)
  ]);
}

function setSpawn(roomKey = DEFAULT_ROOM_KEY, doorKey) {
  const spec = roomSpec(roomKey);
  const spawn = defaultSpawn(specKey(spec));
  if (spawn && (!doorKey || doorKey === spec.defaultDoorKey)) {
    avatarState.position = spawn.position;
    avatarState.target = spawn.position;
    avatarState.direction = spawn.direction;
    avatarState.status = "i";
    avatarState.roomKey = specKey(spec);
    return;
  }
  const door = spec.doors.find((item) => item.key === doorKey) || defaultDoor(spec);
  if (door) {
    avatarState.position = `${door.targetX},${door.targetY}`;
    avatarState.target = avatarState.position;
  }
  avatarState.direction = roomKey === DEFAULT_ROOM_KEY && (!doorKey || doorKey === "d1") ? 1 : (door && door.targetDir) || 1;
  avatarState.status = "i";
  avatarState.roomKey = specKey(spec);
}

function buildRoomJoinResponse(roomKey = DEFAULT_ROOM_KEY, doorKey) {
  setSpawn(roomKey, doorKey);
  const spec = roomSpec(roomKey);
  return encodePacket({
    c: sfs.byte(0),
    a: sfs.short(4),
    p: sfs.object({
      r: buildRoomArray(spec),
      ul: sfs.array([buildUserArray()])
    })
  });
}

function buildUserVariablesUpdate(vars) {
  return encodePacket({
    c: sfs.byte(0),
    a: sfs.short(12),
    p: sfs.object({
      u: sfs.int(devAvatar.id),
      vl: sfs.array(vars)
    })
  });
}

function directionFromMove(from, to) {
  const [fromX, fromY] = from.split(",").map(Number);
  const dx = Math.sign(to.x - fromX);
  const dy = Math.sign(to.y - fromY);
  const vectors = ["1,0", "1,-1", "0,-1", "-1,-1", "-1,0", "-1,1", "0,1", "1,1"];
  const index = vectors.indexOf(`${dx},${dy}`);
  return index >= 0 ? index + 1 : avatarState.direction;
}

function buildWalkRequestResponses(data = {}) {
  const [currentX, currentY] = avatarState.position.split(",").map(Number);
  const target = {
    x: Number.isFinite(Number(data.x)) ? Number(data.x) : currentX,
    y: Number.isFinite(Number(data.y)) ? Number(data.y) : currentY
  };
  const position = `${target.x},${target.y}`;
  avatarState.direction = directionFromMove(avatarState.position, target);
  avatarState.target = position;
  avatarState.position = position;
  avatarState.status = "i";

  return [
    buildUserVariablesUpdate([
      userVariable("target", VARIABLE_TYPE_STRING, sfs.utf(avatarState.target)),
      userVariable("position", VARIABLE_TYPE_STRING, sfs.utf(avatarState.position)),
      userVariable("direction", VARIABLE_TYPE_INT, sfs.int(avatarState.direction)),
      userVariable("status", VARIABLE_TYPE_STRING, sfs.utf(avatarState.status))
    ]),
    buildExtensionResponse("walkrequest", { ok: true })
  ];
}

function buildRoomJoinCompleteResponse() {
  return buildExtensionResponse("roomjoincomplete", {});
}

function buildTeleportResponses(payload = {}) {
  const spec = roomSpec(payload.roomKey || DEFAULT_ROOM_KEY);
  const key = specKey(spec);
  return [
    buildExtensionResponse("teleport", roomEnvelope(key)),
    buildRoomJoinResponse(key)
  ];
}

function buildConfigResponse(options = {}) {
  const fileServer = options.fileServer || "127.0.0.1:8081";
  const webServer = options.webServer || "http://127.0.0.1:8080";

  return buildExtensionResponse("config", {
    moods: [
      { id: 1, label: "Happy" },
      { id: 2, label: "Cool" }
    ],
    chatBaloons: [],
    itemFile: "data/ifile.1366",
    versionFile: "data/vf.403",
    langFile: "locale/ar",
    fileServer: [fileServer],
    webServer,
    language: "ar",
    roomTheme: [],
    farmCleaningCost: 5,
    farmMaxPlantedItemSize: 9,
    order: {
      avatarOrderLifeTime: 300,
      orderLifeTime: 300,
      prepareLifeTime: 300
    },
    masterRoles: []
  });
}

function buildInitResponse() {
  const created = devAvatar.created;
  const gender = created ? devAvatar.gender : "m";
  setSpawn(DEFAULT_ROOM_KEY, "d1");

  return buildExtensionResponse("init", {
    ts: Date.now(),

    selectedAvatarID: devAvatar.id,
    email: "dev@example.local",

    deactivationReason: null,
    banData: null,

    extensionInfo: [],
    settings: {
      wideMode: 0,
      showInvitations: 1,
      transferRequests: 1,
      incomingMessages: 1,
      tradeRequests: 1,
      whisperMessage: 1,
      flatNotifications: 1,
      onlyBuddyWhisper: 0,
      verifySession: 0
    },

    bans: [],
    orderRequest: null,
    fbToken: "local",

    gender,
    guest: false,
    completedAchievementsCount: 0,

    // Before avatarcreate, open full avatar-create mode. After avatarcreate,
    // allow the client to continue bootstrapping toward room load.
    checkAvatar: 1,
    createAvatar: false,
    roomKey: DEFAULT_ROOM_KEY,
    ...roomEnvelope(DEFAULT_ROOM_KEY),

    wallet: [
      { currency: "SANIL", balance: 0 },
      { currency: "DIAMOND", balance: 0 },
      { currency: "PEPSICOIN", balance: 0 }
    ],

    clothes: {
      items: created ? toClothItems(devAvatar.clothes) : []
    }
  });
}

function buildPingResponse() {
  return buildExtensionResponse("ping", {
    ts: Date.now(),
    ok: true
  });
}

function buildClothListResponse() {
  return buildExtensionResponse("clothlist", {
    type: "CLOTH",
    ...responseMeta(),
    items: getAllLocalClothItems(devAvatar.gender)
  });
}

function buildQuestListResponse() {
  return buildExtensionResponse("questlist", {});
}

function buildCardListResponse() {
  const cards = VIP_CARD_ITEMS.map(buildInventoryItem);
  return buildExtensionResponse("cardlist", {
    type: "CARD",
    ...responseMeta(),
    items: cards
  });
}

function buildProfileResponse(payload = {}) {
  const avatarID = payload.avatarID || String(devAvatar.id);
  return buildExtensionResponse("profile", {
    ...responseMeta(),
    avatarName: avatarID === String(devAvatar.id) ? devAvatar.name : `Avatar ${avatarID}`,
    avatarAge: 26,
    avatarCity: "Local",
    avarageRating: "0",
    badges: [],
    banCount: 0,
    cards: VIP_CARD_ITEMS.map(toProfileCard),
    dislikeCount: 0,
    duration: 0,
    emailRegistered: 1,
    flats: [],
    hasBestFriend: false,
    isBuddy: false,
    isRequest: false,
    likeCount: 0,
    mood: 1,
    nameColor: "FF6600",
    nameFont: "Arial",
    privilegeId: 1,
    runWinTeam: "",
    skin: {
      clip: "default",
      property: {
        cn: "",
        alpha: "1",
        bgColor: "FFFFFF",
        textColor: "333333"
      }
    },
    status: "Local profile",
    stickers: [],
    totalBuddies: 0
  });
}

function buildProfileLikeResponse() {
  return buildExtensionResponse("profilelike", {
    ...responseMeta(2000),
    likeCount: 1,
    dislikeCount: 0
  });
}

function buildChangeClothesResponses(payload = {}) {
  const selectedIds = Array.isArray(payload.clothes) ? payload.clothes.map(Number) : [];
  const itemsById = new Map(getAllLocalClothItems(devAvatar.gender).map((item) => [item.id, item]));
  const selectedClothes = selectedIds
    .map((id) => itemsById.get(id))
    .filter(Boolean)
    .map((item) => ({ clip: item.clip }));

  if (selectedClothes.length > 0) {
    devAvatar.clothes = selectedClothes;
  }

  return [
    buildExtensionResponse("changeclothes", {
      ...responseMeta(),
      status: "success",
      message: "Clothes changed successfully"
    }),
    buildUserVariablesUpdate([
      userVariable("clothes", VARIABLE_TYPE_STRING, sfs.utf(currentClothesJson()))
    ])
  ];
}

function buildHandItemListResponse() {
  return buildExtensionResponse("handitemlist", {
    items: [],
    handItems: [],
    list: [],
    page: 1,
    pageCount: 0,
    total: 0
  });
}

function buildSpecialItemListResponse() {
  return buildExtensionResponse("specialitemlist", {
    items: [],
    specialItems: [],
    list: [],
    page: 1,
    pageCount: 0,
    total: 0
  });
}

function buildAchievementListResponse() {
  return buildExtensionResponse("achievementlist", {
    achievements: [],
    items: [],
    list: [],
    rewardCount: 0,
    completedAchievementsCount: 0
  });
}

function buildUniverseListResponse() {
  return buildExtensionResponse("universelist", {
    universes: [],
    universeList: [],
    rooms: [],
    list: []
  });
}

function buildSmileyListResponse() {
  return buildExtensionResponse("smileylist", {
    smilies: [],
    smileys: [],
    items: []
  });
}

function buildGenericOkResponse(command) {
  return buildExtensionResponse(command, {
    ok: true,
    items: [],
    list: []
  });
}

function buildBuddyListResponse() {
  return buildExtensionResponse("buddylist", {
    buddies: [],
    requests: []
  });
}

function baseCloth(placeBit, clip, colors) {
  const item = { placeBit, clip };
  if (colors) {
    item.colors = colors;
  }
  return item;
}

function buildBaseClothesResponse() {
  // These are the complete A/B/C body color sets currently present in the local CDN.
  const skinColors = [1, 2, 8, 12];

  return buildExtensionResponse("baseclothes", {
    m: [
      baseCloth(1, "A", skinColors),
      baseCloth(2, "B", skinColors),
      baseCloth(4, "C", skinColors),
      baseCloth(131072, "13", [3]),
      baseCloth(512, "2", [5]),
      baseCloth(64, "6", [6]),
      baseCloth(16, "7", [1])
    ],
    f: [
      baseCloth(1, "A", skinColors),
      baseCloth(2, "B", skinColors),
      baseCloth(4, "C", skinColors),
      baseCloth(131072, "11", [6]),
      baseCloth(512, "7", [10]),
      baseCloth(64, "3", [7]),
      baseCloth(16, "5", [1])
    ]
  });
}

function toClothItems(clothes) {
  return (clothes || []).map((item, index) => ({
    id: index + 1,
    quantity: 1,
    active: true,
    base: true,
    clip: item.color != null ? `${item.clip}_${item.color}` : item.clip
  }));
}

function toClothKeys(clothes) {
  return (clothes || []).map((item) => item.color != null ? `${item.clip}_${item.color}` : item.clip);
}

function saveAvatarFromPayload(payload) {
  const data = payload || {};
  devAvatar.created = true;
  devAvatar.name = data.avatarName || devAvatar.name;
  devAvatar.gender = data.gender || devAvatar.gender;
  devAvatar.clothes = Array.isArray(data.clothes) ? data.clothes : [];
  return devAvatar;
}

function buildAvatarCreateResponse(payload) {
  saveAvatarFromPayload(payload);
  return buildExtensionResponse("avatarcreate", {
    avatarID: devAvatar.id
  });
}

function buildSaveBaseClothesResponse(payload) {
  saveAvatarFromPayload(payload);
  return buildExtensionResponse("savebaseclothes", {
    avatarID: devAvatar.id
  });
}

module.exports = {
  buildAchievementListResponse,
  buildAvatarCreateResponse,
  buildBaseClothesResponse,
  buildBuddyListResponse,
  buildCardListResponse,
  buildChangeClothesResponses,
  buildClothListResponse,
  buildConfigResponse,
  buildGenericOkResponse,
  buildHandItemListResponse,
  buildHandshakeResponse,
  buildInitResponse,
  buildLoginResponse,
  buildPingResponse,
  buildProfileLikeResponse,
  buildProfileResponse,
  buildQuestListResponse,
  buildRoomJoinCompleteResponse,
  buildRoomJoinResponse,
  buildSaveBaseClothesResponse,
  buildSmileyListResponse,
  buildSpecialItemListResponse,
  buildTeleportResponses,
  buildUniverseListResponse,
  buildWalkRequestResponses,
  decodePacket,
  encodePacket,
  packetSummary
};