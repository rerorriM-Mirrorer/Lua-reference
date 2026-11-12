# WORKFLOW.md - TrustTimer

This is a small addon-specific application of the [canonical NPCMirror development workflow](https://github.com/rerorriM-Mirrorer/ffxi-NPCmirror/blob/main/WORKFLOW.md). The repository hosting this addon is `rerorriM-Mirrorer/Windower-Addons`; its existing root `AGENTS.md`, `WORKFLOW.md`, and `TESTING.md` remain authoritative for shared conventions and are preserved in Git history.

## Principles

- Prefer invisible-by-default, FFXI-like UI; default text resembles EnemyBar2, but TrustTimer must not depend on EnemyBar2.
- Keep defaults in Lua; use Windower's `config` library for per-character edits. No names, installation paths, or device assumptions are hardcoded.
- Make party timing client-local: observe a successful roster change rather than assuming a sent invitation was accepted. Never inject packets for this addon.
- Clearly distinguish game-observed, inferred, simulated, and untested behavior. Don't describe the 120-second estimate as server authority.
- Prefer bare toggles for `//tt edit`, `enabled`, and `debug`, while explicit `on`/`off` remains idempotent.
- Maintain `//tt help`, `status`, `restart`, and `unload`; bare or unknown commands print help. Format help with the required fragment colors (140/167/200/207/0) and keep all emitted punctuation ASCII.
- No invisible UI mouse interception; drag only while edit mode is enabled. Support position recovery and modest font size changes.
- Keep debug output quiet by default. Preserve previous behavior and saved settings as the addon evolves.
- Review original requirements, check Lua syntax, simulate event cases, then verify in live Windower/FFXI with controlled joins and leadership changes. Preserve a cumulative `TESTING.md` history.
- Use a working branch for untested changes. Package the Lua source, `README.md`, `WORKFLOW.md`, and `TESTING.md` inside `TrustTimer/`. Report the source branch, commit, and what was or was not tested.

## Future changes

Read the latest GitHub repository root `AGENTS.md`, `WORKFLOW.md`, `TESTING.md` and this document before editing. Document packet observations in `docs/PACKETS.md`, including source/observed fields and confidence. Only promote to a trusted default branch after actual in-game acceptance.
