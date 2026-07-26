package com.hara.protocol.handlers.boot;

import com.hara.protocol.framework.HandlerBase;
import com.hara.protocol.framework.ResponseBuilder;
import com.smartfoxserver.v2.entities.User;
import com.smartfoxserver.v2.entities.data.ISFSObject;

/**
 * Reusable stub that replies with a top-level array under a configurable
 * key (default {@code items}). The same instance can be registered under
 * many commands; the array is always empty. Used for {@code buddylist},
 * {@code orderlist}, {@code privatechatlist}, {@code questlist}, etc.,
 * so the client clears those callbacks and HUD widgets show "you have nothing"
 * rather than spinners.
 */
public final class EmptyListHandler extends HandlerBase {

    private final String command;
    private final String arrayKey;

    public EmptyListHandler(String command) { this(command, "items"); }

    public EmptyListHandler(String command, String arrayKey) {
        this.command  = command;
        this.arrayKey = arrayKey;
    }

    @Override
    protected String command() { return command; }

    @Override
    protected ISFSObject handle(User user, ISFSObject params) {
        return new ResponseBuilder().putEmptyArr(arrayKey).build();
    }
}
