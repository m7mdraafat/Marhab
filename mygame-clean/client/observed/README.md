# Observed Client

This is the editable, instrumented client copy used for feature capture sessions.

- `game-src/` is the frozen AS3 source copy with logging inserted directly.
- `runtime/` is the runtime payload used by this observed client only.
- `build/build.ps1` compiles `game-src/Sanalika.as` into `runtime/snl.780.swf`.
- `build/run.ps1` launches AIR with `runtime/` without modifying `client/runtime`.

Logs are written by `com.oyunstudyosu.capture.CaptureLog` to:

```text
%APPDATA%\com.mygame.clean\Local Store\captures\sfs-capture-*.jsonl
```

Build:

```powershell
$airSdk = "$HOME\OneDrive - Microsoft\Desktop\Marhab\tools\flex\apache-flex-sdk-4.16.1-air-51.1.4.1"
$java8 = "C:\Program Files\Eclipse Adoptium\jdk-8.0.492.9-hotspot"
client/observed/build/build.ps1 -SdkHome $airSdk -JavaHome $java8
```

Run:

```powershell
$airSdk = "$HOME\OneDrive - Microsoft\Desktop\Marhab\tools\flex\apache-flex-sdk-4.16.1-air-51.1.4.1"
client/observed/build/run.ps1 -SdkHome $airSdk
```