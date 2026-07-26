package com.hara.protocol.handlers.avatar;

import com.hara.domain.model.Avatar;
import com.hara.protocol.framework.BadRequestException;
import com.hara.protocol.framework.HandlerBase;
import com.hara.protocol.framework.ResponseBuilder;
import com.hara.protocol.framework.ServiceErrorCode;
import com.hara.service.auth.UserSession;
import com.hara.service.avatar.AvatarService;
import com.smartfoxserver.v2.entities.User;
import com.smartfoxserver.v2.entities.data.ISFSArray;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSArray;
import com.smartfoxserver.v2.entities.data.SFSObject;

/**
 * Returns the current avatar's full wardrobe under {@code items:[...]}.
 * Today equals the equipped outfit (no separate inventory store yet);
 * Wave 5 will broaden it with owned-but-not-equipped items.
 */
public final class ClothListHandler extends HandlerBase {

    private final AvatarService avatars;

    public ClothListHandler(AvatarService avatars) { this.avatars = avatars; }

    @Override
    protected String command() { return "clothlist"; }

    @Override
    protected ISFSObject handle(User user, ISFSObject params) {
        long avatarId = UserSession.avatarId(user).orElseThrow(() ->
            new BadRequestException(ServiceErrorCode.AVATAR_NOT_FOUND, "no avatar bound to session"));
        Avatar avatar = avatars.requireById(avatarId);
        return new ResponseBuilder().putArr("items", toArray(avatar)).build();
    }

    static ISFSArray toArray(Avatar avatar) {
        ISFSArray arr = new SFSArray();
        for (var c : avatar.clothes()) {
            ISFSObject o = new SFSObject();
            o.putUtfString("clip", c.clip());
            if (c.hasColor()) o.putInt("color", c.color());
            arr.addSFSObject(o);
        }
        return arr;
    }
}
