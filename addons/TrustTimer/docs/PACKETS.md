# TrustTimer Packet Investigation

## 2026-11-12: Outgoing 0x06E (party invite)

- **Scenario:** Local client sends a party invitation.
- **Source:** Windower Lua `packets/data.lua` (0x06E = Party invite) and `packets/fields.lua` (Target, Target Index, Alliance, constant).
- **Observed live:** None in this project. Fields and IDs are documentation-derived, not measured.
- **Current behavior:** On an unblocked, non-injected outgoing 0x06E, use Windower `packets.parse('outgoing', data)` and require `Alliance == 0`. Mark invite intent for up to 180 seconds; do not begin timer until a new human party member appears in `windower.ffxi.get_party()`.
- **Assumption:** Inviter locally bears the Trust summon cooldown. Forum reports differ on exact wait duration; 120 seconds is initial adjustable estimate, not an exact server clock.
- **Confidence:** High for Windower packet identity/field mapping; medium for applying invite events to local client; low-to-medium for exact cooldown/leader-pass effects until FFXI tests.
- **Next capture:** Record client, join/decline, 0x06E field values, time of party roster join, first successful Trust summon, leader-swap timing, and zone state.

## Additional watchpoints

- Incoming 0x0C8 = Party Struct Update; incoming 0x0DD = Party Member Update. This version polls `get_party` once per second instead of decoding these packets. Avoid claiming those updates alone prove a newly joined human.
- Outgoing 0x077 = Change Permissions (includes leadership). This version deliberately does not start a new timer for 0x077; investigate actual acceptance and server effect before attempting early-clear behavior.
