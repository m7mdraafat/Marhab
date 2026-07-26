package com.mygame.server.protocol.system;

import com.mygame.server.smartfox.SmartFoxPacket;
import com.mygame.server.smartfox.SmartFoxPacketCodec;
import com.mygame.server.smartfox.SmartFoxValue;
import java.security.SecureRandom;
import java.util.HexFormat;
import java.util.LinkedHashMap;
import java.util.Map;
import org.springframework.stereotype.Component;

@Component
public class HandshakeHandler {
    public static final int COMPRESSION_THRESHOLD = 1024;
    public static final int MAX_MESSAGE_SIZE = 500_000;

    private final SecureRandom secureRandom = new SecureRandom();

    public byte[] handle(String connectionId, SmartFoxPacket packet) {
        if (packet.controller() != 0 || packet.action() != 0) {
            throw new IllegalArgumentException("HandshakeHandler can only handle controller 0 action 0");
        }

        return SmartFoxPacketCodec.encode(responseRoot(newSessionToken()));
    }

    SmartFoxValue responseRoot(String sessionToken) {
        Map<String, SmartFoxValue> params = new LinkedHashMap<>();
        params.put("tk", SmartFoxValue.utf(sessionToken));
        params.put("ct", SmartFoxValue.intValue(COMPRESSION_THRESHOLD));
        params.put("ms", SmartFoxValue.intValue(MAX_MESSAGE_SIZE));

        Map<String, SmartFoxValue> root = new LinkedHashMap<>();
        root.put("c", SmartFoxValue.byteValue(0));
        root.put("a", SmartFoxValue.shortValue(0));
        root.put("p", SmartFoxValue.object(params));
        return SmartFoxValue.object(root);
    }

    private String newSessionToken() {
        byte[] bytes = new byte[16];
        secureRandom.nextBytes(bytes);
        return HexFormat.of().formatHex(bytes);
    }
}