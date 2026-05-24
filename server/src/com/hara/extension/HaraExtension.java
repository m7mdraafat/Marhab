package com.hara.extension;

import com.hara.extension.events.UserLifecycleHandler;
import com.hara.protocol.handlers.auth.ConfigHandler;
import com.hara.protocol.handlers.auth.LoginHandler;
import com.hara.protocol.handlers.avatar.AvatarSaveHandler;
import com.hara.protocol.handlers.boot.InitHandler;
import com.hara.protocol.handlers.boot.ListHandler;
import com.hara.protocol.handlers.stubs.OkHandler;
import com.smartfoxserver.v2.core.ISFSEvent;
import com.smartfoxserver.v2.core.SFSEventParam;
import com.smartfoxserver.v2.core.SFSEventType;
import com.smartfoxserver.v2.entities.User;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.exceptions.SFSException;
import com.smartfoxserver.v2.extensions.SFSExtension;

public class HaraExtension extends SFSExtension {

    @Override
    public void init() {
        trace("HaraExtension.init() -- starting");

        addRequestHandler("config", ConfigHandler.class);
        addRequestHandler("login",  LoginHandler.class);
        addRequestHandler("init",   InitHandler.class);

        addRequestHandler("buddylist",       ListHandler.class);
        addRequestHandler("privatechatlist", ListHandler.class);
        addRequestHandler("orderlist",       ListHandler.class);
        addRequestHandler("questlist",       ListHandler.class);
        addRequestHandler("baseclothes",     ListHandler.class);

        addRequestHandler("savebaseclothes", AvatarSaveHandler.class);
        addRequestHandler("avatarcreate",    AvatarSaveHandler.class);

        addEventHandler(SFSEventType.USER_LOGIN,     UserLifecycleHandler.class);
        addEventHandler(SFSEventType.USER_JOIN_ZONE, UserLifecycleHandler.class);

        for (String cmd : STUBBED) addRequestHandler(cmd, OkHandler.class);

        trace("HaraExtension.init() -- registered " + (3 + 5 + 2 + STUBBED.length)
            + " handlers (3 boot, 5 list, 2 avatar, " + STUBBED.length + " stub)");
    }

    @Override
    public void destroy() {
        trace("HaraExtension.destroy()");
        super.destroy();
    }

    @Override
    public void handleClientRequest(String requestId, User user, ISFSObject params) {
        String paramsJson = (params == null) ? "{}" : params.toJson();
        if (paramsJson.length() > 400) paramsJson = paramsJson.substring(0, 400) + "...(truncated)";
        trace("[EXT-REQ] cmd='" + requestId + "' user=" + user.getName() + " params=" + paramsJson);
        super.handleClientRequest(requestId, user, params);
    }

    @Override
    public void handleServerEvent(ISFSEvent event) throws SFSException {
        if (event.getType() == SFSEventType.USER_JOIN_ZONE) {
            trace("user joined zone: " + event.getParameter(SFSEventParam.USER));
        }
        try {
            super.handleServerEvent(event);
        } catch (Exception e) {
            trace("handleServerEvent dispatch failed: " + e.getMessage());
        }
    }

    private static final String[] STUBBED = new String[] {
        "ping",
        "addbuddy", "addbuddyresponse",
        "avatarsalescollect",
        "bartercancel", "barterrequest", "barterresponse",
        "buddyacceptinvitegame", "buddyinvitelocation", "buddylocate", "buddyrespondinvitelocation",
        "campaignquest",
        "changebuddyrating", "changemood", "changeobjectframe", "changeobjectlock", "changestatusmessage",
        "debugcommand",
        "diamondtransferrequest", "diamondtransferresponse",
        "drop", "dropthrowaction",
        "emailActivation", "exchangediamond",
        "farmclean", "farmgather", "farmimplantation",
        "flatpurchase", "fortunewheel",
        "gatheritemcollect", "gatheritemsearch", "giftcheckexchange", "groupwhisper",
        "matchmakingCancel", "messagedetails",
        "partyIsland.leave", "partyIsland.rollDice",
        "privatechatdeletegroup", "purchase",
        "questaction", "randomwheel",
        "removeavatarrestriction", "removebuddy",
        "roomjoincomplete",
        "startroomvideo", "stickerlist",
        "teleport",
        "transferrequest", "transferresponse",
        "usechatballoon", "usedoor", "usehanditem", "usehousedoor", "useobjectdoor", "usesticker",
        "walkfinalrequest", "walkrequest",
        "whisper"
    };
}