# Resurgence

[![License: MIT](https://img.shields.io/badge/license-MIT-yellow.svg)](LICENSE)
[![WoW: Retail 12.0](https://img.shields.io/badge/WoW-Retail%2012.0-orange.svg)]()
[![Status: alpha](https://img.shields.io/badge/status-alpha-red.svg)]()

> WeakAuras-style proc and cooldown tracker, rebuilt from scratch for the 12.0.x Midnight era. The addons that work.

While WeakAuras, Plater, OmniCD and Details have all been broken or restricted by Blizzard's tighter security in Midnight, Resurgence is a focused, lightweight rewrite that uses only the new safe APIs. No `COMBAT_LOG_EVENT_UNFILTERED`, no protected hooks, no taint.

<p align="center">
  <img src="icon.png" alt="Resurgence" width="320"/>
</p>

## Features (v0.1.0 alpha)

- 28 curated procs / buffs across 13 classes (Mage Hot Streak, Druid Clearcasting, Rogue Shadow Dance, Hunter Bestial Wrath, etc.)
- Auto-filtered by your class on login and respec
- Glow border + cooldown sweep + remaining time when an aura activates
- Draggable panel with persisted position, scale, and lock state
- Per-aura toggle so you can hide tracks you don't care about

## Roadmap

- v0.2 : merge PartyCD as a Party Cooldowns module
- v0.3 : lightweight DPS / healing meter (Details replacement, no UNFILTERED)
- v0.4 : Vault and lockout tracker for the login screen
- v1.0 : custom trigger editor for power users

## Commands

| Command | Description |
|---|---|
| `/res` or `/resurgence` | Show command help |
| `/res unlock` / `/res lock` | Toggle drag mode |
| `/res test` | Preview all icons for 8 seconds |
| `/res list` | List tracked auras for your class |
| `/res off <id>` / `/res on <id>` | Disable / re-enable a specific aura |
| `/res scale <n>` | Resize the panel (0.5 to 2.5) |
| `/res reset` | Restore defaults |

## License

MIT.

## Author

**AxelRodd** · still chasing the perfect corner hit
