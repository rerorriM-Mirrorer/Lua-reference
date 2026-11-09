# SkillTrainer — 0.3.2 beta

A small, opt-in Windower 4 skill-training addon evolved from the standalone CarbyTrainer v1.0 Lua file. Each client runs independently. No spell is cast merely by loading the addon.

## Install

Copy the `SkillTrainer` folder to `Windower/addons/SkillTrainer`. In-game: `//lua l SkillTrainer`. Do not rename the `SkillTrainer.lua` file. CarbyTrainer can remain installed, but **unload CarbyTrainer** on any client using SkillTrainer summoning so two addons don't compete for Carbuncle.

## Commands

- `//st healing [minutes]` — Repeated Cure on self or configured target; rest at or below 20% MP; rise at 90%; stop when capped or timer expires.
- `//st enhancing [minutes]` — Self: available Barspells, falling back to Protect/Shell/Enthunder/Enstone/other tier-I Enspells/Regen/Aquaveil/Blink. Named target: Protect, Shell, then Regen.
- `//st target Myrr` — Send Healing or Enhancing casts to the visible named character (player, party Trust or eligible NPC). Other modes stay self-targeted.
- `//st target me` — Restore self-targeting. `//st target` reports the current target.
- `//st spell Enstone` — Prefer exactly Enstone in Enhancing mode after verifying it is learned, job-usable, and self-target compatible. Other supported Enhancing spells may be selected similarly.
- `//st spell auto` — Restore automatic Enhancing spell selection; `//st spell` displays the current preference.
- `//st singing [minutes]` — Repeat an available Army's Paeon/Valor Minuet song. Songs require no MP; this mode stops on **Singing** skill cap, not necessarily the equipped instrument's cap.
- `//st summoning [minutes]` — Summon Carbuncle only when pet-free; release only if current pet is Carbuncle. Works as the CarbyTrainer replacement.
- `//st books` — Use recognized skill-up tomes from **Inventory** in sequence until exhausted. Skip capped/unavailable skills, confirm each item count decrement, stop if use is not confirmed. Safe to run separately from spell training.
- `//st cap <number>` — Manually set a skill cap for the current mode, if automatic cap status hasn't been observed or you want to stop earlier.
- `//st cap auto` — Remove the manual cap override.
- `//st status` — Show current skill/cap, MP and time for spell loops, or books used/remaining/skipped during `//st books`.
- `//st stop` — Stop, standing up if SkillTrainer initiated the rest.
- `//st restart` — Start the last mode for its last duration again.
- `//st debug on|off` — Show decisions/transitions for testing.
- `//st unload` — Stop, then unload.
- `//st help` — Display commands.

For Lionstag, run `//st target Myrr`, then `//st enhancing 5`, and check `//st status` for `target Myrr`. The name is local to each client and lasts until changed or SkillTrainer is reloaded. It may be changed during training without restarting: the addon switches to an appropriate spell, preserving an ongoing `/heal` transition. Myrr must remain visible and within approximately 20 yalms; if she leaves, the addon waits without casting, then resumes when she returns. A name must not contain chat-command characters. Named casting uses FFXI's `/ma "Protect" "Myrr"` form without changing Lionstag's actual selected target. This is *not* a guarantee of more skillups: self and other players are similar; high-level friendly NPCs/Trusts can give better rates when eligible and targetable.

For Clairvaux, use `//st target me`, `//st spell Enstone`, `//st enhancing 5` for a short test (or `//st enhancing 60` for a full hour). Enstone is self-only, costs 12 MP, casts in 3 seconds, and has a 10-second recast. It can be learned by RDM from level 18, including a sufficiently leveled subjob. A configured Enspell cannot be redirected to another character; the addon explicitly rejects that combination. The spell preference is **per client**, lasts for the current addon load, and does not change Lionstag's choice on another client. `//st status` shows the actual selected spell and target, even if the preference is automatic. The existing rest, timer, and server capped flag still govern the loop. If Enstone is unavailable to the current job/subjob, the addon refuses the preference rather than silently selecting something else.

Spell-loop duration defaults to **60 minutes**, adjustable from 1 to 1440 minutes. `//st books` has its own 60-minute safety limit. The server capped flag stops a spell loop first.

## Numeric cap calculation and server confirmation

The **0x062 Skills Update** packet contains `Healing Magic Level` / `Healing Magic Capped` (and equivalent fields for other modes), **but not the numerical skill cap**. SkillTrainer calculates the cap from the main job's skill rank and level using the documented FFXI skill-cap progression from level 1 to 99. It reads the latest skill value directly from the packet, falling back to Windower's `get_player().skills` until a packet arrives.

Supported rank/job pairs: Healing (WHM, PLD, RDM, SCH); Enhancing (BLM, PLD, RDM, RUN, SCH, WHM); Singing (BRD); Summoning (SMN); and Enfeebling (BLM, DRK, GEO, RDM, SCH, WHM) for book-progress reporting. Other book skills display an unknown cap until one is observed capped; no unsupported numeric cap is invented. At level 99, a known **Master Level adds +1 per level** to the cap; SkillTrainer learns it from passive 0x061 or 0x0DF packets. If Master Level has not yet been observed, the number is explicitly shown as a **base cap**, e.g. `424+ML? (base only)`, rather than claiming an exact total. Scholar's rank is the base D rank; Light Arts can enhance effective skill, but the **server capped flag is authoritative** for the actual stopping decision.

Examples (before Master Level): WHM 75 Healing cap **276**; WHM 99 Healing **424**; SMN 99 Summoning **417**; BRD 99 Singing **373**. A WHM 99 at ML25 has a Healing cap of **449**.

`//st status` shows `skill 151/276 | server uncapped` after the relevant skill packet. When an updated cap first becomes available, the addon reports it in chat. It only stops automatically when the **server reports capped**, a manual `//st cap <number>` is reached, or the time limit expires. Numeric calculations alone never prematurely stop a session. If a cap flag is set and the packet supplies the skill value, the addon can report that exact server-observed cap.

The chat format uses `string.color` per WORKFLOW.md: separator 140; heading 167; `//st` and `->` 200; command syntax 207; descriptions and ordinary feedback 0, all through `windower.add_to_chat(0, ...)`.

References: [Windower packet fields](https://github.com/Windower/Lua/blob/dev/addons/libs/packets/fields.lua), [FFXIclopedia Combat Skills rank/cap chart](https://ffxiclopedia.fandom.com/wiki/Category:Combat_Skills), [Master Level skill cap bonus](https://wiki.ffo.jp/html/38412.html).


## Skill-up books and congratulations

`//st books` identifies the 33 known Sparks skill-up books by item ID **6147–6179**. For example, **Inv. report** (`6169`) increases **Enfeebling Magic**; **Aid for All** (`6168`) increases **Enhancing Magic**; **Coveffe Musings** (`6167`) increases **Healing Magic**. The addon reads **active Inventory only** (`get_items(0)`); it does not use items from Sack, Satchel, Case or Wardrobes and does not move items. Other consumables are never selected.

Book mode is deliberately exclusive with spell training. Each `/item "<resource item name>" <me>` command is followed by a wait for that slot's quantity to decrease. A successful decrease schedules the next book after a short buffer; a capped skill is skipped; an unconfirmed use after 12 seconds **stops** the book session rather than retrying indefinitely. `//st status` reports used, eligible remaining, skipped and pending item. `//st stop`, `//st unload`, job/level/zone changes, and the 60-minute session limit all end book mode. Skill values unavailable for the main job are skipped. If `0x062` hasn't been observed since loading, some capped books may only be rejected by the game; the timeout then stops the queue.

Whenever the incoming `0x062` packet shows a **new whole-number** skill level during an active mode, SkillTrainer reports `SkillTrainer -> Congratulations! Healing Magic 152/276 (+1)` (example for a WHM at level 75). Fractional skill gains do not cause duplicate messages. In book mode any affected skill may be announced; when a job/rank numeric cap isn't known, it prints `unknown` instead of guessing. Source book mapping: [Skill Up Books](https://pegasusxi.com/wiki/Category:Skill_Up_Book).

## Safety and limitations

- Runs only when explicitly started; never auto-starts from loading. Blocks new actions during menus, chat entry, combat, death and zoning.
- Stops on job, level, character or zone changes; does not alter gear, deploy Trusts or engage enemies. Only the explicit `//st books` command uses recognized skill-up consumables from Inventory.
- Skilling from a **subjob alone** cannot advance a skill not owned by the main job. An attempted spell need not succeed; if unavailable/recast handling varies, report the exact behavior.
- Casts use resource-defined MP costs, availability, and conservative cast/recast buffers; the beta has **no confirmed spell-completion event handling** yet. Observe whether all actual casts land and whether resting behaves correctly in-game.
- Changing gear/job/spells during a session is not recommended. Song mode assumes a suitable instrument is already equipped if training instrument skill is desired.
- Does not log off, shut down the game, or monitor threats. Use in a safe location and observe the first several cycles.

## Development provenance

- Initial input: `CarbyTrainer.zip` from this conversation, version 1.0.
- Source baseline: `rerorriM-Mirrorer/Windower-Addons`, branch `dev`, head `e9cf6ad66b42c322be0351dd735893c85bac4369` when checked 2026-11-06.
- Version 0.1 was a local uncommitted beta. Version 0.2 was published as commit `77b832c` on the `skilltrainer-0.1-beta` branch. Version 0.3 added books and congratulations; version 0.3.1 adds named-target training. See TESTING.md for publication and live verification status.

## Cumulative changelog

- **2026-11-09 — 0.3.2-beta:** Added first-tier Enspells (including Enstone) to self-targeting Enhancing discovery, plus optional per-client `//st spell <name|auto>` selection; validates learned/job eligibility and self-only target restrictions, permits changing spell mid-session, shows selected spell in status; retains Lionstag named-target defaults, books and capped-flag behavior.

- **2026-11-07 — 0.3.1-beta:** Add `//st target <name|me>` for Healing/Enhancing spells, named-target Protect/Shell/Regen prioritization, additional self-cast spell fallbacks, conservative visibility/range pausing, safe target-name validation, mid-session switching without disrupting an ongoing MP-rest transition, and updated `status`/`help` output. No changes to Singing/Summoning target selection, book consumption, skill packet parsing or cap stop logic. User reports Lionstag has capped Healing Magic using SkillTrainer; named-target behavior is not yet confirmed in FFXI.

- **2026-11-06 — 0.3.0-beta:** Add `//st books` for all 33 recognized skill-up tomes, Inventory-only sequential consumption with no automatic retries, capped/unavailable skipping and count confirmation; add one congratulatory message per completed whole skill level during a training or book session; calculate Enfeebling Magic caps where job rank is supported; update status/help/packet docs and mocked tests.

- **2026-11-06 — 0.2.0-beta:** Calculate main-job numerical skill caps for all four training modes using skill-rank tables; account for observed Master Level; consume live 0x062 skill levels; continue using server capped flags for stopping; display current/maximum and server state; adopt WORKFLOW.md chat colors and output conventions; expand simulated tests and packet documentation.

- **2026-11-06 — 0.1.0-beta:** Converted the Carby summon/release loop into explicit Healing, Enhancing, Singing, and Summoning modes; added MP rest state machine, passive skill-cap flag detection, 60-minute default session limit, manual cap override, status/help/debug/stop/restart/unload, and safeguards for other pets.