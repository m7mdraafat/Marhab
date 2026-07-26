package com.hara.protocol.handlers.boot;

import com.hara.protocol.framework.HandlerBase;
import com.smartfoxserver.v2.entities.User;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSObject;

/**
 * Reusable stub that replies with an empty SFSObject under whatever command
 * name it's registered as. The same instance can be registered under many
 * commands — the reply is identical for all (just {@code {}}), which keeps
 * the client's pending-request callback from leaking.
 *
 * <p>Used for {@code ping}, {@code changesettings}, and the long tail of
 * pre-Wave-5 commands that the client may fire but the server has no
 * meaningful response for yet.
 */
public final class EmptyOkHandler extends HandlerBase {

    private final String command;

    public EmptyOkHandler(String command) { this.command = command; }

    @Override
    protected String command() { return command; }

    @Override
    protected ISFSObject handle(User user, ISFSObject params) {
        return new SFSObject();
    }
}
