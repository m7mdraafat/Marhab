package com.mygame.server.cdn;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "mygame.cdn")
public record CdnProperties(
    String upstream,
    String publicHost,
    boolean pullThroughEnabled,
    long negativeTtlSeconds,
    int upstreamConnectTimeoutMs,
    int upstreamRequestTimeoutMs,
    boolean warmupOnStartup,
    int warmupConcurrency,
    int warmupMaxItems
) {
    public CdnProperties {
        if (upstream == null || upstream.isBlank()) upstream = "https://xo.newmarhab.net";
        if (publicHost == null || publicHost.isBlank()) publicHost = "xo.newmarhab.net";
        if (negativeTtlSeconds <= 0) negativeTtlSeconds = 600;
        if (upstreamConnectTimeoutMs <= 0) upstreamConnectTimeoutMs = 5_000;
        if (upstreamRequestTimeoutMs <= 0) upstreamRequestTimeoutMs = 60_000;
        if (warmupConcurrency <= 0) warmupConcurrency = 4;
        if (warmupMaxItems <= 0) warmupMaxItems = Integer.MAX_VALUE;
    }
}
