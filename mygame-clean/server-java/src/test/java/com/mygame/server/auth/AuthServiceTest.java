package com.mygame.server.auth;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.mygame.server.game.avatar.AvatarState;
import com.mygame.server.game.persistence.AvatarGameDataRepository;
import com.mygame.server.game.roles.AvatarRoleCatalog;
import java.util.List;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

@SpringBootTest(properties = "mygame.seed.privileged-emails=seeded@example.test")
@ActiveProfiles("test")
class AuthServiceTest {
    @Autowired
    private AuthService authService;

    @Autowired
    private AvatarGameDataRepository avatarGameDataRepository;

    @Test
    void registerCreatesBridgeCompletionAndTokenLoginAvatar() {
        AuthBridgeResult result = authService.register("Mohamed Raafat", "mohamed.raafat@example.test", "secret1", "m");

        assertThat(result.completionCommand()).isEqualTo("externalAuthComplete");
        assertThat(result.avatarId()).startsWith("101010");
        assertThat(result.token()).isNotBlank();

        assertThat(authService.consumeCompletedAuth()).contains(result);
        assertThat(authService.consumeCompletedAuth()).isEmpty();

        Optional<AvatarState> avatar = authService.authenticateToken(result.token());
        assertThat(avatar).isPresent();
        assertThat(avatar.orElseThrow().avatarName()).isEqualTo("Mohamed Raafat");
        assertThat(avatar.orElseThrow().gender()).isEqualTo("m");
        assertThat(avatar.orElseThrow().roomKey()).isEqualTo("airport");
        assertThat(avatarGameDataRepository.cards(avatar.orElseThrow().userId())).isEmpty();
        assertThat(avatarGameDataRepository.profileCards(avatar.orElseThrow().userId())).isEmpty();
    }

    @Test
    void loginCreatesExternalAuthCompletionForExistingAccount() {
        authService.register("Lina", "lina@example.test", "secret1", "f");
        authService.consumeCompletedAuth();

        AuthBridgeResult result = authService.login("lina@example.test", "secret1");

        assertThat(result.completionCommand()).isEqualTo("externalAuthComplete");
        assertThat(authService.authenticateToken(result.token())).isPresent();
    }

    @Test
    void duplicateEmailIsRejected() {
        authService.register("First", "duplicate@example.test", "secret1", "m");

        assertThatThrownBy(() -> authService.register("Second", "duplicate@example.test", "secret1", "f"))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("Email");
    }

    @Test
    void configuredSeedGrantEmailReceivesExpandedCardsAndPermissions() {
        AuthBridgeResult result = authService.register("Seeded", "seeded@example.test", "secret1", "m");
        AvatarState avatar = authService.authenticateToken(result.token()).orElseThrow();

        assertThat(avatarGameDataRepository.hasRequiredRoles(avatar.userId(), List.of(8, 7, 14, 16, 20, 29, 32, 40, 43, 46, 47))).isTrue();
        assertThat(AvatarRoleCatalog.requirementIndexes(avatarGameDataRepository.rolesBitset(avatar.userId())))
            .contains(8, 7, 14, 16, 20, 29, 32, 40, 43, 46, 47);
        assertThat(avatarGameDataRepository.cards(avatar.userId()).stream().map(card -> (String) card.get("clip")))
            .contains("CARD_SILVER", "CARD_ELITE", "CARD_SANALIKAX", "CARD_SECURITY", "CARD_GUIDE")
            .doesNotContain("card_security", "card_guide", "card_moderator", "card_admin_security");
        assertThat(avatarGameDataRepository.profileCards(avatar.userId()))
            .hasSize(17)
            .allSatisfy(card -> assertThat(card).containsKeys("quantity", "productID", "expire", "subType", "clip"));
    }
}