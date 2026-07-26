package com.mygame.server.protocol.extension;

import com.mygame.server.smartfox.SmartFoxPacket;
import com.mygame.server.smartfox.SmartFoxPacketCodec;
import com.mygame.server.smartfox.SmartFoxValue;
import com.mygame.server.smartfox.SmartFoxValues;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.stereotype.Component;

@Component
public class BuddyListCommandHandler implements ExtensionCommandHandler {
    @Override
    public String command() {
        return "buddylist";
    }

    @Override
    public List<byte[]> handle(String connectionId, SmartFoxPacket packet) {
        return List.of(SmartFoxPacketCodec.encode(responseRoot(requestRid(packet))));
    }

    SmartFoxValue responseRoot(int rid) {
        Map<String, Object> payload = new LinkedHashMap<>();
        payload.put("requests", List.of());
        payload.put("rid", rid);
        payload.put("buddies", List.of());
        payload.put("nextRequest", 10000);

        Map<String, SmartFoxValue> params = new LinkedHashMap<>();
        params.put("p", SmartFoxValues.fromPlain(payload));
        params.put("c", SmartFoxValue.utf(command()));

        Map<String, SmartFoxValue> root = new LinkedHashMap<>();
        root.put("c", SmartFoxValue.byteValue(1));
        root.put("a", SmartFoxValue.shortValue(13));
        root.put("p", SmartFoxValue.object(params));
        return SmartFoxValue.object(root);
    }

    private int requestRid(SmartFoxPacket packet) {
        if (packet == null) {
            return 0;
        }
        SmartFoxValue payload = packet.params().asObject().get("p");
        if (payload == null || payload.value() == null) {
            return 0;
        }
        SmartFoxValue rid = payload.asObject().get("rid");
        return rid == null || rid.value() == null ? 0 : (int) rid.asLong();
    }
}