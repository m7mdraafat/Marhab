package com.hara.service.catalog;

import com.hara.domain.enums.CellType;
import com.hara.domain.model.RoomGrid;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Build a walkability grid from a captured production {@code map.xml}.
 * Mirrors {@code GridManager.doFixedObjectOperations()} from the client:
 * every {@code <box>}/{@code <chair>}/{@code <stuff>}/{@code <pool>}
 * entry stamps its {@code w x d} footprint as {@link CellType#TYPE_DISABLED}.
 * {@code <floor>} entries are walk-through (they paint visuals only).
 *
 * <p>Grid dimensions are inferred from the maximum {@code (x+w, z+d)} seen
 * in the XML, rounded up to a generous bounding box so off-map obstacles
 * (pier, water, etc.) don't constrain the walkable street area.
 */
public final class MapXmlGridSynth {

    /** Floor of cells past the rightmost/southmost obstacle to keep walkable. */
    private static final int PADDING = 6;
    /** Hard cap so a stray off-map obstacle doesn't blow grid size up. */
    private static final int MAX_DIM = 256;

    private static final Pattern ENTRY_RE = Pattern.compile(
        "<(?<tag>box|chair|stuff|pool|cinema|exhibition|youtube|sound|billboard|farm|cencor)\\b(?<attrs>[^/>]*?)/>",
        Pattern.DOTALL);

    private MapXmlGridSynth() {}

    public static RoomGrid synthesize(String mapXml) {
        if (mapXml == null || mapXml.isEmpty()) return RoomGrid.allEmpty(40, 40);

        // First pass: bounding box
        int maxX = 0, maxZ = 0;
        Matcher m = ENTRY_RE.matcher(mapXml);
        while (m.find()) {
            String attrs = m.group("attrs");
            Entry e = parseEntry(attrs);
            if (e == null) continue;
            if (e.x < 0 || e.z < 0) continue;          // skip negative-positioned decor
            if (e.x > MAX_DIM || e.z > MAX_DIM) continue;
            maxX = Math.max(maxX, e.x + Math.max(1, e.w));
            maxZ = Math.max(maxZ, e.z + Math.max(1, e.d));
        }
        int w = Math.min(MAX_DIM, Math.max(40, maxX + PADDING));
        int h = Math.min(MAX_DIM, Math.max(40, maxZ + PADDING));
        byte[] cells = new byte[w * h]; // 0 == TYPE_EMPTY

        // Second pass: stamp footprints
        m.reset();
        while (m.find()) {
            String tag = m.group("tag");
            String attrs = m.group("attrs");
            Entry e = parseEntry(attrs);
            if (e == null) continue;
            if (e.x < 0 || e.z < 0 || e.x >= w || e.z >= h) continue;
            // Billboards are typically signs hung above the ground -- they're
            // visual-only. Same for the abstract <farm> tile container which
            // the client treats as the parent of plantable cells.
            if ("billboard".equals(tag) || "farm".equals(tag)) continue;
            int ww = Math.max(1, e.w);
            int dd = Math.max(1, e.d);
            for (int dx = 0; dx < ww; dx++) {
                for (int dz = 0; dz < dd; dz++) {
                    int xx = e.x + dx;
                    int zz = e.z + dz;
                    if (xx >= 0 && xx < w && zz >= 0 && zz < h) {
                        cells[zz * w + xx] = CellType.TYPE_DISABLED;
                    }
                }
            }
        }
        return new RoomGrid(w, h, cells);
    }

    private static Entry parseEntry(String attrs) {
        Integer x = readInt(attrs, "x");
        Integer z = readInt(attrs, "z");
        if (x == null || z == null) return null;
        int ww = orDefault(readInt(attrs, "w"), 1);
        int dd = orDefault(readInt(attrs, "d"), 1);
        return new Entry(x, z, ww, dd);
    }

    private static Integer readInt(String attrs, String name) {
        // Matches attr='123' or attr="123" or attr=123
        Pattern p = Pattern.compile("\\b" + name + "\\s*=\\s*(?:\"([^\"]+)\"|'([^']+)'|(-?\\d+))");
        Matcher m = p.matcher(attrs);
        if (!m.find()) return null;
        String v = m.group(1);
        if (v == null) v = m.group(2);
        if (v == null) v = m.group(3);
        if (v == null) return null;
        try {
            // attrs are sometimes floats ("0.7"); use the integer part.
            int dot = v.indexOf('.');
            if (dot > 0) v = v.substring(0, dot);
            return Integer.parseInt(v.trim());
        } catch (NumberFormatException e) { return null; }
    }

    private static int orDefault(Integer v, int def) { return v == null ? def : v; }

    private static final class Entry {
        final int x, z, w, d;
        Entry(int x, int z, int w, int d) { this.x = x; this.z = z; this.w = w; this.d = d; }
    }
}
