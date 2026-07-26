const fs = require("fs");
const http = require("http");
const path = require("path");

const HOST = process.env.CDN_HOST || "127.0.0.1";
const PORT = Number(process.env.CDN_PORT || 8081);

const repoRoot = path.resolve(__dirname, "..", "..", "..");
const cdnRoot = path.resolve(repoRoot, "assets", "cdn");
const logDir = path.join(repoRoot, "assets", "reports");

fs.mkdirSync(cdnRoot, { recursive: true });
fs.mkdirSync(logDir, { recursive: true });

const logFile = path.join(
  logDir,
  `cdn-${new Date().toISOString().replace(/[:.]/g, "-")}.log`
);

const mimeTypes = {
  ".swf": "application/x-shockwave-flash",
  ".png": "image/png",
  ".jpg": "image/jpeg",
  ".jpeg": "image/jpeg",
  ".gif": "image/gif",
  ".json": "application/json; charset=utf-8",
  ".txt": "text/plain; charset=utf-8",
  ".xml": "application/xml; charset=utf-8",
  ".mo": "application/octet-stream",
  ".bin": "application/octet-stream"
};

function log(message) {
  const line = `${new Date().toISOString()} ${message}`;
  console.log(line);
  fs.appendFileSync(logFile, `${line}\n`, "utf8");
}

function send(res, statusCode, contentType, body) {
  const data = Buffer.isBuffer(body) ? body : Buffer.from(String(body), "utf8");

  res.writeHead(statusCode, {
    "Content-Type": contentType,
    "Content-Length": data.length,
    "Access-Control-Allow-Origin": "*",
    "Cache-Control": "no-store",
    "Connection": "close"
  });

  res.end(data);
}

function safeResolve(urlPath) {
  const decoded = decodeURIComponent(urlPath.split("?")[0]);
  const normalized = path.normalize(decoded).replace(/^(\.\.[/\\])+/, "");
  const relative = normalized.replace(/^[/\\]+/, "");
  const fullPath = path.resolve(cdnRoot, relative);

  if (!fullPath.startsWith(cdnRoot)) {
    return null;
  }

  return fullPath;
}

const crossdomainXml = `<?xml version="1.0"?>
<cross-domain-policy>
  <allow-access-from domain="*" to-ports="8081"/>
</cross-domain-policy>
`;

const server = http.createServer((req, res) => {
  log(`[HTTP] ${req.method} ${req.url} from ${req.socket.remoteAddress}:${req.socket.remotePort}`);

  if (req.method === "OPTIONS") {
    res.writeHead(204, {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "GET,HEAD,OPTIONS",
      "Access-Control-Allow-Headers": "*"
    });
    res.end();
    return;
  }

  if (req.method !== "GET" && req.method !== "HEAD") {
    send(res, 405, "text/plain; charset=utf-8", "method not allowed\n");
    return;
  }

  if (req.url === "/crossdomain.xml") {
    send(res, 200, "text/x-cross-domain-policy", crossdomainXml);
    return;
  }

  const filePath = safeResolve(req.url);
  if (!filePath) {
    send(res, 403, "text/plain; charset=utf-8", "forbidden\n");
    return;
  }

  if (!fs.existsSync(filePath) || !fs.statSync(filePath).isFile()) {
    log(`[MISS] ${filePath}`);
    send(res, 404, "text/plain; charset=utf-8", "not found\n");
    return;
  }

  const ext = path.extname(filePath).toLowerCase();
  const contentType = mimeTypes[ext] || "application/octet-stream";
  const data = fs.readFileSync(filePath);

  log(`[HIT] ${filePath} ${data.length} bytes`);

  if (req.method === "HEAD") {
    res.writeHead(200, {
      "Content-Type": contentType,
      "Content-Length": data.length,
      "Access-Control-Allow-Origin": "*",
      "Cache-Control": "no-store",
      "Connection": "close"
    });
    res.end();
    return;
  }

  send(res, 200, contentType, data);
});

server.listen(PORT, HOST, () => {
  log(`[BOOT] local CDN listening on http://${HOST}:${PORT}`);
  log(`[BOOT] serving ${cdnRoot}`);
  log(`[BOOT] log file ${logFile}`);
});