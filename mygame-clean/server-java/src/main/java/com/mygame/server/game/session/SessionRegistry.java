package com.mygame.server.game.session;

import com.mygame.server.game.avatar.AvatarState;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;
import org.springframework.stereotype.Component;

@Component
public class SessionRegistry {
    private final Map<String, GameSession> sessionsByConnectionId = new ConcurrentHashMap<>();

    public GameSession createDevSession(String connectionId, String zone) {
        return createSession(connectionId, zone, AvatarState.devDefault());
    }

    public GameSession createGuestBootstrapSession(String connectionId, String zone) {
        return createSession(connectionId, zone, AvatarState.guestBootstrap());
    }

    public GameSession createSession(String connectionId, String zone, AvatarState avatar) {
        GameSession session = new GameSession(connectionId, zone, avatar);
        sessionsByConnectionId.put(connectionId, session);
        return session;
    }

    public Optional<GameSession> findByConnectionId(String connectionId) {
        return Optional.ofNullable(sessionsByConnectionId.get(connectionId));
    }

    public List<GameSession> sessions() {
        return List.copyOf(sessionsByConnectionId.values());
    }

    public void remove(String connectionId) {
        sessionsByConnectionId.remove(connectionId);
    }
}