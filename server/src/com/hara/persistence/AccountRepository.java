package com.hara.persistence;

import java.util.Optional;

import com.hara.domain.model.Account;

/** Storage abstraction for {@link Account}. In-memory today; DB later. */
public interface AccountRepository {

    /** Persist a new or updated account. */
    void save(Account account);

    Optional<Account> findById(long id);
    Optional<Account> findByToken(String token);

    /** Best-effort count of all known accounts (for ops/metrics). */
    long count();
}
