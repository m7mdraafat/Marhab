package com.mygame.server.protocol.extension;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Component;

import com.mygame.server.smartfox.SmartFoxPacket;
import com.mygame.server.smartfox.SmartFoxPacketCodec;
import com.mygame.server.smartfox.SmartFoxValue;

@Component
public class RoomJoinCompleteCommandHandler implements ExtensionCommandHandler {
    @Override
    public String command() {
        return "roomjoincomplete";
    }

    @Override
    public List<byte[]> handle(String connectionId, SmartFoxPacket packet) {
        return List.of(SmartFoxPacketCodec.encode(responseRoot()));
    }

    SmartFoxValue responseRoot() {
        Map<String, SmartFoxValue> params = new LinkedHashMap<>();
        params.put("p", SmartFoxValue.object(Map.of()));
        params.put("c", SmartFoxValue.utf(command()));

        Map<String, SmartFoxValue> root = new LinkedHashMap<>();
        root.put("c", SmartFoxValue.byteValue(1));
        root.put("a", SmartFoxValue.shortValue(13));
        root.put("p", SmartFoxValue.object(params));
        return SmartFoxValue.object(root);
    }
}