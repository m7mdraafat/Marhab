package com.hara.protocol.presenter;

import com.hara.Constants;
import com.hara.domain.model.Account;
import com.hara.domain.model.Avatar;
import com.hara.domain.model.Place;
import com.hara.protocol.framework.ResponseBuilder;
import com.hara.protocol.wire.ServerEnvelope;
import com.hara.protocol.wire.WireBlocks;
import com.smartfoxserver.v2.entities.data.ISFSArray;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSArray;
import com.smartfoxserver.v2.entities.data.SFSObject;

/**
 * Builds the two wire shapes returned by the {@code init} handler. Field
 * set + ordering verified against the live Marhab transcript captured in
 * {@code docs/protocol-sniffed.md}.
 *
 * <p>The two cases mirror {@code Sanalika.process()} on the client:
 * <ul>
 *   <li>{@link #needsBaseCloth(Account)} — no avatar yet; sends
 *       {@code checkAvatar=1, createAvatar=true} which opens
 *       AvatarCreatePanel in create mode.</li>
 *   <li>{@link #ready(Account, Avatar, Place)} — returning player; carries
 *       wallet / clothes / room.map / universe so the client can spawn
 *       directly without an extra handshake.</li>
 * </ul>
 */
public final class InitResponsePresenter {

    private InitResponsePresenter() {}

    /**
     * Brand-new account, no avatar. The client opens AvatarCreatePanel in
     * its create branch which shows the name input pre-filled with the
     * localized "Jack The One" placeholder.
     */
    public static ISFSObject needsBaseCloth(Account account) {
        long placeholderAvatarId = account.id();
        String placeholderName   = Constants.GUEST_NAME_PREFIX + placeholderAvatarId;

        return new ResponseBuilder()
            .putInt ("rid",                ServerEnvelope.nextRid())
            .putLong("ts",                 ServerEnvelope.nowSec())
            .putLong("accountId",          account.id())
            .putLong("selectedAvatarID",   placeholderAvatarId)
            .putStr ("avatarName",         placeholderName)
            .putInt ("checkAvatar",        1)
            .putBool("createAvatar",       true)
            .putBool("guest",              false)
            .putBool("isBanned",           false)
            .putInt ("emailActive",        0)
            .putInt ("tutorialStep",       0)
            .putStr ("gender",             "m")
            .putInt ("completedAchievementsCount", 0)
            .putArr ("extensionInfo",      extensionInfo())
            .putArr ("bans",               new SFSArray())
            .putArr ("campaigns",          new SFSArray())
            .putObj ("settings",           AvatarSettingsCodec.defaults())
            .build();
    }

    /**
     * Returning player with an avatar. The caller is expected to have
     * already stamped the SFS room and joined the user before this reply
     * lands so the client's auto-join handler fires immediately after.
     */
    public static ISFSObject ready(Account account, Avatar avatar, Place starter, String starterDoorKey) {
        ISFSObject clothes = new SFSObject();
        clothes.putUtfString("type", "CLOTH");
        clothes.putSFSArray ("items", ClothesCodec.encodeItems(avatar.clothes()));

        return new ResponseBuilder()
            .putInt ("rid",                ServerEnvelope.nextRid())
            .putLong("ts",                 ServerEnvelope.nowSec())
            .putLong("accountId",          account.id())
            .putLong("selectedAvatarID",   avatar.id())
            .putStr ("playerID",           String.valueOf(avatar.id()))
            .putInt ("checkAvatar",        1)
            .putBool("createAvatar",       false)
            .putBool("guest",              account.email() == null)
            .putBool("isBanned",           false)
            .putInt ("emailActive",        account.email() == null ? 0 : 1)
            .putInt ("tutorialStep",       0)
            .putStr ("gender",             avatar.gender())
            .putStr ("email",              account.email() == null ? "" : account.email())
            .putInt ("completedAchievementsCount", avatar.completedAchievementsCount())
            .putArr ("extensionInfo",      extensionInfo())
            .putArr ("bans",               new SFSArray())
            .putArr ("campaigns",          new SFSArray())
            .putObj ("settings",           AvatarSettingsCodec.defaults())
            .putArr ("wallet",             WalletCodec.encode(avatar.wallet()))
            .putObj ("clothes",            clothes)
                .putObj ("room",               WireBlocks.room(starter, starterDoorKey))
            .putObj ("universe",           WireBlocks.universe())
            .build();
    }

    /**
     * The {@code extensionInfo} array tells the client which sub-extensions
     * exist on the server so it can route their messages. Live Marhab ships
     * {@code CursorExtension} and {@code SoundExtension}; we mirror the
     * shape so the client doesn't trip on a missing field, even though we
     * don't implement those extensions yet.
     */
    private static ISFSArray extensionInfo() {
        ISFSArray arr = new SFSArray();
        arr.addSFSObject(extEntry("CursorExtension"));
        arr.addSFSObject(extEntry("SoundExtension"));
        return arr;
    }

    private static ISFSObject extEntry(String name) {
        ISFSObject prop = new SFSObject();
        prop.putUtfString("cn", "");
        ISFSObject e = new SFSObject();
        e.putUtfString("name", name);
        e.putSFSObject("property", prop);
        return e;
    }
}
