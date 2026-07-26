package com.hara.domain.model;

/**
 * Server-side walk reservation — created by {@code walkrequest}, consumed by
 * {@code walkfinalrequest}. See {@code docs/04 §4.9}.
 */
public final class WalkSession {
    private final long userId;
    private final int roomId;
    private final int targetX;
    private final int targetY;
    private final int direction;
    private final boolean door;
    private final long createdAtMillis;
    private final long expiresAtMillis;

    public WalkSession(long userId, int roomId, int targetX, int targetY, int direction,
                       boolean door, long createdAtMillis, long expiresAtMillis) {
        this.userId = userId;
        this.roomId = roomId;
        this.targetX = targetX;
        this.targetY = targetY;
        this.direction = direction;
        this.door = door;
        this.createdAtMillis = createdAtMillis;
        this.expiresAtMillis = expiresAtMillis;
    }

    public long userId() { return userId; }
    public int roomId() { return roomId; }
    public int targetX() { return targetX; }
    public int targetY() { return targetY; }
    public int direction() { return direction; }
    public boolean door() { return door; }
    public long createdAtMillis() { return createdAtMillis; }
    public long expiresAtMillis() { return expiresAtMillis; }

    public boolean isExpired(long nowMillis) { return nowMillis > expiresAtMillis; }
}
