package com.mygame.server.transport;

import java.io.IOException;
import java.nio.ByteBuffer;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.BinaryMessage;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.BinaryWebSocketHandler;

import com.mygame.server.protocol.extension.ExtensionCommandRouter;
import com.mygame.server.protocol.system.HandshakeHandler;
import com.mygame.server.protocol.system.LoginHandler;
import com.mygame.server.protocol.system.PublicMessageHandler;
import com.mygame.server.smartfox.SmartFoxPacket;
import com.mygame.server.smartfox.SmartFoxPacketCodec;

@Component
public class SfsWebSocketHandler extends BinaryWebSocketHandler {
    private static final Logger log = LoggerFactory.getLogger(SfsWebSocketHandler.class);

    private final HandshakeHandler handshakeHandler;
    private final LoginHandler loginHandler;
    private final PublicMessageHandler publicMessageHandler;
    private final ExtensionCommandRouter extensionCommandRouter;

    public SfsWebSocketHandler(
        HandshakeHandler handshakeHandler,
        LoginHandler loginHandler,
        PublicMessageHandler publicMessageHandler,
        ExtensionCommandRouter extensionCommandRouter
    ) {
        this.handshakeHandler = handshakeHandler;
        this.loginHandler = loginHandler;
        this.publicMessageHandler = publicMessageHandler;
        this.extensionCommandRouter = extensionCommandRouter;
    }

    @Override
    public void afterConnectionEstablished(WebSocketSession session) {
        log.info("SFS client connected sessionId={}", session.getId());
    }

    @Override
    protected void handleBinaryMessage(WebSocketSession session, BinaryMessage message) throws IOException {
        byte[] frame = copyPayload(message.getPayload());
        SmartFoxPacket packet = SmartFoxPacketCodec.decode(frame);

        log.info(
            "SmartFox packet sessionId={} controller={} action={} bytes={}",
            session.getId(),
            packet.controller(),
            packet.action(),
            frame.length
        );

        if (packet.controller() == 0 && packet.action() == 0) {
            byte[] response = handshakeHandler.handle(session.getId(), packet);
            session.sendMessage(new BinaryMessage(response));
            log.info("SmartFox handshake sent sessionId={} bytes={}", session.getId(), response.length);
            return;
        }

        if (packet.controller() == 0 && packet.action() == 1) {
            byte[] response = loginHandler.handle(session.getId(), packet);
            session.sendMessage(new BinaryMessage(response));
            log.info("SmartFox login sent sessionId={} bytes={}", session.getId(), response.length);
            return;
        }

        if (packet.controller() == 0 && packet.action() == 2) {
            byte[] response = loginHandler.handleLogout(session.getId());
            session.sendMessage(new BinaryMessage(response));
            log.info("SmartFox logout sent sessionId={} bytes={}", session.getId(), response.length);
            return;
        }

        if (packet.controller() == 0 && packet.action() == 7) {
            byte[] response = publicMessageHandler.handle(session.getId(), packet);
            session.sendMessage(new BinaryMessage(response));
            log.info("SmartFox public message sent sessionId={} bytes={}", session.getId(), response.length);
            return;
        }

        if (packet.controller() == 0 && packet.action() == 12) {
            log.info("SmartFox user variables received sessionId={} bytes={}", session.getId(), frame.length);
            return;
        }

        if (packet.controller() == 1 && packet.action() == 13) {
            extensionCommandRouter.handle(session.getId(), packet).ifPresent(responses -> {
                try {
                    for (byte[] response : responses) {
                        session.sendMessage(new BinaryMessage(response));
                        log.info("SmartFox extension response sent sessionId={} bytes={}", session.getId(), response.length);
                    }
                } catch (IOException error) {
                    throw new IllegalStateException("Failed to send SmartFox extension response", error);
                }
            });
            return;
        }

        log.warn(
            "Unsupported SmartFox packet sessionId={} controller={} action={}",
            session.getId(),
            packet.controller(),
            packet.action()
        );
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) {
        loginHandler.disconnect(session.getId());
        log.info("SFS client closed sessionId={} status={}", session.getId(), status);
    }

    private static byte[] copyPayload(ByteBuffer payload) {
        ByteBuffer copy = payload.asReadOnlyBuffer();
        byte[] bytes = new byte[copy.remaining()];
        copy.get(bytes);
        return bytes;
    }
}