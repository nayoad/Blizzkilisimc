-- Rotation.lua
local addonName, addon = ...
local Rotation = LibStub:NewLibrary("Blizzkili-Rotation", 2)
local BlizzardAPI = LibStub("Blizzkili-BlizzardAPI")
local SpellBlacklist = LibStub("Blizzkili-SpellBlacklist")
local SimCPriorities = LibStub("Blizzkili-SimCPriorities")

-- Build a lookup table of lowercase spell name -> priority index from a list.
local function BuildPriorityMap(priorityList)
    local map = {}
    if not priorityList then return map end
    for i, name in ipairs(priorityList) do
        map[name:lower()] = i
    end
    return map
end

-- Re-order spellIds according to the SimC priority map.
-- Spells found in the map are sorted by priority; unknown spells are appended last.
local function SortBySimC(spellIds, priorityMap)
    local known = {}
    local unknown = {}
    for _, spellId in ipairs(spellIds) do
        local name = BlizzardAPI.GetSpellName(spellId)
        local prio = name and priorityMap[name:lower()]
        if prio then
            table.insert(known, { id = spellId, prio = prio })
        else
            table.insert(unknown, spellId)
        end
    end
    table.sort(known, function(a, b) return a.prio < b.prio end)
    local result = {}
    for _, entry in ipairs(known) do table.insert(result, entry.id) end
    for _, id in ipairs(unknown) do table.insert(result, id) end
    return result
end

function Rotation.GetRotation()
    local fullRotation = BlizzardAPI.GetAssistedCombatRotation()
    -- Filter blacklisted spells; always keep index 1 (Blizzard's top suggestion as anchor).
    local filtered = {}
    for i, spellId in ipairs(fullRotation) do
        if i == 1 or not SpellBlacklist.isBlacklisted(spellId) then
            table.insert(filtered, spellId)
        end
    end
    -- Re-sort by SimC priority when data is available for the current spec.
    local priorityList = SimCPriorities.GetCurrentPriority()
    if priorityList and #priorityList > 0 then
        local priorityMap = BuildPriorityMap(priorityList)
        return SortBySimC(filtered, priorityMap)
    end
    -- Fallback: no SimC data for this spec — return Blizzard order unchanged.
    return filtered
end