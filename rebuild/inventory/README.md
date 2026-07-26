# Rebuild Inventory

This folder is the working inventory area for extracted, mined, downloaded, and validated game assets.

There are two different kinds of files here:

```text
*.urls.txt, url-catalog*/    Catalogs: lists of asset URLs discovered from the client, vf, ifile, or SWFs.
*/files/                     Actual downloaded asset files.
*.report.*                   Coverage and validation reports.
```

The URL catalogs are not the final inventory. They are inputs used to fetch and verify the real files.

The actual runtime asset inventory is the URL-shaped file tree under each `files/` directory, then promoted into:

```text
assets/cdn-mirror/global/...
```

That mirror path must match the original URL path after the host. For example:

```text
http://xo.newmarhab.net/global/static/items/clothes/f_0001_1.swf
assets/cdn-mirror/global/static/items/clothes/f_0001_1.swf
```

Use `rebuild/promote-cdn-mirror.ps1` to copy validated actual files into the local CDN mirror without flattening paths.