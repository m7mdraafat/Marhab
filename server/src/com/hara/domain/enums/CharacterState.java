package com.hara.domain.enums;

/** Mirrors {@code com.oyunstudyosu.enums.CharacterState}. Wire values are short strings. */
public final class CharacterState {
    public static final String IDLE            = "i";
    public static final String WALK            = "w";
    public static final String SITTING         = "s";
    public static final String DANCE           = "d";
    public static final String ACTION          = "a1";
    public static final String GAME_MOVE       = "gm";
    public static final String GAME_IDLE       = "gi";
    public static final String GAME_ACTION     = "ga";
    public static final String SNOWBALL_ACTION = "ac";

    private CharacterState() {}
}
