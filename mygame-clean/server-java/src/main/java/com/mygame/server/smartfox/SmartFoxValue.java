package com.mygame.server.smartfox;

import java.util.List;
import java.util.Map;

public record SmartFoxValue(Type type, Object value) {
    public enum Type {
        NULL,
        BOOL,
        BYTE,
        SHORT,
        INT,
        LONG,
        DOUBLE,
        UTF_STRING,
        UTF_STRING_ARRAY,
        ARRAY,
        OBJECT
    }

    public static SmartFoxValue nil() {
        return new SmartFoxValue(Type.NULL, null);
    }

    public static SmartFoxValue bool(boolean value) {
        return new SmartFoxValue(Type.BOOL, value);
    }

    public static SmartFoxValue byteValue(int value) {
        return new SmartFoxValue(Type.BYTE, value);
    }

    public static SmartFoxValue shortValue(int value) {
        return new SmartFoxValue(Type.SHORT, value);
    }

    public static SmartFoxValue intValue(int value) {
        return new SmartFoxValue(Type.INT, value);
    }

    public static SmartFoxValue longValue(long value) {
        return new SmartFoxValue(Type.LONG, value);
    }

    public static SmartFoxValue doubleValue(double value) {
        return new SmartFoxValue(Type.DOUBLE, value);
    }

    public static SmartFoxValue utf(String value) {
        return new SmartFoxValue(Type.UTF_STRING, value);
    }

    public static SmartFoxValue utfArray(List<String> value) {
        return new SmartFoxValue(Type.UTF_STRING_ARRAY, value);
    }

    public static SmartFoxValue array(List<SmartFoxValue> value) {
        return new SmartFoxValue(Type.ARRAY, value);
    }

    public static SmartFoxValue object(Map<String, SmartFoxValue> value) {
        return new SmartFoxValue(Type.OBJECT, value);
    }

    @SuppressWarnings("unchecked")
    public Map<String, SmartFoxValue> asObject() {
        return (Map<String, SmartFoxValue>) value;
    }

    @SuppressWarnings("unchecked")
    public List<SmartFoxValue> asArray() {
        return (List<SmartFoxValue>) value;
    }

    @SuppressWarnings("unchecked")
    public List<String> asUtfArray() {
        return (List<String>) value;
    }

    public String asUtf() {
        return (String) value;
    }

    public int asInt() {
        return ((Number) value).intValue();
    }

    public long asLong() {
        return ((Number) value).longValue();
    }

    public double asDouble() {
        return ((Number) value).doubleValue();
    }

    public boolean asBoolean() {
        return (Boolean) value;
    }
}