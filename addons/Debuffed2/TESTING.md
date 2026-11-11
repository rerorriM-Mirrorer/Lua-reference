# TESTING — Debuffed2 independent edition

## Current testing batch — Debuffed2 Test 1 (2026-11-11)

- **Source:** `rerorriM-Mirrorer/Windower-Addons`, based on published Debuffed Test 2.4.5 Save 1 (`88011713f46d3822431fa4d13928845d9539ef09`) from `work/debuffed-position-save-20261107`. New candidate branch: `work/debuffed2-name-style-20261111`. Original `addons/Debuffed/` and previous development branches are unchanged.
- **Purpose:** Isolate the personalized icon addon from Windower updates to stock `addons/Debuffed/`, and match the EnemyBar2 main target name typography without brackets.
- **Rename:** `Debuffed2/Debuffed2.lua`, `_addon.name='Debuffed2'`, internal renderer module `debuffed2_renderer`, commands `//db2`/`//debuffed2`, restart/unload target `Debuffed2`. No inherited `db` aliases or auto-migration of saved data.
- **Heading:** EnemyBar2 `cioara-defaults-2026-11-10` uses main name font Arial 14 bold italic, 2px stroke (alpha 180, near-black for FFXI skin); Debuffed2 uses this typography but keeps its previous white color and name-only content. No brackets, dynamic HP percent or EnemyBar2 target-color logic. Classic text fallback also removes brackets. Default `targetname=false` remains unchanged.
- **Non-goals:** No changes to the original debuff tracker, row/slot defaults (`wrap=16`, `slots=16`), 24px icon size, layout math, position saving, Ctrl+drag, fades, or assets. No promotion to an existing tested baseline.
- **Installation:** Extract only `Debuffed2/` into `Windower/addons/`; preserve existing `Debuffed/data/` and do not load both addons simultaneously for ordinary testing. Optional personal XML migration only after backing up and unloading. XivParty icon textures remain an external dependency.

### Checks completed in this development session (offline only)

- `texlua --luaonly` parsed `Debuffed2.lua` and `debuffed2_renderer.lua` successfully. This is a syntax check, not proof of Lua 5.1/Windower integration.
- Mocked renderer creation/rendering: Arial 14 bold italic, dark 2px stroke alpha 180, unbracketed name, correct targetname on/off behavior, 24px and 96px icons, two rows of eight, position retention relative to the parent anchor, and resource cleanup: **PASS**.
- Static identity/command verification: new addon/module/file names, `db2`/`debuffed2` aliases only, no hijacking of `db`, `dbf`, or `debuffed`, and restart/unload dispatch to `Debuffed2`: **PASS** by code inspection.
- Mocked main-addon entrypoint: validated `Debuffed2` identity/aliases, in-chat `//db2` help, status, and exactly one `lua r Debuffed2` after a simulated restart; **PASS**. The mock does not replace Windower input or in-game testing.
- Debuff tracker section compared byte-for-byte with Test 2.4.5 Save 1: **PASS**. Settings schema and 24px/16/16 defaults unchanged; previous persistence tests are historical and were not re-run against Windower here.
- Actual UI rendering, input and persistence in FFXI are **not tested**; the test build must not replace the last user-tested baseline until accepted.

### In-game acceptance still needed

1. `//lua u Debuffed`, `//lua l Debuffed2`, `//db2 status`: check the version, aliases, and independent folder. `//db2 help` should show the new prefix; `//db` should not be taken over by Debuffed2.
2. `//db2 targetname on` and target a valid claimed monster: check Arial 14 bold italic, outlined name without brackets, heading above icons and no clipping. Turn it off and confirm layout returns to its earlier position.
3. Run `//db2 wrap 8`, `//db2 slots 16` (two eight-icon rows), `//db2 iconsize 24`; test normal and Ctrl+drag, save position, reload and zone. Try extreme icon sizes and multiple window resolutions.
4. Check edit previews, timer labels, original Dia-first tracking, fades, reload/unload only affecting Debuffed2, and independent settings persistence. Restart and load from an AddonManager profile if used.
5. Verify the original Debuffed directory remains unchanged and a Windower addon update does not overwrite `Debuffed2/` (not simulated here). Do not claim live acceptance until observed.

---

## Historical Debuffed testing record retained verbatim

# TESTING — Debuffed Icon Presentation

## Current development — Test 2.4.5 Save 1 (2026-11-07)

- **User observation (live FFXI):** Version `1.0.0.4-icons-test2.4.4-grid1` sometimes fails to retain the newly dragged position. This is a report about the previous version; the new fix has **not** been tested in-game.
- **Source:** `rerorriM-Mirrorer/Windower-Addons`, based on committed `work/debuffed-ctrl-grid` commit `5a8fcda4f6daf68754c801c2f65ef6657a9d2c09`. Isolate this work on a new branch; do not replace the previously working `work/debuffed-icons`, existing grid branch, or `dev` baseline.
- **Diagnosis:** In Grid 1, pending saves occur only in the `elseif` branch of `sync_position`. When `images.lua` repeatedly proposes a raw position inside the same snapped grid cell, the `if moved` branch prevents the debounce from saving, even though the anchor has stopped changing. `layout()` also clamps a changed viewport position without recording it in `settings.pos`, and `visual_time()` falls back to CPU time if LuaSocket is unavailable, making the wait depend on client CPU usage.
- **Fix:** Track any effective anchor changes, including viewport clamps; use a real elapsed clock for the save debounce (LuaSocket `gettime`, with `os.time` fallback). Check the pending-save timer **independently** of raw drag motion. Flush pending positions before a display/edit/layout transition, restart/unload fade, and on renderer destruction. The existing `images.lua` mouse capture, Ctrl snap, icon layout, and tracking are retained.
- **Modified executable files:** `addons/Debuffed/icon_renderer.lua` and `addons/Debuffed/Debuffed.lua` (build marker plus position-flush wiring). No external input interception, texture or saved-config schema changes. `draggrid` remains default 10px.

### Available verification — simulated/static, not FFXI

- Lua `loadfile` parse for both files using `texlua --luaonly`: **PASS**. This parser isn't a full Lua 5.1/Windower environment.
- Renderer mock: **PASS** — normal drag saved after debounce; Ctrl snapping to screen-origin 10/16px grid; repeated raw jitter inside the same snapped cell no longer blocks saving; explicit flush saves immediately and exactly once; pending changes save on `destroy`.
- Layout regression mock: **PASS** — grid spacing independent of 12/24/96px icons, oversized field and viewport resize adjust the anchor and save it; bounds checked across 320×240, 960×540, 1280×720, 1600×900, and 3840×2160.
- LuaSocket absent mock: **PASS** — fallback persistence clock advances by wall time (`os.time`) even if CPU time would not.
- Static scope comparison against Test 2.4.4: tracker section unchanged, original mouse capture/keyboard callback preserved, no animation timing change. Earlier tests remain historical observations, not retested in FFXI.

### In-game acceptance checks (pending)

1. Back up `Windower/addons/Debuffed/`, especially `data/settings.xml`. Install the new `Debuffed/` folder and reload; check `//db status` shows `1.0.0.4-icons-test2.4.5-save1`.
2. Drag the field to a new *non-grid* location. Wait a second, check `//db status` for its reported field coordinates, `//lua r Debuffed`, and verify it returns at the new position.
3. Repeat with **left Ctrl** and **right Ctrl**, moving in and out of the same 10px cell several times before releasing. Reload and verify the last snapped anchor persists. Check `//db grid 16` and restore 10.
4. Drag and immediately run `//db edit off`, change layout or slots, or `//db restart`. Verify position survives. Repeat using `//db unload` and `//lua l Debuffed`.
5. Try small and large icons, changed wraps, edges of 3840×2160 and smaller 1600×900/1280×720/960×540 clients. Verify position is saved after onscreen clamping and no icons/timers drift.
6. Check `//db preview`, editing guides, real debuffs, target switching, and animation/restart/unload timing. For multiple clients, confirm their saved positions behave independently.
7. If the problem continues, record `//db status` field coordinates before and after reload and which character/window size is affected; do not assume the on-screen position equals the file's saved coordinates.

---

## Previous development — Test 2.4.4 Grid 1 (2026-10-18)

- **Repo / source branch:** `rerorriM-Mirrorer/Windower-Addons`, starting at `work/debuffed-icons` commit `667da6e`; candidate on `work/debuffed-ctrl-grid` (keeps live-used version separate).
- **Scope:** Icon field positioning only. Native `images.lua` retains mouse capture; callback simply observes left/right Ctrl (DIK 29/157) without consuming keyboard input. The field's single draggable backdrop is the absolute screen-origin grid anchor.
- **Commands:** `//db grid` reads spacing; `//db grid <1-200>` persists an integer pixel spacing, default 10, independent of icon size or layout.
- **Bounds:** Clamp top-left anchor using actual rendered widget width/height and Windower UI resolution. A widget larger than the viewport is pinned to origin on the overflowing axis; resize layout to restore movement. Live resolution changes re-bound the field.
- **Source preservation:** Tracker section `function handle_overwrites` through the incoming-chunk handler remains byte-for-byte identical to Test 2.4.3. Existing fade, preview, and restart/unload shutdown sequence is unmodified apart from passing the Ctrl flag to its existing position flush.
- **Packaging:** Install the `Debuffed/` directory into `Windower/addons/`. Do not overwrite `data/settings.xml` and do not nest addon folders. See README for XivParty icon dependency. Place workflow/testing guidance alongside the addon according to the current canonical rules.

### Verification completed — offline only

- **Lua parser:** `texlua` loadfile syntax checks for `Debuffed.lua` and `icon_renderer.lua`: PASS. `texlua` is not a full Windower 4/Lua 5.1 compatibility or input test.
- **Renderer mock:** PASS — free dragging to precise pixels; screen-origin Ctrl snapping (10 and custom 16px); immediate return to free drag; bounds on 320×240, 960×540, 1280×720, 1600×900, 3840×2160; viewport resize without mouse motion; oversized field fallback; saved-position debounce; 12px and 96px icons with repeated resizing and no cumulative geometry drift; icon/outline/sample/timer common anchoring; preview/exit and teardown paths.
- **Modifier path:** PASS by code inspection — DIK 29/157 are separately tracked, and the passive `keyboard` callback returns no keyboard-blocking result. Full key-down/mouse-drag integration is NOT tested in a Windower client.
- **Regression diff:** PASS — original tracker unchanged; only version, grid defaults/command, passive modifier observation, positional clamp/snap path, and documentation modified. No new scale factor introduced; existing `iconsize` remains pixel-based.
- **Actual FFXI verification:** NOT performed; please verify free drag, both Ctrl keys, edit preview, live icon positioning, settings persistence across reload, narrow-window boundaries, target switches, restart, and unload.

### In-game verification checklist (pending)

1. Back up installed `Debuffed/` and its settings; install test build and `//lua r Debuffed`; check `//db status` and `//db grid` (10px).
2. Drag field freely to a non-grid position, e.g. `(273,57)`; confirm smooth pixel placement. Hold **left Ctrl** while moving and check `(270,50)`-style snapping. Repeat with **right Ctrl**; check release restores free dragging.
3. Run `//db grid 16`, test screen-origin multiples of 16, then `//db grid 10`; reload and confirm grid/position persist.
4. Test near each screen edge, on large screen and smaller multibox window (e.g. 3840×2160 desktop, 1600×900, 1280×720 and 960×540 clients). Confirm readable onscreen field and sensible behavior if configured field exceeds viewport.
5. Try `//db edit on`, 12px and 96px `//db iconsize` (restoring 24 afterward), horizontal/vertical wrap, target name, and real debuffs. Check children remain aligned to the field while dragging or after settings changes.
6. Confirm preview starts, its 11..0 counter and the edit countdown still run; `//db restart`, `//db unload`, and saved position still work. Check classic text fallback is unchanged.

### Pre-existing layout observations — reported separately, not redesigned

- Debuffed already uses the draggable backdrop as one anchor; guide samples deliberately inset by one pixel, and timer labels are centered from text extents when available. No pre-existing coordinate-system split was found in the icon layout.
- Text/font metrics, outline strokes and fixed-pixel insets may appear a pixel off at extreme icon sizes or different DPI; that should be assessed in-game before changing unrelated rendering design.
- Existing transparent drag rectangle can still intercept mouse input even when alpha is zero; fixing this would change the known-good drag interaction and was intentionally kept outside the current scope.
- The separate classic text fallback does not share the backdrop's drag anchor; it is deliberately untouched.

---

## Previous development — Test 2.4.3 (2026-10-13)

## Current delivery

**Batch:** Test 2.4.3 (2026-10-13)  
**Build ID:** `1.0.0.4-icons-test2.4.3`  
**Base:** Test 2.4.2 compact-timer source, GitHub revision `0735414` on `work/debuffed-icons`.  
**Git:** Test 2.4 restored in `a92dda3`, color refinement in `02f38d1`, 2.4.2 compact timers repaired at `0735414`. Latest 2.4.3 revision is maintained on `work/debuffed-icons`; `dev` untouched.  
**Original tracker:** From `function handle_overwrites` through the incoming-chunk handler, byte-for-byte identical to Test 2.3 (scripted comparison).
**Delta from 2.4.2:** Chat help prints neutral white descriptions and full `//db` command prefix with `->` arrow; edit dummy timer counts 61..0 instead of 70..0. Manual preview, live tracker and restart/unload unchanged.

### Installation precautions

Extract at `Windower/addons/` (archive contains `Debuffed/`). Avoid nesting `Debuffed/Debuffed/`. Preserve `Debuffed/data/settings.xml`. The `WORKFLOW.md` and `TESTING.md` files are in the ZIP root for developer reference; install only the `Debuffed/` folder. XivParty is needed separately for icon textures.

### Try these first

1. In game: `//lua reload Debuffed`. Confirm short intro and fade. Optionally use `//db status` to verify Test 2.4.3.
2. Run `//db slots 16` and `//db wrap 16`, since existing settings can still say 32.
3. Run `//db edit` and confirm 16 familiar **outlined edit squares** each containing a semi-transparent example icon. The timer should show `1m` for the first 2 seconds (61 and 60 remaining), then `59`, `58` ... `0`, resetting to `1m` each cycle. Check that moving field works and `//db edit off` removes the samples without losing the position.
4. Run `//db preview` outside edit mode. Confirm 11..0 labels on example icons over 12 seconds, then faded disappearance. Confirm that actual debuff tracker is unaffected.
5. Adjust `//db timersize 7`, `//db timerx -2`, `//db timery -4` while editing; confirm sample timers reposition/sizes update. Restore preferences.
6. Run `//db help`, verify the full BattleStations-like palette: yellow/warm borders, contrasting title/section, accented `//db` and `->`, light syntax, **white** descriptions. Help appears **only in FFXI chat**, not duplicated in console.
7. Test `//db restart`: chat reports restart, icons/edit presentation fade, addon comes back with intro. Test `//db unload`: fades and stays unloaded; restore with `//lua load Debuffed`.
8. Apply Dia to an enemy and ensure it appears first; verify real timer/target/debuff removal in combat. Test with other concurrent Windower clients when convenient.

### Offline checks completed

- Syntax: `luatex --luaonly` loadfile for both Lua modules: **PASS**.
- Renderer mock (earlier baseline): intro; fade; 11..0 manual; 1:10→0:00→reset edit samples; guide + icon + timer layering; X/Y timer offsets; resizing; wrapping; live sprite; orderly cleanup; fade before unload: **PASS** (from Test 2.4.1; the timer-format change is separately checked below).
- Command mock: default slots/wrap 16, help output via chat only, edit on, wrapping/slot changes, manual preview notice, shutdown delay, exactly one `lua r Debuffed` or `lua u Debuffed` after fade: **PASS**.
- Original tracking section compared to Test 2.3: **PASS / unchanged**.

**Not tested:** actual Windower runtime, XivParty texture rendering and color codes in the FFXI chat window, physical controller behavior, live effect expiration semantics. Do not assume offline simulations establish those.

- Test 2.4.2 timer formatting cases (unchanged): `1796s → 29m`, `70s → 1m`, `60s → 1m`, `59.9s → 59`, `1s → 1`, plus edit 70..0 and manual 11..0: **PASS** (offline; pending in-game).

### Known risks / follow-ups

- Many help lines may scroll the game chat; consider grouped/help topic pages if this becomes intrusive.
- The whole transparent icon rectangle remains mouse-draggable in normal mode, as in earlier builds.
- Icon count increases primitives and rendering load per client.
- The original effect duration uses `os.clock`, not real wall time; no tracking changes were attempted in this presentation batch.
- Native FFXI text extents and `Arial Bold Italic` presentation may differ from offline estimates.

## Earlier batches

- **Test 2.4.2 (2026-10-13):** Native-style timers, 70-second edit preview; published and verified with corrective Git revision `0735414`.

- **Test 2.4.1 (2026-10-13):** BattleStations color hierarchy on top of Test 2.4; committed as `02f38d1`.

- **Test 2.4 (2026-10-13):** preserved in Git as commit `a92dda3` after the original testing ZIPs had remained uncommitted. This catch-up does **not** fabricate separate historical commits. Added animated 11..0 preview, edit sample countdowns, 16-slot defaults, fade-aware reload/unload, colored help. User liked the help appearance, but the precise color palette was not yet verified in-game.


- **Test 2.3 (2026-10-10):** timer typography, icon count, wrap, `//db`; earlier Test 2.2 behavior was visibly confirmed by the user; new Test 2.3 features were not individually confirmed. This is the source baseline, not a claim of full live validation.
- **Test 2.2:** chat log feedback and edit outlines; user liked the individual slot guides and startup animation after correcting nested folder installation.
- **Test 2.1:** startup sample preview texture timing fixes and diagnostics.
- **Test 2:** initial startup/exit fading and Dia-first sorting.
- **Test 1:** original Windower Debuffed tracking plus icon presentation adapter.

## User-provided test observations / requirements

- The startup animation was described as lovely; 32 individual edit square guides were liked.
- Earlier confusing “no animation” reports were partly caused by extracting archives into the already existing Debuffed directory, creating `Debuffed/Debuffed/`.
- User requested BattleStations-style help, chat-only help output, sample timer animations, 16/16 defaults, and standardized restart/unload behavior.

## Test 2.4.3 specific checks

- **Offline syntax:** LuaTeX `loadfile` for `Debuffed.lua` and `icon_renderer.lua`: **PASS**.
- **Mocked help output:** 33 ordered chat lines, 26 `//db` examples, white base color `0`, accented `->`, zero calls to console: **PASS**. Actual in-game color rendering is unverified.
- **Timer bounds:** edit time 61s→`1m`, 60s→`1m`, 59s→`59`, 1s→`1`, 0s→`0`, 62s loop reset→`1m`; 29m56s→`29m`; manual preview 11..0 code unchanged: **PASS**.
- **Regression scope:** diff from 2.4.2 changes only build marker, help output, edit dummy timer counter, and documentation. Restart/unload and packet tracker untouched: **PASS** (static). User previously reported restart and unload working in FFXI.
- **Live status:** FFXI render and colors for Test 2.4.3 untested; do not label as live-verified.

- Inspect chat help `//db help`: every entry must begin with distinct-colored `//db`; arrow should be `->` (verify FFXI glyph renders cleanly); descriptions should be true neutral white, not pale command color; headings and separators remain as before. No console duplicate.
- `//db edit on`: verify first sample reads `1m` for about two seconds, then `59` `58` ... `0` and resets; outline squares remain visible and semi-transparent icons persist. Manual `//db preview` still counts `11` to `0`.
- Regression: `//db restart` and `//db unload` should still fade and dispatch exactly once. Live tracking must still work.
- Offline results and untested conditions will be recorded after build tests.
