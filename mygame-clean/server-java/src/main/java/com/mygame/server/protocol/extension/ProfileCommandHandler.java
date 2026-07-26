package com.mygame.server.protocol.extension;

import com.mygame.server.game.avatar.AvatarState;
import com.mygame.server.game.persistence.AvatarGameDataRepository;
import com.mygame.server.game.session.GameSession;
import com.mygame.server.game.session.SessionRegistry;
import com.mygame.server.smartfox.SmartFoxPacket;
import com.mygame.server.smartfox.SmartFoxPacketCodec;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class ProfileCommandHandler extends AbstractPanelCommandHandler {
    private final SessionRegistry sessionRegistry;
    private final AvatarGameDataRepository avatarGameDataRepository;

    @Autowired
    public ProfileCommandHandler(SessionRegistry sessionRegistry, AvatarGameDataRepository avatarGameDataRepository) {
        this.sessionRegistry = sessionRegistry;
        this.avatarGameDataRepository = avatarGameDataRepository;
    }

    ProfileCommandHandler(SessionRegistry sessionRegistry) {
        this(sessionRegistry, null);
    }

    @Override
    public String command() {
        return "profile";
    }

    @Override
    protected Map<String, Object> payload(SmartFoxPacket packet) {
        return payload(packet, null);
    }

    private Map<String, Object> payload(SmartFoxPacket packet, AvatarState avatar) {
        Map<String, Object> payload = new LinkedHashMap<>();
        payload.put("cards", cards(avatar));
        payload.put("mood", 0);
        payload.put("isRequest", false);
        payload.put("hasBestFriend", false);
        payload.put("dislikeCount", 0);
        payload.put("skin", Map.of(
            "clip", "0",
            "property", Map.of("cn", "ProfileSkinProperty", "bgColor", "690e0e", "alpha", "0.4", "textColor", "154c79")
        ));
        payload.put("banCount", 0);
        payload.put("likeCount", 0);
        payload.put("rid", requestRid(packet));
        payload.put("totalBuddies", 0);
        payload.put("duration", 0);
        payload.put("runWinTeam", "");
        payload.put("avatarCity", "Marhab");
        payload.put("flats", List.of());
        payload.put("avatarAge", 18);
        payload.put("stickers", List.of());
        payload.put("emailRegistered", 1);
        payload.put("avarageRating", "0.00");
        payload.put("badges", List.of(Map.of("quantity", 1, "clip", "1stGenBadge")));
        payload.put("avatarName", avatar == null ? "M7MED" : avatar.avatarName());
        payload.put("avatarID", requestedAvatarId(packet, avatar));
        payload.put("gender", avatar == null ? "m" : avatar.gender());
        payload.put("privilegeId", avatar == null ? 1 : avatar.privilegeId());
        payload.put("isBuddy", false);
        payload.put("nextRequest", 500);
        payload.put("status", "Sanalika");
        payload.put("ts", requestTimestamp(packet));
        return payload;
    }

    @Override
    public List<byte[]> handle(String connectionId, SmartFoxPacket packet) {
        AvatarState avatar = sessionRegistry.findByConnectionId(connectionId).map(GameSession::avatar).orElse(null);
        return List.of(SmartFoxPacketCodec.encode(extensionRoot(command(), payload(packet, avatar))));
    }

    private String requestedAvatarId(SmartFoxPacket packet, AvatarState avatar) {
        Map<String, com.mygame.server.smartfox.SmartFoxValue> data = requestData(packet);
        com.mygame.server.smartfox.SmartFoxValue avatarId = data.get("avatarID");
        if (avatarId != null && avatarId.value() != null) {
            return avatarId.asUtf();
        }
        return avatar == null ? "101002081" : avatar.avatarId();
    }

    private Map<String, com.mygame.server.smartfox.SmartFoxValue> requestData(SmartFoxPacket packet) {
        com.mygame.server.smartfox.SmartFoxValue wrapper = packet.params().asObject().get("p");
        if (wrapper == null || wrapper.value() == null) {
            return Map.of();
        }
        com.mygame.server.smartfox.SmartFoxValue data = wrapper.asObject().get("data");
        return data == null || data.value() == null ? Map.of() : data.asObject();
    }

    private List<Map<String, Object>> cards(AvatarState avatar) {
        if (avatar == null || avatarGameDataRepository == null) {
            return List.of();
        }
        return avatarGameDataRepository.profileCards(avatar.userId());
    }
}