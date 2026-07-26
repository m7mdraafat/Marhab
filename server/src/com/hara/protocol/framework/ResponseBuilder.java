package com.hara.protocol.framework;

import java.util.List;
import java.util.Map;

import com.smartfoxserver.v2.entities.data.ISFSArray;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSArray;
import com.smartfoxserver.v2.entities.data.SFSObject;

/**
 * Fluent builder over {@link ISFSObject}. Keeps handler code readable —
 * no per-field {@code obj.putUtfString} chain. Build returns the underlying
 * object so it can be passed straight into {@link HandlerBase#send}.
 */
public final class ResponseBuilder {

    private final ISFSObject obj;

    public ResponseBuilder() { this.obj = new SFSObject(); }
    public ResponseBuilder(ISFSObject backing) { this.obj = backing; }

    public static ResponseBuilder ok()  { return new ResponseBuilder().putBool("ok", true); }
    public static ResponseBuilder of(ISFSObject backing) { return new ResponseBuilder(backing); }

    public ResponseBuilder putStr(String k, String v)   { obj.putUtfString(k, v); return this; }
    public ResponseBuilder putInt(String k, int v)      { obj.putInt(k, v); return this; }
    public ResponseBuilder putLong(String k, long v)    { obj.putLong(k, v); return this; }
    public ResponseBuilder putBool(String k, boolean v) { obj.putBool(k, v); return this; }
    public ResponseBuilder putDouble(String k, double v){ obj.putDouble(k, v); return this; }
    public ResponseBuilder putObj(String k, ISFSObject v) { obj.putSFSObject(k, v); return this; }
    public ResponseBuilder putArr(String k, ISFSArray v) { obj.putSFSArray(k, v); return this; }

    /** Convenience: put an int array as an SFSArray of ints. */
    public ResponseBuilder putIntArr(String k, int[] v) {
        ISFSArray arr = new SFSArray();
        for (int i : v) arr.addInt(i);
        obj.putSFSArray(k, arr);
        return this;
    }

    /** Convenience: put a list of strings as an SFSArray of UTF strings. */
    public ResponseBuilder putStrArr(String k, List<String> v) {
        ISFSArray arr = new SFSArray();
        for (String s : v) arr.addUtfString(s);
        obj.putSFSArray(k, arr);
        return this;
    }

    /** Put an empty SFSArray at {@code k} — common for "no items yet" stubs. */
    public ResponseBuilder putEmptyArr(String k) {
        obj.putSFSArray(k, new SFSArray());
        return this;
    }

    /** Put an empty SFSObject at {@code k}. */
    public ResponseBuilder putEmptyObj(String k) {
        obj.putSFSObject(k, new SFSObject());
        return this;
    }

    /**
     * Generic untyped putter. Resolves {@link Map}, {@link List}, primitives,
     * and {@link ISFSObject}/{@link ISFSArray} to the correct SFS API call.
     * Use sparingly — prefer the typed methods above.
     */
    @SuppressWarnings({"unchecked", "rawtypes"})
    public ResponseBuilder putAny(String k, Object v) {
        if (v == null) { obj.putNull(k); return this; }
        if (v instanceof String)     { obj.putUtfString(k, (String) v); return this; }
        if (v instanceof Integer)    { obj.putInt(k, (Integer) v); return this; }
        if (v instanceof Long)       { obj.putLong(k, (Long) v); return this; }
        if (v instanceof Boolean)    { obj.putBool(k, (Boolean) v); return this; }
        if (v instanceof Double)     { obj.putDouble(k, (Double) v); return this; }
        if (v instanceof Float)      { obj.putFloat(k, (Float) v); return this; }
        if (v instanceof ISFSObject) { obj.putSFSObject(k, (ISFSObject) v); return this; }
        if (v instanceof ISFSArray)  { obj.putSFSArray(k, (ISFSArray) v); return this; }
        if (v instanceof Map) {
            ISFSObject inner = new SFSObject();
            ResponseBuilder rb = new ResponseBuilder(inner);
            for (Map.Entry e : ((Map<?, ?>) v).entrySet()) rb.putAny(String.valueOf(e.getKey()), e.getValue());
            obj.putSFSObject(k, inner);
            return this;
        }
        if (v instanceof List) {
            ISFSArray inner = new SFSArray();
            for (Object item : (List) v) addAny(inner, item);
            obj.putSFSArray(k, inner);
            return this;
        }
        obj.putUtfString(k, String.valueOf(v));
        return this;
    }

    @SuppressWarnings({"unchecked", "rawtypes"})
    private static void addAny(ISFSArray arr, Object v) {
        if (v == null) { arr.addNull(); return; }
        if (v instanceof String)     { arr.addUtfString((String) v); return; }
        if (v instanceof Integer)    { arr.addInt((Integer) v); return; }
        if (v instanceof Long)       { arr.addLong((Long) v); return; }
        if (v instanceof Boolean)    { arr.addBool((Boolean) v); return; }
        if (v instanceof Double)     { arr.addDouble((Double) v); return; }
        if (v instanceof ISFSObject) { arr.addSFSObject((ISFSObject) v); return; }
        if (v instanceof ISFSArray)  { arr.addSFSArray((ISFSArray) v); return; }
        if (v instanceof Map) {
            ISFSObject inner = new SFSObject();
            ResponseBuilder rb = new ResponseBuilder(inner);
            for (Map.Entry e : ((Map<?, ?>) v).entrySet()) rb.putAny(String.valueOf(e.getKey()), e.getValue());
            arr.addSFSObject(inner);
            return;
        }
        if (v instanceof List) {
            ISFSArray inner = new SFSArray();
            for (Object item : (List) v) addAny(inner, item);
            arr.addSFSArray(inner);
            return;
        }
        arr.addUtfString(String.valueOf(v));
    }

    public ISFSObject build() { return obj; }
}
