--- Core.lua
-- Main addon initialization and frame management

local addonName, addon = ...

local Blizzkili = LibStub("AceAddon-3.0"):GetAddon("Blizzkili", true)

local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Blizzkili", true)
local UILib = LibStub("Blizzkili-UILib")
local BlizzardAPI = LibStub("Blizzkili-BlizzardAPI")
local ActionBarScanner = LibStub("Blizzkili-ActionBarScanner")
local ButtonLib = LibStub("Blizzkili-ButtonLib")
local Options = LibStub("Blizzkili-Options")
local Rotation = LibStub("Blizzkili-Rotation")
local SimCPriorities = LibStub("Blizzkili-SimCPriorities")
local Debug = LibStub("Blizzkili-Debug")
local error = function(msg) Debug.Error(Blizzkili.db.profile, msg) end
local info = function(msg) Debug.Info(Blizzkili.db.profile, msg) end
local trace = function(msg) Debug.Trace(Blizzkili.db.profile, msg) end

-- Initialize the addon
function Blizzkili:OnInitialize()
    -- Register the database
    self.db = LibStub("AceDB-3.0"):New("BlizzkiliDB", self.defaults, true)

    -- Register slash commands
    Blizzkili:RegisterChatCommand(addon.longName:lower(), "SlashCommand")
    Blizzkili:RegisterChatCommand(addon.shortName:lower(), "SlashCommand")
    Blizzkili:RegisterChatCommand("hekili", "SlashCommand")

    ActionBarScanner:OnInitialize()
    Options:SetupOptions()
    -- Print initialization message
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00["..addon.shortName.."]|r ".. addon.longName .." v".. addon.version .. " - |cff00ff00/".. addon.shortName:lower() .. "|r")
end

-- Enable the addon
function Blizzkili:OnEnable()
    -- Register events after initialization
    ActionBarScanner:OnEnable()
    self:RegisterEvent("PLAYER_LOGIN", "OnLogin")
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "PlayerEnteringWorld")
    self:RegisterEvent("ZONE_CHANGED", "PlayerEnteringWorld")
    self:RegisterEvent("ZONE_CHANGED_INDOORS", "PlayerEnteringWorld")
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "PlayerEnteringWorld")
    self:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED", "PlayerEnteringWorld")
    self:RegisterEvent("ACTIONBAR_SLOT_CHANGED", "ActionbarChanged")
    self:RegisterEvent("PLAYER_REGEN_ENABLED", "OutOfCombat")
    self:RegisterEvent("PLAYER_REGEN_DISABLED", "InCombat")
    self:RegisterEvent("UNIT_AURA", "OnUnitAura")
end

-- Handle player login
function Blizzkili:OnLogin()
    info("Player logged in,")
    self.isInitalized = false
end

-- Update OnUnitAura
-- TODO Fires alot might not be needed
function Blizzkili:OnUnitAura(unit)
    -- if unit == "player" then
    --     self:UpdateRotation()
    -- end
end

-- PlayerEnteringWorld event handler
function Blizzkili:PlayerEnteringWorld()
    info("Player entering world")
    -- Initialize the UI
    if not self.isInitialized then
        UILib.CreateUI()
        self.isInitialized = true
    end
    UILib.UpdateButtons()
    -- Lock or unlock the frame
    self:UpdateFrameLock()
    if self.ticker then
        self.ticker:Cancel()
        self.ticker = nil
    end
    self.ticker = C_Timer.NewTicker(self.db.profile.outOfCombatUpdateRate, function() self:UpdateRotation() end)
    if self.actionbarScanner then
        self.actionbarScanner:Cancel()
        self.actionbarScanner = nil
    end
    self.actionbarScanner = C_Timer.NewTicker(self.db.profile.keybindUpdateRate, function() ActionBarScanner:ScanActionBars() end)
end

function Blizzkili:OutOfCombat()
    UILib.UpdateButtons()
    if self.ticker then
        self.ticker:Cancel()
        self.ticker = nil
    end
    ActionBarScanner:ScanActionBars()
    -- Out of combat we can update less frequently since we can use all API functions, so we can slow down the ticker to reduce CPU usage.
    self.ticker = C_Timer.NewTicker(self.db.profile.outOfCombatUpdateRate, function() self:UpdateRotation() end)
end

function Blizzkili:InCombat()
    if self.ticker then
        self.ticker:Cancel()
        self.ticker = nil
    end
    self.ticker = C_Timer.NewTicker(self.db.profile.inCombatUpdateRate, function() self:UpdateRotation() end)
end

--Action bar changed event handler
function Blizzkili:ActionbarChanged(_, slot)
    local type, id, subtype = BlizzardAPI._GetActionInfo(slot)
    -- if it's the single button assistant, if it is, ignore, it fires too frequently
    if subtype == "assistedcombat" then return end
    info("Action bar changed, rescaning action bars")

    ActionBarScanner:ScanActionBars()
end

-- Update frame lock status
function Blizzkili:UpdateFrameLock()
    trace("Updating frame lock status")
    if not self.frame then return end

    if self.db.profile.lockFrames then
        info("Locking frames")
        self.frame:EnableMouse(false)
        self.frame:SetMovable(false)
        self.frame:SetBackdropColor(0, 0, 0, 0)

    else
        info("Unlocking frames")
        self.frame:EnableMouse(true)
        self.frame:SetMovable(true)
        self.frame:SetBackdropColor(0, 0, 0, 0.7)

    end
end

-- Update the rotation display
function Blizzkili:UpdateRotation()
    -- This implements the Single Button Assistant rotation logic
    if not self.buttons then
        error("No buttons found, cannot update rotation")
        return
    end
    trace("Updating rotation display") --debug

    -- Get the current rotation information
    local rotationSpells = Rotation.GetRotation()

    -- TODO add prioritySpell(Cooldowns) Requires tracking cooldowns manually since we can't use IsSpellOnCooldown in combat due to secret values.
    -- local prioritySpell= 442204
    -- if not BlizzardAPI.IsSpellOnCooldown(prioritySpell) then
    --     print("Priority spell " .. prioritySpell .. " is not on cooldown, adding to rotation")
    --     table.insert(rotationSpells, 1, prioritySpell)
    -- else
    --     print("Priority spell " .. prioritySpell .. " is on cooldown, not adding to rotation")
    -- end

    -- Update buttons based on rotation
    for i, button in ipairs(self.buttons) do
        if i <= #self.buttons and i <= #rotationSpells  and i <= self.db.profile.buttons.numButtons then
            ButtonLib.UpdateButton(button, rotationSpells[i], self.db.profile)
        elseif not BlizzardAPI:InCombat() then
            button:Hide()  -- Hide unused buttons when not in combat
        end
    end
end

-- Handle slash commands
function Blizzkili:SlashCommand(input)
    if input == "lock" then
        self.db.profile.lockFrames = true
        self:UpdateFrameLock()
        info("Blizzkili frames locked")
    elseif input == "unlock" then
        self.db.profile.lockFrames = false
        self:UpdateFrameLock()
        info("Blizzkili frames unlocked")
    elseif input == "simcdebug" then
        self:SimCDebug()
    else
        -- Open configuration panel
        if AceConfigDialog and AceConfigDialog.OpenFrames["Blizzkili"] then
            AceConfigDialog:Close("Blizzkili")
        else
            AceConfigDialog:Open("Blizzkili")
        end
    end
end

-- Print SimC priority debug information to chat
function Blizzkili:SimCDebug()
    local PREFIX = "|cff00ccff[BK SimC Debug]|r "
    local SEP = "──────────────────────────"

    DEFAULT_CHAT_FRAME:AddMessage(PREFIX .. SEP)

    -- Determine spec key
    local specIndex = GetSpecialization()
    local specName = specIndex and select(2, GetSpecializationInfo(specIndex))
    local _, classToken = UnitClass("player")
    local specKey = (classToken and specName) and (classToken .. "_" .. specName) or "Unknown"
    DEFAULT_CHAT_FRAME:AddMessage(PREFIX .. "Spec key: " .. specKey)

    -- SimC priority list
    local priorityList = SimCPriorities.GetCurrentPriority()
    if priorityList and #priorityList > 0 then
        DEFAULT_CHAT_FRAME:AddMessage(PREFIX .. "|cff00ff00SimC priority list: FOUND (" .. #priorityList .. " spells)|r")
        for i, name in ipairs(priorityList) do
            DEFAULT_CHAT_FRAME:AddMessage(PREFIX .. "  #" .. i .. "  |cffffff00" .. name .. "|r")
        end
    else
        DEFAULT_CHAT_FRAME:AddMessage(PREFIX .. "|cffff4444SimC priority list: NOT FOUND for key \"" .. specKey .. "\"|r")
        DEFAULT_CHAT_FRAME:AddMessage(PREFIX .. "Falling back to Blizzard order.")
    end

    -- Raw Blizzard pool
    local ok, available = pcall(function() return C_AssistedCombat and C_AssistedCombat.IsAvailable() end)
    if not (ok and available) then
        DEFAULT_CHAT_FRAME:AddMessage(PREFIX .. "|cffff4444C_AssistedCombat not available for this spec/zone.|r")
        DEFAULT_CHAT_FRAME:AddMessage(PREFIX .. SEP)
        return
    end

    local rawPool = BlizzardAPI.GetAssistedCombatRotation()
    if not rawPool or #rawPool == 0 then
        DEFAULT_CHAT_FRAME:AddMessage(PREFIX .. "|cffff4444C_AssistedCombat not available for this spec/zone.|r")
        DEFAULT_CHAT_FRAME:AddMessage(PREFIX .. SEP)
        return
    end

    DEFAULT_CHAT_FRAME:AddMessage(PREFIX .. "Blizzard pool (raw from C_AssistedCombat):")
    for i, spellId in ipairs(rawPool) do
        local name = BlizzardAPI.GetSpellName(spellId) or tostring(spellId)
        DEFAULT_CHAT_FRAME:AddMessage(PREFIX .. "  [" .. i .. "] |cffffff00" .. name .. "|r (id: " .. spellId .. ")")
    end

    -- Build priority map and sort
    local sorted = {}
    for _, id in ipairs(rawPool) do table.insert(sorted, id) end
    if priorityList and #priorityList > 0 then
        local priorityMap = {}
        for i, name in ipairs(priorityList) do
            priorityMap[name:lower()] = i
        end
        local known = {}
        local unknown = {}
        for _, spellId in ipairs(rawPool) do
            local name = BlizzardAPI.GetSpellName(spellId)
            local prio = name and priorityMap[name:lower()]
            if prio then
                table.insert(known, { id = spellId, prio = prio })
            else
                table.insert(unknown, spellId)
            end
        end
        table.sort(known, function(a, b) return a.prio < b.prio end)
        sorted = {}
        for _, entry in ipairs(known) do table.insert(sorted, entry.id) end
        for _, id in ipairs(unknown) do table.insert(sorted, id) end

        DEFAULT_CHAT_FRAME:AddMessage(PREFIX .. "After SimC sort:")
        for i, spellId in ipairs(sorted) do
            local name = BlizzardAPI.GetSpellName(spellId) or tostring(spellId)
            local prio = (name and priorityMap[name:lower()]) or "?"
            DEFAULT_CHAT_FRAME:AddMessage(PREFIX .. "  [" .. i .. "] |cffffff00" .. name .. "|r (id: " .. spellId .. ")  ← SimC prio: " .. tostring(prio))
        end
    end

    -- Determine if order changed
    local orderChanged = false
    if #sorted == #rawPool then
        for i = 1, #sorted do
            if sorted[i] ~= rawPool[i] then
                orderChanged = true
                break
            end
        end
    else
        orderChanged = true
    end

    if #rawPool > 1 and orderChanged then
        DEFAULT_CHAT_FRAME:AddMessage(PREFIX .. "|cff00ff00Order changed: YES  ✓|r")
    else
        DEFAULT_CHAT_FRAME:AddMessage(PREFIX .. "|cffff4444Order changed: NO (Blizzard and SimC agree, or pool too small)|r")
    end

    DEFAULT_CHAT_FRAME:AddMessage(PREFIX .. SEP)
end
