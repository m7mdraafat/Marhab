package com.hara.protocol.handlers.avatar;

import java.util.List;

import com.hara.domain.model.Account;
import com.hara.domain.model.Avatar;
import com.hara.domain.model.ClothItem;
import com.hara.infra.audit.AuditLog;
import com.hara.protocol.framework.HandlerBase;
import com.hara.protocol.framework.ResponseBuilder;
import com.hara.protocol.framework.SfsObjectMapper;
import com.hara.service.auth.AccountService;
import com.hara.service.auth.UserSession;
import com.hara.service.avatar.AvatarService;
import com.smartfoxserver.v2.entities.User;
import com.smartfoxserver.v2.entities.data.ISFSObject;

/**
 * Completes step C of {@code docs/11 §11.3}: the "BaseCloth" finalize call
 * from AvatarCreatePanel when the user is restricted to picking a starter
 * outfit only (no full create — guest fast-path).
 *
 * <p>Wire shape in: {@code { clothes:[{clip,color?},...], gender, avatarName }}.
 * Wire shape out: {@code { avatarID }} on success — the client immediately
 * runs {@code Connectr.reset()} to re-bootstrap with the new avatar.
 */
public final class SaveBaseClothesHandler extends HandlerBase {

    private final AccountService accounts;
    private final AvatarService avatars;

    public SaveBaseClothesHandler(AccountService accounts, AvatarService avatars) {
        this.accounts = accounts;
        this.avatars  = avatars;
    }

    @Override
    protected String command() { return "savebaseclothes"; }

    @Override
    protected ISFSObject handle(User user, ISFSObject params) {
        long accountId = UserSession.accountId(user).orElseThrow();
        Account account = accounts.requireById(accountId);

        String gender = SfsObjectMapper.reqStr(params, "gender");
        String name   = SfsObjectMapper.reqStr(params, "avatarName");
        List<ClothItem> clothes = ClothesPayloadCodec.decode(params, "clothes");

        Avatar avatar = avatars.create(account, name.trim(), gender, clothes, true);
        UserSession.setAvatarId(user, avatar.id());
        AuditLog.info("avatar.create-base", accountId, "avatarId=" + avatar.id() + " name=" + name);

        return new ResponseBuilder().putLong("avatarID", avatar.id()).build();
    }
}
