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
import sys
import urllib.request

try:
    import websockets
    from websockets.server import serve as ws_serve
    from websockets.client import connect as ws_connect
except ImportError:
    print("missing 'websockets' — run: pip install websockets")
    sys.exit(2)


async def relay(src, dst, label: str) -> None:
    try:
        async for msg in src:
            await dst.send(msg)
    except websockets.ConnectionClosed:
        pass
    except Exception as e:
        print(f"  [{label}] relay error: {type(e).__name__}: {e}")


def make_handler(upstream_host: str, upstream_port: int):
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
                    relay(client_ws, up_ws, "c->u"),
                    relay(up_ws, client_ws, "u->c"),
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
    args = ap.parse_args()

    host, _, port = args.upstream.partition(":")
    port = int(port or 8080)
    print(f"forwarding ws://0.0.0.0:{args.listen}/BlueBox/websocket -> "
          f"ws://{host}:{port}/BlueBox/websocket")
    print("(Ctrl-C to stop)")

    async with ws_serve(make_handler(host, port), "0.0.0.0", args.listen,
                        max_size=None) as server:
        await asyncio.Future()  # run forever


if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\nstopped")
