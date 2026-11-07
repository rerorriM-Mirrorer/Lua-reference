# Current Development Status — 2026-11-06 (America/Chicago)

- **Repository / working branch:** `rerorriM-Mirrorer/Windower-Addons`, `skilltrainer-0.1-beta`, based on `dev` at `e9cf6ad66b42c322be0351dd735893c85bac4369`. Final source publication/commit status is listed in the delivery report; this ZIP is not a live-verified release.
- **Current beta:** SkillTrainer `0.2.0-beta`. Rank/level numeric caps for four modes; 0x062 skill Level and Capped flags; optional Master Level from 0x061/0x0DF; WORKFLOW chat colors and prefix. Training logic retained from 0.1.
- **Most recent live feedback:** User reported on 2026-11-06 that the earlier SkillTrainer beta was 'Already working great.' No new live testing has yet been reported for numerical caps or message formatting.
- **Verification:** Original six simulated behavior tests and three cap/packet/style test groups pass with the installed Linux Lua 5.4 library. No Windows/Windower 4 or FFXI runtime was available for this beta's verification.
- **Unresolved:** Confirm actual packet field names and ordering in-game, especially 0x061/0x0DF Master Level; confirm rank/level totals, live server flag handling, and format. Numeric caps are estimates until confirmed by the server flag. SCH Light Arts changes effective rank; calculated figure is base main-job rank.
- **Next action:** On Lionstag, `//st healing 5`, `//st status` before and after a skillup. Check that the displayed total matches his in-game job cap, the server field reads 'uncapped' and the existing rest/stand/cure cycle continues. Report one sample status line and any mismatch.

## Current tests — cap calculation / presentation (2026-11-06, 0.2.0-beta)

1. Begin Healing: `//st healing 5`, then `//st status`. Expect numerical current/cap for eligible main jobs. WHM 75 = 276; PLD 99 = 373 base; SCH 99 = 334 base.
2. After a 0x062 skill update, expect skill value to reflect packet Level; 'server uncapped' until flag becomes true; after true, stop and do not cast again. Numeric value alone must not cause premature stop.
3. At 99, absent a Master Level packet the cap displays `+ML? (base only)`. On 0x061 or 0x0DF, cap updates by +1 per observed Master Level. Verify on a 99 character only.
4. `//st help`: headings 167, separator 140, prefix/arrow 200, syntax 207, descriptive text 0; all chat lines channel 0. Normal feedback `SkillTrainer -> ...` with heading/arrow/neutral body.
5. Regression: Lionstag Cure/rest/stand, Barspell, Paeon, Carbuncle release, manual cap, timer, no load-time casting, menu/combat/zoning. No actual FFXI tests performed for 0.2 as of packaging.

## Checks actually performed — simulated/static only

- **PASS:** Original `test_skilltrainer_mock.py`: 6 groups (no auto start, healing/rest/recover, server cap stop, override, enhancing, singing, pet safety, summoning/timeout).
- **PASS:** New `test_skilltrainer_caps.py`: 3 groups (chat formatting; WHM75 cap and packet level; WHM99 master level/flag priority; ranks for WHM/RDM/PLD/SCH/BRD/SMN/RUN at relevant levels and job isolation).
- **PASS:** Lua syntax via Lua 5.4 `loadfile` in tests; Lua 5.1 runtime not available in this environment.
- **NOT TESTED:** FFXI Windower 4 / live skill update, real Master Level, live chat colors or output positioning.

## Delivery register update

| Date | Batch | Contents | Commit | Verification |
| --- | --- | --- | --- | --- |
| 2026-11-06 | 0.2.0-beta | Numeric cap calculator; Master Level observation; packet level; WORKFLOW chat formatting; docs/tests | See published branch commit in delivery message | Linux Lua 5.4 mocked tests, not live FFXI |

## New user observation / request — 2026-11-06

- User reports that the earlier SkillTrainer beta is already working very well.
- User asks whether current numeric caps can be calculated when the skill-update packet arrives, and requests all messages formatted per WORKFLOW.md conventions.

---

# TESTING.md

## Current development status — 2026-11-06

- **Project:** SkillTrainer 0.1.0-beta, standalone new Windower addon; based on locally supplied `CarbyTrainer.zip` v1.0.
- **Repository baseline:** `rerorriM-Mirrorer/Windower-Addons`, `dev`, SHA `e9cf6ad66b42c322be0351dd735893c85bac4369`. A separate `skilltrainer-0.1-beta` branch was created but this local testing prototype has **not been committed or pushed to the branch**.
- **Runtime:** Windower 4 / Lua 5.1 target. Tested only with Linux-hosted Lua 5.4 syntax loading and mocked Windower calls, not inside Windows/FFXI. The mocked runtime does not replicate all Windower details.
- **New behavior:** Explicit Healing/Enhancing/Singing/Summoning modes; passive packet cap flags; configurable session timer (default 60m); `/heal on` at 20% MP and `/heal off` at 90% MP; refuse other pets; stop on job/zone changes.
- **Next:** Lionstag's actual Cure/MP/rest test; check 0x062 cap status and player job/spell resource lookup in-game; refine wait/confirmation timing.

## Current tests — perform in game

1. Place `SkillTrainer` in Windower addons and load using `//lua l SkillTrainer`. Expected: no actions until explicitly started.
2. On Lionstag as a job with Healing Magic as a main-job skill and Cure learned, use `//st healing 5`. Expected: Cure on self repeatedly, no duplicated commands while spells cast/recast.
3. Once MP is 20% or lower, expect `/heal on`, enter resting status 33, wait for 90% MP, `/heal off`, resume Cure without manual input.
4. Use `//st status`; verify skill, MP, remaining time, phase. Test `//st stop` while resting, and ensure trainer stands only if *it* initiated resting.
5. Observe a natural healing-skill increase and confirm `0x062` capped flag is read and training ends when Healing Magic becomes blue-capped. If already capped before load, test `//st cap <number>` as a fallback.
6. Test `//st enhancing 2` on a suitable job with a Bar-element spell, `//st singing 2` on BRD, and `//st summoning 2` on SMN. Confirm each stops after 2 minutes.
7. For summoning, verify no second summon if another pet is out, and no release of avatars besides Carbuncle. Do not run CarbyTrainer at the same time.
8. Test interruption with chat/menu, combat, zoning, job change, and unload. Report any unexpected command after stop.

## Verification performed — simulated/static only

- **Lua parser:** PASS — `luaL_loadfilex` with installed Lua 5.4 library; this is not the Windower Lua 5.1 runtime.
- **Mock Windower harness:** PASS — explicit opt-in (no load-time actions), Cure at `<me>`, no duplicate rapid cast, 20% MP rest, confirmation of resting state, 90% MP stand, continued Cure, cap packet immediately stops.
- **Mock override:** PASS — exact cap number immediately stops at current skill.
- **Mock other modes:** PASS — available Barspell selected; song casts without MP; non-Carbuncle pet never released; Carbuncle summoned/released and time limit obeyed. Cap cache is partitioned by character/job/level to avoid a prior job's cap flag stopping a new job.
- **Actual FFXI/Windower:** NOT TESTED. This beta should be treated as a first-pass test package, not an in-game verified release.

## Previous behavior and regression notes

- **CarbyTrainer v1.0:** Local original ZIP contained a single Lua file with 60-minute timer, check for Carbuncle presence, summon if MP >= 5, release existing Carbuncle, pause when menu/chat/combat active. It was previously delivered, but **no confirmed in-game testing was available in this conversation**.
- **Behavior intentionally changed:** SkillTrainer does not auto-start on load. The summoning loop now may rest for MP rather than simply waiting when low, and may stop at observed skill cap before its hour expires.
- No original CarbyTrainer source files are modified. Both addons can be installed but shouldn't run together on the same character.

## Delivery register

| Date | Batch | Package | Commit | Test status |
| --- | --- | --- | --- | --- |
| 2026-11-06 | SkillTrainer 0.1.0-beta | `SkillTrainer-0.1.0-beta.zip` | Not committed / not pushed | Mock + syntax checks only |

## User materials / requests

- **2026-11-06:** User requested conversion of CarbyTrainer to SkillTrainer, especially Lionstag casting Cure on himself, resting until MP nearly full, and continuing until current Healing Magic skill cap. Also proposed singing and Bar-element Enhancing Magic loops and requested more possibilities.
- **Source archive:** `CarbyTrainer.zip`, supplied earlier in this conversation; single Lua file with preexisting behavior described above.
- **Future:** Instrument cap tracking for bard songs; other spells/magic schools; successful-cast acknowledgement; skillup rate metrics; safer progress UI; per-character persistent defaults.