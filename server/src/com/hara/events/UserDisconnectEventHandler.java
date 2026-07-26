package com.hara.events;

import com.hara.infra.audit.AuditLog;
import com.hara.service.auth.UserSession;
import com.hara.service.walk.WalkSessionRegistry;
import com.smartfoxserver.v2.core.ISFSEvent;
import com.smartfoxserver.v2.core.SFSEventParam;
import com.smartfoxserver.v2.entities.User;
import com.smartfoxserver.v2.exceptions.SFSException;
import com.smartfoxserver.v2.extensions.BaseServerEventHandler;

/**
 * Cleanup on socket teardown: drop any pending walk session, audit-log the
 * disconnect, leave session-bag state intact so reconnect-with-same-token
 * lands on the same {@link com.hara.domain.model.Account}.
 *
 * <p>Note: SFS fires both {@code USER_LOGOUT} and {@code USER_DISCONNECT} —
 * the former is a clean app-level logout (e.g. {@code LogoutRequest} sent
 * during avatar create's {@code Connectr.reset()}), the latter is socket
 * loss. Both want the same cleanup, so register this handler for both.
 */
public final class UserDisconnectEventHandler extends BaseServerEventHandler {

    private final WalkSessionRegistry walkSessions;

    public UserDisconnectEventHandler(WalkSessionRegistry walkSessions) {
        this.walkSessions = walkSessions;
    }

    @Override
    public void handleServerEvent(ISFSEvent event) throws SFSException {
        User user = (User) event.getParameter(SFSEventParam.USER);
        if (user == null) return;

        walkSessions.clear(user.getId());
        long accountId = UserSession.accountId(user).orElse(-1L);
        AuditLog.info("user.disconnect", accountId, "name=" + user.getName());
    }
}
