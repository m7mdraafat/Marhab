package com.hara.protocol.handlers.room;

import com.hara.protocol.framework.HandlerBase;
import com.hara.protocol.framework.ResponseBuilder;
import com.hara.domain.auth.RoleBitset;
import com.hara.service.room.VariableNames;
import com.smartfoxserver.v2.entities.User;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSObject;
import com.smartfoxserver.v2.extensions.SFSExtension;

/**
 * Client signals "scene fully built". Per the sniffed transcript, the
 * server's correct response is:
 * <ol>
 *   <li>Echo back {@code roomjoincomplete{}} so the client's pending
 *       callback resolves and the door-overlay HUD unfreezes.</li>
 *   <li>Push {@code roles{roles:"<base64 permission bitmap>"}} — the
 *       client's {@code AvatarController.onRoleUpdate} listener gates a
 *       large amount of HUD (teleport hotkey, security panel, etc.) on
 *       this push.</li>
 * </ol>
 */
public final class RoomJoinCompleteHandler extends HandlerBase {

    private final SFSExtension extension;

    public RoomJoinCompleteHandler(SFSExtension extension) { this.extension = extension; }

    @Override
    protected String command() { return "roomjoincomplete"; }

    @Override
    protected ISFSObject handle(User user, ISFSObject params) {
        // Echo immediately so client's pending requestData callback resolves.
        extension.send(command(), new SFSObject(), user);

        // Push role bitmap. Reads from UserVariable; falls back to all-zero.
        String roles = RoleBitset.allKnown();
        try {
            var rolesVar = user.getVariable(VariableNames.UV_ROLES);
            if (rolesVar != null && rolesVar.getStringValue() != null && !rolesVar.getStringValue().isBlank()) {
                roles = rolesVar.getStringValue();
            }
        } catch (Exception ignored) {}
        ISFSObject rolesPush = new ResponseBuilder().putStr("roles", roles).build();
        extension.send("roles", rolesPush, user);

        return null; // suppress duplicate auto-reply from HandlerBase
    }
}
