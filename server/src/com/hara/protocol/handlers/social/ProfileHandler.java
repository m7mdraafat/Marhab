package com.hara.protocol.handlers.social;

import com.hara.protocol.framework.HandlerBase;
import com.hara.protocol.framework.ResponseBuilder;
import com.hara.protocol.wire.ServerEnvelope;
import com.smartfoxserver.v2.entities.User;
import com.smartfoxserver.v2.entities.data.ISFSArray;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSArray;
import com.smartfoxserver.v2.entities.data.SFSObject;

/**
 * Avatar profile card. Sniffed shape has 5 variants depending on the
 * avatar's customisations; we return the minimal-but-complete base shape
 * which the client renders without optional decorations.
 *
 * <p>Until persistence lands, we echo back a static "stranger" profile so
 * the client doesn't crash on null fields.
 */
public final class ProfileHandler extends HandlerBase {

    @Override
    protected String command() { return "profile"; }

    @Override
    protected ISFSObject handle(User user, ISFSObject params) {
        String avatarId = params.containsKey("avatarID") ? params.getUtfString("avatarID") : "0";

        ISFSObject skinProp = new SFSObject();
        skinProp.putUtfString("cn",        "DefaultSkin");
        skinProp.putUtfString("bgColor",   "FFFFFF");
        skinProp.putUtfString("textColor", "000000");
        skinProp.putUtfString("alpha",     "1");
        ISFSObject skin = new SFSObject();
        skin.putUtfString("clip", "default");
        skin.putSFSObject("property", skinProp);

        return ServerEnvelope.stamp(
            new ResponseBuilder()
                .putStr ("avatarName",      "Stranger#" + avatarId)
                .putInt ("avatarAge",       0)
                .putStr ("avatarCity",      "")
                .putStr ("avarageRating",   "0")
                .putInt ("likeCount",       0)
                .putInt ("dislikeCount",    0)
                .putInt ("totalBuddies",    0)
                .putInt ("banCount",        0)
                .putInt ("duration",        0)
                .putInt ("emailRegistered", 0)
                .putInt ("privilegeId",     1)
                .putInt ("mood",            0)
                .putStr ("status",          "")
                .putStr ("runWinTeam",      "")
                .putBool("isBuddy",         false)
                .putBool("isRequest",       false)
                .putBool("hasBestFriend",   false)
                .putArr ("badges",          new SFSArray())
                .putArr ("cards",           new SFSArray())
                .putArr ("stickers",        new SFSArray())
                .putArr ("flats",           new SFSArray())
                .putObj ("skin",            skin),
            ServerEnvelope.NEXT_DEFAULT)
            .build();
    }
}
