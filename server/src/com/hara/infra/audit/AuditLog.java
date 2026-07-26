package com.hara.infra.audit;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * One-line structured log of every state-changing handler call so we have a
 * grep-friendly audit trail of joins, purchases, transfers, kicks, etc.
 *
 * <p>Logs under the {@code Extensions} category because that's the only
 * non-SFS-internal category SFS's stock {@code log4j.properties} routes to
 * the file + console appenders — a {@code hara.audit} logger would be
 * silently filtered. The lines are prefixed with {@code [hara.audit]} so
 * they stand out and stay grep-friendly.
 */
public final class AuditLog {

    private static final Logger LOG = LoggerFactory.getLogger("Extensions");

    private AuditLog() {}

    public static void info(String event, long actorId, String detail) {
        LOG.info("[hara.audit] event={} actor={} {}", event, actorId, detail == null ? "" : detail);
    }

    public static void warn(String event, long actorId, String detail) {
        LOG.warn("[hara.audit] event={} actor={} {}", event, actorId, detail == null ? "" : detail);
    }
}
