package com.hara.service.catalog;

import com.hara.domain.enums.Direction;
import com.hara.domain.model.DoorDef;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Per-room door table extracted from the original room SWFs by
 * {@code rebuild/extract-all-doors.py}. Lives at
 * {@code rebuild/inventory/room-doors/all-doors.csv} with columns:
 * <pre>roomKey, swf, key, pixel_x, pixel_y, tile_x, tile_y, xOrigin, yOrigin</pre>
 *
 * <p>Used as a fallback when no captured {@code doors.json} from the live
 * server is available. The tile_x/tile_y columns are exactly the
 * {@code targetX}/{@code targetY} the production server returns, so the
 * spawn lines up with the visible door clip in the room SWF.
 *
 * <p>{@code targetDir} isn't in the CSV; we default to {@link Direction#SOUTH}
 * since most doors face outward (the client overrides the facing once the
 * avatar's first walk fires).
 */
public final class AllDoorsCsv {

    private final Map<String, List<DoorDef>> byRoom;

    private AllDoorsCsv(Map<String, List<DoorDef>> byRoom) {
        this.byRoom = byRoom;
    }

    /** Look up doors for {@code roomKey}; empty list if unknown. */
    public List<DoorDef> forRoom(String roomKey) {
        return byRoom.getOrDefault(roomKey, List.of());
    }

    public boolean isEmpty() { return byRoom.isEmpty(); }

    /** Number of distinct rooms with at least one door. */
    public int roomCount() { return byRoom.size(); }

    /**
     * Try common paths to find the CSV: the explicit {@code csvOverride}
     * first, then a sibling of {@code wwwRoot}'s repo checkout, then a
     * relative path used in tests. Returns an empty instance on any miss.
     */
    public static AllDoorsCsv loadOrEmpty(Path csvOverride, Path wwwRoot) {
        Path csv = resolve(csvOverride, wwwRoot);
        if (csv == null || !Files.isRegularFile(csv)) return new AllDoorsCsv(Map.of());
        try {
            return parse(Files.readAllLines(csv));
        } catch (IOException e) {
            return new AllDoorsCsv(Map.of());
        }
    }

    private static Path resolve(Path csvOverride, Path wwwRoot) {
        if (csvOverride != null && Files.isRegularFile(csvOverride)) return csvOverride;
        if (wwwRoot != null) {
            // wwwRoot lives at <repoRoot>/server/www -- walk back to the repo root
            // and into rebuild/inventory/room-doors/all-doors.csv.
            Path candidate = wwwRoot.resolve("..").resolve("..")
                .resolve("rebuild").resolve("inventory").resolve("room-doors")
                .resolve("all-doors.csv").normalize();
            if (Files.isRegularFile(candidate)) return candidate;
        }
        Path fallback = Path.of("rebuild", "inventory", "room-doors", "all-doors.csv");
        if (Files.isRegularFile(fallback)) return fallback;
        return null;
    }

    private static AllDoorsCsv parse(List<String> lines) {
        Map<String, List<DoorDef>> byRoom = new HashMap<>();
        boolean headerSkipped = false;
        for (String raw : lines) {
            if (raw == null || raw.isBlank()) continue;
            String line = raw.trim();
            if (!headerSkipped) { headerSkipped = true; if (line.startsWith("roomKey")) continue; }
            String[] cols = line.split(",");
            if (cols.length < 7) continue;
            try {
                String roomKey = cols[0].trim();
                String key     = cols[2].trim();
                int tileX = Integer.parseInt(cols[5].trim());
                int tileY = Integer.parseInt(cols[6].trim());
                DoorDef d = new DoorDef(
                    key, tileX, tileY, Direction.SOUTH,
                    "PassageProperty", Map.of()
                );
                byRoom.computeIfAbsent(roomKey, k -> new ArrayList<>()).add(d);
            } catch (NumberFormatException e) {
                // skip malformed row
            }
        }
        // Defensive: replace mutable lists with copies the catalog can rely on.
        Map<String, List<DoorDef>> immutable = new HashMap<>(byRoom.size());
        for (var e : byRoom.entrySet()) immutable.put(e.getKey(), List.copyOf(e.getValue()));
        return new AllDoorsCsv(immutable);
    }
}
