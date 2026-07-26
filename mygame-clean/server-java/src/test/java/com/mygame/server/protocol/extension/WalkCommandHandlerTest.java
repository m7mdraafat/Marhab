package com.mygame.server.protocol.extension;

import static org.assertj.core.api.Assertions.assertThat;

import com.mygame.server.game.session.SessionRegistry;
import com.mygame.server.smartfox.SmartFoxPacket;
import com.mygame.server.smartfox.SmartFoxPacketCodec;
import com.mygame.server.smartfox.SmartFoxPacketHeader;
import com.mygame.server.smartfox.SmartFoxValue;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.Test;

class WalkCommandHandlerTest {
    @Test
    void walkRequestSetsTargetAndReturnsDoorDelay() {
        SessionRegistry sessionRegistry = new SessionRegistry();
        sessionRegistry.createDevSession("connection-1", "marhab");
        WalkRequestCommandHandler handler = new WalkRequestCommandHandler(sessionRegistry);

        List<byte[]> responses = handler.handle("connection-1", requestPacket("walkrequest", 6, Map.of("x", 4, "y", 0, "door", true)));

        SmartFoxPacket userVariables = SmartFoxPacketCodec.decode(responses.get(0));
        SmartFoxPacket response = SmartFoxPacketCodec.decode(responses.get(1));
        Map<String, SmartFoxValue> payload = response.params().asObject().get("p").asObject();

        assertThat(userVariables.controller()).isEqualTo(0);
        assertThat(userVariables.action()).isEqualTo(12);
        assertThat(payload.get("isDoor").asBoolean()).isTrue();
        assertThat(payload.get("doorX").asInt()).isEqualTo(4);
        assertThat(payload.get("doorY").asInt()).isZero();
        assertThat(payload.get("delay").asInt()).isGreaterThanOrEqualTo(120);
    }

    @Test
    void walkRequestBeforeLoginDoesNotCloseSocketWithException() {
        WalkRequestCommandHandler handler = new WalkRequestCommandHandler(new SessionRegistry());

        List<byte[]> responses = handler.handle("connection-1", requestPacket("walkrequest", 6, Map.of("x", 4, "y", 0)));

        assertThat(responses).isEmpty();
    }

    @Test
    void walkFinalCommitsPositionAndAcknowledgesOriginalRequest() {
        SessionRegistry sessionRegistry = new SessionRegistry();
        sessionRegistry.createDevSession("connection-1", "marhab");
        WalkRequestCommandHandler requestHandler = new WalkRequestCommandHandler(sessionRegistry);
        WalkFinalRequestCommandHandler finalHandler = new WalkFinalRequestCommandHandler(sessionRegistry);

        requestHandler.handle("connection-1", requestPacket("walkrequest", 6, Map.of("x", 4, "y", 0, "door", true)));
        List<byte[]> responses = finalHandler.handle("connection-1", requestPacket("walkfinalrequest", 7, Map.of()));

        SmartFoxPacket positionUpdate = SmartFoxPacketCodec.decode(responses.get(0));
        SmartFoxPacket targetClear = SmartFoxPacketCodec.decode(responses.get(1));
        SmartFoxPacket response = SmartFoxPacketCodec.decode(responses.get(2));
        Map<String, SmartFoxValue> payload = response.params().asObject().get("p").asObject();

        assertThat(positionUpdate.params().asObject().get("vl").asArray().getFirst().asArray().get(2).asUtf()).isEqualTo("4,0");
        assertThat(targetClear.params().asObject().get("vl").asArray().getFirst().asArray().get(0).asUtf()).isEqualTo("target");
        assertThat(payload.get("rid").asInt()).isEqualTo(6);
        assertThat(payload.get("nextRequest").asInt()).isEqualTo(100);
        assertThat(sessionRegistry.findByConnectionId("connection-1").orElseThrow().avatar().position()).isEqualTo("4,0");
    }

    @Test
    void walkFinalBeforeLoginDoesNotCloseSocketWithException() {
        WalkFinalRequestCommandHandler handler = new WalkFinalRequestCommandHandler(new SessionRegistry());

        List<byte[]> responses = handler.handle("connection-1", requestPacket("walkfinalrequest", 7, Map.of()));

        assertThat(responses).isEmpty();
    }

    private SmartFoxPacket requestPacket(String command, int rid, Map<String, Object> data) {
        Map<String, SmartFoxValue> payload = new LinkedHashMap<>();
        payload.put("data", com.mygame.server.smartfox.SmartFoxValues.fromPlain(data));
        payload.put("sn", SmartFoxValue.utf(command));
        payload.put("ts", SmartFoxValue.longValue(1780232507L));
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