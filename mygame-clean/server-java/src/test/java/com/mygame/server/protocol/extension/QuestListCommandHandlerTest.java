package com.mygame.server.protocol.extension;

import static org.assertj.core.api.Assertions.assertThat;

import com.mygame.server.smartfox.SmartFoxPacket;
import com.mygame.server.smartfox.SmartFoxPacketCodec;
import com.mygame.server.smartfox.SmartFoxPacketHeader;
import com.mygame.server.smartfox.SmartFoxValue;
import java.util.LinkedHashMap;
import java.util.Map;
import org.junit.jupiter.api.Test;

class QuestListCommandHandlerTest {
    @Test
    void returnsEmptyQuestListWithRequestMetadata() {
        QuestListCommandHandler handler = new QuestListCommandHandler();

        SmartFoxPacket response = SmartFoxPacketCodec.decode(SmartFoxPacketCodec.encode(handler.responseRoot(requestPacket(5, 1780236498))));
        Map<String, SmartFoxValue> params = response.params().asObject();
        Map<String, SmartFoxValue> payload = params.get("p").asObject();

        assertThat(response.controller()).isEqualTo(1);
        assertThat(response.action()).isEqualTo(13);
        assertThat(params.get("c").asUtf()).isEqualTo("questlist");
        assertThat(payload.get("quests").asArray()).isEmpty();
        assertThat(payload.get("rid").asInt()).isEqualTo(5);
        assertThat(payload.get("nextRequest").asInt()).isEqualTo(1000);
        assertThat(payload.get("ts").asLong()).isEqualTo(1780236498);
    }

    private SmartFoxPacket requestPacket(int rid, long timestamp) {
        Map<String, SmartFoxValue> requestPayload = new LinkedHashMap<>();
        requestPayload.put("rid", SmartFoxValue.longValue(rid));
        requestPayload.put("ts", SmartFoxValue.longValue(timestamp));

        Map<String, SmartFoxValue> params = new LinkedHashMap<>();
        params.put("p", SmartFoxValue.object(requestPayload));
        params.put("c", SmartFoxValue.utf("questlist"));
        Map<String, SmartFoxValue> root = new LinkedHashMap<>();
        root.put("c", SmartFoxValue.byteValue(1));
        root.put("a", SmartFoxValue.shortValue(13));
        root.put("p", SmartFoxValue.object(params));
        return new SmartFoxPacket(new SmartFoxPacketHeader(true, false, false, false, false, 0), SmartFoxValue.object(root));
    }
}