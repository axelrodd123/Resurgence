# Changelog

## 0.5.5-alpha (2026-05-09)
- Fix : the default `ChatFrame1` no longer overlaps the Resurgence mini chat. It is now faded to alpha 0 in Clean Mode (still receives messages so our hooked `AddMessage` mirrors them), instead of being left visible.
- Fix : the gargoyle / dragon ornament on the right side of the action bar (with the page number and up / down arrows) was rendering through the previous fade pass. Two new layers catch it : a nested-children pass (`MainMenuBar.EndCaps`, `MainMenuBar.BorderArt`, `MainMenuBar.ActionBarPageNumber`, etc., which are not exposed as Lua globals in 12.0.x retail) and a brute-force walk of every region and child of `MainMenuBar` that fades anything not already handled.
- The Resurgence mini chat is now the sole visible message log when Clean Mode is on. Slash commands typed in its edit box still route through `SlashCmdList`.

## 0.5.4-alpha (2026-05-09)
- Fix : action bar end-cap ornaments (the gargoyle / dragon decorations at the bottom of the screen) and the page number / nav arrows are now part of the fade list and disappear with Clean Mode.
- Fix : cursor halo is now visible by default with a subtle cyan ring, vibrant red / green / gold tint on hover. Switched to a more reliable Blizzard texture (`TempleofKotmogu_ball_cyan` with ADD blend) for guaranteed rendering.
- New : **Resurgence mini chat**. Bottom-left message log that mirrors the default chat stream and exposes its own edit box for slash commands. Functional even when Blizzard chat is hidden. Toggle in Settings, default on.
- The default Blizzard `ChatFrame1` and its edit box are no longer hidden by Clean Mode (player still needs to type), only the docked extra chat tabs and channel buttons are.

## 0.5.3-alpha (2026-05-09)
- Clean Mode now also fades every individual action button (`ActionButton1-12`, `MultiBarBottomLeftButton1-12`, `MultiBarLeftButton1-12`, etc., across 13 button groups, 130+ buttons total). The previous version only faded the parent bars, leaving the buttons drawn on top.
- Added `TemporaryEnchantFrame` and edit-mode wrappers to the fade list.
- New : **Cursor Halo**. A colored ring follows your cursor and tints based on what's underneath : red on hostile, green on allies, gold on quest objectives, yellow on neutral. Native cursor stays for precision. Toggle in Settings, on by default.

## 0.5.2-alpha (2026-05-09)
- Clean Mode is now full-nuke : the chat frames, the minimap entirely, the world map button, all bag slot icons, every Blizzard popup, every alert frame, and every remaining default UI element are now hidden. Only Resurgence UI elements remain on screen.
- Auto-enable on upgrade : Clean Mode is forced ON one time for users coming from earlier versions. Toggle off in Settings any time.
- Use this build to evaluate Resurgence's progress without Blizzard's UI biasing the visual.

## 0.5.1-alpha (2026-05-09)
- Clean Mode is now **aggressive** : hides 35+ Blizzard frames including unit frames, all action bars (faded to alpha 0, keybinds still cast), minimap entirely, boss frames, raid frames, cast bar, micro menu, bag bar, vehicle seat indicator, alert popups. Two-tier strategy : hard `:Hide()` for non-secure frames, `SetAlpha(0)` + `EnableMouse(false)` for secure action bars to avoid combat taint.
- Toggle off any time to restore everything to default.

## 0.5.0-alpha (2026-05-09)
- New : **Resurgence XP Bar** at the top of the screen. Custom gold gradient progress bar with the level, current XP / max, percentage, and a live time-to-ding estimate based on the XP rate over the last 30 minutes.
- New : **Clean Mode**. One toggle hides Blizzard's quest tracker, default buffs and debuffs, talking head, zone enter banners, micro menu, default XP bar at the bottom, minimap zone label and clutter. Action bars and unit frames stay so you can still play. Toggle off anytime to bring everything back.
- New : **Chat skin**. Re-styles the default chat frames with the Resurgence dark navy and gold trim. Functionality untouched, only visuals.
- Settings tab gets a new "Resurgence UI replacement" section with checkboxes for the three above.
- XP bar is draggable with `Ctrl + drag` to avoid accidental displacement during normal play.

## 0.4.2-alpha (2026-05-09)
- Fix : `attempt to index field 'preferences' (a nil value)` crash on the wizard's step 2 when upgrading from a pre-v0.4.0 SavedVariables file. Defaults for `preferences`, `aurasEnabled / Disabled`, `aurasHudPos`, `buffsHudPos`, `setupDone`, `aurasHudLocked` now applied in `ADDON_LOADED` (after SavedVariables restore) plus defensive fallbacks in the wizard step builders.

## 0.4.1-alpha (2026-05-09)
- Fix : the onboarding wizard opened with an empty black content area on first display. `renderStep()` was defined but never called at build time, so the first step only appeared after clicking Next.

## 0.4.0-alpha (2026-05-09)
- New : 3-step onboarding wizard at first launch (welcome / role + content / modules) that personalizes the addon to the player.
- New : Aura Engine. 39 hand-picked procs and active buffs across all 13 classes. Auto-filtered by player class. Floating panel with cooldown sweep and Blizzard-native countdown numbers. Position persisted, lockable.
- New : Auras tab in the main window. Per-aura toggle checkboxes, refresh button, lock / unlock and reset position controls.
- New : `/res setup` re-runs the wizard. `/res auras` opens the Auras tab directly.
- The aura HUD only loads when the Personal Auras module is enabled in the wizard or Settings, keeping the addon footprint zero for users who only want the World Buffs HUD.

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
