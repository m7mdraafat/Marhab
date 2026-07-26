package com.mygame.server.protocol.extension;

import com.mygame.server.smartfox.SmartFoxPacket;
import java.util.List;

public interface ExtensionCommandHandler {
    String command();

    List<byte[]> handle(String connectionId, SmartFoxPacket packet);
}