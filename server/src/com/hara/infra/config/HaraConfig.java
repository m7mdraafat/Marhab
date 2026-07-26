package com.hara.infra.config;

import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Properties;

/**
 * Typed view over {@code extension.properties} loaded by SFS at extension
 * init. All keys have sensible defaults so the file is optional.
 *
 * <p>Properties consumed today:
 * <ul>
 *   <li>{@code starter.room} — first-room key for new avatars (default {@code street01})</li>
 *   <li>{@code cdn.host} — host:port the client should hit for assets (default {@code 127.0.0.1:8081})</li>
 *   <li>{@code catalog.item.file} — path served from CDN root <strong>relative
 *       to {@code /static/}</strong>; the client prepends that prefix (default
 *       {@code data/ifile.1366})</li>
 *   <li>{@code catalog.version.file} — same convention (default {@code data/vf.403})</li>
 *   <li>{@code locale.default.file} — locale path, the client appends {@code .mo}
 *       (default {@code locale/ar})</li>
 *   <li>{@code www.root} — local filesystem root from which catalogs are loaded
 *       at boot (default {@code <SFS_HOME>/extensions/HaraExtension/../../../server/www})</li>
 * </ul>
 */
public final class HaraConfig {

    private final String starterRoom;
    private final String cdnHost;
    private final String itemFilePath;
    private final String versionFilePath;
    private final String defaultLocaleFile;
    private final Path wwwRoot;

    private HaraConfig(Builder b) {
        this.starterRoom        = b.starterRoom;
        this.cdnHost            = b.cdnHost;
        this.itemFilePath       = b.itemFilePath;
        this.versionFilePath    = b.versionFilePath;
        this.defaultLocaleFile  = b.defaultLocaleFile;
        this.wwwRoot            = b.wwwRoot;
    }

    public String starterRoom()       { return starterRoom; }
    public String cdnHost()           { return cdnHost; }
    public String itemFilePath()      { return itemFilePath; }
    public String versionFilePath()   { return versionFilePath; }
    public String defaultLocaleFile() { return defaultLocaleFile; }
    public Path   wwwRoot()           { return wwwRoot; }

    public static HaraConfig from(Properties props, Path extensionFolder) {
        return new Builder()
            .starterRoom(get(props, "starter.room", "street01"))
            .cdnHost(get(props, "cdn.host", "127.0.0.1:8081"))
            .itemFilePath(get(props, "catalog.item.file", "data/ifile.1366"))
            .versionFilePath(get(props, "catalog.version.file", "data/vf.403"))
            .defaultLocaleFile(get(props, "locale.default.file", "locale/ar"))
            .wwwRoot(resolveWwwRoot(props, extensionFolder))
            .build();
    }

    private static String get(Properties p, String key, String def) {
        if (p == null) return def;
        String v = p.getProperty(key);
        return (v == null || v.isBlank()) ? def : v.trim();
    }

    private static Path resolveWwwRoot(Properties p, Path extensionFolder) {
        if (p != null) {
            String override = p.getProperty("www.root");
            if (override != null && !override.isBlank()) return Paths.get(override.trim());
        }
        // <SFS_HOME>/extensions/HaraExtension/  →  <repoRoot>/server/www
        // SFS deploys our jar under SFS_HOME/extensions/HaraExtension; the
        // repo-side www tree is reachable by walking back through the dev
        // checkout, but in production the operator should set www.root.
        if (extensionFolder == null) return Paths.get("server", "www");
        return extensionFolder.resolve("www");
    }

    public static final class Builder {
        private String starterRoom = "street01";
        private String cdnHost = "127.0.0.1:8081";
        private String itemFilePath = "data/ifile.1366";
        private String versionFilePath = "data/vf.403";
        private String defaultLocaleFile = "locale/ar";
        private Path wwwRoot = Paths.get("server", "www");

        public Builder starterRoom(String v)       { this.starterRoom = v; return this; }
        public Builder cdnHost(String v)           { this.cdnHost = v; return this; }
        public Builder itemFilePath(String v)      { this.itemFilePath = v; return this; }
        public Builder versionFilePath(String v)   { this.versionFilePath = v; return this; }
        public Builder defaultLocaleFile(String v) { this.defaultLocaleFile = v; return this; }
        public Builder wwwRoot(Path v)             { this.wwwRoot = v; return this; }
        public HaraConfig build() { return new HaraConfig(this); }
    }
}
