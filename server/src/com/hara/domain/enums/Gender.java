package com.hara.domain.enums;

/** Mirrors {@code com.oyunstudyosu.enums.GenderType}. Wire values are single-character strings. */
public final class Gender {
    public static final String MALE   = "m";
    public static final String FEMALE = "f";

    public static boolean isValid(String g) { return MALE.equals(g) || FEMALE.equals(g); }

    private Gender() {}
}
