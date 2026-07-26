package com.hara.protocol.framework;

/**
 * Mirrors {@code com.oyunstudyosu.service.ServiceErrorCode.as}. The client
 * looks up {@code errorCode} strings in the localized message table — using
 * the wrong key shows an English fallback or no message at all. Add new
 * codes here as the matching client code is verified.
 *
 * <p>The numeric codes (e.g. 1, 12, 2002, 5000) and string codes
 * (e.g. {@code FLOOD}, {@code BUDDY_IS_NOT_ONLINE}) come from
 * {@code docs/05 §5.5}.
 */
public final class ServiceErrorCode {
    // numeric — sent as string for protocol consistency
    public static final String SERVICE_ERROR        = "0";
    public static final String SERVICE_METHOD_NF    = "1";
    public static final String AVATAR_NOT_FOUND     = "9";
    public static final String UNAUTHORIZED         = "10";
    public static final String WRONG_PARAMETER      = "11";
    public static final String MISSING_PARAMETER    = "12";
    public static final String PERSON_NOT_FOUND     = "16";
    public static final String SCRIPT_ERROR         = "17";
    public static final String INVALID_ITEM_ID      = "18";
    public static final String MESSAGING_EXCEPTION  = "19";
    public static final String JSON_EXCEPTION       = "20";
    public static final String SERVICE_NOT_FOUND    = "22";
    public static final String NOT_ENOUGH_DIAMOND   = "2002";
    public static final String NOT_ENOUGH_SANIL     = "2003";
    public static final String WRONG_ITEM           = "2008";
    public static final String WRONG_POSITION       = "2009";
    public static final String ALREADY_HAS_ITEM     = "2010";
    public static final String INSUFFICIENT_CREDITS = "5000";
    public static final String INSUFFICIENT_QTY     = "5001";
    public static final String WRONG_ITEM_TYPE      = "5002";
    public static final String INVALID_REQUEST      = "5003";

    // string keys
    public static final String FLOOD                = "FLOOD";
    public static final String EXTENSION_IDLE       = "EXTENSION_IDLE";
    public static final String SYSTEM_ERROR         = "SYSTEM_ERROR";
    public static final String INSUFFICIENT_ROLE    = "INSUFFICIENT_ROLE";
    public static final String INVALID_SECURITYKEY  = "INVALID_SECURITYKEY";
    public static final String BANNED_FROM_ROOM     = "BANNED_FROM_ROOM";
    public static final String ROOM_PASSWORD_WRONG  = "ROOM_PASSWORD_WRONG";
    public static final String ROOM_IS_FULL         = "ROOM_IS_FULL";
    public static final String GUEST_NOT_ALLOWED    = "GUEST_NOT_ALLOWED";
    public static final String MISSING_ITEM         = "MISSING_ITEM";

    private ServiceErrorCode() {}
}
