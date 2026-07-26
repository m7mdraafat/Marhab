package com.hara.protocol.handlers.avatar;

import java.util.List;

import com.hara.domain.enums.Gender;
import com.hara.domain.model.BaseClothOption;
import com.hara.protocol.framework.HandlerBase;
import com.hara.protocol.framework.ResponseBuilder;
import com.hara.service.avatar.ClothCatalog;
import com.smartfoxserver.v2.entities.User;
import com.smartfoxserver.v2.entities.data.ISFSArray;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSArray;
import com.smartfoxserver.v2.entities.data.SFSObject;

/**
 * Returns the catalog of starter outfits the AvatarCreatePanel iterates
 * through. Wire shape from {@code docs/11 §11.3 Step A}:
 *
 * <pre>
 * { "f": [ {"placeBit":N,"clip":"...","colors":[...]} , ... ],
 *   "m": [  ... ] }
 * </pre>
 *
 * <p>Each entry's {@code clip} MUST resolve to a real SWF under
 * {@code server/www/global/static/items/clothes/}. The current
 * {@link ClothCatalog} is hand-curated against the bulk asset mirror;
 * verify after every {@code rebuild/build-www.ps1} run.
 */
public final class BaseClothesHandler extends HandlerBase {

    private final ClothCatalog catalog;

    public BaseClothesHandler(ClothCatalog catalog) { this.catalog = catalog; }

    @Override
    protected String command() { return "baseclothes"; }

    @Override
    protected ISFSObject handle(User user, ISFSObject params) {
        return new ResponseBuilder()
            .putArr("f", asArray(catalog.optionsFor(Gender.FEMALE)))
            .putArr("m", asArray(catalog.optionsFor(Gender.MALE)))
            .build();
    }

    private static ISFSArray asArray(List<BaseClothOption> options) {
        ISFSArray arr = new SFSArray();
        for (BaseClothOption opt : options) {
            ISFSObject o = new SFSObject();
            o.putInt("placeBit", opt.placeBit());
            o.putUtfString("clip", opt.clip());
            if (opt.hasColors()) {
                ISFSArray colors = new SFSArray();
                for (int c : opt.colors()) colors.addInt(c);
                o.putSFSArray("colors", colors);
            }
            arr.addSFSObject(o);
        }
        return arr;
    }
}
