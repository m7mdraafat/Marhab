package com.hara.protocol.handlers.avatar;

import java.util.List;

import com.hara.protocol.framework.HandlerBase;
import com.hara.protocol.framework.ResponseBuilder;
import com.hara.protocol.framework.SfsObjectMapper;
import com.hara.service.room.VariableNames;
import com.smartfoxserver.v2.entities.User;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.variables.SFSUserVariable;
import com.smartfoxserver.v2.entities.variables.UserVariable;
import com.smartfoxserver.v2.extensions.SFSExtension;

/**
 * Pick a chat-balloon color. Updates the {@code chatBalloon} UserVariable;
 * other clients read it to colorize the speech bubble outline.
 *
 * <p>Wire shape in: {@code { id:int }}. Out: {@code {}}.
 */
public final class UseChatBalloonHandler extends HandlerBase {

    private final SFSExtension extension;

    public UseChatBalloonHandler(SFSExtension extension) { this.extension = extension; }

    @Override
    protected String command() { return "usechatballoon"; }

    @Override
    protected ISFSObject handle(User user, ISFSObject params) throws Exception {
        int balloonId = SfsObjectMapper.optInt(params, "id", 0);
        UserVariable uv = new SFSUserVariable(VariableNames.UV_CHAT_BALLOON, balloonId);
        extension.getApi().setUserVariables(user, List.of(uv));
        return new ResponseBuilder().putBool("ok", true).build();
    }
}
