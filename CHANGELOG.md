# Changelog

## 0.3.0-alpha
- New module : **World Buffs**. A floating HUD with every currently-active world event, live countdowns ticking by the second, location label, and a per-event Track button.
- Tracking integrates with the in-game native waypoint system : click Track and follow the 3D arrow at the top of your screen (it tilts up or down based on the target's altitude) plus the line drawn on the world map. Zero custom navigation code, all native Blizzard.
- New tab `World Buffs` in the main menu, with the full event list and HUD toggle buttons.
- New slash : `/res buffs` (toggle), `/res buffs show`, `/res buffs hide`.
- HUD is movable, lockable, position persisted across sessions, can be shown automatically on next login.
- 7 events shipped : Battlegrounds Bonus, Trial of Style, Vyranoth's Echo (world boss), Winds of Wisdom, Pet Battle Bonus, Darkmoon Faire, Mythic Dungeon Event.

## 0.2.3-alpha
- New logo : transparent-background circular asset, no mask texture required at runtime, sharper edges and smoother rim glow.
- Removed the runtime alpha mask code now that the source is already a perfect circle.

## 0.2.2-alpha
- New : the launcher button is now a true circle (alpha mask applied to the icon and shadow)
- New : drag the launcher with a normal click-and-drag, no modifier key required
- Brand : copy revisited across the welcome screen, About tab, roadmap and tooltips. Resurgence stands on its own merits.

## 0.2.1-alpha
- Fix : `attempt to index local 'p' (a nil value)` crash on first load when the saved variables file pre-dates the v0.2.0 schema. Defaults now applied in `ADDON_LOADED` (after SavedVariables are restored) instead of at file scope, plus defensive fallbacks in the launcher and main-window builders.
- Updated logo : new render with tighter framing, more refined gold bezel, brighter cyan rim glow.

## 0.2.0-alpha
- Pivot to UI shell milestone : the visual foundation ships first, the engine follows in v0.3.0
- New : on-screen circular logo button (draggable with shift, click to open menu, right click to hide for the session)
- New : main window with sidebar navigation, 5 tabs (Welcome, Roadmap, About, Settings, Support)
- New : first-launch welcome popup with onboarding (replayable from Settings)
- New : full roadmap of upcoming modules : Aura Engine, Party CDs, Combat Info, Vault & Lockout, Custom Editor
- New : Settings tab with launcher controls, Support tab with GitHub / CurseForge / Issues links
- Removed : aura tracking from v0.1.0 (returning in v0.3.0 with the engine)
- License : switched to proprietary, all rights reserved (source visible on GitHub for transparency)

## 0.1.0-alpha
- Initial alpha : 28 curated procs / buffs across 13 classes
- Auto-filters by player class on login and spec change
- Glow border + cooldown sweep when an aura activates
- Draggable panel with persisted position, scale, lock state
- Slash commands : `/res` (help), `lock`, `unlock`, `test`, `list`, `on/off <id>`, `scale`, `reset`
- Built without `COMBAT_LOG_EVENT_UNFILTERED` (taint trigger on retail 12.0.x).
  Uses `UNIT_AURA` per-unit and standard player events instead.
