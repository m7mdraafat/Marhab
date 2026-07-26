package com.mygame.server.auth;

import java.util.Optional;

public interface AuthBridge {
    Optional<AuthBridgeResult> consumeCompletedAuth();

    AuthBridgeResult createGuestToken();
}