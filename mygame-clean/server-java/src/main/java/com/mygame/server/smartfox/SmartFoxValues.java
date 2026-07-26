package com.mygame.server.smartfox;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public final class SmartFoxValues {
    private SmartFoxValues() {
    }

    public static SmartFoxValue fromPlain(Object value) {
        if (value == null) {
            return SmartFoxValue.nil();
        }
        if (value instanceof SmartFoxValue smartFoxValue) {
            return smartFoxValue;
        }
        if (value instanceof Boolean bool) {
            return SmartFoxValue.bool(bool);
        }
        if (value instanceof Integer integer) {
            return SmartFoxValue.intValue(integer);
        }
        if (value instanceof Long longValue) {
            return SmartFoxValue.longValue(longValue);
        }
        if (value instanceof Double doubleValue) {
            return SmartFoxValue.doubleValue(doubleValue);
        }
        if (value instanceof Float floatValue) {
            return SmartFoxValue.doubleValue(floatValue.doubleValue());
        }
        if (value instanceof Number number) {
            return SmartFoxValue.doubleValue(number.doubleValue());
        }
        if (value instanceof String string) {
            return SmartFoxValue.utf(string);
        }
        if (value instanceof List<?> list) {
            List<SmartFoxValue> values = new ArrayList<>(list.size());
            for (Object item : list) {
                values.add(fromPlain(item));
            }
            return SmartFoxValue.array(values);
        }
        if (value instanceof Map<?, ?> map) {
            Map<String, SmartFoxValue> values = new LinkedHashMap<>();
            for (Map.Entry<?, ?> entry : map.entrySet()) {
                values.put(String.valueOf(entry.getKey()), fromPlain(entry.getValue()));
            }
            return SmartFoxValue.object(values);
        }
        return SmartFoxValue.utf(String.valueOf(value));
    }
}