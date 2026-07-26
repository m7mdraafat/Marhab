package com.hara.protocol.handlers.chat;

import com.hara.protocol.framework.HandlerBase;
import com.hara.protocol.framework.SfsObjectMapper;
import com.smartfoxserver.v2.entities.User;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSObject;
import com.smartfoxserver.v2.extensions.SFSExtension;

/**
 * 1-to-1 private message. Wire in:
 * {@code { targetAvatarID:string, message:string }}. The server pushes a
 * matching {@code whisper} event to the target user only — see
 * {@code docs/03 §3.2}.
 *
 * <p>Lookup is by avatarID string, which today maps directly to SFS user
 * name {@code "acct_<id>"} since we mint one user per account. When
 * multiple avatars per account land, we'll need an avatar-id → user-name
 * index.
 */
public final class WhisperHandler extends HandlerBase {

    private final SFSExtension extension;

    public WhisperHandler(SFSExtension extension) { this.extension = extension; }

    @Override
    protected String command() { return "whisper"; }

    @Override
    protected ISFSObject handle(User sender, ISFSObject params) {
        String target = SfsObjectMapper.reqStr(params, "targetAvatarID");
        String msg    = SfsObjectMapper.reqStr(params, "message");

        User to = extension.getParentZone().getUserByName(resolveUserName(target));
        if (to == null) return null; // recipient offline; drop silently for now

        ISFSObject push = new SFSObject();
        push.putUtfString("fromAvatarID", String.valueOf(sender.getId()));
        push.putUtfString("fromAvatarName", sender.getName());
        push.putUtfString("message", msg);
        extension.send(command(), push, to);
        return null;
    }

    /** Map an avatarID-as-string to the corresponding SFS user name. */
    private static String resolveUserName(String avatarId) {
        return "acct_" + avatarId;
    }
}
