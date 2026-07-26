package com.mygame.server.protocol.extension;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.when;

import com.mygame.server.game.persistence.AvatarGameDataRepository;
import com.mygame.server.game.session.SessionRegistry;
import com.mygame.server.smartfox.SmartFoxPacket;
import com.mygame.server.smartfox.SmartFoxPacketCodec;
import com.mygame.server.smartfox.SmartFoxPacketHeader;
import com.mygame.server.smartfox.SmartFoxValue;
import com.mygame.server.smartfox.SmartFoxValues;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;

class ProfileAndRoomMessageCommandHandlerTest {
    @Test
    void profileReturnsCapturedPanelShapeWithoutDefaultCards() {
        SessionRegistry sessionRegistry = new SessionRegistry();
        sessionRegistry.createDevSession("connection-1", "marhab");
        ProfileCommandHandler handler = new ProfileCommandHandler(sessionRegistry);

        SmartFoxPacket response = SmartFoxPacketCodec.decode(handler.handle("connection-1", requestPacket("profile", 7, Map.of("avatarID", "101002081"))).getFirst());
        Map<String, SmartFoxValue> payload = response.params().asObject().get("p").asObject();

        assertThat(response.params().asObject().get("c").asUtf()).isEqualTo("profile");
        assertThat(payload.get("cards").asArray()).isEmpty();
        assertThat(payload.get("skin").asObject().get("property").asObject().get("cn").asUtf()).isEqualTo("ProfileSkinProperty");
        assertThat(payload.get("avatarName").asUtf()).isEqualTo("M7MED");
        assertThat(payload.get("rid").asLong()).isEqualTo(7);
    }

    @Test
    void profileUsesPersistedPublicCardsWhenPresent() {
        SessionRegistry sessionRegistry = new SessionRegistry();
        sessionRegistry.createDevSession("connection-1", "marhab");
        AvatarGameDataRepository avatarGameDataRepository = Mockito.mock(AvatarGameDataRepository.class);
        when(avatarGameDataRepository.profileCards(1L)).thenReturn(List.of(
            Map.of("quantity", 1, "productID", 19999, "expire", 0, "subType", "VIP", "clip", "CARD_DIAMOND_CLUB")
        ));
        ProfileCommandHandler handler = new ProfileCommandHandler(sessionRegistry, avatarGameDataRepository);

        SmartFoxPacket response = SmartFoxPacketCodec.decode(handler.handle("connection-1", requestPacket("profile", 7, Map.of("avatarID", "101002081"))).getFirst());
        Map<String, SmartFoxValue> payload = response.params().asObject().get("p").asObject();

        assertThat(payload.get("cards").asArray()).hasSize(1);
        assertThat(payload.get("cards").asArray().getFirst().asObject().get("clip").asUtf()).isEqualTo("CARD_DIAMOND_CLUB");
    }

    @Test
    void roomMessageEchoesSenderAndMessage() {
        SessionRegistry sessionRegistry = new SessionRegistry();
        sessionRegistry.createDevSession("connection-1", "marhab");
        RoomMessageCommandHandler handler = new RoomMessageCommandHandler(sessionRegistry);

        SmartFoxPacket response = SmartFoxPacketCodec.decode(handler.handle("connection-1", requestPacket("roommessage", 24, Map.of("message", "test"))).getFirst());
        Map<String, SmartFoxValue> payload = response.params().asObject().get("p").asObject();

        assertThat(response.params().asObject().get("c").asUtf()).isEqualTo("roommessage");
        assertThat(payload.get("senderID").asUtf()).isEqualTo("101002081");
        assertThat(payload.get("senderName").asUtf()).isEqualTo("M7MED");
        assertThat(payload.get("message").asUtf()).isEqualTo("test");
    }

    private SmartFoxPacket requestPacket(String command, int rid, Map<String, Object> data) {
        Map<String, SmartFoxValue> payload = new LinkedHashMap<>();
        payload.put("data", SmartFoxValues.fromPlain(data));
        payload.put("sn", SmartFoxValue.utf(command));
        payload.put("ts", SmartFoxValue.longValue(1780238345L));
        payload.put("rid", SmartFoxValue.longValue(rid));

        Map<String, SmartFoxValue> params = new LinkedHashMap<>();
        params.put("r", SmartFoxValue.intValue(-1));
        params.put("p", SmartFoxValue.object(payload));
        params.put("c", SmartFoxValue.utf(command));
        Map<String, SmartFoxValue> root = new LinkedHashMap<>();
        root.put("c", SmartFoxValue.byteValue(1));
        root.put("a", SmartFoxValue.shortValue(13));
        root.put("p", SmartFoxValue.object(params));
        return new SmartFoxPacket(new SmartFoxPacketHeader(true, false, false, false, false, 0), SmartFoxValue.object(root));
    }
}