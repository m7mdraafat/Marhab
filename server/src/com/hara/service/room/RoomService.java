package com.hara.service.room;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

import com.hara.domain.auth.RoleBitset;
import com.hara.domain.enums.CharacterState;
import com.hara.domain.enums.RoomTypeName;
import com.hara.domain.model.Avatar;
import com.hara.domain.model.DoorDef;
import com.hara.domain.model.Place;
import com.hara.service.catalog.PlaceCatalog;
import com.hara.service.catalog.WireCodecs;
import com.smartfoxserver.v2.api.CreateRoomSettings;
import com.smartfoxserver.v2.entities.Room;
import com.smartfoxserver.v2.entities.User;
import com.smartfoxserver.v2.entities.Zone;
import com.smartfoxserver.v2.entities.variables.RoomVariable;
import com.smartfoxserver.v2.entities.variables.SFSRoomVariable;
import com.smartfoxserver.v2.entities.variables.SFSUserVariable;
import com.smartfoxserver.v2.entities.variables.UserVariable;
import com.smartfoxserver.v2.exceptions.SFSException;
import com.smartfoxserver.v2.extensions.SFSExtension;

/**
 * Owns the "join the user to a logical room" flow:
 * <ol>
 *   <li>Look up the {@link Place} in {@link PlaceCatalog}.</li>
 *   <li>Find or create the public SFS {@link Room} keyed by {@code roomKey}.</li>
 *   <li>Stamp all required RoomVariables ({@link VariableNames#RV_*}) atomically
 *       <strong>before</strong> joining the user, so {@code RoomController.startload}
 *       sees a fully-populated room on the first read.</li>
 *   <li>Stamp the user's spawn UserVariables ({@code position}, {@code direction},
 *       {@code status}, etc.) before the SFS auto-broadcast fires.</li>
 *   <li>Move the user into the SFS room.</li>
 * </ol>
 */
public final class RoomService {

    /** Public, game-owned rooms live in this group so SFS doesn't trim them. */
    public static final String STREET_GROUP = "street";
    /** Default room capacity for public rooms. Tune per place type later. */
    public static final int    DEFAULT_CAPACITY = 100;

    private final SFSExtension extension;
    private final PlaceCatalog places;

    public RoomService(SFSExtension extension, PlaceCatalog places) {
        this.extension = Objects.requireNonNull(extension);
        this.places    = Objects.requireNonNull(places);
    }

    /**
     * Move {@code user} into the room keyed by {@code roomKey}. Creates the
     * SFS {@link Room} on first reference. Returns the joined room.
     */
    public Room joinByKey(User user, String roomKey, Avatar avatar) throws SFSException {
        return joinByKey(user, roomKey, avatar, null);
    }

    /**
     * Move {@code user} into a room and spawn them at {@code enterDoorKey}'s
     * landing tile (instead of the place's default spawn). If
     * {@code enterDoorKey} is null/blank or no matching door exists, falls
     * back to the place's default spawn. Returns the joined room.
     */
    public Room joinByKey(User user, String roomKey, Avatar avatar, String enterDoorKey)
            throws SFSException {
        Place place = places.require(roomKey);
        Room room = findOrCreate(place);
        DoorDef enter = resolveEnterDoor(place, enterDoorKey);
        stampUserSpawn(user, place, avatar, enter);
        extension.getApi().joinRoom(user, room, "", false, user.getLastJoinedRoom());
        return room;
    }

    private static DoorDef resolveEnterDoor(Place place, String enterDoorKey) {
        if (enterDoorKey == null || enterDoorKey.isBlank()) return null;
        for (DoorDef d : place.doors()) {
            if (enterDoorKey.equals(d.key())) return d;
        }
        return null;
    }

    /** Find the SFS room by {@code roomKey} group/name, or create + stamp it. */
    public Room findOrCreate(Place place) throws SFSException {
        Zone zone = extension.getParentZone();
        Room existing = zone.getRoomByName(place.key());
        if (existing != null) return existing;

        CreateRoomSettings settings = new CreateRoomSettings();
        settings.setName(place.key());
        settings.setGroupId(STREET_GROUP);
        settings.setMaxUsers(DEFAULT_CAPACITY);
        // SFS rooms default to maxVariables=5; we stamp ~10 (roomKey, type,
        // title, width, height, grid, doors, bots, extensions, source).
        // Anything past the cap is silently discarded with a WARN, breaking
        // room load on the client. Raise the cap to a comfortable ceiling.
        settings.setMaxVariablesAllowed(32);
        settings.setGame(false);
        settings.setHidden(false);
        settings.setRoomVariables(buildRoomVariables(place));

        Room room = extension.getApi().createRoom(zone, settings, null);
        return room;
    }

    private List<RoomVariable> buildRoomVariables(Place place) {
        List<RoomVariable> out = new ArrayList<>();
        out.add(strVar(VariableNames.RV_ROOM_KEY,   place.key()));
        out.add(strVar(VariableNames.RV_TYPE,       place.roomType()));
        out.add(strVar(VariableNames.RV_ROOM_TITLE, place.title()));
        // PIXEL dimensions of the room SWF, NOT grid columns/rows. Read by
        // ScaleModel.updateSceneContainer to size the playgame canvas. The
        // grid (column/row count) is encoded separately inside RV_GRID.
        out.add(intVar(VariableNames.RV_WIDTH,      place.canvasWidth()));
        out.add(intVar(VariableNames.RV_HEIGHT,     place.canvasHeight()));
        out.add(intVar(VariableNames.RV_X_ORIGIN,   place.xOrigin()));
        out.add(intVar(VariableNames.RV_Y_ORIGIN,   place.yOrigin()));
        out.add(strVar(VariableNames.RV_GRID,       WireCodecs.encodeGrid(place.grid())));
        String doorsJson = WireCodecs.encodeDoorsJson(place.doors());
        out.add(strVar(VariableNames.RV_DOORS, doorsJson));
        extension.getLogger().info("[hara.room] " + place.key() + " doors=" + place.doors().size()
            + " grid=" + place.grid().width() + "x" + place.grid().height()
            + " spawn=(" + place.spawnX() + "," + place.spawnY() + ") doorsJson=" + doorsJson);
        // Bots: prefer captured production JSON when available, else empty array.
        String botsJson = com.hara.service.catalog.CapturedRoomData.loadBotsJson(
            places.wwwRoot(), place.key());
        out.add(strVar(VariableNames.RV_BOTS,       botsJson));
        out.add(strVar(VariableNames.RV_EXTENSIONS, "[]"));
        if (place.defaultSource() != null) {
            out.add(strVar(VariableNames.RV_SOURCE, place.defaultSource()));
        }
        // Outdoor public rooms have no owner; ownerID/flatID intentionally absent.
        if (!RoomTypeName.OUTDOOR.equals(place.roomType())) {
            // placeholder — flats / user-owned rooms will inject ownerID/flatID here
        }
        return out;
    }

    /** Stamp the user's spawn before SFS joins them so the broadcast is correct. */
    public void stampUserSpawn(User user, Place place, Avatar avatar) {
        stampUserSpawn(user, place, avatar, null);
    }

    /**
     * Stamp spawn UserVariables. When {@code enterDoor} is non-null, spawn
     * at that door's {@code targetX/Y/Dir} (matches the convention that
     * door {@code d1} of room A points at door {@code d1} of the room you
     * arrive in). Otherwise use the place's default spawn.
     */
    public void stampUserSpawn(User user, Place place, Avatar avatar, DoorDef enterDoor) {
        int spawnX   = enterDoor != null ? enterDoor.targetX()   : place.spawnX();
        int spawnY   = enterDoor != null ? enterDoor.targetY()   : place.spawnY();
        int spawnDir = enterDoor != null ? enterDoor.targetDir() : place.spawnDir();
        List<UserVariable> uvs = new ArrayList<>();
        uvs.add(strUv(VariableNames.UV_POSITION,    spawnX + "," + spawnY));
        uvs.add(intUv(VariableNames.UV_DIRECTION,   spawnDir));
        uvs.add(dblUv(VariableNames.UV_SPEED,       1.0));
        uvs.add(strUv(VariableNames.UV_STATUS,      CharacterState.IDLE));
        uvs.add(strUv(VariableNames.UV_AVATAR_NAME, avatar.name()));
        uvs.add(strUv(VariableNames.UV_GENDER,      avatar.gender()));
        uvs.add(dblUv(VariableNames.UV_AVATAR_SIZE, 1.0));
        uvs.add(strUv(VariableNames.UV_SMILEY,      ""));
        uvs.add(strUv(VariableNames.UV_HAND,        ""));
        uvs.add(strUv(VariableNames.UV_CLOTHES,     UserVariablePayloads.clothesJson(avatar.clothes())));
        // Local-dev grant: unlock all known cards/admin/VIP UI through the
        // normal client permission path. Server-side validation must still be
        // enforced for any real economy/admin action.
        uvs.add(strUv(VariableNames.UV_ROLES,       RoleBitset.allKnown()));
        try {
            extension.getApi().setUserVariables(user, uvs);
        } catch (Exception e) {
            extension.getLogger().warn("[room] failed to stamp UserVariables for "
                + user.getName() + ": " + e.getMessage());
        }
    }

    // ---- small typed factories ----
    private static RoomVariable strVar(String k, String v) { return new SFSRoomVariable(k, v); }
    private static RoomVariable intVar(String k, int v)    { return new SFSRoomVariable(k, v); }

    private static UserVariable strUv(String k, String v)  { return new SFSUserVariable(k, v); }
    private static UserVariable intUv(String k, int v)     { return new SFSUserVariable(k, v); }
    private static UserVariable dblUv(String k, double v)  { return new SFSUserVariable(k, v); }
}
