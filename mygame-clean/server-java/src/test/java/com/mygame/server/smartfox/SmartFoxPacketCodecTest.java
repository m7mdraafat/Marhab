package com.mygame.server.smartfox;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.Test;

class SmartFoxPacketCodecTest {
    @Test
    void encodesAndDecodesHandshakeResponse() {
        SmartFoxValue packet = SmartFoxValue.object(Map.of(
            "c", SmartFoxValue.byteValue(0),
            "a", SmartFoxValue.shortValue(0),
            "p", SmartFoxValue.object(Map.of(
                "tk", SmartFoxValue.utf("dev-session"),
                "ct", SmartFoxValue.intValue(2_000_000),
                "ms", SmartFoxValue.intValue(500_000)
            ))
        ));

        byte[] encoded = SmartFoxPacketCodec.encode(packet);
        SmartFoxPacket decoded = SmartFoxPacketCodec.decode(encoded);

        assertThat(decoded.controller()).isEqualTo(0);
        assertThat(decoded.action()).isEqualTo(0);
        assertThat(decoded.params().asObject().get("tk").asUtf()).isEqualTo("dev-session");
        assertThat(decoded.params().asObject().get("ct").asInt()).isEqualTo(2_000_000);
        assertThat(decoded.params().asObject().get("ms").asInt()).isEqualTo(500_000);
    }

    @Test
    void supportsUtfArraysAndNestedArrays() {
        SmartFoxValue packet = SmartFoxValue.object(Map.of(
            "c", SmartFoxValue.byteValue(1),
            "a", SmartFoxValue.shortValue(13),
            "p", SmartFoxValue.object(Map.of(
                "c", SmartFoxValue.utf("sample"),
                "roles", SmartFoxValue.utfArray(List.of("AA==", "ACA=")),
                "values", SmartFoxValue.array(List.of(
                    SmartFoxValue.utf("position"),
                    SmartFoxValue.intValue(4),
                    SmartFoxValue.utf("34,26"),
                    SmartFoxValue.bool(false)
                ))
            ))
        ));

        SmartFoxPacket decoded = SmartFoxPacketCodec.decode(SmartFoxPacketCodec.encode(packet));
        Map<String, SmartFoxValue> params = decoded.params().asObject();

        assertThat(decoded.controller()).isEqualTo(1);
        assertThat(decoded.action()).isEqualTo(13);
        assertThat(params.get("c").asUtf()).isEqualTo("sample");
        assertThat(params.get("roles").asUtfArray()).containsExactly("AA==", "ACA=");
        assertThat(params.get("values").asArray().get(2).asUtf()).isEqualTo("34,26");
    }
}