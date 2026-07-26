package com.hara.protocol.handlers.shop;

import com.hara.protocol.framework.HandlerBase;
import com.hara.protocol.framework.ResponseBuilder;
import com.hara.protocol.wire.ServerEnvelope;
import com.smartfoxserver.v2.entities.User;
import com.smartfoxserver.v2.entities.data.ISFSObject;

/**
 * Stub purchase handler. Until the shop catalog is implemented we reject
 * every attempt with a graceful "out of stock" error envelope that the
 * client renders without crashing.
 *
 * Sniffed error shape: {@code {errorCode:int, errorMessage:str, rid, ts}}.
 */
public final class PurchaseHandler extends HandlerBase {

    @Override
    protected String command() { return "purchase"; }

    @Override
    protected ISFSObject handle(User user, ISFSObject params) {
        return new ResponseBuilder()
            .putInt ("rid",          ServerEnvelope.nextRid())
            .putLong("ts",           ServerEnvelope.nowSec())
            .putInt ("errorCode",    404)
            .putStr ("errorMessage", "Product not available in this universe yet.")
            .build();
    }
}
