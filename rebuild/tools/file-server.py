"""Minimal static file server for MyGame boot assets.

Serves the contents of ./files on http://0.0.0.0:8088. The client (after a
successful `config` response) downloads three files from here:
  /global/static/data/vf.001       version map         (base64 of "k=v|...")
  /global/static/data/ifile.001    item/cloth catalog  (base64 of "<lines>")
  /global/static/locale/en_US.001.mo  gettext binary   (may be empty)

Add real assets later for full gameplay.
"""
from __future__ import annotations

import http.server
import os
import socketserver
import sys

PORT = 8088
ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "files")


class CORSHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self) -> None:  # noqa: D401
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Cache-Control", "no-store")
        super().end_headers()

    def log_message(self, fmt: str, *args) -> None:  # quieter than default
        sys.stdout.write("[file-server] " + (fmt % args) + "\n")


def main() -> None:
    os.chdir(ROOT)
    with socketserver.ThreadingTCPServer(("0.0.0.0", PORT), CORSHandler) as httpd:
        print(f"[file-server] serving {ROOT} on http://0.0.0.0:{PORT}")
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("[file-server] shutting down")


if __name__ == "__main__":
    main()
