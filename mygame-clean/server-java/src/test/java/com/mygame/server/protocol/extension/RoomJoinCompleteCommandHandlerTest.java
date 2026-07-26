package com.mygame.server.protocol.extension;

import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import org.junit.jupiter.api.Test;

import com.mygame.server.smartfox.SmartFoxPacket;
import com.mygame.server.smartfox.SmartFoxPacketCodec;
import com.mygame.server.smartfox.SmartFoxValue;

class RoomJoinCompleteCommandHandlerTest {
    @Test
    void returnsEmptyRoomJoinCompletePayload() {
        RoomJoinCompleteCommandHandler handler = new RoomJoinCompleteCommandHandler();

        SmartFoxPacket response = SmartFoxPacketCodec.decode(SmartFoxPacketCodec.encode(handler.responseRoot()));
        Map<String, SmartFoxValue> params = response.params().asObject();

        assertThat(response.controller()).isEqualTo(1);
        assertThat(response.action()).isEqualTo(13);
        assertThat(params.get("c").asUtf()).isEqualTo("roomjoincomplete");
        assertThat(params.get("p").asObject()).isEmpty();
    }
}