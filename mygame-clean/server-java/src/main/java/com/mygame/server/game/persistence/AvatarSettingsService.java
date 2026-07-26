package com.mygame.server.game.persistence;

import com.mygame.server.game.session.GameSession;
import org.springframework.stereotype.Service;

/**
 * Bridges the in-memory {@link GameSession} fields and the {@code avatar_settings}
 * table. Only fields that survive a refresh ({@code clothes}) are persisted; transient
 * variables ({@code handItem}, {@code smiley}, {@code chatBalloon}) intentionally reset
 * to defaults on each fresh session, matching real-game behavior.
 */
@Service
public class AvatarSettingsService {
    static final String CLOTHES_KEY = "clothes";
    static final String DEFAULT_CLOTHES = "[\"A_2\",\"B_2\",\"C_2\",\"8_9\",\"1_9\",\"4_9\",\"7_10\"]";

    private final AvatarGameDataRepository repository;

    public AvatarSettingsService(AvatarGameDataRepository repository) {
        this.repository = repository;
    }

    public void hydrate(GameSession session) {
        long avatarId = session.avatar().userId();
        if (avatarId <= 0) {
            return;
        }
        session.clothes(repository.setting(avatarId, CLOTHES_KEY, DEFAULT_CLOTHES));
    }

    public void persistClothes(GameSession session, String clothes) {
        session.clothes(clothes);
        long avatarId = session.avatar().userId();
        if (avatarId <= 0) {
            return;
        }
        repository.updateSetting(avatarId, CLOTHES_KEY, clothes);
    }
}
