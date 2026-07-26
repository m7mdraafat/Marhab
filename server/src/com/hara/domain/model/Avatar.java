package com.hara.domain.model;

import java.time.Instant;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Objects;

/**
 * Player-controllable character. One account owns 0..N avatars; the active
 * one is identified by {@code selectedAvatarID} in the {@code init} reply.
 * Mutable on purpose — this is the unit of game-loop state.
 */
public final class Avatar {
    private final long id;
    private final long accountId;
    private String name;
    private String gender;
    private boolean baseClothSelected;
    private final List<ClothItem> clothes = new ArrayList<>();
    private final Wallet wallet;
    private int completedAchievementsCount;
    private final Instant createdAt;

    public Avatar(long id, long accountId, String name, String gender,
                  boolean baseClothSelected, Wallet wallet, Instant createdAt) {
        this.id = id;
        this.accountId = accountId;
        this.name = Objects.requireNonNull(name, "name");
        this.gender = Objects.requireNonNull(gender, "gender");
        this.baseClothSelected = baseClothSelected;
        this.wallet = Objects.requireNonNull(wallet, "wallet");
        this.createdAt = Objects.requireNonNull(createdAt, "createdAt");
    }

    public long id() { return id; }
    public long accountId() { return accountId; }
    public String name() { return name; }
    public String gender() { return gender; }
    public boolean baseClothSelected() { return baseClothSelected; }
    public Wallet wallet() { return wallet; }
    public int completedAchievementsCount() { return completedAchievementsCount; }
    public Instant createdAt() { return createdAt; }
    public List<ClothItem> clothes() { return Collections.unmodifiableList(clothes); }

    public void rename(String newName) { this.name = Objects.requireNonNull(newName); }
    public void setGender(String newGender) { this.gender = Objects.requireNonNull(newGender); }
    public void markBaseClothSelected() { this.baseClothSelected = true; }
    public void incrementAchievements() { this.completedAchievementsCount++; }

    public void replaceClothes(List<ClothItem> incoming) {
        this.clothes.clear();
        this.clothes.addAll(incoming);
    }
}
