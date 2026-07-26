package com.mygame.server.protocol.extension;

import com.mygame.server.smartfox.SmartFoxPacket;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.stereotype.Component;

@Component
public class GuideRequestCommandHandler extends AbstractPanelCommandHandler {
    @Override
    public String command() {
        return "guiderequest";
    }

    @Override
    protected Map<String, Object> payload(SmartFoxPacket packet) {
        Map<String, Object> payload = new LinkedHashMap<>();
        payload.put("requests", List.of());
        payload.put("rid", requestRid(packet));
        payload.put("nextRequest", 1000);
        payload.put("ts", requestTimestamp(packet));
        return payload;
    }
}