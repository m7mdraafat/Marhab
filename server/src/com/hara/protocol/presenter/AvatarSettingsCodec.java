package com.hara.protocol.presenter;

import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSObject;

/**
 * Defaults for the {@code settings} branch of the init reply. Mirrors what
 * the client merges into {@code AvatarSettings} when no user-saved overrides
 * exist yet. Wire shape only — domain meaning is documented on the client
 * model.
 */
public final class AvatarSettingsCodec {

    private AvatarSettingsCodec() {}

    public static ISFSObject defaults() {
        ISFSObject s = new SFSObject();
        s.putInt("wideMode",          1);
        s.putInt("showInvitations",   1);
        s.putInt("transferRequests",  1);
        s.putInt("incomingMessages",  1);
        s.putInt("tradeRequests",     1);
        s.putInt("whisperMessage",    1);
        s.putInt("flatNotifications", 1);
        s.putInt("onlyBuddyWhisper",  0);
        s.putInt("verifySession",     0);
        return s;
    }
}
