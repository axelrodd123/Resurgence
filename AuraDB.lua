-- Resurgence_AuraDB
-- Curated player-side aura library : procs, buffs, and active forms worth
-- showing on screen. Each entry filters by class (and optionally spec).
-- This data is hand-picked, deliberately small, and tuned for premium
-- visibility rather than completeness.
--
-- Schema :
--   id            unique key, used as save state
--   spellID       the buff to track on the player
--   class         class filter ("MAGE", "DRUID", ...) or "ALL"
--   spec          optional spec name for display
--   role          "dps" | "healer" | "tank" | "any"
--   name          display label
--   tag           short subtitle (e.g. "proc", "active", "form")
--   priority      higher = more visually prominent (1 = featured, 3 = low)

Resurgence_AuraDB = {

    -- DEATH KNIGHT
    { id = "dk_killing_machine",  spellID = 51124,  class = "DEATHKNIGHT", spec = "Frost",   role = "dps",   name = "Killing Machine", tag = "proc",   priority = 1 },
    { id = "dk_rime",             spellID = 59052,  class = "DEATHKNIGHT", spec = "Frost",   role = "dps",   name = "Rime",            tag = "proc",   priority = 1 },
    { id = "dk_dancing_rune",     spellID = 81256,  class = "DEATHKNIGHT", spec = "Blood",   role = "tank",  name = "Dancing Rune Weapon", tag = "active", priority = 1 },

    -- DEMON HUNTER
    { id = "dh_metamorphosis",    spellID = 187827, class = "DEMONHUNTER", spec = "Vengeance", role = "tank", name = "Metamorphosis",   tag = "form",   priority = 1 },
    { id = "dh_furious_gaze",     spellID = 343311, class = "DEMONHUNTER", spec = "Havoc",   role = "dps",   name = "Furious Gaze",    tag = "proc",   priority = 2 },

    -- DRUID
    { id = "druid_clearcasting",  spellID = 16870,  class = "DRUID",                         role = "any",   name = "Clearcasting",    tag = "proc",   priority = 1 },
    { id = "druid_tigers_fury",   spellID = 5217,   class = "DRUID",       spec = "Feral",   role = "dps",   name = "Tiger's Fury",    tag = "active", priority = 1 },
    { id = "druid_berserk",       spellID = 106951, class = "DRUID",       spec = "Feral",   role = "dps",   name = "Berserk",         tag = "active", priority = 2 },
    { id = "druid_sotf",          spellID = 114108, class = "DRUID",       spec = "Restoration", role = "healer", name = "Soul of the Forest", tag = "proc", priority = 2 },

    -- EVOKER
    { id = "evoker_essence_burst", spellID = 369299, class = "EVOKER",                       role = "any",   name = "Essence Burst",   tag = "proc",   priority = 1 },
    { id = "evoker_hover",         spellID = 358267, class = "EVOKER",                       role = "any",   name = "Hover",           tag = "active", priority = 3 },

    -- HUNTER
    { id = "hunter_bestial_wrath", spellID = 19574,  class = "HUNTER",     spec = "BeastMastery", role = "dps", name = "Bestial Wrath", tag = "active", priority = 1 },
    { id = "hunter_trueshot",      spellID = 288613, class = "HUNTER",     spec = "Marksmanship", role = "dps", name = "Trueshot",      tag = "active", priority = 1 },
    { id = "hunter_beast_cleave",  spellID = 115939, class = "HUNTER",     spec = "BeastMastery", role = "dps", name = "Beast Cleave",  tag = "proc",   priority = 2 },

    -- MAGE
    { id = "mage_hot_streak",      spellID = 48108,  class = "MAGE",       spec = "Fire",    role = "dps",   name = "Hot Streak !",    tag = "proc",   priority = 1 },
    { id = "mage_brain_freeze",    spellID = 190446, class = "MAGE",       spec = "Frost",   role = "dps",   name = "Brain Freeze",    tag = "proc",   priority = 1 },
    { id = "mage_clearcasting",    spellID = 263725, class = "MAGE",       spec = "Arcane",  role = "dps",   name = "Clearcasting",    tag = "proc",   priority = 1 },
    { id = "mage_combustion",      spellID = 190319, class = "MAGE",       spec = "Fire",    role = "dps",   name = "Combustion",      tag = "active", priority = 2 },
    { id = "mage_icy_veins",       spellID = 12472,  class = "MAGE",       spec = "Frost",   role = "dps",   name = "Icy Veins",       tag = "active", priority = 2 },

    -- MONK
    { id = "monk_blackout_kick",   spellID = 116768, class = "MONK",       spec = "Windwalker", role = "dps", name = "Blackout Kick !", tag = "proc",  priority = 1 },
    { id = "monk_invoke_yulon",    spellID = 322118, class = "MONK",       spec = "Mistweaver", role = "healer", name = "Invoke Yu'lon", tag = "active", priority = 2 },
    { id = "monk_renewing_mist",   spellID = 119611, class = "MONK",       spec = "Mistweaver", role = "healer", name = "Renewing Mist", tag = "hot",   priority = 3 },

    -- PALADIN
    { id = "pala_avenging_wrath",  spellID = 31884,  class = "PALADIN",                      role = "any",   name = "Avenging Wrath",  tag = "active", priority = 1 },
    { id = "pala_crusade",         spellID = 231895, class = "PALADIN",    spec = "Retribution", role = "dps", name = "Crusade",       tag = "active", priority = 1 },
    { id = "pala_divine_purpose",  spellID = 223819, class = "PALADIN",                      role = "any",   name = "Divine Purpose",  tag = "proc",   priority = 1 },
    { id = "pala_infusion_light",  spellID = 54149,  class = "PALADIN",    spec = "Holy",    role = "healer", name = "Infusion of Light", tag = "proc", priority = 1 },

    -- PRIEST
    { id = "priest_surge_of_light", spellID = 114255, class = "PRIEST",                      role = "healer", name = "Surge of Light", tag = "proc",   priority = 1 },
    { id = "priest_voidform",      spellID = 194249, class = "PRIEST",     spec = "Shadow",  role = "dps",   name = "Voidform",        tag = "active", priority = 1 },
    { id = "priest_apotheosis",    spellID = 200183, class = "PRIEST",     spec = "Holy",    role = "healer", name = "Apotheosis",     tag = "active", priority = 2 },

    -- ROGUE
    { id = "rogue_shadow_dance",   spellID = 185313, class = "ROGUE",      spec = "Subtlety", role = "dps",  name = "Shadow Dance",    tag = "active", priority = 1 },
    { id = "rogue_adrenaline",     spellID = 13750,  class = "ROGUE",      spec = "Outlaw",  role = "dps",   name = "Adrenaline Rush", tag = "active", priority = 1 },
    { id = "rogue_envenom",        spellID = 32645,  class = "ROGUE",      spec = "Assassination", role = "dps", name = "Envenom",     tag = "active", priority = 2 },

    -- SHAMAN
    { id = "shaman_lava_surge",    spellID = 77762,  class = "SHAMAN",     spec = "Elemental", role = "dps", name = "Lava Surge",     tag = "proc",   priority = 1 },
    { id = "shaman_maelstrom",     spellID = 344179, class = "SHAMAN",     spec = "Enhancement", role = "dps", name = "Maelstrom Weapon", tag = "stack", priority = 1 },
    { id = "shaman_unleash_life",  spellID = 73685,  class = "SHAMAN",     spec = "Restoration", role = "healer", name = "Unleash Life", tag = "active", priority = 2 },

    -- WARLOCK
    { id = "lock_demonic_core",    spellID = 264173, class = "WARLOCK",    spec = "Demonology", role = "dps", name = "Demonic Core",  tag = "proc",   priority = 1 },
    { id = "lock_backdraft",       spellID = 117828, class = "WARLOCK",    spec = "Destruction", role = "dps", name = "Backdraft",    tag = "proc",   priority = 1 },
    { id = "lock_nightfall",       spellID = 264571, class = "WARLOCK",    spec = "Affliction", role = "dps", name = "Nightfall",     tag = "proc",   priority = 1 },

    -- WARRIOR
    { id = "warrior_sudden_death", spellID = 52437,  class = "WARRIOR",    spec = "Arms",    role = "dps",   name = "Sudden Death",    tag = "proc",   priority = 1 },
    { id = "warrior_enrage",       spellID = 184362, class = "WARRIOR",    spec = "Fury",    role = "dps",   name = "Enrage",          tag = "proc",   priority = 1 },
    { id = "warrior_recklessness", spellID = 1719,   class = "WARRIOR",    spec = "Fury",    role = "dps",   name = "Recklessness",    tag = "active", priority = 2 },
    { id = "warrior_shield_block", spellID = 132404, class = "WARRIOR",    spec = "Protection", role = "tank", name = "Shield Block",  tag = "active", priority = 1 },
}
