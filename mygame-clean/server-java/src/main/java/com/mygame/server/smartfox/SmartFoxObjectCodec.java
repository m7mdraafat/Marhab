package com.mygame.server.smartfox;

import java.io.ByteArrayOutputStream;
import java.nio.ByteBuffer;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public final class SmartFoxObjectCodec {
    private static final int TYPE_NULL = 0;
    private static final int TYPE_BOOL = 1;
    private static final int TYPE_BYTE = 2;
    private static final int TYPE_SHORT = 3;
    private static final int TYPE_INT = 4;
    private static final int TYPE_LONG = 5;
    private static final int TYPE_DOUBLE = 7;
    private static final int TYPE_UTF_STRING = 8;
    private static final int TYPE_UTF_STRING_ARRAY = 16;
    private static final int TYPE_ARRAY = 17;
    private static final int TYPE_OBJECT = 18;

    private SmartFoxObjectCodec() {
    }

    public static SmartFoxValue decode(byte[] payload) {
        ByteBuffer buffer = ByteBuffer.wrap(payload);
        SmartFoxValue value = decodeValue(buffer);
        if (value.type() != SmartFoxValue.Type.OBJECT) {
            throw new IllegalArgumentException("Root SmartFox payload must be an SFS object");
        }
        if (buffer.hasRemaining()) {
            throw new IllegalArgumentException("SmartFox payload has trailing bytes: " + buffer.remaining());
        }
        return value;
    }

    public static byte[] encode(SmartFoxValue value) {
        ByteArrayOutputStream output = new ByteArrayOutputStream();
        encodeValue(output, value);
        return output.toByteArray();
    }

    private static SmartFoxValue decodeValue(ByteBuffer buffer) {
        ensureRemaining(buffer, 1, "value type");
        int type = Byte.toUnsignedInt(buffer.get());
        return switch (type) {
            case TYPE_NULL -> SmartFoxValue.nil();
            case TYPE_BOOL -> SmartFoxValue.bool(readByte(buffer, "bool") != 0);
            case TYPE_BYTE -> SmartFoxValue.byteValue(readByte(buffer, "byte"));
            case TYPE_SHORT -> SmartFoxValue.shortValue(readShort(buffer));
            case TYPE_INT -> SmartFoxValue.intValue(readInt(buffer));
            case TYPE_LONG -> SmartFoxValue.longValue(readLong(buffer));
            case TYPE_DOUBLE -> SmartFoxValue.doubleValue(Double.longBitsToDouble(readLong(buffer)));
            case TYPE_UTF_STRING -> SmartFoxValue.utf(readUtf(buffer));
            case TYPE_UTF_STRING_ARRAY -> SmartFoxValue.utfArray(readUtfArray(buffer));
            case TYPE_ARRAY -> SmartFoxValue.array(readArray(buffer));
            case TYPE_OBJECT -> SmartFoxValue.object(readObject(buffer));
            default -> throw new IllegalArgumentException("Unsupported SmartFox value type: " + type);
        };
    }

    private static Map<String, SmartFoxValue> readObject(ByteBuffer buffer) {
        int fieldCount = readUnsignedShort(buffer);
        Map<String, SmartFoxValue> object = new LinkedHashMap<>();
        for (int index = 0; index < fieldCount; index++) {
            String key = readUtf(buffer);
            object.put(key, decodeValue(buffer));
        }
        return object;
    }

    private static List<SmartFoxValue> readArray(ByteBuffer buffer) {
        int count = readUnsignedShort(buffer);
        List<SmartFoxValue> items = new ArrayList<>(count);
        for (int index = 0; index < count; index++) {
            items.add(decodeValue(buffer));
        }
        return items;
    }

    private static List<String> readUtfArray(ByteBuffer buffer) {
        int count = readUnsignedShort(buffer);
        List<String> items = new ArrayList<>(count);
        for (int index = 0; index < count; index++) {
            items.add(readUtf(buffer));
        }
        return items;
    }

    private static String readUtf(ByteBuffer buffer) {
        int length = readUnsignedShort(buffer);
        ensureRemaining(buffer, length, "utf string");
        byte[] bytes = new byte[length];
        buffer.get(bytes);
        return new String(bytes, StandardCharsets.UTF_8);
    }

    private static void encodeValue(ByteArrayOutputStream output, SmartFoxValue value) {
        switch (value.type()) {
            case NULL -> output.write(TYPE_NULL);
            case BOOL -> {
                output.write(TYPE_BOOL);
                output.write(value.asBoolean() ? 1 : 0);
            }
            case BYTE -> {
                output.write(TYPE_BYTE);
                output.write(value.asInt() & 0xff);
            }
            case SHORT -> {
                output.write(TYPE_SHORT);
                writeShort(output, value.asInt());
            }
            case INT -> {
                output.write(TYPE_INT);
                writeInt(output, value.asInt());
            }
            case LONG -> {
                output.write(TYPE_LONG);
                writeLong(output, value.asLong());
            }
            case DOUBLE -> {
                output.write(TYPE_DOUBLE);
                writeLong(output, Double.doubleToLongBits(value.asDouble()));
            }
            case UTF_STRING -> {
                output.write(TYPE_UTF_STRING);
                writeUtf(output, value.asUtf());
            }
            case UTF_STRING_ARRAY -> writeUtfArray(output, value.asUtfArray());
            case ARRAY -> writeArray(output, value.asArray());
            case OBJECT -> writeObject(output, value.asObject());
        }
    }

    private static void writeObject(ByteArrayOutputStream output, Map<String, SmartFoxValue> object) {
        output.write(TYPE_OBJECT);
        writeShort(output, object.size());
        object.forEach((key, value) -> {
            writeUtf(output, key);
            encodeValue(output, value);
        });
    }

    private static void writeArray(ByteArrayOutputStream output, List<SmartFoxValue> items) {
        output.write(TYPE_ARRAY);
        writeShort(output, items.size());
        items.forEach(item -> encodeValue(output, item));
    }

    private static void writeUtfArray(ByteArrayOutputStream output, List<String> items) {
        output.write(TYPE_UTF_STRING_ARRAY);
        writeShort(output, items.size());
        items.forEach(item -> writeUtf(output, item));
    }

    private static void writeUtf(ByteArrayOutputStream output, String value) {
        byte[] bytes = value.getBytes(StandardCharsets.UTF_8);
        writeShort(output, bytes.length);
        output.writeBytes(bytes);
    }

    private static byte readByte(ByteBuffer buffer, String label) {
        ensureRemaining(buffer, 1, label);
        return buffer.get();
    }

    private static short readShort(ByteBuffer buffer) {
        ensureRemaining(buffer, Short.BYTES, "short");
        return buffer.getShort();
    }

    private static int readUnsignedShort(ByteBuffer buffer) {
        return Short.toUnsignedInt(readShort(buffer));
    }

    private static int readInt(ByteBuffer buffer) {
        ensureRemaining(buffer, Integer.BYTES, "int");
        return buffer.getInt();
    }

    private static long readLong(ByteBuffer buffer) {
        ensureRemaining(buffer, Long.BYTES, "long");
        return buffer.getLong();
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

    private static void writeLong(ByteArrayOutputStream output, long value) {
        for (int shift = 56; shift >= 0; shift -= 8) {
            output.write((int) ((value >>> shift) & 0xff));
        }
    }

    private static void ensureRemaining(ByteBuffer buffer, int required, String label) {
        if (buffer.remaining() < required) {
            throw new IllegalArgumentException("SmartFox payload ended while reading " + label);
        }
    }
}