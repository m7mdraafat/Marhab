package com.hara.domain.enums;

/**
 * Wire byte values for the {@code grid} RoomVariable payload. These are NOT
 * the AS3 {@code CellType} enum constants -- they are the {@code cell.bit}
 * values the client's {@code IsoScene.processGrid} switch consumes via
 * {@code switch(cell.bit + 1)}:
 * <pre>
 *   case 0  (bit=-1) =&gt; TYPE_WALK_ONLY
 *   case 1,3 (bit=0,2) =&gt; TYPE_EMPTY
 *   case 2  (bit= 1) =&gt; TYPE_DISABLED       (walls/buildings live here)
 *   case 5  (bit= 4) =&gt; TYPE_DIAMOND
 *   case 6  (bit= 5) =&gt; TYPE_ADMIN
 *   case 8  (bit= 7) =&gt; TYPE_FISH
 *   case 9  (bit= 8) =&gt; TYPE_SANALIKAX
 *   case 11 (bit=10) =&gt; TYPE_SHORTCUT
 *   case 12 (bit=11) =&gt; TYPE_NPC
 *   case 13 (bit=12) =&gt; TYPE_STAGE
 *   case 14 (bit=13) =&gt; TYPE_FURNITURE_ONLY
 * </pre>
 * Any byte outside that set silently defaults to TYPE_EMPTY (walkable) on
 * the client, which is the bug that made every wall walk-through.
 * See {@code docs/04 sec 4.4}.
 */
public final class CellType {
    public static final byte TYPE_EMPTY          =  0;
    public static final byte TYPE_WALK_ONLY      = -1;
    /** Non-walkable (building/water). Was 3 — clients silently treat 3 as EMPTY. */
    public static final byte TYPE_DISABLED       =  1;
    public static final byte TYPE_DIAMOND        =  4;
    public static final byte TYPE_ADMIN          =  5;
    /** Runtime-only (cursor highlight). Never written to the wire. */
    public static final byte TYPE_TARGET         =  6;
    public static final byte TYPE_FISH           =  7;
    public static final byte TYPE_SANALIKAX      =  8;
    public static final byte TYPE_SHORTCUT       = 10;
    public static final byte TYPE_NPC            = 11;
    public static final byte TYPE_STAGE          = 12;
    public static final byte TYPE_FURNITURE_ONLY = 13;

    /** True for plain ground tiles anyone can walk on (subject to role bits). */
    public static boolean isPlainWalkable(byte b) {
        return b == TYPE_EMPTY || b == TYPE_WALK_ONLY;
    }

    private CellType() {}
}
