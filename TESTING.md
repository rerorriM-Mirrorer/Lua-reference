# TESTING.md

## Current Development Status - 2026-11-12 (FixConfig v1.1.0)

- **Repository / working branch:** `rerorriM-Mirrorer/Windower-Addons` / `feature/fpsfix-zone-60fps-20261112` (unverified working branch; not merged into `dev`).
- **Starting source baseline:** `a9aa2c4282a6ae4b9f963ab351bab2f4dd568de4` (FPSFix v1.0.1).
- **Change:** Replace `addons/FPSFix/` with `addons/FixConfig/` and rename addon to FixConfig. Automatic load/login/zone requests restore desired `FrameRateDivisor`, `ClippingPlane` and `BattleAutoTarget` immediately and after 1 and 3 seconds. `//fix` reapplies all saved values; `//fix fps/draw/autotarget` adjust and persist character preferences; original `//fps`/`//fpsfix` 60-FPS-only action is retained through the unhandled-command fallback. Help/status/debug/lifecycle commands updated.
- **Verification:** Lua 5.4 parser check PASSED; mocked Windower event/command/state tests PASSED for load/login/zone, 1- and 3-second retries, logout/unload cancellation, legacy FPS-only aliases, three-setting recovery, invalid commands, per-character preference updates, and once-only lifecycle. These are simulated tests, **not** Windower 4 / Lua 5.1 or live FFXI checks.
- **Live testing needed:** Unload old FPSFix; load FixConfig and confirm `//fps`, `//fix`, `//fix fps 30/60`, `//fix draw 1.5`, `//fix autotarget` and explicit on/off. Test per-character persistence and fresh login/zone transitions, then verify other addons/aliases do not claim `fps` or `fpsfix`. Confirm plugin availability; check console for errors.
- **Limitations:** No documented live readback of Config plugin settings. `//fix debug` reports attempted applications, not detected changes or culprit identification. Finite retries do not prevent a reset occurring more than 3 seconds after the last zone. No Config-plugin `config save` is issued.
- **Next:** User FFXI acceptance testing; keep unverified branch separate from `dev`.

---

## Current Development Status - 2026-11-12 (FPSFix v1.0.1 alias update)

- **Repository / branch:** `rerorriM-Mirrorer/Windower-Addons` / `feature/fpsfix-zone-60fps-20261112`.
- **Tested starting/source checkpoint:** `09f18292d38195409613ed597577633702e232d7` (FPSFix v1.0.0). Subsequent working-branch commit reported externally.
- **Change:** FPSFix v1.0.1 accepts `//fps` as a shortcut for immediate divisor 1. Windower Lua addon aliases share one callback, so bare `//fpsfix` also applies while `//fpsfix help` remains explicit. No changes to load/login/zone enforcement or delayed retries.
- **Conflict check:** Windower 4's documented built-ins include `showfps` and `fps_position`, not `fps`, and its addon system supports multiple command aliases. A user-installed FPS addon/alias could still conflict; remote inspection cannot rule that out.
- **Available verification:** Local Lua 5.4 parse and mocked Windower command/event/lifecycle checks (not Windower 4 or FFXI).
- **Live tests pending:** Verify `//fps` works on each loaded client, test `//fpsfix help` and `//fpsfix apply`, check no local `fps` alias collision, then repeat zoning/login FPS recovery tests from v1.0.0.
- **Next:** User in-game acceptance; do not merge unverified code into `dev`.

---

## Current Development Status - 2026-11-12 (America/Chicago)

- **Repository / branch:** `rerorriM-Mirrorer/Windower-Addons` / `feature/fpsfix-zone-60fps-20261112` (unverified working branch, not merged into dev).
- **Source baseline:** `e9cf6ad66b42c322be0351dd735893c85bac4369` on `dev`.
- **Batch:** FPSFix v1.0.0 - add standalone addon under `addons/FPSFix/`; on load/login/zone, request `config FrameRateDivisor 1` immediately and again after 1 and 3 seconds. No settings files; silent automatic actions.
- **Verification:** Lua 5.4 parser pass (container shared library); scripted mock Windower event tests pass for load, login, zone, delayed retries, stale-generation suppression, status, manual apply, restart, unload. Lua 5.1/Windower 4 runtime and in-game FPS transitions **not tested**.
- **Live tests requested:** Load on a client with the Config plugin active; ensure 60 FPS after login and across repeated zones; reproduce a reset to 30 FPS and confirm recovery; check 0->1 overwrite; verify multibox clients independently. Test a competing addon resetting FPS more than 3 seconds after zoning.
- **Next:** User live confirmation, investigate any later reset. Do not promote this untested batch to `dev`.

---


## Agent entry-point adoption — 2026-10-16

- Added [`AGENTS.md`](AGENTS.md) to direct repository-aware coding agents to read the current `WORKFLOW.md` and `TESTING.md` before making changes.
- **Commit:** [`f0651c0`](https://github.com/rerorriM-Mirrorer/Windower-Addons/commit/f0651c0f9ed0104803611a2309f3039dba078c2a).
- **Scope:** Documentation only; no addon code changed, testing ZIP generated, or in-game test performed.
- **Continuity:** Earlier testing and development records below remain intact.

## Package layout convention — 2026-10-16

- **Repository:** Keep `WORKFLOW.md` and `TESTING.md` at the repository root.
- **Testing ZIPs:** Include both inside the installable addon folder alongside the README and code. For patch/test-only bundles without an addon folder, place both next to the delivered files. No redundant outer ZIP-root copies.
- **Reference commit:** [`bd228bd`](https://github.com/rerorriM-Mirrorer/Windower-Addons/commit/bd228bdf02c3cb14b88de7d71a41fbe41568667e).
- **Verification:** Documentation only; no game code changed and no in-game tests performed for this instruction update.
- **History:** Previous ZIP-root conventions remain below as historical records, with dated corrections where they were stated as current instructions.

Read this first when preparing or evaluating a development/testing batch. This cumulative, project-specific record belongs at the repository ~~and testing-package~~ root alongside `WORKFLOW.md`. **Correction (2026-10-16):** In testing packages, put both guides alongside the addon or patch/test files, not at the outer ZIP root.

## Current testing batch — documentation adoption (2026-10-13)

- **Project:** Windower-Addons (including ConsoleBGPlus) (`rerorriM-Mirrorer/Windower-Addons`).
- **Batch:** Documentation-only adoption; no addon testing package or executable changes.
- **Starting default-branch commit:** `080ec5e34d386f6b07e6a654b104589dae71f51b` (`dev`).
- **Documents:** Added root `WORKFLOW.md` and `TESTING.md`.
- **Reference:** [NPCMirror consolidated workflow](https://github.com/rerorriM-Mirrorer/ffxi-NPCmirror/blob/main/WORKFLOW.md).
- **Verification:** Check root filenames and links; compare migration against its starting commit and confirm only Markdown documentation changed.
- **In-game testing:** Not performed for this documentation-only change; existing addon behavior has not been revalidated.

- **Recorded migration commit:** [`16a05d6`](https://github.com/rerorriM-Mirrorer/Windower-Addons/commit/16a05d601ee5b23a9503f2e20bbeee9b9e9ab4c0).
- **Verified result:** Git comparison against the recorded starting commit lists Markdown changes only; `WORKFLOW.md` and `TESTING.md` exist at the repository root. No Lua source paths changed.

## FPSFix v1.0.0 testing batch - 2026-11-12

- **User request:** Windower can revert to 30 FPS (FrameRateDivisor 2) after login/zone. User permits overriding uncapped (0) as well.
- **Behavior:** Always request divisor 1 on load, login and zone change. Reapply once each after 1 and 3 seconds. Never poll every frame; do not alter persistent Config settings. Automatic behavior is silent.
- **Dependencies:** Windower 4 LuaCore and Windower Config plugin.
- **Automated results:** Lua 5.4 syntax PASS; mock event/command/lifecycle PASS. Tests use mocked Windower commands/events, not an actual FFXI client.
- **Not yet tested:** Actual zone transitions, plugin configuration ordering, character switching, live FPS, six-client resource use, conflicting addons.
- **Installation:** Install the `FPSFix` folder in Windower addons, then `//lua load fpsfix`. ZIP includes README.md, WORKFLOW.md and TESTING.md inside that folder.
- **Publication:** New working branch `feature/fpsfix-zone-60fps-20261112`. Baseline `e9cf6ad66b42c322be0351dd735893c85bac4369`. Final branch commit is reported in the delivery; do not self-embed the newly created commit hash in this file.

## FPSFix v1.0.1 shortcut batch - 2026-11-12

- **Request:** `//fps` should be equivalent to `//fpsfix apply` if it has no conflict.
- **Implementation:** `_addon.commands = {'fpsfix', 'fps'}`. Both command names invoke the same addon callback; with no arguments it applies divisor 1. Explicit `help`, `status`, `apply`, `restart`, and `unload` continue working via `//fpsfix`.
- **Conflict review:** Windower's published built-ins do not list `fps`, but local custom aliases or third-party addons cannot be inspected from here. If present, disable/rename the conflicting alias/addon; `//fpsfix apply` remains available.
- **Tests:** Lua 5.4 syntax, alias declarations, bare/explicit apply and original mocked event/lifecycle checks. No real FFXI/Windower 4 test.
- **Package:** FPSFix-v1.0.1-Test.zip, addon folder contains Lua, README, WORKFLOW, TESTING; source branch `feature/fpsfix-zone-60fps-20261112`.

## FixConfig v1.1.0 test batch - 2026-11-12

- **User request:** Rename FPSFix to FixConfig, preserve original `//fps` 60 FPS shortcut, and add automatic recovery for `FrameRateDivisor 1`, `ClippingPlane 1.5`, `BattleAutoTarget false` with short `//fix` commands. An unknown reset source remains **unidentified**; do not attribute to FastCS.
- **Installation:** Unload `fpsfix` and remove its startup entry before installing/loading `FixConfig` (`//lua load fixconfig`). Remove old folder after verifying migration. `WORKFLOW.md` and `TESTING.md` travel inside the installable `FixConfig/` folder in the testing ZIP.
- **Dependencies:** Windower LuaCore with Lua `config`/`chat` libraries; Windower **Config plugin** for `config ...` commands.
- **Behavior and compatibility:** `//fix` and `//fixconfig` restore all three saved preferences. `//fps` and `//fpsfix` one-shot apply divisor 1 without editing preferred settings or draw/autotarget. `//fpsfix` is handled as an unhandled command only when nothing else claimed that name. Per-character save uses Lua config library, not Config-plugin `config save`.
- **Testing and results:** Lua 5.4 parse PASSED; scripted mocked Windower Lua API smoke tests PASSED. Test script exercised 2 named simulated characters and confirmed per-character values and transitions. Actual Windower 4 / Lua 5.1 and in-game behavior NOT tested. Run live test sequence from Current Development Status before merging.
- **Remote checkpoint:** Prior FPSFix branch head `a9aa2c4282a6ae4b9f963ab351bab2f4dd568de4`. Final FixConfig publishing SHA supplied separately in delivery, not embedded as its own document commit.
- **Questions/limitations:** Verify user input alias precedence and Config plugin load order on each client. Debug prints only issued commands; it cannot detect the source of setting resets.

## Tests for the next functional batch

List the requested change, actions to perform, expected outcomes, previously working behavior to retest, and results actually observed. This repository may maintain multiple addons; name the addon and its testing branch in each future batch.

## Previous tests and checks

No historical test results were reconstructed or verified during this documentation migration. Preserve previous testing materials and bring forward only accurately attributed results when reviewed.

## Cumulative changelog

- **2026-11-12:** FixConfig v1.1.0 replaces FPSFix; adds three-setting enforcement, per-character preferences and `//fix` commands, and preserves one-shot `//fps`. In-game acceptance pending.

- **2026-11-12:** FPSFix v1.0.1 adds `//fps` shortcut and bare-command apply behavior. Existing zone/login behavior unchanged; user testing pending.

- **2026-11-12:** Added FPSFix 1.0.0, a self-contained 60 FPS reapplication addon. Mock-tested only; awaiting live validation.

- **2026-10-13 — Navigation refinement:** Corrected the heading levels for the Testing Packages and Shared Development Conventions sections in `WORKFLOW.md` ([`ca3b01b`](https://github.com/rerorriM-Mirrorer/Windower-Addons/commit/ca3b01bc98d1017a27d5bddc1f9fe15f89eaef7f)). Documentation only; no addon code changed.

- **2026-10-13:** Adopted the shared two-document development convention without changing executable addon behavior.

## Delivered packages and documents

| Date | Batch | Item | Type | Commit/reference | Notes |
| --- | --- | --- | --- | --- | --- |
| 2026-11-12 | FixConfig v1.1.0 | addons/FixConfig; testing ZIP | Rename + multi-setting safeguard | feature/fpsfix-zone-60fps-20261112 | In-game tests pending |
| 2026-11-12 | FPSFix v1.0.1 | addons/FPSFix; updated ZIP | Shortcut addition | Working branch feature/fpsfix-zone-60fps-20261112 | Local mock tests; live FFXI untested |
| 2026-11-12 | FPSFix v1.0.0 | addons/FPSFix; ZIP | New Lua addon | Working branch feature/fpsfix-zone-60fps-20261112 | Mock tests passed; live FFXI untested |
| 2026-10-13 | Documentation adoption | WORKFLOW.md; TESTING.md | Repository documents | [`16a05d6`](https://github.com/rerorriM-Mirrorer/Windower-Addons/commit/16a05d601ee5b23a9503f2e20bbeee9b9e9ab4c0) | No testing package or Lua changes |

## User-provided materials, observations, and requests

- **2026-11-12 - FixConfig:** User requests replacing FPSFix with FixConfig, preserving existing `//fps` behavior, and applying all three desired settings automatically. User explicitly ruled out FastCS as a cause.

- **2026-11-12 - FPS shortcut:** User requests `//fps = //fpsfix apply`, provided no conflict.

- **2026-11-12 - FPS reset:** User requests automatic 60 FPS on login/zone and expressly allows changing existing uncapped divisor 0; no need to condition changes on reading divisor 2.

- **2026-10-13 — Shared conventions:** Combine Agathos, Design, and Workflow into one `WORKFLOW.md` with linked table of contents; retain `TESTING.md` as the project-specific historical record; both documents belong in each active repository and testing-package root.
- Add earlier requests, tests, screenshots, files, and observations only when their provenance is verified; record date, batch, and reference.

## Corrections and retention

Correct errors with ~~strikethrough~~, an explanation, and the replacement. Remove historical information only by mutual agreement.
