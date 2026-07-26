package com.hara.service.auth;

import java.util.Optional;

import com.smartfoxserver.bitswarm.sessions.ISession;
import com.smartfoxserver.v2.entities.User;

/**
 * Typed helpers over {@link ISession#getProperty}/{@link ISession#setProperty}.
 * SFS's session bag is the only state shared between the {@code USER_LOGIN}
 * event (no {@link User} yet) and per-request handlers (User-bound).
 *
 * <p>String key constants are public so handlers can {@code remove} them on
 * logout / reconnect if needed.
 */
public final class UserSession {

    public static final String ACCOUNT_ID = "hara.accountId";
    public static final String AVATAR_ID  = "hara.avatarId";

    private UserSession() {}

    // -- write -------------------------------------------------------------

    public static void setAccountId(ISession session, long accountId) {
        session.setProperty(ACCOUNT_ID, accountId);
    }

    public static void setAvatarId(ISession session, long avatarId) {
        session.setProperty(AVATAR_ID, avatarId);
    }

    public static void setAvatarId(User user, long avatarId) {
        setAvatarId(user.getSession(), avatarId);
    }

    // -- read --------------------------------------------------------------

    public static Optional<Long> accountId(ISession session) {
        Object v = session.getProperty(ACCOUNT_ID);
        return (v instanceof Long) ? Optional.of((Long) v) : Optional.empty();
    }

    public static Optional<Long> accountId(User user) {
        return accountId(user.getSession());
    }

    public static Optional<Long> avatarId(ISession session) {
        Object v = session.getProperty(AVATAR_ID);
        return (v instanceof Long) ? Optional.of((Long) v) : Optional.empty();
    }

    public static Optional<Long> avatarId(User user) {
        return avatarId(user.getSession());
    }
}
