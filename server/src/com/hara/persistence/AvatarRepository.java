package com.hara.persistence;

import java.util.List;
import java.util.Optional;

import com.hara.domain.model.Avatar;

/** Storage abstraction for {@link Avatar}. In-memory today; DB later. */
public interface AvatarRepository {

    void save(Avatar avatar);

    Optional<Avatar> findById(long id);
    List<Avatar> findByAccountId(long accountId);

    /**
     * Latest avatar for an account (highest id). Convenience for the very
     * common "give me this user's currently-active avatar" query before we
     * track a per-account {@code selectedAvatarID}.
     */
    Optional<Avatar> latestForAccount(long accountId);

    long count();
}
