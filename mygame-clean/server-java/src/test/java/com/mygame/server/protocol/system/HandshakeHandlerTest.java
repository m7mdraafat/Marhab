package com.mygame.server.protocol.system;

import static org.assertj.core.api.Assertions.assertThat;

import com.mygame.server.smartfox.SmartFoxPacket;
import com.mygame.server.smartfox.SmartFoxPacketCodec;
import com.mygame.server.smartfox.SmartFoxValue;
import java.util.LinkedHashMap;
import java.util.Map;
import org.junit.jupiter.api.Test;

class HandshakeHandlerTest {
    @Test
    void returnsCapturedSmartFoxHandshakeShape() {
        HandshakeHandler handler = new HandshakeHandler();

        SmartFoxPacket response = SmartFoxPacketCodec.decode(
            SmartFoxPacketCodec.encode(handler.responseRoot("0123456789abcdef0123456789abcdef"))
        );

        assertThat(response.controller()).isEqualTo(0);
        assertThat(response.action()).isEqualTo(0);
        assertThat(response.params().asObject().get("tk").asUtf()).isEqualTo("0123456789abcdef0123456789abcdef");
        assertThat(response.params().asObject().get("ct").asInt()).isEqualTo(1024);
        assertThat(response.params().asObject().get("ms").asInt()).isEqualTo(500_000);
    }

    @Test
    void handlesClientHandshakePacket() {
        HandshakeHandler handler = new HandshakeHandler();
        SmartFoxPacket request = SmartFoxPacketCodec.decode(SmartFoxPacketCodec.encode(clientHandshakeRoot()));

        SmartFoxPacket response = SmartFoxPacketCodec.decode(handler.handle("connection-1", request));

        assertThat(response.controller()).isEqualTo(0);
        assertThat(response.action()).isEqualTo(0);
        assertThat(response.params().asObject().get("tk").asUtf()).hasSize(32);
    }

    private SmartFoxValue clientHandshakeRoot() {
        Map<String, SmartFoxValue> params = new LinkedHashMap<>();
        params.put("api", SmartFoxValue.utf("1.7.9"));
        params.put("cl", SmartFoxValue.utf("Flash"));

        Map<String, SmartFoxValue> root = new LinkedHashMap<>();
        root.put("c", SmartFoxValue.byteValue(0));
        root.put("a", SmartFoxValue.shortValue(0));
        root.put("p", SmartFoxValue.object(params));
        return SmartFoxValue.object(root);
    }
}