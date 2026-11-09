# Current Development Status — 2026-11-09 (America/Chicago) — SkillTrainer 0.3.2-beta

- **Repository / branch:** `rerorriM-Mirrorer/Windower-Addons` / `skilltrainer-0.1-beta`. Starting checkpoint: `1b075f6b0d117c76adada69147baa536e687acc1` (0.3.1-beta); `dev` remains untouched.
- **Request:** Let Clairvaux train Enhancing with self-only Enstone without changing Lionstag's separate Protect-on-Myrr setup.
- **Change:** Add Enstone and other tier-I Enspells to self Enhancing candidates; add per-client `//st spell <name|auto>`, validate learned/job/target compatibility, and display selected spell in status. The rest/stand cycle, server-cap stop, books, and other training modes are preserved.
- **Live baseline:** User confirmed Lionstag capped Healing Magic using SkillTrainer. No actual FFXI Enstone tests have been reported for 0.3.2.
- **Verification:** Lua 5.4 syntax passed; `tests/test_target.lua` passed existing target regression; `tests/test_enstone.lua` passed simulated PLD/RDM Enstone selection, safe targeting, auto restore, invalid input rejection, restart, MP rest/stand, and server capped stop. No native Lua 5.1 or actual Windower/FFXI test this turn.
- **Next:** Clairvaux `//st target me`, `//st spell Enstone`, `//st enhancing 5`, then `//st status`. Check spell casts, Enhancing gains, MP recovery and cap reporting; verify Lionstag's Protect-on-Myrr regression.
- **Publication:** This file records the starting source; the delivered GitHub commit is identified separately in the handoff and branch history.

## Current tests — 0.3.2-beta

1. A learned RDM Lv18+ Enstone is selected even if the character also knows Protect; `//st enhancing 5` casts `/ma "Enstone" <me>`.
2. `//st target Myrr` is rejected while Enstone is forced; `//st spell Enstone` is rejected if Myrr is configured, with no self-target fallback.
3. `//st spell auto` returns to original automatic preference. Existing named Protect target behavior continues.
4. At low MP the loop rests; it stands at 90% MP and resumes the selected Enstone.
5. `//st status` includes target and selected spell; capped packet stops training; unrelated skills/books are unaffected.

**Performed:** Lua 5.4 mock tests for target and Enstone passed; not in-game. Full historical book suites were not rerun because book logic was unchanged.

## Delivery register — 2026-11-09

| Batch | Files | Source checkpoint | Verification |
| --- | --- | --- | --- |
| 0.3.2-beta | SkillTrainer.lua, README, TESTING, tests/test_enstone.lua | `1b075f6b` | Lua 5.4 mocks; FFXI live pending |

## User feedback — 2026-11-09

- Clairvaux has Enstone and needs his own Enhancing skill loop, without disrupting Lionstag's already working setup.

---

# Current Development Status — 2026-11-07 (America/Chicago) — SkillTrainer 0.3.1-beta

- **Repository / branch:** `rerorriM-Mirrorer/Windower-Addons` / `skilltrainer-0.1-beta`. Starting live/baseline source is 0.3.0 commit `dc9de3be0c347119437f63ab0f3b079b879c056d`; only the 0.3.1 target changes are intended. `dev` remains untouched.
- **New request:** Lionstag has capped Healing Magic. User wants to train Enhancing by casting Protect (and potentially Shell/Regen) on nearby Myrr, and asks if another player improves skillup rates. Research indicates other players aren't reliably better than self; appropriately leveled friendly NPCs or Trusts can improve rates.
- **Change:** `//st target Myrr` and `//st target me` control the optional per-client, reload-volatile Healing/Enhancing target. Named Enhancing prefers Protect/Shell/Regen, while self-training retains previous Barspell priority with additional fallback spells. Target validity is checked before each cast; missing/out-of-range targets pause rather than trigger a self-cast. Session timer, MP resting, book mode, Singing and Summoning are intentionally unchanged.
- **Observed in-game:** User reports Lionstag's Healing Magic is capped; the exact beta and cap packet evidence aren't independently observed. No named-target live testing has been reported yet.
- **Verification:** Lua 5.4 mock harness passed for named spell dispatch, self fallback, missing/out-of-range pause+resume, unsafe target rejection, Healing reuse, song isolation, mid-session target change, and capped-flag stop. Windower 4 / Lua 5.1 / actual Myrr casting **NOT TESTED** here.
- **Next tests:** On Lionstag, `//lua r SkillTrainer`, `//st target Myrr`, `//st enhancing 5`, `//st status`; observe whether Protect casts reach Myrr and gain skill, verify resting and resumption. Walk Myrr >20 yalms away then back; confirm no cast while away. `//st target me` while training should switch back to a self-compatible spell. Confirm a server capped flag stops the loop. If external cast errors appear, capture exact FFXI text.
- **Publication:** This section records the source baseline; final published SHA is reported in the delivery message and GitHub commit history.

## Current test batch — 0.3.1-beta, 2026-11-07

| Check | Expected | Result |
| --- | --- | --- |
| Named target | `//st target Myrr`; Enhancing dispatches `/ma "Protect" "Myrr"` | PASS in Lua 5.4 mock, not live |
| Default/self | `//st target me` returns to original Barstone choice | PASS in mock |
| Target unavailable | No casts while missing or >20 yalms; resumes when visible | PASS in mock |
| Name safety | Invalid command delimiters rejected | PASS in mock |
| Other modes | Healing can cast Cure on name; Singing remains self-only | PASS in mock |
| Live skills | Confirm Myrr receives Protect and skillups; 20%/90% rest | PENDING |
| Prior book loop | Sequential consumption, confirmation, capped skill skip | No code changes; not rerun in this batch |

## User observation — 2026-11-07

- Lionstag has now capped Healing Magic using SkillTrainer (user-confirmed outcome). User has Protect/Shell, Enthunder, Regen, Aquaveil and Blink as potential Enhancing training spells, and would like Myrr as an optional cast target. Other-player skillups are not assumed faster; testing will establish observed throughput.

---

# Current Development Status — 2026-11-06 (America/Chicago) — SkillTrainer 0.3.0-beta

- **Repository / working branch:** `rerorriM-Mirrorer/Windower-Addons` / `skilltrainer-0.1-beta`; source baseline `77b832cc213f9e3ffd250f30c3a4c7ff22a9cc23` (last published version 0.2). Work remains isolated from `dev`.
- **Change:** `//st books` uses only the 33 known Sparks skill-up tomes (item IDs 6147–6179) from active Inventory; serial item use with count-change confirmation, skipping known capped/unavailable skills and stopping on timeout or unsafe transitions. Add congratulatory whole-level skillup messages from incoming `0x062` and optional Enfeebling Magic cap calculation. Chat follows existing WORKFLOW coloring.
- **User-confirmed live baseline:** User says earlier SkillTrainer training is “already working great.” There is no live report for these 0.3 changes.
- **Verification:** Lua 5.4 parsing and mocked Windower behavior tests passed (book filtering, item-use flow, status, packet skillup, duplicate suppression, timeout, stop, Cure regression). Lua 5.1-native Windower and real FFXI testing NOT RUN.
- **Next live check:** On Lionstag, note `//st status`, run `//st books`, verify Inv. report is recognized as Enfeebling Magic and only actual Inventory items decrease. Check full-skill congratulations and that `//st stop`/timeouts prevent further use.
- **Checkpoint:** This section records the 0.2 starting SHA, not its own final publication SHA. See branch history for final 0.3 SHA.

## Current tests — SkillTrainer 0.3.0-beta (2026-11-06)

1. Load with `//lua l SkillTrainer`: confirm no cast or consumable action until user explicitly invokes a mode.
2. Use `//st books` with Inv. reports in Inventory; verify recognized name, one-at-a-time `/item` use and exactly one confirmation per count decrease. No other item IDs consumed.
3. Place a capped skill book alongside an eligible one; confirm skipped count and no action for capped book when `0x062` cap flag has been observed. Confirm an unavailable-skill book is skipped.
4. Simulate an item command with no Inventory decrement: after 12 seconds the queue stops with diagnostic, no repeated consumption. `//st stop`, `//st unload`, job/level/zone change and 60-minute guard must terminate.
5. Whole-level changes from 0x062 should congratulate exactly once, e.g. Healing Magic 151→152 with current/cap. Repeated packets and same-integer fractional increments should not notify.
6. Regression: `//st healing 5` still casts Cure, rests/stands as before; enhancing, singing and summoning loops retain their prior state machine and 60-minute default. Check all in-game separately before promotion to dev.

**Performed:** Lua 5.4 syntax parse PASS; 0.3 Lua mocked tests PASS for eligibility, sequencing, no false repeats, whole-skillup, command status, stop, timeout, capped flags and Cure; pre-existing 0.2 original tests were not all rerun against the new source. **Not performed:** Windows/Windower 4 real gameplay, item-use server messages or real packet captures.

## 2026-11-06 — User observation and delivery register

- **Request:** User specifically asked for `//st books` to consume all skill-up books in Inventory (Lionstag holds “Inv. Reports”) and a congratulatory `current/cap` notification on each complete skill increase.
- **Reference check:** Inv. report ID 6169 is **Enfeebling Magic**; Aid for All ID 6168 is Enhancing; Coveffe Musings ID 6167 is Healing. Corrects the earlier mistaken tentative identification. Source: FFXI Skill Up Book table and Sparks item mapping.
- **Delivery:** 0.3.0 beta test ZIP plus source/docs on working branch; exact commit and verification in handoff.
- **History:** All earlier entries follow without removal.

---

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