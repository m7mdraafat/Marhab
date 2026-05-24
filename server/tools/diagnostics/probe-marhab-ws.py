"""Quick liveness probe for Marhab's live SFS WebSocket endpoint.

Just opens the BlueBox WebSocket and waits up to 6 seconds for any frame.
If the server doesn't respond we know capture-via-proxy is also dead in the
water and we should fall back to Path B (authoring) instead.
"""
import asyncio
import sys

try:
    import websockets
except ImportError:
    print("missing 'websockets' module — run: pip install websockets")
    sys.exit(2)

URL = "ws://marhab-sfs.rage-world.net:8080/BlueBox/websocket"


async def main() -> int:
    candidates = [
        "ws://marhab-sfs.newmarhab.net:8080/BlueBox/websocket",
        "ws://sfs.newmarhab.net:8080/BlueBox/websocket",
        "ws://xo.newmarhab.net:8080/BlueBox/websocket",
        "ws://marhab-sfs.rage-world.net:8080/BlueBox/websocket",
        URL,
    ]
    seen = set()
    for u in candidates:
        if u in seen:
            continue
        seen.add(u)
        print(f"\n--- {u}")
        try:
            async with websockets.connect(u, open_timeout=6, max_size=None) as ws:
                print("  WS upgrade OK")
                try:
                    frame = await asyncio.wait_for(ws.recv(), timeout=4)
                    kind = type(frame).__name__
                    length = len(frame) if hasattr(frame, "__len__") else "?"
                    print(f"  got frame: type={kind} len={length}")
                    if isinstance(frame, (bytes, bytearray)):
                        print("  first bytes hex:", frame[:64].hex())
                except asyncio.TimeoutError:
                    print("  connected, no frame in 4s (likely needs us to speak first)")
        except Exception as e:
            print(f"  connect failed: {type(e).__name__}: {str(e)[:160]}")
    return 0


if __name__ == "__main__":
    sys.exit(asyncio.run(main()))
