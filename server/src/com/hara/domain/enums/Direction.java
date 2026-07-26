package com.hara.domain.enums;

/** Mirrors {@code com.oyunstudyosu.enums.Direction}. Values 1..8 — see {@code docs/04 §4.6}. */
public final class Direction {
    public static final int NORTH_EAST = 1;
    public static final int EAST       = 2;
    public static final int SOUTH_EAST = 3;
    public static final int SOUTH      = 4;
    public static final int SOUTH_WEST = 5;
    public static final int WEST       = 6;
    public static final int NORTH_WEST = 7;
    public static final int NORTH      = 8;

    public static boolean isValid(int dir) { return dir >= 1 && dir <= 8; }

    private Direction() {}
}
