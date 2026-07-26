package com.hara.protocol.handlers.boot;

import com.hara.protocol.framework.HandlerBase;
import com.hara.protocol.framework.ResponseBuilder;
import com.smartfoxserver.v2.entities.User;
import com.smartfoxserver.v2.entities.data.ISFSArray;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSArray;
import com.smartfoxserver.v2.entities.data.SFSObject;

/**
 * Returns the catalog of supported UI languages. Wire shape (sniffed):
 * <pre>{ currentLanguage:"ar", languages:[{code:str, name:str}, ...] }</pre>
 *
 * The client uses this to populate the language picker in Settings.
 */
public final class GetLanguagesHandler extends HandlerBase {

    @Override
    protected String command() { return "getlanguages"; }

    @Override
    protected ISFSObject handle(User user, ISFSObject params) {
        ISFSArray langs = new SFSArray();
        langs.addSFSObject(lang("ar", "العربية"));
        langs.addSFSObject(lang("en", "English"));
        langs.addSFSObject(lang("tr", "Türkçe"));
        return new ResponseBuilder()
            .putArr("languages",       langs)
            .putStr("currentLanguage", "ar")
            .build();
    }

    private static ISFSObject lang(String code, String name) {
        ISFSObject o = new SFSObject();
        o.putUtfString("code", code);
        o.putUtfString("name", name);
        return o;
    }
}
