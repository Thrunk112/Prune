
-- Always-remove buffs (icon fragment → buff name)
local AlwaysRemove = {
    ["Spell_Holy_SealOfProtection"] = "Blessing of Protection",
    ["Spell_Holy_ArcaneIntellect"]  = "Arcane Intellect",
    ["Spell_Holy_MagicalSentry"]    = "Arcane Intellect",
}

-- Buffs that can be removed if near cap (icon fragment → buff name) In order of most likely to least likely to be removed
-- Remove unneeded buffs for preformance
local RemoveNearCap = {
    ["Spell_Holy_PrayerofSpirit"]     = "Prayer of Spirit",
    ["Spell_Holy_DivineSpirit"]       = "Divine Spirit", 
    ["Spell_Shadow_UnsummonBuilding"] = "Bloodmoon Vampirism", --5% vamp
	["Spell_Holy_BlessingOfAgility"]  = "Blessing of the Claw", --+50 hp
    ["Spell_Nature_UndyingStrength"]  = "Ancestral Healing", --25% armor bonus
    ["INV_Shield_06"]                 = "Inspiration", --25% armor
    ["Spell_Holy_InnerFire"]          = "Faithful", --Inner fire issue? 2% less dmg taken
    ["Spell_Nature_HealingWay"]       = "Healing Way", --bigger shaman heals
    ["Spell_Holy_AuraMastery"]        = "Daybreak", --400 healing
	["Spell_Holy_BlessingOfProtection"] = "Armor of Faith", --500 dmg shield & no pushback
	["Spell_Holy_PowerWordShield"]		= "Power Word: Shield", --1k dmg shield
	["Spell_Holy_GreaterBlessingofSanctuary"] = "Blessing of Sanctuary",
	--["Spell_Nature_AbolishMagic"]     = "Dampen Magic", --3% less dmg. 2% less heal
	--["Spell_Nature_NullifyDisease"]   = "Abolish Disease",
	["Spell_Nature_NullifyPoison_02"] = "Abolish Poison",
	["Spell_Holy_PrayerofShadowProtection"] = "Shadow Protection",
	["Spell_Nature_ResistNature"]     = "Regrowth",
    ["Spell_Holy_Renew"]              = "Renew",
    ["Spell_Nature_Rejuvenation"]     = "Rejuvenation",
    ["Spell_Nature_BloodLust"]        = "Thirst for Blood", --movement speed ALSO BLOODLUST turn off in shaman group!!!
    ["Spell_Fire_Fire"]               = "Cozy Fire / Chili / Rocket Boots?", --remove if rocket boots
	["Spell_Holy_GreaterBlessingofLight"] = "Blessing of Light / Heathen's Light",
    --["Spell_Shadow_Haunting"]         = "Ghost Costume",
    --["INV_Misc_Head_Gnome_02"]        = "Gnome Costume (Pink)",
    --["INV_Misc_Head_Gnome_01"]        = "Leper Gnome Costume",
    --["Ability_Kick"]                  = "Speed Potion / Ninja Costume",  --remove if Speed potion
    --["Ability_Rogue_Disguise"]        = "NoggenFogger/ Costumes (Gordok, etc.)",
}


local MaxBuffs = 30

local PruneDebug = false -- default false

local function SlashCmdHandler(msg)
    if msg == "on" then
        PruneDebug = true
        DEFAULT_CHAT_FRAME:AddMessage("Prune debug enabled", 1, 1, 0)
    elseif msg == "off" then
        PruneDebug = false
        DEFAULT_CHAT_FRAME:AddMessage("Prune debug disabled", 1, 1, 0)
    else
        DEFAULT_CHAT_FRAME:AddMessage("Usage: /prune on | off to toggle debug", 1, 1, 0)
    end
end

SLASH_PRUNE1 = "/prune"
SlashCmdList["PRUNE"] = SlashCmdHandler

-- Count current player buffs
local function CountBuffs()
    local count = 0
    for i = 0, 63 do
        local index = GetPlayerBuff(i, "HELPFUL")
        if index >= 0 then
            count = count + 1
        end
    end
    return count
end

local function PrunePrint(msg)
    if PruneDebug then
        DEFAULT_CHAT_FRAME:AddMessage("<Prune> " .. msg, 1, 1, 0)
    end
end

-- Remove "always-remove" buffs
local function RemoveAlways()
    for i = 0, 63 do
        local index, untilCancelled = GetPlayerBuff(i, "HELPFUL")
        if index >= 0 and untilCancelled ~= 1 then
            local texture = GetPlayerBuffTexture(index)
            if texture then
                for icon, name in pairs(AlwaysRemove) do
                    if string.find(texture, icon) then
                        CancelPlayerBuff(index)
                        PrunePrint("Removed " .. name)
                        return true
                    end
                end
            end
        end
    end
    return false
end

-- Remove buffs if over cap
local function RemoveForCap()
    local buffCount = CountBuffs()
    if buffCount <= MaxBuffs then return end

    for icon, name in pairs(RemoveNearCap) do
        for i = 0, 63 do
            local buffIndex, untilCancelled = GetPlayerBuff(i, "HELPFUL")
            if buffIndex >= 0 and untilCancelled ~= 1 then
                local texture = GetPlayerBuffTexture(buffIndex)
                if texture and string.find(texture, icon) then
                    CancelPlayerBuff(buffIndex)
                    PrunePrint("Removed " .. name .. " due to Buff Cap")
                    return
                end
            end
        end
    end
end


local PruneFrame = CreateFrame("Frame", nil, UIParent)
PruneFrame:RegisterEvent("PLAYER_AURAS_CHANGED")

local function PruneEvent()
    if event == "PLAYER_AURAS_CHANGED" then
        if RemoveAlways() then 
            return 
        end
        RemoveForCap()
    end
end

PruneFrame:SetScript("OnEvent", PruneEvent)

