package com.hara.service.catalog;

import com.hara.domain.enums.Direction;
import com.hara.domain.enums.RoomTypeName;
import com.hara.domain.model.DoorDef;
import com.hara.domain.model.Place;
import com.hara.domain.model.RoomGrid;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Base64;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;

/**
 * Logical-room-key → {@link Place} lookup. Every key registered here must
 * also exist in the active {@code vf.*} catalog, because the client loads the
 * main room SWF by {@code roomModel.key}, not by the {@code source}
 * RoomVariable. The active catalog is loaded from the served CDN root at
 * startup, then enriched with hand-authored metadata for rooms we know how to
 * calibrate today.
 *
 * <p>Per memory note: {@code street01} → {@code st01.swf} (day); calibrated
 * canvas 800×515 with xOrigin=200, yOrigin=350; spawn (5,5) lands at scene
 * (200, 287) on visible road. {@code testStreet} is kept as an admin
 * teleport target (matches {@code Sanalika.testStreet()}).
 */
public final class PlaceCatalog {

    /** Default grid dimensions for first-cut rooms — generous and all-walkable. */
    private static final int DEFAULT_W = 60;
    private static final int DEFAULT_H = 40;

    /** Native pixel dimensions of {@code st01.swf} — verified via FFDec
     *  frameSize=16000×10300 twips → 800×515 px. The {@code width}/{@code height}
     *  RoomVariables MUST be pixel dimensions, not grid counts, otherwise
     *  {@code ScaleModel.updateSceneContainer} sizes the playgame canvas to
     *  60×40 pixels and the room renders cropped (see canvasWidth javadoc on
     *  {@link com.hara.domain.model.Place}). */
    private static final int ST01_CANVAS_W = 800;
    private static final int ST01_CANVAS_H = 515;

    /** Isometric projection calibration for {@code st01.swf}. Empirical:
     *  with yOrigin=500 the avatar's positive grid cells project to screen
     *  Y values within the visible road region (roughly 380–480 px). xOrigin=400
     *  centres the grid on the 800-wide canvas. Need to be re-calibrated
     *  precisely once we have captured map XMLs from the live server. */
    private static final int ST01_X_ORIGIN = 400;
    private static final int ST01_Y_ORIGIN = 500;

    private final Map<String, Place> byKey = new HashMap<>();
    private final String starterKey;
    private final Path wwwRoot;
    private final AllDoorsCsv allDoors;

    public PlaceCatalog(String starterKey) {
        this(starterKey, null, "data/vf.403");
    }

    public PlaceCatalog(String starterKey, Path wwwRoot, String versionFilePath) {
        this.starterKey = Objects.requireNonNull(starterKey, "starterKey");
        this.wwwRoot    = wwwRoot;
        this.allDoors   = AllDoorsCsv.loadOrEmpty(null, wwwRoot);
        loadActiveVersionCatalog(wwwRoot, versionFilePath);
        seedKnownOverrides();
    }

    public Optional<Place> findByKey(String key) {
        if (key == null) return Optional.empty();
        return Optional.ofNullable(byKey.get(key));
    }

    /** Throw if the key is unknown. */
    public Place require(String key) {
        return findByKey(key).orElseThrow(() ->
            new IllegalArgumentException("unknown room key: " + key));
    }

    public Place starter() { return require(starterKey); }

    public String starterKey() { return starterKey; }

    /** Root used to load captured per-room data files; nullable in tests. */
    public Path wwwRoot() { return wwwRoot; }

    /** Register or replace a {@link Place}. Last writer wins. */
    public void put(Place place) { byKey.put(place.key(), place); }

    // -----------------------------------------------------------------------

    private void seedKnownOverrides() {
        put(street01(sourceFor("street01", "rooms/st01"), findByKey("street02").isPresent()));
        if (!byKey.containsKey("testStreet")) {
            put(genericPublicRoom("testStreet", "rooms/testStreet"));
        }
        // Ensure every room that has captured data or SWF-extracted doors
        // is in the catalog even if the vf catalog doesn't list it.
        ensureCapturedRoomsRegistered();
        // After all places exist, prefer any captured live-server data for
        // each one (grid + doors). Captures live under
        // {@code <wwwRoot>/rooms/<roomKey>/}. Missing files = keep the
        // hand-authored defaults above.
        applyCapturedOverrides();
    }

    /**
     * Walk the captured rooms directory and the all-doors CSV; for every
     * roomKey that isn't already registered (because vf.* didn't mention
     * it), inject a generic Place so {@link #applyCapturedOverrides()}
     * has something to upgrade.
     */
    private void ensureCapturedRoomsRegistered() {
        if (wwwRoot == null) return;
        Path rooms = wwwRoot.resolve("rooms");
        try {
            if (Files.isDirectory(rooms)) {
                try (var stream = Files.list(rooms)) {
                    stream.filter(Files::isDirectory).forEach(dir -> {
                        String key = dir.getFileName().toString();
                        if (!byKey.containsKey(key)) {
                            put(genericPublicRoom(key, "rooms/" + key));
                        }
                    });
                }
            }
        } catch (IOException ignored) {}
        // Also walk the all-doors.csv so e.g. street04 (no captured map yet)
        // still gets its real door tile coords on disk.
        for (String key : allDoorsRoomKeys()) {
            if (!byKey.containsKey(key)) put(genericPublicRoom(key, "rooms/" + key));
        }
    }

    private java.util.Set<String> allDoorsRoomKeys() {
        // Probe the CSV's known keys -- expose via a small reflection-free helper
        // by trying each known street + ad-hoc rooms we care about.
        java.util.Set<String> keys = new java.util.HashSet<>();
        for (String k : new String[]{
            "street01","street02","street03","street04","street05","street06",
            "street07","street08","street09","street10"
        }) {
            if (!allDoors.forRoom(k).isEmpty()) keys.add(k);
        }
        return keys;
    }

    /**
     * For every registered place, swap in the captured grid + doors when
     * present on disk. Reuses every other Place field (canvas dims, source,
     * roomType, etc.) so a single capture run upgrades the entire catalog.
     */
    private void applyCapturedOverrides() {
        if (wwwRoot == null) return;
        for (Place p : List.copyOf(byKey.values())) {
            Optional<RoomGrid> grid = CapturedRoomData.loadGrid(wwwRoot, p.key());
            List<DoorDef> capturedDoors = CapturedRoomData.loadDoors(wwwRoot, p.key());
            Optional<String> mapXml = CapturedRoomData.loadMapXml(wwwRoot, p.key());

            // Door resolution priority: captured production JSON → SWF-extracted
            // CSV → whatever was hand-authored on the Place. This guarantees
            // every captured room has real-looking doors even when the live
            // server didn't push the doors RoomVariable into our sniff.
            List<DoorDef> doors = capturedDoors;
            boolean doorsFromCsv = false;
            if (doors.isEmpty()) {
                List<DoorDef> csvDoors = allDoors.forRoom(p.key());
                if (!csvDoors.isEmpty()) {
                    doors = wireKnownPassages(p.key(), csvDoors);
                    doorsFromCsv = true;
                }
            }

            if (grid.isEmpty() && doors.isEmpty() && mapXml.isEmpty()) continue;

            // If we have a captured map XML but no grid, synthesize the grid
            // from the obstacles in the XML (mirrors the client's
            // GridManager.doFixedObjectOperations). This is what makes
            // walking around buildings work without needing the actual
            // server-authored grid bytes.
            RoomGrid effectiveGrid = grid.orElseGet(() ->
                mapXml.map(MapXmlGridSynth::synthesize).orElse(p.grid()));

            // Pull xOrigin / yOrigin from the captured XML only when door
            // coords also came from the same production capture. Mixing a
            // CSV-extracted door (which uses the local SWF's iso projection
            // baseline of 200/590) with captured XML origins from a different
            // server build collapses the avatar to off-screen tiles.
            int xOrigin = p.xOrigin();
            int yOrigin = p.yOrigin();
            if (mapXml.isPresent() && !doorsFromCsv) {
                int[] origins = readOrigins(mapXml.get());
                if (origins[0] > 0) xOrigin = origins[0];
                if (origins[1] > 0) yOrigin = origins[1];
            }

            // Recompute a sane spawn from the captured d1 (or fallback).
            DoorDef spawnDoor = doors.stream()
                .filter(d -> "d1".equals(d.key()))
                .findFirst()
                .orElse(doors.isEmpty() ? null : doors.get(0));
            int spawnX = spawnDoor != null ? spawnDoor.targetX() : p.spawnX();
            int spawnY = spawnDoor != null ? spawnDoor.targetY() : p.spawnY();
            int spawnDir = spawnDoor != null ? spawnDoor.targetDir() : p.spawnDir();

            put(new Place(
                p.key(), p.roomType(), p.title(), p.defaultSource(),
                effectiveGrid,
                p.canvasWidth(), p.canvasHeight(),
                xOrigin, yOrigin,
                mapXml.orElse(p.mapXml()),
                doors.isEmpty() ? p.doors() : doors,
                spawnX, spawnY, spawnDir
            ));
        }
    }

    /**
     * Decorate a bare list of SWF-extracted doors with hard-coded passage
     * targets so cross-street navigation works without captured server
     * door data. Each entry pairs a {@code (roomKey, sourceDoorKey)} with
     * the {@code (destRoomKey, destDoorKey)} the user will land on.
     *
     * <p>Today we only wire street01's doors; expand the table as the user
     * needs more cross-room paths.
     */
    private static List<DoorDef> wireKnownPassages(String roomKey, List<DoorDef> doors) {
        Map<String, String[]> map = PASSAGE_TABLE.get(roomKey);
        if (map == null || map.isEmpty()) return doors;
        List<DoorDef> out = new ArrayList<>(doors.size());
        for (DoorDef d : doors) {
            String[] dest = map.get(d.key());
            if (dest == null) { out.add(d); continue; }
            out.add(new DoorDef(
                d.key(), d.targetX(), d.targetY(), d.targetDir(),
                "PassageProperty",
                Map.of("roomKey", dest[0], "destDoorKey", dest[1])
            ));
        }
        return out;
    }

    /**
     * {@code roomKey -> sourceDoorKey -> [destRoomKey, destDoorKey]}.
     * Hand-curated based on the real Marhab street topology (street01 is
     * the central plaza, neighbouring streets branch off via doors d1-d9).
     */
    private static final Map<String, Map<String, String[]>> PASSAGE_TABLE = Map.of(
        "street01", Map.of(
            "d1",  new String[]{"street03", "d1"},  // east avenue
            "d2",  new String[]{"street02", "d1"},  // west avenue
            "d3",  new String[]{"street04", "d1"},
            "d4",  new String[]{"street05", "d1"},
            "d5",  new String[]{"street10", "d1"},
            "d6",  new String[]{"street06", "d1"},
            "d7",  new String[]{"street07", "d1"},
            "d8",  new String[]{"street08", "d1"},
            "d9",  new String[]{"street09", "d1"}
        )
    );

    /** Parse {@code xOrigin}/{@code yOrigin} from the {@code <map ...>} root. */
    private static int[] readOrigins(String xml) {
        int[] r = new int[]{0, 0};
        java.util.regex.Matcher m = java.util.regex.Pattern.compile(
            "<map[^>]*?xOrigin\\s*=\\s*[\"']?(-?\\d+)[\"']?[^>]*?yOrigin\\s*=\\s*[\"']?(-?\\d+)").matcher(xml);
        if (m.find()) {
            try { r[0] = Integer.parseInt(m.group(1)); } catch (Exception ignored) {}
            try { r[1] = Integer.parseInt(m.group(2)); } catch (Exception ignored) {}
        }
        return r;
    }

    private void loadActiveVersionCatalog(Path wwwRoot, String versionFilePath) {
        Path vf = versionFile(wwwRoot, versionFilePath);
        if (vf == null || !Files.isRegularFile(vf)) return;

        try {
            String b64 = Files.readString(vf, StandardCharsets.UTF_8).trim();
            String decoded = new String(Base64.getDecoder().decode(b64), StandardCharsets.UTF_8);
            for (String row : decoded.split("\\|")) {
                int equals = row.indexOf('=');
                if (equals <= 0 || equals == row.length() - 1) continue;
                String key = row.substring(0, equals).trim();
                String source = row.substring(equals + 1).trim();
                if (!key.isEmpty() && source.startsWith("rooms/")) {
                    put(genericPublicRoom(key, source));
                }
            }
        } catch (IOException | IllegalArgumentException ignored) {
            // Keep the hand-authored fallback rooms below. SFS logs the final
            // starter room during extension init; missing catalog assets will
            // surface as CDN misses rather than blocking extension startup.
        }
    }

    private static Path versionFile(Path wwwRoot, String versionFilePath) {
        if (wwwRoot == null || versionFilePath == null || versionFilePath.isBlank()) return null;
        String rel = versionFilePath.trim().replace('\\', '/');
        if (rel.startsWith("/static/")) rel = rel.substring("/static/".length());
        if (rel.startsWith("static/")) rel = rel.substring("static/".length());
        while (rel.startsWith("/")) rel = rel.substring(1);
        return wwwRoot.resolve("global").resolve("static").resolve(rel.replace('/', java.io.File.separatorChar));
    }

    private String sourceFor(String key, String fallback) {
        Place place = byKey.get(key);
        return place == null || place.defaultSource() == null ? fallback : place.defaultSource();
    }

    private static Place street01(String source, boolean hasStreet02) {
        return new Place(
            "street01",
            RoomTypeName.OUTDOOR,
            "Street 01",
            source,
            RoomGrid.allEmpty(DEFAULT_W, DEFAULT_H), // TODO: derive from per-room metadata (see testStreet.swf reference grid)
            ST01_CANVAS_W, ST01_CANVAS_H, // native st01.swf pixel dims
            ST01_X_ORIGIN, ST01_Y_ORIGIN, // iso projection calibration
            null,                            // default map XML — builds <map xOrigin yOrigin/>
            street01Doors(hasStreet02),
            10, 10, Direction.SOUTH          // spawn (10,10) → canvas (400, 385) — on the road
        );
    }

    private static List<DoorDef> street01Doors(boolean hasStreet02) {
        // Always expose d1 so the init handshake (which spawns the avatar at
        // d1's tile) has somewhere to land. When the captured production
        // doors file exists it overrides this entirely.
        DoorDef d1 = new DoorDef(
            "d1",
            5, 5, Direction.SOUTH,
            hasStreet02 ? "PassageProperty" : "TeleportProperty",
            hasStreet02 ? Map.of("roomKey", "street02", "destDoorKey", "d1") : Map.of()
        );
        return List.of(d1);
    }

    private static Place genericPublicRoom(String key, String source) {
        return new Place(
            key,
            RoomTypeName.OUTDOOR,
            key,
            source,
            RoomGrid.allEmpty(DEFAULT_W, DEFAULT_H),
            ST01_CANVAS_W, ST01_CANVAS_H,
            ST01_X_ORIGIN, ST01_Y_ORIGIN,
            null,
            List.<DoorDef>of(),
            10, 10, Direction.SOUTH
        );
    }
}
