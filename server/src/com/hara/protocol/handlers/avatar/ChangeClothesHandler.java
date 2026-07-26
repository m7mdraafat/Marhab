package com.hara.protocol.handlers.avatar;

import java.util.List;

import com.hara.domain.model.Avatar;
import com.hara.domain.model.ClothItem;
import com.hara.protocol.framework.BadRequestException;
import com.hara.protocol.framework.HandlerBase;
import com.hara.protocol.framework.ResponseBuilder;
import com.hara.protocol.framework.ServiceErrorCode;
import com.hara.service.auth.UserSession;
import com.hara.service.avatar.AvatarService;
import com.hara.service.room.UserVariablePayloads;
import com.hara.service.room.VariableNames;
import com.smartfoxserver.v2.entities.User;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.variables.SFSUserVariable;
import com.smartfoxserver.v2.entities.variables.UserVariable;
import com.smartfoxserver.v2.extensions.SFSExtension;

/**
 * Live outfit swap. Updates the avatar's persisted clothes AND publishes
 * the new {@code clothes} UserVariable so other users in the room see the
 * change in real time (via SFS's automatic user-var broadcast).
 *
 * <p>Wire shape in: {@code { clothes:[{clip,color?},...] }}.
 * Wire shape out: echoes the equipped list, so the client's callback can
 * refresh its preview without an extra round-trip.
 */
public final class ChangeClothesHandler extends HandlerBase {

    private final SFSExtension extension;
    private final AvatarService avatars;

    public ChangeClothesHandler(SFSExtension extension, AvatarService avatars) {
        this.extension = extension;
        this.avatars = avatars;
    }

    @Override
    protected String command() { return "changeclothes"; }

    @Override
    protected ISFSObject handle(User user, ISFSObject params) throws Exception {
        long avatarId = UserSession.avatarId(user).orElseThrow(() ->
            new BadRequestException(ServiceErrorCode.AVATAR_NOT_FOUND, "no avatar bound to session"));

        List<ClothItem> newClothes = ClothesPayloadCodec.decode(params, "clothes");
        avatars.updateClothes(avatarId, newClothes);

        UserVariable uv = new SFSUserVariable(VariableNames.UV_CLOTHES,
            UserVariablePayloads.clothesJson(newClothes));
        extension.getApi().setUserVariables(user, List.of(uv));

        Avatar avatar = avatars.requireById(avatarId);
        return new ResponseBuilder().putArr("items", ClothListHandler.toArray(avatar)).build();
    }
}
