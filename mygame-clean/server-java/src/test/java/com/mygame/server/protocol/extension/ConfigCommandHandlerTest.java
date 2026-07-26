package com.mygame.server.protocol.extension;

import static org.assertj.core.api.Assertions.assertThat;

import com.mygame.server.smartfox.SmartFoxPacket;
import com.mygame.server.smartfox.SmartFoxPacketCodec;
import java.util.Map;
import org.junit.jupiter.api.Test;

class ConfigCommandHandlerTest {
    @Test
    void returnsCapturedConfigShape() {
        ConfigCommandHandler handler = new ConfigCommandHandler();

        SmartFoxPacket response = SmartFoxPacketCodec.decode(SmartFoxPacketCodec.encode(handler.responseRoot()));
        Map<String, com.mygame.server.smartfox.SmartFoxValue> params = response.params().asObject();
        Map<String, com.mygame.server.smartfox.SmartFoxValue> payload = params.get("p").asObject();

        assertThat(response.controller()).isEqualTo(1);
        assertThat(response.action()).isEqualTo(13);
        assertThat(params.get("c").asUtf()).isEqualTo("config");
        assertThat(payload.get("itemFile").asUtf()).isEqualTo("data/ifile.2013");
        assertThat(payload.get("webServer").asUtf()).isEqualTo("127.0.0.1:8080");
        assertThat(payload.get("fileServer").asArray().getFirst().asUtf()).isEqualTo("127.0.0.1:8080");
        assertThat(payload.get("langFile").asUtf()).isEqualTo("locale/ar_AR.702");
        assertThat(payload.get("versionFile").asUtf()).isEqualTo("data/vf.19910");
        assertThat(payload.get("language").asUtf()).isEqualTo("ar");
        assertThat(payload.get("version").asInt()).isEqualTo(92);
        assertThat(payload.get("moods").asArray()).hasSize(31);
        assertThat(payload.get("masterRoles").asArray()).hasSize(50);
        assertThat(payload.get("chatBaloons").asArray()).hasSize(9);
        assertThat(payload.get("masterRoles").asArray().stream()
            .map(role -> role.asObject())
            .filter(role -> role.get("name").asUtf().equals("SECURITY"))
            .findFirst().orElseThrow().get("index").asInt()).isEqualTo(40);
        assertThat(payload.get("masterRoles").asArray().stream()
            .map(role -> role.asObject())
            .filter(role -> role.get("name").asUtf().equals("CARD_MUSIC"))
            .findFirst().orElseThrow().get("index").asInt()).isEqualTo(43);
    }
}