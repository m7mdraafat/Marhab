package com.hara.service;

import com.smartfoxserver.v2.api.CreateRoomSettings;
import com.smartfoxserver.v2.entities.Room;
import com.smartfoxserver.v2.entities.User;
import com.smartfoxserver.v2.entities.Zone;
import com.smartfoxserver.v2.entities.variables.RoomVariable;
import com.smartfoxserver.v2.entities.variables.SFSRoomVariable;
import com.smartfoxserver.v2.entities.variables.SFSUserVariable;
import com.smartfoxserver.v2.entities.variables.UserVariable;
import com.smartfoxserver.v2.extensions.SFSExtension;

import java.util.ArrayList;
import java.util.List;

/**
 * Owns everything related to SFS Rooms in Hara: creation, seeding the
 * RoomVariables/UserVariables the client needs, and joining users.
 *
 * Handlers never touch the SFS room API directly -- they go through here.
 * That makes it the single place we enforce: required variables present,
 * correct types, valid names (zone.xml caps room names at 10 chars), and
 * the correct ordering ("seed UserVariables BEFORE joinRoom").
 *
 * This is the only Service class that imports SFS APIs; the rest of the
 * service layer is pure business logic. Intentional split: this is the SFS
 * adapter, everything else is testable without SmartFox.
 */
public final class RoomService {

    /** Stable name for the auto-created lobby; clients join here on first init. */
    public static final String DEFAULT_LOBBY = "lobby";

    private RoomService() {}

    /**
     * Idempotently create the default lobby AND seed the RoomVariables that
     * RoomController.startload() reads on join. Missing any required
     * RoomVariable NPEs silently in the client; the splash stalls at INIT_READY.
     *
     * Required: roomKey, width, height.
     * Optional but consumed: source, bots, doors, ownerID, ownerName,
     *   roomTitle, flatID, roomID, grid, extensions.
     */
    public static synchronized void ensureDefaultLobby(SFSExtension ext, Zone zone) {
        try {
            Room existing = zone.getRoomByName(DEFAULT_LOBBY);
            if (existing != null) return;
            CreateRoomSettings settings = new CreateRoomSettings();
            settings.setName(DEFAULT_LOBBY);
            settings.setGroupId("default");
            settings.setGame(false);
            settings.setMaxUsers(100);
            settings.setMaxSpectators(0);
            settings.setDynamic(false);
            settings.setHidden(false);

            List<RoomVariable> vars = new ArrayList<>();
            // TODO Phase 5: switch roomKey to "street01" once the room SWF
            // pipeline + base64 grid binary are wired. Keeping a placeholder
            // lobby so the boot chain has *something* to join during dev.
            vars.add(new SFSRoomVariable("roomKey",   "lobby"));
            vars.add(new SFSRoomVariable("width",     20));
            vars.add(new SFSRoomVariable("height",    20));
            vars.add(new SFSRoomVariable("roomID",    1));
            vars.add(new SFSRoomVariable("roomTitle", "Lobby"));
            // CSV is a placeholder; the real client expects base64 of
            // [int32 w][int32 h][w*h bytes]. Authored grids land in Phase 5.
            vars.add(new SFSRoomVariable("grid",      buildOpenGrid(20, 20)));
            settings.setRoomVariables(vars);

            ext.getApi().createRoom(zone, settings, null);
            ext.trace("RoomService.ensureDefaultLobby: created '" + DEFAULT_LOBBY + "' (placeholder grid)");
        } catch (Exception e) {
            ext.trace("RoomService.ensureDefaultLobby FAILED: "
                + e.getClass().getSimpleName() + ": " + e.getMessage());
        }
    }

    /**
     * Seed the UserVariables read by RoomController.startload() right after
     * roomJoin. Missing any of these NPEs the client.
     *
     * Required reads: clothes (JSON array string), gender ("m"|"f"),
     *                 position ("x,y" string), direction (int 0..7).
     * Idempotent.
     */
    public static void seedUserVariables(SFSExtension ext, User user) {
        try {
            UserStateRegistry.UserState st = UserStateRegistry.forUser(user);
            String clothesJson =
                "[{\"clip\":\"C\",\"color\":1},"
              + "{\"clip\":\"B\",\"color\":1},"
              + "{\"clip\":\"A\",\"color\":1}]";
            List<UserVariable> vars = new ArrayList<>();
            vars.add(new SFSUserVariable("clothes",   clothesJson));
            vars.add(new SFSUserVariable("gender",    st.gender != null ? st.gender : "m"));
            vars.add(new SFSUserVariable("position",  "10,10"));
            vars.add(new SFSUserVariable("direction", 4));
            ext.getApi().setUserVariables(user, vars);
            ext.trace("RoomService.seedUserVariables: " + user.getName()
                + " gender=" + st.gender + " position=10,10");
        } catch (Exception e) {
            ext.trace("RoomService.seedUserVariables FAILED for " + user.getName()
                + ": " + e.getMessage());
        }
    }

    /**
     * Seed user vars + join the user to the default lobby.
     *
     * MUST be called AFTER InitHandler has replied, NOT from USER_JOIN_ZONE.
     * The client's RoomController only registers its `roomJoin` listener
     * inside Sanalika.initCommandsCompleted, which runs after init replies.
     * Joining earlier delivers the event to nobody and the splash stalls.
     */
    public static void autoJoinDefaultLobby(SFSExtension ext, User user) {
        try {
            Zone zone = user.getZone();
            ensureDefaultLobby(ext, zone);
            Room lobby = zone.getRoomByName(DEFAULT_LOBBY);
            if (lobby == null) {
                ext.trace("RoomService.autoJoin: '" + DEFAULT_LOBBY
                    + "' could not be created/found in zone '" + zone.getName() + "'");
                return;
            }
            seedUserVariables(ext, user);
            ext.getApi().joinRoom(user, lobby);
            ext.trace("RoomService.autoJoin: " + user.getName() + " -> '" + lobby.getName()
                + "' (occupants=" + lobby.getSize().getUserCount() + ")");
        } catch (Exception e) {
            ext.trace("RoomService.autoJoin FAILED for " + user.getName()
                + ": " + e.getMessage());
        }
    }

    /** Build a CSV grid of all-walkable cells (placeholder format). */
    private static String buildOpenGrid(int w, int h) {
        StringBuilder sb = new StringBuilder(w * h * 2);
        for (int y = 0; y < h; y++) {
            for (int x = 0; x < w; x++) {
                if (x > 0) sb.append(',');
                sb.append('1');
            }
            sb.append('\n');
        }
        return sb.toString();
    }
}
