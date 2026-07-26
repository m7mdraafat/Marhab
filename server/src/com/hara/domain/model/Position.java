package com.hara.domain.model;

import com.hara.domain.enums.Direction;

/** Tile-grid position with facing direction (1..8 per {@link Direction}). */
public final class Position {
    private final int x;
    private final int y;
    private final int direction;

    public Position(int x, int y, int direction) {
        this.x = x; this.y = y; this.direction = direction;
    }

    public int x() { return x; }
    public int y() { return y; }
    public int direction() { return direction; }

    /** Wire shape that goes into the {@code position} UserVariable. */
    public String asWireString() { return x + "," + y; }
}
