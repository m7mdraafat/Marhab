package com.mygame.server.protocol.extension;

import com.mygame.server.smartfox.SmartFoxPacket;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.stereotype.Component;

@Component
public class SmileyListCommandHandler extends AbstractPanelCommandHandler {
    @Override
    public String command() {
        return "smileylist";
    }

    @Override
    protected Map<String, Object> payload(SmartFoxPacket packet) {
        Map<String, Object> payload = new LinkedHashMap<>();
        payload.put("smilies", smilies());
        payload.put("moods", moods());
        payload.put("rid", requestRid(packet));
        payload.put("nextRequest", 1000);
        payload.put("ts", requestTimestamp(packet));
        return payload;
    }

    private List<Map<String, Object>> smilies() {
        return List.of(
            smiley(1, "empty", 0, "AA=="),
            smiley(116, "mutlu", 10, "AA=="),
            smiley(117, "lol", 11, "AA=="),
            smiley(12, "cool", 12, "AA=="),
            smiley(21, "peaceful", 12, "AA=="),
            smiley(14, "flirty", 13, "AA=="),
            smiley(34, "mutsuz", 13, "AA=="),
            smiley(16, "nervous", 13, "AA=="),
            smiley(42, "saskin", 17, "AA=="),
            smiley(2, "cry", 18, "AA=="),
            smiley(36, "olu", 19, "AA=="),
            smiley(19, "ill", 20, "AA=="),
            smiley(47, "uyku", 21, "AA=="),
            smiley(163, "sun", 22, "AA=="),
            smiley(13, "storm", 23, "AA=="),
            smiley(27, "kirik_kalp", 24, "AA==")
        );
    }

    private List<Map<String, Object>> moods() {
        return List.of(
            mood(0, "visitor", "Cheerful"),
            mood(1, "peaceful", "Peaceful"),
            mood(2, "crazy", "Crazy"),
            mood(3, "rundown", "Run Down"),
            mood(4, "unhappy", "Unhappy"),
            mood(5, "nervous", "Nervous"),
            mood(10, "romantical", "Romantical"),
            mood(12, "excited", "Excited"),
            mood(18, "mysterious", "Mysterious"),
            mood(20, "optimistic", "Optimistic")
        );
    }

    private Map<String, Object> smiley(int id, String metaKey, int sorting, String requirements) {
        Map<String, Object> smiley = new LinkedHashMap<>();
        smiley.put("requirements", requirements);
        smiley.put("sorting", sorting);
        smiley.put("metaKey", metaKey);
        smiley.put("id", id);
        return smiley;
    }

    private Map<String, Object> mood(int id, String clip, String label) {
        Map<String, Object> smiley = new LinkedHashMap<>();
        smiley.put("id", id);
        smiley.put("clip", clip);
        smiley.put("label", label);
        smiley.put("name", label);
        smiley.put("active", id == 0 ? 1 : 0);
        return smiley;
    }
}