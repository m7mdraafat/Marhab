const crypto = require("crypto");
const fs = require("fs");
const http = require("http");
const https = require("https");
const net = require("net");
const path = require("path");
const zlib = require("zlib");
const { decodePacket, packetSummary, rewriteLoginZone } = require("./sfs-capture-codec");

const LISTEN_HOST = process.env.ORIGINAL_PROXY_HOST || "127.0.0.1";
const LISTEN_PORT = Number(process.env.ORIGINAL_PROXY_PORT || 8080);
const REMOTE_HOST = process.env.ORIGINAL_PROXY_REMOTE_HOST || "marhab-sfs.rage-world.net";
const REMOTE_PORT = Number(process.env.ORIGINAL_PROXY_REMOTE_PORT || 8080);
const CRYPTO_PORT = Number(process.env.ORIGINAL_PROXY_CRYPTO_PORT || 8443);
const MAX_HEX_BYTES = Number(process.env.ORIGINAL_PROXY_MAX_HEX_BYTES || 512);
const REMOTE_ZONE = process.env.ORIGINAL_PROXY_REMOTE_ZONE || "marhab";
const LOG_RAW_LOGIN = process.env.ORIGINAL_PROXY_LOG_RAW_LOGIN === "1";

const repoRoot = path.resolve(__dirname, "..", "..", "..");
const logDir = path.join(repoRoot, "server", "logs", "original-proxy");
fs.mkdirSync(logDir, { recursive: true });

const sessionId = `original-proxy-${new Date().toISOString().replace(/[:.]/g, "-")}`;
const eventsPath = path.join(logDir, `${sessionId}.jsonl`);
fs.writeFileSync(path.join(logDir, "latest.txt"), `${eventsPath}\n`, "utf8");

let seq = 0;

function write(kind, payload = {}) {
  const event = { seq: ++seq, time: Date.now(), kind, payload };
  const line = JSON.stringify(event);
  console.log(line);
  fs.appendFileSync(eventsPath, `${line}\n`, "utf8");
  return event;
}

function hexDump(buffer, maxBytes = MAX_HEX_BYTES) {
  const slice = buffer.subarray(0, maxBytes);
  const hex = slice.toString("hex").match(/.{1,2}/g)?.join(" ") || "";
  return buffer.length > maxBytes ? `${hex} ... (${buffer.length} bytes total)` : hex;
}

function previewBuffer(buffer) {
  const text = buffer.toString("utf8").replace(/\0/g, "\\0").replace(/\r/g, "\\r").replace(/\n/g, "\\n");
  return text.length > 300 ? `${text.slice(0, 300)}...` : text;
}

function summarizeSfs(payload) {
  try {
    const packet = decodePacket(payload);
    const summary = packetSummary(packet);
    if (summary.ok === false) {
      return summary;
    }
    const params = summary.params || {};
    return {
      ok: true,
      controller: summary.controller,
      action: summary.action,
      extensionCommand: params.c,
      requestId: params.rid,
      roomId: params.r,
      params
    };
  } catch (error) {
    return { ok: false, error: error.message };
  }
}

function frameCapturePayload(connectionId, direction, frame, payload, summary, rewrite = null) {
  const isLogin = summary && summary.ok && summary.controller === 0 && summary.action === 1;
  const hideRaw = isLogin && !LOG_RAW_LOGIN;
  return {
    connectionId,
    direction,
    fin: frame.fin,
    opcode: frame.opcode,
    bytes: payload.length,
    preview: hideRaw ? "[redacted-login-frame]" : previewBuffer(payload),
    hex: hideRaw ? "[redacted-login-frame]" : hexDump(payload),
    sfs: summary,
    rewrite
  };
}

const crossdomainXml = `<?xml version="1.0"?>
<cross-domain-policy>
  <allow-access-from domain="*" to-ports="${LISTEN_PORT}"/>
</cross-domain-policy>
`;

const server = http.createServer((req, res) => {
  write("proxy.http.request", {
    method: req.method,
    url: req.url,
    remoteAddress: req.socket.remoteAddress,
    remotePort: req.socket.remotePort,
    headers: req.headers
  });

  if (req.method === "GET" && req.url === "/crossdomain.xml") {
    res.writeHead(200, {
      "Content-Type": "text/x-cross-domain-policy",
      "Content-Length": Buffer.byteLength(crossdomainXml),
      Connection: "close"
    });
    res.end(crossdomainXml);
    return;
  }

  res.writeHead(404, { "Content-Type": "text/plain", Connection: "close" });
  res.end("not found\n");
});

server.on("upgrade", (req, localSocket) => {
  const connectionId = `${Date.now()}-${Math.random().toString(16).slice(2)}`;
  const connectionState = {
    cryptoKey: null,
    cryptoKeyError: null,
    cryptoKeyPromise: null,
    pendingEncryptedFrames: []
  };
  write("proxy.ws.local.upgrade", {
    connectionId,
    url: req.url,
    remoteAddress: localSocket.remoteAddress,
    remotePort: localSocket.remotePort,
    headers: req.headers
  });

  const localKey = req.headers["sec-websocket-key"];
  if (!localKey) {
    write("proxy.ws.local.reject", { connectionId, reason: "missing sec-websocket-key" });
    localSocket.destroy();
    return;
  }

  const accept = crypto.createHash("sha1").update(`${localKey}258EAFA5-E914-47DA-95CA-C5AB0DC85B11`).digest("base64");
  localSocket.write([
    "HTTP/1.1 101 Switching Protocols",
    "Upgrade: websocket",
    "Connection: Upgrade",
    `Sec-WebSocket-Accept: ${accept}`,
    "",
    ""
  ].join("\r\n"));

  const remoteSocket = net.connect(REMOTE_PORT, REMOTE_HOST);
  const remoteKey = crypto.randomBytes(16).toString("base64");
  const queuedLocalFrames = [];
  let remoteReady = false;
  let localPending = Buffer.alloc(0);
  let remotePending = Buffer.alloc(0);
  let remoteHandshakeBuffer = Buffer.alloc(0);

  remoteSocket.on("connect", () => {
    const requestPath = req.url || "/BlueBox/websocket";
    write("proxy.ws.remote.connect", { connectionId, host: REMOTE_HOST, port: REMOTE_PORT, requestPath });
    remoteSocket.write([
      `GET ${requestPath} HTTP/1.1`,
      `Host: ${REMOTE_HOST}:${REMOTE_PORT}`,
      "Upgrade: websocket",
      "Connection: Upgrade",
      `Sec-WebSocket-Key: ${remoteKey}`,
      "Origin: *",
      "Sec-WebSocket-Version: 13",
      "",
      ""
    ].join("\r\n"));
  });

  remoteSocket.on("data", (chunk) => {
    if (!remoteReady) {
      remoteHandshakeBuffer = Buffer.concat([remoteHandshakeBuffer, chunk]);
      const headerEnd = remoteHandshakeBuffer.indexOf("\r\n\r\n");
      if (headerEnd < 0) return;

      const header = remoteHandshakeBuffer.subarray(0, headerEnd).toString("latin1");
      const rest = remoteHandshakeBuffer.subarray(headerEnd + 4);
      remoteReady = true;
      write("proxy.ws.remote.upgrade", { connectionId, header });

      for (const frame of queuedLocalFrames.splice(0)) {
        remoteSocket.write(encodeWebSocketFrame(frame.opcode, frame.payload, true));
      }
      if (rest.length > 0) {
        remotePending = parseWebSocketFrames(rest, (frame) => handleRemoteFrame(connectionId, frame, localSocket, remoteSocket, connectionState));
      }
      return;
    }

    remotePending = parseWebSocketFrames(Buffer.concat([remotePending, chunk]), (frame) => handleRemoteFrame(connectionId, frame, localSocket, remoteSocket, connectionState));
  });

  localSocket.on("data", (chunk) => {
    localPending = parseWebSocketFrames(Buffer.concat([localPending, chunk]), (frame) => {
      handleLocalFrame(connectionId, frame, remoteSocket, remoteReady, queuedLocalFrames, connectionState);
    });
  });

  localSocket.on("close", () => {
    write("proxy.ws.local.close", { connectionId });
    remoteSocket.end();
  });
  remoteSocket.on("close", () => {
    write("proxy.ws.remote.close", { connectionId });
    localSocket.end();
  });
  localSocket.on("error", (error) => {
    write("proxy.ws.local.error", { connectionId, message: error.message });
    remoteSocket.destroy();
  });
  remoteSocket.on("error", (error) => {
    write("proxy.ws.remote.error", { connectionId, message: error.message });
    localSocket.destroy();
  });
});

server.on("clientError", (error, socket) => {
  write("proxy.http.clientError", { message: error.message, rawPacketHex: error.rawPacket ? hexDump(error.rawPacket) : null });
  socket.destroy();
});

server.listen(LISTEN_PORT, LISTEN_HOST, () => {
  write("proxy.session.start", { sessionId, eventsPath, listenHost: LISTEN_HOST, listenPort: LISTEN_PORT, remoteHost: REMOTE_HOST, remotePort: REMOTE_PORT });
});

function handleLocalFrame(connectionId, frame, remoteSocket, remoteReady, queue, connectionState) {
  const forwarded = prepareLocalFrame(connectionId, frame, connectionState);
  if (remoteReady) {
    remoteSocket.write(encodeWebSocketFrame(frame.opcode, forwarded.payload, true));
  } else {
    queue.push({ opcode: frame.opcode, payload: forwarded.payload });
  }
  if (frame.opcode === 0x8) remoteSocket.end();
}

function prepareLocalFrame(connectionId, frame, connectionState) {
  const payload = frame.payload || Buffer.alloc(0);
  let summary = frame.opcode === 0x2 ? summarizeSfs(payload) : null;
  let rewrite = null;
  let forwardedPayload = payload;

  if (frame.opcode === 0x2) {
    const result = rewriteLoginZone(payload, REMOTE_ZONE);
    if (result.changed) {
      forwardedPayload = result.frame;
      summary = packetSummary(result.rewrittenPacket);
      rewrite = { kind: "login-zone", from: result.from, to: result.to, originalBytes: payload.length, rewrittenBytes: forwardedPayload.length };
      write("proxy.sfs.rewrite", { connectionId, direction: "client->server", kind: rewrite.kind, from: rewrite.from, to: rewrite.to, originalBytes: rewrite.originalBytes, rewrittenBytes: rewrite.rewrittenBytes });
    } else if (result.error) {
      rewrite = { kind: "login-zone", changed: false, error: result.error };
    }
  }

  const frameEvent = write("proxy.ws.frame", frameCapturePayload(connectionId, "client->server", frame, payload, summary, rewrite));
  maybeDecryptAndLogFrame(connectionId, "client->server", frameEvent.seq, payload, summary, connectionState);
  return { payload: forwardedPayload };
}

function handleRemoteFrame(connectionId, frame, localSocket, remoteSocket, connectionState) {
  logFrame(connectionId, "server->client", frame, connectionState);
  localSocket.write(encodeWebSocketFrame(frame.opcode, frame.payload, false));
  if (frame.opcode === 0x8) localSocket.end();
}

function logFrame(connectionId, direction, frame, connectionState) {
  const payload = frame.payload || Buffer.alloc(0);
  const summary = frame.opcode === 0x2 ? summarizeSfs(payload) : null;
  const frameEvent = write("proxy.ws.frame", frameCapturePayload(connectionId, direction, frame, payload, summary));
  maybeStartCryptoKeyFetch(connectionId, summary, connectionState);
  maybeDecryptAndLogFrame(connectionId, direction, frameEvent.seq, payload, summary, connectionState);
}

function maybeStartCryptoKeyFetch(connectionId, summary, connectionState) {
  if (!summary || !summary.ok || summary.controller !== 0 || summary.action !== 0) return;
  const token = summary.params && summary.params.tk;
  if (!token || connectionState.cryptoKey || connectionState.cryptoKeyPromise) return;

  connectionState.cryptoKeyPromise = fetchCryptoKey(token)
    .then((cryptoKey) => {
      connectionState.cryptoKey = cryptoKey;
      write("proxy.crypto.ready", {
        connectionId,
        cryptoPort: CRYPTO_PORT,
        pendingEncryptedFrames: connectionState.pendingEncryptedFrames.length
      });
      for (const pending of connectionState.pendingEncryptedFrames.splice(0)) {
        decryptAndLogFrame(connectionId, pending.direction, pending.frameSeq, pending.payload, connectionState);
      }
    })
    .catch((error) => {
      connectionState.cryptoKeyError = error.message;
      write("proxy.crypto.error", { connectionId, cryptoPort: CRYPTO_PORT, message: error.message });
    });
}

function fetchCryptoKey(sessionToken) {
  return new Promise((resolve, reject) => {
    const body = `SessToken=${encodeURIComponent(sessionToken)}`;
    const request = https.request({
      host: REMOTE_HOST,
      port: CRYPTO_PORT,
      path: "/BlueBox/CryptoManager",
      method: "POST",
      rejectUnauthorized: false,
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        "Content-Length": Buffer.byteLength(body)
      }
    }, (response) => {
      const chunks = [];
      response.on("data", (chunk) => chunks.push(chunk));
      response.on("end", () => {
        const text = Buffer.concat(chunks).toString("utf8").trim();
        if (response.statusCode !== 200) {
          reject(new Error(`CryptoManager HTTP ${response.statusCode}`));
          return;
        }
        const material = Buffer.from(text, "base64");
        if (material.length !== 32) {
          reject(new Error(`CryptoManager key material length ${material.length}`));
          return;
        }
        resolve({ key: material.subarray(0, 16), iv: material.subarray(16, 32) });
      });
    });
    request.on("error", reject);
    request.write(body);
    request.end();
  });
}

function maybeDecryptAndLogFrame(connectionId, direction, frameSeq, payload, summary, connectionState) {
  if (!summary || summary.ok !== false || !summary.encrypted) return;
  if (connectionState.cryptoKey) {
    decryptAndLogFrame(connectionId, direction, frameSeq, payload, connectionState);
    return;
  }
  if (!connectionState.cryptoKeyError) {
    connectionState.pendingEncryptedFrames.push({ direction, frameSeq, payload: Buffer.from(payload) });
  }
}

function decryptAndLogFrame(connectionId, direction, frameSeq, framePayload, connectionState) {
  try {
    const clearFrame = decryptSfsFrame(framePayload, connectionState.cryptoKey);
    const packet = decodePacket(clearFrame);
    const summary = packetSummary(packet);
    write("proxy.sfs.decrypted", {
      connectionId,
      frameSeq,
      direction,
      bytes: framePayload.length,
      clearBytes: clearFrame.length,
      sfs: summary
    });
  } catch (error) {
    write("proxy.sfs.decrypt.error", { connectionId, frameSeq, direction, bytes: framePayload.length, message: error.message });
  }
}

function decryptSfsFrame(framePayload, cryptoKey) {
  if (!cryptoKey) throw new Error("Missing crypto key");
  if (framePayload.length < 3) throw new Error("Encrypted frame too short");

  const header = framePayload[0];
  const bigSized = (header & 0x08) !== 0;
  const compressed = (header & 0x20) !== 0;
  const encrypted = (header & 0x40) !== 0;
  if (!encrypted) throw new Error("Frame is not encrypted");

  const offset = bigSized ? 5 : 3;
  if (framePayload.length < offset) throw new Error("Encrypted frame missing size header");
  const encryptedPayload = framePayload.subarray(offset);

  const decipher = crypto.createDecipheriv("aes-128-cbc", cryptoKey.key, cryptoKey.iv);
  let clearPayload = Buffer.concat([decipher.update(encryptedPayload), decipher.final()]);
  let clearHeader = header & ~0x40;

  if (compressed) {
    clearPayload = zlib.unzipSync(clearPayload);
    clearHeader &= ~0x20;
  }

  if (clearPayload.length > 0xffff) {
    clearHeader |= 0x08;
    const size = Buffer.alloc(4);
    size.writeUInt32BE(clearPayload.length, 0);
    return Buffer.concat([Buffer.from([clearHeader]), size, clearPayload]);
  }

  clearHeader &= ~0x08;
  const size = Buffer.alloc(2);
  size.writeUInt16BE(clearPayload.length, 0);
  return Buffer.concat([Buffer.from([clearHeader]), size, clearPayload]);
}

function parseWebSocketFrames(buffer, onFrame) {
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
      if (high !== 0) throw new Error("WebSocket frame too large");
      payloadLength = low;
      headerLength = 10;
    }

    const maskLength = masked ? 4 : 0;
    const frameLength = headerLength + maskLength + payloadLength;
    if (buffer.length - offset < frameLength) break;

    let payload = buffer.subarray(offset + headerLength + maskLength, offset + frameLength);
    if (masked) {
      const mask = buffer.subarray(offset + headerLength, offset + headerLength + 4);
      const unmasked = Buffer.alloc(payload.length);
      for (let index = 0; index < payload.length; index++) {
        unmasked[index] = payload[index] ^ mask[index % 4];
      }
      payload = unmasked;
    }

    onFrame({ fin, opcode, masked, payload });
    offset += frameLength;
  }
  return buffer.subarray(offset);
}

function encodeWebSocketFrame(opcode, payload, masked) {
  const data = Buffer.isBuffer(payload) ? payload : Buffer.from(payload || "");
  let header;
  const maskBit = masked ? 0x80 : 0;

  if (data.length < 126) {
    header = Buffer.from([0x80 | opcode, maskBit | data.length]);
  } else if (data.length <= 0xffff) {
    header = Buffer.alloc(4);
    header[0] = 0x80 | opcode;
    header[1] = maskBit | 126;
    header.writeUInt16BE(data.length, 2);
  } else {
    header = Buffer.alloc(10);
    header[0] = 0x80 | opcode;
    header[1] = maskBit | 127;
    header.writeUInt32BE(0, 2);
    header.writeUInt32BE(data.length, 6);
  }

  if (!masked) return Buffer.concat([header, data]);

  const mask = crypto.randomBytes(4);
  const maskedPayload = Buffer.alloc(data.length);
  for (let index = 0; index < data.length; index++) {
    maskedPayload[index] = data[index] ^ mask[index % 4];
  }
  return Buffer.concat([header, mask, maskedPayload]);
}