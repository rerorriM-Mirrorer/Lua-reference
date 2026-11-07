# PACKETS.md — SkillTrainer packet investigation

## 2026-11-06 — static inspection (not live capture)

The addon observes packets only. **No injection or packet modification.** No raw user captures were supplied in this batch.

| Direction / ID | Scenario | Fields (from Windower `packets/fields.lua`) | Current use | Confidence |
| --- | --- | --- | --- | --- |
| Incoming 0x062 | Skill update / skillup | Per skill `... Level`, `... Capped` (bitfield) | Cache current skill and cap flag; stop if server capped | High for field definitions; not confirmed in user's FFXI session |
| Incoming 0x061 | Character stats / login | `Master Level` | Add +1 cap per observed ML at 99 | High for field definitions; live availability after addon load unverified |
| Incoming 0x0DF | Self character update | `Master Level` | Refresh ML in long-running sessions | High for field definitions; live availability unverified |

### Numeric cap derivation

The 0x062 packet does **not** carry a numeric maximum. SkillTrainer derives one from the main-job rank and level 1–99 table, optionally +1 per observed Master Level. At 99 without observed ML, displays base only. The server's `... Capped` flag is the authority for automatic stopping, not the numerical estimate.

References:
- https://github.com/Windower/Lua/blob/dev/addons/libs/packets/fields.lua
- https://ffxiclopedia.fandom.com/wiki/Category:Combat_Skills
- https://wiki.ffo.jp/html/38412.html

### Outstanding controlled live observations

1. Sample `//st status` before and after skill gain; compare `0x062` Level with in-game skill.
2. Confirm `... Capped` transitions true exactly when eligible current-job cap is reached.
3. At level 99, observe 0x061/0x0DF Master Level and verify computed cap.
4. For Scholar, record behavior with and without Light Arts; do not assume buffed effective rank is base trainable cap.

## 2026-11-06 — 0.3 book progression / skill notifications (static; no live capture)

- **Incoming 0x062:** The `... Level` field is compared against the last observed integer boundary. During a spell or book session, print one congratulatory message on a whole-skill increase and display the rank-derived cap if available. `... Capped` still determines authoritative stop/skip decisions.
- **Inventory confirmation:** `windower.ffxi.get_items(0)` is polled to compare a pending slot's item ID/count before and after an ordinary `/item` command. **No packet injection**, and no assumptions made about the timing of 0x01E/0x020 inventory update packets; item mutation observation is by Windower's API.
- **Unknowns:** Confirm actual item names sent by the game, server refusal behavior for capped books, and ordering of 0x062 versus Inventory changes on Lionstag. Capture packet data only if behavior diverges.
