package com.mygame.server.protocol.system;

import com.mygame.server.game.session.GameSession;
import com.mygame.server.game.session.SessionRegistry;
import com.mygame.server.smartfox.SmartFoxPacket;
import com.mygame.server.smartfox.SmartFoxPacketCodec;
import com.mygame.server.smartfox.SmartFoxValue;
import java.time.Instant;
import java.util.LinkedHashMap;
import java.util.Map;
import org.springframework.stereotype.Component;

@Component
public class PublicMessageHandler {
    private final SessionRegistry sessionRegistry;

    public PublicMessageHandler(SessionRegistry sessionRegistry) {
        this.sessionRegistry = sessionRegistry;
    }

    public byte[] handle(String connectionId, SmartFoxPacket packet) {
        GameSession session = sessionRegistry.findByConnectionId(connectionId)
            .orElseThrow(() -> new IllegalStateException("No SmartFox session for connection " + connectionId));
        Map<String, SmartFoxValue> request = packet.params().asObject();

        Map<String, SmartFoxValue> extra = new LinkedHashMap<>();
        SmartFoxValue extraParams = request.get("p");
        if (extraParams != null && extraParams.value() != null) {
            extra.putAll(extraParams.asObject());
        }
        extra.putIfAbsent("ts", SmartFoxValue.longValue(Instant.now().getEpochSecond()));

        Map<String, SmartFoxValue> params = new LinkedHashMap<>();
        params.put("p", SmartFoxValue.object(extra));
        params.put("r", request.getOrDefault("r", SmartFoxValue.intValue(24)));
        params.put("t", request.getOrDefault("t", SmartFoxValue.byteValue(0)));
        params.put("u", SmartFoxValue.intValue((int) session.avatar().userId()));
        params.put("m", request.getOrDefault("m", SmartFoxValue.utf("")));

        Map<String, SmartFoxValue> root = new LinkedHashMap<>();
        root.put("c", SmartFoxValue.byteValue(0));
        root.put("a", SmartFoxValue.shortValue(7));
        root.put("p", SmartFoxValue.object(params));
        return SmartFoxPacketCodec.encode(SmartFoxValue.object(root));
    }
}