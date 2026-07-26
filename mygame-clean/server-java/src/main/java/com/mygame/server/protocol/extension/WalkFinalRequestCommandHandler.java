package com.mygame.server.protocol.extension;

import com.mygame.server.game.avatar.AvatarState;
import com.mygame.server.game.session.GameSession;
import com.mygame.server.game.session.SessionRegistry;
import com.mygame.server.smartfox.SmartFoxPacket;
import com.mygame.server.smartfox.SmartFoxPacketCodec;
import com.mygame.server.smartfox.SmartFoxValue;
import com.mygame.server.smartfox.SmartFoxValues;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.stereotype.Component;

@Component
public class WalkFinalRequestCommandHandler implements ExtensionCommandHandler {
    private final SessionRegistry sessionRegistry;

    public WalkFinalRequestCommandHandler(SessionRegistry sessionRegistry) {
        this.sessionRegistry = sessionRegistry;
    }

    @Override
    public String command() {
        return "walkfinalrequest";
    }

    @Override
    public List<byte[]> handle(String connectionId, SmartFoxPacket packet) {
        GameSession session = sessionRegistry.findByConnectionId(connectionId).orElse(null);
        if (session == null) {
            return List.of();
        }

        GameSession.PendingWalk pendingWalk = session.pendingWalk();
        if (pendingWalk == null) {
            return List.of(SmartFoxPacketCodec.encode(extensionRoot(command(), Map.of("rid", requestRid(packet), "nextRequest", 100))));
        }

        AvatarState updatedAvatar = session.avatar().withPosition(pendingWalk.position(), session.avatar().direction());
        session.updateAvatar(updatedAvatar);
        session.pendingWalk(null);

        return List.of(
            SmartFoxPacketCodec.encode(userVariablesRoot((int) updatedAvatar.userId(), List.of(variable("position", 4, updatedAvatar.position())))),
            SmartFoxPacketCodec.encode(userVariablesRoot((int) updatedAvatar.userId(), List.of(variable("target", 0, null)))),
            SmartFoxPacketCodec.encode(extensionRoot(command(), Map.of("rid", pendingWalk.requestRid(), "nextRequest", 100)))
        );
    }

    private int requestRid(SmartFoxPacket packet) {
        SmartFoxValue payload = packet.params().asObject().get("p");
        if (payload == null || payload.value() == null) {
            return 0;
        }
        SmartFoxValue rid = payload.asObject().get("rid");
        return rid == null || rid.value() == null ? 0 : (int) rid.asLong();
    }

    private SmartFoxValue userVariablesRoot(int userId, List<List<Object>> variables) {
        Map<String, SmartFoxValue> params = new LinkedHashMap<>();
        params.put("u", SmartFoxValue.intValue(userId));
        params.put("vl", SmartFoxValues.fromPlain(variables));

        Map<String, SmartFoxValue> root = new LinkedHashMap<>();
        root.put("c", SmartFoxValue.byteValue(0));
        root.put("a", SmartFoxValue.shortValue(12));
        root.put("p", SmartFoxValue.object(params));
        return SmartFoxValue.object(root);
    }

    private SmartFoxValue extensionRoot(String command, Map<String, Object> payload) {
        Map<String, SmartFoxValue> params = new LinkedHashMap<>();
        params.put("p", SmartFoxValues.fromPlain(payload));
        params.put("c", SmartFoxValue.utf(command));

        Map<String, SmartFoxValue> root = new LinkedHashMap<>();
        root.put("c", SmartFoxValue.byteValue(1));
        root.put("a", SmartFoxValue.shortValue(13));
        root.put("p", SmartFoxValue.object(params));
        return SmartFoxValue.object(root);
    }

    private List<Object> variable(String name, int type, Object value) {
        List<Object> variable = new ArrayList<>(4);
        variable.add(name);
        variable.add(type);
        variable.add(value);
        variable.add(false);
        return variable;
    }
}