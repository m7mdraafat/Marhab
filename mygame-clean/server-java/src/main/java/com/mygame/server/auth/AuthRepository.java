package com.mygame.server.auth;

import com.mygame.server.game.avatar.AvatarState;
import java.sql.PreparedStatement;
import java.sql.Timestamp;
import java.time.Instant;
import java.util.Optional;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.stereotype.Repository;

@Repository
public class AuthRepository {
    private final JdbcTemplate jdbcTemplate;

    public AuthRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public long createAccount(String email, String passwordHash) {
        KeyHolder keyHolder = new GeneratedKeyHolder();
        jdbcTemplate.update(connection -> {
            PreparedStatement statement = connection.prepareStatement(
                "INSERT INTO accounts (email, password_hash) VALUES (?, ?)",
                new String[] { "id" }
            );
            statement.setString(1, email);
            statement.setString(2, passwordHash);
            return statement;
        }, keyHolder);
        return keyHolder.getKey().longValue();
    }

    public Optional<AccountCredentials> findAccountCredentials(String email) {
        return jdbcTemplate.query(
            "SELECT id, password_hash FROM accounts WHERE lower(email) = lower(?)",
            (rs, rowNum) -> new AccountCredentials(rs.getLong("id"), rs.getString("password_hash")),
            email
        ).stream().findFirst();
    }

    public AvatarState createAvatar(long accountId, String avatarId, String avatarName, String gender) {
        KeyHolder keyHolder = new GeneratedKeyHolder();
        jdbcTemplate.update(connection -> {
            PreparedStatement statement = connection.prepareStatement(
                """
                INSERT INTO avatars (account_id, avatar_id, avatar_name, gender)
                VALUES (?, ?, ?, ?)
                """,
                new String[] { "id" }
            );
            statement.setLong(1, accountId);
            statement.setString(2, avatarId);
            statement.setString(3, avatarName);
            statement.setString(4, gender);
            return statement;
        }, keyHolder);
        return findAvatarByInternalId(keyHolder.getKey().longValue()).orElseThrow();
    }

    public Optional<AvatarState> findPrimaryAvatar(long accountId) {
        return jdbcTemplate.query(
            """
            SELECT id, avatar_id, avatar_name, gender, privilege_id, sanil, diamond, universe_key, room_key, position, direction
            FROM avatars
            WHERE account_id = ?
            ORDER BY id
            LIMIT 1
            """,
            (rs, rowNum) -> avatarFromRow(rs.getLong("id"), rs.getString("avatar_id"), rs.getString("avatar_name"), rs.getString("gender"), rs.getInt("privilege_id"), rs.getInt("sanil"), rs.getInt("diamond"), rs.getString("universe_key"), rs.getString("room_key"), rs.getString("position"), rs.getInt("direction")),
            accountId
        ).stream().findFirst();
    }

    public Optional<AvatarState> findAvatarByInternalId(long avatarInternalId) {
        return jdbcTemplate.query(
            """
            SELECT id, avatar_id, avatar_name, gender, privilege_id, sanil, diamond, universe_key, room_key, position, direction
            FROM avatars
            WHERE id = ?
            """,
            (rs, rowNum) -> avatarFromRow(rs.getLong("id"), rs.getString("avatar_id"), rs.getString("avatar_name"), rs.getString("gender"), rs.getInt("privilege_id"), rs.getInt("sanil"), rs.getInt("diamond"), rs.getString("universe_key"), rs.getString("room_key"), rs.getString("position"), rs.getInt("direction")),
            avatarInternalId
        ).stream().findFirst();
    }

    public void createToken(String tokenHash, long accountId, long avatarInternalId, Instant expiresAt) {
        jdbcTemplate.update(
            "INSERT INTO auth_tokens (token_hash, account_id, avatar_id, expires_at) VALUES (?, ?, ?, ?)",
            tokenHash,
            accountId,
            avatarInternalId,
            Timestamp.from(expiresAt)
        );
    }

    public Optional<AvatarState> findAvatarByTokenHash(String tokenHash, Instant now) {
        return jdbcTemplate.query(
            """
            SELECT v.id, v.avatar_id, v.avatar_name, v.gender, v.privilege_id, v.sanil, v.diamond, v.universe_key, v.room_key, v.position, v.direction
            FROM auth_tokens t
            JOIN avatars v ON v.id = t.avatar_id
            WHERE t.token_hash = ? AND t.expires_at > ?
            """,
            (rs, rowNum) -> avatarFromRow(rs.getLong("id"), rs.getString("avatar_id"), rs.getString("avatar_name"), rs.getString("gender"), rs.getInt("privilege_id"), rs.getInt("sanil"), rs.getInt("diamond"), rs.getString("universe_key"), rs.getString("room_key"), rs.getString("position"), rs.getInt("direction")),
            tokenHash,
            Timestamp.from(now)
        ).stream().findFirst();
    }

    public String nextAvatarId(long accountId) {
        return String.valueOf(101_010_000L + accountId);
    }

    private AvatarState avatarFromRow(
        long internalId,
        String avatarId,
        String avatarName,
        String gender,
        int privilegeId,
        int sanil,
        int diamond,
        String universeKey,
        String roomKey,
        String position,
        int direction
    ) {
        return new AvatarState(internalId, avatarId, avatarName, gender, privilegeId, sanil, diamond, universeKey, roomKey, position, direction);
    }

    public record AccountCredentials(long accountId, String passwordHash) {
    }
}