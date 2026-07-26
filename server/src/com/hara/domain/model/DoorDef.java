package com.hara.domain.model;

import java.util.Collections;
import java.util.Map;
import java.util.Objects;

/**
 * One entry in a room's {@code doors} RoomVariable JSON. See
 * {@code docs/04 §4.5}. {@code propertyData} carries the {@code cn}-resolved
 * property's data bag (e.g. {@code {"roomKey":"street02"}} for a passage).
 */
public final class DoorDef {
    private final String key;
    private final int targetX;
    private final int targetY;
    private final int targetDir;
    private final String propertyClass;
    private final Map<String, Object> propertyData;

    public DoorDef(String key, int targetX, int targetY, int targetDir,
                   String propertyClass, Map<String, Object> propertyData) {
        this.key = Objects.requireNonNull(key, "key");
        this.targetX = targetX;
        this.targetY = targetY;
        this.targetDir = targetDir;
        this.propertyClass = Objects.requireNonNull(propertyClass, "propertyClass");
        this.propertyData = propertyData == null ? Map.of() : Map.copyOf(propertyData);
    }

    public String key() { return key; }
    public int targetX() { return targetX; }
    public int targetY() { return targetY; }
    public int targetDir() { return targetDir; }
    public String propertyClass() { return propertyClass; }
    public Map<String, Object> propertyData() { return Collections.unmodifiableMap(propertyData); }
}
