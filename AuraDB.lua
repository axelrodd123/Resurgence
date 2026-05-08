-- Resurgence_AuraDB : curated list of player procs / buffs / cooldowns
-- worth tracking visually. Each entry can be enabled/disabled per-user.
--
-- Schema :
--   id        unique string key, used as save-state key
--   spellID   the spell whose buff (or cooldown) we track
--   class     class filter (only loaded for matching class), or nil for all
--   spec      optional spec filter (display only, not enforced for now)
--   name      display name
--   type      "buff"        : show icon while spell is active on player
--             "cd_ready"    : show icon while spell cooldown is up
--   visual    "glow"        : pulsing colored border when active
--             "flash"       : single quick scale-up when first triggered
--             "solid"       : just shown, no animation
--   sound     optional kit sound or path to play on activation

Resurgence_AuraDB = {

    -- =================================================================
    -- MAGE
    -- =================================================================
    { id = "mage_hot_streak",   spellID = 48108,  class = "MAGE", spec = "Fire",
      name = "Hot Streak",      type = "buff",    visual = "glow" },
    { id = "mage_combustion",   spellID = 190319, class = "MAGE", spec = "Fire",
      name = "Combustion",      type = "buff",    visual = "glow" },
    { id = "mage_brain_freeze", spellID = 190446, class = "MAGE", spec = "Frost",
      name = "Brain Freeze",    type = "buff",    visual = "glow" },
    { id = "mage_icy_veins",    spellID = 12472,  class = "MAGE", spec = "Frost",
      name = "Icy Veins",       type = "buff",    visual = "glow" },
    { id = "mage_arcane_surge", spellID = 365350, class = "MAGE", spec = "Arcane",
      name = "Arcane Surge",    type = "buff",    visual = "glow" },

    -- =================================================================
    -- DRUID
    -- =================================================================
    { id = "druid_clearcasting",  spellID = 16870,  class = "DRUID",
      name = "Clearcasting",      type = "buff",    visual = "glow" },
    { id = "druid_tigers_fury",   spellID = 5217,   class = "DRUID", spec = "Feral",
      name = "Tiger's Fury",      type = "buff",    visual = "glow" },
    { id = "druid_berserk",       spellID = 106951, class = "DRUID", spec = "Feral",
      name = "Berserk",           type = "buff",    visual = "glow" },

    -- =================================================================
    -- PALADIN
    -- =================================================================
    { id = "pala_avenging_wrath", spellID = 31884,  class = "PALADIN",
      name = "Avenging Wrath",    type = "buff",    visual = "glow" },
    { id = "pala_crusade",        spellID = 231895, class = "PALADIN", spec = "Retribution",
      name = "Crusade",           type = "buff",    visual = "glow" },
    { id = "pala_divine_purpose", spellID = 223819, class = "PALADIN",
      name = "Divine Purpose",    type = "buff",    visual = "glow" },

    -- =================================================================
    -- ROGUE
    -- =================================================================
    { id = "rogue_shadow_dance",   spellID = 185313, class = "ROGUE", spec = "Subtlety",
      name = "Shadow Dance",       type = "buff",    visual = "glow" },
    { id = "rogue_adrenaline_rush", spellID = 13750, class = "ROGUE", spec = "Outlaw",
      name = "Adrenaline Rush",    type = "buff",    visual = "glow" },

    -- =================================================================
    -- HUNTER
    -- =================================================================
    { id = "hunter_bestial_wrath", spellID = 19574,  class = "HUNTER", spec = "BeastMastery",
      name = "Bestial Wrath",      type = "buff",    visual = "glow" },
    { id = "hunter_trueshot",      spellID = 288613, class = "HUNTER", spec = "Marksmanship",
      name = "Trueshot",           type = "buff",    visual = "glow" },

    -- =================================================================
    -- WARLOCK
    -- =================================================================
    { id = "lock_demonic_core",   spellID = 264173, class = "WARLOCK", spec = "Demonology",
      name = "Demonic Core",      type = "buff",    visual = "glow" },
    { id = "lock_backdraft",      spellID = 117828, class = "WARLOCK", spec = "Destruction",
      name = "Backdraft",         type = "buff",    visual = "glow" },

    -- =================================================================
    -- DEATHKNIGHT
    -- =================================================================
    { id = "dk_killing_machine",  spellID = 51124,  class = "DEATHKNIGHT", spec = "Frost",
      name = "Killing Machine",   type = "buff",    visual = "glow" },
    { id = "dk_rime",             spellID = 59052,  class = "DEATHKNIGHT", spec = "Frost",
      name = "Rime",              type = "buff",    visual = "glow" },

    -- =================================================================
    -- SHAMAN
    -- =================================================================
    { id = "shaman_lava_surge",       spellID = 77762,  class = "SHAMAN", spec = "Elemental",
      name = "Lava Surge",            type = "buff",    visual = "glow" },
    { id = "shaman_maelstrom_weapon", spellID = 344179, class = "SHAMAN", spec = "Enhancement",
      name = "Maelstrom Weapon",      type = "buff",    visual = "glow" },

    -- =================================================================
    -- PRIEST
    -- =================================================================
    { id = "priest_surge_of_light", spellID = 114255, class = "PRIEST",
      name = "Surge of Light",      type = "buff",    visual = "glow" },

    -- =================================================================
    -- MONK
    -- =================================================================
    { id = "monk_blackout_kick",    spellID = 116768, class = "MONK", spec = "Windwalker",
      name = "Blackout Kick!",      type = "buff",    visual = "glow" },

    -- =================================================================
    -- DEMONHUNTER
    -- =================================================================
    { id = "dh_metamorphosis_demonic", spellID = 162264, class = "DEMONHUNTER",
      name = "Metamorphosis",          type = "buff",    visual = "glow" },

    -- =================================================================
    -- EVOKER
    -- =================================================================
    { id = "evoker_essence_burst", spellID = 369299, class = "EVOKER",
      name = "Essence Burst",      type = "buff",    visual = "glow" },

    -- =================================================================
    -- WARRIOR
    -- =================================================================
    { id = "warrior_sudden_death",  spellID = 52437,  class = "WARRIOR", spec = "Arms",
      name = "Sudden Death",        type = "buff",    visual = "glow" },
    { id = "warrior_recklessness",  spellID = 1719,   class = "WARRIOR", spec = "Fury",
      name = "Recklessness",        type = "buff",    visual = "glow" },
}
