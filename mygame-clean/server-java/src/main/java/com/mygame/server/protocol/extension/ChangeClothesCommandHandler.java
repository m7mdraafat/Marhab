package com.mygame.server.protocol.extension;

import com.mygame.server.game.persistence.AvatarSettingsService;
import com.mygame.server.game.session.GameSession;
import com.mygame.server.game.session.SessionRegistry;
import com.mygame.server.smartfox.SmartFoxPacket;
import com.mygame.server.smartfox.SmartFoxPacketCodec;
import com.mygame.server.smartfox.SmartFoxValue;
import com.mygame.server.smartfox.SmartFoxValues;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class ChangeClothesCommandHandler implements ExtensionCommandHandler {
    private final SessionRegistry sessionRegistry;
    private final AvatarSettingsService avatarSettingsService;

    @Autowired
    public ChangeClothesCommandHandler(SessionRegistry sessionRegistry, AvatarSettingsService avatarSettingsService) {
        this.sessionRegistry = sessionRegistry;
        this.avatarSettingsService = avatarSettingsService;
    }

    // Test seam: in-memory updates only, no DB write-through.
    ChangeClothesCommandHandler(SessionRegistry sessionRegistry) {
        this(sessionRegistry, null);
    }

    @Override
    public String command() {
        return "changeclothes";
    }

    @Override
    public List<byte[]> handle(String connectionId, SmartFoxPacket packet) {
        GameSession session = sessionRegistry.findByConnectionId(connectionId)
            .orElseThrow(() -> new IllegalStateException("No SmartFox session for connection " + connectionId));
        String clothes = requestClothes(packet, session.clothes());
        if (avatarSettingsService != null) {
            avatarSettingsService.persistClothes(session, clothes);
        } else {
            session.clothes(clothes);
        }
        return List.of(
            SmartFoxPacketCodec.encode(userVariablesRoot((int) session.avatar().userId(), List.of(variable("clothes", 4, clothes)))),
            SmartFoxPacketCodec.encode(extensionRoot(command(), successPayload(packet)))
        );
    }

    private String requestClothes(SmartFoxPacket packet, String fallback) {
        SmartFoxValue value = requestData(packet).get("clothes");
        if (value == null) {
            value = requestData(packet).get("items");
        }
        if (value == null || value.value() == null) {
            return fallback;
        }
        return value.value() instanceof List<?> ? value.value().toString() : String.valueOf(value.value());
    }

    private Map<String, SmartFoxValue> requestData(SmartFoxPacket packet) {
        SmartFoxValue data = requestField(packet, "data");
        return data == null || data.value() == null ? Map.of() : data.asObject();
    }

    private SmartFoxValue requestField(SmartFoxPacket packet, String name) {
        SmartFoxValue payload = packet.params().asObject().get("p");
        return payload == null || payload.value() == null ? null : payload.asObject().get(name);
    }

    private Map<String, Object> successPayload(SmartFoxPacket packet) {
        Map<String, Object> payload = new LinkedHashMap<>();
        SmartFoxValue rid = requestField(packet, "rid");
        SmartFoxValue ts = requestField(packet, "ts");
        payload.put("status", "success");
        payload.put("rid", rid == null || rid.value() == null ? 0 : rid.asLong());
        payload.put("ts", ts == null || ts.value() == null ? 0 : ts.asLong());
        return payload;
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