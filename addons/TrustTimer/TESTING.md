# TESTING.md - TrustTimer

## Current Development Status - November 12, 2026 (America/Chicago)

- **Repository / branch:** `rerorriM-Mirrorer/Windower-Addons` / `feature/trusttimer-20261112` (working branch; do not merge as live-verified).
- **Addon version:** `0.1.0-test2`. Independent Lua addon at `addons/TrustTimer/` in the working repository; install package folder `TrustTimer/`.
- **Baseline:** Existing Windower-Addons `dev` branch, read alongside canonical NPCMirror workflow; test1 source checkpoint `9040df27fde1797e0ae80369824a0435edcc1ed7`; no known-good live behavior.
- **Automated checks:** Syntax checked using LuaTeX embedded Lua (not Windower's LuaJIT 5.1). Test1: 19 simulated event/command assertions passed with a stubbed Windower API. Test2: 31 additional simulated assertions passed with a stubbed Windower API and LuaTeX. No actual LuaJIT/Windower execution.
- **Live tests:** NONE. No real outgoing 0x06E capture has been observed or decoded by this build; 120-second countdown is estimated.
- **Next:** Load on inviting character, enable debug, invite another actual PC, time first allowed Trust summon; test leader pass and zoning without breaking existing timer.

## Current live acceptance checklist

1. Fresh-install `TrustTimer/` into `Windower4/addons/`. `//lua load trusttimer` should load without chat errors or visible HUD. `//tt help` must display colored Windower help; `//tt status` must identify version/state.
2. `//tt edit` toggles edit mode ON then OFF on consecutive calls; `//tt enabled` and `//tt debug` likewise toggle. Explicit `on` twice stays ON and `off` twice stays OFF for all three. Invalid arguments report syntax without changing state. `//tt test` shows `Trusts Available in 0:15`, counts down independently of framerate, briefly flashes `Trusts Ready!` green and hides. `//tt edit on`, drag, `//tt edit off`; reload and confirm position persists. If off-screen, use `//tt resetpos`.
3. Enable `//tt debug on` on the **inviting** client. Send a party invite to a real second character. Confirm **no timer** before the recipient accepts and **one timer** after human roster join. Compare the display to when Trust summoning actually becomes possible (record discrepancy).
4. Repeat with a declined or ignored invite. No timer should appear. Summoning a Trust NPC should not create/restart the timer. An alliance invitation should not create one.
5. During an active timer, change party leader, including changing it away and back. Record whether the game restriction actually clears; this addon should not manufacture a fresh 120-second timer for the leader change.
6. Zone during an active timer. The remaining estimate should continue, not restart. Loading mid-party should only baseline current members, not start an invented cooldown.
7. Run with two to four FFXI clients, verifying only the client that issued the invitation receives the matching timer. Check font/position at 4K and 720p and verify no invisible mouse interception when edit mode is off.
8. `//tt unload` should remove the primitive; `//tt restart` should reload once without leaving duplicate timers. Check `//tt enabled off` for hidden display and safe reload.

## Testing history and observations

### Batch 0.1.0-test2 - November 12, 2026

- **Request:** Prefer one-command toggling. User confirmed existing chat message formatting is pretty; preserve its style.
- **Changes:** Bare `//tt edit`, `//tt enabled`, and `//tt debug` now invert current state. Explicit `on` and `off` remain repeatable without inversion. Help/README synchronized. Cooldown packet/roster logic not changed.
- **Static / simulated:** LuaTeX `loadfile`/execution with stubbed Windower API passed 31 checks (toggle behavior, idempotent explicit states, invalid inputs, help syntax, preview, ready transition, hide, position, size, and status). No real Windower or FFXI execution.
- **Regression:** Confirm timer preview, active countdown, fade, position persistence and debug toggles in Windower 4. Existing test1 historical record below remains intact.
- **Delivery:** `TrustTimer-v0.1.0-test2.zip`, `TrustTimer/` installable folder, no settings data.


### Batch 0.1.0-test1 - November 12, 2026

- **Change:** New standalone automatic Trust cooldown HUD with client-specific invitation tracking, 120-second initial estimate, quiet auto-hiding state, editor, saved position, debug, and help/status/lifecycle commands.
- **Static:** LuaTeX loadfile compiled without syntax error; this checks syntax on the available embedded Lua, not real Lua 5.1 runtime bindings.
- **Simulated:** 19 assertions covering initial hidden state, invitation intent without join, Trust NPC exclusions, confirmed human join, wall-clock countdown, zoning continuity, ready and auto-hide, join without local invitation, alliance exclusion, demo preview, editing/drag flag, position and font-size changes, enable/disable, pending invitation timeout, and single lifecycle dispatch/cleanup.
- **Unverified:** True Windower 4 outgoing packet semantics; time the game applies its cooldown; leader-change bypass; persistence and font/stroke rendering on actual Windows clients; success-based early completion.
- **Delivery:** `TrustTimer-v0.1.0-test1.zip`, containing one installable `TrustTimer/` folder and no bundled settings data. Source commit is reported in the delivery message rather than embedded here, to keep the packaged testing record synchronized with the committed source.

## User feedback and requests

- **2026-11-12 (follow-up):** User asked that bare toggle commands toggle rather than require `on`/`off`, especially `//tt edit`. User liked the existing addon-conventions chat formatting; do not change it.

- **2026-11-12:** Requested a tiny visible timer after party invitation/leadership changes when Trusts cannot be summoned. Preferred the appearance of EnemyBar2's main target bar name text, with no permanent clutter. Approved a standalone addon, `//tt test` and `//tt status` commands, a green completion moment, and independent client-local operation.

## Future work / investigation

- Measure actual retail cooldown and whether the inviting party leader is uniquely restricted. Improve timing calibration or detect an explicit server message, if evidence supports it.
- Detect valid successful Trust summon and cancel any inaccurate timer only after reliable confirmation; do not treat an attempted cast as success.
- Consider handling an invitation acceptance before the first roster baseline; avoid false countdowns on addon loading/zoning.
