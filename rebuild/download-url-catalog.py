"""
Download a URL catalog into a local mirror.

Designed for the large Sanalika/MyGame asset catalogs emitted by
mine-asset-urls.py. It is safe to rerun: existing files are skipped unless
--force is passed, and every run writes machine-readable reports.
"""

from __future__ import annotations

import argparse
import csv
import json
import os
import socket
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Iterable
from urllib.error import HTTPError, URLError
from urllib.parse import urlsplit
from urllib.request import Request, urlopen


SWF_HEADERS = (b"FWS", b"CWS", b"ZWS")
PNG_HEADER = b"\x89PNG\r\n\x1a\n"


@dataclass
class DownloadResult:
    url: str
    status: str
    size: int
    path: str
    attempts: int
    elapsed_ms: int
    error: str = ""


def url_to_path(url: str, mirror_root: Path) -> Path:
    parsed = urlsplit(url)
    relative = f"{parsed.netloc}{parsed.path}" if parsed.netloc else parsed.path.lstrip("/")
    for char in ':*?"<>|':
        relative = relative.replace(char, "_")
    return mirror_root / relative.replace("/", os.sep)


def read_urls(paths: Iterable[Path]) -> list[str]:
    urls: list[str] = []
    seen: set[str] = set()
    for path in paths:
        for line in path.read_text(encoding="utf-8").splitlines():
            url = line.strip()
            if not url or url.startswith("#") or url in seen:
                continue
            seen.add(url)
            urls.append(url)
    return urls


def validate_file(path: Path) -> tuple[bool, str]:
    suffix = path.suffix.lower()
    try:
        with path.open("rb") as handle:
            header = handle.read(8)
    except OSError as exc:
        return False, str(exc)

    if suffix == ".swf" and not header.startswith(SWF_HEADERS):
        return False, f"invalid swf header {header[:3]!r}"
    if suffix == ".png" and header != PNG_HEADER:
        return False, f"invalid png header {header!r}"
    return True, ""


def download_one(url: str, mirror_root: Path, timeout: int, retries: int, force: bool) -> DownloadResult:
    start = time.perf_counter()
    destination = url_to_path(url, mirror_root)

    if destination.exists() and not force:
        ok, error = validate_file(destination)
        status = "present" if ok else "invalid-present"
        return DownloadResult(
            url=url,
            status=status,
            size=destination.stat().st_size,
            path=str(destination),
            attempts=0,
            elapsed_ms=int((time.perf_counter() - start) * 1000),
            error=error,
        )

    destination.parent.mkdir(parents=True, exist_ok=True)
    temp_path = destination.with_suffix(destination.suffix + ".tmp")
    last_error = ""

    for attempt in range(1, retries + 2):
        try:
            request = Request(url, headers={"User-Agent": "MyGameAssetMirror/1.0"})
            with urlopen(request, timeout=timeout) as response, temp_path.open("wb") as output:
                while True:
                    chunk = response.read(1024 * 128)
                    if not chunk:
                        break
                    output.write(chunk)
            temp_path.replace(destination)
            ok, error = validate_file(destination)
            if not ok:
                last_error = error
                destination.unlink(missing_ok=True)
                raise ValueError(error)
            return DownloadResult(
                url=url,
                status="downloaded",
                size=destination.stat().st_size,
                path=str(destination),
                attempts=attempt,
                elapsed_ms=int((time.perf_counter() - start) * 1000),
            )
        except (HTTPError, URLError, TimeoutError, OSError, ValueError) as exc:
            last_error = str(exc)
            temp_path.unlink(missing_ok=True)
            if isinstance(exc, HTTPError) and exc.code in {403, 404, 410}:
                break
            if attempt <= retries:
                time.sleep(min(2.0, 0.25 * attempt))

    return DownloadResult(
        url=url,
        status="failed",
        size=0,
        path=str(destination),
        attempts=retries + 1,
        elapsed_ms=int((time.perf_counter() - start) * 1000),
        error=last_error,
    )


def write_reports(results: list[DownloadResult], report_dir: Path) -> None:
    report_dir.mkdir(parents=True, exist_ok=True)
    rows = [asdict(result) for result in results]

    csv_path = report_dir / "download-report.csv"
    with csv_path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=list(rows[0].keys()) if rows else [])
        if rows:
            writer.writeheader()
            writer.writerows(rows)

    (report_dir / "download-report.json").write_text(
        json.dumps(rows, indent=2, ensure_ascii=False), encoding="utf-8"
    )
    failures = [row for row in rows if row["status"] in {"failed", "invalid-present"}]
    (report_dir / "download-failures.json").write_text(
        json.dumps(failures, indent=2, ensure_ascii=False), encoding="utf-8"
    )


def main() -> int:
    parser = argparse.ArgumentParser(description="Download a newline-delimited asset URL catalog.")
    parser.add_argument("catalog", nargs="+", type=Path, help="URL catalog file(s).")
    parser.add_argument("--mirror-root", type=Path, default=Path("rebuild/inventory/item-assets/files"))
    parser.add_argument("--report-dir", type=Path, default=Path("rebuild/inventory/item-assets"))
    parser.add_argument("--workers", type=int, default=12)
    parser.add_argument("--timeout", type=int, default=30)
    parser.add_argument("--retries", type=int, default=2)
    parser.add_argument("--force", action="store_true")
    parser.add_argument("--start", type=int, default=0, help="Skip the first N URLs before processing.")
    parser.add_argument("--limit", type=int, default=0, help="Download only the first N URLs; useful for validation.")
    args = parser.parse_args()

    socket.setdefaulttimeout(args.timeout)
    urls = read_urls(args.catalog)
    if args.start > 0:
        urls = urls[args.start :]
    if args.limit > 0:
        urls = urls[: args.limit]

    print(f"urls={len(urls)} mirror={args.mirror_root} workers={args.workers}", flush=True)
    started = time.perf_counter()
    results: list[DownloadResult] = []
    counts: dict[str, int] = {}

    with ThreadPoolExecutor(max_workers=max(1, args.workers)) as executor:
        futures = [
            executor.submit(download_one, url, args.mirror_root, args.timeout, args.retries, args.force)
            for url in urls
        ]
        for index, future in enumerate(as_completed(futures), start=1):
            result = future.result()
            results.append(result)
            counts[result.status] = counts.get(result.status, 0) + 1
            if index % 500 == 0 or index == len(futures):
                elapsed = int(time.perf_counter() - started)
                summary = " ".join(f"{key}={value}" for key, value in sorted(counts.items()))
                print(f"progress {index}/{len(futures)} elapsed={elapsed}s {summary}", flush=True)

    results.sort(key=lambda item: item.url)
    write_reports(results, args.report_dir)

    elapsed = int(time.perf_counter() - started)
    total_bytes = sum(result.size for result in results if result.status in {"present", "downloaded"})
    summary = " ".join(f"{key}={value}" for key, value in sorted(counts.items()))
    print(f"done elapsed={elapsed}s bytes={total_bytes} {summary}", flush=True)
    return 1 if any(result.status in {"failed", "invalid-present"} for result in results) else 0


if __name__ == "__main__":
    raise SystemExit(main())