local ADDON_NAME = ...

local function meta(k)
    if C_AddOns and C_AddOns.GetAddOnMetadata then
        return C_AddOns.GetAddOnMetadata(ADDON_NAME, k)
    end
    return GetAddOnMetadata and GetAddOnMetadata(ADDON_NAME, k) or nil
end
local ADDON_VERSION = meta("Version") or "?"

----------------------------------------------------------------------
-- DB / state
----------------------------------------------------------------------
ResurgenceDB = ResurgenceDB or {}
ResurgenceDB.disabled = ResurgenceDB.disabled or {}
ResurgenceDB.position = ResurgenceDB.position or { "CENTER", "UIParent", "CENTER", 0, -200 }
ResurgenceDB.locked = (ResurgenceDB.locked == nil) and true or ResurgenceDB.locked
ResurgenceDB.scale = ResurgenceDB.scale or 1.0

local state = {
    playerClass = nil,
    activeAuras = {},      -- list of aura defs for this character's class
    icons = {},            -- aura.id -> icon frame
    mainFrame = nil,
}

----------------------------------------------------------------------
-- Helpers
----------------------------------------------------------------------
local function getSpellIcon(spellID)
    if C_Spell and C_Spell.GetSpellInfo then
        local info = C_Spell.GetSpellInfo(spellID)
        if info and info.iconID then return info.iconID end
    end
    if GetSpellTexture then return GetSpellTexture(spellID) end
    if GetSpellInfo then
        local _, _, icon = GetSpellInfo(spellID)
        return icon
    end
    return 134400
end

local function getSpellName(spellID, fallback)
    if C_Spell and C_Spell.GetSpellInfo then
        local info = C_Spell.GetSpellInfo(spellID)
        if info and info.name then return info.name end
    end
    if GetSpellInfo then
        local n = GetSpellInfo(spellID)
        if n then return n end
    end
    return fallback or ("spell:" .. tostring(spellID))
end

local function playerHasBuff(spellID)
    if C_UnitAuras and C_UnitAuras.GetPlayerAuraBySpellID then
        local aura = C_UnitAuras.GetPlayerAuraBySpellID(spellID)
        if aura then return true, aura.expirationTime or 0, aura.duration or 0 end
        return false
    end
    -- Legacy fallback : iterate
    for i = 1, 40 do
        if AuraUtil and AuraUtil.FindAuraBySpellID then
            local aura = AuraUtil.FindAuraBySpellID(spellID, "player", "HELPFUL")
            if aura then return true, aura.expirationTime or 0, aura.duration or 0 end
            return false
        end
    end
    return false
end

----------------------------------------------------------------------
-- Icon factory
----------------------------------------------------------------------
local ICON_SIZE = 56

local function makeIcon(parent, aura)
    local f = CreateFrame("Frame", nil, parent)
    f:SetSize(ICON_SIZE, ICON_SIZE)
    f:Hide()

    f.bg = f:CreateTexture(nil, "BACKGROUND")
    f.bg:SetPoint("TOPLEFT", -2, 2)
    f.bg:SetPoint("BOTTOMRIGHT", 2, -2)
    f.bg:SetColorTexture(0, 0, 0, 0.6)

    f.tex = f:CreateTexture(nil, "ARTWORK")
    f.tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    f.tex:SetAllPoints()
    f.tex:SetTexture(getSpellIcon(aura.spellID))

    -- Glow border (overlay texture for the active state)
    f.glow = f:CreateTexture(nil, "OVERLAY")
    f.glow:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
    f.glow:SetBlendMode("ADD")
    f.glow:SetAlpha(0)
    f.glow:SetPoint("TOPLEFT", -10, 10)
    f.glow:SetPoint("BOTTOMRIGHT", 10, -10)
    f.glow:SetVertexColor(1.0, 0.85, 0.2)

    -- Cooldown frame (for showing remaining time as a sweep)
    f.cd = CreateFrame("Cooldown", nil, f, "CooldownFrameTemplate")
    f.cd:SetAllPoints()
    f.cd:SetSwipeColor(0, 0, 0, 0.55)
    f.cd:SetDrawEdge(true)
    f.cd:SetHideCountdownNumbers(false)

    f.aura = aura

    -- Tooltip
    f:EnableMouse(true)
    f:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(getSpellName(aura.spellID, aura.name), 1, 0.85, 0.2)
        if aura.spec then
            GameTooltip:AddLine(aura.class .. " : " .. aura.spec, 0.7, 0.7, 0.7)
        else
            GameTooltip:AddLine(aura.class, 0.7, 0.7, 0.7)
        end
        GameTooltip:AddLine("Resurgence", 0.5, 0.6, 1)
        GameTooltip:Show()
    end)
    f:SetScript("OnLeave", function() GameTooltip:Hide() end)

    return f
end

local function pulseGlow(icon)
    -- Quick fade-in then sustained alpha while active.
    icon.glow:SetAlpha(1)
    icon:SetAlpha(0.4)
    UIFrameFadeIn(icon, 0.18, icon:GetAlpha(), 1.0)
end

local function showAuraActive(icon, expirationTime, duration)
    icon:Show()
    pulseGlow(icon)
    if duration and duration > 0 and expirationTime and expirationTime > 0 then
        local startTime = expirationTime - duration
        icon.cd:SetCooldown(startTime, duration)
    else
        icon.cd:Clear()
    end
end

local function hideAuraActive(icon)
    icon.glow:SetAlpha(0)
    icon.cd:Clear()
    UIFrameFadeOut(icon, 0.18, icon:GetAlpha(), 0)
    C_Timer.After(0.20, function()
        if icon.glow:GetAlpha() == 0 then icon:Hide() end
    end)
end

----------------------------------------------------------------------
-- Main frame (anchor for the icon row)
----------------------------------------------------------------------
local function buildMainFrame()
    if state.mainFrame then return state.mainFrame end

    local f = CreateFrame("Frame", nil, UIParent)
    f:SetSize(800, ICON_SIZE + 40)
    local p = ResurgenceDB.position
    f:SetPoint(p[1] or "CENTER", UIParent, p[3] or "CENTER", p[4] or 0, p[5] or -200)
    f:SetMovable(true)
    f:EnableMouse(false)
    f:SetClampedToScreen(true)
    f:SetFrameStrata("MEDIUM")
    f:SetScale(ResurgenceDB.scale)

    -- Title (only visible when unlocked)
    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    f.title:SetPoint("TOP", 0, 18)
    f.title:SetText("|cffffd200Resurgence|r |cff707080(drag to move)|r")
    f.title:Hide()

    -- Drag handle background (visible when unlocked)
    f.handle = f:CreateTexture(nil, "BACKGROUND")
    f.handle:SetAllPoints()
    f.handle:SetColorTexture(0, 0.2, 0.4, 0.20)
    f.handle:Hide()

    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", function(self)
        if not ResurgenceDB.locked then self:StartMoving() end
    end)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local p1, _, p3, x, y = self:GetPoint()
        ResurgenceDB.position = { p1, "UIParent", p3, x, y }
    end)

    state.mainFrame = f
    return f
end

local function applyLockState()
    local f = state.mainFrame
    if not f then return end
    if ResurgenceDB.locked then
        f:EnableMouse(false)
        f.title:Hide()
        f.handle:Hide()
    else
        f:EnableMouse(true)
        f.title:Show()
        f.handle:Show()
    end
end

----------------------------------------------------------------------
-- Engine : layout + activity check
----------------------------------------------------------------------
local function buildIconsForClass()
    state.activeAuras = {}
    if not Resurgence_AuraDB then return end
    for _, aura in ipairs(Resurgence_AuraDB) do
        if (not aura.class) or aura.class == state.playerClass then
            if not ResurgenceDB.disabled[aura.id] then
                table.insert(state.activeAuras, aura)
            end
        end
    end
end

local function layoutIcons()
    local main = buildMainFrame()
    -- Hide all icons first
    for _, icon in pairs(state.icons) do icon:Hide() end

    local x = 0
    for _, aura in ipairs(state.activeAuras) do
        local icon = state.icons[aura.id]
        if not icon then
            icon = makeIcon(main, aura)
            state.icons[aura.id] = icon
        end
        icon:ClearAllPoints()
        icon:SetPoint("LEFT", main, "LEFT", x + 20, 0)
        x = x + ICON_SIZE + 8
        -- Don't Show() here : visibility is driven by buff presence.
    end
    main:SetWidth(math.max(800, x + 40))
end

local function refreshAuraStates()
    for _, aura in ipairs(state.activeAuras) do
        local icon = state.icons[aura.id]
        if icon then
            local has, exp, dur = playerHasBuff(aura.spellID)
            if has and not icon._active then
                showAuraActive(icon, exp, dur)
                icon._active = true
            elseif (not has) and icon._active then
                hideAuraActive(icon)
                icon._active = false
            end
        end
    end
end

----------------------------------------------------------------------
-- Events
-- We deliberately avoid COMBAT_LOG_EVENT_UNFILTERED, ADDON_ACTION_BLOCKED
-- and ADDON_ACTION_FORBIDDEN : registering those triggered an in-game popup
-- on retail 12.0.x in our previous addon. UNIT_AURA + SPELL_UPDATE_USABLE
-- give us everything we need for buff / proc tracking.
----------------------------------------------------------------------
local handler = CreateFrame("Frame")
handler:RegisterEvent("ADDON_LOADED")
handler:RegisterEvent("PLAYER_LOGIN")
handler:RegisterEvent("PLAYER_ENTERING_WORLD")
handler:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
handler:RegisterUnitEvent("UNIT_AURA", "player")

handler:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local n = ...
        if n == ADDON_NAME then
            ResurgenceDB = ResurgenceDB or {}
            ResurgenceDB.disabled = ResurgenceDB.disabled or {}
            ResurgenceDB.position = ResurgenceDB.position or { "CENTER", "UIParent", "CENTER", 0, -200 }
            if ResurgenceDB.locked == nil then ResurgenceDB.locked = true end
            ResurgenceDB.scale = ResurgenceDB.scale or 1.0
        end
    elseif event == "PLAYER_LOGIN" then
        local _, class = UnitClass("player")
        state.playerClass = class
        buildIconsForClass()
        layoutIcons()
        applyLockState()
        refreshAuraStates()
        print(string.format(
            "|cffffd200[Resurgence]|r v%s loaded. %d aura(s) tracked for your class. |cff80c0ff/res|r for commands.",
            ADDON_VERSION, #state.activeAuras))
    elseif event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_SPECIALIZATION_CHANGED" then
        if state.playerClass then
            buildIconsForClass()
            layoutIcons()
            refreshAuraStates()
        end
    elseif event == "UNIT_AURA" then
        local unit = ...
        if unit == "player" then
            refreshAuraStates()
        end
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

    if cmd == "lock" then
        ResurgenceDB.locked = true
        applyLockState()
        print("|cffffd200[Resurgence]|r locked")
    elseif cmd == "unlock" then
        ResurgenceDB.locked = false
        applyLockState()
        print("|cffffd200[Resurgence]|r unlocked, drag the panel to move")
    elseif cmd == "test" then
        for _, icon in pairs(state.icons) do
            showAuraActive(icon, GetTime() + 8, 8)
            icon._active = true
        end
        print("|cffffd200[Resurgence]|r preview : all auras shown for 8s")
        C_Timer.After(8.5, function() refreshAuraStates() end)
    elseif cmd == "list" then
        print("|cffffd200[Resurgence]|r tracking " .. #state.activeAuras .. " aura(s) for " .. tostring(state.playerClass) .. " :")
        for _, aura in ipairs(state.activeAuras) do
            print(string.format("  |cff80c0ff%s|r  -  %s", aura.id, aura.name))
        end
    elseif cmd == "off" then
        if arg ~= "" then
            ResurgenceDB.disabled[arg] = true
            buildIconsForClass()
            layoutIcons()
            refreshAuraStates()
            print("|cffffd200[Resurgence]|r disabled : " .. arg)
        else
            print("|cffffd200[Resurgence]|r usage : /res off <id>")
        end
    elseif cmd == "on" then
        if arg ~= "" then
            ResurgenceDB.disabled[arg] = nil
            buildIconsForClass()
            layoutIcons()
            refreshAuraStates()
            print("|cffffd200[Resurgence]|r enabled : " .. arg)
        else
            print("|cffffd200[Resurgence]|r usage : /res on <id>")
        end
    elseif cmd == "scale" then
        local n = tonumber(arg)
        if n and n >= 0.5 and n <= 2.5 then
            ResurgenceDB.scale = n
            if state.mainFrame then state.mainFrame:SetScale(n) end
            print(string.format("|cffffd200[Resurgence]|r scale : %.2f", n))
        else
            print("|cffffd200[Resurgence]|r usage : /res scale <0.5 to 2.5>")
        end
    elseif cmd == "reset" then
        ResurgenceDB.disabled = {}
        ResurgenceDB.position = { "CENTER", "UIParent", "CENTER", 0, -200 }
        ResurgenceDB.locked = true
        ResurgenceDB.scale = 1.0
        if state.mainFrame then
            state.mainFrame:ClearAllPoints()
            state.mainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, -200)
            state.mainFrame:SetScale(1.0)
        end
        buildIconsForClass()
        layoutIcons()
        applyLockState()
        refreshAuraStates()
        print("|cffffd200[Resurgence]|r settings reset")
    elseif cmd == "" or cmd == "help" then
        print("|cffffd200[Resurgence]|r v" .. ADDON_VERSION .. " commands :")
        print("  |cff80c0ff/res unlock|r / |cff80c0ff/res lock|r  drag mode")
        print("  |cff80c0ff/res test|r       preview all icons for 8s")
        print("  |cff80c0ff/res list|r       list tracked auras for your class")
        print("  |cff80c0ff/res off <id>|r   disable a specific aura by id")
        print("  |cff80c0ff/res on <id>|r    re-enable a previously disabled aura")
        print("  |cff80c0ff/res scale <n>|r  resize the panel (0.5 to 2.5)")
        print("  |cff80c0ff/res reset|r      restore default settings")
    else
        print("|cffffd200[Resurgence]|r unknown. |cff80c0ff/res help|r")
    end
end
