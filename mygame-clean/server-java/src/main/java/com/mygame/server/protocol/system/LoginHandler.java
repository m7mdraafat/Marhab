package com.mygame.server.protocol.system;

import com.mygame.server.auth.TokenAuthenticator;
import com.mygame.server.game.avatar.AvatarState;
import com.mygame.server.game.persistence.AvatarSettingsService;
import com.mygame.server.game.session.GameSession;
import com.mygame.server.game.session.SessionRegistry;
import com.mygame.server.smartfox.SmartFoxPacket;
import com.mygame.server.smartfox.SmartFoxPacketCodec;
import com.mygame.server.smartfox.SmartFoxValue;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class LoginHandler {
    private static final Logger log = LoggerFactory.getLogger(LoginHandler.class);

    private static final String DEFAULT_ZONE = "marhab";

    private final SessionRegistry sessionRegistry;
    private final TokenAuthenticator tokenAuthenticator;
    private final AvatarSettingsService avatarSettingsService;

    @Autowired
    public LoginHandler(
        SessionRegistry sessionRegistry,
        TokenAuthenticator tokenAuthenticator,
        AvatarSettingsService avatarSettingsService
    ) {
        this.sessionRegistry = sessionRegistry;
        this.tokenAuthenticator = tokenAuthenticator;
        this.avatarSettingsService = avatarSettingsService;
    }

    // Test seam: no persisted-setting hydration, in-memory session only.
    LoginHandler(SessionRegistry sessionRegistry, TokenAuthenticator tokenAuthenticator) {
        this(sessionRegistry, tokenAuthenticator, null);
    }

    public byte[] handle(String connectionId, SmartFoxPacket packet) {
        if (packet.controller() != 0 || packet.action() != 1) {
            throw new IllegalArgumentException("LoginHandler can only handle controller 0 action 1");
        }

        String requestedZone = requestedZone(packet);
        String effectiveZone = requestedZone == null || requestedZone.isBlank() || "local".equalsIgnoreCase(requestedZone)
            ? DEFAULT_ZONE
            : requestedZone;
        String token = token(packet);
        AvatarState avatar = tokenAuthenticator.authenticateToken(token).orElseGet(AvatarState::guestBootstrap);
        GameSession session = sessionRegistry.createSession(connectionId, effectiveZone, avatar);
        if (avatarSettingsService != null) {
            avatarSettingsService.hydrate(session);
        }

        log.info(
            "SmartFox login accepted connectionId={} zone={} avatarId={} privilegeId={}",
            connectionId,
            effectiveZone,
            session.avatar().avatarId(),
            session.avatar().privilegeId()
        );

        return SmartFoxPacketCodec.encode(responseRoot(session));
    }

    public void disconnect(String connectionId) {
        sessionRegistry.remove(connectionId);
    }

    public byte[] handleLogout(String connectionId) {
        GameSession session = sessionRegistry.findByConnectionId(connectionId).orElse(null);
        String zone = session == null ? DEFAULT_ZONE : session.zone();
        sessionRegistry.remove(connectionId);

        Map<String, SmartFoxValue> params = new LinkedHashMap<>();
        params.put("zn", SmartFoxValue.utf(zone));

        Map<String, SmartFoxValue> root = new LinkedHashMap<>();
        root.put("c", SmartFoxValue.byteValue(0));
        root.put("a", SmartFoxValue.shortValue(2));
        root.put("p", SmartFoxValue.object(params));
        return SmartFoxPacketCodec.encode(SmartFoxValue.object(root));
    }

    SmartFoxValue responseRoot(GameSession session) {
        Map<String, SmartFoxValue> params = new LinkedHashMap<>();
        params.put("p", SmartFoxValue.object(Map.of("$FS_NEW_LOGIN_NAME", SmartFoxValue.utf(session.avatar().avatarId()))));
        params.put("rs", SmartFoxValue.shortValue(100));
        params.put("zn", SmartFoxValue.utf(session.zone()));
        params.put("un", SmartFoxValue.utf(session.avatar().avatarId()));
        params.put("pi", SmartFoxValue.shortValue(session.avatar().privilegeId()));
        params.put("rl", roomList());
        params.put("id", SmartFoxValue.intValue((int) session.avatar().userId()));

        Map<String, SmartFoxValue> root = new LinkedHashMap<>();
        root.put("c", SmartFoxValue.byteValue(0));
        root.put("a", SmartFoxValue.shortValue(1));
        root.put("p", SmartFoxValue.object(params));
        return SmartFoxValue.object(root);
    }

    private SmartFoxValue roomList() {
        return SmartFoxValue.array(List.of(
            roomTuple(24, "w1#airport", "default", 0, 300),
            roomTuple(190, "chat", "default", 0, 500),
            roomTuple(1, "w1#pier", "default", 0, 300),
            roomTuple(25, "w1#nriettaLobby", "default", 0, 300),
            roomTuple(49, "w1#realEstate", "default", 0, 300),
            roomTuple(60, "w1#oyunika", "default", 0, 300)
        ));
    }

    private SmartFoxValue roomTuple(int id, String name, String group, int userCount, int maxUsers) {
        return SmartFoxValue.array(List.of(
            SmartFoxValue.intValue(id),
            SmartFoxValue.utf(name),
            SmartFoxValue.utf(group),
            SmartFoxValue.bool(false),
            SmartFoxValue.bool(false),
            SmartFoxValue.bool(false),
            SmartFoxValue.shortValue(userCount),
            SmartFoxValue.shortValue(maxUsers),
            SmartFoxValue.array(List.of())
        ));
    }

    private String requestedZone(SmartFoxPacket packet) {
        SmartFoxValue zone = packet.params().asObject().get("zn");
        if (zone == null || zone.value() == null) {
            return null;
        }
        return zone.asUtf();
    }

    private String token(SmartFoxPacket packet) {
        SmartFoxValue params = packet.params().asObject().get("p");
        if (params == null || params.value() == null) {
            return "";
        }
        Map<String, SmartFoxValue> object = params.asObject();
        SmartFoxValue token = object.get("token");
        if (token == null) {
            token = object.get("at");
        }
        if (token == null || token.value() == null) {
            return "";
        }
        return token.asUtf();
    }
}