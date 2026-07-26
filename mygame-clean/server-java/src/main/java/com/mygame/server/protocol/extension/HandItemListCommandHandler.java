package com.mygame.server.protocol.extension;

import com.mygame.server.game.persistence.AvatarGameDataRepository;
import com.mygame.server.game.session.GameSession;
import com.mygame.server.game.session.SessionRegistry;
import com.mygame.server.smartfox.SmartFoxPacket;
import com.mygame.server.smartfox.SmartFoxPacketCodec;
import com.mygame.server.smartfox.SmartFoxValue;
import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class HandItemListCommandHandler extends AbstractPanelCommandHandler {
    private final SessionRegistry sessionRegistry;
    private final AvatarGameDataRepository avatarGameDataRepository;

    @Autowired
    public HandItemListCommandHandler(SessionRegistry sessionRegistry, AvatarGameDataRepository avatarGameDataRepository) {
        this.sessionRegistry = sessionRegistry;
        this.avatarGameDataRepository = avatarGameDataRepository;
    }

    HandItemListCommandHandler() {
        this.sessionRegistry = null;
        this.avatarGameDataRepository = null;
    }

    @Override
    public String command() {
        return "handitemlist";
    }

    @Override
    public List<byte[]> handle(String connectionId, SmartFoxPacket packet) {
        if (sessionRegistry == null || avatarGameDataRepository == null) {
            return super.handle(connectionId, packet);
        }
        GameSession session = sessionRegistry.findByConnectionId(connectionId).orElse(null);
        if (session == null) {
            return super.handle(connectionId, packet);
        }
        return List.of(SmartFoxPacketCodec.encode(extensionRoot(command(), payload(packet, avatarGameDataRepository.handItems(session.avatar().userId())))));
    }

    @Override
    protected Map<String, Object> payload(SmartFoxPacket packet) {
        return payload(packet, List.of());
    }

    private Map<String, Object> payload(SmartFoxPacket packet, List<Map<String, Object>> items) {
        int page = requestPage(packet);
        return Map.of(
            "rid", requestRid(packet),
            "items", Map.of("list", items, "page", page),
            "pageSelected", page,
            "totalPages", items.isEmpty() ? 0 : 1,
            "nextRequest", 1000,
            "ts", requestTimestamp(packet)
        );
    }

    private int requestPage(SmartFoxPacket packet) {
        SmartFoxValue data = packet.params().asObject().get("p").asObject().get("data");
        if (data == null || data.value() == null) {
            return 1;
        }
        SmartFoxValue page = data.asObject().get("page");
        return page == null || page.value() == null ? 1 : Math.max(1, page.asInt());
    }
}