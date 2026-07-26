package com.hara.infra.id;

import java.util.concurrent.atomic.AtomicLong;

/**
 * Process-local monotonically increasing 63-bit IDs. Seeded from the current
 * epoch-millis so restarts don't reuse low numbers. Good enough for the
 * in-memory phase; swap for a DB sequence or Snowflake once persistence
 * lands.
 */
public final class IdGen {

    private final AtomicLong counter;

    public IdGen() { this(System.currentTimeMillis()); }
    public IdGen(long seed) { this.counter = new AtomicLong(seed); }

    public long next() { return counter.incrementAndGet(); }
}
