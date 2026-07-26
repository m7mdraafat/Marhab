package com.mygame.server.protocol.extension;

import java.time.Instant;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import com.mygame.server.game.avatar.AvatarState;
import com.mygame.server.game.persistence.AvatarGameDataRepository;
import com.mygame.server.game.session.GameSession;
import com.mygame.server.game.session.SessionRegistry;
import com.mygame.server.smartfox.SmartFoxPacket;
import com.mygame.server.smartfox.SmartFoxPacketCodec;
import com.mygame.server.smartfox.SmartFoxValue;
import com.mygame.server.smartfox.SmartFoxValues;

@Component
public class InitCommandHandler implements ExtensionCommandHandler {
    private static final int AIRPORT_ROOM_ID = 24;
    private static final int STREET01_ROOM_ID = 0;
    private static final String AIRPORT_MAP = "PG1hcCB4T3JpZ2luPSI0OTAiIHlPcmlnaW49IjQ5MCI+IDxib3ggZD0iMyIgZGVmPSJzdGFuZCIgaD0iNCIgdz0iOSIgeD0iNyIgeT0iMCIgej0iMjAiLz4gPGJveCBkPSIxIiBkZWY9ImxjZCIgaD0iMiIgdz0iMSIgeD0iMSIgeT0iMCIgej0iMjEiLz4gPGNoYWlyIGQ9IjEiIGRlZj0idGFidXJlIiBkaXI9IjciIGg9IjAuNyIgdz0iMSIgeD0iMSIgeT0iMCIgej0iMTkiLz4gPGJveCBkPSIxIiBkZWY9ImxjZCIgaD0iMiIgdz0iMSIgeD0iNCIgeT0iMCIgej0iMjEiLz4gPGNoYWlyIGQ9IjEiIGRlZj0idGFidXJlIiBkaXI9IjciIGg9IjAuNyIgdz0iMSIgeD0iNCIgeT0iMCIgej0iMTkiLz4gPHByb3BlcnR5IGNuPSJXZWxjb21lUHJvcGVydHkiIGg9IjAiIHc9IjAiIHg9IjAiIHk9IjAiIHo9IjAiLz4gPC9tYXA+";
    private static final String AIRPORT_DOORS = "[{\"key\":\"d1\",\"targetDir\":1,\"targetX\":15,\"targetY\":15,\"property\":{\"doorKey\":\"d1\",\"roles\":\"AIAAEA==\",\"roomKey\":\"street01\",\"cn\":\"PassageProperty\"},\"primary\":true},{\"key\":\"d2\",\"targetDir\":3,\"targetX\":7,\"targetY\":0,\"property\":{\"doorKey\":\"d1\",\"roles\":\"AA==\",\"roomKey\":\"street01\",\"cn\":\"PassageProperty\"},\"primary\":false}]";
    private static final String AIRPORT_GRID = "AAAAEAAAABcAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
        + "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
        + "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
        + "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
        + "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
        + "AAAAAAAAAAAAAAAAAAEAAAEAAAAAAAAAAAAAAAAAAAAAAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEB"
        + "AQEBAQEBAQEBAQEBAQEBAQ==";

    private final SessionRegistry sessionRegistry;
    private final AvatarGameDataRepository avatarGameDataRepository;
    private final String firstRoom;

    @Autowired
    public InitCommandHandler(SessionRegistry sessionRegistry, AvatarGameDataRepository avatarGameDataRepository, @Value("${mygame.world.first-room:airport}") String firstRoom) {
        this.sessionRegistry = sessionRegistry;
        this.avatarGameDataRepository = avatarGameDataRepository;
        this.firstRoom = firstRoom;
    }

    InitCommandHandler(SessionRegistry sessionRegistry, String firstRoom) {
        this(sessionRegistry, null, firstRoom);
    }

    @Override
    public String command() {
        return "init";
    }

    @Override
    public List<byte[]> handle(String connectionId, SmartFoxPacket packet) {
        GameSession session = sessionRegistry.findByConnectionId(connectionId)
            .orElseThrow(() -> new IllegalStateException("No SmartFox session for connection " + connectionId));
        long timestamp = Instant.now().getEpochSecond();

        return List.of(
            SmartFoxPacketCodec.encode(userVariablesRoot(session.avatar(), userVariablesMinimal(session.avatar()))),
            SmartFoxPacketCodec.encode(userVariablesRoot(session.avatar(), userVariablesFull(session.avatar()))),
            SmartFoxPacketCodec.encode(extensionRoot("initQueue", Map.of("p", 1, "ts", timestamp))),
            SmartFoxPacketCodec.encode(extensionRoot("restartServer", Map.of("reason", "", "isRestartWaiting", false))),
            SmartFoxPacketCodec.encode(extensionRoot("roles", Map.of("roles", rolesFor(session.avatar()), "ts", timestamp))),
            SmartFoxPacketCodec.encode(userVariablesRoot(session.avatar(), List.of(variable("roles", 4, rolesFor(session.avatar()))))),
            SmartFoxPacketCodec.encode(userVariablesRoot(session.avatar(), userVariablesPosition(session.avatar()))),
            SmartFoxPacketCodec.encode(userVariablesRoot(session.avatar(), List.of(variable("speed", 3, 1.0d)))),
            SmartFoxPacketCodec.encode(initRoot(session.avatar(), timestamp)),
            SmartFoxPacketCodec.encode(roomJoinRoot(session.avatar()))
        );
    }

    SmartFoxValue initRoot(AvatarState avatar, long timestamp) {
        Map<String, Object> payload = new LinkedHashMap<>();
        payload.put("tutorialStep", 0);
        payload.put("settings", settings());
        payload.put("wallet", wallet(avatar));
        payload.put("extensionInfo", extensionInfo());
        payload.put("gender", avatar.gender());
        payload.put("selectedAvatarID", avatar.avatarId());
        payload.put("bans", List.of());
        payload.put("rid", 2);
        payload.put("checkAvatar", 1);
        payload.put("clothes", clothesPayload());
        payload.put("room", roomPayload());
        payload.put("createAvatar", false);
        payload.put("campaigns", List.of());
        payload.put("completedAchievementsCount", 0);
        payload.put("universe", universePayload());
        payload.put("guest", false);
        payload.put("isBanned", false);
        payload.put("emailActive", 0);
        payload.put("playerID", "101059138");
        payload.put("ts", timestamp);
        return extensionRoot(command(), payload);
    }

    SmartFoxValue roomJoinRoot(AvatarState avatar) {
        String roomKey = normalizedFirstRoom();
        int roomId = "airport".equals(roomKey) ? AIRPORT_ROOM_ID : STREET01_ROOM_ID;
        String group = "airport".equals(roomKey) ? "default" : "OUTDOOR";
        List<Object> roomTuple = List.of(
            roomId,
            "w1#" + roomKey,
            group,
            false,
            false,
            false,
            1,
            300,
            roomVariables(roomKey)
        );

        Map<String, SmartFoxValue> params = new LinkedHashMap<>();
        params.put("r", SmartFoxValues.fromPlain(roomTuple));
        params.put("ul", SmartFoxValues.fromPlain(roomUsers()));

        Map<String, SmartFoxValue> root = new LinkedHashMap<>();
        root.put("c", SmartFoxValue.byteValue(0));
        root.put("a", SmartFoxValue.shortValue(4));
        root.put("p", SmartFoxValue.object(params));
        return SmartFoxValue.object(root);
    }

    private List<Object> userTuple(AvatarState avatar) {
        String hand = handItemFor(avatar);
        String clothes = clothesFor(avatar);
        List<List<Object>> variables = List.of(
            variable("mood", 2, 0),
            variable("gender", 4, avatar.gender()),
            variable("optimizedAssetKey", 2, 1_459_553_073),
            variable("roles", 4, rolesFor(avatar)),
            variable("universeKey", 4, avatar.universeKey()),
            variable("avatarSize", 3, 1.0d),
            variable("platform", 4, "browser"),
            variable("statusMessage", 4, "Sanalika"),
            variable("clothes", 4, clothes),
            variable("speed", 3, 1.0d),
            variable("avatarName", 4, avatar.avatarName()),
            variable("forceSmiley", 1, true),
            variable("chatBalloon", 4, "1"),
            variable("imgPath", 2, 1_728_065_974),
            variable("position", 4, avatar.position()),
            variable("tp", 2, 1),
            variable("playerID", 2, 1_111_111),
            variable("smiley", 4, "visitor"),
            variable("status", 4, "i"),
            variable("direction", 2, avatar.direction()),
            variable("hand", 4, hand)
        );
        return List.of((int) avatar.userId(), avatar.avatarId(), avatar.privilegeId(), 0, variables);
    }

    private String handItemFor(AvatarState avatar) {
        return sessionRegistry.sessions().stream()
            .filter(s -> s.avatar().userId() == avatar.userId())
            .map(GameSession::handItem)
            .findFirst()
            .orElse("0");
    }

    private String clothesFor(AvatarState avatar) {
        return sessionRegistry.sessions().stream()
            .filter(s -> s.avatar().userId() == avatar.userId())
            .map(GameSession::clothes)
            .findFirst()
            .orElseGet(this::defaultClothesJson);
    }

    private List<Object> roomUsers() {
        return sessionRegistry.sessions().stream()
            .map(GameSession::avatar)
            .map(this::userTuple)
            .map(tuple -> (Object) tuple)
            .toList();
    }

    private String rolesFor(AvatarState avatar) {
        if (avatarGameDataRepository == null) {
            return "AA==";
        }
        return avatarGameDataRepository.rolesBitset(avatar.userId());
    }

    private SmartFoxValue userVariablesRoot(AvatarState avatar, List<List<Object>> variables) {
        Map<String, SmartFoxValue> params = new LinkedHashMap<>();
        params.put("u", SmartFoxValue.intValue((int) avatar.userId()));
        params.put("vl", SmartFoxValues.fromPlain(variables));

        Map<String, SmartFoxValue> root = new LinkedHashMap<>();
        root.put("c", SmartFoxValue.byteValue(0));
        root.put("a", SmartFoxValue.shortValue(12));
        root.put("p", SmartFoxValue.object(params));
        return SmartFoxValue.object(root);
    }

    private SmartFoxValue extensionRoot(String command, Map<String, Object> payload) {
        Map<String, SmartFoxValue> params = new LinkedHashMap<>();
        params.put("p", SmartFoxValues.fromPlain(payload));
        params.put("c", SmartFoxValue.utf(command));

        Map<String, SmartFoxValue> root = new LinkedHashMap<>();
        root.put("c", SmartFoxValue.byteValue(1));
        root.put("a", SmartFoxValue.shortValue(13));
        root.put("p", SmartFoxValue.object(params));
        return SmartFoxValue.object(root);
    }

    private List<List<Object>> userVariablesMinimal(AvatarState avatar) {
        return List.of(
            variable("avatarName", 4, avatar.avatarName()),
            variable("gender", 4, avatar.gender())
        );
    }

    private List<List<Object>> userVariablesFull(AvatarState avatar) {
        return List.of(
            variable("gender", 4, avatar.gender()),
            variable("playerID", 2, 1_111_111),
            variable("avatarName", 4, avatar.avatarName()),
            variable("universeKey", 4, avatar.universeKey()),
            variable("imgPath", 2, 1_728_065_974),
            variable("mood", 2, 0),
            variable("platform", 4, "browser"),
            variable("statusMessage", 4, "Sanalika"),
            variable("avatarSize", 3, 1.0d),
            variable("chatBalloon", 4, "1"),
            variable("smiley", 4, "visitor"),
            variable("forceSmiley", 1, true),
            variable("tp", 2, 1),
            variable("clothes", 4, clothesFor(avatar)),
            variable("optimizedAssetKey", 2, 1_459_553_073)
        );
    }

    private List<List<Object>> userVariablesPosition(AvatarState avatar) {
        return List.of(
            variable("status", 4, "i"),
            variable("position", 4, avatar.position()),
            variable("direction", 2, avatar.direction())
        );
    }

    private List<Object> variable(String name, int type, Object value) {
        return List.of(name, type, value, false);
    }

    private Map<String, Object> settings() {
        Map<String, Object> settings = new LinkedHashMap<>();
        settings.put("wideScreenMode", "1");
        settings.put("transferRequests", "1");
        settings.put("wideMode", "1");
        settings.put("muteSound", "0");
        settings.put("onlyBuddyWhisper", "0");
        settings.put("verifySession", "1");
        settings.put("whisperMessage", "0");
        settings.put("hideRequests", "1");
        settings.put("tradeRequests", "1");
        settings.put("incomingMessages", "1");
        settings.put("showInvitations", "1");
        settings.put("flatNotifications", "1");
        return settings;
    }

    private List<Map<String, Object>> wallet(AvatarState avatar) {
        return List.of(
            Map.of("avatarID", Long.parseLong(avatar.avatarId()), "balance", avatar.sanil(), "currency", "SANIL"),
            Map.of("avatarID", Long.parseLong(avatar.avatarId()), "balance", avatar.diamond(), "currency", "DIAMOND")
        );
    }

    private List<Map<String, Object>> extensionInfo() {
        return List.of(
            Map.of("name", "CursorExtension", "property", Map.of("cn", "")),
            Map.of("name", "SoundExtension", "property", Map.of("cn", ""))
        );
    }

    private Map<String, Object> clothesPayload() {
        return Map.of("type", "CLOTH", "items", defaultClothesItems());
    }

    private List<Map<String, Object>> defaultClothesItems() {
        return defaultClothes().stream().map(clip -> {
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("quantity", 1);
            item.put("color", 1);
            item.put("productID", 4);
            item.put("roles", "AA==");
            item.put("active", 1);
            item.put("source", "FREE");
            item.put("createdAt", "2016-10-07 06:01:59.0");
            item.put("expire", 0);
            item.put("transferrable", false);
            item.put("subType", "COSTUME");
            item.put("id", 6262);
            item.put("clip", clip);
            item.put("base", 1);
            return item;
        }).toList();
    }

    private Map<String, Object> roomPayload() {
        String roomKey = normalizedFirstRoom();
        Map<String, Object> room = new LinkedHashMap<>();
        room.put("key", roomKey);
        room.put("doorKey", "d1");
        room.put("dv", 0);
        room.put("pv", 0);
        if ("airport".equals(roomKey)) {
            room.put("map", AIRPORT_MAP);
        }
        return room;
    }

    private Map<String, Object> universePayload() {
        return Map.of(
            "fullness", 9,
            "roles", "AA==",
            "name", "جزيرة مرحب",
            "roomFullness", 0,
            "key", "w1",
            "roomAvailable", false,
            "recommended", false
        );
    }

    private List<List<Object>> roomVariables(String roomKey) {
        if ("airport".equals(roomKey)) {
            return airportRoomVariables();
        }

        return List.of(
            List.of("doors", 4, "[]", false, false),
            List.of("extensions", 4, "[]", false, false),
            List.of("bots", 4, "[]", false, false),
            List.of("music", 1, true, false, false),
            List.of("grid", 4, "", false, false),
            List.of("width", 2, 800, false, false),
            List.of("roomKey", 4, roomKey, false, false),
            List.of("height", 2, 515, false, false)
        );
    }

    private List<List<Object>> airportRoomVariables() {
        return List.of(
            List.of("doors", 4, AIRPORT_DOORS, false, false),
            List.of("extensions", 4, "[]", false, false),
            List.of("bots", 4, "[]", false, false),
            List.of("music", 1, true, false, false),
            List.of("grid", 4, AIRPORT_GRID, false, false),
            List.of("width", 2, 800, false, false),
            List.of("roomKey", 4, "airport", false, false),
            List.of("height", 2, 515, false, false)
        );
    }

    private String defaultClothesJson() {
        return "[\"" + String.join("\",\"", defaultClothes()) + "\"]";
    }

    private List<String> defaultClothes() {
        return List.of("A_2", "B_2", "C_2", "8_9", "1_9", "4_9", "7_10");
    }

    private String normalizedFirstRoom() {
        if ("street01".equalsIgnoreCase(firstRoom)) {
            return "street01";
        }
        return "airport";
    }
}