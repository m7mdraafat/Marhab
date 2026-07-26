package com.mygame.server.smartfox;

import java.util.Map;

public record SmartFoxPacket(SmartFoxPacketHeader header, SmartFoxValue root) {
    public int controller() {
        return requiredRootField("c").asInt();
    }

    public int action() {
        return requiredRootField("a").asInt();
    }

    public SmartFoxValue params() {
        return requiredRootField("p");
    }

    private SmartFoxValue requiredRootField(String key) {
        Map<String, SmartFoxValue> object = root.asObject();
        SmartFoxValue value = object.get(key);
        if (value == null) {
            throw new IllegalStateException("SmartFox packet missing root field: " + key);
        }
        return value;
    }
}