package com.mygame.server.protocol.extension;

import com.mygame.server.game.session.GameSession;
import com.mygame.server.game.session.SessionRegistry;
import com.mygame.server.smartfox.SmartFoxPacket;
import com.mygame.server.smartfox.SmartFoxPacketCodec;
import com.mygame.server.smartfox.SmartFoxValue;
import com.mygame.server.smartfox.SmartFoxValues;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.stereotype.Component;

@Component
public class WalkRequestCommandHandler implements ExtensionCommandHandler {
    private final SessionRegistry sessionRegistry;

    public WalkRequestCommandHandler(SessionRegistry sessionRegistry) {
        this.sessionRegistry = sessionRegistry;
    }

    @Override
    public String command() {
        return "walkrequest";
    }

    @Override
    public List<byte[]> handle(String connectionId, SmartFoxPacket packet) {
        GameSession session = sessionRegistry.findByConnectionId(connectionId).orElse(null);
        if (session == null) {
            return List.of();
        }

        WalkTarget target = target(packet);
        int rid = requestRid(packet);
        session.pendingWalk(new GameSession.PendingWalk(target.x(), target.y(), target.door(), rid));

        Map<String, Object> payload = new LinkedHashMap<>();
        payload.put("delay", walkDelay(session.avatar().position(), target.x(), target.y(), target.door()));
        if (target.door()) {
            payload.put("isDoor", true);
            payload.put("doorY", target.y());
            payload.put("doorX", target.x());
        }

        return List.of(
            SmartFoxPacketCodec.encode(userVariablesRoot((int) session.avatar().userId(), List.of(variable("target", 4, target.position())))),
            SmartFoxPacketCodec.encode(extensionRoot(command(), payload))
        );
    }

    private int walkDelay(String currentPosition, int targetX, int targetY, boolean door) {
        String[] parts = currentPosition.split(",", 2);
        int currentX = parts.length > 0 ? parseInt(parts[0], targetX) : targetX;
        int currentY = parts.length > 1 ? parseInt(parts[1], targetY) : targetY;
        int distance = Math.abs(targetX - currentX) + Math.abs(targetY - currentY);
        int baseDelay = Math.max(120, distance * 120);
        return door ? Math.min(baseDelay, 6000) : baseDelay;
    }

    private WalkTarget target(SmartFoxPacket packet) {
        Map<String, SmartFoxValue> data = requestData(packet);
        int x = (int) data.getOrDefault("x", SmartFoxValue.intValue(0)).asLong();
        int y = (int) data.getOrDefault("y", SmartFoxValue.intValue(0)).asLong();
        SmartFoxValue doorValue = data.get("door");
        boolean door = doorValue != null && doorValue.value() != null && doorValue.asBoolean();
        return new WalkTarget(x, y, door);
    }

    private Map<String, SmartFoxValue> requestData(SmartFoxPacket packet) {
        SmartFoxValue payload = packet.params().asObject().get("p");
        if (payload == null || payload.value() == null) {
            return Map.of();
        }
        SmartFoxValue data = payload.asObject().get("data");
        return data == null || data.value() == null ? Map.of() : data.asObject();
    }

    private int requestRid(SmartFoxPacket packet) {
        SmartFoxValue payload = packet.params().asObject().get("p");
        if (payload == null || payload.value() == null) {
            return 0;
        }
        SmartFoxValue rid = payload.asObject().get("rid");
        return rid == null || rid.value() == null ? 0 : (int) rid.asLong();
    }

    private int parseInt(String value, int fallback) {
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException error) {
            return fallback;
        }
    }

    private SmartFoxValue userVariablesRoot(int userId, List<List<Object>> variables) {
        Map<String, SmartFoxValue> params = new LinkedHashMap<>();
        params.put("u", SmartFoxValue.intValue(userId));
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

    private List<Object> variable(String name, int type, Object value) {
        return List.of(name, type, value, false);
    }

    private record WalkTarget(int x, int y, boolean door) {
        String position() {
            return x + "," + y;
        }
    }
}