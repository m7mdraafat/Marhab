package com.hara.domain.model;

import java.util.Objects;

/**
 * A single equipped or owned cloth — what the {@code clothes} UserVariable
 * and the {@code clothes:{items:[...]}} block in the {@code init} reply
 * carry. {@code color} is optional (omitted entirely when the clip has no
 * color variants — mirrors AvatarCreatePanel's serialization).
 */
public final class ClothItem {
    private final String clip;
    private final Integer color; // nullable

    public ClothItem(String clip, Integer color) {
        this.clip = Objects.requireNonNull(clip, "clip");
        this.color = color;
    }

    public String clip() { return clip; }
    public Integer color() { return color; }
    public boolean hasColor() { return color != null; }
}
