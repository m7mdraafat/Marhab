package com.hara.domain.auth;

import java.util.Base64;

import com.hara.domain.enums.AvatarPermission;

/**
 * Encodes the client's {@code com.oyunstudyosu.auth.Permission} bitmap.
 *
 * <p>The AS3 client stores permissions as a little-endian byte array, with
 * permission index {@code n} mapped by:
 * <pre>
 *   byteIndex = ceil(n / 8) - 1
 *   bitIndex  = n % 8 - 1; if -1 then bit 7
 * </pre>
 * The resulting bytes are base64-encoded into the {@code roles} UserVariable
 * and into the {@code roles{roles:"..."}} extension push.
 */
public final class RoleBitset {

    private static final int MAX_KNOWN_PERMISSION = AvatarPermission.STAGE;

    private RoleBitset() {}

    /** Grant every known role/card/permission used by the decompiled client. */
    public static String allKnown() {
        byte[] data = new byte[(int) Math.ceil(MAX_KNOWN_PERMISSION / 8.0)];
        for (int i = 1; i <= MAX_KNOWN_PERMISSION; i++) grant(data, i);
        return Base64.getEncoder().encodeToString(data);
    }

    /** Production-like all-zero roles value. */
    public static String none() {
        return "AA==";
    }

    private static void grant(byte[] data, int permissionIndex) {
        int byteIndex = (int) Math.ceil(permissionIndex / 8.0) - 1;
        int bitIndex = permissionIndex % 8 - 1;
        if (bitIndex == -1) bitIndex = 7;
        data[byteIndex] = (byte) (data[byteIndex] | (1 << bitIndex));
    }
}
