package com.hara.protocol.handlers.boot;

import com.hara.protocol.framework.HandlerBase;
import com.hara.protocol.framework.ResponseBuilder;
import com.hara.protocol.wire.ServerEnvelope;
import com.smartfoxserver.v2.entities.User;
import com.smartfoxserver.v2.entities.data.ISFSObject;

/**
 * Mark the active group for unread-message tracking. Sniffed shape:
 * request {@code {groupID:str}} → reply {@code {updateUnread:0, rid, nextRequest:500}}.
 * We don't persist unread state yet — the reply is a static "you're all caught up".
 */
public final class SetActiveGroupHandler extends HandlerBase {

    @Override
    protected String command() { return "setactivegroup"; }

    @Override
    protected ISFSObject handle(User user, ISFSObject params) {
        return ServerEnvelope.stamp(
            new ResponseBuilder().putInt("updateUnread", 0),
            ServerEnvelope.NEXT_NORMAL).build();
    }
}
