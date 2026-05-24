package com.hara.service;

import com.smartfoxserver.v2.entities.User;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * In-memory per-user state, keyed by a STABLE identifier derived from the
 * SFS {@link User}:
 *
 *   real accounts: username (set by LoginHandler from users.properties)
 *   guest accounts: client IP address
 *
 * Why not username for everyone? SFS auto-generates {@code Guest#N} where N
 * increments per session, so after {@code Connectr.reset()} (the avatar-save
 * flow) the new session gets a different Guest# and any state keyed by
 * username would be wiped -- causing AvatarCreatePanel to reopen forever.
 *
 * Persists for the lifetime of the SFS JVM. Restarting SFS resets every user
 * back to "fresh guest" -- fine for dev. Will be backed by AvatarDao when
 * persistence lands.
 */
public final class UserStateRegistry {

    public static final class UserState {
        /** True after the user has gone through AvatarCreatePanel (BaseCloth). */
        public boolean baseClothSelected = false;
        /** True after the user has finished avatar creation entirely. */
        public boolean avatarCreated = false;
        public String  avatarId   = "1";
        public String  avatarName = "";
        public String  gender     = "m";
        /** Last room key the user was in -- restored on next login. */
        public String  lastRoomKey = null;
    }

    private static final Map<String, UserState> STATES = new ConcurrentHashMap<>();

    private UserStateRegistry() {}

    /** Resolve the stable key for a User -- IP for guests, username otherwise. */
    public static String stableKey(User u) {
        String name = u.getName();
        if (name != null && name.startsWith("Guest#")) {
            String ip = u.getIpAddress();
            return "ip:" + (ip != null ? ip : name);
        }
        return "user:" + name;
    }

    public static UserState forUser(User u) {
        return STATES.computeIfAbsent(stableKey(u), k -> new UserState());
    }

    public static void removeUser(User u) {
        STATES.remove(stableKey(u));
    }
}
