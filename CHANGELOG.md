# Changelog

## 0.1.0-alpha
- Initial alpha : 28 curated procs / buffs across 13 classes
- Auto-filters by player class on login and spec change
- Glow border + cooldown sweep when an aura activates
- Draggable panel with persisted position, scale, lock state
- Slash commands : `/res` (help), `lock`, `unlock`, `test`, `list`, `on/off <id>`, `scale`, `reset`
- Built without `COMBAT_LOG_EVENT_UNFILTERED` (taint trigger on retail 12.0.x).
  Uses `UNIT_AURA` per-unit and standard player events instead.
