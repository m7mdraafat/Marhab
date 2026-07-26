package com.hara.persistence;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;

import com.hara.domain.model.Avatar;

/**
 * Process-local {@link AvatarRepository}. See note on
 * {@link InMemoryAccountRepository}.
 */
public final class InMemoryAvatarRepository implements AvatarRepository {

    private final ConcurrentMap<Long, Avatar> byId = new ConcurrentHashMap<>();

    @Override
    public void save(Avatar avatar) { byId.put(avatar.id(), avatar); }

    @Override
    public Optional<Avatar> findById(long id) { return Optional.ofNullable(byId.get(id)); }

    @Override
    public List<Avatar> findByAccountId(long accountId) {
        List<Avatar> out = new ArrayList<>();
        for (Avatar a : byId.values()) if (a.accountId() == accountId) out.add(a);
        out.sort(Comparator.comparingLong(Avatar::id));
        return out;
    }

    @Override
    public Optional<Avatar> latestForAccount(long accountId) {
        Avatar best = null;
        for (Avatar a : byId.values()) {
            if (a.accountId() != accountId) continue;
            if (best == null || a.id() > best.id()) best = a;
        }
        return Optional.ofNullable(best);
    }

    @Override
    public long count() { return byId.size(); }
}
