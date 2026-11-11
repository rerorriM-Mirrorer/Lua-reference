# Debuffed2 — independent icon-presentation test build

Original addon: Xathe, `Debuffed` v1.0.0.4 (Windower/Lua).  
Icon presentation, help, and transitions: A.  
Testing build: `1.0.0.4-debuffed2-test1` (2026-11-11), based on the complete Debuffed Test 2.4.5 Save 1 fix.

## Debuffed2 independent installation

This is an optional copy of our updated Debuffed, installed separately as `Windower/addons/Debuffed2/` so an ordinary Windower update of `addons/Debuffed/` does not replace this edition. It registers only `//db2` and `//debuffed2`, not `//db`, `//dbf` or `//debuffed`; no command collisions with the stock addon.

First unload the old addon with `//lua u Debuffed` to avoid duplicate tracking/UI. Then install the complete `Debuffed2/` directory into `Windower/addons/` and run `//lua l Debuffed2`. Start with fresh Debuffed2 settings; after validating the new version, optionally copy your backed-up original `Debuffed/data/settings.xml` into `Debuffed2/data/settings.xml` while the addon is unloaded, then reload it. This is an explicit one-time migration, not an automatic modification of either installation.

Run `//db2 targetname on` to show the current target name above the icon field, in EnemyBar2's main-bar **Arial 14 bold italic, 2px outlined** name style, without surrounding brackets or an appended HP percentage. The original default of `targetname off` remains unchanged. The classic-text fallback also removes the old `[name]` brackets.

The `//db2 wrap 8` command starts a new row after eight icons; `//db2 slots 16` limits the display to sixteen icons total. Default icon size is still 24px. Existing Ctrl+drag grid-snapping and position-saving fixes carry over.

## Installation

1. Back up the original `Windower/addons/Debuffed/` and its `data/settings.xml`; do not remove or overwrite it.
2. Extract the ZIP into **`Windower/addons/`**, *not* into `Windower/addons/Debuffed2/`. The archive already includes the `Debuffed2` folder.
3. Confirm that the active file is `Windower/addons/Debuffed2/Debuffed2.lua`, **not** `Windower/addons/Debuffed2/Debuffed2/Debuffed2.lua`.
4. Replace files when prompted; your `data/settings.xml` is **not included** in the archive.
5. Install XivParty separately with its original `assets/buffIcons/` directory. We read those existing textures and do not redistribute them.
6. Unload the original addon if it is loaded (`//lua u Debuffed`); then run `//lua l Debuffed2` (use `//lua r Debuffed2` for future updates).

Command aliases: `//db2` and `//debuffed2`. (`//db`, `//dbf`, `//debuffed` belong to the original addon.)

### Positioning and Ctrl+drag (Test 2.4.4)

The icon field is always draggable as before. **Drag normally** for smooth, unrestricted pixel positioning within the current Windower UI viewport. **Hold either Ctrl key while dragging** to floor the field's top-left parent anchor onto the same shared, screen-origin grid as BarFiller2/EnemyBar2: `(273,57)` becomes `(270,50)` at the default 10px spacing. Child outlines, icon art, texts and timers follow that one anchor; individual elements do not snap independently.

`//db2 grid` reports spacing, `//db2 grid 10` restores the default and `//db2 grid 16` sets 16px. This is independent of `//db2 iconsize`, `//db2 wrap` and timer size. Grid spacing and the moved location persist to the character's existing settings. Drag coordinates are recorded immediately, then saved after roughly 0.65 seconds without an anchor change; a display/layout command, restart, or unload saves any pending movement immediately. The widget is clamped to the viewport. If it is larger than the viewport (for example, too many large icons), its anchor clamps to `(0,0)` on the overflowing axis; reduce slots, wrap, or icon size if needed.

The classic text fallback retains its historical behavior apart from its newly unbracketed target name; the new grid applies to the **icon** field's existing draggable backdrop, not an unrelated text widget. No extra keyboard or mouse blocking is introduced.

## Inherited from Test 2.4

- `//db2 preview` — full **12-second** visual preview: 11, 10, ... 0 (one count per second), then a 0.65-second fade-out. Samples are **not** reported as enemy debuffs. The *automatic* startup animation remains brief (1.2-second hold plus 0.65-second fade).
- `//db2 edit` — 16 outlined slot guides by default, with dimmed sample status icons and individual timer labels. Their 62-second sample cycle repeats, displayed as **1m → 1m → 59 → ... → 0 → 1m** until editing is turned off. Real tracked icons are temporarily hidden during edit mode. Timer X/Y offsets and timer size apply to these dummy labels too.
- Default `slots=16`, `wrap=16`, horizontal orientation (one row). **Existing saved settings override defaults**: run `//db2 slots 16` and `//db2 wrap 16` once if your prior installation retained `32`.
- `//db2 restart` — reports action in the FFXI chat log, fades visible UI for ~0.36s, then sends `lua r Debuffed2` once.
- `//db2 unload` — same closing transition followed by `lua u Debuffed2` once.
- `//db2` or `//db2 help` — new BattleStations-inspired, color-coded in-game help with commands and explanations; no deliberate duplicate console output. Bad commands receive short errors instead of dumping the entire help.
- `//db2 status` — current version, mode, layout position and icon diagnostics.

## Commands

The bracket notation is `<required>` and `[optional]`. The `|` character indicates a choice, not something to type literally.

| Command | Function |
|---|---|
| `//db2 help` | Show the complete chat help |
| `//db2 edit [on\|off]` | Toggle or set the positioning/edit preview |
| `//db2 preview` | Replay the 11→0 sample countdown |
| `//db2 slots <1-64>` | Maximum visible real effects **and** number of slot guides |
| `//db2 wrap <0-64>` | Slots per row (horizontal) or column (vertical); 0 = no wrap |
| `//db2 display <icons\|text>` | Select icon rendering or classic text |
| `//db2 layout <horizontal\|vertical>` | Set primary fill direction |
| `//db2 iconsize <12-96>` | Icon size in pixels (default 24) |
| `//db2 iconspacing <0-40>` | Gap between slots (default 5) |
| `//db2 grid [1-200]` | Show/set shared Ctrl+drag snap spacing in Windower UI pixels (default 10) |
| `//db2 sort <priority\|id>` | Dia first or numeric buff status ID |
| `//db2 timers` | Toggle estimated live timer text |
| `//db2 timersize <6-24>` | Timer font size; default 8px Arial bold italic |
| `//db2 timerx <-32..32>` | Timer horizontal offset (positive moves right) |
| `//db2 timery <-32..32>` | Timer vertical offset (negative moves up) |
| `//db2 timeroffset <x> <y>` | Both offsets in one command |
| `//db2 targetname [on\|off]` | Toggle or set enemy name (default off) |
| `//db2 background [on\|off\|0-255]` | Transparent by default |
| `//db2 mode` | Switch blacklist/whitelist |
| `//db2 blacklist <add\|remove> <spell>` | Filter spell name |
| `//db2 whitelist <add\|remove> <spell>` | Filter spell name |
| `//db2 interval <seconds>` | Refresh interval (original tracker) |
| `//db2 hide` | Original hide-at-zero toggle (original behavior retained) |
| `//db2 iconpath [path]` | Read or override icon directory |
| `//db2 status` | Show basic settings and asset status |
| `//db2 diagnose` | Show renderer diagnostics |
| `//db2 restart` | Fade then reload the addon |
| `//db2 unload` | Fade then unload the addon |

For example: `//db2 timerx -2`, `//db2 timery -4`, `//db2 slots 16`, `//db2 wrap 8`.

## Technical behavior

- All debuff detection, action/packet handling, overwrite logic, durations, and wear-off tracking are Xathe's original functions and are **unchanged from Test 2.3**. The sample icons/timers never enter `debuffed_mobs`.
- Real timer labels remain estimates from the original tracker. Their behavior is independent of the simulated edit/preview countdowns.
- Compact timers match native icon display: floor hours at 60+ minutes (`1h`), floor minutes at 1–59 minutes (`29m` for 29:56 remaining), integer seconds below 1 minute. Edit-mode dummy timers follow the same display rule (`1m` → `59` → `0`); manual preview remains 11→0. These labels are estimates; no tracking changes.
- The transparent drag hit rectangle spans the configured grid and can intercept mouse input even when invisible.
- Fading disappearance of a real debuff is presentation-only (0.32s). The restart/unload closing fade is a separate transition (0.36s).
- The renderer uses image and text primitives proportional to configured `slots`. For multi-client play, use a modest slot count where practical.
- Long help output scrolls the chat log; topic-specific pages may be explored later after in-game feedback.

## Testing status

Lua parser checks and mocked renderer regression simulations passed for drag saving, mouse jitter under Ctrl snap, viewport changes, icon sizes, and shutdown. Earlier animation/command checks are preserved in `TESTING.md`. **Test 2.4.5 has not yet been verified in FFXI.** See `TESTING.md` included with the addon in the testing archive for procedures and scope.

## Changelog

- **Test 2.4.5 (2026-11-07):** Corrected position persistence after normal and Ctrl+drag. Pending moves can no longer be prevented from saving by same-cell snapped motion; screen-boundary corrections are recorded too. The fallback save timer uses wall time instead of CPU time if LuaSocket is unavailable. Movement is saved before edit/layout changes, restart and unload. No changes to tracking, drag capture, icon layout or animation timing.
- **Test 2.4 (2026-10-13):** BattleStations-style chat help; 12-second countdown preview; editable 1:10 looping dummy timers with transparent samples + retained edit boxes; 16/16 defaults; fade-before-restart/unload; preserved tracking.
- **Test 2.3 (2026-10-10):** Arial bold-italic timer font and adjustable size/X/Y positions, configurable slots and wrapping, added `//db` alias.
- **Test 2.2 (2026-10-10):** Chat-log command feedback, fixed preview texture initialization, individual slot edit guides, updated A authorship.
- **Test 2.1 (2026-10-10):** More reliable startup sample-image loading and preview diagnostics.
- **Test 2 (2026-10-10):** Dia-first sorting, timer repositioning, opening and disappearing fades, drag/edit outlines.
- **Test 1 (2026-10-08):** Initial status-ID icons using installed XivParty art; kept original tracker.


### Test 2.4.1 (2026-10-13) — BattleStations-style color hierarchy

Chat help now gives separate colors to the warm `=`/`----` separators (140), accented `db` prefix and `=>` (200), light command syntax (207), contrasting `Commands`/section heading (167), and neutral descriptions (0). Like BattleStations, help is built from small formatter helpers; unlike it, output is chat-only, never duplicated in the console. No gameplay behavior changed. Git catch-up was committed separately as Test 2.4.


### Test 2.4.2 (2026-10-13) — Native-style timer text

Adjusted **display formatting only**: minutes start at 60 seconds instead of 120 and round down rather than up (`29:56` → `29m`). Hours similarly show completed hours. Under 60 seconds, show whole seconds. The looping edit preview uses the same formatter, while the manual 11-to-0 countdown remains unchanged. Tracking code and icon layout are unchanged.


### Test 2.4.3 (2026-10-13) — Help colors and edit timer polish

- Chat help now uses neutral base color `0`, so the description is genuinely white instead of inheriting the light-colored `207` line. Syntax `207`, prefix and arrow `200`, heading `167`, and borders `140` remain independently colored. Normal help prints **only** to the FFXI chat log.
- Every help command is printed with its full `//db` prefix; replaced `=>` with `->` as an in-game glyph test.
- Edit-mode sample countdown now begins at **61 seconds** (`1:01` internally), showing `1m` for two beats before `59` and continuing to `0`; repeats every 62 seconds. The manual 11→0 preview, real tracking, restart and unload are unchanged.
- Install by extracting the included `Debuffed/` into `Windower/addons/` and run `//lua reload Debuffed`. Existing per-character settings are preserved.

### Test 2.4.4 (2026-10-18) — Ctrl+drag screen-grid snap

- Supports both left/right Ctrl with independent key state; does not hook/intercept mouse input.
- Uses the already draggable backdrop as the sole parent anchor, with a screen-origin 10px grid (`//db grid [1-200]`) independent of icon size.
- Adds UI-viewport bounding and resolution-change recovery; the existing slot, sprite, sample timer and heading layout remains derived from the original pixel dimensions.
- Keeps original tracker, preview/edit timers, help colors, and restart/unload logic unchanged. Source syntax and mock positioning checks passed; actual FFXI input rendering still needs validation.

### Test 2.4.5 (2026-11-07) — Position-save regression fix

- Resolve stuck pending drag saves caused by sub-grid motion; use elapsed wall time, not CPU time, for save settling. Record clamped bounds and flush pending positions before display changes and shutdown. This candidate was checked offline but has not yet been confirmed in live FFXI.

### Debuffed2 Test 1 (2026-11-11) — independent installation and EnemyBar2 name typography

- Copied the complete Test 2.4.5 Save 1 code to a new `Debuffed2/` addon without changing the old `Debuffed/` tree. New addon name, entry file, renderer module, commands `//db2` and `//debuffed2`, and lifecycle commands; user data is separate by addon folder. No automatic settings migration.
- Target names (when enabled) use the main EnemyBar2 font style: Arial 14 bold italic, 2px stroke with alpha 180; draw the plain name without brackets. The classic fallback also omits brackets. The bar's dynamic color/HP% display is not copied.
- The 24px icon size, default 16 slots and 16-per-row, manual placement, Ctrl+drag grid, saves, fades, commands, and original tracker remain otherwise unchanged. Offline tests are not live FFXI verification.
