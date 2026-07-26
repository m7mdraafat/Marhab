package com.hara.protocol.handlers.walk;

import java.util.List;
import java.util.Map;
import java.util.Optional;

import com.hara.domain.enums.CharacterState;
import com.hara.domain.enums.Direction;
import com.hara.domain.model.Avatar;
import com.hara.domain.model.DoorDef;
import com.hara.domain.model.Place;
import com.hara.domain.model.WalkSession;
import com.hara.protocol.framework.HandlerBase;
import com.hara.protocol.framework.ResponseBuilder;
import com.hara.protocol.wire.ServerEnvelope;
import com.hara.protocol.wire.WireBlocks;
import com.hara.service.auth.UserSession;
import com.hara.service.avatar.AvatarService;
import com.hara.service.catalog.PlaceCatalog;
import com.hara.service.room.RoomService;
import com.hara.service.room.VariableNames;
import com.hara.service.walk.WalkSessionRegistry;
import com.smartfoxserver.v2.entities.Room;
import com.smartfoxserver.v2.entities.User;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.variables.SFSUserVariable;
import com.smartfoxserver.v2.entities.variables.UserVariable;
import com.smartfoxserver.v2.extensions.SFSExtension;

/**
 * Commit phase of a walk. Looks up the open {@link WalkSession}, validates
 * it hasn't expired, then publishes the new {@code position} + {@code direction}
 * + {@code status} UserVariables. SFS auto-broadcasts the change to every
 * other user in the room.
 */
public final class WalkFinalRequestHandler extends HandlerBase {

    private final SFSExtension extension;
    private final WalkSessionRegistry sessions;
    private final PlaceCatalog places;
    private final RoomService rooms;
    private final AvatarService avatars;

    public WalkFinalRequestHandler(SFSExtension extension, WalkSessionRegistry sessions,
                                             PlaceCatalog places, RoomService rooms, AvatarService avatars) {
        this.extension = extension;
        this.sessions = sessions;
        this.places = places;
        this.rooms = rooms;
        this.avatars = avatars;
    }

    @Override
    protected String command() { return "walkfinalrequest"; }

    @Override
    protected ISFSObject handle(User user, ISFSObject params) throws Exception {
        Optional<WalkSession> taken = sessions.take(user.getId());
        if (taken.isEmpty()) return null; // no open walk to commit — silent drop
        WalkSession s = taken.get();
        if (s.isExpired(System.currentTimeMillis())) return null;

        List<UserVariable> uvs = List.of(
            new SFSUserVariable(VariableNames.UV_POSITION,  s.targetX() + "," + s.targetY()),
            new SFSUserVariable(VariableNames.UV_DIRECTION, validatedDir(s.direction())),
            new SFSUserVariable(VariableNames.UV_STATUS,    CharacterState.IDLE),
            // Clear the in-progress target now that the avatar arrived.
            // Sending null/empty triggers SFS to remove the variable on clients.
            new SFSUserVariable(VariableNames.UV_TARGET,    "")
        );
        extension.getApi().setUserVariables(user, uvs);

        // In the production client the local Character usually calls usedoor
        // after finishing a door walk. In our local build that call can be
        // swallowed when the server position commit races the local animation.
        // Treat a committed door walk as authoritative and push the same
        // `usedoor` payload the client would have requested. RoomController
        // listens for unsolicited `usedoor` extension messages, so this cleanly
        // triggers roomModel.checkMap() + engine.changeScene().
        if (s.door()) {
            pushDoorTransition(user, s.targetX(), s.targetY());
        }

        // Production replies with {rid, nextRequest:100} so the client can
        // queue the next walkrequest after the rate-limit window.
        return ServerEnvelope.stamp(new ResponseBuilder(), ServerEnvelope.NEXT_FAST).build();
    }

    private void pushDoorTransition(User user, int tileX, int tileY) throws Exception {
        Room current = user.getLastJoinedRoom();
        if (current == null || current.getVariable(VariableNames.RV_ROOM_KEY) == null) return;

        String currentKey = current.getVariable(VariableNames.RV_ROOM_KEY).getStringValue();
        Place currentPlace = places.findByKey(currentKey).orElse(null);
        if (currentPlace == null) return;

        DoorDef door = null;
        for (DoorDef candidate : currentPlace.doors()) {
            if (candidate.targetX() == tileX && candidate.targetY() == tileY) {
                door = candidate;
                break;
            }
        }
        if (door == null) return;

        Map<String, Object> property = door.propertyData();
        Object targetRoomKey = property.get("roomKey");
        if (targetRoomKey == null || String.valueOf(targetRoomKey).isBlank()) return;

        String destRoomKey = String.valueOf(targetRoomKey);
        String destDoorKey = property.get("destDoorKey") == null
            ? door.key()
            : String.valueOf(property.get("destDoorKey"));
        Place target = places.findByKey(destRoomKey).orElse(null);
        if (target == null) return;

        long avatarId = UserSession.avatarId(user).orElse(0L);
        Avatar avatar = avatars.requireById(avatarId);
        rooms.joinByKey(user, target.key(), avatar, destDoorKey);

        ISFSObject payload = new ResponseBuilder()
            .putObj("room", WireBlocks.room(target, destDoorKey))
            .putObj("universe", WireBlocks.universe())
            .build();
        extension.send("usedoor", payload, user);
    }

    private static int validatedDir(int dir) {
        return Direction.isValid(dir) ? dir : Direction.SOUTH;
    }
}
