package com.hara.protocol.handlers.shop;

import com.hara.protocol.framework.HandlerBase;
import com.hara.protocol.framework.ResponseBuilder;
import com.hara.protocol.wire.ServerEnvelope;
import com.smartfoxserver.v2.entities.User;
import com.smartfoxserver.v2.entities.data.ISFSObject;

/**
 * "Use hand item" success stub. Sniffed shape:
 * {@code {status:"success", message:"...", rid, ts}}.
 *
 * Until inventory persistence lands, every request "succeeds" and the
 * client updates its local hand-item state from the request payload.
 */
public final class UseHandItemHandler extends HandlerBase {

    @Override
    protected String command() { return "usehanditem"; }

    @Override
    protected ISFSObject handle(User user, ISFSObject params) {
        return new ResponseBuilder()
            .putInt ("rid",     ServerEnvelope.nextRid())
            .putLong("ts",      ServerEnvelope.nowSec())
            .putStr ("status",  "success")
            .putStr ("message", "Hand item equipped successfully.")
            .build();
    }
}
