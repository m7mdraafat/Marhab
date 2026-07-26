package com.hara.service.avatar;

import java.time.Instant;
import java.util.List;
import java.util.Objects;
import java.util.Optional;

import com.hara.domain.enums.Gender;
import com.hara.domain.model.Account;
import com.hara.domain.model.Avatar;
import com.hara.domain.model.ClothItem;
import com.hara.domain.model.Wallet;
import com.hara.infra.id.IdGen;
import com.hara.persistence.AvatarRepository;
import com.hara.protocol.framework.BadRequestException;
import com.hara.protocol.framework.ServiceErrorCode;

/**
 * Creation + mutation of {@link Avatar}s. Encapsulates the persisted-once
 * fields (id, accountId, createdAt) and the always-validated fields
 * (gender, name). New avatars start with a generous starter wallet so
 * Wave 5 economy work can lean on real funds.
 */
public final class AvatarService {

    /** Tunable defaults; tighten when economy rules land in Wave 7. */
    public static final long STARTER_SANIL     = 1_000L;
    public static final long STARTER_DIAMOND   =     5L;
    public static final long STARTER_PEPSICOIN =     0L;

    private final AvatarRepository avatars;
    private final IdGen ids;

    public AvatarService(AvatarRepository avatars, IdGen ids) {
        this.avatars = Objects.requireNonNull(avatars);
        this.ids     = Objects.requireNonNull(ids);
    }

    public Avatar create(Account account, String name, String gender,
                         List<ClothItem> clothes, boolean baseClothOnly) {
        validateName(name);
        validateGender(gender);
        Wallet w = new Wallet(STARTER_SANIL, STARTER_DIAMOND, STARTER_PEPSICOIN);
        Avatar a = new Avatar(ids.next(), account.id(), name, gender,
            baseClothOnly, w, Instant.now());
        if (clothes != null && !clothes.isEmpty()) a.replaceClothes(clothes);
        avatars.save(a);
        account.addAvatar(a.id());
        return a;
    }

    public Optional<Avatar> latestForAccount(long accountId) {
        return avatars.latestForAccount(accountId);
    }

    public Avatar requireById(long id) {
        return avatars.findById(id).orElseThrow(() ->
            new BadRequestException(ServiceErrorCode.AVATAR_NOT_FOUND,
                "avatar " + id + " not found"));
    }

    public void updateClothes(long avatarId, List<ClothItem> newClothes) {
        Avatar a = requireById(avatarId);
        a.replaceClothes(newClothes);
        avatars.save(a);
    }

    /** Convenience shape for the {@code init} reply's {@code clothes:{items:[...]}}. */
    public List<ClothItem> equippedFor(long avatarId) {
        return requireById(avatarId).clothes();
    }

    // -----------------------------------------------------------------------

    static void validateName(String name) {
        if (name == null || name.isBlank()) {
            throw new BadRequestException(ServiceErrorCode.WRONG_PARAMETER,
                "avatarName must be non-empty");
        }
        int len = name.trim().length();
        if (len < 3 || len > 20) {
            throw new BadRequestException("avatarNameLengthError",
                "avatarName must be 3..20 chars");
        }
    }

    static void validateGender(String gender) {
        if (!Gender.isValid(gender)) {
            throw new BadRequestException(ServiceErrorCode.WRONG_PARAMETER,
                "gender must be 'm' or 'f'");
        }
    }
}
