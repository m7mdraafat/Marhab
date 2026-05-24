package com.hara.protocol.handlers.avatar;

import com.hara.service.UserStateRegistry;

import com.smartfoxserver.v2.entities.User;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSObject;
import com.smartfoxserver.v2.extensions.BaseClientRequestHandler;

/**
 * Handles AvatarCreatePanel save flow.
 *
 * Routes both "savebaseclothes" and "avatarcreate" commands. The panel's
 * saveResponseFunction in AvatarCreatePanel.as expects:
 *   success: {avatarID: "<string>"}
 *   failure: {errorCode: <int>, message: "<translation key>"}
 *
 * On success the client sets avatarModel.isBaseClothSelected = true,
 * stores avatarId, then calls Connectr.reset() which re-runs the bootstrap.
 * That re-issued init MUST return checkAvatar != 0 so Sanalika.process()
 * skips back through the AvatarCreatePanel branch â€” InitHandler reads
 * UserStateRegistry to decide.
 *
 * Request params (from the panel):
 *   savebaseclothes: {clothes: [...], gender: "m"|"f", avatarName: "..."}
 *   avatarcreate:    {clothes: [...], avatarName, gender, token}
 */
public class AvatarSaveHandler extends BaseClientRequestHandler {

    @Override
    public void handleClientRequest(User user, ISFSObject params) {
        String cmd = (params != null && params.containsKey("sn"))
                ? params.getUtfString("sn") : "?";

        String gender     = params != null && params.containsKey("gender")     ? params.getUtfString("gender")     : "m";
        String avatarName = params != null && params.containsKey("avatarName") ? params.getUtfString("avatarName") : "";

        UserStateRegistry.UserState st = UserStateRegistry.forUser(user);
        st.gender     = gender;
        st.avatarName = avatarName.trim();
        st.baseClothSelected = true;
        if ("avatarcreate".equals(cmd)) {
            st.avatarCreated = true;
        }
        // avatarId stays "1" â€” dev only; a real impl would mint a unique id.

        ISFSObject response = new SFSObject();
        response.putUtfString("avatarID", st.avatarId);
        send(cmd, response, user);

        trace("AvatarSaveHandler: " + cmd + " user=" + user.getName()
                + " gender=" + gender + " name='" + avatarName + "' -> avatarID=" + st.avatarId);
    }
}
