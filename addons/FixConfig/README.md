# FixConfig (Windower 4)

FixConfig replaces FPSFix. It automatically requests your three preferred Windower Config plugin settings when the addon loads, at login, and after zoning, then reissues them once after 1 and 3 seconds to work around late resets. Automatic operation is quiet, with optional request diagnostics. It does not poll every frame or call the Config plugin's `config save` command.

**Default preferred values:** `FrameRateDivisor 1` (60 FPS); `ClippingPlane 1.5`; `BattleAutoTarget false` (off). User-selected preferred values are saved in `FixConfig/data/settings.xml` and are applied independently per character.

## Installation and upgrade from FPSFix

1. **Unload the old addon**: `//lua unload fpsfix`. Remove `lua load fpsfix` from startup scripts so the old addon cannot fight the new one. You can remove the old `Windower4/addons/FPSFix/` folder afterward.
2. Extract the supplied `FixConfig/` folder into `Windower4/addons/`.
3. Load `//lua load fixconfig`. For startup loading, add `lua load fixconfig` to your Windower `scripts/init.txt` (or other appropriate startup script).
4. Keep Windower's **Config plugin** loaded; the Lua library called `config` is separate from that plugin.

Do not rename `fixconfig.lua` or the folder, and do not leave both FPSFix and FixConfig loaded. FixConfig intentionally has a different settings file, so it starts with the three defaults above rather than migrating old FPSFix state (FPSFix had no saved settings).

## Commands

- `//fix` or `//fixconfig` - Immediately reapply all three *preferred* values.
- `//fix fps 60`, `//fix fps 30`, `//fix fps uncapped` - Save a new FPS preference and apply it; `1`, `2`, `0` also work.
- `//fix draw 1.5` (or any positive finite number) - Save and apply a preferred clipping plane. Windower has no documented fixed upper bound; very large values may hurt performance.
- `//fix autotarget` - Toggle your saved preference (not a readback of the live plugin state).
- `//fix autotarget on` / `//fix autotarget off` - Set a specific preferred value.
- `//fix defaults` - Restore 60 FPS, draw 1.5, auto-target off, and apply all three.
- `//fix status` - Display desired values, debug mode, and last requested action. It **cannot read back actual Config plugin values** or identify which addon changed them.
- `//fix debug` / `//fix debug on` / `//fix debug off` - Toggle/request debug messages (saved per character). Debug reports **commands issued**, not observed setting changes.
- `//fix apply`, `//fix help`, `//fix restart`, `//fix unload` - Reapply, help, restart, unload.

**Legacy compatibility:** `//fps` still requests 60 FPS **once, without changing any saved preference or the other two settings**. `//fpsfix` and `//fpsfix apply` do the same, and legacy `//fpsfix help/status/restart/unload` are also understood. These two legacy commands use Windower's `unhandled command` event so `//fix` can retain a different bare-command meaning. If some other plugin, existing alias, or still-loaded FPSFix addon claims `fps`/`fpsfix` first, it will win. `//fix fps 60` always remains available.

Because there is no reliable documented API for reading the Config plugin's current values, the addon does not confirm that a command succeeded. Your preferred FPS setting will be re-applied on the next login/zone even if you temporarily used the `//fps` shortcut to force 60 FPS. `//fix` is the quick command to reapply *all* saved settings. Automatic reapplication ends after the 3-second retry; resets occurring later need manual `//fix` or investigation. If the Config plugin is missing, commands cannot enforce these values.

## Changelog

- **1.1.0 - 2026-11-12:** Renamed/replaced FPSFix with FixConfig; added automatic FPS, clipping plane and battle auto-target repair, per-character preferences, short `//fix` commands, debug request tracing and compatibility for the original `//fps`/`//fpsfix` quick 60 FPS action. Updated installation, help and lifecycle commands.
- **FPSFix 1.0.1 - 2026-11-12:** Added `//fps` shortcut to request 60 FPS.
- **FPSFix 1.0.0 - 2026-11-12:** Initial 60 FPS request on load, login and zone, with 1- and 3-second retries.
