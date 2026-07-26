const fs = require("fs");
const path = require("path");

const repoRoot = path.resolve(__dirname, "..", "..", "..");
const latestPath = fs.readFileSync(path.join(repoRoot, "server", "logs", "original-proxy", "latest.txt"), "utf8").trim();
const events = fs.readFileSync(latestPath, "utf8").trim().split(/\r?\n/).filter(Boolean).map((line) => JSON.parse(line));
const frames = events.filter((event) => event.kind === "proxy.ws.frame");
const decoded = frames.filter((frame) => frame.payload.sfs && frame.payload.sfs.ok === true);
const undecoded = frames.filter((frame) => frame.payload.sfs && frame.payload.sfs.ok === false);

function table(rows, headers) {
  const lines = [];
  lines.push(`| ${headers.join(" | ")} |`);
  lines.push(`| ${headers.map(() => "---").join(" | ")} |`);
  for (const row of rows) {
    lines.push(`| ${row.map((value) => String(value ?? "").replace(/\|/g, "\\|").replace(/\r?\n/g, "<br>")).join(" | ")} |`);
  }
  return lines.join("\n");
}

function countBy(items, keyFn) {
  const counts = new Map();
  for (const item of items) {
    const value = keyFn(item);
    if (value == null || value === "") continue;
    const key = typeof value === "object" ? JSON.stringify(value) : String(value);
    counts.set(key, (counts.get(key) || 0) + 1);
  }
  return [...counts.entries()].sort((left, right) => right[1] - left[1] || left[0].localeCompare(right[0]));
}

function json(value, depth = 6, max = 900) {
  const text = JSON.stringify(value ?? {}, null, 0);
  return text.length > max ? `${text.slice(0, max)}...` : text;
}

function decodeMap(mapBase64) {
  if (!mapBase64 || typeof mapBase64 !== "string") return null;
  try {
    const xml = Buffer.from(mapBase64, "base64").toString("utf8");
    const tags = {};
    for (const match of xml.matchAll(/<([a-zA-Z0-9_:-]+)/g)) {
      const tag = match[1];
      if (tag === "map") continue;
      tags[tag] = (tags[tag] || 0) + 1;
    }
    return { xmlLength: xml.length, preview: xml.slice(0, 500), tags };
  } catch (error) {
    return { error: error.message };
  }
}

function command(name, direction) {
  return decoded.filter((frame) => {
    const sfs = frame.payload.sfs;
    return sfs.extensionCommand === name && (!direction || frame.payload.direction === direction);
  });
}

function action(actionId) {
  return decoded.filter((frame) => frame.payload.sfs.controller === 0 && frame.payload.sfs.action === actionId);
}

function roomTuple(value) {
  if (!Array.isArray(value)) return null;
  return {
    id: value[0],
    name: value[1],
    group: value[2],
    passwordProtected: value[3],
    game: value[4],
    hidden: value[5],
    userCount: value[6],
    maxUsers: value[7],
    variables: value[8]
  };
}

function variableRows() {
  const variables = new Map();
  function addList(list) {
    if (!Array.isArray(list)) return;
    for (const item of list) {
      if (!Array.isArray(item) || item.length < 3) continue;
      const [name, type, value] = item;
      if (!variables.has(name)) variables.set(name, { name, count: 0, types: new Set(), examples: new Set() });
      const row = variables.get(name);
      row.count += 1;
      row.types.add(type);
      if (row.examples.size < 4) row.examples.add(typeof value === "string" ? value : JSON.stringify(value));
    }
  }

  for (const frame of decoded) {
    const sfs = frame.payload.sfs;
    const params = sfs.params || {};
    if (sfs.controller === 0 && sfs.action === 12) addList(params.vl);
    if (sfs.controller === 0 && sfs.action === 1000 && Array.isArray(params.u)) addList(params.u[4]);
  }

  return [...variables.values()].sort((left, right) => right.count - left.count).map((row) => [
    row.name,
    row.count,
    [...row.types].join(","),
    [...row.examples].join("; ")
  ]);
}

const commandCounts = countBy(decoded.filter((frame) => frame.payload.sfs.extensionCommand), (frame) => frame.payload.sfs.extensionCommand);
const actionCounts = countBy(decoded, (frame) => `c=${frame.payload.sfs.controller} a=${frame.payload.sfs.action}`);
const roomCounts = countBy(decoded.filter((frame) => frame.payload.sfs.roomId != null && typeof frame.payload.sfs.roomId !== "object"), (frame) => frame.payload.sfs.roomId);
const roomAddSamples = action(6).map((frame) => ({ seq: frame.seq, tuple: roomTuple(frame.payload.sfs.params.r) })).filter((item) => item.tuple);
const joinSamples = action(4).slice(0, 8).map((frame) => ({ seq: frame.seq, room: roomTuple(frame.payload.sfs.params.r), params: frame.payload.sfs.params }));
const houseDoorSamples = command("usehousedoor", "server->client").concat(command("usedoor", "server->client")).map((frame) => {
  const payload = frame.payload.sfs.params.p || {};
  const room = payload.room || {};
  return { seq: frame.seq, command: frame.payload.sfs.extensionCommand, room, decodedMap: decodeMap(room.map) };
});

const report = `# Room State Capture Analysis - 2026-05-31

Source: \`${latestPath}\`

## Capture Health

${table([
  ["events", events.length],
  ["frames", frames.length],
  ["decoded", decoded.length],
  ["undecoded", undecoded.length],
  ["client -> server", frames.filter((frame) => frame.payload.direction === "client->server").length],
  ["server -> client", frames.filter((frame) => frame.payload.direction === "server->client").length]
], ["metric", "value"])}

## Top Commands

${table(commandCounts.slice(0, 35).map(([name, count]) => [name, count]), ["command", "count"])}

## System Actions

${table(actionCounts.slice(0, 20).map(([name, count]) => [name, count]), ["action", "count"])}

## Room Ids Seen

${table(roomCounts.slice(0, 40).map(([roomId, count]) => [roomId, count]), ["roomId", "count"])}

## Room Tuple Shape

System action \`6\` and some action \`4\` payloads carry room tuples:

\`[id, name, group, passwordProtected, game, hidden, userCount, maxUsers, variables]\`

Examples:

${table(roomAddSamples.slice(0, 12).map((item) => [item.seq, json(item.tuple, 6, 450)]), ["seq", "room tuple"])}

## Room Join / Street State

Action \`4\` is the large room-join state path. It can contain a room tuple plus room/user variables, depending on join type.

${table(joinSamples.map((item) => [item.seq, json(item.room || item.params, 8, 700)]), ["seq", "payload"])}

## Door / Map Payloads

\`usedoor\` / \`usehousedoor\` responses can include room map data. \`room.map\` is Base64 XML, not hex.

${table(houseDoorSamples.slice(0, 12).map((item) => [
  item.seq,
  item.command,
  item.room.key || "",
  item.room.roomType || "",
  item.room.roomName || "",
  item.room.doorKey || "",
  item.decodedMap ? item.decodedMap.xmlLength || "" : "",
  item.decodedMap ? json(item.decodedMap.tags, 4, 250) : ""
]), ["seq", "cmd", "key", "roomType", "roomName", "doorKey", "mapXmlLength", "mapTags"])}

## User Variable Schema

User enter action \`1000\` and user variable action \`12\` use the same variable tuple shape:

\`[name, typeId, value, isPrivate]\`

${table(variableRows().slice(0, 35), ["name", "count", "typeIds", "examples"])}

## Current Understanding

- The data that looked like “hex” was SmartFox binary framing. Room maps themselves are Base64 XML in fields such as \`room.map\`.
- SmartFox header flags are: \`0x40 encrypted\`, \`0x20 compressed\`, \`0x10 blueBoxed\`, \`0x08 bigSized\`.
- The latest fixed proxy decodes the currently captured room/user-state frames. If future true encrypted frames appear, CryptoManager support is already wired and key/IV order now matches the recovered client.
- To build our server, the critical room contracts are: room tuple shape, room variable/user variable tuple shape, door response \`room\` object, \`walkrequest\`/\`walkfinalrequest\`, and room join action \`4\`.
`;

const outDir = path.join(repoRoot, "docs", "captures");
fs.mkdirSync(outDir, { recursive: true });
const outPath = path.join(outDir, "room-state-capture-2026-05-31.md");
fs.writeFileSync(outPath, report, "utf8");
console.log(outPath);