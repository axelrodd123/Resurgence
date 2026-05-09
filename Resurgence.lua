local ADDON_NAME = ...

local function meta(k)
    if C_AddOns and C_AddOns.GetAddOnMetadata then
        return C_AddOns.GetAddOnMetadata(ADDON_NAME, k)
    end
    return GetAddOnMetadata and GetAddOnMetadata(ADDON_NAME, k) or nil
end
local ADDON_VERSION = meta("Version") or "?"

----------------------------------------------------------------------
-- Brand palette
----------------------------------------------------------------------
local C = {
    bg          = { 0.04, 0.05, 0.10, 1.00 },
    bgDeep      = { 0.02, 0.03, 0.06, 1.00 },
    panel       = { 0.08, 0.10, 0.18, 0.96 },
    panelHover  = { 0.13, 0.16, 0.26, 1.00 },
    gold        = { 1.00, 0.84, 0.27, 1.00 },
    goldSoft    = { 0.85, 0.70, 0.22, 1.00 },
    goldDim     = { 0.55, 0.45, 0.15, 1.00 },
    cyan        = { 0.37, 0.82, 1.00, 1.00 },
    cyanDim     = { 0.20, 0.50, 0.75, 1.00 },
    text        = { 0.96, 0.96, 0.96, 1.00 },
    textMuted   = { 0.60, 0.65, 0.75, 1.00 },
    textFaint   = { 0.40, 0.45, 0.55, 1.00 },
    bronze      = { 0.55, 0.40, 0.20, 1.00 },
    accentGreen = { 0.40, 1.00, 0.50, 1.00 },
}

local LOGO_PATH = "Interface\\AddOns\\" .. ADDON_NAME .. "\\icon"

local function rgb(c) return c[1], c[2], c[3], c[4] or 1 end
local function setBG(tex, c) tex:SetColorTexture(rgb(c)) end

----------------------------------------------------------------------
-- DB defaults
----------------------------------------------------------------------
ResurgenceDB = ResurgenceDB or {}
ResurgenceDB.welcomed       = ResurgenceDB.welcomed or false
ResurgenceDB.launcherPos    = ResurgenceDB.launcherPos or { "RIGHT", -8, 80 }
ResurgenceDB.launcherHidden = ResurgenceDB.launcherHidden or false
ResurgenceDB.windowPos      = ResurgenceDB.windowPos or { "CENTER", 0, 40 }
ResurgenceDB.lastTab        = ResurgenceDB.lastTab or "welcome"
ResurgenceDB.buffsHudPos    = ResurgenceDB.buffsHudPos or { "TOPRIGHT", -260, -260 }
ResurgenceDB.buffsHudOpen   = ResurgenceDB.buffsHudOpen or false
ResurgenceDB.buffsHudLocked = ResurgenceDB.buffsHudLocked or false

----------------------------------------------------------------------
-- Tab definitions
----------------------------------------------------------------------
local TABS = {
    { id = "welcome",  label = "Welcome" },
    { id = "buffs",    label = "World Buffs" },
    { id = "roadmap",  label = "Roadmap" },
    { id = "about",    label = "About" },
    { id = "settings", label = "Settings" },
    { id = "support",  label = "Support" },
}

----------------------------------------------------------------------
-- Roadmap data
----------------------------------------------------------------------
local ROADMAP = {
    {
        ver = "0.2.x", status = "shipped",
        title = "UI Shell",
        body = "The visual foundation : welcome screen, on-screen launcher, roadmap and info tabs. Shipped.",
        items = {
            "Welcome window with onboarding flow",
            "Draggable circular launcher button",
            "Roadmap, About, Support, Settings tabs",
            "Persistent positions and preferences",
        },
    },
    {
        ver = "0.3.0-alpha", status = "current",
        title = "World Buffs",
        body = "Live countdowns for every active world event in one floating window. One click takes you there with the in-game native 3D arrow that tilts up or down depending on the target's altitude.",
        items = {
            "Floating HUD with active events and live countdowns",
            "Per-event Track button : sets a Blizzard waypoint, line on the map, 3D arrow that adapts in real time",
            "Toggle from launcher menu, slash command, or in-app tab",
            "Movable, lockable, position persisted",
        },
    },
    {
        ver = "0.4.0", status = "planned",
        title = "Aura Engine",
        body = "Track the procs and buffs that actually matter to your spec, with the visual polish your gameplay deserves.",
        items = {
            "Curated proc and buff library, hand-picked per spec",
            "Glow border, cooldown sweep, countdown numbers",
            "Per-aura toggle from Settings",
            "Drag-and-drop layout, position persisted",
        },
    },
    {
        ver = "0.5.0", status = "planned",
        title = "Group Awareness",
        body = "Real-time visibility on the cooldowns of every player in your group, in one unified panel that respects your class roles.",
        items = {
            "Defensive, interrupt, utility, combat res tracking",
            "Color-coded by category, sized for raid view",
            "Real-time updates via the safe player-cast API",
        },
    },
    {
        ver = "0.6.0", status = "planned",
        title = "Combat Insights",
        body = "Live damage, healing, threat, and top-spell metrics that read at a glance. Built for the encounter, not the spreadsheet.",
        items = {
            "Per-fight DPS / HPS / damage taken",
            "Top spell breakdown",
            "Multi-window support",
        },
    },
    {
        ver = "0.7.0", status = "future",
        title = "Vault & Lockout Tracker",
        body = "Cross-character vault progress, weekly lockouts, currency caps. Visible without alt-tabbing.",
        items = {
            "Great Vault status across alts",
            "Raid and dungeon lockouts",
            "Currency caps per alt",
        },
    },
    {
        ver = "1.0.0", status = "future",
        title = "Custom Trigger Editor",
        body = "For power users who want to define their own triggers. A focused, opinionated editor without the legacy bloat.",
        items = {
            "Visual trigger builder",
            "Import / export trigger strings",
            "Community trigger library",
        },
    },
}

local STATUS_COLORS = {
    shipped = C.accentGreen,
    current = C.cyan,
    planned = C.gold,
    future  = C.textFaint,
}
local STATUS_LABELS = {
    shipped = "DONE",
    current = "NOW",
    planned = "NEXT",
    future  = "LATER",
}

----------------------------------------------------------------------
-- World Buffs : curated active events with countdowns and waypoints
----------------------------------------------------------------------
-- endsAt is a relative offset from the moment the addon loads, in seconds.
-- In a real Blizzard-calendar-driven build (v0.3.1+) these timestamps
-- come live from the in-game calendar API. For this alpha they are
-- realistic placeholders so the live countdown ticks immediately.
local function inDays(d) return d * 86400 end

local WORLD_BUFFS = {
    {
        id = "bg_bonus",
        name = "Battlegrounds Bonus Event",
        desc = "+50% Honor from BG objectives.",
        icon = 132355,
        endsAt = inDays(3) + 8 * 3600,
        location = "Active globally",
    },
    {
        id = "trial_of_style",
        name = "Trial of Style",
        desc = "Show off your transmog for a week.",
        icon = 1392952,
        endsAt = inDays(5),
        location = "Stormwind, Trial entrance",
        waypoint = { mapID = 84, x = 0.4824, y = 0.6622 },
    },
    {
        id = "world_boss_1",
        name = "Vyranoth's Echo",
        desc = "World boss, drops 645 ilvl loot.",
        icon = 134155,
        endsAt = inDays(2) + 12 * 3600,
        location = "Emerald Dream",
        waypoint = { mapID = 2200, x = 0.50, y = 0.50 },
    },
    {
        id = "winds_of_wisdom",
        name = "Winds of Wisdom",
        desc = "+50% experience gain on character leveling.",
        icon = 1764109,
        endsAt = inDays(20),
        location = "Active globally",
    },
    {
        id = "pet_battle_bonus",
        name = "Pet Battle Bonus",
        desc = "+200% Pet Battle XP from wins.",
        icon = 132440,
        endsAt = inDays(6) + 4 * 3600,
        location = "Active globally",
    },
    {
        id = "darkmoon",
        name = "Darkmoon Faire",
        desc = "Once-monthly faire, profession quests, mounts, pets.",
        icon = 134419,
        endsAt = inDays(4),
        location = "Mulgore portal entrance",
        waypoint = { mapID = 7, x = 0.45, y = 0.66 },
    },
    {
        id = "mythic_dungeon",
        name = "Mythic Dungeon Event",
        desc = "Bonus rewards from completed Mythic dungeons.",
        icon = 1444938,
        endsAt = inDays(11) + 6 * 3600,
        location = "Active globally",
    },
}

-- Resolve absolute end times relative to the moment the addon loads.
local LOAD_TIME = GetTime()
for _, b in ipairs(WORLD_BUFFS) do
    b.endsAtAbsolute = LOAD_TIME + b.endsAt
end

local function formatCountdown(seconds)
    if seconds <= 0 then return "ended" end
    local d = math.floor(seconds / 86400)
    local h = math.floor((seconds % 86400) / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = math.floor(seconds % 60)
    if d > 0 then return string.format("%dd %dh %dm", d, h, m) end
    if h > 0 then return string.format("%dh %dm %ds", h, m, s) end
    if m > 0 then return string.format("%dm %ds", m, s) end
    return string.format("%ds", s)
end

local function trackWaypoint(buff)
    if not buff.waypoint then
        print(string.format("|cffffd700[Resurgence]|r %s is active globally — no specific location to track.", buff.name))
        return
    end
    if not (C_Map and C_Map.SetUserWaypoint and UiMapPoint) then
        print("|cffff8888[Resurgence]|r waypoint API unavailable on this client.")
        return
    end
    local w = buff.waypoint
    local point = UiMapPoint.CreateFromCoordinates(w.mapID, w.x, w.y, w.z or 0)
    C_Map.SetUserWaypoint(point)
    if C_SuperTrack and C_SuperTrack.SetSuperTrackedUserWaypoint then
        C_SuperTrack.SetSuperTrackedUserWaypoint(true)
    end
    print(string.format("|cffffd700[Resurgence]|r tracking : %s — follow the in-game arrow.", buff.name))
end

----------------------------------------------------------------------
-- State
----------------------------------------------------------------------
local state = {
    launcher = nil,
    window = nil,
    welcomePopup = nil,
    buffsHUD = nil,
    buffsHUDRows = {},
    tabButtons = {},
    tabPanels = {},
    activeTab = nil,
}

----------------------------------------------------------------------
-- UI primitives
----------------------------------------------------------------------
local function makePanel(parent, color, alphaOverride)
    local f = CreateFrame("Frame", nil, parent)
    f.bg = f:CreateTexture(nil, "BACKGROUND")
    f.bg:SetAllPoints()
    local r, g, b, a = rgb(color)
    f.bg:SetColorTexture(r, g, b, alphaOverride or a)
    return f
end

local function makeBorderLine(parent, color, thickness, dir, padding)
    local t = parent:CreateTexture(nil, "OVERLAY")
    setBG(t, color)
    padding = padding or 0
    if dir == "TOP" then
        t:SetHeight(thickness)
        t:SetPoint("TOPLEFT", padding, 0)
        t:SetPoint("TOPRIGHT", -padding, 0)
    elseif dir == "BOTTOM" then
        t:SetHeight(thickness)
        t:SetPoint("BOTTOMLEFT", padding, 0)
        t:SetPoint("BOTTOMRIGHT", -padding, 0)
    elseif dir == "LEFT" then
        t:SetWidth(thickness)
        t:SetPoint("TOPLEFT", 0, -padding)
        t:SetPoint("BOTTOMLEFT", 0, padding)
    elseif dir == "RIGHT" then
        t:SetWidth(thickness)
        t:SetPoint("TOPRIGHT", 0, -padding)
        t:SetPoint("BOTTOMRIGHT", 0, padding)
    end
    return t
end

local function makeText(parent, text, fontObj, color)
    local fs = parent:CreateFontString(nil, "OVERLAY", fontObj or "GameFontNormal")
    fs:SetText(text)
    if color then fs:SetTextColor(rgb(color)) end
    return fs
end

local function makeButton(parent, label, w, h, accent)
    local b = CreateFrame("Button", nil, parent)
    b:SetSize(w, h)
    accent = accent or C.gold
    b.bg = b:CreateTexture(nil, "BACKGROUND")
    b.bg:SetAllPoints()
    setBG(b.bg, C.panel)
    b.borderTop    = makeBorderLine(b, accent, 1, "TOP", 0)
    b.borderBottom = makeBorderLine(b, accent, 1, "BOTTOM", 0)
    b.borderLeft   = makeBorderLine(b, accent, 1, "LEFT", 0)
    b.borderRight  = makeBorderLine(b, accent, 1, "RIGHT", 0)
    b.label = makeText(b, label, "GameFontNormal", accent)
    b.label:SetPoint("CENTER")
    b:SetScript("OnEnter", function(self)
        setBG(self.bg, C.panelHover)
        self.label:SetTextColor(rgb(C.text))
    end)
    b:SetScript("OnLeave", function(self)
        setBG(self.bg, C.panel)
        self.label:SetTextColor(rgb(accent))
    end)
    return b
end

----------------------------------------------------------------------
-- Launcher button (the on-screen circular logo)
----------------------------------------------------------------------
local function buildLauncher()
    if state.launcher then return state.launcher end

    local L = CreateFrame("Button", nil, UIParent)
    L:SetSize(44, 44)
    L:SetMovable(true)
    L:EnableMouse(true)
    L:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    L:RegisterForDrag("LeftButton")
    L:SetClampedToScreen(true)
    L:SetFrameStrata("MEDIUM")

    local p = ResurgenceDB.launcherPos or { "RIGHT", -8, 80 }
    L:SetPoint(p[1] or "RIGHT", UIParent, p[1] or "RIGHT", p[2] or -8, p[3] or 80)

    -- Soft drop shadow (icon source is already a circle with transparent corners,
    -- so the shadow inherits the circular silhouette automatically).
    L.shadow = L:CreateTexture(nil, "BACKGROUND")
    L.shadow:SetTexture(LOGO_PATH)
    L.shadow:SetPoint("CENTER", 1, -1)
    L.shadow:SetSize(46, 46)
    L.shadow:SetVertexColor(0, 0, 0, 0.7)

    -- Main icon (the source PNG / TGA is a perfectly circular logo on
    -- a transparent canvas, no mask needed).
    L.icon = L:CreateTexture(nil, "ARTWORK")
    L.icon:SetTexture(LOGO_PATH)
    L.icon:SetAllPoints()

    -- Cyan hover ring (GoldRing texture is already round)
    L.ring = L:CreateTexture(nil, "OVERLAY")
    L.ring:SetTexture("Interface\\COMMON\\GoldRing")
    L.ring:SetPoint("TOPLEFT", -3, 3)
    L.ring:SetPoint("BOTTOMRIGHT", 3, -3)
    L.ring:SetVertexColor(rgb(C.cyan))
    L.ring:SetAlpha(0)

    L:SetScript("OnEnter", function(self)
        UIFrameFadeIn(self.ring, 0.15, self.ring:GetAlpha(), 1)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText("|cffffd700Resurgence|r", 1, 1, 1)
        GameTooltip:AddLine("|cffaaaaaaLeft click|r  open the menu", 0.7, 0.85, 1)
        GameTooltip:AddLine("|cffaaaaaaDrag|r        move this button anywhere", 0.7, 0.85, 1)
        GameTooltip:AddLine("|cffaaaaaaRight click|r hide for this session", 0.7, 0.85, 1)
        GameTooltip:Show()
    end)
    L:SetScript("OnLeave", function(self)
        UIFrameFadeOut(self.ring, 0.20, self.ring:GetAlpha(), 0)
        GameTooltip:Hide()
    end)

    -- Plain drag (no shift modifier required). WoW's RegisterForDrag +
    -- RegisterForClicks automatically distinguishes a drag from a click
    -- based on whether the mouse moves between press and release.
    L:SetScript("OnDragStart", function(self) self:StartMoving() end)
    L:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local p1, _, _, x, y = self:GetPoint()
        ResurgenceDB.launcherPos = { p1, x, y }
    end)
    L:SetScript("OnClick", function(self, button)
        if button == "RightButton" then
            self:Hide()
            print("|cffffd700[Resurgence]|r launcher hidden. Use |cff80c0ff/res show|r to bring it back.")
            return
        end
        ResurgenceUI_Toggle()
    end)

    if ResurgenceDB.launcherHidden then L:Hide() end

    state.launcher = L
    return L
end

----------------------------------------------------------------------
-- World Buffs HUD (floating draggable window)
----------------------------------------------------------------------
local function buildBuffsHUD()
    if state.buffsHUD then return state.buffsHUD end

    local F = CreateFrame("Frame", nil, UIParent)
    F:SetSize(320, 480)
    F:SetMovable(true)
    F:EnableMouse(true)
    F:SetClampedToScreen(true)
    F:SetFrameStrata("MEDIUM")
    F:Hide()

    local p = ResurgenceDB.buffsHudPos or { "TOPRIGHT", -260, -260 }
    F:SetPoint(p[1] or "TOPRIGHT", UIParent, p[1] or "TOPRIGHT", p[2] or -260, p[3] or -260)

    -- Outer + inner
    local bg = F:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    setBG(bg, C.bgDeep)
    local inner = makePanel(F, C.bg)
    inner:SetPoint("TOPLEFT", 2, -2)
    inner:SetPoint("BOTTOMRIGHT", -2, 2)
    makeBorderLine(F, C.bronze, 1, "TOP", 0)
    makeBorderLine(F, C.bronze, 1, "BOTTOM", 0)
    makeBorderLine(F, C.bronze, 1, "LEFT", 0)
    makeBorderLine(F, C.bronze, 1, "RIGHT", 0)

    -- Header
    local header = makePanel(inner, C.bgDeep)
    header:SetPoint("TOPLEFT", 0, 0)
    header:SetPoint("TOPRIGHT", 0, 0)
    header:SetHeight(40)

    local title = makeText(header, "World Buffs", "GameFontNormalLarge", C.gold)
    title:SetPoint("LEFT", 12, 0)

    local goldLine = inner:CreateTexture(nil, "OVERLAY")
    setBG(goldLine, C.gold)
    goldLine:SetHeight(1)
    goldLine:SetPoint("LEFT", 8, 0)
    goldLine:SetPoint("RIGHT", -8, 0)
    goldLine:SetPoint("TOP", inner, "TOP", 0, -40)
    goldLine:SetAlpha(0.5)

    -- Close button
    F.close = CreateFrame("Button", nil, header, "UIPanelCloseButton")
    F.close:SetPoint("TOPRIGHT", 4, 4)
    F.close:SetScript("OnClick", function()
        F:Hide()
        ResurgenceDB.buffsHudOpen = false
    end)

    -- Subtitle
    local sub = makeText(inner, "Active right now. Click [Track] to follow the in-game arrow.",
        "GameFontDisableSmall", C.textMuted)
    sub:SetPoint("TOPLEFT", 12, -44)

    -- Drag the header to move
    header:EnableMouse(true)
    header:RegisterForDrag("LeftButton")
    header:SetScript("OnDragStart", function()
        if not ResurgenceDB.buffsHudLocked then F:StartMoving() end
    end)
    header:SetScript("OnDragStop", function()
        F:StopMovingOrSizing()
        local p1, _, _, x, y = F:GetPoint()
        ResurgenceDB.buffsHudPos = { p1, x, y }
    end)

    -- Build rows
    local rowY = 64
    local rowH = 56
    state.buffsHUDRows = {}
    for _, buff in ipairs(WORLD_BUFFS) do
        local row = CreateFrame("Frame", nil, inner)
        row:SetHeight(rowH)
        row:SetPoint("TOPLEFT", 8, -rowY)
        row:SetPoint("TOPRIGHT", -8, -rowY)

        local rowBG = row:CreateTexture(nil, "BACKGROUND")
        rowBG:SetAllPoints()
        setBG(rowBG, C.panel)

        -- Category/status accent on the left
        local accent = row:CreateTexture(nil, "OVERLAY")
        accent:SetWidth(2)
        accent:SetPoint("TOPLEFT", 0, 0)
        accent:SetPoint("BOTTOMLEFT", 0, 0)
        setBG(accent, buff.waypoint and C.cyan or C.goldDim)

        -- Spell icon
        row.icon = row:CreateTexture(nil, "ARTWORK")
        row.icon:SetSize(36, 36)
        row.icon:SetPoint("LEFT", 8, 0)
        row.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        row.icon:SetTexture(buff.icon or 134400)

        -- Name
        row.name = makeText(row, buff.name, "GameFontNormal", C.gold)
        row.name:SetPoint("TOPLEFT", row.icon, "TOPRIGHT", 8, -2)
        row.name:SetPoint("RIGHT", row, "RIGHT", -78, 0)
        row.name:SetJustifyH("LEFT")
        row.name:SetWordWrap(false)

        -- Countdown (live)
        row.countdown = makeText(row, "", "GameFontHighlightSmall", C.cyan)
        row.countdown:SetPoint("TOPLEFT", row.icon, "TOPRIGHT", 8, -18)
        row.countdown:SetJustifyH("LEFT")

        -- Location text
        row.location = makeText(row, buff.location or "", "GameFontDisableSmall", C.textMuted)
        row.location:SetPoint("TOPLEFT", row.icon, "TOPRIGHT", 8, -34)
        row.location:SetPoint("RIGHT", row, "RIGHT", -78, 0)
        row.location:SetJustifyH("LEFT")
        row.location:SetWordWrap(false)

        -- Track button
        if buff.waypoint then
            local btn = makeButton(row, "Track", 64, 24, C.cyan)
            btn:SetPoint("RIGHT", -6, 0)
            btn:SetScript("OnClick", function() trackWaypoint(buff) end)
        else
            local pill = makeText(row, "GLOBAL", "GameFontDisableSmall", C.textFaint)
            pill:SetPoint("RIGHT", -10, 0)
        end

        row.buff = buff
        table.insert(state.buffsHUDRows, row)
        rowY = rowY + rowH + 4
    end

    -- Resize HUD to fit
    inner:SetHeight(rowY + 8)
    F:SetHeight(rowY + 12)

    -- Footer signature
    local footer = makeText(inner, "Resurgence  |cff707080·|r  v" .. ADDON_VERSION,
        "GameFontDisableSmall", C.textFaint)
    footer:SetPoint("BOTTOM", 0, 6)

    -- Live countdown ticker (1s precision)
    F._tickAcc = 0
    F:SetScript("OnUpdate", function(self, elapsed)
        self._tickAcc = self._tickAcc + elapsed
        if self._tickAcc < 1.0 then return end
        self._tickAcc = 0
        local now = GetTime()
        for _, row in ipairs(state.buffsHUDRows) do
            local remaining = row.buff.endsAtAbsolute - now
            row.countdown:SetText(formatCountdown(remaining))
            if remaining <= 0 then
                row.countdown:SetTextColor(rgb(C.textFaint))
            elseif remaining < 3600 then
                row.countdown:SetTextColor(rgb(C.gold))
            else
                row.countdown:SetTextColor(rgb(C.cyan))
            end
        end
    end)

    state.buffsHUD = F
    return F
end

local function showBuffsHUD()
    local F = buildBuffsHUD()
    F:Show()
    ResurgenceDB.buffsHudOpen = true
end

local function hideBuffsHUD()
    if state.buffsHUD then state.buffsHUD:Hide() end
    ResurgenceDB.buffsHudOpen = false
end

local function toggleBuffsHUD()
    if state.buffsHUD and state.buffsHUD:IsShown() then
        hideBuffsHUD()
    else
        showBuffsHUD()
    end
end

----------------------------------------------------------------------
-- Tab content : Welcome
----------------------------------------------------------------------
local function buildWelcomeContent(parent)
    local p = makePanel(parent, { 0, 0, 0, 0 })
    p:SetAllPoints()

    -- Hero logo
    p.logo = p:CreateTexture(nil, "ARTWORK")
    p.logo:SetTexture(LOGO_PATH)
    p.logo:SetSize(140, 140)
    p.logo:SetPoint("TOP", 0, -16)

    -- Title
    p.title = makeText(p, "Welcome to Resurgence", "GameFontNormalHuge", C.gold)
    p.title:SetPoint("TOP", p.logo, "BOTTOM", 0, -16)

    -- Subtitle
    p.subtitle = makeText(p,
        "Premium awareness for the 12.0.x Midnight era.",
        "GameFontNormalLarge", C.cyan)
    p.subtitle:SetPoint("TOP", p.title, "BOTTOM", 0, -8)

    -- Decorative line
    local line = makeBorderLine(p, C.goldDim, 1, "TOP", 60)
    line:ClearAllPoints()
    line:SetHeight(1)
    line:SetPoint("TOP", p.subtitle, "BOTTOM", 0, -16)
    line:SetWidth(420)

    -- Body
    local body = makeText(p, "", "GameFontNormal", C.text)
    body:SetPoint("TOP", line, "BOTTOM", 0, -20)
    body:SetWidth(620)
    body:SetJustifyH("CENTER")
    body:SetJustifyV("TOP")
    body:SetSpacing(6)
    body:SetText(
        "Hi. You just installed Resurgence.\n\n" ..
        "Resurgence is the modern, focused, ground-up toolkit for the 12.0.x era. Designed by players, built for players. Premium awareness of the procs, cooldowns, and combat moments that actually matter, with the polish you expect and none of the bloat you don't.\n\n" ..
        "This first build is the visual shell. The engine arrives in v0.3.0. Browse the |cff80c0ffRoadmap|r tab to see what's coming and when.")

    -- CTA buttons
    local btnRoadmap = makeButton(p, "View Roadmap", 160, 32, C.cyan)
    btnRoadmap:SetPoint("BOTTOM", -90, 24)
    btnRoadmap:SetScript("OnClick", function() ResurgenceUI_OpenTab("roadmap") end)

    local btnAbout = makeButton(p, "Why Resurgence ?", 160, 32, C.gold)
    btnAbout:SetPoint("BOTTOM", 90, 24)
    btnAbout:SetScript("OnClick", function() ResurgenceUI_OpenTab("about") end)

    return p
end

----------------------------------------------------------------------
-- Tab content : Roadmap
----------------------------------------------------------------------
local function buildRoadmapContent(parent)
    local outer = makePanel(parent, { 0, 0, 0, 0 })
    outer:SetAllPoints()

    -- Section header
    local header = makeText(outer, "Roadmap", "GameFontNormalHuge", C.gold)
    header:SetPoint("TOPLEFT", 24, -20)
    local sub = makeText(outer,
        "Here is the build order. The community is missing too much to ship everything at once : we build the foundation, then layer on.",
        "GameFontNormal", C.textMuted)
    sub:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -6)
    sub:SetWidth(620)
    sub:SetJustifyH("LEFT")

    -- Scroll area
    local scroll = CreateFrame("ScrollFrame", nil, outer, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", sub, "BOTTOMLEFT", 0, -16)
    scroll:SetPoint("BOTTOMRIGHT", -28, 12)

    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(660, 1)
    scroll:SetScrollChild(content)

    local y = 0
    for _, milestone in ipairs(ROADMAP) do
        local card = makePanel(content, C.panel)
        card:SetPoint("TOPLEFT", 0, -y)
        card:SetPoint("RIGHT", content, "RIGHT", -8, 0)

        -- Status badge (left bar + label)
        local statusColor = STATUS_COLORS[milestone.status] or C.textFaint
        local bar = makeBorderLine(card, statusColor, 3, "LEFT", 0)
        local badge = makeText(card, STATUS_LABELS[milestone.status] or "?",
            "GameFontNormalSmall", statusColor)
        badge:SetPoint("TOPLEFT", 14, -10)

        -- Version + title
        local title = makeText(card, milestone.title, "GameFontNormalLarge", C.gold)
        title:SetPoint("TOPLEFT", 14, -28)

        local ver = makeText(card, "v" .. milestone.ver, "GameFontNormalSmall", C.textMuted)
        ver:SetPoint("LEFT", title, "RIGHT", 12, 0)

        -- Body
        local body = makeText(card, milestone.body, "GameFontHighlight", C.text)
        body:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
        body:SetWidth(600)
        body:SetJustifyH("LEFT")
        body:SetSpacing(3)

        local cardH = 28 + 20 + body:GetStringHeight() + 12

        -- Items list
        for _, item in ipairs(milestone.items) do
            local bullet = makeText(card, "  +  " .. item, "GameFontHighlightSmall", C.cyan)
            bullet:SetPoint("TOPLEFT", body, "BOTTOMLEFT", 6, -(cardH - 28 - 20 - body:GetStringHeight()))
            bullet:SetWidth(580)
            bullet:SetJustifyH("LEFT")
            cardH = cardH + bullet:GetStringHeight() + 2
        end

        cardH = cardH + 14
        card:SetHeight(cardH)
        y = y + cardH + 12
    end
    content:SetHeight(y)

    return outer
end

----------------------------------------------------------------------
-- Tab content : About
----------------------------------------------------------------------
local function buildAboutContent(parent)
    local outer = makePanel(parent, { 0, 0, 0, 0 })
    outer:SetAllPoints()

    local header = makeText(outer, "Why Resurgence ?", "GameFontNormalHuge", C.gold)
    header:SetPoint("TOPLEFT", 24, -20)

    local body = makeText(outer, "", "GameFontNormal", C.text)
    body:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -16)
    body:SetWidth(640)
    body:SetJustifyH("LEFT")
    body:SetSpacing(6)
    body:SetText(
        "Midnight changed the rules. The new engine is stricter, the security model is tighter, and the API surface most veteran addons leaned on is gone.\n\n" ..
        "Resurgence was designed for that world from day one. Every module is built on the new safe APIs. No |cff80c0ffCOMBAT_LOG_EVENT_UNFILTERED|r. No protected hooks. No engine-level taint. The kind of foundation you only get when you start fresh and listen to what the game is actually telling you.\n\n" ..
        "What you get is a focused, premium toolkit that earns its place on your screen. Per-class curation. Real attention to typography and timing. A roadmap that ships rather than promises. A maintainer who actually plays the game.\n\n" ..
        "|cffd0d0d0Built with care. Released with a roadmap. Maintained for keeps.|r")

    local sigLine = makeBorderLine(outer, C.goldDim, 1, "TOP", 24)
    sigLine:ClearAllPoints()
    sigLine:SetHeight(1)
    sigLine:SetPoint("BOTTOMLEFT", 24, 60)
    sigLine:SetPoint("BOTTOMRIGHT", -24, 60)

    local sig = makeText(outer, "AxelRodd  |cff707080·|r  still chasing the perfect corner hit",
        "GameFontNormalLarge", C.gold)
    sig:SetPoint("BOTTOM", 0, 28)

    return outer
end

----------------------------------------------------------------------
-- Tab content : Settings (placeholder)
----------------------------------------------------------------------
local function buildSettingsContent(parent)
    local outer = makePanel(parent, { 0, 0, 0, 0 })
    outer:SetAllPoints()

    local header = makeText(outer, "Settings", "GameFontNormalHuge", C.gold)
    header:SetPoint("TOPLEFT", 24, -20)

    local sub = makeText(outer,
        "Module settings will appear here as features ship. The shell stage exposes only the launcher options.",
        "GameFontNormal", C.textMuted)
    sub:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -8)
    sub:SetWidth(620)
    sub:SetJustifyH("LEFT")

    -- Launcher section
    local section = makeText(outer, "Launcher button", "GameFontNormalLarge", C.cyan)
    section:SetPoint("TOPLEFT", sub, "BOTTOMLEFT", 0, -28)

    local desc = makeText(outer,
        "The circular Resurgence logo on your screen. Shift + drag to move it. Right click on it to hide for the session.",
        "GameFontHighlight", C.text)
    desc:SetPoint("TOPLEFT", section, "BOTTOMLEFT", 0, -8)
    desc:SetWidth(620)
    desc:SetJustifyH("LEFT")
    desc:SetSpacing(3)

    local btnReset = makeButton(outer, "Reset launcher position", 220, 30, C.gold)
    btnReset:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 0, -16)
    btnReset:SetScript("OnClick", function()
        ResurgenceDB.launcherPos = { "RIGHT", -8, 80 }
        if state.launcher then
            state.launcher:ClearAllPoints()
            state.launcher:SetPoint("RIGHT", UIParent, "RIGHT", -8, 80)
        end
        print("|cffffd700[Resurgence]|r launcher position reset")
    end)

    local btnToggle = makeButton(outer, "Show / Hide launcher", 220, 30, C.cyan)
    btnToggle:SetPoint("LEFT", btnReset, "RIGHT", 12, 0)
    btnToggle:SetScript("OnClick", function()
        if not state.launcher then return end
        if state.launcher:IsShown() then
            state.launcher:Hide()
            ResurgenceDB.launcherHidden = true
        else
            state.launcher:Show()
            ResurgenceDB.launcherHidden = false
        end
    end)

    -- Tutorial replay section
    local section2 = makeText(outer, "Welcome message", "GameFontNormalLarge", C.cyan)
    section2:SetPoint("TOPLEFT", btnReset, "BOTTOMLEFT", 0, -28)

    local desc2 = makeText(outer,
        "The first-launch popup is shown once per character. Replay it any time below.",
        "GameFontHighlight", C.text)
    desc2:SetPoint("TOPLEFT", section2, "BOTTOMLEFT", 0, -8)
    desc2:SetWidth(620)

    local btnReplay = makeButton(outer, "Replay welcome popup", 220, 30, C.gold)
    btnReplay:SetPoint("TOPLEFT", desc2, "BOTTOMLEFT", 0, -16)
    btnReplay:SetScript("OnClick", function()
        ResurgenceDB.welcomed = false
        ResurgenceUI_ShowWelcome()
    end)

    return outer
end

----------------------------------------------------------------------
-- Tab content : Support
----------------------------------------------------------------------
local function buildSupportContent(parent)
    local outer = makePanel(parent, { 0, 0, 0, 0 })
    outer:SetAllPoints()

    local header = makeText(outer, "Support & Links", "GameFontNormalHuge", C.gold)
    header:SetPoint("TOPLEFT", 24, -20)

    local sub = makeText(outer,
        "Resurgence is open source on GitHub. Bug reports, feature suggestions, and pull requests welcome.",
        "GameFontNormal", C.textMuted)
    sub:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -8)
    sub:SetWidth(640)

    local function addLinkRow(yOffset, label, url, color)
        local row = makePanel(outer, C.panel)
        row:SetHeight(54)
        row:SetPoint("TOPLEFT", sub, "BOTTOMLEFT", 0, -yOffset)
        row:SetPoint("RIGHT", outer, "RIGHT", -28, 0)
        makeBorderLine(row, color or C.gold, 2, "LEFT", 0)
        local title = makeText(row, label, "GameFontNormalLarge", color or C.gold)
        title:SetPoint("TOPLEFT", 14, -10)
        local edit = CreateFrame("EditBox", nil, row, "InputBoxTemplate")
        edit:SetSize(560, 18)
        edit:SetAutoFocus(false)
        edit:SetText(url)
        edit:SetCursorPosition(0)
        edit:SetScript("OnEscapePressed", edit.ClearFocus)
        edit:SetScript("OnEnterPressed", edit.ClearFocus)
        edit:SetPoint("BOTTOMLEFT", 18, 8)
        return row
    end

    addLinkRow(20,  "Source code on GitHub",     "https://github.com/axelrodd123/Resurgence",          C.cyan)
    addLinkRow(86,  "Open an issue",             "https://github.com/axelrodd123/Resurgence/issues",   C.gold)
    addLinkRow(152, "CurseForge project",        "https://www.curseforge.com/wow/addons/resurgence",   C.gold)
    addLinkRow(218, "Author profile",            "https://github.com/axelrodd123",                     C.cyan)

    -- Footer signature
    local sig = makeText(outer,
        "AxelRodd  |cff707080·|r  Resurgence v" .. ADDON_VERSION,
        "GameFontDisableSmall", C.textFaint)
    sig:SetPoint("BOTTOM", 0, 16)

    return outer
end

----------------------------------------------------------------------
-- Tab content : World Buffs
----------------------------------------------------------------------
local function buildBuffsContent(parent)
    local outer = makePanel(parent, { 0, 0, 0, 0 })
    outer:SetAllPoints()

    local header = makeText(outer, "World Buffs", "GameFontNormalHuge", C.gold)
    header:SetPoint("TOPLEFT", 24, -20)

    local sub = makeText(outer,
        "Live countdowns for every active world event. Open the floating HUD to keep them on screen, or click any event below to track its location with the in-game arrow.",
        "GameFontNormal", C.textMuted)
    sub:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -8)
    sub:SetWidth(620)
    sub:SetJustifyH("LEFT")

    -- Toggle HUD button
    local btnHUD = makeButton(outer, "Open the HUD", 180, 30, C.cyan)
    btnHUD:SetPoint("TOPLEFT", sub, "BOTTOMLEFT", 0, -16)
    btnHUD:SetScript("OnClick", function() toggleBuffsHUD() end)

    local btnAllHidden = makeButton(outer, "Hide the HUD", 180, 30, C.gold)
    btnAllHidden:SetPoint("LEFT", btnHUD, "RIGHT", 12, 0)
    btnAllHidden:SetScript("OnClick", function() hideBuffsHUD() end)

    -- Scroll area with full event list
    local scroll = CreateFrame("ScrollFrame", nil, outer, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", btnHUD, "BOTTOMLEFT", 0, -20)
    scroll:SetPoint("BOTTOMRIGHT", -28, 12)

    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(640, 1)
    scroll:SetScrollChild(content)

    local y = 0
    local rowH = 64
    for _, buff in ipairs(WORLD_BUFFS) do
        local card = makePanel(content, C.panel)
        card:SetHeight(rowH)
        card:SetPoint("TOPLEFT", 0, -y)
        card:SetPoint("RIGHT", content, "RIGHT", -8, 0)

        local accent = card:CreateTexture(nil, "OVERLAY")
        accent:SetWidth(3)
        accent:SetPoint("TOPLEFT", 0, 0)
        accent:SetPoint("BOTTOMLEFT", 0, 0)
        setBG(accent, buff.waypoint and C.cyan or C.goldDim)

        local icon = card:CreateTexture(nil, "ARTWORK")
        icon:SetSize(40, 40)
        icon:SetPoint("LEFT", 10, 0)
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        icon:SetTexture(buff.icon or 134400)

        local name = makeText(card, buff.name, "GameFontNormalLarge", C.gold)
        name:SetPoint("TOPLEFT", icon, "TOPRIGHT", 10, -2)

        local desc = makeText(card, buff.desc or "", "GameFontHighlightSmall", C.text)
        desc:SetPoint("TOPLEFT", icon, "TOPRIGHT", 10, -22)
        desc:SetPoint("RIGHT", card, "RIGHT", -110, 0)
        desc:SetJustifyH("LEFT")

        local loc = makeText(card, buff.location or "", "GameFontDisableSmall", C.textMuted)
        loc:SetPoint("TOPLEFT", icon, "TOPRIGHT", 10, -42)
        loc:SetPoint("RIGHT", card, "RIGHT", -110, 0)
        loc:SetJustifyH("LEFT")

        if buff.waypoint then
            local btn = makeButton(card, "Track", 90, 26, C.cyan)
            btn:SetPoint("RIGHT", -10, 0)
            btn:SetScript("OnClick", function() trackWaypoint(buff) end)
        else
            local pill = makeText(card, "GLOBAL", "GameFontNormalSmall", C.textFaint)
            pill:SetPoint("RIGHT", -16, 0)
        end

        y = y + rowH + 6
    end

    content:SetHeight(y)
    return outer
end

----------------------------------------------------------------------
-- Tab dispatcher
----------------------------------------------------------------------
local TAB_BUILDERS = {
    welcome  = buildWelcomeContent,
    buffs    = buildBuffsContent,
    roadmap  = buildRoadmapContent,
    about    = buildAboutContent,
    settings = buildSettingsContent,
    support  = buildSupportContent,
}

local function selectTab(tabId)
    if not state.window then return end
    for id, panel in pairs(state.tabPanels) do
        if id == tabId then
            panel:Show()
        else
            panel:Hide()
        end
    end
    for id, btn in pairs(state.tabButtons) do
        if id == tabId then
            setBG(btn.bg, C.panelHover)
            btn.label:SetTextColor(rgb(C.gold))
            btn.activeBar:Show()
        else
            setBG(btn.bg, C.panel)
            btn.label:SetTextColor(rgb(C.textMuted))
            btn.activeBar:Hide()
        end
    end
    state.activeTab = tabId
    ResurgenceDB.lastTab = tabId
end

----------------------------------------------------------------------
-- Main window
----------------------------------------------------------------------
local function buildMainWindow()
    if state.window then return state.window end

    local W = CreateFrame("Frame", nil, UIParent)
    W:SetSize(900, 600)
    W:SetMovable(true)
    W:EnableMouse(true)
    W:SetClampedToScreen(true)
    W:SetFrameStrata("DIALOG")
    W:Hide()

    local p = ResurgenceDB.windowPos or { "CENTER", 0, 40 }
    W:SetPoint(p[1] or "CENTER", UIParent, p[1] or "CENTER", p[2] or 0, p[3] or 40)

    -- Outer dark backdrop
    local bg = W:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    setBG(bg, C.bgDeep)

    -- Inner panel
    local panel = makePanel(W, C.bg)
    panel:SetPoint("TOPLEFT", 2, -2)
    panel:SetPoint("BOTTOMRIGHT", -2, 2)

    -- Bronze border
    makeBorderLine(W, C.bronze, 2, "TOP", 0)
    makeBorderLine(W, C.bronze, 2, "BOTTOM", 0)
    makeBorderLine(W, C.bronze, 2, "LEFT", 0)
    makeBorderLine(W, C.bronze, 2, "RIGHT", 0)

    -- Header
    local header = makePanel(panel, C.bgDeep)
    header:SetPoint("TOPLEFT", 0, 0)
    header:SetPoint("TOPRIGHT", 0, 0)
    header:SetHeight(72)

    -- Header logo
    header.logo = header:CreateTexture(nil, "ARTWORK")
    header.logo:SetTexture(LOGO_PATH)
    header.logo:SetSize(56, 56)
    header.logo:SetPoint("LEFT", 16, 0)

    -- Title
    header.title = makeText(header, "RESURGENCE", "GameFontNormalHuge", C.gold)
    header.title:SetPoint("LEFT", header.logo, "RIGHT", 16, 4)

    header.subtitle = makeText(header,
        "Premium awareness for the 12.0.x era",
        "GameFontNormal", C.textMuted)
    header.subtitle:SetPoint("TOPLEFT", header.title, "BOTTOMLEFT", 0, -2)

    -- Version + close in top right
    header.version = makeText(header, "v" .. ADDON_VERSION, "GameFontNormalSmall", C.cyan)
    header.version:SetPoint("TOPRIGHT", -54, -16)

    header.close = CreateFrame("Button", nil, header, "UIPanelCloseButton")
    header.close:SetPoint("TOPRIGHT", -8, -8)
    header.close:SetScript("OnClick", function() W:Hide() end)

    -- Decorative gold line under header
    makeBorderLine(panel, C.gold, 1, "TOP", 0):SetPoint("TOPLEFT", 0, -72)
    -- Reset that anchor (above call's last parameter is wrong for our usage). Use direct texture:
    local goldLine = panel:CreateTexture(nil, "OVERLAY")
    setBG(goldLine, C.gold)
    goldLine:SetHeight(1)
    goldLine:SetPoint("LEFT", 16, 0)
    goldLine:SetPoint("RIGHT", -16, 0)
    goldLine:SetPoint("TOP", panel, "TOP", 0, -72)
    goldLine:SetAlpha(0.55)

    -- Sidebar
    local sidebar = makePanel(panel, C.bgDeep)
    sidebar:SetWidth(180)
    sidebar:SetPoint("TOPLEFT", 0, -73)
    sidebar:SetPoint("BOTTOMLEFT", 0, 32)

    -- Right divider for sidebar
    local sideDiv = sidebar:CreateTexture(nil, "OVERLAY")
    setBG(sideDiv, C.goldDim)
    sideDiv:SetWidth(1)
    sideDiv:SetPoint("TOPRIGHT", 0, 0)
    sideDiv:SetPoint("BOTTOMRIGHT", 0, 0)
    sideDiv:SetAlpha(0.4)

    -- Build tab buttons
    local tabY = 12
    for _, tab in ipairs(TABS) do
        local b = CreateFrame("Button", nil, sidebar)
        b:SetHeight(40)
        b:SetPoint("TOPLEFT", 8, -tabY)
        b:SetPoint("RIGHT", sidebar, "RIGHT", -8, 0)

        b.bg = b:CreateTexture(nil, "BACKGROUND")
        b.bg:SetAllPoints()
        setBG(b.bg, C.panel)

        -- Active indicator (cyan left bar)
        b.activeBar = b:CreateTexture(nil, "OVERLAY")
        setBG(b.activeBar, C.cyan)
        b.activeBar:SetWidth(3)
        b.activeBar:SetPoint("TOPLEFT", 0, 0)
        b.activeBar:SetPoint("BOTTOMLEFT", 0, 0)
        b.activeBar:Hide()

        b.label = makeText(b, tab.label, "GameFontNormalLarge", C.textMuted)
        b.label:SetPoint("LEFT", 18, 0)

        b:SetScript("OnEnter", function(self)
            if state.activeTab ~= tab.id then
                setBG(self.bg, C.panelHover)
                self.label:SetTextColor(rgb(C.text))
            end
        end)
        b:SetScript("OnLeave", function(self)
            if state.activeTab ~= tab.id then
                setBG(self.bg, C.panel)
                self.label:SetTextColor(rgb(C.textMuted))
            end
        end)
        b:SetScript("OnClick", function() selectTab(tab.id) end)

        state.tabButtons[tab.id] = b
        tabY = tabY + 48
    end

    -- Content area
    local content = makePanel(panel, C.bg)
    content:SetPoint("TOPLEFT", sidebar, "TOPRIGHT", 0, 0)
    content:SetPoint("BOTTOMRIGHT", 0, 32)

    -- Build all tab panels
    for _, tab in ipairs(TABS) do
        local builder = TAB_BUILDERS[tab.id]
        if builder then
            local panel = builder(content)
            panel:Hide()
            state.tabPanels[tab.id] = panel
        end
    end

    -- Footer
    local footer = makePanel(panel, C.bgDeep)
    footer:SetHeight(32)
    footer:SetPoint("BOTTOMLEFT", 0, 0)
    footer:SetPoint("BOTTOMRIGHT", 0, 0)
    local footerLine = panel:CreateTexture(nil, "OVERLAY")
    setBG(footerLine, C.goldDim)
    footerLine:SetHeight(1)
    footerLine:SetPoint("LEFT", 16, 0)
    footerLine:SetPoint("RIGHT", -16, 0)
    footerLine:SetPoint("BOTTOM", panel, "BOTTOM", 0, 32)
    footerLine:SetAlpha(0.4)

    local footerSig = makeText(footer,
        "Resurgence  |cff707080·|r  AxelRodd  |cff707080·|r  Proprietary, all rights reserved",
        "GameFontDisableSmall", C.textFaint)
    footerSig:SetPoint("CENTER")

    -- Drag the header to move
    header:EnableMouse(true)
    header:RegisterForDrag("LeftButton")
    header:SetScript("OnDragStart", function() W:StartMoving() end)
    header:SetScript("OnDragStop", function()
        W:StopMovingOrSizing()
        local p1, _, _, x, y = W:GetPoint()
        ResurgenceDB.windowPos = { p1, x, y }
    end)

    state.window = W
    return W
end

----------------------------------------------------------------------
-- Welcome popup (first-time)
----------------------------------------------------------------------
local function buildWelcomePopup()
    if state.welcomePopup then return state.welcomePopup end

    local P = CreateFrame("Frame", nil, UIParent)
    P:SetSize(560, 420)
    P:SetPoint("CENTER", 0, 60)
    P:SetMovable(true)
    P:EnableMouse(true)
    P:SetFrameStrata("DIALOG")
    P:SetClampedToScreen(true)
    P:Hide()

    local bg = P:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    setBG(bg, C.bgDeep)

    local inner = makePanel(P, C.bg)
    inner:SetPoint("TOPLEFT", 2, -2)
    inner:SetPoint("BOTTOMRIGHT", -2, 2)

    -- Bronze border
    makeBorderLine(P, C.bronze, 2, "TOP", 0)
    makeBorderLine(P, C.bronze, 2, "BOTTOM", 0)
    makeBorderLine(P, C.bronze, 2, "LEFT", 0)
    makeBorderLine(P, C.bronze, 2, "RIGHT", 0)

    -- Logo
    P.logo = inner:CreateTexture(nil, "ARTWORK")
    P.logo:SetTexture(LOGO_PATH)
    P.logo:SetSize(120, 120)
    P.logo:SetPoint("TOP", 0, -16)

    -- Title
    P.title = makeText(inner, "Welcome to Resurgence", "GameFontNormalHuge", C.gold)
    P.title:SetPoint("TOP", P.logo, "BOTTOM", 0, -8)

    -- Subtitle
    P.subtitle = makeText(inner,
        "Premium awareness for the 12.0.x era",
        "GameFontNormal", C.cyan)
    P.subtitle:SetPoint("TOP", P.title, "BOTTOM", 0, -4)

    -- Body
    local body = makeText(inner, "", "GameFontNormal", C.text)
    body:SetPoint("TOP", P.subtitle, "BOTTOM", 0, -16)
    body:SetWidth(480)
    body:SetJustifyH("CENTER")
    body:SetSpacing(4)
    body:SetText(
        "Look at your screen : a small circular logo just appeared on the right edge. " ..
        "Click it any time to open the full menu, or use |cff80c0ff/res|r in chat.\n\n" ..
        "This early build is the visual shell. The aura engine ships next. " ..
        "Browse the Roadmap to see what's coming.")

    -- Buttons
    local btnRoadmap = makeButton(inner, "Show me the roadmap", 200, 32, C.cyan)
    btnRoadmap:SetPoint("BOTTOM", -110, 24)
    btnRoadmap:SetScript("OnClick", function()
        ResurgenceDB.welcomed = true
        P:Hide()
        ResurgenceUI_OpenTab("roadmap")
    end)

    local btnDismiss = makeButton(inner, "Got it, take me to the game", 200, 32, C.gold)
    btnDismiss:SetPoint("BOTTOM", 110, 24)
    btnDismiss:SetScript("OnClick", function()
        ResurgenceDB.welcomed = true
        P:Hide()
    end)

    -- Close X
    P.close = CreateFrame("Button", nil, inner, "UIPanelCloseButton")
    P.close:SetPoint("TOPRIGHT", -2, -2)
    P.close:SetScript("OnClick", function()
        ResurgenceDB.welcomed = true
        P:Hide()
    end)

    state.welcomePopup = P
    return P
end

----------------------------------------------------------------------
-- Public API
----------------------------------------------------------------------
function ResurgenceUI_OpenTab(tabId)
    local W = buildMainWindow()
    selectTab(tabId or ResurgenceDB.lastTab or "welcome")
    W:Show()
end

function ResurgenceUI_Toggle()
    local W = buildMainWindow()
    if W:IsShown() then
        W:Hide()
    else
        selectTab(ResurgenceDB.lastTab or "welcome")
        W:Show()
    end
end

function ResurgenceUI_ShowWelcome()
    local P = buildWelcomePopup()
    P:Show()
end

----------------------------------------------------------------------
-- Login flow
----------------------------------------------------------------------
local handler = CreateFrame("Frame")
handler:RegisterEvent("ADDON_LOADED")
handler:RegisterEvent("PLAYER_LOGIN")
handler:SetScript("OnEvent", function(_, event, name)
    if event == "ADDON_LOADED" then
        if name == ADDON_NAME then
            -- Defaults applied here (after SavedVariables are restored). Doing
            -- this at file scope is unreliable when the saved file pre-dates
            -- the current schema, because the saved table can be re-bound
            -- after the file has run.
            ResurgenceDB = ResurgenceDB or {}
            if ResurgenceDB.welcomed       == nil then ResurgenceDB.welcomed       = false end
            if ResurgenceDB.launcherHidden == nil then ResurgenceDB.launcherHidden = false end
            ResurgenceDB.launcherPos = ResurgenceDB.launcherPos or { "RIGHT", -8, 80 }
            ResurgenceDB.windowPos   = ResurgenceDB.windowPos   or { "CENTER", 0, 40 }
            ResurgenceDB.lastTab     = ResurgenceDB.lastTab     or "welcome"
        end
    elseif event == "PLAYER_LOGIN" then
        buildLauncher()
        if ResurgenceDB.buffsHudOpen then
            C_Timer.After(0.5, function() showBuffsHUD() end)
        end
        if not ResurgenceDB.welcomed then
            C_Timer.After(2.0, function()
                ResurgenceUI_ShowWelcome()
            end)
        end
        print(string.format(
            "|cffffd700[Resurgence]|r v%s loaded. Click the logo on the right edge of your screen, or use |cff80c0ff/res|r.",
            ADDON_VERSION))
    end
end)

----------------------------------------------------------------------
-- Slash commands
----------------------------------------------------------------------
SLASH_RESURGENCE1 = "/res"
SLASH_RESURGENCE2 = "/resurgence"
SlashCmdList["RESURGENCE"] = function(msg)
    msg = (msg or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
    local cmd, arg = msg:match("^(%S+)%s*(.*)$")
    cmd = cmd or ""

    if cmd == "" or cmd == "show" then
        if msg == "show" and state.launcher and ResurgenceDB.launcherHidden then
            state.launcher:Show()
            ResurgenceDB.launcherHidden = false
            print("|cffffd700[Resurgence]|r launcher visible")
        else
            ResurgenceUI_Toggle()
        end
    elseif cmd == "hide" then
        if state.launcher then
            state.launcher:Hide()
            ResurgenceDB.launcherHidden = true
            print("|cffffd700[Resurgence]|r launcher hidden. /res show to bring it back.")
        end
    elseif cmd == "welcome" then
        ResurgenceDB.welcomed = false
        ResurgenceUI_ShowWelcome()
    elseif cmd == "roadmap" then
        ResurgenceUI_OpenTab("roadmap")
    elseif cmd == "about" then
        ResurgenceUI_OpenTab("about")
    elseif cmd == "settings" or cmd == "config" then
        ResurgenceUI_OpenTab("settings")
    elseif cmd == "support" then
        ResurgenceUI_OpenTab("support")
    elseif cmd == "buffs" or cmd == "worldbuffs" then
        if arg == "show" then
            showBuffsHUD()
        elseif arg == "hide" then
            hideBuffsHUD()
        else
            toggleBuffsHUD()
        end
    elseif cmd == "reset" then
        ResurgenceDB.launcherPos = { "RIGHT", -8, 80 }
        ResurgenceDB.windowPos   = { "CENTER", 0, 40 }
        if state.launcher then
            state.launcher:ClearAllPoints()
            state.launcher:SetPoint("RIGHT", UIParent, "RIGHT", -8, 80)
            state.launcher:Show()
            ResurgenceDB.launcherHidden = false
        end
        if state.window then
            state.window:ClearAllPoints()
            state.window:SetPoint("CENTER", UIParent, "CENTER", 0, 40)
        end
        print("|cffffd700[Resurgence]|r positions reset")
    elseif cmd == "help" or cmd == "?" then
        print("|cffffd700[Resurgence]|r v" .. ADDON_VERSION .. " commands :")
        print("  |cff80c0ff/res|r              toggle the main window")
        print("  |cff80c0ff/res show / hide|r  toggle the on-screen launcher button")
        print("  |cff80c0ff/res welcome|r      replay the welcome popup")
        print("  |cff80c0ff/res roadmap|r      open Roadmap tab")
        print("  |cff80c0ff/res about|r        open About tab")
        print("  |cff80c0ff/res settings|r     open Settings tab")
        print("  |cff80c0ff/res support|r      open Support / Links tab")
        print("  |cff80c0ff/res buffs|r        toggle the floating World Buffs HUD")
        print("  |cff80c0ff/res reset|r        reset launcher and window positions")
    else
        print("|cffffd700[Resurgence]|r unknown. |cff80c0ff/res help|r for commands")
    end
end
