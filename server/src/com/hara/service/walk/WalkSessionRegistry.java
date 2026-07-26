package com.hara.service.walk;

import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;

import com.hara.domain.model.WalkSession;

/**
 * Process-local TTL map of pending walk reservations. One open session per
 * user — re-issuing {@code walkrequest} replaces the previous reservation
 * (cancellation semantics; matches client expectation that the timer is
 * reset by {@code clearTimeout(walkTimeout)} in {@code WalkModel.onWalkStart}).
 */
public final class WalkSessionRegistry {

    private final ConcurrentMap<Long, WalkSession> byUserId = new ConcurrentHashMap<>();

    public void open(WalkSession session) {
        byUserId.put(session.userId(), session);
    }

    /** Remove and return the session if any. */
    public Optional<WalkSession> take(long userId) {
        return Optional.ofNullable(byUserId.remove(userId));
    }

    /** Peek without removing. */
    public Optional<WalkSession> peek(long userId) {
        return Optional.ofNullable(byUserId.get(userId));
    }

    /** Drop on logout / room change. */
    public void clear(long userId) {
        byUserId.remove(userId);
    }

    public int size() { return byUserId.size(); }
}
