local AlwaysRemove = {
    --[10278] = "Blessing of Protection",            --r3
    [10157]  = "Arcane Intellect",
    [23028]  = "Arcane Brilliance",
}

local RemoveNearCap = {
    {id = 27681, name = "Prayer of Spirit"},         -- r1
    {id = 27841, name = "Divine Spirit"},            -- r4
    {id = 52428, name = "Heathen's Light Heal"},	 -- From pala libram
    {id = 7353,  name = "Cozy Fire"},				 -- 4 spirit version
    {id = 51001, name = "Bloodmoon Vampirism"},      -- 5% vamp proc from Bloodmoon Axe
    {id = 28750, name = "Blessing of the Claw"},
    {id = 16242, name = "Ancestral Healing"},
    {id = 15361, name = "Inspiration"},
    {id = 16237, name = "Ancestral Fortitude"},		 --r3
    {id = 28790, name = "Holy Power"},
    {id = 45862, name = "Faithful"},				 -- From pala libram
    {id = 29202, name = "Healing Way"},              --either incorrect ID or need more ranks
    {id = 28810, name = "Armor of Faith"},
    {id = 10901, name = "Power Word: Shield"},        --r10
    {id = 25899, name = "Blessing of Sanctuary"},
    {id = 27683, name = "Prayer of Shadow Protection"},
    {id = 10958, name = "Shadow Protection"},        -- r3
    --{id = 8451,  name = "Dampen Magic"},
    --{id = 2893,  name = "Abolish Poison"},
    --{id = 552,   name = "Abolish Disease"},          
    {id = 51322, name = "Daybreak"},
    {id = 52430, name = "Heathen's Light Str"},		 -- From pala libram
    --{id = 9858,  name = "Regrowth"},                 -- r9
    --{id = 25315, name = "Renew"},                    -- r10
    --{id = 25299, name = "Rejuvenation"},             -- r11 from aq book
    {id = 51670, name = "Thirst for Blood"},		 -- Bloodthirst movement speed
    --{id = 25890, name = "Blessing of Light"},
    --{id = 24740, name = "Wisp Costume"},
}

local MaxBuffs   = 30
local PruneDebug = false

local function SlashCmdHandler(msg)
    msg = string.lower(msg or "")
    if msg == "on" then
        PruneDebug = true
        DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Prune debug enabled|r")
    elseif msg == "off" then
        PruneDebug = false
        DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Prune debug disabled|r")
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Usage: /prune on | off")
    end
end

SLASH_PRUNE1 = "/prune"
SlashCmdList["PRUNE"] = SlashCmdHandler

local function PrunePrint(msg)
    if PruneDebug then
        DEFAULT_CHAT_FRAME:AddMessage("<Prune>|r " .. msg)
    end
end

local function CountBuffs()
    local count = 0
    for i = 0, 63 do
        local id = GetPlayerBuffID(i)
        if id and id > 0 then
            count = count + 1
        end
    end
    return count
end

local function RemoveAlways()
    for i = 0, 63 do
        local spellId = GetPlayerBuffID(i)
        if spellId and AlwaysRemove[spellId] then
            CancelPlayerBuff(i) 
            PrunePrint("Removed " .. AlwaysRemove[spellId])
            return true
        end
    end
    return false
end

local function RemoveForCap()
    local buffCount = CountBuffs()
    if buffCount <= MaxBuffs then return end

    for _, entry in ipairs(RemoveNearCap) do
        for i = 0, 63 do
            local id = GetPlayerBuffID(i)
            if id == entry.id then
                CancelPlayerBuff(i)
                PrunePrint("Removed " .. entry.name .. " for buff cap")
                return
            end
        end
    end
end

local PruneFrame = CreateFrame("Frame", "PruneFrame", UIParent)
PruneFrame:RegisterEvent("PLAYER_AURAS_CHANGED")

local function PruneEvent()
    if event == "PLAYER_AURAS_CHANGED" then
        if RemoveAlways() then return end
        RemoveForCap()
    end
end

PruneFrame:SetScript("OnEvent", PruneEvent)

