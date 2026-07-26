package com.hara.domain.model;

import com.hara.domain.enums.CellType;

/**
 * Per-room walkability grid. Cell {@code (x,y)} lives at index
 * {@code y * width + x}; each byte is a {@link CellType}. The wire format
 * is {@code [int32 width][int32 height][w*h bytes]} base64-encoded — see
 * {@code docs/04 §4.4}.
 */
public final class RoomGrid {
    private final int width;
    private final int height;
    private final byte[] cells;

    public RoomGrid(int width, int height, byte[] cells) {
        if (width <= 0 || height <= 0) throw new IllegalArgumentException("width/height must be >0");
        if (cells.length != width * height) {
            throw new IllegalArgumentException("cells length " + cells.length
                + " != width*height " + (width * height));
        }
        this.width = width;
        this.height = height;
        this.cells = cells.clone();
    }

    public int width() { return width; }
    public int height() { return height; }
    public byte[] cells() { return cells.clone(); }

    public boolean inBounds(int x, int y) {
        return x >= 0 && y >= 0 && x < width && y < height;
    }

    public byte cellAt(int x, int y) {
        if (!inBounds(x, y)) throw new IndexOutOfBoundsException(x + "," + y);
        return cells[y * width + x];
    }

    /** Lightweight walkability check ignoring role gates (cheaper than full Cell.isWalkable). */
    public boolean isPlainWalkable(int x, int y) {
        return inBounds(x, y) && CellType.isPlainWalkable(cellAt(x, y));
    }

    /** Build an all-empty grid of the given dimensions. Useful for first-cut rooms. */
    public static RoomGrid allEmpty(int width, int height) {
        return new RoomGrid(width, height, new byte[width * height]); // 0 == TYPE_EMPTY
    }

    /**
     * Author a grid from an ASCII art representation. One character per cell,
     * one line per row (rows top-to-bottom, columns left-to-right). Width is
     * the longest row length; shorter rows are right-padded with the
     * default character.
     *
     * <p>Character → cell-byte mapping:
     * <ul>
     *   <li>{@code '.'} → {@link CellType#TYPE_EMPTY}     (default walkable)</li>
     *   <li>{@code 'w'} → {@link CellType#TYPE_WALK_ONLY} (walk-only, no furniture)</li>
     *   <li>{@code '#'} → {@link CellType#TYPE_DISABLED}  (blocked — building / water / etc.)</li>
     *   <li>{@code 'D'} → {@link CellType#TYPE_DIAMOND}   (diamond-club gated)</li>
     *   <li>{@code 'A'} → {@link CellType#TYPE_ADMIN}     (moderator gated)</li>
     *   <li>{@code 'F'} → {@link CellType#TYPE_FURNITURE_ONLY} (no avatar)</li>
     * </ul>
     * Any other character throws.
     */
    public static RoomGrid fromAscii(String... rows) {
        if (rows == null || rows.length == 0) throw new IllegalArgumentException("no rows");
        int h = rows.length;
        int w = 0;
        for (String row : rows) if (row.length() > w) w = row.length();
        if (w == 0) throw new IllegalArgumentException("zero-width grid");
        byte[] cells = new byte[w * h];
        for (int y = 0; y < h; y++) {
            String row = rows[y];
            for (int x = 0; x < w; x++) {
                char ch = x < row.length() ? row.charAt(x) : '.';
                cells[y * w + x] = asciiToCell(ch, x, y);
            }
        }
        return new RoomGrid(w, h, cells);
    }

    private static byte asciiToCell(char ch, int x, int y) {
        switch (ch) {
            case '.': return CellType.TYPE_EMPTY;
            case 'w': return CellType.TYPE_WALK_ONLY;
            case '#': return CellType.TYPE_DISABLED;
            case 'D': return CellType.TYPE_DIAMOND;
            case 'A': return CellType.TYPE_ADMIN;
            case 'F': return CellType.TYPE_FURNITURE_ONLY;
            default:
                throw new IllegalArgumentException(
                    "RoomGrid.fromAscii: unknown cell char '" + ch + "' at (" + x + "," + y + ")");
        }
    }
}
