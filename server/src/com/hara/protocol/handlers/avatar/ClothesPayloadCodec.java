package com.hara.protocol.handlers.avatar;

import java.util.ArrayList;
import java.util.List;

import com.hara.domain.model.ClothItem;
import com.hara.protocol.framework.BadRequestException;
import com.hara.protocol.framework.ServiceErrorCode;
import com.smartfoxserver.v2.entities.data.ISFSArray;
import com.smartfoxserver.v2.entities.data.ISFSObject;

/**
 * Decodes the {@code clothes:[{clip,color?},...]} array AvatarCreatePanel
 * sends in {@code savebaseclothes} and {@code avatarcreate} (see
 * {@code docs/11 §11.3 Step B}). Centralized here so future cloth-mutating
 * handlers (e.g. {@code changeclothes}) reuse the same validation.
 */
public final class ClothesPayloadCodec {

    private ClothesPayloadCodec() {}

    public static List<ClothItem> decode(ISFSObject params, String fieldName) {
        ISFSArray arr = params.getSFSArray(fieldName);
        if (arr == null) {
            throw new BadRequestException(ServiceErrorCode.MISSING_PARAMETER,
                "Missing required parameter: " + fieldName);
        }
        List<ClothItem> out = new ArrayList<>(arr.size());
        for (int i = 0; i < arr.size(); i++) {
            ISFSObject o = arr.getSFSObject(i);
            if (o == null) {
                throw new BadRequestException(ServiceErrorCode.WRONG_PARAMETER,
                    fieldName + "[" + i + "] is not an object");
            }
            String clip = o.getUtfString("clip");
            if (clip == null || clip.isBlank()) {
                throw new BadRequestException(ServiceErrorCode.WRONG_PARAMETER,
                    fieldName + "[" + i + "].clip missing");
            }
            Integer color = o.containsKey("color") ? o.getInt("color") : null;
            out.add(new ClothItem(clip, color));
        }
        return out;
    }
}
