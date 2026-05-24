package com.hara.protocol.handlers.stubs;

import com.smartfoxserver.v2.entities.User;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSObject;
import com.smartfoxserver.v2.extensions.BaseClientRequestHandler;

/**
 * Generic "yes, ok" responder.
 *
 * Many Sanalika-protocol commands (config, init, ping, buddylist, walkrequest, ...)
 * follow the same envelope shape:
 *     request  = { sn:"<cmd>", rid:<n>, ts:<t>, data:{...} }
 *     response = { sn:"<cmd>", rid:<n>, ts:<t>, data:{...} }
 *
 * For a stub server, returning {ok:true} with an echoed sn+rid is enough to
 * unblock the client's pending promise so it moves on to the next command.
 * Real game features (walk, chat, items, currency) need their own handlers
 * with real data; this is a placeholder so the bootstrap doesn't hang on
 * "handler not found" errors.
 */
public class OkHandler extends BaseClientRequestHandler {

    @Override
    public void handleClientRequest(User user, ISFSObject params) {
        String sn = params != null && params.containsKey("sn") ? params.getUtfString("sn") : "?";
        long rid = params != null && params.containsKey("rid") ? params.getLong("rid") : 0L;

        // Client's ServiceModel unwraps response.toObject() and passes it flat
        // to the callback. So we send a flat {ok:true} object; cmd matching is
        // handled by SFS automatically via the send(cmd,...) name.
        ISFSObject response = new SFSObject();
        response.putBool("ok", true);
        send(sn, response, user);
        trace("OkHandler: stub-ok for sn=" + sn + " rid=" + rid + " user=" + user.getName());
    }
}
