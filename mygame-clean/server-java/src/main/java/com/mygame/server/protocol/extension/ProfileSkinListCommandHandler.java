package com.mygame.server.protocol.extension;

import com.mygame.server.smartfox.SmartFoxPacket;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.stereotype.Component;

@Component
public class ProfileSkinListCommandHandler extends AbstractPanelCommandHandler {
    @Override
    public String command() {
        return "profileskinlist";
    }

    @Override
    protected Map<String, Object> payload(SmartFoxPacket packet) {
        Map<String, Object> payload = new LinkedHashMap<>();
        payload.put("items", Map.of("list", List.of(), "page", 1));
        payload.put("pageSelected", 1);
        payload.put("totalPages", 0);
        payload.put("rid", requestRid(packet));
        payload.put("nextRequest", 1000);
        payload.put("ts", requestTimestamp(packet));
        return payload;
    }
}