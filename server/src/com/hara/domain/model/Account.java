package com.hara.domain.model;

import java.time.Instant;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Objects;

/**
 * A login identity. One account owns 0..N {@link Avatar}s. The wire-level
 * authentication token (see {@code LoginCommand.as}'s {@code token} field) is
 * the natural primary key — every reconnect carries it, and guests get a
 * server-minted token on first contact.
 */
public final class Account {
    private final long id;
    private final String token;
    private final String email; // nullable; null for anonymous guests
    private final List<Long> avatarIds;
    private final Instant createdAt;

    public Account(long id, String token, String email, Instant createdAt) {
        this.id = id;
        this.token = Objects.requireNonNull(token, "token");
        this.email = email;
        this.avatarIds = new ArrayList<>();
        this.createdAt = Objects.requireNonNull(createdAt, "createdAt");
    }

    public long id() { return id; }
    public String token() { return token; }
    public String email() { return email; }
    public Instant createdAt() { return createdAt; }
    public List<Long> avatarIds() { return Collections.unmodifiableList(avatarIds); }

    public void addAvatar(long avatarId) {
        if (!avatarIds.contains(avatarId)) avatarIds.add(avatarId);
    }
}
