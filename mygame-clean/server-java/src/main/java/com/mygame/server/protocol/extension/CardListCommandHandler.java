package com.mygame.server.protocol.extension;

import com.mygame.server.game.persistence.AvatarGameDataRepository;
import com.mygame.server.game.session.GameSession;
import com.mygame.server.game.session.SessionRegistry;
import com.mygame.server.smartfox.SmartFoxPacket;
import com.mygame.server.smartfox.SmartFoxPacketCodec;
import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class CardListCommandHandler extends AbstractPanelCommandHandler {
    private final SessionRegistry sessionRegistry;
    private final AvatarGameDataRepository avatarGameDataRepository;

    @Autowired
    public CardListCommandHandler(SessionRegistry sessionRegistry, AvatarGameDataRepository avatarGameDataRepository) {
        this.sessionRegistry = sessionRegistry;
        this.avatarGameDataRepository = avatarGameDataRepository;
    }

    CardListCommandHandler() {
        this.sessionRegistry = null;
        this.avatarGameDataRepository = null;
    }

    @Override
    public String command() {
        return "cardlist";
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
        return List.of(SmartFoxPacketCodec.encode(extensionRoot(command(), listPayload(packet, "CARD", avatarGameDataRepository.cards(session.avatar().userId())))));
    }

    @Override
    protected Map<String, Object> payload(SmartFoxPacket packet) {
        return listPayload(packet, "CARD", List.of());
    }
}