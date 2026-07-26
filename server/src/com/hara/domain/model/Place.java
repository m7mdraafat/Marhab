package com.hara.domain.model;

import com.hara.domain.enums.RoomTypeName;
import java.util.Collections;
import java.util.List;
import java.util.Objects;

/**
 * Static catalog entry for a logical room key (e.g. {@code street01}). The
 * server stamps this onto the SFS Room at create-time:
 * <ul>
 *   <li>{@code canvasWidth/canvasHeight} → {@code width}/{@code height} RoomVariables (pixels)</li>
 *   <li>{@code grid} → base64-encoded {@code grid} RoomVariable</li>
 *   <li>{@code mapXml} → base64-encoded {@code room.map} field in the init reply</li>
 *   <li>{@code doors} → {@code doors} RoomVariable (JSON-encoded)</li>
 *   <li>{@code spawn*} → user's {@code position} + {@code direction} UserVariables on join</li>
 * </ul>
 * See {@code docs/04 §4.11} for the full set of required RoomVariables.
 */
public final class Place {
    private final String key;
    private final String roomType;     // RoomTypeName.OUTDOOR/INDOOR/BUSINESS
    private final String title;
    private final String defaultSource; // matches vf catalog (e.g. "rooms/st01")
    private final RoomGrid grid;
    private final int canvasWidth;     // room SWF pixel width  (e.g. 800 for st01)
    private final int canvasHeight;    // room SWF pixel height (e.g. 515 for st01)
    private final int xOrigin;          // iso projection origin X (screen px)
    private final int yOrigin;          // iso projection origin Y (screen px)
    private final String mapXml;        // raw XML — handlers base64-encode at send time
    private final List<DoorDef> doors;
    private final int spawnX;
    private final int spawnY;
    private final int spawnDir;

    public Place(String key, String roomType, String title, String defaultSource,
                 RoomGrid grid, int canvasWidth, int canvasHeight,
                 int xOrigin, int yOrigin,
                 String mapXml, List<DoorDef> doors,
                 int spawnX, int spawnY, int spawnDir) {
        this.key = Objects.requireNonNull(key, "key");
        this.roomType = Objects.requireNonNull(roomType, "roomType");
        this.title = title == null ? key : title;
        this.defaultSource = defaultSource;
        this.grid = Objects.requireNonNull(grid, "grid");
        this.canvasWidth  = canvasWidth;
        this.canvasHeight = canvasHeight;
        this.xOrigin = xOrigin;
        this.yOrigin = yOrigin;
        this.mapXml = mapXml == null ? defaultMapXml(xOrigin, yOrigin) : mapXml;
        this.doors = doors == null ? List.of() : List.copyOf(doors);
        this.spawnX = spawnX;
        this.spawnY = spawnY;
        this.spawnDir = spawnDir;
    }

    public String key() { return key; }
    public String roomType() { return roomType; }
    public String title() { return title; }
    public String defaultSource() { return defaultSource; }
    public RoomGrid grid() { return grid; }
    /** Room SWF pixel width. Fed into the {@code width} RoomVariable that
     *  {@code ScaleModel.updateSceneContainer} multiplies by currentScale
     *  to size the playgame canvas. Sending grid columns (e.g. 60) instead
     *  collapses the canvas to a tiny mask and the room renders cropped. */
    public int canvasWidth()  { return canvasWidth; }
    /** Room SWF pixel height. See {@link #canvasWidth()}. */
    public int canvasHeight() { return canvasHeight; }
    public int xOrigin() { return xOrigin; }
    public int yOrigin() { return yOrigin; }
    public String mapXml() { return mapXml; }
    public List<DoorDef> doors() { return Collections.unmodifiableList(doors); }
    public int spawnX() { return spawnX; }
    public int spawnY() { return spawnY; }
    public int spawnDir() { return spawnDir; }

    public boolean isOutdoor() { return RoomTypeName.OUTDOOR.equals(roomType); }

    /**
     * Door key the {@code init} reply advertises as the entry point. Uses
     * the first declared door, or the conventional {@code d1} placeholder
     * if the room has none yet (single-room test scenes).
     */
    public String defaultDoorKey() {
        return doors.isEmpty() ? "d1" : doors.get(0).key();
    }

    /**
     * Minimal valid map XML with the room-specific origins. Used when the
     * caller doesn't provide a hand-authored XML body. Until obstacle
     * entries (buildings, fountains, etc.) are hand-authored per room,
     * every grid cell is walkable.
     */
    private static String defaultMapXml(int xOrigin, int yOrigin) {
        return "<map xOrigin=\"" + xOrigin + "\" yOrigin=\"" + yOrigin + "\"/>";
    }
}
