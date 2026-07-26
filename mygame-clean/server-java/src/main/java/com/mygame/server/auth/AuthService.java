package com.mygame.server.auth;

import com.mygame.server.game.avatar.AvatarState;
import com.mygame.server.game.persistence.AvatarGameDataRepository;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.time.Duration;
import java.time.Instant;
import java.util.HexFormat;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.atomic.AtomicReference;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.security.crypto.bcrypt.BCrypt;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AuthService implements TokenAuthenticator, AuthBridge {
    private static final Duration TOKEN_TTL = Duration.ofDays(30);

    private final AuthRepository authRepository;
    private final AvatarGameDataRepository avatarGameDataRepository;
    private final AtomicReference<AuthBridgeResult> completedAuth = new AtomicReference<>();

    public AuthService(AuthRepository authRepository, AvatarGameDataRepository avatarGameDataRepository) {
        this.authRepository = authRepository;
        this.avatarGameDataRepository = avatarGameDataRepository;
    }

    @Transactional
    public AuthBridgeResult register(String characterName, String email, String password, String gender) {
        validateRegistration(characterName, email, password, gender);
        try {
            long accountId = authRepository.createAccount(email.trim(), BCrypt.hashpw(password, BCrypt.gensalt(12)));
            AvatarState avatar = authRepository.createAvatar(accountId, authRepository.nextAvatarId(accountId), characterName.trim(), normalizedGender(gender));
            avatarGameDataRepository.ensureSeeded(avatar);
            AuthBridgeResult result = issueToken(accountId, avatar, "externalAuthComplete");
            completedAuth.set(result);
            return result;
        } catch (DuplicateKeyException error) {
            throw new IllegalArgumentException("Email is already registered", error);
        }
    }

    @Transactional
    public AuthBridgeResult login(String email, String password) {
        AuthRepository.AccountCredentials credentials = authRepository.findAccountCredentials(email.trim())
            .orElseThrow(() -> new IllegalArgumentException("Invalid email or password"));
        if (!BCrypt.checkpw(password, credentials.passwordHash())) {
            throw new IllegalArgumentException("Invalid email or password");
        }
        AvatarState avatar = authRepository.findPrimaryAvatar(credentials.accountId())
            .orElseThrow(() -> new IllegalStateException("Account has no avatar"));
        avatarGameDataRepository.ensureSeeded(avatar);
        AuthBridgeResult result = issueToken(credentials.accountId(), avatar, "externalAuthComplete");
        completedAuth.set(result);
        return result;
    }

    @Override
    public Optional<AvatarState> authenticateToken(String token) {
        if (token == null || token.isBlank()) {
            return Optional.empty();
        }
        Optional<AvatarState> avatar = authRepository.findAvatarByTokenHash(hashToken(token), Instant.now());
        avatar.ifPresent(avatarGameDataRepository::ensureSeeded);
        return avatar;
    }

    @Override
    public Optional<AuthBridgeResult> consumeCompletedAuth() {
        return Optional.ofNullable(completedAuth.getAndSet(null));
    }

    @Override
    @Transactional
    public AuthBridgeResult createGuestToken() {
        String suffix = UUID.randomUUID().toString();
        long accountId = authRepository.createAccount("guest+" + suffix + "@local.invalid", "");
        AvatarState avatar = authRepository.createAvatar(accountId, authRepository.nextAvatarId(accountId), "Guest", "m");
        avatarGameDataRepository.ensureSeeded(avatar);
        return issueToken(accountId, avatar, "externalTokenComplete");
    }

    private AuthBridgeResult issueToken(long accountId, AvatarState avatar, String completionCommand) {
        String token = UUID.randomUUID().toString();
        authRepository.createToken(hashToken(token), accountId, avatar.userId(), Instant.now().plus(TOKEN_TTL));
        return new AuthBridgeResult(avatar.avatarId(), token, completionCommand);
    }

    private void validateRegistration(String characterName, String email, String password, String gender) {
        if (characterName == null || characterName.isBlank()) {
            throw new IllegalArgumentException("Character name is required");
        }
        if (email == null || !email.contains("@")) {
            throw new IllegalArgumentException("Valid email is required");
        }
        if (password == null || password.length() < 6) {
            throw new IllegalArgumentException("Password must be at least 6 characters");
        }
        normalizedGender(gender);
    }

    private String normalizedGender(String gender) {
        if ("f".equalsIgnoreCase(gender) || "female".equalsIgnoreCase(gender)) {
            return "f";
        }
        if ("m".equalsIgnoreCase(gender) || "male".equalsIgnoreCase(gender)) {
            return "m";
        }
        throw new IllegalArgumentException("Gender must be m or f");
    }

    private String hashToken(String token) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            return HexFormat.of().formatHex(digest.digest(token.getBytes(StandardCharsets.UTF_8)));
        } catch (NoSuchAlgorithmException error) {
            throw new IllegalStateException("SHA-256 is unavailable", error);
        }
    }
}