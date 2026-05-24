package com.hara.protocol.framework;

import com.smartfoxserver.v2.entities.data.ISFSArray;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSArray;
import com.smartfoxserver.v2.entities.data.SFSObject;

/**
 * Fluent builder for response {@link ISFSObject} payloads. Removes the
 * boilerplate of constructing + chaining putUtfString/putInt/putSFSObject.
 *
 * Example:
 *   ISFSObject r = ResponseBuilder.ok()
 *       .str("avatarID", "1")
 *       .obj("wallet", ResponseBuilder.empty().str("currency", "SANIL").build())
 *       .build();
 */
public final class ResponseBuilder {
    private final ISFSObject obj;

    private ResponseBuilder(ISFSObject delegate) { this.obj = delegate; }

    public static ResponseBuilder empty() { return new ResponseBuilder(new SFSObject()); }
    public static ResponseBuilder ok()    { return empty().bool("ok", true); }
    public static ResponseBuilder error(int code, String message) {
        return empty().bool("ok", false).intv("errorCode", code).str("message", message);
    }

    public ResponseBuilder str (String k, String v)  { obj.putUtfString(k, v); return this; }
    public ResponseBuilder intv(String k, int v)     { obj.putInt(k, v);       return this; }
    public ResponseBuilder lng (String k, long v)    { obj.putLong(k, v);      return this; }
    public ResponseBuilder bool(String k, boolean v) { obj.putBool(k, v);      return this; }
    public ResponseBuilder obj (String k, ISFSObject v) { obj.putSFSObject(k, v); return this; }
    public ResponseBuilder arr (String k, ISFSArray v)  { obj.putSFSArray(k, v);  return this; }

    /** Empty array shortcut for "no data, here's the empty list" responses. */
    public ResponseBuilder emptyArr(String k) { obj.putSFSArray(k, new SFSArray()); return this; }

    public ISFSObject build() { return obj; }
}
