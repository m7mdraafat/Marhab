package com.mygame.server.protocol.extension;

import com.mygame.server.game.persistence.AvatarGameDataRepository;
import com.mygame.server.game.session.GameSession;
import com.mygame.server.game.session.SessionRegistry;
import com.mygame.server.smartfox.SmartFoxPacket;
import com.mygame.server.smartfox.SmartFoxPacketCodec;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class AchievementListCommandHandler extends AbstractPanelCommandHandler {
    private final SessionRegistry sessionRegistry;
    private final AvatarGameDataRepository avatarGameDataRepository;

    @Autowired
    public AchievementListCommandHandler(SessionRegistry sessionRegistry, AvatarGameDataRepository avatarGameDataRepository) {
        this.sessionRegistry = sessionRegistry;
        this.avatarGameDataRepository = avatarGameDataRepository;
    }

    AchievementListCommandHandler() {
        this.sessionRegistry = null;
        this.avatarGameDataRepository = null;
    }

    @Override
    public String command() {
        return "achievementlist";
    }

    @Override
    public List<byte[]> handle(String connectionId, SmartFoxPacket packet) {
        if (sessionRegistry == null || avatarGameDataRepository == null) {
            return super.handle(connectionId, packet);
        }
        GameSession session = sessionRegistry.findByConnectionId(connectionId)
            .orElseThrow(() -> new IllegalStateException("No SmartFox session for connection " + connectionId));
        Map<String, Object> payload = new LinkedHashMap<>();
        payload.put("achievements", avatarGameDataRepository.achievements(session.avatar().userId()));
        payload.put("completedAchievementsCount", avatarGameDataRepository.completedAchievementCount(session.avatar().userId()));
        payload.put("rid", requestRid(packet));
        payload.put("nextRequest", 1000);
        payload.put("ts", requestTimestamp(packet));
        return List.of(SmartFoxPacketCodec.encode(extensionRoot(command(), payload)));
    }

    @Override
    protected Map<String, Object> payload(SmartFoxPacket packet) {
        Map<String, Object> payload = new LinkedHashMap<>();
        payload.put("achievements", achievements());
        payload.put("completedAchievementsCount", 0);
        payload.put("rid", requestRid(packet));
        payload.put("nextRequest", 1000);
        payload.put("ts", requestTimestamp(packet));
        return payload;
    }

    private List<Map<String, Object>> achievements() {
        return List.of(
            achievement(4187101, "catchFish", 3, 3, 699, List.of(
                step(1, 10, 699, rewards(100, 10, "fishingBadge1")),
                step(2, 100, 699, rewards(1000, 50, "fishingBadge2")),
                step(3, 1000, 699, rewards(2000, 100, "fishingBadge3"))
            )),
            achievement(4187202, "questmania", 3, 3, 119, List.of(
                step(1, 10, 119, rewards(2000, 30, "questFirstBadge")),
                step(2, 100, 119, rewards(10000, 150, "questSecondBadge")),
                step(3, 1000, 119, rewards(20000, 1000, "questmaniaBadge"))
            )),
            achievement(3719553, "spendDiamond", 2, 3, 3940, List.of(
                step(1, 3000, 3940, rewards(3000, 300, "shoppingBadge1")),
                step(2, 6000, 3940, rewards(6000, 700, "shoppingBadge2")),
                step(3, 20000, 3940, rewards(10000, 2500, "shoppingBadge3"))
            ))
        );
    }

    private Map<String, Object> achievement(int id, String metaKey, int currentStep, int totalStep, int currentValue, List<Map<String, Object>> steps) {
        Map<String, Object> achievement = new LinkedHashMap<>();
        achievement.put("currentStep", currentStep);
        achievement.put("totalStep", totalStep);
        achievement.put("id", id);
        achievement.put("metaKey", metaKey);
        achievement.put("type", "ACHIEVEMENT");
        achievement.put("steps", steps);
        achievement.put("rewardSteps", List.of());
        achievement.put("rewardMultiplier", 1);
        achievement.put("status", currentValue >= requiredValue(steps, currentStep) ? "ONGOING" : "NEW");
        return achievement;
    }

    private Map<String, Object> step(int step, int requirementValue, int currentValue, List<Map<String, Object>> rewards) {
        Map<String, Object> payload = new LinkedHashMap<>();
        payload.put("requirementValue", requirementValue);
        payload.put("step", step);
        payload.put("rewards", rewards);
        payload.put("currentValue", currentValue);
        return payload;
    }

    private List<Map<String, Object>> rewards(int sanil, int diamond, String badgeClip) {
        return List.of(
            Map.of("type", "SANIL", "data", Map.of("amount", sanil)),
            Map.of("type", "DIAMOND", "data", Map.of("amount", diamond)),
            Map.of("type", "PRODUCT", "data", Map.of("quantity", 1, "color", 0, "countDownType", "IMMORTAL", "clip", badgeClip))
        );
    }

    private int requiredValue(List<Map<String, Object>> steps, int currentStep) {
        return steps.stream()
            .filter(step -> ((Number) step.get("step")).intValue() == currentStep)
            .findFirst()
            .map(step -> ((Number) step.get("requirementValue")).intValue())
            .orElse(1);
    }
}