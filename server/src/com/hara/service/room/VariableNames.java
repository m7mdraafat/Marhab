package com.hara.service.room;

/**
 * Canonical SFS RoomVariable / UserVariable name constants. Every server
 * write goes through these (no magic strings in handlers) so renaming or
 * widening a key is one-touch. Mirrors the catalog in
 * {@code docs/03 §3.3 + §3.4}.
 */
public final class VariableNames {

    // ---- RoomVariables (server-set, broadcast to room members) ----
    public static final String RV_ROOM_KEY            = "roomKey";
    public static final String RV_TYPE                = "type";
    public static final String RV_TITLE               = "title";
    public static final String RV_ROOM_TITLE          = "roomTitle";
    public static final String RV_WIDTH               = "width";
    public static final String RV_HEIGHT              = "height";
    public static final String RV_GRID                = "grid";
    public static final String RV_DOORS               = "doors";
    public static final String RV_BOTS                = "bots";
    public static final String RV_EXTENSIONS          = "extensions";
    public static final String RV_OWNER_ID            = "ownerID";
    public static final String RV_OWNER_NAME          = "ownerName";
    public static final String RV_FLAT_ID             = "flatID";
    public static final String RV_ROOM_ID             = "roomID";
    public static final String RV_IS_INTERACTIVE_ROOM = "isInteractiveRoom";
    public static final String RV_SOURCE              = "source";
    public static final String RV_X_ORIGIN            = "xOrigin";
    public static final String RV_Y_ORIGIN            = "yOrigin";

    // ---- UserVariables (per-user; SFS auto-broadcasts on change) ----
    public static final String UV_POSITION       = "position";   // "x,y"
    public static final String UV_DIRECTION      = "direction";  // 1..8
    public static final String UV_TARGET         = "target";     // "x,y" while walking
    public static final String UV_SPEED          = "speed";      // double
    public static final String UV_STATUS         = "status";     // CharacterState
    public static final String UV_CLOTHES        = "clothes";    // JSON
    public static final String UV_GENDER         = "gender";     // "m"/"f"
    public static final String UV_AVATAR_NAME    = "avatarName";
    public static final String UV_AVATAR_SIZE    = "avatarSize"; // VIP scale
    public static final String UV_NAME_COLOR     = "nameColor";
    public static final String UV_CHAT_BALLOON   = "chatBalloon";
    public static final String UV_SMILEY         = "smiley";
    public static final String UV_HAND           = "hand";
    public static final String UV_MOOD           = "mood";
    public static final String UV_STATUS_MSG     = "statusMessage";
    public static final String UV_ROLES          = "roles";       // permission base64
    public static final String UV_PLATFORM       = "platform";
    public static final String UV_UNIVERSE       = "universeKey";

    private VariableNames() {}
}
