package com.mygame.server.protocol.extension;

import com.mygame.server.game.roles.AvatarRoleCatalog;
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
public class UseHandItemCommandHandler implements ExtensionCommandHandler {
    private final SessionRegistry sessionRegistry;

    public UseHandItemCommandHandler(SessionRegistry sessionRegistry) {
        this.sessionRegistry = sessionRegistry;
    }

    @Override
    public String command() {
        return "usehanditem";
    }

    @Override
    public List<byte[]> handle(String connectionId, SmartFoxPacket packet) {
        GameSession session = sessionRegistry.findByConnectionId(connectionId)
            .orElseThrow(() -> new IllegalStateException("No SmartFox session for connection " + connectionId));
        int itemId = requestInt(packet, "id", 0);
        String hand = itemId == 0 ? "0" : AvatarRoleCatalog.handItemClip(itemId);
        if (hand == null) {
            hand = "0";
        }
        session.handItem(hand);

        String message = itemId == 0 || "0".equals(hand) ? "Hand item removed, speed reset to 1.0." : "Hand item equipped successfully.";
        Map<String, Object> payload = new LinkedHashMap<>();
        payload.put("message", message);
        payload.put("rid", requestRid(packet));
        payload.put("status", "success");
        payload.put("ts", requestTimestamp(packet));

        return List.of(
            SmartFoxPacketCodec.encode(userVariablesRoot((int) session.avatar().userId(), List.of(variable("hand", 4, hand)))),
            SmartFoxPacketCodec.encode(userVariablesRoot((int) session.avatar().userId(), List.of(variable("speed", 3, 1.0d)))),
            SmartFoxPacketCodec.encode(extensionRoot(command(), payload))
        );
    }

    private int requestInt(SmartFoxPacket packet, String name, int fallback) {
        SmartFoxValue value = requestData(packet).get(name);
        return value == null || value.value() == null ? fallback : (int) value.asLong();
    }

    private int requestRid(SmartFoxPacket packet) {
        SmartFoxValue value = requestField(packet, "rid");
        return value == null || value.value() == null ? 0 : (int) value.asLong();
    }

    private long requestTimestamp(SmartFoxPacket packet) {
        SmartFoxValue value = requestField(packet, "ts");
        return value == null || value.value() == null ? 0 : value.asLong();
    }

    private Map<String, SmartFoxValue> requestData(SmartFoxPacket packet) {
        SmartFoxValue data = requestField(packet, "data");
        return data == null || data.value() == null ? Map.of() : data.asObject();
    }

    private SmartFoxValue requestField(SmartFoxPacket packet, String name) {
        SmartFoxValue payload = packet.params().asObject().get("p");
        if (payload == null || payload.value() == null) {
            return null;
        }
        return payload.asObject().get(name);
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
}