package com.hara.protocol.handlers.social;

import com.hara.protocol.framework.HandlerBase;
import com.hara.protocol.framework.ResponseBuilder;
import com.hara.protocol.wire.ServerEnvelope;
import com.smartfoxserver.v2.entities.User;
import com.smartfoxserver.v2.entities.data.ISFSObject;

/**
 * Like / dislike toggle. Request {@code {avatarID:str, avatarLike:1|-1}}
 * → reply {@code {likeCount, dislikeCount, rid, nextRequest:2000, ts}}.
 *
 * No persistence yet — we echo zero counts. Production also broadcasts
 * {@code avatarLikeUpdated{avatarID,status}} to nearby users; we'll add
 * that push when buddy persistence lands.
 */
public final class ProfileLikeHandler extends HandlerBase {

    @Override
    protected String command() { return "profilelike"; }

    @Override
    protected ISFSObject handle(User user, ISFSObject params) {
        return ServerEnvelope.stamp(
            new ResponseBuilder()
                .putInt("likeCount",    0)
                .putInt("dislikeCount", 0),
            ServerEnvelope.NEXT_SLOW)
            .build();
    }
}
