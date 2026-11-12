# FPSFix (Windower 4)

A tiny, silent addon that requests **60 FPS** (`config FrameRateDivisor 1`) when the addon loads, at login, and when zoning. It also reissues the same command 1 and 3 seconds afterward to handle late resets. It does not continuously poll or change any saved Config settings.

## Installation

Copy the `FPSFix` folder to `Windower4/addons/FPSFix/` and load it with `//lua load fpsfix`. To load automatically, add `lua load fpsfix` to your Windower `scripts/init.txt`, or to another appropriate startup script.

Windower's **Config plugin** must be loaded (the `config` console command must work). If a different addon repeatedly changes the frame rate after the 3-second grace period, FPSFix will not fight it continuously.

## Commands

- `//fps` - Request 60 FPS immediately (shortcut for `//fpsfix apply`).
- `//fpsfix` - Same immediate action; both aliases share the bare-command handler.

- `//fpsfix help` - List commands.
- `//fpsfix status` - Show automatic behavior and last requested action. This **does not read the live divisor**.
- `//fpsfix apply` - Request 60 FPS immediately.
- `//fpsfix restart` - Restart FPSFix.
- `//fpsfix unload` - Unload FPSFix.

The addon deliberately overwrites **both 30 FPS (2) and uncapped (0)** with divisor 1. To manually switch back to 30 FPS after unloading, use `//config FrameRateDivisor 2`.

## Changelog

- **1.0.1 - 2026-11-12:** Added `//fps` shortcut, using Windower's multi-command alias; bare `//fpsfix` now also applies 60 FPS. `//fpsfix help` continues to show help. No Windower 4 built-in `fps` command is documented; third-party/user aliases may still conflict.
- **1.0.0 - 2026-11-12:** Initial zone/login/load 60 FPS enforcement with two limited delayed requests; quiet automatic operation, help/status/manual apply, restart/unload.
