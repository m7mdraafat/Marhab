package com.mygame.server.protocol.extension;

import com.mygame.server.smartfox.SmartFoxPacket;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.stereotype.Component;

@Component
public class UniverseListCommandHandler extends AbstractPanelCommandHandler {
    @Override
    public String command() {
        return "universelist";
    }

    @Override
    protected Map<String, Object> payload(SmartFoxPacket packet) {
        Map<String, Object> universe = new LinkedHashMap<>();
        universe.put("fullness", 9);
        universe.put("roles", "AA==");
        universe.put("name", "جزيرة مرحب");
        universe.put("roomFullness", 1);
        universe.put("key", "w1");
        universe.put("recommended", true);
        universe.put("roomAvailable", true);

        Map<String, Object> payload = new LinkedHashMap<>();
        payload.put("onlineCount", 1);
        payload.put("universes", List.of(universe));
        payload.put("rid", requestRid(packet));
        payload.put("nextRequest", 1000);
        return payload;
    }
}