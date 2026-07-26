package com.hara.service.room;

import java.util.List;

import com.hara.domain.model.ClothItem;

/**
 * Tiny encoders for free-form fields the client expects as JSON-in-a-string
 * (rather than as nested SFS objects). Kept separate from {@link RoomService}
 * to make the conversion logic unit-testable without dragging in SFS.
 */
public final class UserVariablePayloads {

    private UserVariablePayloads() {}

    /**
     * {@code clothes} UserVariable shape: JSON Array of {@code "<clip>_<color>"}
     * strings (e.g. {@code ["C_2","A_2","84_10",...]}). The client's
     * {@code Character.setAccesory()} concatenates {@code sex + "_" + element}
     * to form the {@code ItemModel.clothDataDict} lookup key, and that dict
     * is keyed by {@code <gender>_<clip>_<color>} (per
     * {@code InfoFileParser.as} line 211). Sending bare clip names
     * ({@code "C"}) makes the lookup miss every entry — character ends up
     * with no body parts and {@code drawCharNormal()} bails to a 0-pixel
     * {@code Ghost} placeholder, making the avatar invisible in the room.
     */
    public static String clothesJson(List<ClothItem> clothes) {
        if (clothes == null || clothes.isEmpty()) return "[]";
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < clothes.size(); i++) {
            if (i > 0) sb.append(',');
            ClothItem c = clothes.get(i);
            sb.append('"').append(escape(c.clip()));
            if (c.hasColor()) sb.append('_').append(c.color());
            sb.append('"');
        }
        sb.append(']');
        return sb.toString();
    }

    private static String escape(String s) {
        if (s == null) return "";
        StringBuilder out = new StringBuilder(s.length());
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            if (c == '"' || c == '\\') out.append('\\').append(c);
            else if (c < 0x20) out.append(String.format("\\u%04x", (int) c));
            else out.append(c);
        }
        return out.toString();
    }
}
