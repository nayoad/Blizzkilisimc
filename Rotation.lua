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
    if #fullRotation == 0 then return fullRotation end

    -- Index 1 is GetNextCastSpell() — Blizzard's live "cast this now" recommendation.
    -- It must stay pinned at position 1 so the display always reflects the current suggestion.
    -- Intentionally not blacklist-checked: if Blizzard says cast it now, we show it regardless.
    local nextSpell = fullRotation[1]

    -- Build the remaining pool (indices 2+), filtering out blacklisted spells.
    local pool = {}
    for i = 2, #fullRotation do
        if not SpellBlacklist.isBlacklisted(fullRotation[i]) then
            table.insert(pool, fullRotation[i])
        end
    end

    -- Re-sort the pool by SimC priority when data is available for the current spec.
    local priorityList = SimCPriorities.GetCurrentPriority()
    if priorityList and #priorityList > 0 then
        local priorityMap = BuildPriorityMap(priorityList)
        pool = SortBySimC(pool, priorityMap)
    end

    -- Assemble result: nextSpell pinned first, SimC-sorted pool after.
    local result = { nextSpell }
    for _, id in ipairs(pool) do
        table.insert(result, id)
    end
    return result
end