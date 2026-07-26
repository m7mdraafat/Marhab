package com.mygame.server.game.roles;

import java.util.ArrayList;
import java.util.Base64;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public final class AvatarRoleCatalog {
    private static final List<Role> ROLES = List.of(
        new Role("TRANSFER", 2),
        new Role("BARTER", 3),
        new Role("VIP", 4),
        new Role("VIP_GOLD", 5),
        new Role("WHISPER", 6),
        new Role("VIP_DIAMOND", 7),
        new Role("VIP_SILVER", 8),
        new Role("AGE_18PLUS", 9),
        new Role("AGE_13MINUS", 10),
        new Role("VERIFIED_EMAIL", 11),
        new Role("VERIFIED_PHONE", 12),
        new Role("HOLIDAY_VISA_TURKEY", 13),
        new Role("DIAMOND_CLUB", 14),
        new Role("HOLIDAY_VISA_ABUDABI", 15),
        new Role("CARD_SECURITY", 16),
        new Role("HOLIDAY_VISA_SPAIN", 17),
        new Role("CARD_JOURNALIST", 18),
        new Role("CARD_DIRECTOR", 19),
        new Role("MODERATOR", 20),
        new Role("CARD_PHOTOGRAPHER", 21),
        new Role("EDITOR_SECURITY", 22),
        new Role("CARD_PAINTER", 23),
        new Role("PARTY", 24),
        new Role("SPACE_COSTUME", 25),
        new Role("KEY", 26),
        new Role("CARD_ACTOR", 27),
        new Role("CARD_GUARD", 28),
        new Role("CARD_GUIDE", 29),
        new Role("PLATO", 30),
        new Role("FORUM", 31),
        new Role("CARD_SANALIKAX", 32),
        new Role("CafeSmiley", 33),
        new Role("KIDO", 34),
        new Role("AIRPASS", 35),
        new Role("RUNWIN", 36),
        new Role("SNOWBALL", 37),
        new Role("HOLIDAY_VISA_JAPON", 38),
        new Role("HOLIDAY_VISA_TR_JPN", 39),
        new Role("SECURITY", 40),
        new Role("SWIM", 41),
        new Role("SKATE", 42),
        new Role("CARD_MUSIC", 43),
        new Role("BONUS_X2", 44),
        new Role("GAME_SHORTCUT", 45),
        new Role("SHIP_LICENSE", 46),
        new Role("CARD_CAPTAIN", 47),
        new Role("EVENT", 48),
        new Role("NPC", 49),
        new Role("STAGE", 50),
        new Role("NOT_VISITOR", 52)
    );

    private static final List<ChatBalloon> CHAT_BALLOONS = List.of(
        new ChatBalloon(1, "Default", "AA=="),
        new ChatBalloon(2, "Silver", "gA=="),
        new ChatBalloon(3, "Yellow", "EA=="),
        new ChatBalloon(4, "Grey", "QA=="),
        new ChatBalloon(23, "Black", "QA=="),
        new ChatBalloon(24, "Red", "EA=="),
        new ChatBalloon(25, "Pink", "EA=="),
        new ChatBalloon(26, "DiamondClub", "ACA="),
        new ChatBalloon(30, "SanalikaX", "AAAAgA==")
    );

    private AvatarRoleCatalog() {
    }

    public static List<Map<String, Object>> masterRoles() {
        return ROLES.stream().map(role -> Map.<String, Object>of("name", role.name(), "index", role.index())).toList();
    }

    public static List<Map<String, Object>> chatBalloons() {
        return CHAT_BALLOONS.stream().map(balloon -> {
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("requirements", balloon.requirements());
            item.put("name", balloon.name());
            item.put("id", balloon.id());
            return item;
        }).toList();
    }

    public static List<Integer> chatBalloonRequirementIndexes(int id) {
        return CHAT_BALLOONS.stream()
            .filter(balloon -> balloon.id() == id)
            .findFirst()
            .map(balloon -> requirementIndexes(balloon.requirements()))
            .orElse(List.of(Integer.MAX_VALUE));
    }

    public static List<Integer> requirementIndexes(String requirements) {
        if (requirements == null || requirements.isBlank()) {
            return List.of();
        }
        byte[] bytes = Base64.getDecoder().decode(requirements);
        List<Integer> indexes = new ArrayList<>();
        for (int byteIndex = 0; byteIndex < bytes.length; byteIndex++) {
            int value = bytes[byteIndex] & 0xff;
            for (int bit = 0; bit < 8; bit++) {
                if ((value & (1 << bit)) != 0) {
                    indexes.add(byteIndex * 8 + bit + 1);
                }
            }
        }
        return indexes;
    }

    public static String requirementsForIndexes(List<Integer> indexes) {
        if (indexes.isEmpty()) {
            return "AA==";
        }
        int maxIndex = indexes.stream().mapToInt(Integer::intValue).max().orElse(0);
        byte[] bytes = new byte[(maxIndex + 7) / 8];
        for (int index : indexes) {
            if (index <= 0) {
                continue;
            }
            int zeroBased = index - 1;
            bytes[zeroBased / 8] = (byte) (bytes[zeroBased / 8] | (1 << (zeroBased % 8)));
        }
        return Base64.getEncoder().encodeToString(bytes);
    }

    public static List<CardSeed> seedCards() {
        return List.of(
            new CardSeed(20003, "CARD_DIAMOND", "VIP", requirementsForIndexes(List.of(7))),
            new CardSeed(19999, "CARD_DIAMOND_CLUB", "VIP", requirementsForIndexes(List.of(14))),
            new CardSeed(9999, "CARD_GOLD", "VIP", requirementsForIndexes(List.of(5))),
            new CardSeed(9999, "CARD_SILVER", "VIP", requirementsForIndexes(List.of(8))),
            new CardSeed(9999, "CARD_ELITE", "VIP", requirementsForIndexes(List.of(4, 20))),
            new CardSeed(9999, "CARD_SANALIKAX", "VIP", requirementsForIndexes(List.of(32))),
            new CardSeed(19999, "CARD_GUIDE", "VIP", requirementsForIndexes(List.of(29))),
            new CardSeed(9999, "CARD_SECURITY", "VIP", requirementsForIndexes(List.of(16))),
            new CardSeed(9999, "CARD_MODERATOR", "VIP", requirementsForIndexes(List.of(20))),
            new CardSeed(9999, "CARD_JOURNALIST", "VIP", requirementsForIndexes(List.of(18))),
            new CardSeed(9999, "CARD_DIRECTOR", "VIP", requirementsForIndexes(List.of(19))),
            new CardSeed(9999, "CARD_PHOTOGRAPHER", "VIP", requirementsForIndexes(List.of(21))),
            new CardSeed(9999, "CARD_PAINTER", "VIP", requirementsForIndexes(List.of(23))),
            new CardSeed(9999, "CARD_ACTOR", "VIP", requirementsForIndexes(List.of(27))),
            new CardSeed(9999, "CARD_GUARD", "VIP", requirementsForIndexes(List.of(28))),
            new CardSeed(9999, "CARD_MUSIC", "VIP", requirementsForIndexes(List.of(43))),
            new CardSeed(9999, "CARD_CAPTAIN", "VIP", requirementsForIndexes(List.of(47)))
        );
    }

    public static List<Map<String, Object>> handItemsForIndexes(List<Integer> indexes) {
        List<Map<String, Object>> items = new ArrayList<>();
        if (indexes.contains(16) || indexes.contains(40)) {
            items.add(handItem(91001, "flag_guide", "SYSTEM ROLE", 16));
        }
        if (indexes.contains(29)) {
            items.add(handItem(91002, "flag_guide", "SYSTEM ROLE", 29));
        }
        if (indexes.contains(43)) {
            items.add(handItem(4055317, "kf", "SYSTEM ROLE", 43));
        }
        return items;
    }

    public static String handItemClip(int id) {
        return switch (id) {
            case 91001, 91002 -> "flag_guide";
            case 4055317 -> "kf";
            default -> null;
        };
    }

    private static Map<String, Object> handItem(int id, String clip, String source, int roleIndex) {
        Map<String, Object> item = new LinkedHashMap<>();
        item.put("id", id);
        item.put("productID", id);
        item.put("clip", clip);
        item.put("subType", "HAND_ITEM");
        item.put("roles", requirementsForIndexes(List.of(roleIndex)));
        item.put("source", source);
        item.put("active", 0);
        item.put("quantity", 1);
        item.put("color", 0);
        item.put("expire", 0);
        item.put("lifeTime", 0);
        item.put("timeLeft", 0);
        item.put("transferrable", false);
        item.put("base", 0);
        item.put("createdAt", "SYSTEM");
        return item;
    }

    public static List<Role> seedPermissions() {
        return ROLES.stream().filter(role -> List.of(
            4, 5, 7, 8, 14, 16, 18, 19, 20, 21, 22, 23, 27, 28, 29, 32, 40, 43, 46, 47
        ).contains(role.index())).toList();
    }

    public record Role(String name, int index) {
    }

    public record CardSeed(int productId, String clip, String subType, String roles) {
    }

    private record ChatBalloon(int id, String name, String requirements) {
    }
}