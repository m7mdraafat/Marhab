package com.hara.protocol.handlers.walk;

import java.util.List;

import com.hara.domain.enums.CharacterState;
import com.hara.domain.model.Place;
import com.hara.domain.model.Position;
import com.hara.domain.model.WalkSession;
import com.hara.protocol.framework.BadRequestException;
import com.hara.protocol.framework.HandlerBase;
import com.hara.protocol.framework.ResponseBuilder;
import com.hara.protocol.framework.ServiceErrorCode;
import com.hara.protocol.framework.SfsObjectMapper;
import com.hara.service.catalog.PlaceCatalog;
import com.hara.service.room.VariableNames;
import com.hara.service.walk.WalkSessionRegistry;
import com.hara.service.walk.WalkValidator;
import com.smartfoxserver.v2.SmartFoxServer;
import com.smartfoxserver.v2.entities.Room;
import com.smartfoxserver.v2.entities.User;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.variables.SFSUserVariable;
import com.smartfoxserver.v2.entities.variables.UserVariable;

/**
 * Start of a walk. Per {@code docs/04 §4.9}: validate target against the
 * server's authoritative grid, compute a delay that matches the client's
 * local walk timer, register a {@link WalkSession}, and send back
 * {@code { delay:<ms> }} so {@code WalkModel.onWalkStart} can arm the
 * commit timer.
 *
 * <p>Failure mode for invalid targets: silently drop (no reply). The client
 * locally pathfinds and "snaps" via {@code reLocate} on its own, so the
 * server can simply refuse to commit. Sending an error envelope would
 * confuse the WalkModel listener since it's registered as a one-way push.
 */
public final class WalkRequestHandler extends HandlerBase {

    private final PlaceCatalog places;
    private final WalkSessionRegistry sessions;

    public WalkRequestHandler(PlaceCatalog places, WalkSessionRegistry sessions) {
        this.places = places;
        this.sessions = sessions;
    }

    @Override
    protected String command() { return "walkrequest"; }

    @Override
    protected ISFSObject handle(User user, ISFSObject params) {
        Room room = user.getLastJoinedRoom();
        if (room == null) {
            throw new BadRequestException(ServiceErrorCode.INVALID_REQUEST, "user not in a room");
        }
        String roomKey = room.getVariable(VariableNames.RV_ROOM_KEY).getStringValue();
        Place place = places.findByKey(roomKey).orElseThrow(() ->
            new BadRequestException(ServiceErrorCode.INVALID_REQUEST, "unknown room: " + roomKey));

        int targetX = SfsObjectMapper.reqInt(params, "x");
        int targetY = SfsObjectMapper.reqInt(params, "y");
        boolean door = SfsObjectMapper.optBool(params, "door", false);

        Position current = readCurrentPosition(user);
        double speed = readSpeed(user);
        var result = WalkValidator.validate(place, current.x(), current.y(), targetX, targetY, speed);

        if (result.outcome != WalkValidator.Outcome.OK) {
            // Production returns a structured error envelope (verified via sniff).
            // The client's WalkModel sees status="error" and snaps back instead
            // of replaying the local prediction.
            return new ResponseBuilder()
                .putStr("status",  "error")
                .putStr("message", result.outcome == WalkValidator.Outcome.OUT_OF_BOUNDS
                    ? "The target position is out of bounds."
                    : "The target position is not walkable.")
                .build();
        }

        long now = System.currentTimeMillis();
        long expires = now + result.delayMs + 250; // 250ms grace before timeout
        Position target = new Position(targetX, targetY, current.direction());
        sessions.open(new WalkSession(user.getId(), room.getId(),
            target.x(), target.y(), target.direction(), door, now, expires));

        // Broadcast walk-in-progress to everyone in the room so other clients
        // animate this avatar walking instead of teleporting on arrival.
        // Cleared by WalkFinalRequestHandler when the walk commits.
        List<UserVariable> uvs = List.of(
            new SFSUserVariable(VariableNames.UV_TARGET, targetX + "," + targetY),
            new SFSUserVariable(VariableNames.UV_STATUS, CharacterState.WALK)
        );
        SmartFoxServer.getInstance().getAPIManager().getSFSApi().setUserVariables(user, uvs);

        ResponseBuilder rb = new ResponseBuilder().putLong("delay", result.delayMs);
        if (door) {
            // Door walks: client expects `isDoor` + door tile coords so the
            // SceneDoorComponent overlay can highlight the destination cell.
            rb.putBool("isDoor", true)
              .putInt("doorX",  targetX)
              .putInt("doorY",  targetY);
        }
        return rb.build();
    }

    // -----------------------------------------------------------------------

    private static Position readCurrentPosition(User user) {
        UserVariable posVar = user.getVariable(VariableNames.UV_POSITION);
        UserVariable dirVar = user.getVariable(VariableNames.UV_DIRECTION);
        int x = 0, y = 0, dir = 4;
        if (posVar != null && posVar.getStringValue() != null) {
            String[] parts = posVar.getStringValue().split(",");
            if (parts.length == 2) {
                try { x = Integer.parseInt(parts[0].trim()); } catch (Exception ignored) {}
                try { y = Integer.parseInt(parts[1].trim()); } catch (Exception ignored) {}
            }
        }
        if (dirVar != null) {
            try { dir = dirVar.getIntValue(); } catch (Exception ignored) {}
        }
        return new Position(x, y, dir);
    }

    private static double readSpeed(User user) {
        UserVariable v = user.getVariable(VariableNames.UV_SPEED);
        if (v == null) return 1.0;
        try { return v.getDoubleValue(); } catch (Exception e) { return 1.0; }
    }
}
