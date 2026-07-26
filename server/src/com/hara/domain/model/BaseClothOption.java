package com.hara.domain.model;

/**
 * One row in the {@code baseclothes} reply array — see
 * {@code docs/11 §11.3 Step A}. {@code placeBit} is the cloth-slot bitmask
 * (NOT bit index) per ClothType (e.g. body=1, shirt=512, hair=131072).
 * {@code colors} may be empty (no color variants).
 */
public final class BaseClothOption {
    private final int placeBit;
    private final String clip;
    private final int[] colors;

    public BaseClothOption(int placeBit, String clip, int[] colors) {
        this.placeBit = placeBit;
        this.clip = clip;
        this.colors = colors == null ? new int[0] : colors;
    }

    public int placeBit() { return placeBit; }
    public String clip()  { return clip; }
    public int[] colors() { return colors.clone(); }
    public boolean hasColors() { return colors.length > 0; }
}
