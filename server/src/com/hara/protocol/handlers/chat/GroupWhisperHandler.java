package com.hara.protocol.handlers.chat;

import java.util.ArrayList;
import java.util.List;

import com.hara.protocol.framework.HandlerBase;
import com.hara.protocol.framework.SfsObjectMapper;
import com.smartfoxserver.v2.entities.User;
import com.smartfoxserver.v2.entities.data.ISFSArray;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSObject;
import com.smartfoxserver.v2.extensions.SFSExtension;

/**
 * Multi-recipient whisper. Wire in:
 * {@code { targetList:string[], message:string }}. Pushes a
 * {@code whispernotify} event to every online recipient (offline ones are
 * silently skipped; persistence to inbox lands in Wave 6).
 */
public final class GroupWhisperHandler extends HandlerBase {

    private final SFSExtension extension;

    public GroupWhisperHandler(SFSExtension extension) { this.extension = extension; }

    @Override
    protected String command() { return "groupwhisper"; }

    @Override
    protected ISFSObject handle(User sender, ISFSObject params) {
        ISFSArray targets = SfsObjectMapper.reqArr(params, "targetList");
        String msg        = SfsObjectMapper.reqStr(params, "message");

        List<User> recipients = new ArrayList<>(targets.size());
        for (int i = 0; i < targets.size(); i++) {
            String avatarId = targets.getUtfString(i);
            if (avatarId == null) continue;
            User to = extension.getParentZone().getUserByName("acct_" + avatarId);
            if (to != null) recipients.add(to);
        }
        if (recipients.isEmpty()) return null;

        ISFSObject push = new SFSObject();
        push.putUtfString("fromAvatarID", String.valueOf(sender.getId()));
        push.putUtfString("fromAvatarName", sender.getName());
        push.putUtfString("message", msg);
        extension.send("whispernotify", push, recipients);
        return null;
    }
}
