# TrustTimer

Small, independent Windower 4 addon showing an estimated Trust summoning cooldown after **your client sends a party invitation** and a real player joins. No automation, injections, audio, permanent window, or dependency on your Trust addon or EnemyBar2.

The HUD resembles EnemyBar2's target-name typography: bold italic Arial, 2px dark stroke, no background. It reads `Trusts Available in 1:42`, then briefly shows green `Trusts Ready!` before disappearing.

## Install

Copy the **TrustTimer** directory into `Windower4/addons/` (do not merge with another addon). Load with `//lua load trusttimer`. To auto-load, add `lua load trusttimer` to your Windower startup script.

Everything is client-local. Persistent position/style settings are created by Windower's `config` library in the addon's normal `data` directory. Nothing in this ZIP should overwrite an existing settings file.

## Commands

| Command | Action |
| --- | --- |
| `//tt help` | Print chat-only help |
| `//tt status` | Current cooldown estimate, pending invite, and HUD settings |
| `//tt test` | Simulate a 15-second countdown and ready animation |
| `//tt test 120` | Simulate a longer countdown |
| `//tt edit` | Toggle a movable placement preview; drag the text |
| `//tt edit on` | Explicitly enable placement mode (no change if already on) |
| `//tt edit off` | Explicitly disable placement mode and mouse interception |
| `//tt pos 800 160` | Set position directly |
| `//tt resetpos` | Recover off-screen position |
| `//tt size 16` | Set text size (8-40) |
| `//tt duration 120` | Change estimate (30-600 seconds) |
| `//tt enabled [on\|off]` | Toggle automatic HUD display, or explicitly set it |
| `//tt debug [on\|off]` | Toggle invitation/party diagnostics, or explicitly set it |
| `//tt clear` | Clear a countdown or demo |
| `//tt restart` | Reload this addon |
| `//tt unload` | Unload this addon |

## What starts the timer?

Windower observes your **outgoing party invitation (0x06E)**. Only when a **human PC actually appears** in your local party roster within 180 seconds does the addon start the configurable 120-second estimate. Attempts that were declined, NPC Trust joins, alliance invitations, login, and ordinary zoning do not create a timer. Zoning does not reset an existing timer.

Leader changes do **not** independently start or reset a countdown. Reports from retail players suggest changing leaders can sometimes bypass the restriction. An exact server-side Trust lockout status/remaining-time value has not been established. The 120 seconds is an **estimate**, not a server-confirmed unlock time. Try summoning when it says ready; tell us if it consistently ends early or late.

The first test version deliberately does not claim to detect successful Trust spell casts or arbitrary party restriction messages. Invitations sent before the addon loads, or joins detected on a different client from the inviter, may not start the display.

## Current development status

**v0.1.0-test2 (November 12, 2026):** Lua syntax checked with LuaTeX's embedded Lua; 19 simulated Windower event/command scenarios passed. **Not yet tested in Windower 4 or live FFXI.** See `TESTING.md` for the live acceptance checklist and `docs/PACKETS.md` for detection assumptions.

## Changelog

- **2026-11-12, v0.1.0-test2:** `//tt edit`, `//tt enabled`, and `//tt debug` toggle with no argument; explicit `on`/`off` remains idempotent. Updated help and usage. No cooldown-detection changes.

- **2026-11-12, v0.1.0-test1:** Initial standalone HUD; outgoing-invite + confirmed human-join detection, configurable countdown, ready fade, drag/position persistence, size control, test preview, debug/status/help and lifecycle commands.
