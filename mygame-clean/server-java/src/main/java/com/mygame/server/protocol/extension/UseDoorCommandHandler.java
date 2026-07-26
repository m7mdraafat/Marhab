package com.mygame.server.protocol.extension;

import com.mygame.server.game.avatar.AvatarState;
import com.mygame.server.game.session.GameSession;
import com.mygame.server.game.session.SessionRegistry;
import com.mygame.server.smartfox.SmartFoxPacket;
import com.mygame.server.smartfox.SmartFoxPacketCodec;
import com.mygame.server.smartfox.SmartFoxValue;
import com.mygame.server.smartfox.SmartFoxValues;
import java.time.Instant;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.stereotype.Component;

@Component
public class UseDoorCommandHandler extends AbstractPanelCommandHandler {
    private static final int STREET01_ROOM_ID = 0;
    private static final String STREET01_MAP = "PG1hcCB4T3JpZ2luPScyMDAnIHlPcmlnaW49JzU5MCc+PC9tYXA+";

    private final SessionRegistry sessionRegistry;

    public UseDoorCommandHandler(SessionRegistry sessionRegistry) {
        this.sessionRegistry = sessionRegistry;
    }

    @Override
    public String command() {
        return "usedoor";
    }

    @Override
    public List<byte[]> handle(String connectionId, SmartFoxPacket packet) {
        GameSession session = sessionRegistry.findByConnectionId(connectionId).orElse(null);
        if (session == null) {
            return super.handle(connectionId, packet);
        }
        return List.of(
            SmartFoxPacketCodec.encode(roomJoinRoot(session.avatar())),
            SmartFoxPacketCodec.encode(responseRoot(packet))
        );
    }

    @Override
    protected Map<String, Object> payload(SmartFoxPacket packet) {
        Map<String, Object> payload = new LinkedHashMap<>();
        payload.put("rid", requestRid(packet));
        payload.put("nextRequest", 1000);
        payload.put("room", Map.of("key", "street01", "doorKey", "d1", "dv", 0, "pv", 0, "map", STREET01_MAP));
        payload.put("universe", Map.of("fullness", 3, "roles", "AA==", "roomFullness", 0, "roomAvailable", true, "name", "جزيرة مرحب", "key", "w1", "recommended", false));
        payload.put("ts", requestTimestamp(packet) == 0 ? Instant.now().getEpochSecond() : requestTimestamp(packet));
        return payload;
    }

    private SmartFoxValue roomJoinRoot(AvatarState avatar) {
        List<Object> roomTuple = List.of(
            STREET01_ROOM_ID,
            "w1#street01",
            "OUTDOOR",
            false,
            false,
            false,
            1,
            300,
            roomVariables()
        );

        Map<String, SmartFoxValue> params = new LinkedHashMap<>();
        params.put("r", SmartFoxValues.fromPlain(roomTuple));
        params.put("ul", SmartFoxValues.fromPlain(List.of(userTuple(avatar))));

        Map<String, SmartFoxValue> root = new LinkedHashMap<>();
        root.put("c", SmartFoxValue.byteValue(0));
        root.put("a", SmartFoxValue.shortValue(4));
        root.put("p", SmartFoxValue.object(params));
        return SmartFoxValue.object(root);
    }

    private List<List<Object>> roomVariables() {
        return List.of(
            List.of("doors", 4, "[]", false, false),
            List.of("extensions", 4, "[]", false, false),
            List.of("bots", 4, "[]", false, false),
            List.of("music", 1, true, false, false),
            List.of("grid", 4, walkableGrid(58, 47), false, false),
            List.of("width", 2, 800, false, false),
            List.of("roomKey", 4, "street01", false, false),
            List.of("height", 2, 515, false, false)
        );
    }

    private List<Object> userTuple(AvatarState avatar) {
        return List.of((int) avatar.userId(), avatar.avatarId(), avatar.privilegeId(), 0, List.of(
            List.of("avatarName", 4, avatar.avatarName(), false),
            List.of("gender", 4, avatar.gender(), false),
            List.of("position", 4, "38,25", false),
            List.of("direction", 2, 1, false),
            List.of("status", 4, "i", false)
        ));
    }

    private String walkableGrid(int width, int height) {
        byte[] bytes = new byte[8 + width * height];
        bytes[0] = (byte) (width >> 24);
        bytes[1] = (byte) (width >> 16);
        bytes[2] = (byte) (width >> 8);
        bytes[3] = (byte) width;
        bytes[4] = (byte) (height >> 24);
        bytes[5] = (byte) (height >> 16);
        bytes[6] = (byte) (height >> 8);
        bytes[7] = (byte) height;
        return java.util.Base64.getEncoder().encodeToString(bytes);
    }
}