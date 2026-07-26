package com.mygame.server.protocol.extension;

import static org.assertj.core.api.Assertions.assertThat;

import com.mygame.server.auth.AuthBridge;
import com.mygame.server.auth.AuthBridgeResult;
import com.mygame.server.game.session.GameSession;
import com.mygame.server.game.session.SessionRegistry;
import com.mygame.server.smartfox.SmartFoxPacket;
import com.mygame.server.smartfox.SmartFoxPacketCodec;
import com.mygame.server.smartfox.SmartFoxValue;
import java.util.Map;
import java.util.Optional;
import org.junit.jupiter.api.Test;

class DitchGuestPanelCommandHandlerTest {
    @Test
    void waitsForWebAuthWhenNoCompletedAuthExists() {
        SessionRegistry sessionRegistry = new SessionRegistry();
        sessionRegistry.createDevSession("connection-1", "marhab");
        DitchGuestPanelCommandHandler handler = new DitchGuestPanelCommandHandler(sessionRegistry, new StubAuthBridge(Optional.empty()));

        assertThat(handler.handle("connection-1", null)).isEmpty();
    }

    @Test
    void returnsExternalAuthCompleteAfterWebRegisterOrLogin() {
        SessionRegistry sessionRegistry = new SessionRegistry();
        sessionRegistry.createGuestBootstrapSession("connection-1", "marhab");
        DitchGuestPanelCommandHandler handler = new DitchGuestPanelCommandHandler(
            sessionRegistry,
            new StubAuthBridge(Optional.of(new AuthBridgeResult("101010400", "registered-token-1", "externalAuthComplete")))
        );

        SmartFoxPacket response = SmartFoxPacketCodec.decode(handler.handle("connection-1", null).getFirst());
        Map<String, SmartFoxValue> params = response.params().asObject();
        Map<String, SmartFoxValue> payload = params.get("p").asObject();

        assertThat(params.get("c").asUtf()).isEqualTo("externalAuthComplete");
        assertThat(payload.get("avatarID").asUtf()).isEqualTo("101010400");
        assertThat(payload.get("token").asUtf()).isEqualTo("registered-token-1");
    }

    private record StubAuthBridge(Optional<AuthBridgeResult> completedAuth) implements AuthBridge {
        @Override
        public Optional<AuthBridgeResult> consumeCompletedAuth() {
            return completedAuth;
        }

        @Override
        public AuthBridgeResult createGuestToken() {
            return new AuthBridgeResult("101002081", "guest-token-1", "externalTokenComplete");
        }
    }
}