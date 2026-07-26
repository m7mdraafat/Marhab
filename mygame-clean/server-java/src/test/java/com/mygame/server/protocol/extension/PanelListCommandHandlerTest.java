package com.mygame.server.protocol.extension;

import static org.assertj.core.api.Assertions.assertThat;

import com.mygame.server.game.persistence.AvatarGameDataRepository;
import com.mygame.server.game.session.SessionRegistry;
import com.mygame.server.smartfox.SmartFoxPacket;
import com.mygame.server.smartfox.SmartFoxPacketCodec;
import com.mygame.server.smartfox.SmartFoxPacketHeader;
import com.mygame.server.smartfox.SmartFoxValue;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;

class PanelListCommandHandlerTest {
    @Test
    void returnsInventoryPanelListsWithRequestMetadata() {
        assertListResponse(new CardListCommandHandler(), "cardlist", "CARD");
        assertPagedListResponse(new HandItemListCommandHandler(), "handitemlist");
        assertListResponse(new ClothListCommandHandler(), "clothlist", "CLOTH");
    }

    @Test
    void cardListReturnsEmptyListWhenSessionIsNotReady() {
        CardListCommandHandler handler = new CardListCommandHandler(new SessionRegistry(), Mockito.mock(AvatarGameDataRepository.class));

        SmartFoxPacket response = SmartFoxPacketCodec.decode(handler.handle("connection-1", requestPacket("cardlist")).getFirst());
        Map<String, SmartFoxValue> payload = response.params().asObject().get("p").asObject();

        assertThat(payload.get("type").asUtf()).isEqualTo("CARD");
        assertThat(payload.get("items").asArray()).isEmpty();
    }

    @Test
    void returnsSmileyAchievementAndUniverseLists() {
        Map<String, SmartFoxValue> smileyPayload = responsePayload(new SmileyListCommandHandler(), "smileylist");
        assertThat(smileyPayload.get("smilies").asArray()).hasSizeGreaterThan(1);
        assertThat(smileyPayload.get("smilies").asArray().getFirst().asObject().get("metaKey").asUtf()).isEqualTo("empty");
        assertThat(smileyPayload.get("moods").asArray()).hasSizeGreaterThan(1);

        Map<String, SmartFoxValue> achievementPayload = responsePayload(new AchievementListCommandHandler(), "achievementlist");
        assertThat(achievementPayload.get("achievements").asArray()).isNotEmpty();
        Map<String, SmartFoxValue> firstAchievement = achievementPayload.get("achievements").asArray().getFirst().asObject();
        assertThat(firstAchievement.get("type").asUtf()).isEqualTo("ACHIEVEMENT");
        assertThat(firstAchievement.get("currentStep").asInt()).isGreaterThan(0);
        assertThat(firstAchievement.get("totalStep").asInt()).isGreaterThan(0);
        assertThat(firstAchievement.get("steps").asArray()).isNotEmpty();
        assertThat(firstAchievement.get("rewardSteps").asArray()).isNotNull();
        assertThat(achievementPayload.get("completedAchievementsCount").asInt()).isZero();

        Map<String, SmartFoxValue> universePayload = responsePayload(new UniverseListCommandHandler(), "universelist");
        assertThat(universePayload.get("onlineCount").asInt()).isEqualTo(1);
        assertThat(universePayload.get("universes").asArray()).hasSize(1);
    }

    private void assertListResponse(AbstractPanelCommandHandler handler, String command, String type) {
        Map<String, SmartFoxValue> payload = responsePayload(handler, command);

        assertThat(payload.get("type").asUtf()).isEqualTo(type);
        assertThat(payload.get("items").asArray()).isNotNull();
        assertThat(payload.get("rid").asInt()).isEqualTo(7);
        assertThat(payload.get("nextRequest").asInt()).isEqualTo(1000);
        assertThat(payload.get("ts").asLong()).isEqualTo(1780232601L);
    }

    private void assertPagedListResponse(AbstractPanelCommandHandler handler, String command) {
        Map<String, SmartFoxValue> payload = responsePayload(handler, command);

        assertThat(payload.get("items").asObject().get("list").asArray()).isNotNull();
        assertThat(payload.get("items").asObject().get("page").asInt()).isEqualTo(1);
        assertThat(payload.get("pageSelected").asInt()).isEqualTo(1);
        assertThat(payload.get("totalPages").asInt()).isZero();
        assertThat(payload.get("rid").asInt()).isEqualTo(7);
        assertThat(payload.get("nextRequest").asInt()).isEqualTo(1000);
        assertThat(payload.get("ts").asLong()).isEqualTo(1780232601L);
    }

    private Map<String, SmartFoxValue> responsePayload(AbstractPanelCommandHandler handler, String command) {
        SmartFoxPacket response = SmartFoxPacketCodec.decode(SmartFoxPacketCodec.encode(handler.responseRoot(requestPacket(command))));
        Map<String, SmartFoxValue> params = response.params().asObject();

        assertThat(response.controller()).isEqualTo(1);
        assertThat(response.action()).isEqualTo(13);
        assertThat(params.get("c").asUtf()).isEqualTo(command);
        return params.get("p").asObject();
    }

    private SmartFoxPacket requestPacket(String command) {
        Map<String, SmartFoxValue> requestPayload = new LinkedHashMap<>();
        requestPayload.put("rid", SmartFoxValue.longValue(7));
        requestPayload.put("ts", SmartFoxValue.longValue(1780232601L));

        Map<String, SmartFoxValue> params = new LinkedHashMap<>();
        params.put("p", SmartFoxValue.object(requestPayload));
        params.put("c", SmartFoxValue.utf(command));
        Map<String, SmartFoxValue> root = new LinkedHashMap<>();
        root.put("c", SmartFoxValue.byteValue(1));
        root.put("a", SmartFoxValue.shortValue(13));
        root.put("p", SmartFoxValue.object(params));
        return new SmartFoxPacket(new SmartFoxPacketHeader(true, false, false, false, false, 0), SmartFoxValue.object(root));
    }
}