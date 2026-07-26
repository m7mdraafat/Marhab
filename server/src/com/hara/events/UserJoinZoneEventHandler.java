package com.hara.events;

import com.hara.domain.enums.AvatarPermission;
import com.hara.domain.model.Account;
import com.hara.infra.audit.AuditLog;
import com.hara.service.auth.AccountService;
import com.hara.service.auth.UserSession;
import com.smartfoxserver.v2.core.ISFSEvent;
import com.smartfoxserver.v2.core.SFSEventParam;
import com.smartfoxserver.v2.entities.User;
import com.smartfoxserver.v2.exceptions.SFSException;
import com.smartfoxserver.v2.extensions.BaseServerEventHandler;

/**
 * Fires once the User object is fully constructed and present in the zone.
 * Sets the {@code privilegeId} (controls SFS-level capabilities) — we use
 * SFS's standard {@code STANDARD=1} for everyone today; moderators get
 * bumped to {@code 2} via a separate path when their {@code roles} carry
 * the {@link AvatarPermission#MODERATOR} bit.
 *
 * <p>Avatar auto-selection lives here too: if the account already owns at
 * least one avatar, we stash its id on the session so the {@code init}
 * handler doesn't have to re-query.
 *
 * <p>Auto-join to the starter room is intentionally NOT done here — it
 * belongs in the {@code init} handler so the client has settled UserVars
 * (clothes, gender, position) before the SFS room-join broadcast fires.
 */
public final class UserJoinZoneEventHandler extends BaseServerEventHandler {

    /** SFS-standard privilege ids — keep in sync with {@code UserPrivileges.as} on the client. */
    public static final short PRIV_GUEST    = 0;
    public static final short PRIV_STANDARD = 1;
    public static final short PRIV_MODERATOR= 2;
    public static final short PRIV_ADMIN    = 3;

    private final AccountService accounts;

    public UserJoinZoneEventHandler(AccountService accounts) {
        this.accounts = accounts;
    }

    @Override
    public void handleServerEvent(ISFSEvent event) throws SFSException {
        User user = (User) event.getParameter(SFSEventParam.USER);
        if (user == null) {
            getLogger().warn("[hara] user.join-zone: USER param is null");
            return;
        }

        long accountId = UserSession.accountId(user).orElse(-1L);
        // Guests (no email on Account) keep privilegeId=0 so the client's
        // Sanalika.onVersionFileLoaded() branch opens the GuestPanel.
        // Web-authenticated accounts get bumped to STANDARD, which routes
        // them straight to initialize() and bypasses GuestPanel.
        boolean hasEmail = accountId > 0
            && accounts.findById(accountId).map(a -> a.email() != null).orElse(false);
        user.setPrivilegeId(hasEmail ? PRIV_STANDARD : PRIV_GUEST);
        if (accountId < 0) {
            getLogger().warn("[hara] user.join-zone: NO accountId on session for user={} session={}",
                user.getName(), user.getSession() == null ? -1 : user.getSession().getId());
        } else {
            getLogger().info("[hara] user.join-zone OK acct={} user={} session={}",
                accountId, user.getName(), user.getSession().getId());
        }
        AuditLog.info("user.join-zone", accountId, "name=" + user.getName() + " privId=" + user.getPrivilegeId());
    }
}
