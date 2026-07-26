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
 * Emit/clear the current smiley. The {@code smiley} UserVariable is read
 * by every other client in the room and rendered above the avatar.
 *
 * <p>Wire shape in: {@code { id:"...":string }} — empty string clears.
 * Wire shape out: {@code {}} (success ack).
 */
public final class ChangeSmileyHandler extends HandlerBase {

    private final SFSExtension extension;

    public ChangeSmileyHandler(SFSExtension extension) { this.extension = extension; }

    @Override
    protected String command() { return "changesmiley"; }

    @Override
    protected ISFSObject handle(User user, ISFSObject params) throws Exception {
        String smileyId = SfsObjectMapper.optStr(params, "id", "");
        UserVariable uv = new SFSUserVariable(VariableNames.UV_SMILEY, smileyId);
        extension.getApi().setUserVariables(user, List.of(uv));
        return new ResponseBuilder().putBool("ok", true).build();
    }
}
