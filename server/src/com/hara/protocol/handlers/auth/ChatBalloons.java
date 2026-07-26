package com.hara.protocol.handlers.auth;

import com.smartfoxserver.v2.entities.data.ISFSArray;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSArray;
import com.smartfoxserver.v2.entities.data.SFSObject;

/**
 * Default chat-balloon palette returned in the {@code config} reply.
 * Stored client-side as {@code chatBalloonModel.activeBalloons}; the
 * {@code chatBalloon} UserVariable carries the chosen entry's id.
 */
final class ChatBalloons {

    private static final int[][] ENTRIES = {
        // id, 0xRRGGBB
        { 0, 0xFFFFFF },
        { 1, 0xFFD700 },
        { 2, 0xFF6B6B },
        { 3, 0x6BCEFF },
        { 4, 0xB8FF6B },
        { 5, 0xFF6BFF },
    };

    private ChatBalloons() {}

    static ISFSArray array() {
        ISFSArray arr = new SFSArray();
        for (int[] e : ENTRIES) {
            ISFSObject o = new SFSObject();
            o.putInt("id", e[0]);
            o.putInt("color", e[1]);
            arr.addSFSObject(o);
        }
        return arr;
    }
}
