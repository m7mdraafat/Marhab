package com.mygame.server.game.avatar;

public record AvatarState(
    long userId,
    String avatarId,
    String avatarName,
    String gender,
    int privilegeId,
    int sanil,
    int diamond,
    String universeKey,
    String roomKey,
    String position,
    int direction
) {
    public static AvatarState guestBootstrap() {
        return new AvatarState(
            4_743L,
            "299264109",
            "Guest",
            "m",
            0,
            0,
            0,
            "w1",
            "airport",
            "15,15",
            5
        );
    }

    public static AvatarState devDefault() {
        return new AvatarState(
            1L,
            "101002081",
            "M7MED",
            "m",
            1,
            225_931,
            148,
            "w1",
            "street01",
            "34,26",
            1
        );
    }

    public AvatarState withPosition(String newPosition, int newDirection) {
        return new AvatarState(userId, avatarId, avatarName, gender, privilegeId, sanil, diamond, universeKey, roomKey, newPosition, newDirection);
    }
}