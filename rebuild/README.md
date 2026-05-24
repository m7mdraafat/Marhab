# Sanalika AIR Rebuild Scaffold

This scaffold is for rebuilding the extracted AIR launcher first. The current dump does not include an original `project.xml`, AIR descriptor, SDK config, SWF, AIR package, or ANE binaries, so the first goal is a reproducible compile attempt against the recovered ActionScript tree.

## Current Target

- Entry SWF class: `boot_338d`
- Startup chain: `boot_338d` -> `ApplicationMain.main()` -> `DocumentClass` -> `SanalikaClient`
- Source path: `../scripts`
- Output SWF: `bin/Sanalika.swf`
- AIR descriptor: `application.xml`

## Toolchain Required

Install an AIR-capable ActionScript compiler toolchain and make the tools available on `PATH`, or set one of these environment variables to the SDK root:

- `AIR_SDK_HOME`
- `AIRSDK_HOME`
- `FLEX_HOME`

The scripts look for `amxmlc` first, then `mxmlc`. Runtime testing uses `adl`.

## Commands

From the repository root:

```powershell
.\rebuild\compile.ps1
```

Run with AIR after a successful compile:

```powershell
.\rebuild\run.ps1
```

Create a captive desktop bundle after a successful compile:

```powershell
.\rebuild\package.ps1
```

The bundle is written to `rebuild/dist/Sanalika`. The script creates a local development certificate at `rebuild/cert/SanalikaRebuild.p12` if one does not already exist.

## Local Runtime Cache

The launcher normally downloads `https://txt.ragegames.net/c.json`, then loads the client SWF from `config.loader`. For rebuild testing, `RemoteConfigCommand` first checks `runtime/c.local.json` in the AIR application directory. If that file exists, the launcher uses the locally cached files in `rebuild/runtime`:

- `c.local.json`
- `ml.21.9`
- `snl.780.swf`
- `loader-bg.jpg`

If `runtime/c.local.json` is removed, the launcher falls back to the live config URL.

The OpenFL preloader also expects `lib/SanalikaAirUI/SanalikaAirUI.swf`. This is restored in `rebuild/lib` from `binaryData/1__res._swf%3ASanalikaAirUI_swf.bin` and must be included in packaged bundles.

If native extension `.ane` files are recovered later, place them in `rebuild/anes` and run:

```powershell
.\rebuild\run.ps1 -ExtDir .\rebuild\anes
```

## Expected First Blockers

The first compile/run attempts may expose:

- Missing AIR/Flex compiler tools.
- Decompiled ActionScript syntax that needs cleanup.
- Missing embedded asset path mappings.
- Missing native extension binaries for IDs such as `com.distriqt.Core`, `com.distriqt.facebook.Core`, `com.distriqt.GoogleIdentity`, and related Android/Facebook/Google ANEs.
- The remote game/client SWF, loaded at runtime from `config.loader` in the downloaded config.

The rebuild sequence is: compile launcher SWF, run with `adl`, restore/stub ANEs, then decide whether to preserve remote loading or cache the loaded game SWF locally.