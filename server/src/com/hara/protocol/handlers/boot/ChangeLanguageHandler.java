package com.hara.protocol.handlers.boot;

import com.hara.infra.audit.AuditLog;
import com.hara.protocol.framework.HandlerBase;
import com.hara.protocol.framework.ResponseBuilder;
import com.hara.service.auth.UserSession;
import com.smartfoxserver.v2.entities.User;
import com.smartfoxserver.v2.entities.data.ISFSObject;

/**
 * Change UI language. Sniffed shape:
 * request {@code {language:"en"}} → reply
 * {@code {language:"en", langFile:"locale/en_UK.1", success:true}}.
 *
 * The client downloads the new .mo file from the CDN at {@code /static/<langFile>.mo}
 * and reloads the UI. We don't persist the choice yet.
 */
public final class ChangeLanguageHandler extends HandlerBase {

    @Override
    protected String command() { return "changelanguage"; }

    @Override
    protected ISFSObject handle(User user, ISFSObject params) {
        String lang = params.containsKey("language") ? params.getUtfString("language") : "ar";
        String langFile;
        if ("en".equals(lang))      langFile = "locale/en_UK.1";
        else if ("tr".equals(lang)) langFile = "locale/tr.1";
        else                        langFile = "locale/ar.1";
        AuditLog.info("user.lang", UserSession.avatarId(user).orElse(0L), "lang=" + lang);
        return new ResponseBuilder()
            .putStr ("language", lang)
            .putStr ("langFile", langFile)
            .putBool("success",  true)
            .build();
    }
}
