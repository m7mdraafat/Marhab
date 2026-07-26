package com.hara.protocol.handlers.room;

import com.hara.domain.model.Avatar;
import com.hara.domain.model.DoorDef;
import com.hara.domain.model.Place;
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
import com.hara.service.room.VariableNames;
import com.smartfoxserver.v2.entities.Room;
import com.smartfoxserver.v2.entities.User;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSObject;
import com.smartfoxserver.v2.exceptions.SFSException;

/**
 * Passage transition for non-ceiling door properties. Ceiling door clips use
 * {@code TeleportProperty} in our current catalog, but older/inline map
 * entries still send {@code usedoor}. The response shape matches
 * {@code RoomController.onUseDoor}: {@code { room:{ map, doorKey } }}.
 */
public final class UseDoorHandler extends HandlerBase {

    private final PlaceCatalog places;
    private final RoomService rooms;
    private final AvatarService avatars;

    public UseDoorHandler(PlaceCatalog places, RoomService rooms, AvatarService avatars) {
        this.places = places;
        this.rooms = rooms;
        this.avatars = avatars;
    }

    @Override
    protected String command() { return "usedoor"; }

    @Override
    protected ISFSObject handle(User user, ISFSObject params) throws SFSException {
        String key = SfsObjectMapper.reqStr(params, "key");
        Room current = user.getLastJoinedRoom();
        if (current == null || current.getVariable(VariableNames.RV_ROOM_KEY) == null) {
            throw new BadRequestException(ServiceErrorCode.INVALID_REQUEST, "user not in a room");
        }

        String currentKey = current.getVariable(VariableNames.RV_ROOM_KEY).getStringValue();
        Place currentPlace = places.findByKey(currentKey).orElseThrow(() ->
            new BadRequestException(ServiceErrorCode.INVALID_REQUEST, "unknown room: " + currentKey));
        DoorDef door = findDoor(currentPlace, key);
        Object targetRoom = door.propertyData().get("roomKey");
        if (targetRoom == null || String.valueOf(targetRoom).isBlank()) {
            throw new BadRequestException(ServiceErrorCode.INVALID_REQUEST, "door has no target room: " + key);
        }

        Place target = places.findByKey(String.valueOf(targetRoom)).orElseThrow(() ->
            new BadRequestException(ServiceErrorCode.INVALID_REQUEST, "unknown target room: " + targetRoom));
        long avatarId = UserSession.avatarId(user).orElseThrow(() ->
            new BadRequestException(ServiceErrorCode.AVATAR_NOT_FOUND, "no avatar bound to session"));
        Avatar avatar = avatars.requireById(avatarId);

        // Spawn at the destination door. Convention: explicit `destDoorKey`
        // in propertyData wins; otherwise mirror the source key (so leaving
        // street01 via d2 lands at street02's d2).
        Object explicitDest = door.propertyData().get("destDoorKey");
        String destDoorKey = explicitDest != null && !String.valueOf(explicitDest).isBlank()
            ? String.valueOf(explicitDest) : door.key();
        rooms.joinByKey(user, target.key(), avatar, destDoorKey);

        return new ResponseBuilder()
            .putObj("room",     com.hara.protocol.wire.WireBlocks.room(target, destDoorKey))
            .putObj("universe", com.hara.protocol.wire.WireBlocks.universe())
            .build();
    }

    private static DoorDef findDoor(Place place, String key) {
        for (DoorDef door : place.doors()) {
            if (door.key().equals(key)) return door;
        }
        throw new BadRequestException(ServiceErrorCode.INVALID_REQUEST, "unknown door: " + key);
    }
}
