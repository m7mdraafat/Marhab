package com.hara.protocol.handlers.room;

import com.hara.domain.model.Avatar;
import com.hara.domain.model.Place;
import com.hara.infra.audit.AuditLog;
import com.hara.protocol.framework.BadRequestException;
import com.hara.protocol.framework.HandlerBase;
import com.hara.protocol.framework.ResponseBuilder;
import com.hara.protocol.framework.ServiceErrorCode;
import com.hara.protocol.framework.SfsObjectMapper;
import com.hara.service.auth.UserSession;
import com.hara.service.avatar.AvatarService;
import com.hara.service.catalog.PlaceCatalog;
import com.hara.service.catalog.WireCodecs;
import com.hara.service.room.RoomService;
import com.smartfoxserver.v2.entities.User;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSObject;
import com.smartfoxserver.v2.exceptions.SFSException;

/**
 * Free teleport — admin / portal jumps to a known game-owned room. See
 * {@code docs/04 §4.5}. Resolves the target {@code roomKey}, has
 * {@link RoomService} stamp + create-if-missing the SFS room, joins the
 * user, and replies with the {@code room:{map, doorKey}} envelope so the
 * client's {@code roomModel.checkMap} path runs the same as a fresh
 * {@code init}.
 *
 * <p>No role check yet — Wave 11 will gate this on {@code MASTER}/{@code MOD}.
 */
public final class TeleportHandler extends HandlerBase {

    private final PlaceCatalog places;
    private final RoomService rooms;
    private final AvatarService avatars;

    public TeleportHandler(PlaceCatalog places, RoomService rooms, AvatarService avatars) {
        this.places  = places;
        this.rooms   = rooms;
        this.avatars = avatars;
    }

    @Override
    protected String command() { return "teleport"; }

    @Override
    protected ISFSObject handle(User user, ISFSObject params) throws SFSException {
        String roomKey = SfsObjectMapper.reqStr(params, "roomKey");
        String doorKey = params.containsKey("doorKey") ? params.getUtfString("doorKey") : null;
        Place target = places.findByKey(roomKey).orElseThrow(() ->
            new BadRequestException(ServiceErrorCode.INVALID_REQUEST,
                "unknown roomKey: " + roomKey));

        long avatarId = UserSession.avatarId(user).orElseThrow(() ->
            new BadRequestException(ServiceErrorCode.AVATAR_NOT_FOUND, "no avatar bound to session"));
        Avatar avatar = avatars.requireById(avatarId);

        rooms.joinByKey(user, roomKey, avatar, doorKey);
        AuditLog.info("room.teleport", avatarId, "to=" + roomKey
            + (doorKey != null ? " door=" + doorKey : ""));

        String replyDoorKey = doorKey != null && !doorKey.isBlank()
            ? doorKey : target.defaultDoorKey();
        return new ResponseBuilder()
            .putObj("room",     com.hara.protocol.wire.WireBlocks.room(target, replyDoorKey))
            .putObj("universe", com.hara.protocol.wire.WireBlocks.universe())
            .build();
    }
}
