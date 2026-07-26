const crypto = require("crypto");
const fs = require("fs");
const http = require("http");
const path = require("path");
const {
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
  buildSaveBaseClothesResponse,
  buildSmileyListResponse,
  buildSpecialItemListResponse,
  buildUniverseListResponse,
  decodePacket,
  packetSummary
} = require("./sfs-codec");

const HOST = process.env.PROBE_HOST || "127.0.0.1";
const PORT = Number(process.env.PROBE_PORT || 8080);
const CDN_HOST = process.env.CDN_HOST || "127.0.0.1";
const CDN_PORT = Number(process.env.CDN_PORT || 8081);

const repoRoot = path.resolve(__dirname, "..", "..", "..");
const logDir = path.join(repoRoot, "server", "logs");
fs.mkdirSync(logDir, { recursive: true });

const logFile = path.join(
  logDir,
  `probe-${new Date().toISOString().replace(/[:.]/g, "-")}.log`
);

function log(message) {
  const line = `${new Date().toISOString()} ${message}`;
  console.log(line);
  fs.appendFileSync(logFile, `${line}\n`, "utf8");
}

function previewBuffer(buffer) {
  const text = buffer
    .toString("utf8")
    .replace(/\0/g, "\\0")
    .replace(/\r/g, "\\r")
    .replace(/\n/g, "\\n");

  return text.length > 300 ? `${text.slice(0, 300)}...` : text;
}

function hexDump(buffer, maxBytes = 512) {
  const slice = buffer.subarray(0, maxBytes);
  const hex = slice.toString("hex").match(/.{1,2}/g)?.join(" ") || "";
  return buffer.length > maxBytes ? `${hex} ... (${buffer.length} bytes total)` : hex;
}

function writeHttp(res, statusCode, contentType, body) {
  res.writeHead(statusCode, {
    "Content-Type": contentType,
    "Content-Length": Buffer.byteLength(body),
    "Connection": "close"
  });
  res.end(body);
}

const crossdomainXml = `<?xml version="1.0"?>
<cross-domain-policy>
  <allow-access-from domain="*" to-ports="${PORT}"/>
</cross-domain-policy>
`;

const server = http.createServer((req, res) => {
  log(`[HTTP] ${req.method} ${req.url} from ${req.socket.remoteAddress}:${req.socket.remotePort}`);
  log(`[HTTP] headers ${JSON.stringify(req.headers)}`);

  if (req.method === "GET" && req.url === "/crossdomain.xml") {
    log("[HTTP] serving crossdomain.xml");
    writeHttp(res, 200, "text/x-cross-domain-policy", crossdomainXml);
    return;
  }

  if (req.method === "GET" && req.url === "/") {
    writeHttp(res, 200, "text/plain", "mygame protocol probe\n");
    return;
  }

  writeHttp(res, 404, "text/plain", "not found\n");
});

server.on("upgrade", (req, socket) => {
  log(`[WS] upgrade ${req.url} from ${socket.remoteAddress}:${socket.remotePort}`);
  log(`[WS] headers ${JSON.stringify(req.headers)}`);

  const key = req.headers["sec-websocket-key"];
  if (!key) {
    log("[WS] missing sec-websocket-key; closing");
    socket.destroy();
    return;
  }

  const accept = crypto
    .createHash("sha1")
    .update(`${key}258EAFA5-E914-47DA-95CA-C5AB0DC85B11`)
    .digest("base64");

  socket.write(
    [
      "HTTP/1.1 101 Switching Protocols",
      "Upgrade: websocket",
      "Connection: Upgrade",
      `Sec-WebSocket-Accept: ${accept}`,
      "",
      ""
    ].join("\r\n")
  );

  log("[WS] accepted");

  let pending = Buffer.alloc(0);

  socket.on("data", (chunk) => {
    pending = Buffer.concat([pending, chunk]);
    pending = parseWebSocketFrames(socket, pending);
  });

  socket.on("close", () => {
    log("[WS] closed");
  });

  socket.on("error", (error) => {
    log(`[WS] socket error ${error.stack || error.message}`);
  });
});

server.on("clientError", (error, socket) => {
  log(`[HTTP] clientError ${error.message}`);

  if (error.rawPacket) {
    log(`[HTTP] rawPacket hex=${hexDump(error.rawPacket)}`);
    log(`[HTTP] rawPacket utf8="${previewBuffer(error.rawPacket)}"`);
  }

  try {
    socket.end("HTTP/1.1 400 Bad Request\r\nConnection: close\r\n\r\n");
  } catch {
    socket.destroy();
  }
});

server.on("error", (error) => {
  if (error.code === "EADDRINUSE" || error.code === "EACCES") {
    log(`[BOOT] failed to listen on http://${HOST}:${PORT}: ${error.message}`);
    log("[BOOT] stop the existing listener or rerun with PROBE_PORT set to a free port");
    process.exit(1);
  }

  throw error;
});

server.listen(PORT, HOST, () => {
  log(`[BOOT] protocol probe listening on http://${HOST}:${PORT}`);
  log(`[BOOT] log file ${logFile}`);
});

function parseWebSocketFrames(socket, buffer) {
  let offset = 0;

  while (buffer.length - offset >= 2) {
    const first = buffer[offset];
    const second = buffer[offset + 1];

    const fin = (first & 0x80) !== 0;
    const opcode = first & 0x0f;
    const masked = (second & 0x80) !== 0;

    let payloadLength = second & 0x7f;
    let headerLength = 2;

    if (payloadLength === 126) {
      if (buffer.length - offset < 4) break;
      payloadLength = buffer.readUInt16BE(offset + 2);
      headerLength = 4;
    } else if (payloadLength === 127) {
      if (buffer.length - offset < 10) break;
      const high = buffer.readUInt32BE(offset + 2);
      const low = buffer.readUInt32BE(offset + 6);
      if (high !== 0) {
        log("[WS] frame too large for probe");
        socket.destroy();
        return Buffer.alloc(0);
      }
      payloadLength = low;
      headerLength = 10;
    }

    const maskLength = masked ? 4 : 0;
    const frameLength = headerLength + maskLength + payloadLength;

    if (buffer.length - offset < frameLength) break;

    let payload = buffer.subarray(
      offset + headerLength + maskLength,
      offset + frameLength
    );

    if (masked) {
      const mask = buffer.subarray(offset + headerLength, offset + headerLength + 4);
      const unmasked = Buffer.alloc(payload.length);

      for (let i = 0; i < payload.length; i++) {
        unmasked[i] = payload[i] ^ mask[i % 4];
      }

      payload = unmasked;
    }

    log(`[WS] frame fin=${fin} opcode=${opcode} bytes=${payload.length}`);
    log(`[WS] utf8="${previewBuffer(payload)}"`);
    log(`[WS] hex=${hexDump(payload)}`);

    if (opcode === 0x2) {
        try {
            const packet = decodePacket(payload);
            const summary = packetSummary(packet);

            log(`[SFS] controller=${summary.controller} action=${summary.action}`);
            log(`[SFS] params=${JSON.stringify(summary.params)}`);

            if (summary.controller === 0 && summary.action === 0) {
                const response = buildHandshakeResponse();
                log(`[SFS] sending handshake response hex=${hexDump(response)}`);
                sendWebSocketFrame(socket, 0x2, response);
            } else if (summary.controller === 0 && summary.action === 1) {
            const response = buildLoginResponse();
                log(`[SFS] sending login response hex=${hexDump(response)}`);
                sendWebSocketFrame(socket, 0x2, response);
            } else if (summary.controller === 1 && summary.action === 13) {
                const command = summary.params && summary.params.c;

                if (command === "config") {
                  const response = buildConfigResponse({
                    fileServer: `${CDN_HOST}:${CDN_PORT}`,
                    webServer: `http://${HOST}:${PORT}`
                  });
                    log(`[SFS] sending config response hex=${hexDump(response)}`);
                    sendWebSocketFrame(socket, 0x2, response);
                } else if (command === "init") {
                    const response = buildInitResponse();
                    log(`[SFS] sending init response hex=${hexDump(response)}`);
                    sendWebSocketFrame(socket, 0x2, response);
                } else if (command === "ping") {
                    const response = buildPingResponse();
                    log(`[SFS] sending ping response hex=${hexDump(response)}`);
                    sendWebSocketFrame(socket, 0x2, response);
                } else if (command === "buddylist") {
                  const response = buildBuddyListResponse();
                  log(`[SFS] sending buddylist response hex=${hexDump(response)}`);
                  sendWebSocketFrame(socket, 0x2, response);
                } else if (command === "questlist") {
                  const response = buildQuestListResponse();
                  log(`[SFS] sending questlist response hex=${hexDump(response)}`);
                  sendWebSocketFrame(socket, 0x2, response);
                } else if (command === "cardlist") {
                  const response = buildCardListResponse();
                  log(`[SFS] sending cardlist response hex=${hexDump(response)}`);
                  sendWebSocketFrame(socket, 0x2, response);
                } else if (command === "handitemlist") {
                  const response = buildHandItemListResponse();
                  log(`[SFS] sending handitemlist response hex=${hexDump(response)}`);
                  sendWebSocketFrame(socket, 0x2, response);
                } else if (command === "specialitemlist") {
                  const response = buildSpecialItemListResponse();
                  log(`[SFS] sending specialitemlist response hex=${hexDump(response)}`);
                  sendWebSocketFrame(socket, 0x2, response);
                } else if (command === "achievementlist") {
                  const response = buildAchievementListResponse();
                  log(`[SFS] sending achievementlist response hex=${hexDump(response)}`);
                  sendWebSocketFrame(socket, 0x2, response);
                } else if (command === "universelist") {
                  const response = buildUniverseListResponse();
                  log(`[SFS] sending universelist response hex=${hexDump(response)}`);
                  sendWebSocketFrame(socket, 0x2, response);
                } else if (command === "smileylist") {
                  const response = buildSmileyListResponse();
                  log(`[SFS] sending smileylist response hex=${hexDump(response)}`);
                  sendWebSocketFrame(socket, 0x2, response);
                } else if (command === "clothlist") {
                  const response = buildClothListResponse();
                  log(`[SFS] sending clothlist response hex=${hexDump(response)}`);
                  sendWebSocketFrame(socket, 0x2, response);
                } else if (command === "profile") {
                  const response = buildProfileResponse(summary.params && summary.params.p && summary.params.p.data);
                  log(`[SFS] sending profile response hex=${hexDump(response)}`);
                  sendWebSocketFrame(socket, 0x2, response);
                } else if (command === "profilelike") {
                  const response = buildProfileLikeResponse(summary.params && summary.params.p && summary.params.p.data);
                  log(`[SFS] sending profilelike response hex=${hexDump(response)}`);
                  sendWebSocketFrame(socket, 0x2, response);
                } else if (command === "changeclothes") {
                  const responses = buildChangeClothesResponses(summary.params && summary.params.p && summary.params.p.data);
                  responses.forEach((response, index) => {
                    log(`[SFS] sending changeclothes response[${index}] hex=${hexDump(response)}`);
                    sendWebSocketFrame(socket, 0x2, response);
                  });
                } else if (command === "baseclothes") {
                  const response = buildBaseClothesResponse();
                  log(`[SFS] sending baseclothes response hex=${hexDump(response)}`);
                  sendWebSocketFrame(socket, 0x2, response);
                } else if (command === "avatarcreate") {
                  const response = buildAvatarCreateResponse(summary.params && summary.params.p && summary.params.p.data);
                  log(`[SFS] sending avatarcreate response hex=${hexDump(response)}`);
                  sendWebSocketFrame(socket, 0x2, response);
                } else if (command === "savebaseclothes") {
                  const response = buildSaveBaseClothesResponse(summary.params && summary.params.p && summary.params.p.data);
                  log(`[SFS] sending savebaseclothes response hex=${hexDump(response)}`);
                  sendWebSocketFrame(socket, 0x2, response);
                } else {
                    const response = buildGenericOkResponse(command || "unknown");
                    log(`[SFS] sending generic response for extension command ${command} hex=${hexDump(response)}`);
                    sendWebSocketFrame(socket, 0x2, response);
                }
            }
        } catch (error) {
            log(`[SFS] decode error ${error.stack || error.message}`);
        }
    }

    if (opcode === 0x8) {
      log("[WS] close frame received");
      socket.end();
      return buffer.subarray(offset + frameLength);
    }

    if (opcode === 0x9) {
      sendWebSocketFrame(socket, 0xA, payload);
    }

    offset += frameLength;
  }
  return buffer.subarray(offset);
}

function sendWebSocketFrame(socket, opcode, payload) {
  const data = Buffer.isBuffer(payload) ? payload : Buffer.from(payload || "");
  let header;

  if (data.length < 126) {
    header = Buffer.from([0x80 | opcode, data.length]);
  } else if (data.length <= 0xffff) {
    header = Buffer.alloc(4);
    header[0] = 0x80 | opcode;
    header[1] = 126;
    header.writeUInt16BE(data.length, 2);
  } else {
    header = Buffer.alloc(10);
    header[0] = 0x80 | opcode;
    header[1] = 127;
    header.writeUInt32BE(0, 2);
    header.writeUInt32BE(data.length, 6);
  }

  socket.write(Buffer.concat([header, data]));
}