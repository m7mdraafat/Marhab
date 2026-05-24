package com.hara.protocol.framework;

import com.smartfoxserver.v2.entities.data.ISFSArray;
import com.smartfoxserver.v2.entities.data.ISFSObject;

/**
 * Typed accessors over {@link ISFSObject}. Centralizes the null-checks that
 * would otherwise litter every handler.
 *
 * Two flavors per type:
 *   req*(p, key)             throws BadRequestException if absent
 *   opt*(p, key, fallback)   returns fallback if absent or p is null
 */
public final class SfsObjectMapper {
    private SfsObjectMapper() {}

    public static String  reqStr (ISFSObject p, String k) { mustHave(p, k, "string"); return p.getUtfString(k); }
    public static int     reqInt (ISFSObject p, String k) { mustHave(p, k, "int");    return p.getInt(k); }
    public static long    reqLong(ISFSObject p, String k) { mustHave(p, k, "long");   return p.getLong(k); }
    public static boolean reqBool(ISFSObject p, String k) { mustHave(p, k, "bool");   return p.getBool(k); }
    public static ISFSArray  reqArr(ISFSObject p, String k) { mustHave(p, k, "array");  return p.getSFSArray(k); }
    public static ISFSObject reqObj(ISFSObject p, String k) { mustHave(p, k, "object"); return p.getSFSObject(k); }

    public static String  optStr (ISFSObject p, String k, String fb)  { return (p != null && p.containsKey(k)) ? p.getUtfString(k) : fb; }
    public static int     optInt (ISFSObject p, String k, int fb)     { return (p != null && p.containsKey(k)) ? p.getInt(k)       : fb; }
    public static long    optLong(ISFSObject p, String k, long fb)    { return (p != null && p.containsKey(k)) ? p.getLong(k)      : fb; }
    public static boolean optBool(ISFSObject p, String k, boolean fb) { return (p != null && p.containsKey(k)) ? p.getBool(k)      : fb; }

    private static void mustHave(ISFSObject p, String k, String typeLabel) {
        if (p == null || !p.containsKey(k)) {
            throw new BadRequestException("missing " + typeLabel + " '" + k + "'");
        }
    }
}
