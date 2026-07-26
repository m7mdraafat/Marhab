package com.mygame.server.protocol.extension;

import com.mygame.server.game.avatar.AvatarState;
import com.mygame.server.game.session.GameSession;
import com.mygame.server.game.session.SessionRegistry;
import com.mygame.server.smartfox.SmartFoxPacket;
import java.util.LinkedHashMap;
import java.util.Map;
import org.springframework.stereotype.Component;

@Component
public class RoomMessageCommandHandler extends AbstractPanelCommandHandler {
    private final SessionRegistry sessionRegistry;

    public RoomMessageCommandHandler(SessionRegistry sessionRegistry) {
        this.sessionRegistry = sessionRegistry;
    }

    @Override
    public String command() {
        return "roommessage";
    }

    @Override
    protected Map<String, Object> payload(SmartFoxPacket packet) {
        throw new UnsupportedOperationException("Room message needs connection state");
    }

    @Override
    public java.util.List<byte[]> handle(String connectionId, SmartFoxPacket packet) {
        AvatarState avatar = sessionRegistry.findByConnectionId(connectionId).map(GameSession::avatar)
            .orElseThrow(() -> new IllegalStateException("No SmartFox session for connection " + connectionId));
        Map<String, Object> payload = new LinkedHashMap<>();
        payload.put("senderID", avatar.avatarId());
        payload.put("senderName", avatar.avatarName());
        payload.put("message", requestMessage(packet));
        payload.put("ts", requestTimestamp(packet));
        return java.util.List.of(com.mygame.server.smartfox.SmartFoxPacketCodec.encode(extensionRoot(command(), payload)));
    }

    private String requestMessage(SmartFoxPacket packet) {
        com.mygame.server.smartfox.SmartFoxValue wrapper = packet.params().asObject().get("p");
        if (wrapper == null || wrapper.value() == null) {
            return "";
        }
        com.mygame.server.smartfox.SmartFoxValue data = wrapper.asObject().get("data");
        if (data == null || data.value() == null) {
            return "";
        }
        com.mygame.server.smartfox.SmartFoxValue message = data.asObject().get("message");
        return message == null || message.value() == null ? "" : message.asUtf();
    }
}