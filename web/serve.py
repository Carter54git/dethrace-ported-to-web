#!/usr/bin/env python3
"""Serve the Carmageddon web port without browser caching."""

from __future__ import annotations

import http.server
import os
from pathlib import Path

WEB_DIR = Path(__file__).resolve().parent


class NoCacheHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(WEB_DIR), **kwargs)

    def end_headers(self) -> None:
        self.send_header("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0")
        self.send_header("Pragma", "no-cache")
        self.send_header("Expires", "0")
        super().end_headers()


def main() -> None:
    os.chdir(WEB_DIR)
    port = int(os.environ.get("PORT", "8080"))
    server = http.server.ThreadingHTTPServer(("", port), NoCacheHandler)
    print(f"Serving {WEB_DIR} at http://127.0.0.1:{port}/ (no-cache)")
    server.serve_forever()


if __name__ == "__main__":
    main()
