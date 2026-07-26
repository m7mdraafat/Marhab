package com.mygame.server.smartfox;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.nio.ByteBuffer;
import java.util.zip.InflaterInputStream;

public final class SmartFoxPacketCodec {
    private SmartFoxPacketCodec() {
    }

    public static SmartFoxPacket decode(byte[] frame) {
        ByteBuffer buffer = ByteBuffer.wrap(frame);
        int headerByte = Byte.toUnsignedInt(buffer.get());
        if ((headerByte & 0x80) == 0) {
            throw new IllegalArgumentException("SmartFox packet is not binary");
        }

        boolean bigSized = (headerByte & 0x08) != 0;
        int payloadLength = bigSized ? buffer.getInt() : Short.toUnsignedInt(buffer.getShort());
        if (buffer.remaining() < payloadLength) {
            throw new IllegalArgumentException("SmartFox frame is shorter than declared payload length");
        }

        byte[] payload = new byte[payloadLength];
        buffer.get(payload);
        SmartFoxPacketHeader header = SmartFoxPacketHeader.decode(headerByte, payloadLength);

        if (header.encrypted()) {
            throw new IllegalArgumentException("Encrypted SmartFox packets are not supported by the local server codec yet");
        }
        if (header.compressed()) {
            payload = inflate(payload);
        }

        return new SmartFoxPacket(header, SmartFoxObjectCodec.decode(payload));
    }

    public static byte[] encode(SmartFoxValue root) {
        byte[] payload = SmartFoxObjectCodec.encode(root);
        boolean bigSized = payload.length > 0xffff;
        SmartFoxPacketHeader header = new SmartFoxPacketHeader(true, false, false, false, bigSized, payload.length);

        ByteArrayOutputStream output = new ByteArrayOutputStream();
        output.write(header.encode());
        if (bigSized) {
            writeInt(output, payload.length);
        } else {
            writeShort(output, payload.length);
        }
        output.writeBytes(payload);
        return output.toByteArray();
    }

    private static byte[] inflate(byte[] payload) {
        try (InflaterInputStream input = new InflaterInputStream(new ByteArrayInputStream(payload));
             ByteArrayOutputStream output = new ByteArrayOutputStream()) {
            input.transferTo(output);
            return output.toByteArray();
        } catch (Exception error) {
            throw new IllegalArgumentException("Failed to inflate SmartFox compressed payload", error);
        }
    }

    private static void writeShort(ByteArrayOutputStream output, int value) {
        output.write((value >>> 8) & 0xff);
        output.write(value & 0xff);
    }

    private static void writeInt(ByteArrayOutputStream output, int value) {
        output.write((value >>> 24) & 0xff);
        output.write((value >>> 16) & 0xff);
        output.write((value >>> 8) & 0xff);
        output.write(value & 0xff);
    }
}