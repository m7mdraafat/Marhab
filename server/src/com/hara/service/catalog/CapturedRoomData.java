package com.hara.service.catalog;

import com.hara.domain.enums.Direction;
import com.hara.domain.model.DoorDef;
import com.hara.domain.model.RoomGrid;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * Filesystem loader for sniffed room data captured from the live server via
 * {@code rebuild/extract-room-data.py}. Files live under
 * {@code <wwwRoot>/rooms/<roomKey>/}:
 * <ul>
 *   <li>{@code grid.bin}  — raw bytes {@code [int32 BE w][int32 BE h][w*h cells]}</li>
 *   <li>{@code doors.json} — verbatim {@code doors} RoomVariable JSON string</li>
 *   <li>{@code bots.json}  — verbatim {@code bots} RoomVariable JSON string</li>
 *   <li>{@code meta.json}  — captured-at / source-room-name diagnostics</li>
 * </ul>
 * Anything missing falls back to the hand-authored defaults in
 * {@link PlaceCatalog}, so it's always safe to ship the catalog before any
 * captures exist.
 */
public final class CapturedRoomData {

    private CapturedRoomData() {}

    /** Load the captured grid for {@code roomKey}, or {@link Optional#empty()}. */
    public static Optional<RoomGrid> loadGrid(Path wwwRoot, String roomKey) {
        Path p = roomDir(wwwRoot, roomKey).resolve("grid.bin");
        if (!Files.isRegularFile(p)) return Optional.empty();
        try {
            byte[] raw = Files.readAllBytes(p);
            if (raw.length < 8) return Optional.empty();
            ByteBuffer bb = ByteBuffer.wrap(raw).order(ByteOrder.BIG_ENDIAN);
            int w = bb.getInt();
            int h = bb.getInt();
            if (w <= 0 || h <= 0 || raw.length - 8 != w * h) return Optional.empty();
            byte[] cells = new byte[w * h];
            bb.get(cells);
            return Optional.of(new RoomGrid(w, h, cells));
        } catch (IOException e) {
            return Optional.empty();
        }
    }

    /**
     * Parse a captured {@code doors.json} array (each entry has
     * {@code key, targetX, targetY, targetDir, property}). Returns empty
     * list if the file is missing or unparseable.
     *
     * <p>Hand-rolled JSON parsing — the project deliberately avoids a JSON
     * library on the server today. The file shape is fixed by the live
     * server so a strict positional parser is fine.
     */
    public static List<DoorDef> loadDoors(Path wwwRoot, String roomKey) {
        Path p = roomDir(wwwRoot, roomKey).resolve("doors.json");
        if (!Files.isRegularFile(p)) return List.of();
        try {
            String json = Files.readString(p).trim();
            return parseDoorsArray(json);
        } catch (IOException e) {
            return List.of();
        }
    }

    /** Raw bots JSON, returned verbatim for the {@code bots} RoomVariable. */
    public static String loadBotsJson(Path wwwRoot, String roomKey) {
        Path p = roomDir(wwwRoot, roomKey).resolve("bots.json");
        if (!Files.isRegularFile(p)) return "[]";
        try { return Files.readString(p).trim(); } catch (IOException e) { return "[]"; }
    }

    /**
     * Load the captured (decoded) map XML for {@code roomKey}, or empty.
     * The wire payload is base64-encoded by the live server; the extractor
     * writes the decoded XML to {@code map.xml} for human readability.
     */
    public static Optional<String> loadMapXml(Path wwwRoot, String roomKey) {
        Path p = roomDir(wwwRoot, roomKey).resolve("map.xml");
        if (!Files.isRegularFile(p)) return Optional.empty();
        try {
            String xml = Files.readString(p).trim();
            return xml.isEmpty() ? Optional.empty() : Optional.of(xml);
        } catch (IOException e) { return Optional.empty(); }
    }

    private static Path roomDir(Path wwwRoot, String roomKey) {
        if (wwwRoot == null) return Path.of("rooms", roomKey);
        return wwwRoot.resolve("rooms").resolve(roomKey);
    }

    // -----------------------------------------------------------------------
    // tiny positional JSON reader — handles the live `doors` array shape only
    // -----------------------------------------------------------------------

    private static List<DoorDef> parseDoorsArray(String json) {
        List<DoorDef> out = new ArrayList<>();
        int i = skipWs(json, 0);
        if (i >= json.length() || json.charAt(i) != '[') return out;
        i++;
        while (true) {
            i = skipWs(json, i);
            if (i >= json.length()) break;
            char c = json.charAt(i);
            if (c == ']') break;
            if (c == ',') { i++; continue; }
            if (c != '{') break;
            // parse one object
            int end = matchBrace(json, i);
            if (end < 0) break;
            String objStr = json.substring(i, end + 1);
            DoorDef d = parseDoor(objStr);
            if (d != null) out.add(d);
            i = end + 1;
        }
        return out;
    }

    private static DoorDef parseDoor(String obj) {
        String key       = jsonStr(obj, "key");
        Integer tx       = jsonInt(obj, "targetX");
        Integer ty       = jsonInt(obj, "targetY");
        Integer tdir     = jsonInt(obj, "targetDir");
        String propClass = jsonInnerStr(obj, "property", "cn");
        if (key == null || tx == null || ty == null) return null;
        return new DoorDef(
            key,
            tx,
            ty,
            tdir != null ? tdir : Direction.SOUTH,
            propClass != null ? propClass : "PassageProperty",
            java.util.Map.of()
        );
    }

    private static int skipWs(String s, int i) {
        while (i < s.length() && Character.isWhitespace(s.charAt(i))) i++;
        return i;
    }

    private static int matchBrace(String s, int start) {
        int depth = 0;
        boolean inStr = false;
        for (int i = start; i < s.length(); i++) {
            char c = s.charAt(i);
            if (inStr) {
                if (c == '\\') { i++; continue; }
                if (c == '"') inStr = false;
                continue;
            }
            if (c == '"') { inStr = true; continue; }
            if (c == '{') depth++;
            else if (c == '}') { depth--; if (depth == 0) return i; }
        }
        return -1;
    }

    private static String jsonStr(String obj, String key) {
        int p = obj.indexOf("\"" + key + "\"");
        if (p < 0) return null;
        int colon = obj.indexOf(':', p);
        if (colon < 0) return null;
        int q1 = obj.indexOf('"', colon + 1);
        if (q1 < 0) return null;
        int q2 = obj.indexOf('"', q1 + 1);
        if (q2 < 0) return null;
        return obj.substring(q1 + 1, q2);
    }

    private static Integer jsonInt(String obj, String key) {
        int p = obj.indexOf("\"" + key + "\"");
        if (p < 0) return null;
        int colon = obj.indexOf(':', p);
        if (colon < 0) return null;
        int i = colon + 1;
        while (i < obj.length() && Character.isWhitespace(obj.charAt(i))) i++;
        int start = i;
        if (i < obj.length() && (obj.charAt(i) == '-' || obj.charAt(i) == '+')) i++;
        while (i < obj.length() && Character.isDigit(obj.charAt(i))) i++;
        if (start == i) return null;
        try { return Integer.parseInt(obj.substring(start, i)); }
        catch (NumberFormatException e) { return null; }
    }

    /** Read a string under a nested object: {@code outer.inner = "..."}. */
    private static String jsonInnerStr(String obj, String outerKey, String innerKey) {
        int p = obj.indexOf("\"" + outerKey + "\"");
        if (p < 0) return null;
        int braceStart = obj.indexOf('{', p);
        if (braceStart < 0) return null;
        int braceEnd = matchBrace(obj, braceStart);
        if (braceEnd < 0) return null;
        return jsonStr(obj.substring(braceStart, braceEnd + 1), innerKey);
    }
}
