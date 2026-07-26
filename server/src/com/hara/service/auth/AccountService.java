package com.hara.service.auth;

import java.time.Instant;
import java.util.Objects;
import java.util.Optional;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.hara.domain.model.Account;
import com.hara.infra.id.IdGen;
import com.hara.persistence.AccountRepository;
import com.smartfoxserver.v2.entities.User;

/**
 * Auth flow used by {@code USER_LOGIN}: turn an opaque client token into an
 * {@link Account}. Anonymous guests (empty token) get a synthetic
 * server-minted token so reconnects within the same session land back on
 * the same account.
 */
public final class AccountService {

    private static final Logger log = LoggerFactory.getLogger("Extensions");

    private final AccountRepository accounts;
    private final IdGen ids;

    public AccountService(AccountRepository accounts, IdGen ids) {
        this.accounts = Objects.requireNonNull(accounts);
        this.ids      = Objects.requireNonNull(ids);
    }

    /** Returns an existing account for {@code token} or creates a new guest account. */
    public Account upsertByToken(String token) {
        String key = (token == null || token.isBlank()) ? mintGuestToken() : token;
        return accounts.findByToken(key).orElseGet(() -> {
            Account fresh = new Account(ids.next(), key, null, Instant.now());
            accounts.save(fresh);
            return fresh;
        });
    }

    public Account requireById(long id) {
        return accounts.findById(id).orElseThrow(() ->
            new IllegalStateException("account " + id + " not found"));
    }

    public Optional<Account> findById(long id) {
        return accounts.findById(id);
    }

    /**
     * Returns the account bound to the SFS session, minting one on the fly
     * if {@code USER_LOGIN} never fired (event ordering, SFS variant, or
     * misregistration). Keeps boot from wedging when the lifecycle event
     * mis-fires — the session ends up with the same shape it would have
     * had via the normal path, one dispatch later.
     */
    public long resolveOrMintForSession(User user) {
        Optional<Long> existing = UserSession.accountId(user);
        if (existing.isPresent()) return existing.get();

        log.warn("[hara] resolveOrMintForSession: accountId missing for user={} session={} — "
                + "minting fallback (USER_LOGIN handler did not run?)",
            user == null ? "<null>" : user.getName(),
            (user == null || user.getSession() == null) ? -1 : user.getSession().getId());

        String fallbackToken = "sess-" + (user.getSession() == null
            ? user.getId()
            : user.getSession().getId());
        Account fresh = upsertByToken(fallbackToken);
        UserSession.setAccountId(user.getSession(), fresh.id());
        return fresh.id();
    }

    private String mintGuestToken() {
        return "guest-" + Long.toHexString(System.nanoTime()) + "-" + ids.next();
    }
}
