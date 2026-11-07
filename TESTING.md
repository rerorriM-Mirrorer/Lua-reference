# Current Development Status — 2026-11-06 (America/Chicago)

- **Repository / branch:** `rerorriM-Mirrorer/Windower-Addons` / `skilltrainer-0.1-beta`; source baseline `e9cf6ad66b42c322be0351dd735893c85bac4369` (dev head at branch creation).
- **Current change:** SkillTrainer 0.2.0 beta, standalone `addons/SkillTrainer` source and documentation. It calculates an eligible main-job skill's numerical cap from level/rank, adds observed Master Level when available, reads 0x062 skill values, retains server capped flag for stopping, and adopts WORKFLOW chat colors.
- **User-confirmed baseline:** User reports previous 0.1.0 SkillTrainer beta is already working well; 0.2 changes remain awaiting game testing.
- **Verification:** Nine groups of Linux Lua 5.4 mocked tests passed (six base workflow groups and three cap/format/packet groups). Actual Windows/Windower 4 / FFXI tests: NOT RUN. Neither simulated spell dispatch nor packet parsing is a live test.
- **Packet evidence:** `addons/SkillTrainer/docs/PACKETS.md`; no injection, static Windower fields inspected for 0x062, 0x061, 0x0DF; actual packet observations pending.
- **Next:** On Lionstag run `//st healing 5`, compare `//st status` to game skill, observe 0x062 after skillup and confirm MP recovery continues; test level-99 Master Level path and color display.
- **Published checkpoint:** See GitHub branch commit history; this status records the starting source checkpoint, not a self-referential final commit SHA.

## Current tests — SkillTrainer 0.2.0-beta (2026-11-06)

1. `//lua l SkillTrainer` must not cast on load; `//st healing 5` starts Cures, rests at 20% MP, stands at 90%, resumes.
2. `//st status` shows skill/current rank-derived cap, Master Level provisional or exact state, observed server cap flag, MP and timer. WHM 75 base Healing cap 276; WHM 99 base 424. Unknown 99 Master Level shown as base only.
3. 0x062 skill update refreshes current skill; server Capped=true stops; numeric estimation alone does not prematurely stop; manually overridden cap still stops when reached.
4. `//st help` uses chat-only 140 separator, 167 heading, 200 command prefix/arrow, 207 syntax, 0 descriptions; normal notices channel 0.
5. Regression: `//st enhancing`, `//st singing`, `//st summoning`, pet safety, timeout, menu/combat and zoning protections.

**Verification completed:** Lua 5.4 syntax and nine mocked test groups pass; no in-game checks on this beta. The earlier user report of 0.1 success remains historical, not a new test result.

## 2026-11-06 — SkillTrainer delivery record and user feedback

- **Request:** Calculate the current numeric skill cap on skill-update packets, format all messages to WORKFLOW.md; user reports existing trainer works great.
- **Delivered source:** `addons/SkillTrainer/SkillTrainer.lua`, README, WORKFLOW, TESTING and packet notes on this working branch; 0.1 beta was previously a local ZIP, not committed.
- **History:** All preceding root TESTING.md contents follow unchanged below.

---

# TESTING.md

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
