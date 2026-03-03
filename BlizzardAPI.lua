local addonName, addon = ...
local BlizzardAPI = LibStub:NewLibrary("Blizzkili-BlizzardAPI", 3)
local Debug = LibStub("Blizzkili-Debug")
local Blizzkili = LibStub("AceAddon-3.0"):GetAddon("Blizzkili", true)
local error = function(msg) Debug.Error(Blizzkili.db.profile, msg) end

-- ---------------------------------------------------------------------------
-- API compatibility wrappers (11.2.5 → 12.0.x)
-- ---------------------------------------------------------------------------

-- HasAction moved to C_ActionBar.HasAction in 12.0.0; fall back to global.
function BlizzardAPI._HasAction(slot)
    if C_ActionBar and C_ActionBar.HasAction then
        return C_ActionBar.HasAction(slot)
    end
    return HasAction(slot)
end

-- GetActionInfo moved to C_ActionBar.GetActionInfo in 12.0.0; fall back to global.
function BlizzardAPI._GetActionInfo(slot)
    if C_ActionBar and C_ActionBar.GetActionInfo then
        return C_ActionBar.GetActionInfo(slot)
    end
    return GetActionInfo(slot)
end

function BlizzardAPI.GetAssistedCombatRotation()
  local rotation = {}
  local index = 1
  local ok, available = pcall(function() return C_AssistedCombat and C_AssistedCombat.IsAvailable() end)
  if ok and available then
    -- Get the next cast spell (what's coming next)
    local nextOk, nextCastSpell = pcall(function() return C_AssistedCombat.GetNextCastSpell() end)
    if nextOk and nextCastSpell then
      rotation[index] = nextCastSpell
      index = index + 1
    else
      error("Next Cast Spell invalid")
    end

    -- Get rotation spells for reference
    local rotOk, rotationSpells = pcall(function() return C_AssistedCombat.GetRotationSpells() end)
    if rotOk and rotationSpells and #rotationSpells > 0 then
      for _, spellId in ipairs(rotationSpells) do
          -- Only add if not already in the list
          local alreadyAdded = false
          for _, id in ipairs(rotation) do
            if id == spellId then
              alreadyAdded = true
              break
            end
          end
          if not alreadyAdded then
            rotation[index] = spellId
            index = index + 1
        end
      end
    else
      error("Rotational Spells invalid")
    end
  else
    error("C_AssistedCombat is not available")
  end
  return rotation
end

function BlizzardAPI.GetSpellTexture(spellId)
  if C_Spell and C_Spell.GetSpellTexture then
    return C_Spell.GetSpellTexture(spellId)
  end
  return "Interface\\Buttons\\UI-Quickslot"
end

function BlizzardAPI.GetSpellInfo(spellId)
  if C_Spell and C_Spell.GetSpellInfo then
    return C_Spell.GetSpellInfo(spellId)
  else
    error("C_Spell.GetSpellInfo invalid")
  end
  return nil
end

function BlizzardAPI.GetSpellName(spellId)
  -- C_Spell.GetSpellName was added in 11.2.7; fall back to GetSpellInfo().name.
  if C_Spell and C_Spell.GetSpellName then
    local name = C_Spell.GetSpellName(spellId)
    if name then return name end
  end
  local spellInfo = BlizzardAPI.GetSpellInfo(spellId)
  if spellInfo and spellInfo.name then
    return spellInfo.name
  end
  return ""
end

-- ---------------------------------------------------------------------------
-- C_Spell wrappers
-- ---------------------------------------------------------------------------

-- C_Spell.GetSpellCooldown wrapper; normalises the return value to a table
-- with {startTime, duration, isEnabled, modRate} for both modern and legacy APIs.
function BlizzardAPI.GetSpellCooldown(spellId)
  if C_Spell and C_Spell.GetSpellCooldown then
    local info = C_Spell.GetSpellCooldown(spellId)
    if info then return info end
  end
  -- Legacy fallback: GetSpellCooldown returns start, duration, enabled, modRate
  local start, duration, enabled, modRate = GetSpellCooldown(spellId)
  if start == nil then return nil end
  return {
    startTime = start,
    duration = duration,
    isEnabled = (enabled == 1),
    modRate = modRate or 1,
  }
end

-- C_Spell.GetSpellCharges wrapper.
function BlizzardAPI.GetSpellCharges(spellId)
  if C_Spell and C_Spell.GetSpellCharges then
    return C_Spell.GetSpellCharges(spellId)
  end
  -- Legacy fallback
  local currentCharges, maxCharges, cooldownStartTime, cooldownDuration, chargeModRate = GetSpellCharges(spellId)
  if currentCharges == nil then return nil end
  return {
    currentCharges = currentCharges,
    maxCharges = maxCharges,
    cooldownStartTime = cooldownStartTime,
    cooldownDuration = cooldownDuration,
    chargeModRate = chargeModRate or 1,
  }
end

-- C_Spell.IsSpellUsable wrapper.
function BlizzardAPI.IsSpellUsable(spellId)
  if C_Spell and C_Spell.IsSpellUsable then
    return C_Spell.IsSpellUsable(spellId)
  end
  return IsSpellUsable(spellId)
end

-- C_Spell.IsSpellInRange wrapper.
function BlizzardAPI.IsSpellInRange(spellId, unit)
  if C_Spell and C_Spell.IsSpellInRange then
    return C_Spell.IsSpellInRange(spellId, unit)
  end
  return IsSpellInRange(spellId, unit)
end

-- ---------------------------------------------------------------------------
-- C_ActionBar wrappers
-- ---------------------------------------------------------------------------

-- C_ActionBar.GetActionCooldown wrapper; normalises to {startTime, duration, isEnabled, modRate}.
function BlizzardAPI.GetActionCooldown(slot)
  if C_ActionBar and C_ActionBar.GetActionCooldown then
    local info = C_ActionBar.GetActionCooldown(slot)
    if info then return info end
  end
  -- Legacy fallback
  local start, duration, enabled, modRate = GetActionCooldown(slot)
  if start == nil then return nil end
  return {
    startTime = start,
    duration = duration,
    isEnabled = (enabled == 1),
    modRate = modRate or 1,
  }
end

-- C_ActionBar.GetActionCharges wrapper.
function BlizzardAPI.GetActionCharges(slot)
  if C_ActionBar and C_ActionBar.GetActionCharges then
    return C_ActionBar.GetActionCharges(slot)
  end
  return nil
end

-- ---------------------------------------------------------------------------
-- C_Item / C_Container wrappers
-- ---------------------------------------------------------------------------

-- C_Item.GetItemCooldown wrapper; normalises to {startTime, duration, isEnabled}.
function BlizzardAPI.GetItemCooldown(itemId)
  if C_Item and C_Item.GetItemCooldown then
    local info = C_Item.GetItemCooldown(itemId)
    if info then return info end
  end
  -- Legacy fallback
  local start, duration, enabled = GetItemCooldown(itemId)
  if start == nil then return nil end
  return {
    startTime = start,
    duration = duration,
    isEnabled = (enabled == 1),
  }
end

-- ---------------------------------------------------------------------------
-- IsSpellOnCooldown
-- ---------------------------------------------------------------------------

-- This only works out of combat because values are secret in combat.
-- TODO revisit: will require manually tracking spells to use in combat.
function BlizzardAPI.IsSpellOnCooldown(spellId)
  if BlizzardAPI.InCombatLockdown() then
    return true
  end
  if not spellId then
    return true
  end

  local cooldownInfo = BlizzardAPI.GetSpellCooldown(spellId)
  if not cooldownInfo then
    return true
  end

  -- isEnabled == false means the spell is currently unusable / on full CD.
  if cooldownInfo.isEnabled == false then
    return true
  end

  local startTime = cooldownInfo.startTime or 0
  local duration = cooldownInfo.duration or 0

  if startTime == 0 and duration == 0 then
    return false
  end

  return true
end

function BlizzardAPI.InCombat()
    return BlizzardAPI.InCombatLockdown()
end
function BlizzardAPI.InCombatLockdown()
    return InCombatLockdown() or UnitIsDeadOrGhost("player")
end

function BlizzardAPI.GetAvailableSpells()
  local spells = {}
  local blacklist = {
    [6603] = true, -- Auto Attack
    [83958] = true, -- Mobile Banking
    [125439] = true, -- Revive Battle Pets
    [382499] = true, -- Anomaly Detection
    [382501] = true, -- Mechanism Bypass
    [1231411] = true, -- Recuperate
  }

  for i = 1, C_SpellBook.GetNumSpellBookSkillLines() do
    local skillLineInfo = C_SpellBook.GetSpellBookSkillLineInfo(i)
    local offset, numSlots = skillLineInfo.itemIndexOffset, skillLineInfo.numSpellBookItems
    for j = offset + 1, offset + numSlots do
      local spellBookItemInfo = C_SpellBook.GetSpellBookItemInfo(j, Enum.SpellBookSpellBank.Player)
      -- Normalize fields that may differ between API versions.
      local spellType = spellBookItemInfo.itemType
      local id = spellBookItemInfo.spellID or spellBookItemInfo.actionID
      local passive = spellBookItemInfo.isPassive
      local isOffSpec = spellBookItemInfo.isOffSpec or false

        -- Only process and print spells
        if spellType == Enum.SpellBookItemType.Spell and not passive and not isOffSpec then
          if not blacklist[id] then
            local spellName = BlizzardAPI.GetSpellName(id)
            spells[id] = spellName
          end
      end
    end
  end
  return spells
end