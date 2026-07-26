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
 * Full avatar create — the "registered account, finish onboarding" path
 * (vs the {@link SaveBaseClothesHandler} guest fast-path). Same persistence
 * + reply contract, but accepts the optional {@code token} field
 * AvatarCreatePanel forwards for verification.
 */
public final class AvatarCreateHandler extends HandlerBase {

    private final AccountService accounts;
    private final AvatarService avatars;

    public AvatarCreateHandler(AccountService accounts, AvatarService avatars) {
        this.accounts = accounts;
        this.avatars  = avatars;
    }

    @Override
    protected String command() { return "avatarcreate"; }

    @Override
    protected ISFSObject handle(User user, ISFSObject params) {
        long accountId = UserSession.accountId(user).orElseThrow();
        Account account = accounts.requireById(accountId);

        String gender = SfsObjectMapper.reqStr(params, "gender");
        String name   = SfsObjectMapper.reqStr(params, "avatarName");
        // token: optional today — verify against account.token() when auth is real
        SfsObjectMapper.optStr(params, "token", "");
        List<ClothItem> clothes = ClothesPayloadCodec.decode(params, "clothes");

        Avatar avatar = avatars.create(account, name.trim(), gender, clothes, false);
        UserSession.setAvatarId(user, avatar.id());
        AuditLog.info("avatar.create", accountId, "avatarId=" + avatar.id() + " name=" + name);

        return new ResponseBuilder().putLong("avatarID", avatar.id()).build();
    }
}
