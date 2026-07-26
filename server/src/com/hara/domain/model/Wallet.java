package com.hara.domain.model;

/**
 * Soft/hard/sponsor currency totals. The client reads them at {@code init}
 * time and again on every {@code updateWallet} push.
 */
public final class Wallet {
    private long sanil;
    private long diamond;
    private long pepsicoin;

    public Wallet() {}
    public Wallet(long sanil, long diamond, long pepsicoin) {
        this.sanil = sanil; this.diamond = diamond; this.pepsicoin = pepsicoin;
    }

    public long sanil()     { return sanil; }
    public long diamond()   { return diamond; }
    public long pepsicoin() { return pepsicoin; }

    public void addSanil(long delta)     { this.sanil += delta; }
    public void addDiamond(long delta)   { this.diamond += delta; }
    public void addPepsicoin(long delta) { this.pepsicoin += delta; }
}
