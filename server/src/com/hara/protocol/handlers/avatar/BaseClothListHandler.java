package com.hara.protocol.handlers.avatar;

import com.hara.domain.model.Avatar;
import com.hara.protocol.framework.BadRequestException;
import com.hara.protocol.framework.HandlerBase;
import com.hara.protocol.framework.ResponseBuilder;
import com.hara.protocol.framework.ServiceErrorCode;
import com.hara.service.auth.UserSession;
import com.hara.service.avatar.AvatarService;
import com.smartfoxserver.v2.entities.User;
import com.smartfoxserver.v2.entities.data.ISFSObject;

/**
 * Returns the avatar's saved base outfit (the one auto-equipped on login).
 * For now identical to {@code clothlist} since we don't yet track a
 * separate "base" pin — Wave 5 will diverge them.
 */
public final class BaseClothListHandler extends HandlerBase {

    private final AvatarService avatars;

    public BaseClothListHandler(AvatarService avatars) { this.avatars = avatars; }

    @Override
    protected String command() { return "baseclothlist"; }

    @Override
    protected ISFSObject handle(User user, ISFSObject params) {
        long avatarId = UserSession.avatarId(user).orElseThrow(() ->
            new BadRequestException(ServiceErrorCode.AVATAR_NOT_FOUND, "no avatar bound to session"));
        Avatar avatar = avatars.requireById(avatarId);
        return new ResponseBuilder().putArr("items", ClothListHandler.toArray(avatar)).build();
    }
}
