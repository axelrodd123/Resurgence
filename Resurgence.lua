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
ResurgenceDB.setupDone      = ResurgenceDB.setupDone or false
ResurgenceDB.preferences    = ResurgenceDB.preferences or { role = nil, content = {}, modules = {} }
ResurgenceDB.aurasEnabled   = ResurgenceDB.aurasEnabled or {} -- aura.id -> true if enabled
ResurgenceDB.aurasDisabled  = ResurgenceDB.aurasDisabled or {} -- aura.id -> true if explicitly disabled
ResurgenceDB.aurasHudPos    = ResurgenceDB.aurasHudPos or { "CENTER", 0, -180 }
ResurgenceDB.aurasHudLocked = ResurgenceDB.aurasHudLocked or false
ResurgenceDB.cleanMode      = ResurgenceDB.cleanMode or false
ResurgenceDB.xpBar          = ResurgenceDB.xpBar
if ResurgenceDB.xpBar == nil then ResurgenceDB.xpBar = true end
ResurgenceDB.xpBarPos       = ResurgenceDB.xpBarPos or { "TOP", 0, -8 }
ResurgenceDB.chatSkin       = ResurgenceDB.chatSkin or false

----------------------------------------------------------------------
-- Tab definitions
----------------------------------------------------------------------
local TABS = {
    { id = "welcome",  label = "Welcome" },
    { id = "auras",    label = "Auras" },
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
        ver = "0.3.0", status = "shipped",
        title = "World Buffs",
        body = "Live countdowns for every active world event in one floating window. One click takes you there with the in-game native 3D arrow that tilts up or down depending on the target's altitude.",
        items = {
            "Floating HUD with active events and live countdowns",
            "Per-event Track button with native waypoint and 3D arrow",
            "Toggle from launcher menu, slash command, or in-app tab",
        },
    },
    {
        ver = "0.4.0-alpha", status = "current",
        title = "Aura Engine + Setup Wizard",
        body = "The first real combat module. Curated procs and active buffs that matter to your spec, plus a guided onboarding that asks what you actually need and configures everything for you.",
        items = {
            "39 hand-picked procs and active buffs across all 13 classes",
            "Auto-filtered by your class and spec at login",
            "Floating aura panel, draggable, position persisted",
            "Multi-step onboarding wizard on first launch",
            "Per-aura toggle from the Auras tab",
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

    -- Scroll content (settings list grows with features)
    local scroll = CreateFrame("ScrollFrame", nil, outer, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 4, -4)
    scroll:SetPoint("BOTTOMRIGHT", -28, 4)

    local sc = CreateFrame("Frame", nil, scroll)
    sc:SetSize(660, 1)
    scroll:SetScrollChild(sc)

    local header = makeText(sc, "Settings", "GameFontNormalHuge", C.gold)
    header:SetPoint("TOPLEFT", 24, -20)

    local sub = makeText(sc,
        "Tune Resurgence to your liking. Features grow as modules ship.",
        "GameFontNormal", C.textMuted)
    sub:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -8)
    sub:SetWidth(620)
    sub:SetJustifyH("LEFT")

    -- Helper for toggle rows
    local function addToggleRow(anchor, yOff, title, descText, getter, setter, accent)
        local row = makePanel(sc, C.panel)
        row:SetHeight(56)
        row:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, yOff)
        row:SetPoint("RIGHT", sc, "RIGHT", -8, 0)
        makeBorderLine(row, accent or C.cyan, 2, "LEFT", 0)

        local rt = makeText(row, title, "GameFontNormalLarge", accent or C.cyan)
        rt:SetPoint("TOPLEFT", 14, -8)
        local rd = makeText(row, descText, "GameFontHighlightSmall", C.text)
        rd:SetPoint("TOPLEFT", rt, "BOTTOMLEFT", 0, -2)
        rd:SetPoint("RIGHT", row, "RIGHT", -52, 0)
        rd:SetJustifyH("LEFT")
        rd:SetWordWrap(true)

        local cb = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
        cb:SetSize(28, 28)
        cb:SetPoint("RIGHT", -14, 0)
        cb:SetChecked(getter())
        cb:SetScript("OnClick", function(self_)
            setter(self_:GetChecked() and true or false)
        end)
        return row, cb
    end

    -- Section : UI replacement
    local visSection = makeText(sc, "Resurgence UI replacement", "GameFontNormalLarge", C.gold)
    visSection:SetPoint("TOPLEFT", sub, "BOTTOMLEFT", 0, -28)
    local visSub = makeText(sc,
        "Hide Blizzard's default clutter and replace key bits with Resurgence equivalents. Toggle anything off whenever you need the default behavior back.",
        "GameFontDisableSmall", C.textMuted)
    visSub:SetPoint("TOPLEFT", visSection, "BOTTOMLEFT", 0, -2)
    visSub:SetWidth(620)
    visSub:SetJustifyH("LEFT")

    local row1 = addToggleRow(visSub, -12,
        "Clean Mode",
        "Hides Blizzard's quest tracker, default buffs, talking head, zone banners, micro menu, default XP bar, minimap clutter. Action bars and unit frames stay so you can still play.",
        function() return ResurgenceDB.cleanMode end,
        function(v) applyCleanMode(v) end,
        C.gold)

    local row2 = addToggleRow(row1, -12,
        "Resurgence XP Bar",
        "Custom XP bar at the top of your screen with live progress and a time-to-ding estimate based on the XP you've earned recently.",
        function() return ResurgenceDB.xpBar end,
        function(v)
            if v then showXpBar() else hideXpBar() end
        end,
        C.gold)

    local row3 = addToggleRow(row2, -12,
        "Chat skin",
        "Re-skins the default chat frames with the Resurgence dark navy and gold trim. Functionality stays untouched.",
        function() return ResurgenceDB.chatSkin end,
        function(v) applyChatSkin(v) end,
        C.gold)

    -- Launcher section (existing)
    local section = makeText(sc, "Launcher button", "GameFontNormalLarge", C.cyan)
    section:SetPoint("TOPLEFT", row3, "BOTTOMLEFT", 0, -28)

    local desc = makeText(sc,
        "The circular Resurgence logo on your screen. Drag to move. Right click to hide for the session.",
        "GameFontHighlight", C.text)
    desc:SetPoint("TOPLEFT", section, "BOTTOMLEFT", 0, -8)
    desc:SetWidth(620)
    desc:SetJustifyH("LEFT")
    desc:SetSpacing(3)

    local btnReset = makeButton(sc, "Reset launcher position", 220, 30, C.gold)
    btnReset:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 0, -16)
    btnReset:SetScript("OnClick", function()
        ResurgenceDB.launcherPos = { "RIGHT", -8, 80 }
        if state.launcher then
            state.launcher:ClearAllPoints()
            state.launcher:SetPoint("RIGHT", UIParent, "RIGHT", -8, 80)
        end
        print("|cffffd700[Resurgence]|r launcher position reset")
    end)

    local btnToggle = makeButton(sc, "Show / Hide launcher", 220, 30, C.cyan)
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
    local section2 = makeText(sc, "Onboarding wizard", "GameFontNormalLarge", C.cyan)
    section2:SetPoint("TOPLEFT", btnReset, "BOTTOMLEFT", 0, -28)

    local desc2 = makeText(sc,
        "The 3-step setup wizard runs once per character. Replay it any time below.",
        "GameFontHighlight", C.text)
    desc2:SetPoint("TOPLEFT", section2, "BOTTOMLEFT", 0, -8)
    desc2:SetWidth(620)

    local btnReplay = makeButton(sc, "Replay onboarding wizard", 220, 30, C.gold)
    btnReplay:SetPoint("TOPLEFT", desc2, "BOTTOMLEFT", 0, -16)
    btnReplay:SetScript("OnClick", function()
        ResurgenceUI_StartSetup()
    end)

    -- Set scroll content height
    sc:SetHeight(720)

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
-- AURA ENGINE
-- Watches UNIT_AURA on the player. For every aura in Resurgence_AuraDB
-- that matches the player's class (and is enabled), an icon appears in
-- a floating panel while the buff is active.
----------------------------------------------------------------------
local function getPlayerClass()
    local _, class = UnitClass("player")
    return class
end

local function getActiveAuras()
    local class = getPlayerClass()
    local list = {}
    if not Resurgence_AuraDB then return list end
    for _, aura in ipairs(Resurgence_AuraDB) do
        local classMatch = (aura.class == class) or (aura.class == "ALL")
        local enabled = ResurgenceDB.aurasDisabled and not ResurgenceDB.aurasDisabled[aura.id]
        if classMatch and enabled then
            table.insert(list, aura)
        end
    end
    table.sort(list, function(a, b)
        if (a.priority or 9) ~= (b.priority or 9) then
            return (a.priority or 9) < (b.priority or 9)
        end
        return (a.name or "") < (b.name or "")
    end)
    return list
end

local function getPlayerBuff(spellID)
    if C_UnitAuras and C_UnitAuras.GetPlayerAuraBySpellID then
        return C_UnitAuras.GetPlayerAuraBySpellID(spellID)
    end
    return nil
end

local function getSpellIcon(spellID)
    if C_Spell and C_Spell.GetSpellInfo then
        local info = C_Spell.GetSpellInfo(spellID)
        if info and info.iconID then return info.iconID end
    end
    if GetSpellTexture then return GetSpellTexture(spellID) end
    return 134400
end

local AURA_ICON_SIZE = 52
local function buildAurasHUD()
    if state.aurasHUD then return state.aurasHUD end

    local H = CreateFrame("Frame", nil, UIParent)
    H:SetSize(420, AURA_ICON_SIZE + 20)
    H:SetMovable(true)
    H:EnableMouse(false)
    H:SetClampedToScreen(true)
    H:SetFrameStrata("MEDIUM")

    local p = ResurgenceDB.aurasHudPos or { "CENTER", 0, -180 }
    H:SetPoint(p[1] or "CENTER", UIParent, p[1] or "CENTER", p[2] or 0, p[3] or -180)

    -- Drag handle visible only when unlocked
    H.handle = H:CreateTexture(nil, "BACKGROUND")
    H.handle:SetAllPoints()
    H.handle:SetColorTexture(0, 0.3, 0.5, 0.18)
    H.handle:Hide()

    H.label = makeText(H, "RESURGENCE — Auras (drag to move)",
        "GameFontDisableSmall", C.cyanDim)
    H.label:SetPoint("TOP", 0, 8)
    H.label:Hide()

    H:RegisterForDrag("LeftButton")
    H:SetScript("OnDragStart", function(self)
        if not ResurgenceDB.aurasHudLocked then self:StartMoving() end
    end)
    H:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local p1, _, _, x, y = self:GetPoint()
        ResurgenceDB.aurasHudPos = { p1, x, y }
    end)

    H.icons = {}    -- aura.id -> icon frame (pooled)

    function H:Refresh()
        local active = getActiveAuras()
        -- Hide all current icons
        for _, ic in pairs(self.icons) do ic:Hide() end

        local x = 8
        for _, aura in ipairs(active) do
            local found, dur, exp = false, 0, 0
            local data = getPlayerBuff(aura.spellID)
            if data then
                found = true
                dur = data.duration or 0
                exp = data.expirationTime or 0
            end

            if found then
                local ic = self.icons[aura.id]
                if not ic then
                    ic = CreateFrame("Frame", nil, self, "BackdropTemplate")
                    ic:SetSize(AURA_ICON_SIZE, AURA_ICON_SIZE)
                    ic.tex = ic:CreateTexture(nil, "ARTWORK")
                    ic.tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
                    ic.tex:SetAllPoints()
                    ic.tex:SetTexture(getSpellIcon(aura.spellID))
                    if ic.SetBackdrop then
                        ic:SetBackdrop({
                            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                            edgeSize = 12,
                            insets = { left = 2, right = 2, top = 2, bottom = 2 },
                        })
                        ic:SetBackdropBorderColor(rgb(C.gold))
                    end
                    ic.cd = CreateFrame("Cooldown", nil, ic, "CooldownFrameTemplate")
                    ic.cd:SetAllPoints()
                    ic.cd:SetSwipeColor(0, 0, 0, 0.55)
                    ic.cd:SetDrawEdge(true)
                    ic.cd:SetHideCountdownNumbers(false)
                    ic:EnableMouse(true)
                    ic:SetScript("OnEnter", function(self_)
                        GameTooltip:SetOwner(self_, "ANCHOR_BOTTOM")
                        GameTooltip:SetText(aura.name, 1, 0.85, 0.2)
                        GameTooltip:AddLine(aura.tag or "buff", 0.5, 0.7, 1)
                        GameTooltip:Show()
                    end)
                    ic:SetScript("OnLeave", function() GameTooltip:Hide() end)
                    self.icons[aura.id] = ic
                end
                ic:ClearAllPoints()
                ic:SetPoint("LEFT", self, "LEFT", x, 0)
                ic:Show()
                if dur > 0 and exp > 0 then
                    ic.cd:SetCooldown(exp - dur, dur)
                else
                    ic.cd:Clear()
                end
                x = x + AURA_ICON_SIZE + 6
            end
        end

        if x == 8 then
            self:SetAlpha(0.0)
        else
            self:SetAlpha(1.0)
        end
        self:SetWidth(math.max(60, x + 8))
    end

    function H:ApplyLock()
        if ResurgenceDB.aurasHudLocked then
            self:EnableMouse(false)
            self.handle:Hide()
            self.label:Hide()
        else
            self:EnableMouse(true)
            self.handle:Show()
            self.label:Show()
            self:SetAlpha(1.0)  -- always visible while unlocked
        end
    end

    state.aurasHUD = H
    H:ApplyLock()
    H:Refresh()
    return H
end

local function refreshAurasHUD()
    if state.aurasHUD then state.aurasHUD:Refresh() end
end

local function isAurasModuleEnabled()
    if ResurgenceDB.preferences and ResurgenceDB.preferences.modules then
        return ResurgenceDB.preferences.modules.auras ~= false
    end
    return true  -- default on
end

local auraHandler = CreateFrame("Frame")
auraHandler:RegisterUnitEvent("UNIT_AURA", "player")
auraHandler:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
auraHandler:SetScript("OnEvent", function(_, event, unit)
    if event == "UNIT_AURA" and unit ~= "player" then return end
    if not isAurasModuleEnabled() then return end
    if not state.aurasHUD then buildAurasHUD() end
    refreshAurasHUD()
end)

----------------------------------------------------------------------
-- XP BAR (top of screen, custom, with time-to-ding estimate)
----------------------------------------------------------------------
local xpSamples = {} -- { {time, xp}, ... } rolling window of last 30 minutes

local function addXpSample(t, xp)
    table.insert(xpSamples, { time = t, xp = xp })
    while xpSamples[1] and xpSamples[1].time < t - 1800 do
        table.remove(xpSamples, 1)
    end
end

local function estimateXpRate()
    if #xpSamples < 2 then return 0 end
    local first = xpSamples[1]
    local last = xpSamples[#xpSamples]
    local dt = last.time - first.time
    local dxp = last.xp - first.xp
    if dt < 30 or dxp <= 0 then return 0 end
    return dxp / dt -- xp per second
end

local function fmtBig(n)
    if n >= 1e6 then return string.format("%.2fM", n / 1e6) end
    if n >= 1e3 then return string.format("%.1fk", n / 1e3) end
    return tostring(math.floor(n))
end

local function buildXpBar()
    if state.xpBar then return state.xpBar end

    local B = CreateFrame("Frame", nil, UIParent)
    B:SetSize(640, 22)
    local p = ResurgenceDB.xpBarPos or { "TOP", 0, -8 }
    B:SetPoint(p[1] or "TOP", UIParent, p[1] or "TOP", p[2] or 0, p[3] or -8)
    B:SetMovable(true)
    B:EnableMouse(false)
    B:SetClampedToScreen(true)
    B:SetFrameStrata("HIGH")

    local bg = B:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    setBG(bg, C.bgDeep)

    -- Bronze border
    makeBorderLine(B, C.bronze, 1, "TOP", 0)
    makeBorderLine(B, C.bronze, 1, "BOTTOM", 0)
    makeBorderLine(B, C.bronze, 1, "LEFT", 0)
    makeBorderLine(B, C.bronze, 1, "RIGHT", 0)

    local fill = CreateFrame("StatusBar", nil, B)
    fill:SetPoint("TOPLEFT", 1, -1)
    fill:SetPoint("BOTTOMRIGHT", -1, 1)
    fill:SetMinMaxValues(0, 1)
    fill:SetValue(0)
    local barTex = fill:CreateTexture(nil, "ARTWORK")
    barTex:SetColorTexture(rgb(C.gold))
    barTex:SetAlpha(0.55)
    fill:SetStatusBarTexture(barTex)
    B.fill = fill

    -- Subtle stripe overlay over the fill for premium feel
    local stripe = fill:CreateTexture(nil, "OVERLAY")
    stripe:SetAllPoints()
    stripe:SetColorTexture(1, 1, 1, 0.05)

    local label = B:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("CENTER")
    label:SetTextColor(rgb(C.text))
    label:SetText("Lv ?  ·  -- / --")
    B.label = label

    -- Drag (only when CTRL is held to avoid accidents)
    B:RegisterForDrag("LeftButton")
    B:SetScript("OnDragStart", function(self)
        if IsControlKeyDown() then self:StartMoving() end
    end)
    B:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local p1, _, _, x, y = self:GetPoint()
        ResurgenceDB.xpBarPos = { p1, x, y }
    end)

    function B:UpdateNow()
        local lvl = UnitLevel("player") or 0
        local cur = UnitXP("player") or 0
        local mx  = UnitXPMax("player") or 1

        local maxLevel = (GetMaxLevelForExpansionLevel and GetMaxLevelForExpansionLevel(GetExpansionLevel and GetExpansionLevel() or 0)) or 80
        if mx == 0 or cur == 0 and lvl >= maxLevel then
            self.fill:SetValue(0)
            self.label:SetText(string.format("Lv %d  ·  Max level", lvl))
            return
        end

        addXpSample(GetTime(), cur)

        local pct = mx > 0 and (cur / mx) or 0
        self.fill:SetValue(pct)

        local rate = estimateXpRate() -- xp/sec
        local etaText = ""
        if rate > 0 and cur < mx then
            local remaining = mx - cur
            local etaSec = remaining / rate
            local etaMin = etaSec / 60
            if etaMin < 1 then
                etaText = string.format("  ·  <1m to ding")
            elseif etaMin < 60 then
                etaText = string.format("  ·  %dm to ding", math.floor(etaMin))
            else
                etaText = string.format("  ·  %dh %02dm to ding",
                    math.floor(etaMin / 60), math.floor(etaMin) % 60)
            end
        end

        self.label:SetText(string.format(
            "|cffffd200Lv %d|r  ·  %s / %s  (%.1f%%)%s",
            lvl, fmtBig(cur), fmtBig(mx), pct * 100, etaText))
    end

    -- Throttle update : every 1 sec
    local acc = 0
    B:SetScript("OnUpdate", function(self, elapsed)
        acc = acc + elapsed
        if acc < 1.0 then return end
        acc = 0
        self:UpdateNow()
    end)

    state.xpBar = B
    B:UpdateNow()
    return B
end

local function showXpBar()
    if not state.xpBar then buildXpBar() end
    state.xpBar:Show()
    ResurgenceDB.xpBar = true
end

local function hideXpBar()
    if state.xpBar then state.xpBar:Hide() end
    ResurgenceDB.xpBar = false
end

----------------------------------------------------------------------
-- CLEAN MODE (hide Blizzard clutter so Resurgence's footprint is visible)
----------------------------------------------------------------------
local CLEAN_TARGETS = {
    "ObjectiveTrackerFrame",
    "BuffFrame",
    "DebuffFrame",
    "TalkingHeadFrame",
    "ZoneTextFrame",
    "SubZoneTextFrame",
    "PVPArenaTextFrame",
    "StatusTrackingBarManager",
    "TimeManagerClockButton",
    "MinimapZoneTextButton",
    "MinimapNorthTag",
    "MicroMenuContainer",
}
local cleanOriginalShow = {}

local function applyCleanMode(on)
    for _, name in ipairs(CLEAN_TARGETS) do
        local f = _G[name]
        if f then
            if on then
                if not cleanOriginalShow[name] then
                    cleanOriginalShow[name] = f.Show
                    f.Show = function() end -- neutralize Blizzard auto-show
                end
                if f.UnregisterAllEvents and f.RegisterEvent then
                    -- only unregister for hideable, non-secure frames
                    pcall(function() f:UnregisterAllEvents() end)
                end
                pcall(function() f:Hide() end)
            else
                if cleanOriginalShow[name] then
                    f.Show = cleanOriginalShow[name]
                    cleanOriginalShow[name] = nil
                end
                pcall(function() f:Show() end)
            end
        end
    end
    ResurgenceDB.cleanMode = on
end

----------------------------------------------------------------------
-- CHAT SKIN (re-styles existing chat frames without breaking them)
----------------------------------------------------------------------
local chatSkinned = false

local function applyChatSkin(on)
    -- Iterate all default chat frames (ChatFrame1 through 10).
    for i = 1, NUM_CHAT_WINDOWS or 10 do
        local cf = _G["ChatFrame" .. i]
        if cf then
            local edit = _G["ChatFrame" .. i .. "EditBox"]
            local tab  = _G["ChatFrame" .. i .. "Tab"]
            if on then
                -- Reskin background
                if not cf._resSkin then
                    local bg = cf:CreateTexture(nil, "BACKGROUND")
                    bg:SetAllPoints()
                    setBG(bg, C.bgDeep)
                    bg:SetAlpha(0.85)
                    cf._resSkinBg = bg
                    cf._resSkin = true
                else
                    if cf._resSkinBg then cf._resSkinBg:Show() end
                end
                -- Restyle edit box
                if edit then
                    if not edit._resSkin then
                        local ebbg = edit:CreateTexture(nil, "BACKGROUND")
                        ebbg:SetAllPoints()
                        setBG(ebbg, C.bg)
                        ebbg:SetAlpha(0.92)
                        edit._resSkinBg = ebbg
                        local top   = edit:CreateTexture(nil, "OVERLAY")
                        setBG(top, C.gold)
                        top:SetHeight(1)
                        top:SetPoint("TOPLEFT", 4, 0)
                        top:SetPoint("TOPRIGHT", -4, 0)
                        top:SetAlpha(0.6)
                        edit._resSkinLine = top
                        edit._resSkin = true
                    else
                        if edit._resSkinBg then edit._resSkinBg:Show() end
                        if edit._resSkinLine then edit._resSkinLine:Show() end
                    end
                end
            else
                if cf._resSkinBg then cf._resSkinBg:Hide() end
                if edit and edit._resSkinBg then edit._resSkinBg:Hide() end
                if edit and edit._resSkinLine then edit._resSkinLine:Hide() end
            end
        end
    end
    chatSkinned = on
    ResurgenceDB.chatSkin = on
end

----------------------------------------------------------------------
-- Auras tab content
----------------------------------------------------------------------
local function buildAurasContent(parent)
    local outer = makePanel(parent, { 0, 0, 0, 0 })
    outer:SetAllPoints()

    local header = makeText(outer, "Auras", "GameFontNormalHuge", C.gold)
    header:SetPoint("TOPLEFT", 24, -20)

    local sub = makeText(outer,
        "Procs and active buffs hand-picked for your class. Toggle individual entries below. The floating panel on your screen updates live.",
        "GameFontNormal", C.textMuted)
    sub:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -8)
    sub:SetWidth(660)
    sub:SetJustifyH("LEFT")

    -- Quick controls row
    local row = makePanel(outer, C.panel)
    row:SetHeight(40)
    row:SetPoint("TOPLEFT", sub, "BOTTOMLEFT", 0, -16)
    row:SetPoint("RIGHT", outer, "RIGHT", -28, 0)

    local lockBtn = makeButton(row, "Toggle Lock", 130, 26, C.cyan)
    lockBtn:SetPoint("LEFT", 10, 0)
    lockBtn:SetScript("OnClick", function()
        ResurgenceDB.aurasHudLocked = not ResurgenceDB.aurasHudLocked
        if state.aurasHUD then state.aurasHUD:ApplyLock() end
        local s = ResurgenceDB.aurasHudLocked and "locked" or "unlocked"
        print("|cffffd700[Resurgence]|r aura panel " .. s)
    end)

    local resetBtn = makeButton(row, "Reset position", 130, 26, C.gold)
    resetBtn:SetPoint("LEFT", lockBtn, "RIGHT", 8, 0)
    resetBtn:SetScript("OnClick", function()
        ResurgenceDB.aurasHudPos = { "CENTER", 0, -180 }
        if state.aurasHUD then
            state.aurasHUD:ClearAllPoints()
            state.aurasHUD:SetPoint("CENTER", UIParent, "CENTER", 0, -180)
        end
    end)

    local testBtn = makeButton(row, "Refresh", 100, 26, C.gold)
    testBtn:SetPoint("LEFT", resetBtn, "RIGHT", 8, 0)
    testBtn:SetScript("OnClick", function()
        if not state.aurasHUD then buildAurasHUD() end
        refreshAurasHUD()
        print("|cffffd700[Resurgence]|r refreshed")
    end)

    -- Class-filtered list
    local scroll = CreateFrame("ScrollFrame", nil, outer, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", row, "BOTTOMLEFT", 0, -12)
    scroll:SetPoint("BOTTOMRIGHT", -28, 14)

    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(660, 1)
    scroll:SetScrollChild(content)

    local class = getPlayerClass()
    local y = 0
    if not Resurgence_AuraDB then
        local err = makeText(content, "Aura library not loaded.", "GameFontNormal", C.textFaint)
        err:SetPoint("TOPLEFT", 4, -y)
        content:SetHeight(40)
        return outer
    end

    local count = 0
    for _, aura in ipairs(Resurgence_AuraDB) do
        if aura.class == class or aura.class == "ALL" then
            count = count + 1
            local card = makePanel(content, C.panel)
            card:SetHeight(50)
            card:SetPoint("TOPLEFT", 0, -y)
            card:SetPoint("RIGHT", content, "RIGHT", -8, 0)

            -- Priority bar
            local pbar = makeBorderLine(card,
                aura.priority == 1 and C.gold or (aura.priority == 2 and C.cyan or C.textFaint),
                3, "LEFT", 0)

            -- Spell icon
            local ic = card:CreateTexture(nil, "ARTWORK")
            ic:SetTexture(getSpellIcon(aura.spellID))
            ic:SetSize(34, 34)
            ic:SetPoint("LEFT", 14, 0)
            ic:SetTexCoord(0.08, 0.92, 0.08, 0.92)

            -- Name
            local name = makeText(card, aura.name, "GameFontNormalLarge", C.gold)
            name:SetPoint("TOPLEFT", ic, "TOPRIGHT", 12, -2)

            -- Tag + spec
            local meta_ = makeText(card,
                (aura.tag or "buff") .. (aura.spec and (" · " .. aura.spec) or ""),
                "GameFontDisableSmall", C.textMuted)
            meta_:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 0, -2)

            -- Toggle checkbox
            local cb = CreateFrame("CheckButton", nil, card, "UICheckButtonTemplate")
            cb:SetPoint("RIGHT", -14, 0)
            cb:SetSize(22, 22)
            cb:SetChecked(not (ResurgenceDB.aurasDisabled and ResurgenceDB.aurasDisabled[aura.id]))
            cb:SetScript("OnClick", function(self_)
                ResurgenceDB.aurasDisabled = ResurgenceDB.aurasDisabled or {}
                if self_:GetChecked() then
                    ResurgenceDB.aurasDisabled[aura.id] = nil
                else
                    ResurgenceDB.aurasDisabled[aura.id] = true
                end
                refreshAurasHUD()
            end)

            y = y + 50 + 6
        end
    end

    if count == 0 then
        local none = makeText(content, "No curated auras for your class yet. Drop an issue on GitHub if you'd like one added.",
            "GameFontHighlight", C.textMuted)
        none:SetPoint("TOPLEFT", 4, -8)
        none:SetWidth(620)
        y = 60
    end

    content:SetHeight(math.max(y, 1))
    return outer
end

----------------------------------------------------------------------
-- Tab dispatcher
----------------------------------------------------------------------
local TAB_BUILDERS = {
    welcome  = buildWelcomeContent,
    auras    = buildAurasContent,
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
-- ONBOARDING WIZARD (first-launch, replayable from /res setup)
-- Three-step setup that asks role, content focus, and modules, then
-- writes preferences into ResurgenceDB so the rest of the addon adapts.
----------------------------------------------------------------------
local WIZARD_STEPS = 3

local function buildWizardStepWelcome(parent)
    local p = makePanel(parent, { 0, 0, 0, 0 })
    p:SetAllPoints()
    p.logo = p:CreateTexture(nil, "ARTWORK")
    p.logo:SetTexture(LOGO_PATH)
    p.logo:SetSize(140, 140)
    p.logo:SetPoint("TOP", 0, -10)
    p.title = makeText(p, "Welcome to Resurgence", "GameFontNormalHuge", C.gold)
    p.title:SetPoint("TOP", p.logo, "BOTTOM", 0, -10)
    p.body = makeText(p, "", "GameFontNormal", C.text)
    p.body:SetPoint("TOP", p.title, "BOTTOM", 0, -16)
    p.body:SetWidth(540)
    p.body:SetJustifyH("CENTER")
    p.body:SetSpacing(4)
    p.body:SetText(
        "We'll set things up in three quick steps : your role, the content you play, " ..
        "and the modules you want enabled. Takes 30 seconds. " ..
        "Skip any step at any time and adjust later from the Settings tab.")
    p.skip = makeText(p, "You can replay this wizard any time with |cff80c0ff/res setup|r.",
        "GameFontDisableSmall", C.textFaint)
    p.skip:SetPoint("BOTTOM", 0, 16)
    return p
end

local function buildWizardStepRole(parent, refsOut)
    local p = makePanel(parent, { 0, 0, 0, 0 })
    p:SetAllPoints()
    local title = makeText(p, "What's your main role ?", "GameFontNormalHuge", C.gold)
    title:SetPoint("TOP", 0, -16)
    local sub = makeText(p,
        "We'll prioritize the procs and buffs that matter for that role first.",
        "GameFontNormal", C.textMuted)
    sub:SetPoint("TOP", title, "BOTTOM", 0, -6)

    -- Defensive : if the SavedVariables file pre-dates the v0.4.0 schema
    -- the ADDON_LOADED handler may not have run yet (rare but possible
    -- when the wizard is opened mid-load).
    ResurgenceDB.preferences = ResurgenceDB.preferences or {}
    ResurgenceDB.preferences.content = ResurgenceDB.preferences.content or {}
    ResurgenceDB.preferences.modules = ResurgenceDB.preferences.modules or {}

    refsOut.role = ResurgenceDB.preferences.role
    refsOut.contentSelected = refsOut.contentSelected or {}
    -- Pre-init from saved
    for _, c in ipairs({ "mythic+", "raid", "pvp", "world" }) do
        refsOut.contentSelected[c] = ResurgenceDB.preferences.content[c] or false
    end

    local roles = {
        { id = "dps",    label = "DPS",     desc = "Damage focus, all procs of all DPS specs" },
        { id = "healer", label = "Healer",  desc = "Healing-side procs and clearcasts" },
        { id = "tank",   label = "Tank",    desc = "Defensives, charge buffs, active mitigation" },
    }

    local startY = -90
    for i, r in ipairs(roles) do
        local btn = CreateFrame("Button", nil, p, "BackdropTemplate")
        btn:SetSize(540, 56)
        btn:SetPoint("TOP", 0, startY - (i - 1) * 64)
        btn.bg = btn:CreateTexture(nil, "BACKGROUND")
        btn.bg:SetAllPoints()
        setBG(btn.bg, C.panel)
        if btn.SetBackdrop then
            btn:SetBackdrop({
                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                edgeSize = 12,
                insets = { left = 2, right = 2, top = 2, bottom = 2 },
            })
            btn:SetBackdropBorderColor(rgb(C.panelHover))
        end
        local label = makeText(btn, r.label, "GameFontNormalLarge", C.gold)
        label:SetPoint("TOPLEFT", 18, -10)
        local desc = makeText(btn, r.desc, "GameFontHighlightSmall", C.text)
        desc:SetPoint("TOPLEFT", 18, -32)

        btn:SetScript("OnClick", function(self_)
            refsOut.role = r.id
            for _, b in ipairs(refsOut._roleButtons or {}) do
                if b.SetBackdropBorderColor then b:SetBackdropBorderColor(rgb(C.panelHover)) end
                setBG(b.bg, C.panel)
            end
            if self_.SetBackdropBorderColor then self_:SetBackdropBorderColor(rgb(C.gold)) end
            setBG(self_.bg, C.panelHover)
        end)
        refsOut._roleButtons = refsOut._roleButtons or {}
        table.insert(refsOut._roleButtons, btn)
        if refsOut.role == r.id then
            if btn.SetBackdropBorderColor then btn:SetBackdropBorderColor(rgb(C.gold)) end
            setBG(btn.bg, C.panelHover)
        end
    end

    -- Content checkboxes
    local cTitle = makeText(p, "What content do you mostly do ?",
        "GameFontNormalLarge", C.cyan)
    cTitle:SetPoint("TOP", 0, startY - (#roles * 64) - 12)

    local contentOptions = {
        { id = "mythic+", label = "Mythic+ Dungeons" },
        { id = "raid",    label = "Raids" },
        { id = "pvp",     label = "PvP (Arenas / BGs)" },
        { id = "world",   label = "World Content / Levelling" },
    }
    local cy = startY - (#roles * 64) - 48
    for i, opt in ipairs(contentOptions) do
        local cb = CreateFrame("CheckButton", nil, p, "UICheckButtonTemplate")
        cb:SetSize(28, 28)
        local col = (i - 1) % 2
        local rowi = math.floor((i - 1) / 2)
        cb:SetPoint("TOPLEFT", 80 + col * 240, cy - rowi * 32)
        cb:SetChecked(refsOut.contentSelected[opt.id] or false)
        cb:SetScript("OnClick", function(self_)
            refsOut.contentSelected[opt.id] = self_:GetChecked() and true or false
        end)
        local cbLabel = makeText(p, opt.label, "GameFontHighlight", C.text)
        cbLabel:SetPoint("LEFT", cb, "RIGHT", 6, 0)
    end

    return p
end

local function buildWizardStepModules(parent, refsOut)
    local p = makePanel(parent, { 0, 0, 0, 0 })
    p:SetAllPoints()
    local title = makeText(p, "Pick your modules", "GameFontNormalHuge", C.gold)
    title:SetPoint("TOP", 0, -16)
    local sub = makeText(p,
        "Enable what you want now. You can flip these any time from the Settings tab.",
        "GameFontNormal", C.textMuted)
    sub:SetPoint("TOP", title, "BOTTOM", 0, -6)

    -- Defensive guard against a stale SavedVariables schema
    ResurgenceDB.preferences = ResurgenceDB.preferences or {}
    ResurgenceDB.preferences.modules = ResurgenceDB.preferences.modules or {}

    refsOut.modules = refsOut.modules or {}
    -- Pre-init from saved or defaults (auras + buffs default ON)
    local prevModules = ResurgenceDB.preferences.modules or {}
    refsOut.modules.auras = (prevModules.auras ~= false) and true or false
    refsOut.modules.buffs = (prevModules.buffs ~= false) and true or false

    local modules = {
        {
            id = "auras",
            label = "Personal Auras",
            desc = "Floating panel with the procs and active buffs that matter for your spec. Live.",
            recommended = true,
        },
        {
            id = "buffs",
            label = "World Buffs HUD",
            desc = "On-screen window with countdowns of every active world event. Click to track with native arrow.",
            recommended = true,
        },
        {
            id = "group",
            label = "Group Awareness",
            desc = "Cooldowns of your party / raid in real time. Coming in v0.5.",
            disabled = true,
        },
        {
            id = "combat",
            label = "Combat Insights",
            desc = "Live damage, healing, threat, top spell. Coming in v0.6.",
            disabled = true,
        },
    }

    local startY = -90
    for i, m in ipairs(modules) do
        local row = makePanel(p, C.panel)
        row:SetSize(540, 60)
        row:SetPoint("TOP", 0, startY - (i - 1) * 68)

        local cb = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
        cb:SetSize(28, 28)
        cb:SetPoint("LEFT", 12, 0)
        cb:SetChecked(refsOut.modules[m.id] or false)
        if m.disabled then
            cb:SetEnabled(false)
            cb:SetAlpha(0.4)
            cb:SetChecked(false)
        else
            cb:SetScript("OnClick", function(self_)
                refsOut.modules[m.id] = self_:GetChecked() and true or false
            end)
        end

        local label = makeText(row, m.label, "GameFontNormalLarge",
            m.disabled and C.textFaint or C.gold)
        label:SetPoint("TOPLEFT", cb, "TOPRIGHT", 12, 0)

        if m.recommended then
            local rec = makeText(row, " · recommended", "GameFontDisableSmall", C.cyan)
            rec:SetPoint("LEFT", label, "RIGHT", 4, 0)
        end

        local desc = makeText(row, m.desc, "GameFontHighlightSmall",
            m.disabled and C.textFaint or C.text)
        desc:SetPoint("TOPLEFT", cb, "BOTTOMRIGHT", 12, 8)
        desc:SetPoint("RIGHT", row, "RIGHT", -10, 0)
        desc:SetJustifyH("LEFT")
    end

    return p
end

local function buildOnboardingWizard()
    if state.welcomePopup then return state.welcomePopup end

    local P = CreateFrame("Frame", nil, UIParent)
    P:SetSize(620, 600)
    P:SetPoint("CENTER", 0, 40)
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

    -- Header progress bar
    local progressTrack = inner:CreateTexture(nil, "OVERLAY")
    setBG(progressTrack, C.panelHover)
    progressTrack:SetHeight(3)
    progressTrack:SetPoint("TOPLEFT", 0, -0)
    progressTrack:SetPoint("TOPRIGHT", 0, 0)
    local progressFill = inner:CreateTexture(nil, "OVERLAY")
    setBG(progressFill, C.cyan)
    progressFill:SetHeight(3)
    progressFill:SetPoint("TOPLEFT", 0, 0)
    progressFill:SetWidth(0)

    -- Step content area
    local contentArea = makePanel(inner, { 0, 0, 0, 0 })
    contentArea:SetPoint("TOPLEFT", 16, -32)
    contentArea:SetPoint("BOTTOMRIGHT", -16, 64)

    -- Buttons row
    local btnBack = makeButton(inner, "Back", 110, 32, C.textMuted)
    btnBack:SetPoint("BOTTOMLEFT", 16, 16)

    local btnSkip = makeButton(inner, "Skip", 110, 32, C.textFaint)
    btnSkip:SetPoint("BOTTOM", -70, 16)

    local btnNext = makeButton(inner, "Next", 140, 32, C.gold)
    btnNext:SetPoint("BOTTOMRIGHT", -16, 16)

    -- Step state
    local refs = {}
    local step = 1
    local stepFrames = {}

    local function renderStep()
        for _, f in pairs(stepFrames) do f:Hide() end
        if not stepFrames[step] then
            if step == 1 then
                stepFrames[step] = buildWizardStepWelcome(contentArea)
            elseif step == 2 then
                stepFrames[step] = buildWizardStepRole(contentArea, refs)
            elseif step == 3 then
                stepFrames[step] = buildWizardStepModules(contentArea, refs)
            end
        end
        if stepFrames[step] then stepFrames[step]:Show() end

        progressFill:SetWidth((P:GetWidth() - 4) * (step / WIZARD_STEPS))

        if step == 1 then
            btnBack:Hide()
        else
            btnBack:Show()
        end

        if step == WIZARD_STEPS then
            btnNext.label:SetText("Finish setup")
        else
            btnNext.label:SetText("Next  >")
        end
    end

    btnBack:SetScript("OnClick", function()
        if step > 1 then step = step - 1 end
        renderStep()
    end)

    btnSkip:SetScript("OnClick", function()
        ResurgenceDB.setupDone = true
        ResurgenceDB.welcomed = true
        P:Hide()
        print("|cffffd700[Resurgence]|r setup skipped. Use |cff80c0ff/res setup|r to run it later.")
    end)

    btnNext:SetScript("OnClick", function()
        if step < WIZARD_STEPS then
            step = step + 1
            renderStep()
        else
            -- Save preferences
            ResurgenceDB.preferences = ResurgenceDB.preferences or {}
            ResurgenceDB.preferences.role    = refs.role
            ResurgenceDB.preferences.content = refs.contentSelected or {}
            ResurgenceDB.preferences.modules = refs.modules or {}
            ResurgenceDB.setupDone = true
            ResurgenceDB.welcomed = true

            -- Apply : open the buffs HUD if user enabled the module
            if refs.modules and refs.modules.buffs and showBuffsHUD then
                ResurgenceDB.buffsHudOpen = true
                showBuffsHUD()
            end
            -- Refresh auras HUD if module enabled
            if refs.modules and refs.modules.auras then
                if not state.aurasHUD then buildAurasHUD() end
                refreshAurasHUD()
            end

            P:Hide()
            print(string.format(
                "|cffffd700[Resurgence]|r setup complete. Role : |cff80c0ff%s|r. Modules : |cff80c0ff%s|r. Click the logo any time.",
                tostring(refs.role or "any"),
                table.concat(
                    (function()
                        local list = {}
                        for k, v in pairs(refs.modules or {}) do
                            if v then table.insert(list, k) end
                        end
                        return list
                    end)(),
                    ", "
                )
            ))
        end
    end)

    -- Close X
    P.close = CreateFrame("Button", nil, inner, "UIPanelCloseButton")
    P.close:SetPoint("TOPRIGHT", -2, -2)
    P.close:SetScript("OnClick", function()
        ResurgenceDB.setupDone = true
        ResurgenceDB.welcomed = true
        P:Hide()
    end)

    -- Render the first step now (otherwise the content area is empty until
    -- the user clicks Next, which is the bug we just shipped).
    renderStep()

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
    local P = buildOnboardingWizard()
    P:Show()
end

function ResurgenceUI_StartSetup()
    -- Force the wizard to fully reset and replay
    if state.welcomePopup then
        state.welcomePopup:Hide()
        state.welcomePopup = nil
    end
    ResurgenceDB.setupDone = false
    local P = buildOnboardingWizard()
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
            if ResurgenceDB.setupDone      == nil then ResurgenceDB.setupDone      = false end
            if ResurgenceDB.aurasHudLocked == nil then ResurgenceDB.aurasHudLocked = false end
            ResurgenceDB.launcherPos    = ResurgenceDB.launcherPos    or { "RIGHT", -8, 80 }
            ResurgenceDB.windowPos      = ResurgenceDB.windowPos      or { "CENTER", 0, 40 }
            ResurgenceDB.lastTab        = ResurgenceDB.lastTab        or "welcome"
            ResurgenceDB.buffsHudPos    = ResurgenceDB.buffsHudPos    or { "TOPRIGHT", -260, -260 }
            ResurgenceDB.aurasHudPos    = ResurgenceDB.aurasHudPos    or { "CENTER", 0, -180 }
            ResurgenceDB.preferences    = ResurgenceDB.preferences    or {}
            ResurgenceDB.preferences.content = ResurgenceDB.preferences.content or {}
            ResurgenceDB.preferences.modules = ResurgenceDB.preferences.modules or {}
            ResurgenceDB.aurasEnabled   = ResurgenceDB.aurasEnabled   or {}
            ResurgenceDB.aurasDisabled  = ResurgenceDB.aurasDisabled  or {}
            if ResurgenceDB.cleanMode == nil then ResurgenceDB.cleanMode = false end
            if ResurgenceDB.xpBar     == nil then ResurgenceDB.xpBar     = true  end
            if ResurgenceDB.chatSkin  == nil then ResurgenceDB.chatSkin  = false end
            ResurgenceDB.xpBarPos = ResurgenceDB.xpBarPos or { "TOP", 0, -8 }
        end
    elseif event == "PLAYER_LOGIN" then
        buildLauncher()
        if ResurgenceDB.buffsHudOpen then
            C_Timer.After(0.5, function() showBuffsHUD() end)
        end
        -- Build aura HUD if module is enabled
        if isAurasModuleEnabled() then
            C_Timer.After(0.6, function()
                buildAurasHUD()
                refreshAurasHUD()
            end)
        end
        -- XP bar
        if ResurgenceDB.xpBar then
            C_Timer.After(0.7, function() showXpBar() end)
        end
        -- Clean Mode
        if ResurgenceDB.cleanMode then
            C_Timer.After(0.8, function() applyCleanMode(true) end)
        end
        -- Chat skin
        if ResurgenceDB.chatSkin then
            C_Timer.After(0.9, function() applyChatSkin(true) end)
        end
        -- First-launch onboarding wizard
        if not ResurgenceDB.setupDone then
            C_Timer.After(2.0, function()
                ResurgenceUI_ShowWelcome()
            end)
        end
        print(string.format(
            "|cffffd700[Resurgence]|r v%s loaded. Click the logo, or use |cff80c0ff/res|r.",
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
    elseif cmd == "welcome" or cmd == "setup" then
        ResurgenceUI_StartSetup()
    elseif cmd == "auras" then
        ResurgenceUI_OpenTab("auras")
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
        print("  |cff80c0ff/res setup|r        replay the onboarding wizard")
        print("  |cff80c0ff/res auras|r        open Auras tab")
        print("  |cff80c0ff/res buffs|r        toggle the floating World Buffs HUD")
        print("  |cff80c0ff/res show / hide|r  toggle the on-screen launcher button")
        print("  |cff80c0ff/res roadmap|r      open Roadmap tab")
        print("  |cff80c0ff/res about|r        open About tab")
        print("  |cff80c0ff/res settings|r     open Settings tab")
        print("  |cff80c0ff/res support|r      open Support / Links tab")
        print("  |cff80c0ff/res reset|r        reset launcher and window positions")
    else
        print("|cffffd700[Resurgence]|r unknown. |cff80c0ff/res help|r for commands")
    end
end
