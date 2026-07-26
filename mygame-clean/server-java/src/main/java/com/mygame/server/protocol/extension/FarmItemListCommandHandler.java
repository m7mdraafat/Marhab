package com.mygame.server.protocol.extension;

import com.mygame.server.smartfox.SmartFoxPacket;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.stereotype.Component;

@Component
public class FarmItemListCommandHandler extends AbstractPanelCommandHandler {
    @Override
    public String command() {
        return "farmitemlist";
    }

    @Override
    protected Map<String, Object> payload(SmartFoxPacket packet) {
        Map<String, Object> payload = new LinkedHashMap<>();
        payload.put("items", List.of());
        payload.put("list", List.of());
        payload.put("page", 1);
        payload.put("pageCount", 0);
        payload.put("total", 0);
        return payload;
    }
}