package com.mygame.server.protocol.extension;

import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import org.junit.jupiter.api.Test;

import com.mygame.server.game.session.SessionRegistry;
import com.mygame.server.smartfox.SmartFoxPacket;
import com.mygame.server.smartfox.SmartFoxPacketCodec;
import com.mygame.server.smartfox.SmartFoxValue;

class InitCommandHandlerTest {
    @Test
    void returnsAirportFirstBootstrapFrames() {
        SessionRegistry sessionRegistry = new SessionRegistry();
        sessionRegistry.createDevSession("connection-1", "marhab");
        InitCommandHandler handler = new InitCommandHandler(sessionRegistry, "airport");

        List<SmartFoxPacket> packets = handler.handle("connection-1", null).stream()
            .map(SmartFoxPacketCodec::decode)
            .toList();

        assertThat(packets).hasSize(10);
        assertThat(extensionCommand(packets.get(2))).isEqualTo("initQueue");
        assertThat(extensionCommand(packets.get(3))).isEqualTo("restartServer");
        assertThat(extensionCommand(packets.get(4))).isEqualTo("roles");
        assertThat(extensionCommand(packets.get(8))).isEqualTo("init");

        Map<String, SmartFoxValue> rolesPayload = packets.get(4).params().asObject().get("p").asObject();
        assertThat(rolesPayload.get("roles").asUtf()).isNotBlank();

        Map<String, SmartFoxValue> initPayload = packets.get(8).params().asObject().get("p").asObject();
        assertThat(initPayload.get("createAvatar").asBoolean()).isFalse();
        assertThat(initPayload.get("checkAvatar").asInt()).isEqualTo(1);
        assertThat(initPayload.get("selectedAvatarID").asUtf()).isEqualTo("101002081");
        assertThat(initPayload.get("room").asObject().get("key").asUtf()).isEqualTo("airport");
        assertThat(initPayload.get("room").asObject().get("map").asUtf()).isNotBlank();
        assertThat(initPayload.get("clothes").asObject().get("items").asArray()).hasSize(7);

        SmartFoxPacket roomJoin = packets.get(9);
        assertThat(roomJoin.controller()).isEqualTo(0);
        assertThat(roomJoin.action()).isEqualTo(4);
        List<SmartFoxValue> roomTuple = roomJoin.params().asObject().get("r").asArray();
        List<SmartFoxValue> userList = roomJoin.params().asObject().get("ul").asArray();
        assertThat(roomTuple.get(0).asInt()).isEqualTo(24);
        assertThat(roomTuple.get(1).asUtf()).isEqualTo("w1#airport");
        assertThat(userList).hasSize(1);
        assertThat(userList.getFirst().asArray().get(1).asUtf()).isEqualTo("101002081");
        Map<String, SmartFoxValue> roomVariables = roomVariablesByName(roomTuple.get(8).asArray());
        assertThat(roomVariables.get("doors").asArray().get(2).asUtf()).contains("\"roomKey\":\"street01\"");
        assertThat(roomVariables.get("grid").asArray().get(2).asUtf()).isNotBlank();
        assertThat(roomVariables.get("roomKey").asArray().get(2).asUtf()).isEqualTo("airport");
    }

    @Test
    void canUseStreet01AsConfiguredFirstRoom() {
        SessionRegistry sessionRegistry = new SessionRegistry();
        sessionRegistry.createDevSession("connection-1", "marhab");
        InitCommandHandler handler = new InitCommandHandler(sessionRegistry, "street01");

        SmartFoxPacket init = SmartFoxPacketCodec.decode(handler.handle("connection-1", null).get(8));
        SmartFoxPacket roomJoin = SmartFoxPacketCodec.decode(handler.handle("connection-1", null).get(9));

        assertThat(init.params().asObject().get("p").asObject().get("room").asObject().get("key").asUtf()).isEqualTo("street01");
        assertThat(roomJoin.params().asObject().get("r").asArray().get(1).asUtf()).isEqualTo("w1#street01");
    }

    private String extensionCommand(SmartFoxPacket packet) {
        return packet.params().asObject().get("c").asUtf();
    }

    private Map<String, SmartFoxValue> roomVariablesByName(List<SmartFoxValue> roomVariables) {
        return roomVariables.stream().collect(java.util.stream.Collectors.toMap(variable -> variable.asArray().get(0).asUtf(), variable -> variable));
    }
}