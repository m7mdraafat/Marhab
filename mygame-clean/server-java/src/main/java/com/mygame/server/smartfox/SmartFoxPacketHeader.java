package com.mygame.server.smartfox;

public record SmartFoxPacketHeader(
    boolean binary,
    boolean encrypted,
    boolean compressed,
    boolean blueBoxed,
    boolean bigSized,
    int payloadLength
) {
    public static SmartFoxPacketHeader decode(int headerByte, int payloadLength) {
        return new SmartFoxPacketHeader(
            (headerByte & 0x80) != 0,
            (headerByte & 0x40) != 0,
            (headerByte & 0x20) != 0,
            (headerByte & 0x10) != 0,
            (headerByte & 0x08) != 0,
            payloadLength
        );
    }

    public int encode() {
        int value = 0;
        if (binary) {
            value |= 0x80;
        }
        if (encrypted) {
            value |= 0x40;
        }
        if (compressed) {
            value |= 0x20;
        }
        if (blueBoxed) {
            value |= 0x10;
        }
        if (bigSized) {
            value |= 0x08;
        }
        return value;
    }
}