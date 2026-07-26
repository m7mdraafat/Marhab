package com.mygame.server.protocol.extension;

import com.mygame.server.game.roles.AvatarRoleCatalog;
import com.mygame.server.smartfox.SmartFoxPacket;
import com.mygame.server.smartfox.SmartFoxPacketCodec;
import com.mygame.server.smartfox.SmartFoxValue;
import com.mygame.server.smartfox.SmartFoxValues;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Component
public class ConfigCommandHandler implements ExtensionCommandHandler {
    @Value("${mygame.web.host:127.0.0.1:8080}")
    private String webHost = "127.0.0.1:8080";

    @Value("${mygame.cdn.public-host:127.0.0.1:8080}")
    private String cdnPublicHost = "127.0.0.1:8080";

    @Override
    public String command() {
        return "config";
    }

    @Override
    public List<byte[]> handle(String connectionId, SmartFoxPacket packet) {
        return List.of(SmartFoxPacketCodec.encode(responseRoot()));
    }

    SmartFoxValue responseRoot() {
        Map<String, Object> payload = new LinkedHashMap<>();
        payload.put("farmMaxPlantedItemSize", 12);
        payload.put("itemFile", "data/ifile.2013");
        payload.put("webServer", webHost);
        payload.put("moods", moods());
        payload.put("language", "ar");
        payload.put("diamondExchangeRate", 30);
        payload.put("rid", 0);
        payload.put("version", 92);
        payload.put("roomTheme", List.of("fest", "ramadan"));
        payload.put("fileServer", List.of(cdnPublicHost));
        payload.put("masterRoles", masterRoles());
        payload.put("langFile", "locale/ar_AR.702");
        payload.put("versionFile", "data/vf.19910");
        payload.put("farmCleaningCost", 10);
        payload.put("chatBaloons", chatBalloons());
        payload.put("order", orderConfig());

        Map<String, SmartFoxValue> params = new LinkedHashMap<>();
        params.put("p", SmartFoxValues.fromPlain(payload));
        params.put("c", SmartFoxValue.utf(command()));

        Map<String, SmartFoxValue> root = new LinkedHashMap<>();
        root.put("c", SmartFoxValue.byteValue(1));
        root.put("a", SmartFoxValue.shortValue(13));
        root.put("p", SmartFoxValue.object(params));
        return SmartFoxValue.object(root);
    }

    private List<Map<String, Object>> moods() {
        return List.of(
            Map.of("id", 0, "label", "Cheerful"),
            Map.of("id", 1, "label", "Peaceful"),
            Map.of("id", 2, "label", "Crazy"),
            Map.of("id", 3, "label", "Run Down"),
            Map.of("id", 4, "label", "Unhappy"),
            Map.of("id", 5, "label", "Nervous"),
            Map.of("id", 6, "label", "Broken Heart"),
            Map.of("id", 7, "label", "Pessimistic"),
            Map.of("id", 8, "label", "Pensive"),
            Map.of("id", 9, "label", "Energetic"),
            Map.of("id", 10, "label", "Romantical"),
            Map.of("id", 11, "label", "Sensitive"),
            Map.of("id", 12, "label", "Excited"),
            Map.of("id", 13, "label", "Curious"),
            Map.of("id", 14, "label", "Depressed"),
            Map.of("id", 15, "label", "Unstable"),
            Map.of("id", 16, "label", "Worried"),
            Map.of("id", 17, "label", "Thoughtful"),
            Map.of("id", 18, "label", "Mysterious"),
            Map.of("id", 19, "label", "Mixed"),
            Map.of("id", 20, "label", "Optimistic"),
            Map.of("id", 21, "label", "Confused"),
            Map.of("id", 22, "label", "Sucks"),
            Map.of("id", 23, "label", "Resents"),
            Map.of("id", 24, "label", "Desperate"),
            Map.of("id", 25, "label", "Regret"),
            Map.of("id", 26, "label", "Alone"),
            Map.of("id", 27, "label", "Questionable"),
            Map.of("id", 28, "label", "Lethargic"),
            Map.of("id", 29, "label", "Approachable"),
            Map.of("id", 30, "label", "Stressful")
        );
    }

    private List<Map<String, Object>> masterRoles() {
        return AvatarRoleCatalog.masterRoles();
    }

    private List<Map<String, Object>> chatBalloons() {
        return AvatarRoleCatalog.chatBalloons();
    }

    private Map<String, Object> orderConfig() {
        Map<String, Object> order = new LinkedHashMap<>();
        order.put("customerGainMin", 10);
        order.put("avatarOrderLifeTime", 14400);
        order.put("prepareLifeTime", 30);
        order.put("orderLifeTime", 240);
        order.put("customerGainMax", 100);
        order.put("maxOrder", 10);
        return order;
    }
}