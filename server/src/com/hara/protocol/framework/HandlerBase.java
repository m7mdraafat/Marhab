package com.hara.protocol.framework;

import com.smartfoxserver.v2.entities.User;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSObject;
import com.smartfoxserver.v2.exceptions.SFSException;
import com.smartfoxserver.v2.extensions.BaseClientRequestHandler;

/**
 * Cross-cutting base for every named client request:
 * <ul>
 *   <li>{@link #handle(User, ISFSObject)} is the only method subclasses
 *       override; return {@code null} to suppress the reply (one-way), or
 *       any non-null {@link ISFSObject} to send {@code command()} back.</li>
 *   <li>{@link BadRequestException} → structured {@code {errorCode, message}}
 *       envelope; any other exception → {@code SYSTEM_ERROR}.</li>
 *   <li>Wall-clock timing + concise log line on every dispatch.</li>
 * </ul>
 *
 * <p>The reply uses the SAME command name as the request — that's how the
 * client's {@code requestData(name, payload, callback)} listener pattern is
 * wired (see {@code docs/03 §3.1}).
 */
public abstract class HandlerBase extends BaseClientRequestHandler {

    /** The request name (e.g. {@code "init"}). Used in logs and the reply envelope. */
    protected abstract String command();

    /**
     * Implement the handler. Return the reply payload, or {@code null} for
     * fire-and-forget commands. Throw {@link BadRequestException} for client
     * faults; any other exception becomes an opaque {@code SYSTEM_ERROR}.
     */
    protected abstract ISFSObject handle(User user, ISFSObject params) throws Exception;

    @Override
    public final void handleClientRequest(User user, ISFSObject params) {
        long startNanos = System.nanoTime();
        ISFSObject reply;
        try {
            reply = handle(user, unwrapBody(params));
        } catch (BadRequestException bre) {
            reply = errorEnvelope(bre.errorCode(), bre.getMessage());
            logFailure(user, "bad-request", bre.errorCode(), bre.getMessage(), startNanos);
            send(reply, user);
            return;
        } catch (SFSException sfsEx) {
            reply = errorEnvelope(ServiceErrorCode.MESSAGING_EXCEPTION, sfsEx.getMessage());
            logFailure(user, "sfs-error", null, sfsEx.getMessage(), startNanos);
            send(reply, user);
            return;
        } catch (Throwable t) {
            getLogger().warn("[" + command() + "] uncaught: " + t.getMessage(), t);
            reply = errorEnvelope(ServiceErrorCode.SYSTEM_ERROR, "internal");
            logFailure(user, "internal", null, t.getMessage(), startNanos);
            send(reply, user);
            return;
        }

        if (reply != null) send(reply, user);
        logSuccess(user, startNanos);
    }

    /** Send a reply payload under {@link #command()} back to a single user. */
    protected final void send(ISFSObject payload, User user) {
        send(command(), payload, user);
    }

    /**
     * The client's {@code ServiceModel.requestData(name, body, callback)}
     * wraps the actual payload under a {@code data} envelope on the wire:
     * <pre>{ "sn": "<cmd>", "rid": N, "ts": T, "data": { ...body... } }</pre>
     * Handlers see the body directly — we unwrap once here so every
     * subclass can call {@code params.getUtfString("gender")} etc. without
     * having to know the envelope shape. If a future request lacks the
     * {@code data} wrapper (or is genuinely empty) we pass through the
     * original object so legacy / one-way commands keep working.
     */
    private static ISFSObject unwrapBody(ISFSObject raw) {
        if (raw == null) return new SFSObject();
        if (raw.containsKey("data")) {
            ISFSObject body = raw.getSFSObject("data");
            if (body != null) return body;
        }
        return raw;
    }

    private static ISFSObject errorEnvelope(String code, String msg) {
        return new ResponseBuilder()
            .putStr("errorCode", code == null ? ServiceErrorCode.SERVICE_ERROR : code)
            .putStr("message", msg == null ? "" : msg)
            .build();
    }

    private void logSuccess(User user, long startNanos) {
        long ms = (System.nanoTime() - startNanos) / 1_000_000L;
        if (ms >= 50 || getLogger().isDebugEnabled()) {
            getLogger().info(String.format("[%s] user=%s ms=%d ok",
                command(), userTag(user), ms));
        }
    }

    private void logFailure(User user, String kind, String code, String msg, long startNanos) {
        long ms = (System.nanoTime() - startNanos) / 1_000_000L;
        getLogger().info(String.format("[%s] user=%s ms=%d FAIL kind=%s code=%s msg=%s",
            command(), userTag(user), ms, kind, code, msg));
    }

    private static String userTag(User user) {
        if (user == null) return "<null>";
        return user.getId() + "/" + user.getName();
    }
}
