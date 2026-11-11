# TESTING.md

## Debuffed2 — independent icon edition candidate (2026-11-11)

- **Source/branch:** `rerorriM-Mirrorer/Windower-Addons` / `work/debuffed2-name-style-20261111`, based on Test 2.4.5 Save 1 commit `8801171`. New source lives in `addons/Debuffed2/` only; original `addons/Debuffed/` and live-tested branches remain intact.
- **Scope:** Standalone `Debuffed2` identity and module, collision-free `//db2` commands, isolated configuration, reload/unload; target name uses EnemyBar2 main-bar Arial 14 bold italic with a 2px outlined stroke and no brackets. Preserve 24px icons, 16/16 slot/wrap defaults, drag/snap/persistence, and Xathe's original tracker.
- **Offline verification:** Both Lua files parsed with `texlua`; mock renderer confirmed typography, plain names, heading toggle, 24px/96px icon layouts, two rows of eight, cleanup. Mocked entrypoint also passed alias/help/status/restart-once checks. Original tracker section remains byte-for-byte identical. These checks do not verify FFXI rendering, mouse/keyboard input, or config persistence.
- **Next:** Install from test package on a separate, opt-in basis; validate `//db2 status`, `targetname on`, position saves and reload/unload. The original Debuffed installation must not be overwritten. See [Debuffed2/TESTING.md](addons/Debuffed2/TESTING.md) for cumulative history and full test sequence.

Read this first when preparing or evaluating a development/testing batch. This cumulative, project-specific record belongs at the repository and testing-package roots alongside `WORKFLOW.md`.

## Debuffed — position save regression (2026-11-07)

- **User's live observation:** `1.0.0.4-icons-test2.4.4-grid1` sometimes does not retain a newly dragged position. This is a report about the old build, not a verification of the fix.
- **Development candidate:** `work/debuffed-position-save-20261107`, based on `5a8fcda` with no changes to `work/debuffed-icons`, `work/debuffed-ctrl-grid`, or `dev`.
- **Scope and evidence:** Correct pending position persistence, record viewport clamping, and flush on settings/display transitions or shutdown. Original packet tracker unchanged. Lua parser, simulated drag/save regression, Ctrl snap, UI boundaries, scaling via icon sizes, and no-LuaSocket timing passed offline. In-game validation is pending.
- **Detailed cumulative history and exact next tests:** [Debuffed/TESTING.md](addons/Debuffed/TESTING.md).

## Previous testing batch — documentation adoption (2026-10-13)

- **Project:** Windower-Addons (including ConsoleBGPlus) (`rerorriM-Mirrorer/Windower-Addons`).
- **Batch:** Documentation-only adoption; no addon testing package or executable changes.
- **Starting default-branch commit:** `080ec5e34d386f6b07e6a654b104589dae71f51b` (`dev`).
- **Documents:** Added root `WORKFLOW.md` and `TESTING.md`.
- **Reference:** [NPCMirror consolidated workflow](https://github.com/rerorriM-Mirrorer/ffxi-NPCmirror/blob/main/WORKFLOW.md).
- **Verification:** Check root filenames and links; compare migration against its starting commit and confirm only Markdown documentation changed.
- **In-game testing:** Not performed for this documentation-only change; existing addon behavior has not been revalidated.

- **Recorded migration commit:** [`16a05d6`](https://github.com/rerorriM-Mirrorer/Windower-Addons/commit/16a05d601ee5b23a9503f2e20bbeee9b9e9ab4c0).
- **Verified result:** Git comparison against the recorded starting commit lists Markdown changes only; `WORKFLOW.md` and `TESTING.md` exist at the repository root. No Lua source paths changed.

## Tests for the next functional batch

List the requested change, actions to perform, expected outcomes, previously working behavior to retest, and results actually observed. This repository may maintain multiple addons; name the addon and its testing branch in each future batch.

## Previous tests and checks

No historical test results were reconstructed or verified during this documentation migration. Preserve previous testing materials and bring forward only accurately attributed results when reviewed.

## Cumulative changelog

- **2026-10-13 — Navigation refinement:** Corrected the heading levels for the Testing Packages and Shared Development Conventions sections in `WORKFLOW.md` ([`ca3b01b`](https://github.com/rerorriM-Mirrorer/Windower-Addons/commit/ca3b01bc98d1017a27d5bddc1f9fe15f89eaef7f)). Documentation only; no addon code changed.

- **2026-10-13:** Adopted the shared two-document development convention without changing executable addon behavior.

## Delivered packages and documents

| Date | Batch | Item | Type | Commit/reference | Notes |
| --- | --- | --- | --- | --- | --- |
| 2026-10-13 | Documentation adoption | WORKFLOW.md; TESTING.md | Repository documents | [`16a05d6`](https://github.com/rerorriM-Mirrorer/Windower-Addons/commit/16a05d601ee5b23a9503f2e20bbeee9b9e9ab4c0) | No testing package or Lua changes |

## User-provided materials, observations, and requests

- **2026-10-13 — Shared conventions:** Combine Agathos, Design, and Workflow into one `WORKFLOW.md` with linked table of contents; retain `TESTING.md` as the project-specific historical record; both documents belong in each active repository and testing-package root.
- Add earlier requests, tests, screenshots, files, and observations only when their provenance is verified; record date, batch, and reference.

## Corrections and retention

Correct errors with ~~strikethrough~~, an explanation, and the replacement. Remove historical testing information only by mutual agreement.
