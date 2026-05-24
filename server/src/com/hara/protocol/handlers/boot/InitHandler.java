package com.hara.protocol.handlers.boot;

import com.hara.service.UserStateRegistry;

import com.hara.service.RoomService;

import com.smartfoxserver.v2.entities.User;
import com.smartfoxserver.v2.entities.data.ISFSArray;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSArray;
import com.smartfoxserver.v2.entities.data.SFSObject;
import com.smartfoxserver.v2.extensions.BaseClientRequestHandler;

import java.util.Base64;

/**
 * Handles the game's bootstrap "init" extension request.
 *
 * The client expects a fairly rich object here. For local/dev bring-up we keep
 * it intentionally small and force avatar creation mode so room/world payloads
 * are not required yet.
 */
public class InitHandler extends BaseClientRequestHandler {

    @Override
    public void handleClientRequest(User user, ISFSObject params) {
        long rid = (params != null && params.containsKey("rid")) ? params.getLong("rid") : 0L;
        UserStateRegistry.UserState st = UserStateRegistry.forUser(user);

        ISFSObject response = new SFSObject();
        response.putLong("ts", System.currentTimeMillis());

        // Sanalika.process() branches on these:
        //   checkAvatar == 0           -> AvatarCreatePanel (BaseCloth)
        //   checkAvatar != 0 + create  -> AvatarCreatePanel (full create)
        //   checkAvatar != 0 + !create -> normal room/HUD bootstrap
        // After the user has selected base clothes once we MUST send a non-zero
        // checkAvatar so the panel doesn't open on every reconnect.
        response.putBool("guest", true);
        response.putUtfString("gender", st.gender);
        response.putInt("completedAchievementsCount", 0);
        response.putInt("checkAvatar", st.baseClothSelected ? 1 : 0);
        response.putBool("createAvatar", false);

        // Optional fields consumed by various startup branches.
        response.putUtfString("selectedAvatarID", st.avatarId);
        response.putUtfString("email", "");

        ISFSObject settings = new SFSObject();
        settings.putInt("wideMode", 0);
        settings.putInt("showInvitations", 1);
        settings.putInt("transferRequests", 1);
        settings.putInt("incomingMessages", 1);
        settings.putInt("tradeRequests", 1);
        settings.putInt("whisperMessage", 1);
        settings.putInt("flatNotifications", 1);
        settings.putInt("onlyBuddyWhisper", 0);
        settings.putInt("verifySession", 0);
        response.putSFSObject("settings", settings);

        ISFSArray wallet = new SFSArray();
        wallet.addSFSObject(currency("SANIL", "1000"));
        wallet.addSFSObject(currency("DIAMOND", "100"));
        response.putSFSArray("wallet", wallet);

        ISFSObject clothes = new SFSObject();
        clothes.putSFSArray("items", new SFSArray());
        response.putSFSObject("clothes", clothes);

        ISFSObject room = new SFSObject();
        room.putUtfString("doorKey", "d1");
        room.putUtfString("map", minimalMapBase64());
        response.putSFSObject("room", room);

        response.putSFSArray("extensionInfo", new SFSArray());

        send("init", response, user);
        trace("InitHandler: sent init bootstrap for user=" + user.getName() + " rid=" + rid);

        // Auto-join the default lobby AFTER init replies. By now the client's
        // RoomController has registered its `roomJoin` listener (wired in
        // Sanalika.initCommandsCompleted), so the join event will actually
        // reach onJoinRoom -> startload -> scene render -> splash hides.
        // Skip if the user is still in the AvatarCreatePanel branch (the panel
        // calls Connectr.reset() after confirm, which triggers a re-login;
        // we'll auto-join on that second init).
        if (st.baseClothSelected) {
            RoomService.autoJoinDefaultLobby(
                (com.smartfoxserver.v2.extensions.SFSExtension) getParentExtension(),
                user);
        } else {
            trace("InitHandler: skipping autoJoin -- user still needs AvatarCreatePanel");
        }
    }

    private ISFSObject currency(String code, String balance) {
        ISFSObject c = new SFSObject();
        c.putUtfString("currency", code);
        c.putUtfString("balance", balance);
        return c;
    }

    private String minimalMapBase64() {
        String xml = "<map><cell x=\"0\" y=\"0\"/></map>";
        return Base64.getEncoder().encodeToString(xml.getBytes(java.nio.charset.StandardCharsets.UTF_8));
    }
}
