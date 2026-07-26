"""sfs-passthrough.py — temporary WebSocket forwarder.

Stops being needed once we've captured the live Marhab config response.

Listens on 0.0.0.0:8080/BlueBox/websocket and forwards each upgraded
session bidirectionally to ws://marhab-sfs.newmarhab.net:8080/BlueBox/websocket
with the proper Host header.

USAGE
  python sfs-passthrough.py [--upstream HOST[:PORT]] [--listen PORT]

defaults: upstream=marhab-sfs.newmarhab.net:8080  listen=8080

PRECONDITION
  Local SFS must be stopped first or port 8080 is busy. Use:
  Get-CimInstance Win32_Process | ? { $_.Name -eq 'java.exe' -and
      $_.CommandLine -like '*smartfoxserver.v2.Main*' } |
      % { taskkill /F /PID $_.ProcessId }

The forwarder also serves HEAD/GET /global/static/assets/* by reverse-proxying
to xo.newmarhab.net so the inner game's BG/asset loaders return real bytes.

Stop with Ctrl-C; restart SFS afterwards with server/restart-sfs.ps1.
"""
from __future__ import annotations
import argparse
import asyncio
import base64
import json
import sys
import time
import urllib.request
from pathlib import Path

try:
    import websockets
    from websockets.server import serve as ws_serve
    from websockets.client import connect as ws_connect
except ImportError:
    print("missing 'websockets' — run: pip install websockets")
    sys.exit(2)


def write_capture(capture_path: Path | None, direction: str, msg) -> None:
    if capture_path is None:
        return

    if isinstance(msg, str):
        raw = msg.encode("utf-8")
        kind = "text"
    else:
        raw = bytes(msg)
        kind = "binary"

    record = {
        "ts": time.time(),
        "direction": direction,
        "kind": kind,
        "bytes": len(raw),
        "hexPreview": raw[:96].hex(),
        "base64": base64.b64encode(raw).decode("ascii"),
    }
    with capture_path.open("a", encoding="utf-8") as f:
        f.write(json.dumps(record, separators=(",", ":")) + "\n")


async def relay(src, dst, label: str, capture_path: Path | None) -> None:
    try:
        async for msg in src:
            write_capture(capture_path, label, msg)
            await dst.send(msg)
    except websockets.ConnectionClosed:
        pass
    except Exception as e:
        print(f"  [{label}] relay error: {type(e).__name__}: {e}")


def make_handler(upstream_host: str, upstream_port: int, capture_path: Path | None):
    upstream_url = f"ws://{upstream_host}:{upstream_port}/BlueBox/websocket"

    async def handler(client_ws):
        peer = getattr(client_ws, "remote_address", ("?", 0))
        print(f"\n[+] client {peer} -> upstream {upstream_url}")
        try:
            async with ws_connect(
                upstream_url,
                open_timeout=10,
                max_size=None,
                extra_headers={"Host": f"{upstream_host}:{upstream_port}"},
            ) as up_ws:
                await asyncio.gather(
                    relay(client_ws, up_ws, "c->u", capture_path),
                    relay(up_ws, client_ws, "u->c", capture_path),
                )
        except Exception as e:
            print(f"  upstream connect failed: {type(e).__name__}: {e}")
        finally:
            print(f"[-] client {peer} disconnected")

    return handler


async def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--upstream", default="marhab-sfs.newmarhab.net:8080")
    ap.add_argument("--listen", type=int, default=8080)
    ap.add_argument("--capture", default="captures/sfs-live.jsonl",
                    help="JSONL file for raw WS frames; use '' to disable")
    args = ap.parse_args()

    host, _, port = args.upstream.partition(":")
    port = int(port or 8080)
    capture_path = Path(args.capture) if args.capture else None
    if capture_path is not None:
        capture_path.parent.mkdir(parents=True, exist_ok=True)
        capture_path.write_text("", encoding="utf-8")
    print(f"forwarding ws://0.0.0.0:{args.listen}/BlueBox/websocket -> "
          f"ws://{host}:{port}/BlueBox/websocket")
    if capture_path is not None:
        print(f"capturing raw frames -> {capture_path}")
    print("(Ctrl-C to stop)")

    async with ws_serve(make_handler(host, port, capture_path), "0.0.0.0", args.listen,
                        max_size=None) as server:
        await asyncio.Future()  # run forever


if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\nstopped")
