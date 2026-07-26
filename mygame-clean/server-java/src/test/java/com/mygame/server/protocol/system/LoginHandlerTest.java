package com.mygame.server.protocol.system;

import static org.assertj.core.api.Assertions.assertThat;

import com.mygame.server.auth.TokenAuthenticator;
import com.mygame.server.game.avatar.AvatarState;
import com.mygame.server.game.session.GameSession;
import com.mygame.server.game.session.SessionRegistry;
import com.mygame.server.smartfox.SmartFoxPacket;
import com.mygame.server.smartfox.SmartFoxPacketCodec;
import com.mygame.server.smartfox.SmartFoxValue;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Optional;
import org.junit.jupiter.api.Test;

class LoginHandlerTest {
    @Test
    void returnsCapturedSmartFoxLoginShape() {
        LoginHandler handler = new LoginHandler(new SessionRegistry(), token -> Optional.of(AvatarState.devDefault()));

        SmartFoxPacket response = SmartFoxPacketCodec.decode(handler.handle("connection-1", clientLoginRoot()));

        assertThat(response.controller()).isEqualTo(0);
        assertThat(response.action()).isEqualTo(1);
        assertThat(response.params().asObject().get("zn").asUtf()).isEqualTo("marhab");
        assertThat(response.params().asObject().get("un").asUtf()).isEqualTo("101002081");
        assertThat(response.params().asObject().get("id").asInt()).isEqualTo(1);
        assertThat(response.params().asObject().get("pi").asInt()).isEqualTo(1);
        assertThat(response.params().asObject().get("rs").asInt()).isEqualTo(100);
        assertThat(response.params().asObject().get("p").asObject().get("$FS_NEW_LOGIN_NAME").asUtf()).isEqualTo("101002081");
        assertThat(response.params().asObject().get("rl").asArray()).isNotEmpty();
    }

    @Test
    void createsSessionForConnection() {
        SessionRegistry registry = new SessionRegistry();
        LoginHandler handler = new LoginHandler(registry, token -> Optional.of(AvatarState.devDefault()));

        handler.handle("connection-1", clientLoginRoot());

        GameSession session = registry.findByConnectionId("connection-1").orElseThrow();
        assertThat(session.zone()).isEqualTo("marhab");
        assertThat(session.avatar().avatarId()).isEqualTo("101002081");
    }

    @Test
    void noTokenCreatesGuestBootstrapSessionForGuestPanel() {
        SessionRegistry registry = new SessionRegistry();
        LoginHandler handler = new LoginHandler(registry, TokenAuthenticatorStub.empty());

        SmartFoxPacket response = SmartFoxPacketCodec.decode(handler.handle("connection-1", clientLoginRootWithoutToken()));

        assertThat(response.params().asObject().get("zn").asUtf()).isEqualTo("marhab");
        assertThat(response.params().asObject().get("id").asInt()).isEqualTo(4_743);
        assertThat(response.params().asObject().get("pi").asInt()).isEqualTo(0);
        assertThat(registry.findByConnectionId("connection-1").orElseThrow().avatar().privilegeId()).isEqualTo(0);
    }

    @Test
    void logoutReturnsZoneAndRemovesSession() {
        SessionRegistry registry = new SessionRegistry();
        LoginHandler handler = new LoginHandler(registry, token -> Optional.of(AvatarState.devDefault()));
        handler.handle("connection-1", clientLoginRoot());

        SmartFoxPacket response = SmartFoxPacketCodec.decode(handler.handleLogout("connection-1"));

        assertThat(response.controller()).isEqualTo(0);
        assertThat(response.action()).isEqualTo(2);
        assertThat(response.params().asObject().get("zn").asUtf()).isEqualTo("marhab");
        assertThat(registry.findByConnectionId("connection-1")).isEmpty();
    }

    private SmartFoxPacket clientLoginRoot() {
        Map<String, SmartFoxValue> params = new LinkedHashMap<>();
        params.put("zn", SmartFoxValue.utf("local"));
        params.put("un", SmartFoxValue.utf(""));
        params.put("pw", SmartFoxValue.utf(""));
        params.put("p", SmartFoxValue.object(Map.of("at", SmartFoxValue.utf("dev-token"))));

        Map<String, SmartFoxValue> root = new LinkedHashMap<>();
        root.put("c", SmartFoxValue.byteValue(0));
        root.put("a", SmartFoxValue.shortValue(1));
        root.put("p", SmartFoxValue.object(params));
        return SmartFoxPacketCodec.decode(SmartFoxPacketCodec.encode(SmartFoxValue.object(root)));
    }

    private SmartFoxPacket clientLoginRootWithoutToken() {
        Map<String, SmartFoxValue> params = new LinkedHashMap<>();
        params.put("zn", SmartFoxValue.utf("marhab"));
        params.put("un", SmartFoxValue.utf(""));
        params.put("pw", SmartFoxValue.utf(""));
        params.put("p", SmartFoxValue.object(Map.of("clientKey", SmartFoxValue.utf("MARHAB_V2_SSAAASCVVVAAA"))));

        Map<String, SmartFoxValue> root = new LinkedHashMap<>();
        root.put("c", SmartFoxValue.byteValue(0));
        root.put("a", SmartFoxValue.shortValue(1));
        root.put("p", SmartFoxValue.object(params));
        return SmartFoxPacketCodec.decode(SmartFoxPacketCodec.encode(SmartFoxValue.object(root)));
    }

    private record TokenAuthenticatorStub() implements TokenAuthenticator {
        static TokenAuthenticatorStub empty() {
            return new TokenAuthenticatorStub();
        }

        @Override
        public Optional<AvatarState> authenticateToken(String token) {
            return Optional.empty();
        }
    }
}