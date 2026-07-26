package com.mygame.server.protocol.extension;

import com.mygame.server.smartfox.SmartFoxPacket;
import com.mygame.server.smartfox.SmartFoxValue;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.function.Function;
import java.util.stream.Collectors;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

@Component
public class ExtensionCommandRouter {
    private static final Logger log = LoggerFactory.getLogger(ExtensionCommandRouter.class);

    private final Map<String, ExtensionCommandHandler> handlersByCommand;

    public ExtensionCommandRouter(List<ExtensionCommandHandler> handlers) {
        this.handlersByCommand = handlers.stream().collect(Collectors.toMap(ExtensionCommandHandler::command, Function.identity()));
    }

    public Optional<List<byte[]>> handle(String connectionId, SmartFoxPacket packet) {
        String command = command(packet);
        ExtensionCommandHandler handler = handlersByCommand.get(command);
        if (handler == null) {
            log.warn("Unsupported SmartFox extension command connectionId={} command={}", connectionId, command);
            return Optional.empty();
        }
        return Optional.of(handler.handle(connectionId, packet));
    }

    private String command(SmartFoxPacket packet) {
        SmartFoxValue command = packet.params().asObject().get("c");
        if (command == null) {
            throw new IllegalArgumentException("SmartFox extension packet missing command field 'c'");
        }
        return command.asUtf();
    }
}