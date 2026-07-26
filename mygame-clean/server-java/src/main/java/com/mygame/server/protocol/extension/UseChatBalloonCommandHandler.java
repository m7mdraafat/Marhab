package com.mygame.server.protocol.extension;

import com.mygame.server.game.persistence.AvatarGameDataRepository;
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
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class UseChatBalloonCommandHandler implements ExtensionCommandHandler {
    private final SessionRegistry sessionRegistry;
    private final AvatarGameDataRepository avatarGameDataRepository;

    @Autowired
    public UseChatBalloonCommandHandler(SessionRegistry sessionRegistry, AvatarGameDataRepository avatarGameDataRepository) {
        this.sessionRegistry = sessionRegistry;
        this.avatarGameDataRepository = avatarGameDataRepository;
    }

    UseChatBalloonCommandHandler(SessionRegistry sessionRegistry) {
        this(sessionRegistry, null);
    }

    @Override
    public String command() {
        return "usechatballoon";
    }

    @Override
    public List<byte[]> handle(String connectionId, SmartFoxPacket packet) {
        GameSession session = sessionRegistry.findByConnectionId(connectionId)
            .orElseThrow(() -> new IllegalStateException("No SmartFox session for connection " + connectionId));
        int id = requestInt(packet, "id", 1);
        List<Integer> requiredRoles = AvatarRoleCatalog.chatBalloonRequirementIndexes(id);
        if (!requiredRoles.isEmpty() && (avatarGameDataRepository == null || !avatarGameDataRepository.hasRequiredRoles(session.avatar().userId(), requiredRoles))) {
            return List.of(SmartFoxPacketCodec.encode(extensionRoot(command(), errorPayload(requestRid(packet), requiredRoles))));
        }
        session.chatBalloon(String.valueOf(id));
        if (avatarGameDataRepository != null) {
            avatarGameDataRepository.updateSetting(session.avatar().userId(), "chatBalloon", String.valueOf(id));
        }

        Map<String, Object> payload = new LinkedHashMap<>();
        payload.put("chatBaloon", id);
        payload.put("rid", requestRid(packet));
        payload.put("nextRequest", 1000);

        return List.of(
            SmartFoxPacketCodec.encode(userVariablesRoot((int) session.avatar().userId(), List.of(variable("chatBalloon", 4, String.valueOf(id))))),
            SmartFoxPacketCodec.encode(extensionRoot(command(), payload))
        );
    }

    private Map<String, Object> errorPayload(int rid, List<Integer> requiredRoles) {
        Map<String, Object> payload = new LinkedHashMap<>();
        payload.put("errorCode", "INSUFFICIENT_ROLE");
        payload.put("message", requiredRoles.stream().map(String::valueOf).collect(java.util.stream.Collectors.joining(",")));
        payload.put("rid", rid);
        payload.put("nextRequest", 1000);
        return payload;
    }

    private int requestInt(SmartFoxPacket packet, String name, int fallback) {
        SmartFoxValue value = requestData(packet).get(name);
        return value == null || value.value() == null ? fallback : (int) value.asLong();
    }

    private int requestRid(SmartFoxPacket packet) {
        SmartFoxValue value = requestField(packet, "rid");
        return value == null || value.value() == null ? 0 : (int) value.asLong();
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