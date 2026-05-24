package com.hara.extension.events;

import com.smartfoxserver.v2.core.ISFSEvent;
import com.smartfoxserver.v2.core.SFSEventParam;
import com.smartfoxserver.v2.core.SFSEventType;
import com.smartfoxserver.v2.entities.Room;
import com.smartfoxserver.v2.entities.User;
import com.smartfoxserver.v2.entities.Zone;
import com.smartfoxserver.v2.exceptions.SFSException;
import com.smartfoxserver.v2.extensions.BaseServerEventHandler;

/**
 * Bumps the privilegeId of every user that joins the zone to 1 (Moderator)
 * AND auto-joins them to {@link MyGameExtension#DEFAULT_LOBBY}.
 *
 * Why elevate: Sanalika.onVersionFileLoaded() refuses to call initialize()
 * if {@code privilegeId == 0 && !avatarModel.guest}. It tries to open a
 * GuestPanel SWF we don't ship, and the bootstrap stalls.
 *
 * Why auto-join: RoomController.onJoinRoom is what eventually triggers
 * roomModel.startload() -> scene render -> ProgressView splash hides.
 * Without a SFS Room join the splash stays at INIT_READY (70%) forever
 * after the avatar-create flow completes.
 */
public class UserLifecycleHandler extends BaseServerEventHandler {

    @Override
    public void handleServerEvent(ISFSEvent event) throws SFSException {
        trace("ElevatePrivilege: event=" + event.getType());
        User user = (User) event.getParameter(SFSEventParam.USER);
        if (user == null) {
            trace("ElevatePrivilege: user param null on " + event.getType());
            return;
        }
        elevate(user);
        // NOTE: auto-join was moved to InitHandler. Joining a room here
        // (USER_JOIN_ZONE) delivers the ROOM_JOIN event before the client's
        // RoomController has registered its `roomJoin` listener (that happens
        // inside Sanalika.initCommandsCompleted, AFTER the init reply), so
        // the event is silently dropped and the splash stalls at INIT_READY.
    }

    private void elevate(User user) {
        try {
            user.setPrivilegeId((short) 1);
            try {
                getApi().getClass().getMethod("changeUserPrivilege",
                    com.smartfoxserver.v2.entities.User.class, short.class)
                    .invoke(getApi(), user, (short) 1);
                trace("ElevatePrivilege: notified client via changeUserPrivilege");
            } catch (NoSuchMethodException nsme) {
                trace("ElevatePrivilege: changeUserPrivilege not in API, set-only");
            }
            trace("ElevatePrivilege: " + user.getName() + " -> 1 (Moderator)");
        } catch (Exception e) {
            trace("ElevatePrivilege failed for " + user.getName() + ": " + e.getMessage());
        }
    }
}
