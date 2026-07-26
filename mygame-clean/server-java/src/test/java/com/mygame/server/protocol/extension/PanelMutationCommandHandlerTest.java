package com.mygame.server.protocol.extension;

import static org.assertj.core.api.Assertions.assertThat;

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

class PanelMutationCommandHandlerTest {
    @Test
    void useHandItemUpdatesHandAndReturnsCapturedSuccessShape() {
        SessionRegistry sessionRegistry = new SessionRegistry();
        sessionRegistry.createDevSession("connection-1", "marhab");
        UseHandItemCommandHandler handler = new UseHandItemCommandHandler(sessionRegistry);

        List<byte[]> responses = handler.handle("connection-1", requestPacket("usehanditem", 78, Map.of("id", 4055317)));

        SmartFoxPacket handUpdate = SmartFoxPacketCodec.decode(responses.get(0));
        SmartFoxPacket speedUpdate = SmartFoxPacketCodec.decode(responses.get(1));
        SmartFoxPacket response = SmartFoxPacketCodec.decode(responses.get(2));
        Map<String, SmartFoxValue> payload = response.params().asObject().get("p").asObject();

        assertThat(handUpdate.params().asObject().get("vl").asArray().getFirst().asArray().get(0).asUtf()).isEqualTo("hand");
        assertThat(speedUpdate.params().asObject().get("vl").asArray().getFirst().asArray().get(0).asUtf()).isEqualTo("speed");
        assertThat(payload.get("status").asUtf()).isEqualTo("success");
        assertThat(payload.get("rid").asLong()).isEqualTo(78);
        assertThat(sessionRegistry.findByConnectionId("connection-1").orElseThrow().handItem()).isEqualTo("kf");
    }

    @Test
    void changeSmileyUpdatesSessionAndUserVariable() {
        SessionRegistry sessionRegistry = new SessionRegistry();
        sessionRegistry.createDevSession("connection-1", "marhab");
        ChangeSmileyCommandHandler handler = new ChangeSmileyCommandHandler(sessionRegistry);

        List<byte[]> responses = handler.handle("connection-1", requestPacket("changesmiley", 12, Map.of("smiley", "happy")));

        SmartFoxPacket smileyUpdate = SmartFoxPacketCodec.decode(responses.get(0));
        assertThat(smileyUpdate.params().asObject().get("vl").asArray().getFirst().asArray().get(0).asUtf()).isEqualTo("smiley");
        assertThat(sessionRegistry.findByConnectionId("connection-1").orElseThrow().smiley()).isEqualTo("happy");
    }

    @Test
    void changeClothesUpdatesSessionAndUserVariable() {
        SessionRegistry sessionRegistry = new SessionRegistry();
        sessionRegistry.createDevSession("connection-1", "marhab");
        ChangeClothesCommandHandler handler = new ChangeClothesCommandHandler(sessionRegistry);

        List<byte[]> responses = handler.handle("connection-1", requestPacket("changeclothes", 13, Map.of("clothes", "[\"A_2\"]")));

        SmartFoxPacket clothesUpdate = SmartFoxPacketCodec.decode(responses.get(0));
        assertThat(clothesUpdate.params().asObject().get("vl").asArray().getFirst().asArray().get(0).asUtf()).isEqualTo("clothes");
        assertThat(sessionRegistry.findByConnectionId("connection-1").orElseThrow().clothes()).isEqualTo("[\"A_2\"]");
    }

    @Test
    void useDefaultChatBalloonUpdatesSessionAndReturnsCapturedTypoShape() {
        SessionRegistry sessionRegistry = new SessionRegistry();
        sessionRegistry.createDevSession("connection-1", "marhab");
        UseChatBalloonCommandHandler handler = new UseChatBalloonCommandHandler(sessionRegistry);

        List<byte[]> responses = handler.handle("connection-1", requestPacket("usechatballoon", 96, Map.of("id", 1)));

        SmartFoxPacket variableUpdate = SmartFoxPacketCodec.decode(responses.get(0));
        SmartFoxPacket response = SmartFoxPacketCodec.decode(responses.get(1));
        Map<String, SmartFoxValue> payload = response.params().asObject().get("p").asObject();

        assertThat(variableUpdate.params().asObject().get("vl").asArray().getFirst().asArray().get(0).asUtf()).isEqualTo("chatBalloon");
        assertThat(payload.get("chatBaloon").asInt()).isEqualTo(1);
        assertThat(payload.get("rid").asLong()).isEqualTo(96);
        assertThat(sessionRegistry.findByConnectionId("connection-1").orElseThrow().chatBalloon()).isEqualTo("1");
    }

    @Test
    void usePaidChatBalloonWithoutRequiredRoleReturnsRoleErrorAndDoesNotMutateSession() {
        SessionRegistry sessionRegistry = new SessionRegistry();
        sessionRegistry.createDevSession("connection-1", "marhab");
        UseChatBalloonCommandHandler handler = new UseChatBalloonCommandHandler(sessionRegistry);

        List<byte[]> responses = handler.handle("connection-1", requestPacket("usechatballoon", 97, Map.of("id", 23)));

        SmartFoxPacket response = SmartFoxPacketCodec.decode(responses.getFirst());
        Map<String, SmartFoxValue> payload = response.params().asObject().get("p").asObject();

        assertThat(responses).hasSize(1);
        assertThat(payload.get("errorCode").asUtf()).isEqualTo("INSUFFICIENT_ROLE");
        assertThat(payload.get("message").asUtf()).isEqualTo("7");
        assertThat(payload.get("rid").asLong()).isEqualTo(97);
        assertThat(sessionRegistry.findByConnectionId("connection-1").orElseThrow().chatBalloon()).isEqualTo("1");
    }

    private SmartFoxPacket requestPacket(String command, int rid, Map<String, Object> data) {
        Map<String, SmartFoxValue> payload = new LinkedHashMap<>();
        payload.put("data", SmartFoxValues.fromPlain(data));
        payload.put("sn", SmartFoxValue.utf(command));
        payload.put("ts", SmartFoxValue.longValue(1780232648L));
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