package com.mygame.server.cdn;

import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.annotation.PostConstruct;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.Instant;
import java.util.ArrayList;
import java.util.Base64;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Semaphore;
import java.util.concurrent.atomic.AtomicInteger;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

/**
 * Walks known asset catalogs (ifile item ids, configured manifests) and pulls every
 * candidate URL through {@link CdnCacheService}, populating the local mirror without
 * needing a live client. Disabled/hidden items are still mirrored — visibility is a
 * server-side filter; the asset universe is the catalog.
 */
@Service
public class CdnWarmupService {
    private static final Logger log = LoggerFactory.getLogger(CdnWarmupService.class);

    private final CdnCacheService cache;
    private final CdnProperties properties;
    private final String itemFile;
    private final Path reportDir;
    private final ObjectMapper json = new ObjectMapper();

    public CdnWarmupService(
        CdnCacheService cache,
        CdnProperties properties,
        @Value("${mygame.cdn.warmup-item-file:global/static/data/ifile.2013}") String itemFile,
        @Value("${mygame.assets.report-dir:../assets/reports}") String reportDir
    ) {
        this.cache = cache;
        this.properties = properties;
        this.itemFile = itemFile;
        this.reportDir = Path.of(reportDir).toAbsolutePath().normalize();
    }

    @PostConstruct
    void maybeWarmOnStartup() {
        if (!properties.warmupOnStartup()) {
            return;
        }
        Thread t = new Thread(() -> {
            try {
                runWarmup();
            } catch (Exception e) {
                log.warn("Warmup failed: {}", e.getMessage());
            }
        }, "cdn-warmup");
        t.setDaemon(true);
        t.start();
    }

    @Async
    public void warmupAsync() {
        try {
            runWarmup();
        } catch (Exception e) {
            log.warn("Warmup failed: {}", e.getMessage());
        }
    }

    public Summary runWarmup() throws IOException {
        long startedAt = System.currentTimeMillis();
        log.info("CDN warmup started (itemFile={}, concurrency={})", itemFile, properties.warmupConcurrency());

        List<String> itemIds = loadItemIds();
        log.info("CDN warmup: {} item ids parsed", itemIds.size());

        List<String> paths = candidatePaths(itemIds);
        log.info("CDN warmup: {} candidate asset paths queued", paths.size());

        return mirrorAll(paths, startedAt, itemIds.size());
    }

    private List<String> loadItemIds() throws IOException {
        Path itemPath = cache.resolve(itemFile)
            .orElseThrow(() -> new IOException("Item file not available: " + itemFile));
        byte[] bytes = Files.readAllBytes(itemPath);
        String text;
        try {
            text = new String(Base64.getDecoder().decode(stripWhitespace(bytes)), StandardCharsets.UTF_8);
        } catch (IllegalArgumentException notBase64) {
            text = new String(bytes, StandardCharsets.UTF_8);
        }
        Set<String> ids = new java.util.LinkedHashSet<>();
        for (String line : text.split("\\R")) {
            int bar = line.indexOf('|');
            String id = (bar < 0 ? line : line.substring(0, bar)).trim();
            if (!id.isEmpty()) {
                ids.add(id);
            }
        }
        List<String> result = new ArrayList<>(ids);
        if (result.size() > properties.warmupMaxItems()) {
            result = result.subList(0, properties.warmupMaxItems());
        }
        return result;
    }

    private List<String> candidatePaths(List<String> itemIds) {
        List<String> paths = new ArrayList<>();
        for (String id : itemIds) {
            paths.add("global/static/items/inventory/f_" + id + ".png");
            paths.add("global/static/items/inventory/m_" + id + ".png");
        }
        return paths;
    }

    private Summary mirrorAll(List<String> paths, long startedAt, int itemCount) {
        AtomicInteger hits = new AtomicInteger();
        AtomicInteger misses = new AtomicInteger();
        AtomicInteger errors = new AtomicInteger();
        List<String> missList = new CopyOnWriteArrayList<>();
        List<String> errorList = new CopyOnWriteArrayList<>();

        ExecutorService pool = Executors.newFixedThreadPool(properties.warmupConcurrency(), r -> {
            Thread t = new Thread(r, "cdn-warmup-worker");
            t.setDaemon(true);
            return t;
        });
        Semaphore gate = new Semaphore(properties.warmupConcurrency() * 2);
        ConcurrentHashMap<String, Boolean> seen = new ConcurrentHashMap<>();

        try {
            for (String path : paths) {
                if (seen.putIfAbsent(path, Boolean.TRUE) != null) {
                    continue;
                }
                gate.acquireUninterruptibly();
                pool.submit(() -> {
                    try {
                        Optional<Path> file = cache.resolve(path);
                        if (file.isPresent()) {
                            hits.incrementAndGet();
                        } else {
                            misses.incrementAndGet();
                            if (missList.size() < 1000) missList.add(path);
                        }
                    } catch (Exception e) {
                        errors.incrementAndGet();
                        if (errorList.size() < 200) errorList.add(path + " :: " + e.getMessage());
                    } finally {
                        gate.release();
                    }
                });
            }
        } finally {
            pool.shutdown();
            try {
                if (!pool.awaitTermination(2, java.util.concurrent.TimeUnit.HOURS)) {
                    log.warn("CDN warmup pool did not terminate within 2h; forcing shutdown");
                    pool.shutdownNow();
                }
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                pool.shutdownNow();
            }
        }

        Summary summary = new Summary(
            Instant.ofEpochMilli(startedAt).toString(),
            System.currentTimeMillis() - startedAt,
            itemCount,
            paths.size(),
            hits.get(),
            misses.get(),
            errors.get(),
            missList,
            errorList
        );
        writeReport(summary);
        log.info("CDN warmup done in {}ms: hits={} misses={} errors={} total={}",
            summary.elapsedMs, summary.hits, summary.misses, summary.errors, summary.candidatesQueued);
        return summary;
    }

    private void writeReport(Summary summary) {
        try {
            Files.createDirectories(reportDir);
            Path report = reportDir.resolve("cdn-warmup.json");
            Map<String, Object> body = new LinkedHashMap<>();
            body.put("startedAt", summary.startedAt);
            body.put("elapsedMs", summary.elapsedMs);
            body.put("itemIds", summary.itemIds);
            body.put("candidatesQueued", summary.candidatesQueued);
            body.put("hits", summary.hits);
            body.put("misses", summary.misses);
            body.put("errors", summary.errors);
            body.put("missSample", summary.misses > 0 ? summary.missSample : List.of());
            body.put("errorSample", summary.errors > 0 ? summary.errorSample : List.of());
            json.writerWithDefaultPrettyPrinter().writeValue(report.toFile(), body);
        } catch (IOException e) {
            log.warn("Failed to write CDN warmup report: {}", e.getMessage());
        }
    }

    private static byte[] stripWhitespace(byte[] in) {
        byte[] out = new byte[in.length];
        int n = 0;
        for (byte b : in) {
            if (b > ' ') out[n++] = b;
        }
        if (n == in.length) return in;
        byte[] trimmed = new byte[n];
        System.arraycopy(out, 0, trimmed, 0, n);
        return trimmed;
    }

    public record Summary(
        String startedAt,
        long elapsedMs,
        int itemIds,
        int candidatesQueued,
        int hits,
        int misses,
        int errors,
        List<String> missSample,
        List<String> errorSample
    ) {}
}
