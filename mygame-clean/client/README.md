# Client

This folder contains the runnable recovered client setup.

- `launcher/src`: recovered AIR launcher source. This is the active build target.
- `launcher/build`: launcher descriptor and build/run scripts.
- `runtime`: local runtime payloads loaded by the launcher.
- `observed`: editable instrumented client copy for feature capture sessions.
- `recovered`: read-only recovered sources and extracted assets.
- `generated`: disposable generated AS3 experiments.
- `tools`: verification and preprocessing helpers.

Do not edit `recovered/game-src` directly. Make intentional changes in `launcher/src`, server config, or generated patches.

For capture work, prefer `client/observed` over promoting generated SWFs into `client/runtime`:

```powershell
.\run-observed-client.ps1 -Build -StopExisting
```