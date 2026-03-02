-- SimCPriorities.lua
-- Spell priority lists derived from SimulationCraft APLs (midnight branch)
-- Provides ordered spell name lists (WoW display names) per class/spec.
local addonName, addon = ...
local SimCPriorities = LibStub:NewLibrary("Blizzkili-SimCPriorities", 1)
if not SimCPriorities then return end

-- Keys: "<CLASSTOKEN>_<SpecName>" matching UnitClass() classToken and GetSpecializationInfo() specName.
-- Values: ordered list of WoW spell display names (Title Case), index 1 = highest SimC APL priority.
-- Only combat spells are included; precombat, meta-actions, utility and interrupts are excluded.
-- Each name appears at most once (first/highest occurrence wins).

SimCPriorities.data = {

    -- -------------------------------------------------------------------------
    -- DEATH KNIGHT
    -- -------------------------------------------------------------------------

    -- Blood (tank)
    ["DEATHKNIGHT_Blood"] = {
        "Dancing Rune Weapon",
        "Tombstone",
        "Bonestorm",
        "Consumption",
        "Marrowrend",
        "Blood Boil",
        "Death Strike",
        "Heart Strike",
        "Soul Reaper",
        "Death's Caress",
    },

    -- Frost
    ["DEATHKNIGHT_Frost"] = {
        "Pillar of Frost",
        "Empower Rune Weapon",
        "Breath of Sindragosa",
        "Obliterate",
        "Frost Strike",
        "Glacial Advance",
        "Remorseless Winter",
        "Howling Blast",
        "Cold Heart",
        "Horn of Winter",
        "Frostscythe",
    },

    -- Unholy
    ["DEATHKNIGHT_Unholy"] = {
        "Apocalypse",
        "Dark Transformation",
        "Unholy Blight",
        "Defile",
        "Festering Strike",
        "Scourge Strike",
        "Clawing Shadows",
        "Death Coil",
        "Epidemic",
        "Soul Reaper",
    },

    -- -------------------------------------------------------------------------
    -- DEMON HUNTER
    -- -------------------------------------------------------------------------

    -- Havoc
    ["DEMONHUNTER_Havoc"] = {
        "Immolation Aura",
        "Eye Beam",
        "Essence Break",
        "Blade Dance",
        "Death Sweep",
        "Glaive Tempest",
        "Fel Rush",
        "Chaos Strike",
        "Annihilation",
        "Throw Glaive",
    },

    -- Vengeance (tank)
    ["DEMONHUNTER_Vengeance"] = {
        "Fel Devastation",
        "Spirit Bomb",
        "Immolation Aura",
        "Sigil of Flame",
        "Fracture",
        "Soul Cleave",
        "Infernal Strike",
        "Shear",
        "Soul Barrier",
    },

    -- Devourer (new Midnight spec)
    ["DEMONHUNTER_Devourer"] = {
        "Sigil of Doom",
        "Immolation Aura",
        "Eye Beam",
        "Chaos Strike",
        "Fel Rush",
        "Throw Glaive",
    },

    -- -------------------------------------------------------------------------
    -- DRUID
    -- -------------------------------------------------------------------------

    -- Balance
    ["DRUID_Balance"] = {
        "Celestial Alignment",
        "Incarnation: Chosen of Elune",
        "Fury of Elune",
        "Force of Nature",
        "Warrior of Elune",
        "Starsurge",
        "Stellar Flare",
        "Sunfire",
        "Moonfire",
        "Starfire",
        "Wrath",
    },

    -- Feral
    ["DRUID_Feral"] = {
        "Berserk",
        "Incarnation: Avatar of Ashamane",
        "Tiger's Fury",
        "Primal Wrath",
        "Rip",
        "Rake",
        "Brutal Slash",
        "Shred",
        "Ferocious Bite",
        "Moonfire",
        "Swipe",
        "Thrash",
    },

    -- Guardian (tank)
    ["DRUID_Guardian"] = {
        "Berserk",
        "Incarnation: Guardian of Ursoc",
        "Mangle",
        "Thrash",
        "Pulverize",
        "Maul",
        "Swipe",
        "Brambles",
        "Frenzied Regeneration",
    },

    -- -------------------------------------------------------------------------
    -- EVOKER
    -- -------------------------------------------------------------------------

    -- Devastation
    ["EVOKER_Devastation"] = {
        "Dragonrage",
        "Deep Breath",
        "Fire Breath",
        "Eternity Surge",
        "Shattering Star",
        "Firestorm",
        "Pyre",
        "Disintegrate",
        "Living Flame",
        "Azure Strike",
    },

    -- Augmentation
    ["EVOKER_Augmentation"] = {
        "Ebon Might",
        "Prescience",
        "Breath of Eons",
        "Upheaval",
        "Fire Breath",
        "Eruption",
        "Blistering Scales",
        "Living Flame",
        "Azure Strike",
    },

    -- -------------------------------------------------------------------------
    -- HUNTER
    -- -------------------------------------------------------------------------

    -- Beast Mastery
    ["HUNTER_Beast Mastery"] = {
        "Bestial Wrath",
        "Call of the Wild",
        "Bloodshed",
        "A Murder of Crows",
        "Barbed Shot",
        "Kill Command",
        "Dire Beast",
        "Multi-Shot",
        "Cobra Shot",
    },

    -- Marksmanship
    ["HUNTER_Marksmanship"] = {
        "Trueshot",
        "Double Tap",
        "Explosive Shot",
        "Aimed Shot",
        "Rapid Fire",
        "Volley",
        "Multishot",
        "Arcane Shot",
        "Steady Shot",
    },

    -- Survival
    ["HUNTER_Survival"] = {
        "Coordinated Assault",
        "Flanking Strike",
        "Wildfire Bomb",
        "Mongoose Bite",
        "Kill Command",
        "Carve",
        "Raptor Strike",
        "Serpent Sting",
    },

    -- -------------------------------------------------------------------------
    -- MAGE
    -- -------------------------------------------------------------------------

    -- Arcane
    ["MAGE_Arcane"] = {
        "Arcane Surge",
        "Evocation",
        "Touch of the Magi",
        "Arcane Orb",
        "Arcane Blast",
        "Arcane Missiles",
        "Arcane Barrage",
    },

    -- Fire
    ["MAGE_Fire"] = {
        "Combustion",
        "Phoenix Flames",
        "Fire Blast",
        "Pyroblast",
        "Flamestrike",
        "Dragon's Breath",
        "Meteor",
        "Fireball",
        "Scorch",
    },

    -- Frost
    ["MAGE_Frost"] = {
        "Icy Veins",
        "Frozen Orb",
        "Glacial Spike",
        "Ebonbolt",
        "Ray of Frost",
        "Comet Storm",
        "Flurry",
        "Ice Lance",
        "Ice Nova",
        "Frostbolt",
    },

    -- -------------------------------------------------------------------------
    -- MONK
    -- -------------------------------------------------------------------------

    -- Brewmaster (tank)
    ["MONK_Brewmaster"] = {
        "Weapons of Order",
        "Invoke Niuzao, the Black Ox",
        "Keg Smash",
        "Breath of Fire",
        "Purifying Brew",
        "Celestial Brew",
        "Rushing Jade Wind",
        "Blackout Kick",
        "Tiger Palm",
        "Chi Wave",
    },

    -- Windwalker
    ["MONK_Windwalker"] = {
        "Storm, Earth, and Fire",
        "Invoke Xuen, the White Tiger",
        "Touch of Death",
        "Strike of the Windlord",
        "Fists of Fury",
        "Rising Sun Kick",
        "Whirling Dragon Punch",
        "Spinning Crane Kick",
        "Blackout Kick",
        "Tiger Palm",
        "Chi Burst",
        "Chi Wave",
    },

    -- -------------------------------------------------------------------------
    -- PALADIN
    -- -------------------------------------------------------------------------

    -- Protection (tank)
    ["PALADIN_Protection"] = {
        "Avenger's Shield",
        "Holy Avenger",
        "Eye of Tyr",
        "Shield of the Righteous",
        "Judgment",
        "Hammer of the Righteous",
        "Blessed Hammer",
        "Consecration",
        "Word of Glory",
        "Ardent Defender",
    },

    -- Retribution
    ["PALADIN_Retribution"] = {
        "Crusade",
        "Avenging Wrath",
        "Wake of Ashes",
        "Divine Toll",
        "Blade of Justice",
        "Hammer of Wrath",
        "Judgment",
        "Final Verdict",
        "Templar's Verdict",
        "Divine Storm",
        "Consecration",
    },

    -- -------------------------------------------------------------------------
    -- PRIEST
    -- -------------------------------------------------------------------------

    -- Shadow
    ["PRIEST_Shadow"] = {
        "Dark Ascension",
        "Void Eruption",
        "Mindbender",
        "Shadowfiend",
        "Shadow Crash",
        "Void Bolt",
        "Devouring Plague",
        "Mind Blast",
        "Vampiric Touch",
        "Shadow Word: Pain",
        "Mind Flay",
    },

    -- -------------------------------------------------------------------------
    -- ROGUE
    -- -------------------------------------------------------------------------

    -- Assassination
    ["ROGUE_Assassination"] = {
        "Deathmark",
        "Flagellation",
        "Vendetta",
        "Exsanguinate",
        "Garrote",
        "Mutilate",
        "Envenom",
        "Rupture",
        "Crimson Tempest",
        "Fan of Knives",
        "Shiv",
    },

    -- Outlaw
    ["ROGUE_Outlaw"] = {
        "Adrenaline Rush",
        "Dreadblades",
        "Killing Spree",
        "Roll the Bones",
        "Between the Eyes",
        "Ghostly Strike",
        "Blade Flurry",
        "Dispatch",
        "Ambush",
        "Sinister Strike",
    },

    -- Subtlety
    ["ROGUE_Subtlety"] = {
        "Shadow Dance",
        "Symbols of Death",
        "Secret Technique",
        "Shuriken Tornado",
        "Shadowstrike",
        "Rupture",
        "Black Powder",
        "Eviscerate",
        "Backstab",
        "Shuriken Storm",
        "Shuriken Toss",
    },

    -- -------------------------------------------------------------------------
    -- SHAMAN
    -- -------------------------------------------------------------------------

    -- Elemental
    ["SHAMAN_Elemental"] = {
        "Stormkeeper",
        "Primordial Wave",
        "Elemental Blast",
        "Lava Burst",
        "Earthquake",
        "Flame Shock",
        "Earth Shock",
        "Icefury",
        "Frost Shock",
        "Echoing Shock",
        "Chain Lightning",
        "Lava Beam",
        "Lightning Bolt",
    },

    -- Enhancement
    ["SHAMAN_Enhancement"] = {
        "Doom Winds",
        "Primordial Wave",
        "Elemental Blast",
        "Stormstrike",
        "Lava Lash",
        "Crash Lightning",
        "Sundering",
        "Windstrike",
        "Ice Strike",
        "Flame Shock",
        "Frost Shock",
        "Chain Lightning",
        "Lightning Bolt",
    },

    -- -------------------------------------------------------------------------
    -- WARLOCK
    -- -------------------------------------------------------------------------

    -- Affliction
    ["WARLOCK_Affliction"] = {
        "Soul Rot",
        "Haunt",
        "Vile Taint",
        "Phantom Singularity",
        "Unstable Affliction",
        "Malefic Rapture",
        "Seed of Corruption",
        "Drain Soul",
        "Shadow Bolt",
        "Agony",
        "Corruption",
        "Siphon Life",
    },

    -- Demonology
    ["WARLOCK_Demonology"] = {
        "Nether Portal",
        "Summon Demonic Tyrant",
        "Call Dreadstalkers",
        "Demonic Strength",
        "Bilescourge Bombers",
        "Implosion",
        "Hand of Gul'dan",
        "Power Siphon",
        "Dark Pact",
        "Demonbolt",
        "Shadow Bolt",
    },

    -- Destruction
    ["WARLOCK_Destruction"] = {
        "Dark Soul: Instability",
        "Summon Infernal",
        "Channel Demonfire",
        "Chaos Bolt",
        "Soul Fire",
        "Dimensional Rift",
        "Cataclysm",
        "Rain of Fire",
        "Conflagrate",
        "Shadowburn",
        "Incinerate",
        "Immolate",
    },

    -- -------------------------------------------------------------------------
    -- WARRIOR
    -- -------------------------------------------------------------------------

    -- Arms
    ["WARRIOR_Arms"] = {
        "Avatar",
        "Warbreaker",
        "Bladestorm",
        "Ravager",
        "Colossus Smash",
        "Skullsplitter",
        "Mortal Strike",
        "Execute",
        "Overpower",
        "Cleave",
        "Whirlwind",
        "Slam",
    },

    -- Fury
    ["WARRIOR_Fury"] = {
        "Avatar",
        "Recklessness",
        "Onslaught",
        "Siegebreaker",
        "Bladestorm",
        "Odyn's Fury",
        "Rampage",
        "Bloodthirst",
        "Execute",
        "Raging Blow",
        "Crushing Blow",
        "Whirlwind",
    },

    -- Protection (tank)
    ["WARRIOR_Protection"] = {
        "Avatar",
        "Last Stand",
        "Demoralizing Shout",
        "Ravager",
        "Shield Slam",
        "Shield Block",
        "Thunder Clap",
        "Storm Bolt",
        "Revenge",
        "Ignore Pain",
    },
}

-- Returns the priority list for a given class/spec combination.
-- classToken: UnitClass() second return value, e.g. "DEATHKNIGHT"
-- specName:   GetSpecializationInfo() second return value, e.g. "Blood"
function SimCPriorities.GetPriority(classToken, specName)
    if not classToken or not specName then return nil end
    local key = classToken .. "_" .. specName
    return SimCPriorities.data[key]
end

-- Returns the priority list for the currently active player spec.
-- Returns nil when spec information is unavailable.
function SimCPriorities.GetCurrentPriority()
    local specIndex = GetSpecialization()
    if not specIndex then return nil end
    local _, specName = GetSpecializationInfo(specIndex)
    if not specName then return nil end
    local _, classToken = UnitClass("player")
    if not classToken then return nil end
    return SimCPriorities.GetPriority(classToken, specName)
end
