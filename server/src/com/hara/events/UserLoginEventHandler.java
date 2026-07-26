package com.hara.events;

import java.util.Optional;

import com.hara.domain.model.Account;
import com.hara.infra.audit.AuditLog;
import com.hara.service.auth.AccountService;
import com.hara.service.auth.UserSession;
import com.smartfoxserver.bitswarm.sessions.ISession;
import com.smartfoxserver.v2.core.ISFSEvent;
import com.smartfoxserver.v2.core.SFSEventParam;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.exceptions.SFSException;
import com.smartfoxserver.v2.extensions.BaseServerEventHandler;

/**
 * Fires during SFS login. Reads the client's {@code token} from
 * {@code LOGIN_IN_DATA} (see {@code LoginCommand.as}), upserts the
 * {@link Account}, and stashes the account id on the {@link ISession}
 * for later events / handlers to read via {@link UserSession#accountId}.
 *
 * <p>The SFS {@code User} object does not exist yet at this point —
 * {@code USER_JOIN_ZONE} is where the user object first appears.
 *
 * <p>Auth model today: any token is accepted (anonymous guests get a
 * server-minted token). Replace with a real auth check (OAuth verify /
 * JWT decode / DB lookup) in a later wave.
 */
public final class UserLoginEventHandler extends BaseServerEventHandler {

    private final AccountService accounts;

    public UserLoginEventHandler(AccountService accounts) {
        this.accounts = accounts;
    }

    @Override
    public void handleServerEvent(ISFSEvent event) throws SFSException {
        // Use the SFS-routed extension logger so we ALWAYS see this line, even
        // before AuditLog has anything to say.
        trace("user.login event fired");

        ISFSObject inData = (ISFSObject) event.getParameter(SFSEventParam.LOGIN_IN_DATA);
        ISession   session = (ISession) event.getParameter(SFSEventParam.SESSION);
        if (session == null) {
            getLogger().warn("[hara] user.login: SESSION param is null — accountId WILL be missing later");
            return;
        }

        String token = inData == null ? null : inData.getUtfString("token");
        Account account;
        if (token != null && !token.isBlank()) {
            // Client sent a persistent token (web-login, returning user, or a
            // previously-issued guest token stored client-side). Resolve by it.
            account = accounts.upsertByToken(token);
        } else {
            // Empty token: this is a guest. The client's Connectr.reset()
            // performs a logout + immediate re-login on the SAME TCP socket
            // (same bitswarm session) which means the account id we stashed
            // earlier survives the round-trip. Reuse it so a guest who just
            // created an avatar lands back on the SAME account on reconnect
            // (otherwise every Connectr.reset spawns a fresh orphan account
            // and the avatar created moments ago becomes unreachable, sending
            // the user into a never-ending AvatarCreatePanel loop).
            Optional<Long> stickyAcctId = UserSession.accountId(session);
            if (stickyAcctId.isPresent()) {
                account = accounts.requireById(stickyAcctId.get());
                getLogger().info("[hara] user.login REUSE session-bound acct={} session={}",
                    account.id(), session.getId());
            } else {
                account = accounts.upsertByToken(null);
            }
        }

        UserSession.setAccountId(session, account.id());

        // SFS auto-assigns the user a unique guest name (e.g. Guest#1) when
        // the client logs in with an empty username — the LoginCommand on the
        // client uses ""/"" — so we don't need to rewrite LOGIN_NAME here.
        // Identity is carried by the accountId we stashed on the session above.

        ISFSObject outData = (ISFSObject) event.getParameter(SFSEventParam.LOGIN_OUT_DATA);
        if (outData != null) outData.putLong("accountId", account.id());

        getLogger().info("[hara] user.login OK acct={} session={} token={}",
            account.id(), session.getId(), safeTokenForLog(account.token()));
        AuditLog.info("user.login", account.id(), "token=" + safeTokenForLog(account.token()));
    }

    /** Don't leak a full token into logs — first 8 chars is enough to correlate. */
    private static String safeTokenForLog(String token) {
        if (token == null) return "<null>";
        return token.length() <= 8 ? token : token.substring(0, 8) + "…";
    }
}
