package com.hara.protocol.presenter;

import java.util.List;

import com.hara.domain.model.ClothItem;
import com.smartfoxserver.v2.entities.data.ISFSArray;
import com.smartfoxserver.v2.entities.data.SFSArray;
import com.smartfoxserver.v2.entities.data.SFSObject;

/**
 * Wire-shape codec for the {@code clothes.items} field of the init reply.
 * The client's {@code ClothModel.load(param1:Object)} iterates an Array of
 * objects and constructs a {@code Cloth} per entry, reading
 * {@code id, quantity, active, base, clip, lifeTime, timeLeft}. The
 * {@code clip} value is concatenated as {@code gender + "_" + clip} to
 * form the lookup key against the loaded SWFs.
 *
 * <p>We send an Array of {@link com.smartfoxserver.v2.entities.data.SFSObject}
 * (NOT a JSON-encoded string) so {@code for each} iterates properly on the
 * client. Sending a string causes silent no-op — the avatar renders naked.
 *
 * <p>Defaults applied for fields the domain model doesn't track yet:
 * {@code quantity=1, active=true, base=true, lifeTime=-1, timeLeft=-1}.
 * {@code id} is synthesized from the stable position so subsequent loads
 * are idempotent.
 */
public final class ClothesCodec {

    private ClothesCodec() {}

    public static ISFSArray encodeItems(List<ClothItem> clothes) {
        ISFSArray out = new SFSArray();
        if (clothes == null) return out;
        int idx = 1;
        for (ClothItem c : clothes) {
            SFSObject row = new SFSObject();
            row.putInt("id",        idx++);
            row.putInt("quantity",  1);
            row.putBool("active",   true);
            row.putBool("base",     true);
            row.putUtfString("clip", c.clip());
            if (c.hasColor()) row.putInt("color", c.color());
            row.putInt("lifeTime", -1);
            row.putInt("timeLeft", -1);
            out.addSFSObject(row);
        }
        return out;
    }
}
