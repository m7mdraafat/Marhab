"""mine-assets.py — scan the decompiled snl.780.swf source tree and collect every
asset/module identifier the client tries to resolve via ModuleModel.getPath()
or PanelVO.name, plus every server-push event the client subscribes to.

Output: rebuild/inventory/asset_catalog.json with three categories:
  panels[]   — every panel SWF name (PanelVO.name = "X")
  modules{}  — every getPath("X","ModuleType.Y") pair grouped by module type
  push[]     — every listenExtension("X", ...) event name
"""
from __future__ import annotations
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent
SRC  = ROOT / "inventory" / "snl_780_src" / "scripts"
OUT  = ROOT / "inventory" / "asset_catalog.json"

# Regex patterns
RE_PANEL   = re.compile(r'\.name\s*=\s*"([A-Za-z0-9_.]+Panel)"')
RE_PANEL2  = re.compile(r'new\s+PanelVO\s*\(\s*"([A-Za-z0-9_.]+)"')
RE_GETPATH = re.compile(r'\.getPath\s*\(\s*"([^"\s]+)"\s*,\s*"(ModuleType\.[A-Z_]+)"')
RE_GETPATH_DYN = re.compile(r'\.getPath\s*\(\s*([A-Za-z_][\w.\[\]]*)\s*,\s*"(ModuleType\.[A-Z_]+)"')
RE_LISTEN  = re.compile(r'listenExtension\s*\(\s*"([A-Za-z0-9_.]+)"')
RE_REQUEST = re.compile(r'requestData\s*\(\s*"([A-Za-z0-9_.]+)"')

panels: set[str] = set()
modules: dict[str, set[str]] = {}
dyn_modules: dict[str, set[str]] = {}   # module-type -> variable-reference string
listens: set[str] = set()
requests: set[str] = set()

for path in SRC.rglob("*.as"):
    try:
        text = path.read_text(encoding="utf-8", errors="ignore")
    except Exception:
        continue
    for m in RE_PANEL.finditer(text):
        panels.add(m.group(1))
    for m in RE_PANEL2.finditer(text):
        panels.add(m.group(1))
    for m in RE_GETPATH.finditer(text):
        modules.setdefault(m.group(2), set()).add(m.group(1))
    for m in RE_GETPATH_DYN.finditer(text):
        # filter out obvious literal-string-already-matched cases
        var = m.group(1)
        if var.startswith('"'):
            continue
        dyn_modules.setdefault(m.group(2), set()).add(var)
    for m in RE_LISTEN.finditer(text):
        listens.add(m.group(1))
    for m in RE_REQUEST.finditer(text):
        requests.add(m.group(1))

out = {
    "panels": sorted(panels),
    "modules": {k: sorted(v) for k, v in sorted(modules.items())},
    "modules_dynamic": {k: sorted(v) for k, v in sorted(dyn_modules.items())},
    "listenExtension": sorted(listens),
    "requestData": sorted(requests),
    "summary": {
        "panel_count": len(panels),
        "module_static_count": sum(len(v) for v in modules.values()),
        "module_type_count": len(modules),
        "listen_count": len(listens),
        "request_count": len(requests),
    },
}
OUT.write_text(json.dumps(out, indent=2), encoding="utf-8")
print(f"wrote {OUT}")
print("summary:", json.dumps(out["summary"], indent=2))
