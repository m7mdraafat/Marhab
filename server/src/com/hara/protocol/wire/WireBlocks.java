package com.hara.protocol.wire;

import com.hara.domain.model.Place;
import com.hara.protocol.framework.ResponseBuilder;
import com.hara.service.catalog.WireCodecs;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSObject;

/**
 * Builds the two repeated blocks the live server stamps on init/usedoor
 * replies (verified against {@code docs/protocol-sniffed.md}):
 *
 * <ul>
 *   <li>{@code universe} — describes the player's home universe and
 *       capacity hints. The client uses this on every room transition to
 *       refresh the universe-selector HUD.</li>
 *   <li>{@code room} — minimal scene-load payload: {@code key}, {@code doorKey},
 *       {@code map} (base64 XML), plus {@code dv}/{@code pv} placeholders
 *       (room-version / pack-version, always 0 in our build).</li>
 * </ul>
 *
 * Wire shape mirrors live Marhab exactly — extra fields here will be
 * silently ignored by the client but missing required fields wedge the HUD.
 */
public final class WireBlocks {

    /** Default universe key/name. Hard-coded today; per-account in a later wave. */
    public static final String DEFAULT_UNIVERSE_KEY  = "w1";
    public static final String DEFAULT_UNIVERSE_NAME = "Marhab";

    private WireBlocks() {}

    /** Build the {@code universe} sub-object. */
    public static ISFSObject universe() {
        return new ResponseBuilder()
            .putStr("key",            DEFAULT_UNIVERSE_KEY)
            .putStr("name",           DEFAULT_UNIVERSE_NAME)
            .putInt("fullness",       1)
            .putInt("roomFullness",   0)
            .putBool("roomAvailable", true)
            .putBool("recommended",   false)
            .putStr("roles",          "AA==")
            .build();
    }

    /**
     * Build the {@code room} sub-object the client feeds into
     * {@code RoomModel.checkMap}: {@code {key, doorKey, map, dv, pv}}.
     */
    public static ISFSObject room(Place place, String doorKey) {
        ISFSObject r = new SFSObject();
        r.putUtfString("key",     place.key());
        r.putUtfString("doorKey", doorKey == null || doorKey.isBlank()
            ? place.defaultDoorKey() : doorKey);
        r.putUtfString("map",     WireCodecs.encodeMap(place.mapXml()));
        r.putInt("dv", 0);
        r.putInt("pv", 0);
        return r;
    }
}
