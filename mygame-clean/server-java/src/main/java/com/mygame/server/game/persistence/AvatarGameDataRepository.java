package com.mygame.server.game.persistence;

import com.mygame.server.game.avatar.AvatarState;
import com.mygame.server.game.roles.AvatarRoleCatalog;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
public class AvatarGameDataRepository {
    private static final String DEFAULT_CLOTHES = "[\"A_2\",\"B_2\",\"C_2\",\"8_9\",\"1_9\",\"4_9\",\"7_10\"]";

    private final JdbcTemplate jdbcTemplate;
    private final Set<String> seedGrantEmails;

    public AvatarGameDataRepository(
        JdbcTemplate jdbcTemplate,
        @Value("${mygame.seed.privileged-emails:}") String seedGrantEmails
    ) {
        this.jdbcTemplate = jdbcTemplate;
        this.seedGrantEmails = parseSeedGrantEmails(seedGrantEmails);
    }

    @Transactional
    public void ensureSeeded(AvatarState avatar) {
        ensureSetting(avatar.userId(), "chatBalloon", "1");
        ensureSetting(avatar.userId(), "smiley", "visitor");
        ensureSetting(avatar.userId(), "handItem", "0");
        ensureSetting(avatar.userId(), "clothes", DEFAULT_CLOTHES);
        seedAchievements(avatar.userId());
        if (hasConfiguredSeedGrant(avatar.userId())) {
            seedGrantedCards(avatar.userId());
            seedGrantedPermissions(avatar.userId());
        }
    }

    public List<Map<String, Object>> cards(long avatarInternalId) {
        return jdbcTemplate.query(
            """
            SELECT id, product_id, clip, sub_type, roles, source, active, quantity, color, expire, life_time, transferrable, base, created_at
            FROM avatar_cards
            WHERE avatar_id = ?
            ORDER BY id
            """,
            (rs, rowNum) -> {
                Map<String, Object> item = new LinkedHashMap<>();
                item.put("id", rs.getLong("id"));
                item.put("productID", rs.getInt("product_id"));
                item.put("clip", rs.getString("clip"));
                item.put("subType", rs.getString("sub_type"));
                item.put("roles", rs.getString("roles"));
                item.put("source", rs.getString("source"));
                item.put("active", rs.getInt("active"));
                item.put("quantity", rs.getInt("quantity"));
                item.put("color", rs.getInt("color"));
                item.put("expire", rs.getLong("expire"));
                item.put("lifeTime", rs.getLong("life_time"));
                item.put("timeLeft", 0);
                item.put("transferrable", rs.getBoolean("transferrable"));
                item.put("base", rs.getInt("base"));
                item.put("createdAt", String.valueOf(rs.getTimestamp("created_at")));
                return item;
            },
            avatarInternalId
        );
    }

    public List<Map<String, Object>> profileCards(long avatarInternalId) {
        return jdbcTemplate.query(
            """
            SELECT product_id, clip, sub_type, quantity, expire
            FROM avatar_cards
            WHERE avatar_id = ?
            ORDER BY id
            """,
            (rs, rowNum) -> {
                Map<String, Object> item = new LinkedHashMap<>();
                item.put("quantity", rs.getInt("quantity"));
                item.put("productID", rs.getInt("product_id"));
                item.put("expire", rs.getLong("expire"));
                item.put("subType", rs.getString("sub_type"));
                item.put("clip", rs.getString("clip"));
                return item;
            },
            avatarInternalId
        );
    }

    public List<Map<String, Object>> achievements(long avatarInternalId) {
        return jdbcTemplate.query(
            """
            SELECT achievement_id, meta_key, current_step, total_step, current_value, status
            FROM avatar_achievements
            WHERE avatar_id = ?
            ORDER BY achievement_id
            """,
            (rs, rowNum) -> achievement(
                rs.getInt("achievement_id"),
                rs.getString("meta_key"),
                rs.getInt("current_step"),
                rs.getInt("total_step"),
                rs.getInt("current_value"),
                rs.getString("status")
            ),
            avatarInternalId
        );
    }

    public int completedAchievementCount(long avatarInternalId) {
        Integer count = jdbcTemplate.queryForObject(
            "SELECT count(*) FROM avatar_achievements WHERE avatar_id = ? AND status = 'COMPLETED'",
            Integer.class,
            avatarInternalId
        );
        return count == null ? 0 : count;
    }

    public String setting(long avatarInternalId, String key, String fallback) {
        return jdbcTemplate.query(
            "SELECT setting_value FROM avatar_settings WHERE avatar_id = ? AND setting_key = ?",
            (rs, rowNum) -> rs.getString("setting_value"),
            avatarInternalId,
            key
        ).stream().findFirst().orElse(fallback);
    }

    public void updateSetting(long avatarInternalId, String key, String value) {
        int updated = jdbcTemplate.update(
            "UPDATE avatar_settings SET setting_value = ?, updated_at = CURRENT_TIMESTAMP WHERE avatar_id = ? AND setting_key = ?",
            value,
            avatarInternalId,
            key
        );
        if (updated == 0) {
            jdbcTemplate.update(
                "INSERT INTO avatar_settings (avatar_id, setting_key, setting_value) VALUES (?, ?, ?)",
                avatarInternalId,
                key,
                value
            );
        }
    }

    public boolean hasRequiredRoles(long avatarInternalId, List<Integer> requiredRoleIndexes) {
        if (requiredRoleIndexes.isEmpty()) {
            return true;
        }
        return permissionIndexes(avatarInternalId).containsAll(requiredRoleIndexes);
    }

    public List<Map<String, Object>> handItems(long avatarInternalId) {
        return AvatarRoleCatalog.handItemsForIndexes(List.copyOf(permissionIndexes(avatarInternalId)));
    }

    public String rolesBitset(long avatarInternalId) {
        return AvatarRoleCatalog.requirementsForIndexes(List.copyOf(permissionIndexes(avatarInternalId)));
    }

    private void ensureSetting(long avatarInternalId, String key, String value) {
        Integer count = jdbcTemplate.queryForObject(
            "SELECT count(*) FROM avatar_settings WHERE avatar_id = ? AND setting_key = ?",
            Integer.class,
            avatarInternalId,
            key
        );
        if (count == null || count == 0) {
            jdbcTemplate.update("INSERT INTO avatar_settings (avatar_id, setting_key, setting_value) VALUES (?, ?, ?)", avatarInternalId, key, value);
        }
    }

    private void seedAchievements(long avatarInternalId) {
        for (AchievementSeed seed : achievementSeeds()) {
            Integer count = jdbcTemplate.queryForObject(
                "SELECT count(*) FROM avatar_achievements WHERE avatar_id = ? AND achievement_id = ?",
                Integer.class,
                avatarInternalId,
                seed.id()
            );
            if (count == null || count == 0) {
                jdbcTemplate.update(
                    """
                    INSERT INTO avatar_achievements (avatar_id, achievement_id, meta_key, current_step, total_step, current_value, status)
                    VALUES (?, ?, ?, ?, ?, 0, 'ONGOING')
                    """,
                    avatarInternalId,
                    seed.id(),
                    seed.metaKey(),
                    seed.currentStep(),
                    seed.totalStep()
                );
            }
        }
    }

    private void seedGrantedCards(long avatarInternalId) {
        for (AvatarRoleCatalog.CardSeed card : AvatarRoleCatalog.seedCards()) {
            Integer count = jdbcTemplate.queryForObject(
                "SELECT count(*) FROM avatar_cards WHERE avatar_id = ? AND clip = ?",
                Integer.class,
                avatarInternalId,
                card.clip()
            );
            if (count == null || count == 0) {
                jdbcTemplate.update(
                    """
                    INSERT INTO avatar_cards (avatar_id, product_id, clip, sub_type, roles, source, active, quantity, color, expire, life_time, transferrable, base)
                    VALUES (?, ?, ?, ?, ?, 'SYSTEM', 0, 1, 0, 0, 0, false, 0)
                    """,
                    avatarInternalId,
                    card.productId(),
                    card.clip(),
                    card.subType(),
                    card.roles()
                );
            }
        }
    }

    private void seedGrantedPermissions(long avatarInternalId) {
        for (AvatarRoleCatalog.Role permission : AvatarRoleCatalog.seedPermissions()) {
            Integer count = jdbcTemplate.queryForObject(
                "SELECT count(*) FROM avatar_permissions WHERE avatar_id = ? AND permission_key = ?",
                Integer.class,
                avatarInternalId,
                permission.name()
            );
            if (count == null || count == 0) {
                jdbcTemplate.update(
                    "INSERT INTO avatar_permissions (avatar_id, permission_key, role_index) VALUES (?, ?, ?)",
                    avatarInternalId,
                    permission.name(),
                    permission.index()
                );
            }
        }
    }

    private boolean hasConfiguredSeedGrant(long avatarInternalId) {
        if (seedGrantEmails.isEmpty()) {
            return false;
        }
        String email = jdbcTemplate.query(
            """
            SELECT a.email
            FROM accounts a
            JOIN avatars v ON v.account_id = a.id
            WHERE v.id = ?
            """,
            (rs, rowNum) -> rs.getString("email"),
            avatarInternalId
        ).stream().findFirst().orElse("");
        return seedGrantEmails.contains(email.toLowerCase());
    }

    private Set<Integer> permissionIndexes(long avatarInternalId) {
        Set<Integer> permissions = jdbcTemplate.query(
            "SELECT role_index FROM avatar_permissions WHERE avatar_id = ?",
            (rs, rowNum) -> rs.getInt("role_index"),
            avatarInternalId
        ).stream().collect(Collectors.toSet());
        jdbcTemplate.query(
            "SELECT roles FROM avatar_cards WHERE avatar_id = ?",
            (rs, rowNum) -> rs.getString("roles"),
            avatarInternalId
        ).forEach(roles -> permissions.addAll(AvatarRoleCatalog.requirementIndexes(roles)));
        return permissions;
    }


    private List<AchievementSeed> achievementSeeds() {
        return List.of(
            new AchievementSeed(4187101, "catchFish", 1, 3),
            new AchievementSeed(4187202, "questmania", 1, 3),
            new AchievementSeed(3719553, "spendDiamond", 1, 3)
        );
    }

    private Set<String> parseSeedGrantEmails(String emails) {
        if (emails == null || emails.isBlank()) {
            return Set.of();
        }
        return java.util.Arrays.stream(emails.split(","))
            .map(String::trim)
            .filter(email -> !email.isBlank())
            .map(String::toLowerCase)
            .collect(Collectors.toUnmodifiableSet());
    }

    private Map<String, Object> achievement(int id, String metaKey, int currentStep, int totalStep, int currentValue, String status) {
        Map<String, Object> achievement = new LinkedHashMap<>();
        achievement.put("currentStep", currentStep);
        achievement.put("totalStep", totalStep);
        achievement.put("id", id);
        achievement.put("metaKey", metaKey);
        achievement.put("type", "ACHIEVEMENT");
        achievement.put("steps", List.of(
            step(1, 10, currentValue, rewards(100, 10, metaKey + "Badge1")),
            step(2, 100, currentValue, rewards(1000, 50, metaKey + "Badge2")),
            step(3, 1000, currentValue, rewards(2000, 100, metaKey + "Badge3"))
        ));
        achievement.put("rewardSteps", List.of());
        achievement.put("rewardMultiplier", 1);
        achievement.put("status", status);
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

    private record AchievementSeed(int id, String metaKey, int currentStep, int totalStep) {
    }

}