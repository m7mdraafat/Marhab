"""
mine-asset-urls.py
------------------
Read the local cached ifile.2013, decode it, and emit EVERY URL the inner
SWF might request for clothes / inventory / smileys, using the URL templates
from ModuleModel.as.

Pure offline: no HTTP, no DNS, no CDN contact. Output is plain text, one URL
per line per kind, plus a combined file and a quick coverage report
(cross-referenced against asset-cache/ to see what organic play has seeded).

DO NOT pipe these lists into a bulk downloader. See
memories/repo/mygame-clothes.md for why.
"""

from __future__ import annotations

import base64
import argparse
import os
import sys
from pathlib import Path

HOST = "http://xo.newmarhab.net/global"
GENDERS = ("m", "f")
QS = ""  # ModuleModel adds "-2x" when quality == "hd"; standard quality here.

PATTERNS = {
    "cloth_swf": f"{HOST}/static/items{QS}/clothes/{{key}}{{ver}}.swf",
    "cloth_png": f"{HOST}/static/items{QS}/clothes/r_{{key}}{{ver}}.png",
    "inv_swf":   f"{HOST}/static/items{QS}/inventory/{{key}}{{ver}}.swf",
    "inv_png":   f"{HOST}/static/items{QS}/inventory/{{key}}.png?v={{vraw}}",
    "smiley":    f"{HOST}/static/items{QS}/smileys/{{key}}.{{vraw}}.swf",
}


def cache_root() -> Path:
    appdata = os.environ.get("APPDATA")
    if not appdata:
        sys.exit("APPDATA env var missing.")
    return (Path(appdata) / "com.mygame.standalone" / "Local Store"
            / "asset-cache")


def ifile_path() -> Path:
    p = (cache_root() / "xo.newmarhab.net" / "global"
         / "static" / "data" / "ifile.2013")
    if not p.exists():
        sys.exit(f"ifile.2013 not cached at {p}\n"
                 "Run the game once so MyGameAssetProxy seeds it.")
    return p


def decode_ifile(path: Path) -> list[str]:
    raw = path.read_text(encoding="utf-8")
    decoded = base64.b64decode(raw).decode("utf-8", errors="replace")
    return [ln for ln in decoded.split("\n") if ln]


def emit_for_line(parts: list[str]) -> tuple[str, list[str]]:
    """Return (kind, urls) for a single ifile line."""
    n = len(parts)
    if n == 7:
        clip = parts[0]
        colors = [c for c in parts[1].split(",") if c]
        try:
            version = int(parts[6])
        except ValueError:
            return "skip", []
        ver_suffix = f".{version}" if version > 0 else ""
        urls = []
        for g in GENDERS:
            for col in colors:
                key = f"{g}_{clip}_{col}"
                urls.append(PATTERNS["cloth_swf"].format(key=key, ver=ver_suffix))
                urls.append(PATTERNS["cloth_png"].format(key=key, ver=ver_suffix))
        return "cloth", urls
    if n == 4:
        name = parts[0]
        try:
            version = int(parts[3])
        except ValueError:
            return "skip", []
        ver_suffix = f".{version}" if version > 0 else ""
        urls = []
        for g in GENDERS:
            key = f"{g}_{name}"
            urls.append(PATTERNS["inv_swf"].format(key=key, ver=ver_suffix))
            urls.append(PATTERNS["inv_png"].format(key=key, vraw=version))
        return "inv", urls
    if n == 2:
        name = parts[0]
        try:
            version = int(parts[1])
        except ValueError:
            return "skip", []
        return "smiley", [PATTERNS["smiley"].format(key=name, vraw=version)]
    return "skip", []


def url_to_cache_path(url: str) -> Path:
    """Mirror MyGameAssetProxy._cacheFileFor for coverage check."""
    rest = url.split("://", 1)[1] if "://" in url else url
    for sep in ("?", "#"):
        i = rest.find(sep)
        if i >= 0:
            rest = rest[:i]
    for ch in ':*?"<>|':
        rest = rest.replace(ch, "_")
    return cache_root() / rest


def main() -> None:
    parser = argparse.ArgumentParser(description="Emit asset URLs from an ifile catalog.")
    parser.add_argument(
        "--ifile",
        type=Path,
        default=ifile_path(),
        help="Base64-encoded ifile catalog. Defaults to the AIR asset cache ifile.2013.",
    )
    parser.add_argument(
        "--out-dir",
        type=Path,
        default=None,
        help="Output directory for URL catalogs. Defaults to rebuild/inventory/url-catalog.",
    )
    args = parser.parse_args()

    repo = Path(__file__).resolve().parent.parent
    out_dir = args.out_dir or repo / "rebuild" / "inventory" / "url-catalog"
    out_dir.mkdir(parents=True, exist_ok=True)

    lines = decode_ifile(args.ifile)
    by_kind: dict[str, list[str]] = {"cloth": [], "inv": [], "smiley": []}
    counts = {"cloth": 0, "inv": 0, "smiley": 0, "skip": 0}

    for ln in lines:
        kind, urls = emit_for_line(ln.split("|"))
        counts[kind] = counts.get(kind, 0) + 1
        if kind != "skip":
            by_kind[kind].extend(urls)

    all_urls: list[str] = []
    for kind, urls in by_kind.items():
        (out_dir / f"{kind}.urls.txt").write_text(
            "\n".join(urls) + "\n", encoding="utf-8")
        all_urls.extend(urls)
    (out_dir / "all.urls.txt").write_text(
        "\n".join(all_urls) + "\n", encoding="utf-8")

    cached = sum(1 for u in all_urls if url_to_cache_path(u).exists())

    print(f"ifile lines     : {len(lines)}")
    print(f"  cloth entries : {counts['cloth']:>6}")
    print(f"  inv   entries : {counts['inv']:>6}")
    print(f"  smiley entries: {counts['smiley']:>6}")
    print(f"  unrecognized  : {counts['skip']:>6}")
    print()
    print(f"URLs emitted    : {len(all_urls)}")
    print(f"  cloth URLs    : {len(by_kind['cloth']):>6}")
    print(f"  inv   URLs    : {len(by_kind['inv']):>6}")
    print(f"  smiley URLs   : {len(by_kind['smiley']):>6}")
    print()
    pct = 100.0 * cached / max(1, len(all_urls))
    print(f"Already cached  : {cached} / {len(all_urls)}  ({pct:.2f}%)")
    print(f"Output dir      : {out_dir}")


if __name__ == "__main__":
    main()
