# MyGame Clean

Clean workspace for the recovered AIR client and the new server implementation.

## Layout

```text
client/
  launcher/      Buildable AIR launcher source.
  runtime/       Runnable recovered runtime payloads used by the launcher.
  recovered/     Read-only recovered/decompiled sources and extracted assets.
  generated/     Disposable generated sources and experiments.
  tools/         Client verification and recovery helpers.

server/
  src/           New server implementation.
  config/        Local development configuration.
  scripts/       Server run/test helpers.

assets/
  cdn/           Local CDN root served to the client.
  reports/       Asset inventory and validation reports.

docs/            Current project notes for the clean repo.
tools/           Shared SDK and automation notes.
```

## Current Client Status

- The launcher is buildable.
- The runnable inner game is `client/runtime/snl.780.swf`.
- `client/recovered/game-src` is source reference only; do not edit it directly.
- `client/generated` is disposable and may be regenerated.

## Build Launcher

```powershell
.\client\launcher\build\compile.ps1 -SdkHome "C:\Users\t-malgharib\OneDrive - Microsoft\Desktop\Marhab\tools\flex\apache-flex-sdk-4.16.1-air-51.1.4.1"
```

## Run Launcher

```powershell
.\client\launcher\build\run.ps1 -SdkHome "C:\Users\t-malgharib\OneDrive - Microsoft\Desktop\Marhab\tools\flex\apache-flex-sdk-4.16.1-air-51.1.4.1"
```