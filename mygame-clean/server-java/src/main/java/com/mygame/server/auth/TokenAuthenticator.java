package com.mygame.server.auth;

import com.mygame.server.game.avatar.AvatarState;
import java.util.Optional;

public interface TokenAuthenticator {
    Optional<AvatarState> authenticateToken(String token);
}