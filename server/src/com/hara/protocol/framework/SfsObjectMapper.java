package com.hara.protocol.framework;

import com.smartfoxserver.v2.entities.data.ISFSArray;
import com.smartfoxserver.v2.entities.data.ISFSObject;

/**
 * Typed accessors over {@link ISFSObject}. {@code reqXxx} throw
 * {@link BadRequestException} on missing/wrong type (caught and translated
 * to an error envelope by {@link HandlerBase}). {@code optXxx} return a
 * default. Centralizing this prevents every handler from re-implementing
 * {@code containsKey + getX} dances.
 */
public final class SfsObjectMapper {

    private SfsObjectMapper() {}

    public static String reqStr(ISFSObject obj, String key) {
        if (obj == null || !obj.containsKey(key)) throw BadRequestException.missing(key);
        String v = obj.getUtfString(key);
        if (v == null) throw BadRequestException.missing(key);
        return v;
    }

    public static String optStr(ISFSObject obj, String key, String fallback) {
        if (obj == null || !obj.containsKey(key)) return fallback;
        String v = obj.getUtfString(key);
        return v == null ? fallback : v;
    }

    public static int reqInt(ISFSObject obj, String key) {
        if (obj == null || !obj.containsKey(key)) throw BadRequestException.missing(key);
        try { return obj.getInt(key); }
        catch (Exception e) { throw BadRequestException.wrongType(key, "int"); }
    }

    public static int optInt(ISFSObject obj, String key, int fallback) {
        if (obj == null || !obj.containsKey(key)) return fallback;
        try { return obj.getInt(key); } catch (Exception e) { return fallback; }
    }

    public static long reqLong(ISFSObject obj, String key) {
        if (obj == null || !obj.containsKey(key)) throw BadRequestException.missing(key);
        try { return obj.getLong(key); }
        catch (Exception e) { throw BadRequestException.wrongType(key, "long"); }
    }

    public static boolean reqBool(ISFSObject obj, String key) {
        if (obj == null || !obj.containsKey(key)) throw BadRequestException.missing(key);
        try { return obj.getBool(key); }
        catch (Exception e) { throw BadRequestException.wrongType(key, "bool"); }
    }

    public static boolean optBool(ISFSObject obj, String key, boolean fallback) {
        if (obj == null || !obj.containsKey(key)) return fallback;
        try { return obj.getBool(key); } catch (Exception e) { return fallback; }
    }

    public static ISFSObject reqObj(ISFSObject obj, String key) {
        if (obj == null || !obj.containsKey(key)) throw BadRequestException.missing(key);
        ISFSObject v = obj.getSFSObject(key);
        if (v == null) throw BadRequestException.missing(key);
        return v;
    }

    public static ISFSObject optObj(ISFSObject obj, String key) {
        if (obj == null || !obj.containsKey(key)) return null;
        return obj.getSFSObject(key);
    }

    public static ISFSArray reqArr(ISFSObject obj, String key) {
        if (obj == null || !obj.containsKey(key)) throw BadRequestException.missing(key);
        ISFSArray v = obj.getSFSArray(key);
        if (v == null) throw BadRequestException.missing(key);
        return v;
    }

    public static ISFSArray optArr(ISFSObject obj, String key) {
        if (obj == null || !obj.containsKey(key)) return null;
        return obj.getSFSArray(key);
    }
}
