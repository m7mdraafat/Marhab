package com.mygame.server.protocol.extension;

import com.mygame.server.auth.AuthBridge;
import com.mygame.server.auth.AuthBridgeResult;
import com.mygame.server.game.session.SessionRegistry;
import com.mygame.server.smartfox.SmartFoxPacket;
import com.mygame.server.smartfox.SmartFoxPacketCodec;
import com.mygame.server.smartfox.SmartFoxValue;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.stereotype.Component;

@Component
public class DitchGuestPanelCommandHandler implements ExtensionCommandHandler {
    private final SessionRegistry sessionRegistry;
    private final AuthBridge authBridge;

    public DitchGuestPanelCommandHandler(SessionRegistry sessionRegistry, AuthBridge authBridge) {
        this.sessionRegistry = sessionRegistry;
        this.authBridge = authBridge;
    }

    @Override
    public String command() {
        return "ditchguestpanel";
    }

    @Override
    public List<byte[]> handle(String connectionId, SmartFoxPacket packet) {
        sessionRegistry.findByConnectionId(connectionId)
            .orElseThrow(() -> new IllegalStateException("No SmartFox session for connection " + connectionId));

        return authBridge.consumeCompletedAuth()
            .map(result -> List.of(SmartFoxPacketCodec.encode(responseRoot(result))))
            .orElseGet(List::of);
    }

    SmartFoxValue responseRoot(AuthBridgeResult result) {
        Map<String, SmartFoxValue> payload = new LinkedHashMap<>();
        payload.put("avatarID", SmartFoxValue.utf(result.avatarId()));
        payload.put("token", SmartFoxValue.utf(result.token()));

        Map<String, SmartFoxValue> params = new LinkedHashMap<>();
        params.put("p", SmartFoxValue.object(payload));
        params.put("c", SmartFoxValue.utf(result.completionCommand()));

        Map<String, SmartFoxValue> root = new LinkedHashMap<>();
        root.put("c", SmartFoxValue.byteValue(1));
        root.put("a", SmartFoxValue.shortValue(13));
        root.put("p", SmartFoxValue.object(params));
        return SmartFoxValue.object(root);
    }
}