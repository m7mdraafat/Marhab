package com.hara.service.catalog;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.util.Base64;

import com.hara.domain.model.RoomGrid;

/**
 * Wire encoders for the two pieces of room data the client decodes at
 * scene-load time:
 * <ul>
 *   <li>{@link #encodeGrid(RoomGrid)} — base64 of
 *       {@code [int32 width BE][int32 height BE][w*h signed bytes]}
 *       (matches {@code GridModel.load}, see {@code docs/04 §4.4}).</li>
 *   <li>{@link #encodeMap(String)} — base64-UTF-8 of the room map XML
 *       (matches {@code RoomModel.checkMap}, see {@code docs/04 §4.3}).</li>
 * </ul>
 */
public final class WireCodecs {

    private WireCodecs() {}

    public static String encodeGrid(RoomGrid grid) {
        int w = grid.width();
        int h = grid.height();
        ByteBuffer buf = ByteBuffer.allocate(8 + w * h);
        buf.order(ByteOrder.BIG_ENDIAN); // AS3 ByteArray default
        buf.putInt(w);
        buf.putInt(h);
        buf.put(grid.cells());
        return Base64.getEncoder().encodeToString(buf.array());
    }

    public static String encodeMap(String xml) {
        if (xml == null) xml = "";
        byte[] raw = xml.getBytes(java.nio.charset.StandardCharsets.UTF_8);
        return Base64.getEncoder().encodeToString(raw);
    }

    /**
     * JSON-encode an array of doors for the {@code doors} RoomVariable. Kept
     * here (not in a separate module) because it's tiny and only used by the
     * scene boot path. Replace with a real JSON library when payloads grow.
     */
    public static String encodeDoorsJson(java.util.List<com.hara.domain.model.DoorDef> doors) {
        if (doors == null || doors.isEmpty()) return "[]";
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < doors.size(); i++) {
            if (i > 0) sb.append(',');
            var d = doors.get(i);
            sb.append('{');
            appendStr(sb, "key", d.key()); sb.append(',');
            appendInt(sb, "targetX", d.targetX()); sb.append(',');
            appendInt(sb, "targetY", d.targetY()); sb.append(',');
            appendInt(sb, "targetDir", d.targetDir()); sb.append(',');
            sb.append("\"property\":{");
            appendStr(sb, "cn", d.propertyClass());
            for (var e : d.propertyData().entrySet()) {
                sb.append(',');
                Object v = e.getValue();
                if (v instanceof Number) appendInt(sb, e.getKey(), ((Number) v).longValue());
                else appendStr(sb, e.getKey(), String.valueOf(v));
            }
            sb.append("}}");
        }
        sb.append(']');
        return sb.toString();
    }

    private static void appendStr(StringBuilder sb, String k, String v) {
        sb.append('"').append(k).append("\":\"").append(escape(v)).append('"');
    }
    private static void appendInt(StringBuilder sb, String k, long v) {
        sb.append('"').append(k).append("\":").append(v);
    }
    private static String escape(String s) {
        if (s == null) return "";
        StringBuilder out = new StringBuilder(s.length());
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            switch (c) {
                case '"':  out.append("\\\""); break;
                case '\\': out.append("\\\\"); break;
                case '\n': out.append("\\n"); break;
                case '\r': out.append("\\r"); break;
                case '\t': out.append("\\t"); break;
                default:
                    if (c < 0x20) out.append(String.format("\\u%04x", (int) c));
                    else out.append(c);
            }
        }
        return out.toString();
    }

    // ByteArrayOutputStream retained as import in case future codecs need it.
    @SuppressWarnings("unused")
    private static ByteArrayOutputStream _unused() throws IOException { return new ByteArrayOutputStream(); }
}
