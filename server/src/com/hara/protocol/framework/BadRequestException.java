package com.hara.protocol.framework;

/** Thrown by handlers when client params are missing or malformed. */
public class BadRequestException extends RuntimeException {
    public BadRequestException(String message) { super(message); }
}
