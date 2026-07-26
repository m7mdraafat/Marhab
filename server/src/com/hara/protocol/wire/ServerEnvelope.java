package com.hara.protocol.wire;

import java.util.concurrent.atomic.AtomicInteger;

import com.hara.protocol.framework.ResponseBuilder;

/**
 * Common reply-envelope fields the live Marhab server stamps on every
 * list/action response (per the sniffed transcript):
 * <ul>
 *   <li>{@code rid} — monotonic per-server request id; the client uses it
 *       only for log correlation, so a single global counter is enough.</li>
 *   <li>{@code ts} — UNIX seconds at the moment the reply is built.</li>
 *   <li>{@code nextRequest} — per-command rate-limit window in ms; the
 *       client refuses to re-call the same command for that long.</li>
 * </ul>
 *
 * <p>Standard rate windows derived from the sniff (`docs/protocol-sniffed.md`):
 * fast lookups (lists) ≈ 1000ms, profile / mood-likes ≈ 2000ms, walks ≈ 100ms.
 */
public final class ServerEnvelope {

    public static final int NEXT_FAST     = 100;   // walk commits
    public static final int NEXT_NORMAL   = 500;   // setactivegroup
    public static final int NEXT_DEFAULT  = 1000;  // lists, most actions
    public static final int NEXT_SLOW     = 2000;  // profile-likes, etc.

    private static final AtomicInteger RID = new AtomicInteger(1);

    private ServerEnvelope() {}

    /** Allocate the next monotonic request id. */
    public static int nextRid() { return RID.incrementAndGet(); }

    /** UNIX seconds. */
    public static long nowSec() { return System.currentTimeMillis() / 1000L; }

    /** UNIX milliseconds — used by a handful of pushes (e.g. adminMessage). */
    public static long nowMs() { return System.currentTimeMillis(); }

    /** Stamp {@code rid + ts + nextRequest} onto an in-progress builder. */
    public static ResponseBuilder stamp(ResponseBuilder b, int nextRequestMs) {
        return b.putInt("rid", nextRid())
                .putLong("ts", nowSec())
                .putInt("nextRequest", nextRequestMs);
    }

    /** Stamp with the default 1000ms window. */
    public static ResponseBuilder stamp(ResponseBuilder b) {
        return stamp(b, NEXT_DEFAULT);
    }
}
