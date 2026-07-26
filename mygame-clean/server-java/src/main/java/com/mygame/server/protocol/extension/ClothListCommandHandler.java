package com.mygame.server.protocol.extension;

import com.mygame.server.smartfox.SmartFoxPacket;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.stereotype.Component;

@Component
public class ClothListCommandHandler extends AbstractPanelCommandHandler {
    @Override
    public String command() {
        return "clothlist";
    }

    @Override
    protected Map<String, Object> payload(SmartFoxPacket packet) {
        return listPayload(packet, "CLOTH", defaultClothesItems());
    }

    private List<Map<String, Object>> defaultClothesItems() {
        return List.of("A_2", "B_2", "C_2", "8_9", "1_9", "4_9", "7_10").stream().map(clip -> {
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("quantity", 1);
            item.put("color", 1);
            item.put("productID", 4);
            item.put("roles", "AA==");
            item.put("active", 1);
            item.put("source", "FREE");
            item.put("createdAt", "2016-10-07 06:01:59.0");
            item.put("expire", 0);
            item.put("transferrable", false);
            item.put("subType", "COSTUME");
            item.put("id", 6262);
            item.put("lifeTime", -1);
            item.put("timeLeft", -1);
            item.put("clip", clip);
            item.put("base", 1);
            return item;
        }).toList();
    }
}