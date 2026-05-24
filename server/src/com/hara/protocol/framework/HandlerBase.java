package com.hara.protocol.framework;

import com.smartfoxserver.v2.entities.User;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.extensions.BaseClientRequestHandler;

/**
 * Base for every client-request handler in Hara.
 *
 * Wraps the raw SFS callback with:
 *   - try/catch that converts uncaught exceptions to a standard error envelope
 *   - {@link BadRequestException} -> {ok:false, errorCode:400, message:...}
 *   - any other RuntimeException -> {ok:false, errorCode:500, message:"internal"}
 *   - timing trace (handler name + duration in ms)
 *
 * Subclasses implement {@link #handle(User, ISFSObject)}; if they want a
 * response, return one and the base sends it under {@link #responseCommand()}
 * (defaults to the request name).
 *
 * Rate-limiting + auth gates will hook in here later (Phase 3 of the plan).
 */
public abstract class HandlerBase extends BaseClientRequestHandler {

    /** The client request id this handler is bound to. Used as the default response sn. */
    protected abstract String command();

    /**
     * Override to send the response under a different name (rarely needed).
     * Default = the request command.
     */
    protected String responseCommand() { return command(); }

    /**
     * Implement the handler. Return null to send no response, or an ISFSObject
     * to be sent back under {@link #responseCommand()}.
     */
    protected abstract ISFSObject handle(User user, ISFSObject params) throws Exception;

    @Override
    public final void handleClientRequest(User user, ISFSObject params) {
        long t0 = System.nanoTime();
        String cmd = command();
        try {
            ISFSObject response = handle(user, params);
            if (response != null) send(responseCommand(), response, user);
            long ms = (System.nanoTime() - t0) / 1_000_000L;
            trace(cmd + " ok user=" + user.getName() + " (" + ms + "ms)");
        } catch (BadRequestException bre) {
            send(responseCommand(),
                ResponseBuilder.error(400, bre.getMessage()).build(),
                user);
            trace(cmd + " BAD_REQUEST user=" + user.getName() + ": " + bre.getMessage());
        } catch (Exception e) {
            send(responseCommand(),
                ResponseBuilder.error(500, "internal").build(),
                user);
            trace(cmd + " FAILED user=" + user.getName() + ": "
                + e.getClass().getSimpleName() + ": " + e.getMessage());
        }
    }
}
