package com.mygame.server.protocol.extension;

import static org.assertj.core.api.Assertions.assertThat;

import com.mygame.server.smartfox.SmartFoxPacket;
import com.mygame.server.smartfox.SmartFoxPacketCodec;
import com.mygame.server.smartfox.SmartFoxValue;
import java.util.Map;
import org.junit.jupiter.api.Test;

class BuddyListCommandHandlerTest {
    @Test
    void returnsEmptyBuddyListWithFloodDelayShape() {
        BuddyListCommandHandler handler = new BuddyListCommandHandler();

        SmartFoxPacket response = SmartFoxPacketCodec.decode(SmartFoxPacketCodec.encode(handler.responseRoot(24)));
        Map<String, SmartFoxValue> params = response.params().asObject();
        Map<String, SmartFoxValue> payload = params.get("p").asObject();

        assertThat(response.controller()).isEqualTo(1);
        assertThat(response.action()).isEqualTo(13);
        assertThat(params.get("c").asUtf()).isEqualTo("buddylist");
        assertThat(payload.get("requests").asArray()).isEmpty();
        assertThat(payload.get("buddies").asArray()).isEmpty();
        assertThat(payload.get("rid").asInt()).isEqualTo(24);
        assertThat(payload.get("nextRequest").asInt()).isEqualTo(10000);
    }
}