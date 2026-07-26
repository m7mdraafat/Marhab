package com.hara.persistence;

import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;

import com.hara.domain.model.Account;

/**
 * Process-local {@link AccountRepository}. State vanishes on SFS restart —
 * acceptable for first-time-flow development (Wave 1-3 spec). Swap for a
 * JDBC implementation in Phase 9.
 */
public final class InMemoryAccountRepository implements AccountRepository {

    private final ConcurrentMap<Long, Account> byId = new ConcurrentHashMap<>();
    private final ConcurrentMap<String, Long> idByToken = new ConcurrentHashMap<>();

    @Override
    public void save(Account account) {
        byId.put(account.id(), account);
        idByToken.put(account.token(), account.id());
    }

    @Override
    public Optional<Account> findById(long id) {
        return Optional.ofNullable(byId.get(id));
    }

    @Override
    public Optional<Account> findByToken(String token) {
        if (token == null) return Optional.empty();
        Long id = idByToken.get(token);
        return id == null ? Optional.empty() : findById(id);
    }

    @Override
    public long count() { return byId.size(); }
}
