package com.hara.protocol.framework;

/**
 * Thrown by handlers (or {@link SfsObjectMapper}) when a request payload is
 * malformed or fails business validation. {@link HandlerBase} converts these
 * into a structured error envelope: {@code {errorCode, message}}.
 */
public class BadRequestException extends RuntimeException {
    private final String errorCode;

    public BadRequestException(String errorCode, String message) {
        super(message);
        this.errorCode = errorCode;
    }

    public String errorCode() { return errorCode; }

    public static BadRequestException missing(String field) {
        return new BadRequestException(ServiceErrorCode.MISSING_PARAMETER,
            "Missing required parameter: " + field);
    }

    public static BadRequestException wrongType(String field, String expected) {
        return new BadRequestException(ServiceErrorCode.WRONG_PARAMETER,
            "Parameter '" + field + "' must be " + expected);
    }
}
