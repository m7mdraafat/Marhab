package com.mygame.server.cdn;

import jakarta.servlet.http.HttpServletRequest;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Optional;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.io.PathResource;
import org.springframework.core.io.Resource;
import org.springframework.http.CacheControl;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class CdnController {
    private static final Logger log = LoggerFactory.getLogger(CdnController.class);
    private static final long CACHE_SECONDS = 24L * 60 * 60;

    private final CdnCacheService cache;

    public CdnController(CdnCacheService cache) {
        this.cache = cache;
    }

    @GetMapping("/global/**")
    public ResponseEntity<Resource> serveGlobal(HttpServletRequest request) {
        // Pass through the leading "global/" segment so the cache layout mirrors upstream.
        return serve(stripLeadingSlash(request.getServletPath()));
    }

    @GetMapping("/global-haxe/**")
    public ResponseEntity<Resource> serveGlobalHaxe(HttpServletRequest request) {
        return serve(stripLeadingSlash(request.getServletPath()));
    }

    private ResponseEntity<Resource> serve(String relativePath) {
        if (relativePath == null || relativePath.isBlank()) {
            return ResponseEntity.notFound().build();
        }
        Optional<Path> file;
        try {
            file = cache.resolve(relativePath);
        } catch (IOException e) {
            log.warn("Upstream error for {}: {}", relativePath, e.getMessage());
            return ResponseEntity.status(502).build();
        }
        if (file.isEmpty()) {
            return ResponseEntity.notFound().build();
        }
        Path path = file.get();
        try {
            HttpHeaders headers = new HttpHeaders();
            headers.setContentLength(Files.size(path));
            headers.setContentType(MediaType.parseMediaType(contentType(path)));
            headers.setCacheControl(CacheControl.maxAge(java.time.Duration.ofSeconds(CACHE_SECONDS)).cachePublic());
            headers.setLastModified(Files.getLastModifiedTime(path).toInstant());
            return new ResponseEntity<>(new PathResource(path), headers, 200);
        } catch (IOException e) {
            log.warn("Failed to read cached {}: {}", path, e.getMessage());
            return ResponseEntity.status(500).build();
        }
    }

    private static String stripLeadingSlash(String fullPath) {
        if (fullPath == null) {
            return null;
        }
        return fullPath.startsWith("/") ? fullPath.substring(1) : fullPath;
    }

    private static String contentType(Path path) {
        String name = path.getFileName().toString().toLowerCase();
        int dot = name.lastIndexOf('.');
        String ext = dot < 0 ? "" : name.substring(dot + 1);
        return switch (ext) {
            case "png" -> "image/png";
            case "jpg", "jpeg" -> "image/jpeg";
            case "gif" -> "image/gif";
            case "webp" -> "image/webp";
            case "svg" -> "image/svg+xml";
            case "swf" -> "application/x-shockwave-flash";
            case "json" -> "application/json";
            case "xml" -> "application/xml";
            case "txt", "mo" -> "text/plain";
            case "css" -> "text/css";
            case "js" -> "application/javascript";
            case "wav" -> "audio/wav";
            case "mp3" -> "audio/mpeg";
            case "ogg" -> "audio/ogg";
            default -> "application/octet-stream";
        };
    }
}
