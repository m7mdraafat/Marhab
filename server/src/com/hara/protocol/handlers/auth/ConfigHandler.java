package com.hara.protocol.handlers.auth;

import com.hara.infra.config.HaraConfig;
import com.hara.protocol.framework.HandlerBase;
import com.hara.protocol.framework.ResponseBuilder;
import com.smartfoxserver.v2.entities.User;
import com.smartfoxserver.v2.entities.data.ISFSArray;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSArray;
import com.smartfoxserver.v2.entities.data.SFSObject;

/**
 * Handles the very first extension request after login: {@code config}.
 * Returns the data {@code ConfigCommand.responseFunction} reads
 * unconditionally — see {@code docs/02-bootstrap.md §2.4} for the exact
 * fields. Missing any required field causes the splash to wedge with a
 * client-side NPE, so we send EVERY field even when empty/zero.
 *
 * <p>Wire shape:
 * <pre>
 * {
 *   "fileServer":[ "127.0.0.1:8081" ],      // host:port, no scheme
 *   "itemFile":   "data/ifile.1366",        // client prepends /static/
 *   "versionFile":"data/vf.403",
 *   "langFile":   "locale/ar",              // client appends .mo
 *   "webServer":  "",
 *   "language":   "ar",
 *   "moods":      [...],                     // BuddyMoods catalog
 *   "chatBaloons":[...],                     // chat-bubble color presets
 *   "masterRoles":[...],                     // role -> error-text overrides
 *   "farmCleaningCost": 0,
 *   "farmMaxPlantedItemSize": 0,
 *   "order": { "avatarOrderLifeTime":0, "orderLifeTime":0, "prepareLifeTime":0 }
 * }
 * </pre>
 */
public final class ConfigHandler extends HandlerBase {

    private final HaraConfig config;

    public ConfigHandler(HaraConfig config) {
        this.config = config;
    }

    @Override
    protected String command() { return "config"; }

    @Override
    protected ISFSObject handle(User user, ISFSObject params) {
        ISFSArray fileServer = new SFSArray();
        fileServer.addUtfString(config.cdnHost());

        return new ResponseBuilder()
            .putArr("fileServer", fileServer)
            .putStr("itemFile",    config.itemFilePath())
            .putStr("versionFile", config.versionFilePath())
            .putStr("langFile",    config.defaultLocaleFile())
            .putStr("webServer",   "")
            .putStr("language",    "ar")
            .putArr("moods",        Moods.array())
            .putArr("chatBaloons",  ChatBalloons.array())
            .putArr("masterRoles",  new SFSArray())
            // Seasonal theme tags (e.g. "snow", "christmas", "hallowen"). Room
            // SWFs like {@code street01::bg} call {@code roomTheme.indexOf(...)}
            // unconditionally — null here means Error #1009 inside bg.init()
            // and the entire scene fails to render. The captured street01
            // map XML declared {@code themes="snow"} so we expose that tag
            // to keep snowy variants from popping art with missing assets.
            .putArr("roomTheme",    snowTheme())
            .putInt("farmCleaningCost",        50)
            .putInt("farmMaxPlantedItemSize",  20)
            .putObj("order", defaultOrderConfig())
            .build();
    }

    private static ISFSObject defaultOrderConfig() {
        ISFSObject o = new SFSObject();
        o.putInt("avatarOrderLifeTime", 86400);
        o.putInt("orderLifeTime",       3600);
        o.putInt("prepareLifeTime",     1800);
        return o;
    }

    private static ISFSArray snowTheme() {
        ISFSArray arr = new SFSArray();
        arr.addUtfString("snow");
        return arr;
    }
}
