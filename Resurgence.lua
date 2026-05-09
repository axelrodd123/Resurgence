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

----------------------------------------------------------------------
-- Tab definitions
----------------------------------------------------------------------
local TABS = {
    { id = "welcome",  label = "Welcome" },
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
        ver = "0.2.0-alpha", status = "current",
        title = "UI Shell",
        body = "The visual foundation : welcome screen, on-screen launcher, roadmap and info tabs. The brand and design system ship first; the engine ships next.",
        items = {
            "Welcome window with onboarding flow",
            "Draggable on-screen launcher button",
            "Roadmap, About, Support, Settings tabs",
            "Persistent positions and preferences",
        },
    },
    {
        ver = "0.3.0", status = "planned",
        title = "Aura Engine",
        body = "The reason this addon exists. Track the procs and buffs that matter, with the polish WeakAuras gave us before it broke in 12.0.x.",
        items = {
            "28+ curated procs and buffs across 13 classes",
            "Glow border, cooldown sweep, countdown numbers",
            "Per-aura toggle from Settings",
            "Drag-and-drop layout, position persisted",
        },
    },
    {
        ver = "0.4.0", status = "planned",
        title = "Party CDs Module",
        body = "PartyCD becomes a Resurgence module. Track every group member's cooldowns from one unified config.",
        items = {
            "49 spells across all classes",
            "Color-coded categories : defensive, interrupt, utility, combat res",
            "Real-time tracking via UNIT_SPELLCAST_SUCCEEDED (12.0.x safe)",
        },
    },
    {
        ver = "0.5.0", status = "planned",
        title = "Combat Info",
        body = "Lightweight Details replacement. Damage done, healing done, top spell, threat. Just enough to know what is happening.",
        items = {
            "Per-fight DPS / HPS / damage taken",
            "Top spell breakdown",
            "Multi-window support",
        },
    },
    {
        ver = "0.6.0", status = "future",
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
        body = "For power users who used to write their own WAs. A focused, opinionated editor without the legacy bloat.",
        items = {
            "Visual trigger builder",
            "Import / export aura strings",
            "Community trigger library",
        },
    },
}

local STATUS_COLORS = {
    current = C.cyan,
    planned = C.gold,
    future  = C.textFaint,
}
local STATUS_LABELS = {
    current = "NOW",
    planned = "NEXT",
    future  = "LATER",
}

----------------------------------------------------------------------
-- State
----------------------------------------------------------------------
local state = {
    launcher = nil,
    window = nil,
    welcomePopup = nil,
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

    local p = ResurgenceDB.launcherPos
    L:SetPoint(p[1] or "RIGHT", UIParent, p[1] or "RIGHT", p[2] or -8, p[3] or 80)

    -- Soft drop shadow
    L.shadow = L:CreateTexture(nil, "BACKGROUND")
    L.shadow:SetTexture(LOGO_PATH)
    L.shadow:SetPoint("CENTER", 1, -1)
    L.shadow:SetSize(46, 46)
    L.shadow:SetVertexColor(0, 0, 0, 0.7)

    -- Main icon
    L.icon = L:CreateTexture(nil, "ARTWORK")
    L.icon:SetTexture(LOGO_PATH)
    L.icon:SetAllPoints()

    -- Hover ring
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
        GameTooltip:AddLine("|cffaaaaaaShift drag|r   move this button", 0.7, 0.85, 1)
        GameTooltip:AddLine("|cffaaaaaaRight click|r  hide for this session", 0.7, 0.85, 1)
        GameTooltip:Show()
    end)
    L:SetScript("OnLeave", function(self)
        UIFrameFadeOut(self.ring, 0.20, self.ring:GetAlpha(), 0)
        GameTooltip:Hide()
    end)

    L:SetScript("OnDragStart", function(self)
        if IsShiftKeyDown() then self:StartMoving() end
    end)
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
        "WeakAuras-style addons rebuilt for the 12.0.x Midnight era.",
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
        "While WeakAuras, OmniCD, Plater and Details were broken or stalled by Blizzard's tighter security in Midnight 12.0.x, this is a from-scratch rewrite that uses only the new safe APIs. No tainted combat log handlers. No protected hooks. Just the addons we used to love, working again.\n\n" ..
        "This v0.2.0 ships the visual shell. The engine arrives in v0.3.0. Browse the |cff80c0ffRoadmap|r tab to see what's coming and when.")

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
        "WoW had a problem in 12.0.x : the addons that defined modern raiding all stopped working.\n\n" ..
        "WeakAuras went silent. OmniCD got renamed and stayed half-broken. Plater lost its profile system. Details stopped showing useful information mid-fight. Altoholic never updated. The community got loud, the maintainers got quiet, and players returning to Midnight felt like the UI got worse.\n\n" ..
        "Resurgence is the answer. Each module is a from-scratch rewrite that uses only the safe APIs. No |cff80c0ffCOMBAT_LOG_EVENT_UNFILTERED|r. No protected hooks. No |cff80c0ffhooksecurefunc|r on |cff80c0ffStaticPopup_Show|r. No stuff that triggers ADDON_ACTION_FORBIDDEN at engine level.\n\n" ..
        "What you get is a small, focused, lightweight tool that does what the legacy giants used to do, designed by someone who actually plays the game and got tired of waiting for the maintainers to come back.\n\n" ..
        "|cffd0d0d0Built with care. Released with a roadmap. Maintained with bots.|r")

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
-- Tab dispatcher
----------------------------------------------------------------------
local TAB_BUILDERS = {
    welcome  = buildWelcomeContent,
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

    local p = ResurgenceDB.windowPos
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
        "WeakAuras-style addons rebuilt for the 12.0.x era",
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
        "WeakAuras-style addons rebuilt for the 12.0.x era",
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
            ResurgenceDB = ResurgenceDB or {}
        end
    elseif event == "PLAYER_LOGIN" then
        buildLauncher()
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
        print("  |cff80c0ff/res reset|r        reset launcher and window positions")
    else
        print("|cffffd700[Resurgence]|r unknown. |cff80c0ff/res help|r for commands")
    end
end
