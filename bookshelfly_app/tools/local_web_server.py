#!/usr/bin/env python3
import argparse
import mimetypes
import os
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.parse import parse_qs, urlparse, urlunparse
from urllib.request import Request, urlopen


ALLOWED_PROXY_HOSTS = {
    "gutenberg.org",
    "www.gutenberg.org",
    "gutendex.com",
}


class FlutterWebProxyHandler(SimpleHTTPRequestHandler):
    def __init__(self, *args, directory=None, **kwargs):
        self._directory = directory or os.getcwd()
        super().__init__(*args, directory=self._directory, **kwargs)

    def do_GET(self):
        parsed = urlparse(self.path)
        if parsed.path == "/proxy":
            self._handle_legacy_proxy(parsed, send_body=True)
            return

        if parsed.path.startswith("/gutenberg/"):
            self._handle_gutenberg_proxy(parsed, send_body=True)
            return

        if parsed.path in ("", "/"):
            self.path = "/index.html"
        elif not Path(self.translate_path(parsed.path)).exists() and "." not in Path(parsed.path).name:
            self.path = "/index.html"

        return super().do_GET()

    def do_HEAD(self):
        parsed = urlparse(self.path)
        if parsed.path == "/proxy":
            self._handle_legacy_proxy(parsed, send_body=False)
            return

        if parsed.path.startswith("/gutenberg/"):
            self._handle_gutenberg_proxy(parsed, send_body=False)
            return

        if parsed.path in ("", "/"):
            self.path = "/index.html"
        elif not Path(self.translate_path(parsed.path)).exists() and "." not in Path(parsed.path).name:
            self.path = "/index.html"

        return super().do_HEAD()

    def _handle_legacy_proxy(self, parsed, send_body):
        query = parse_qs(parsed.query)
        target_url = query.get("url", [None])[0]

        if not target_url:
            self.send_error(400, "Missing url parameter")
            return

        self._proxy_target(target_url, send_body)

    def _handle_gutenberg_proxy(self, parsed, send_body):
        target_url = urlunparse(
            (
                "https",
                "www.gutenberg.org",
                parsed.path.removeprefix("/gutenberg"),
                "",
                parsed.query,
                "",
            )
        )
        self._proxy_target(target_url, send_body)

    def _proxy_target(self, target_url, send_body):

        target = urlparse(target_url)
        if target.scheme not in {"http", "https"} or target.hostname not in ALLOWED_PROXY_HOSTS:
            self.send_error(403, "Host not allowed")
            return

        try:
            request = Request(
                target_url,
                headers={
                    "User-Agent": "BookShelflyLocalProxy/1.0",
                    "Accept": "*/*",
                },
            )
            with urlopen(request) as response:
                body = response.read()
                content_type = response.headers.get_content_type()
                charset = response.headers.get_content_charset()

                self.send_response(response.status)
                if charset:
                    self.send_header("Content-Type", f"{content_type}; charset={charset}")
                else:
                    self.send_header("Content-Type", content_type)
                self.send_header("Content-Length", str(len(body)))
                self.send_header("Cache-Control", "public, max-age=3600")
                self.end_headers()
                if send_body:
                    self.wfile.write(body)
        except HTTPError as exc:
            self.send_error(exc.code, exc.reason)
        except URLError as exc:
            self.send_error(502, f"Proxy error: {exc.reason}")

    def end_headers(self):
        parsed = urlparse(self.path)
        if parsed.path in ("/", "/index.html", "/flutter_bootstrap.js", "/flutter_service_worker.js"):
            self.send_header("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0")
            self.send_header("Pragma", "no-cache")
        self.send_header("Access-Control-Allow-Origin", "*")
        super().end_headers()


def main():
    parser = argparse.ArgumentParser(description="Serve Flutter web build with a Gutenberg proxy.")
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=8081)
    parser.add_argument(
        "--directory",
        default=str(Path(__file__).resolve().parents[1] / "build" / "web"),
    )
    args = parser.parse_args()

    mimetypes.add_type("application/wasm", ".wasm")
    server = ThreadingHTTPServer(
        (args.host, args.port),
        lambda *handler_args, **handler_kwargs: FlutterWebProxyHandler(
            *handler_args,
            directory=args.directory,
            **handler_kwargs,
        ),
    )

    print(f"Serving {args.directory} at http://{args.host}:{args.port}")
    server.serve_forever()


if __name__ == "__main__":
    main()
