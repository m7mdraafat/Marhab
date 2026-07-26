package com.mygame.server.protocol.system;

import static org.assertj.core.api.Assertions.assertThat;

import com.mygame.server.game.session.SessionRegistry;
import com.mygame.server.smartfox.SmartFoxPacket;
import com.mygame.server.smartfox.SmartFoxPacketCodec;
import com.mygame.server.smartfox.SmartFoxPacketHeader;
import com.mygame.server.smartfox.SmartFoxValue;
import java.util.LinkedHashMap;
import java.util.Map;
import org.junit.jupiter.api.Test;

class PublicMessageHandlerTest {
    @Test
    void echoesPublicMessageAsSystemActionSeven() {
        SessionRegistry sessionRegistry = new SessionRegistry();
        sessionRegistry.createDevSession("connection-1", "marhab");
        PublicMessageHandler handler = new PublicMessageHandler(sessionRegistry);

        SmartFoxPacket response = SmartFoxPacketCodec.decode(handler.handle("connection-1", requestPacket()));
        Map<String, SmartFoxValue> params = response.params().asObject();

        assertThat(response.controller()).isEqualTo(0);
        assertThat(response.action()).isEqualTo(7);
        assertThat(params.get("u").asInt()).isEqualTo(1);
        assertThat(params.get("m").asUtf()).isEqualTo("hello");
        assertThat(params.get("p").asObject().get("ts").asLong()).isEqualTo(1780232747L);
    }

    private SmartFoxPacket requestPacket() {
        Map<String, SmartFoxValue> extra = new LinkedHashMap<>();
        extra.put("ts", SmartFoxValue.longValue(1780232747L));

        Map<String, SmartFoxValue> params = new LinkedHashMap<>();
        params.put("t", SmartFoxValue.byteValue(0));
        params.put("r", SmartFoxValue.intValue(24));
        params.put("u", SmartFoxValue.intValue(1));
        params.put("m", SmartFoxValue.utf("hello"));
        params.put("p", SmartFoxValue.object(extra));

        Map<String, SmartFoxValue> root = new LinkedHashMap<>();
        root.put("c", SmartFoxValue.byteValue(0));
        root.put("a", SmartFoxValue.shortValue(7));
        root.put("p", SmartFoxValue.object(params));
        return new SmartFoxPacket(new SmartFoxPacketHeader(true, false, false, false, false, 0), SmartFoxValue.object(root));
    }
}