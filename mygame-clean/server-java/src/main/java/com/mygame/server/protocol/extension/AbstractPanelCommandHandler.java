package com.mygame.server.protocol.extension;

import com.mygame.server.smartfox.SmartFoxPacket;
import com.mygame.server.smartfox.SmartFoxPacketCodec;
import com.mygame.server.smartfox.SmartFoxValue;
import com.mygame.server.smartfox.SmartFoxValues;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

abstract class AbstractPanelCommandHandler implements ExtensionCommandHandler {
    @Override
    public List<byte[]> handle(String connectionId, SmartFoxPacket packet) {
        return List.of(SmartFoxPacketCodec.encode(responseRoot(packet)));
    }

    SmartFoxValue responseRoot(SmartFoxPacket packet) {
        return extensionRoot(command(), payload(packet));
    }

    protected SmartFoxValue extensionRoot(String command, Map<String, Object> payload) {
        Map<String, SmartFoxValue> params = new LinkedHashMap<>();
        params.put("p", SmartFoxValues.fromPlain(payload));
        params.put("c", SmartFoxValue.utf(command));

        Map<String, SmartFoxValue> root = new LinkedHashMap<>();
        root.put("c", SmartFoxValue.byteValue(1));
        root.put("a", SmartFoxValue.shortValue(13));
        root.put("p", SmartFoxValue.object(params));
        return SmartFoxValue.object(root);
    }

    protected abstract Map<String, Object> payload(SmartFoxPacket packet);

    protected int requestRid(SmartFoxPacket packet) {
        SmartFoxValue value = requestField(packet, "rid");
        return value == null || value.value() == null ? 0 : (int) value.asLong();
    }

    protected long requestTimestamp(SmartFoxPacket packet) {
        SmartFoxValue value = requestField(packet, "ts");
        return value == null || value.value() == null ? 0 : value.asLong();
    }

    protected Map<String, Object> listPayload(SmartFoxPacket packet, String type, List<Map<String, Object>> items) {
        Map<String, Object> payload = new LinkedHashMap<>();
        payload.put("type", type);
        payload.put("rid", requestRid(packet));
        payload.put("items", items);
        payload.put("nextRequest", 1000);
        payload.put("ts", requestTimestamp(packet));
        return payload;
    }

    private SmartFoxValue requestField(SmartFoxPacket packet, String name) {
        if (packet == null) {
            return null;
        }
        SmartFoxValue payload = packet.params().asObject().get("p");
        if (payload == null || payload.value() == null) {
            return null;
        }
        return payload.asObject().get(name);
    }
}