package com.mygame.server.cdn;

import jakarta.annotation.PostConstruct;
import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.file.AtomicMoveNotSupportedException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.time.Duration;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
public class CdnCacheService {
    private static final Logger log = LoggerFactory.getLogger(CdnCacheService.class);

    private final CdnProperties properties;
    private final Path cacheRoot;
    private final HttpClient http;
    private final ConcurrentHashMap<String, Object> locks = new ConcurrentHashMap<>();
    private final ConcurrentHashMap<String, Long> negativeCache = new ConcurrentHashMap<>();

    public CdnCacheService(
        CdnProperties properties,
        @Value("${mygame.assets.cdn-dir:../assets/cdn}") String cdnDirectory
    ) {
        this.properties = properties;
        this.cacheRoot = Path.of(cdnDirectory).toAbsolutePath().normalize();
        this.http = HttpClient.newBuilder()
            .followRedirects(HttpClient.Redirect.NORMAL)
            .connectTimeout(Duration.ofMillis(properties.upstreamConnectTimeoutMs()))
            .build();
    }

    @PostConstruct
    void init() throws IOException {
        Files.createDirectories(cacheRoot);
        log.info("CDN cache root: {} (upstream={}, pull-through={})",
            cacheRoot, properties.upstream(), properties.pullThroughEnabled());
    }

    public Path cacheRoot() {
        return cacheRoot;
    }

    /**
     * Resolve a CDN path (relative to the cache root, e.g. {@code global/static/data/ifile.2013}
     * or {@code global/dynamic/rooms/89074661nsi.3.swf}) to a local file, pulling from upstream
     * on miss. Returns empty if the file doesn't exist locally, pull-through is disabled, or
     * upstream returns 404. Throws IOException on transport failure so callers can decide to 502/503.
     */
    public Optional<Path> resolve(String relativePath) throws IOException {
        Path resolved = safeResolve(relativePath);
        if (resolved == null) {
            return Optional.empty();
        }
        if (Files.isRegularFile(resolved)) {
            return Optional.of(resolved);
        }
        if (!properties.pullThroughEnabled()) {
            return Optional.empty();
        }
        if (isNegativelyCached(relativePath)) {
            return Optional.empty();
        }
        return pullThrough(relativePath, resolved);
    }

    private Path safeResolve(String relativePath) {
        String cleaned = relativePath.replace('\\', '/').replaceFirst("^/+", "");
        if (cleaned.isEmpty() || cleaned.contains("..")) {
            return null;
        }
        Path candidate = cacheRoot.resolve(cleaned).normalize();
        if (!candidate.startsWith(cacheRoot)) {
            return null;
        }
        return candidate;
    }

    private boolean isNegativelyCached(String relativePath) {
        Long expiresAt = negativeCache.get(relativePath);
        if (expiresAt == null) {
            return false;
        }
        if (System.currentTimeMillis() < expiresAt) {
            return true;
        }
        negativeCache.remove(relativePath, expiresAt);
        return false;
    }

    private Optional<Path> pullThrough(String relativePath, Path destination) throws IOException {
        Object lock = locks.computeIfAbsent(relativePath, k -> new Object());
        try {
            synchronized (lock) {
                if (Files.isRegularFile(destination)) {
                    return Optional.of(destination);
                }
                if (isNegativelyCached(relativePath)) {
                    return Optional.empty();
                }
                return fetchAndStore(relativePath, destination);
            }
        } finally {
            locks.remove(relativePath, lock);
        }
    }

    private Optional<Path> fetchAndStore(String relativePath, Path destination) throws IOException {
        URI upstreamUri = URI.create(properties.upstream() + "/" + relativePath);
        HttpRequest request = HttpRequest.newBuilder(upstreamUri)
            .timeout(Duration.ofMillis(properties.upstreamRequestTimeoutMs()))
            .header("User-Agent", "mygame-cdn-mirror/1.0")
            .GET()
            .build();

        Files.createDirectories(destination.getParent());
        Path tmp = destination.resolveSibling(destination.getFileName() + ".tmp." + UUID.randomUUID());
        HttpResponse<Path> response;
        try {
            response = http.send(request, HttpResponse.BodyHandlers.ofFile(tmp));
        } catch (InterruptedException e) {
            Files.deleteIfExists(tmp);
            Thread.currentThread().interrupt();
            throw new IOException("Interrupted while fetching " + upstreamUri, e);
        } catch (IOException e) {
            Files.deleteIfExists(tmp);
            log.warn("CDN pull-through failed for {} ({})", relativePath, e.getMessage());
            throw e;
        }

        int status = response.statusCode();
        if (status == 404) {
            Files.deleteIfExists(tmp);
            negativeCache.put(relativePath, System.currentTimeMillis() + properties.negativeTtlSeconds() * 1000L);
            return Optional.empty();
        }
        if (status / 100 != 2) {
            Files.deleteIfExists(tmp);
            throw new IOException("Upstream returned " + status + " for " + upstreamUri);
        }

        try {
            Files.move(tmp, destination, StandardCopyOption.ATOMIC_MOVE, StandardCopyOption.REPLACE_EXISTING);
        } catch (AtomicMoveNotSupportedException atomicEx) {
            Files.move(tmp, destination, StandardCopyOption.REPLACE_EXISTING);
        }
        log.debug("CDN cached {} ({} bytes)", relativePath, Files.size(destination));
        return Optional.of(destination);
    }
}
