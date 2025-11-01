local function InitOptions()
	if not PruneDB then 
	PruneDB = { AlwaysRemove = {}, RemoveNearCap = {}, Debug = false}
	end
	PruneDebug = PruneDB.Debug
end

local BuffList = {
{id=552,name="Abolish Disease",icon="Interface\\Icons\\Spell_Nature_NullifyDisease"},
{id=2893,name="Abolish Poison",icon="Interface\\Icons\\Spell_Nature_NullifyPoison"},
{id=28810,name="Armor of Faith",icon="Interface\\Icons\\Spell_Holy_InnerFire"},
{id=23028,name="Arcane Brilliance",icon="Interface\\Icons\\Spell_Holy_ArcaneIntellect"},
{id=10157,name="Arcane Intellect",icon="Interface\\Icons\\Spell_Holy_MagicalSentry"},
{id=16237,name="Ancestral Fortitude",icon="Interface\\Icons\\Spell_Nature_UndyingStrength"},
{id=16242,name="Ancestral Healing",icon="Interface\\Icons\\Spell_Nature_UndyingStrength"}, 
{id=25890,name="Blessing of Light",icon="Interface\\Icons\\Spell_Holy_PrayerOfHealing02"},
{id=28750,name="Blessing of the Claw",icon="Interface\\Icons\\Ability_Druid_ChallangingRoar"},
{id=25899,name="Blessing of Sanctuary",icon="Interface\\Icons\\Spell_Nature_LightningShield"},
{id=25895,name="Blessing of Salvation",icon="Interface\\Icons\\Spell_Holy_GreaterBlessingofSalvation"},
{id=10278,name="Blessing of Protection",icon="Interface\\Icons\\Spell_Holy_SealOfProtection"},
{id=8451,name="Dampen Magic",icon="Interface\\Icons\\Spell_Nature_AbolishMagic"},
{id=27841,name="Divine Spirit",icon="Interface\\Icons\\Spell_Holy_DivineSpirit"},
{id=7353,name="Cozy Fire",icon="Interface\\Icons\\Spell_Fire_Fire"},
{id=51322,name="Daybreak",icon="Interface\\Icons\\Spell_Holy_AuraMastery"},
{id=45862,name="Faithful",icon="Interface\\Icons\\Spell_Holy_DevotionAura"},
{id=52428,name="Heathen's Light Heal",icon="Interface\\Icons\\Spell_Holy_GreaterBlessingofLight"},
{id=52430,name="Heathen's Light Str",icon="Interface\\Icons\\Spell_Holy_GreaterBlessingofLight"},
{id =29203,name ="Healing Way",icon="Interface\\Icons\\Spell_Nature_HealingWay"},
{id=28790,name="Holy Power",icon="Interface\\Icons\\Spell_Magic_MageArmor"},
{id=15361,name="Inspiration",icon="Interface\\Icons\\Spell_Holy_LayOnHands"},
{id=10901,name="Power Word: Shield",icon="Interface\\Icons\\Spell_Holy_PowerWordShield"},
{id=25315,name="Renew",icon="Interface\\Icons\\Spell_Holy_Renew"},
{id=25299,name="Rejuvenation",icon="Interface\\Icons\\Spell_Nature_Rejuvenation"},
{id=9858,name="Regrowth",icon="Interface\\Icons\\Spell_Nature_ResistNature"},
{id=10958,name="Shadow Protection",icon="Interface\\Icons\\Spell_Shadow_AntiShadow"},
{id=27681,name="Prayer of Spirit",icon="Interface\\Icons\\Spell_Holy_PrayerOfSpirit"},
{id=27683,name="Prayer of Shadow Protection",icon="Interface\\Icons\\Spell_Holy_PrayerofShadowProtection"},
{id=51670,name="Thirst for Blood",icon="Interface\\Icons\\Spell_Nature_BloodLust"},
{id=51001,name="Bloodmoon Vampirism",icon="Interface\\Icons\\Spell_Shadow_UnsummonBuilding"},
{id=24740,name="Wisp Costume",icon="Interface\\Icons\\Spell_Nature_WispSplode"},
}

local MaxBuffs   = 31
local selectedBuff = nil
local buffButtons = {}
local selectedButton = nil

local function PrunePrint(msg)
    if PruneDebug then 
		DEFAULT_CHAT_FRAME:AddMessage("<Prune>|r "..msg) 
	end
end

local function CountBuffs()
    local count,i=0,0
    while i<=63 do
        local id=GetPlayerBuffID(i)
        if id and id>0 then 
			count=count+1 
		end
        i=i+1
    end
    return count
end

local function RemoveAlways()
    local i=0
    while i<=63 do
        local spellId=GetPlayerBuffID(i)
        local j=1
        while j<=table.getn(PruneDB.AlwaysRemove) do
            local entry=PruneDB.AlwaysRemove[j]
            if spellId==entry.id then 
				CancelPlayerBuff(i)
				PrunePrint("Removed "..entry.name) 
				return true 
			end
            j=j+1
        end
        i=i+1
    end
    return false
end

local function RemoveForCap()
    if CountBuffs()<=MaxBuffs then return end
    local j=1
    while j<=table.getn(PruneDB.RemoveNearCap) do
        local entry=PruneDB.RemoveNearCap[j]
        local i=0
        while i<=63 do
            local id=GetPlayerBuffID(i)
            if id==entry.id then CancelPlayerBuff(i) PrunePrint("Removed "..entry.name.." for buff cap") return end
            i=i+1
        end
        j=j+1
    end
end


--EVERYTHING BELOW IS THE OPTIONS MENU
local Prune_Optionsmenu=CreateFrame("Frame","PruneUI",UIParent)
Prune_Optionsmenu:SetWidth(800)
Prune_Optionsmenu:SetHeight(400)
Prune_Optionsmenu:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
Prune_Optionsmenu:SetBackdrop({
	bgFile="Interface/Tooltips/UI-Tooltip-Background",
	edgeFile="Interface/Tooltips/UI-Tooltip-Border",
	tile=true,
	tileSize=16,
	edgeSize=16,
	insets={left=4,right=4,top=4,bottom=4}
})
Prune_Optionsmenu:SetBackdropColor(0,0,0,0.9)
Prune_Optionsmenu:Hide()
Prune_Optionsmenu:EnableMouse(true)
Prune_Optionsmenu:SetMovable(true)
Prune_Optionsmenu:RegisterForDrag("LeftButton")  
Prune_Optionsmenu:SetClampedToScreen(true)     

Prune_Optionsmenu:SetScript("OnDragStart", function()
    this:StartMoving()
end)
Prune_Optionsmenu:SetScript("OnDragStop", function()
    this:StopMovingOrSizing()
end)

Prune_Optionsmenu.title=Prune_Optionsmenu:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
Prune_Optionsmenu.title:SetPoint("TOP",0,-10)
Prune_Optionsmenu.title:SetText("Prune - Buff Cap Avoidance")

Prune_Optionsmenu.closeButton = CreateFrame("Button", nil, Prune_Optionsmenu, "UIPanelCloseButton")
Prune_Optionsmenu.closeButton:SetPoint("TOPRIGHT", -5, -5)
Prune_Optionsmenu.closeButton:SetScript("OnClick", function()
    Prune_Optionsmenu:Hide()
end)

Prune_Optionsmenu.debugCheckbox = CreateFrame("CheckButton", nil, Prune_Optionsmenu, "UICheckButtonTemplate")
Prune_Optionsmenu.debugCheckbox:SetPoint("LEFT", Prune_Optionsmenu.title, "RIGHT", 25, 0)
Prune_Optionsmenu.debugCheckbox.text = Prune_Optionsmenu.debugCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
Prune_Optionsmenu.debugCheckbox.text:SetPoint("LEFT", Prune_Optionsmenu.debugCheckbox, "RIGHT", 4, 0)
Prune_Optionsmenu.debugCheckbox.text:SetText("Print when Buffs are removed")


Prune_Optionsmenu.debugCheckbox:SetScript("OnClick", function()
    PruneDebug = this:GetChecked() 
    PruneDB.Debug = PruneDebug
end)

local AllBuffsFrame = CreateFrame("Frame", nil, Prune_Optionsmenu)
AllBuffsFrame:SetWidth(250)
AllBuffsFrame:SetHeight(300) 
AllBuffsFrame:SetPoint("TOPLEFT", 15, -40)
AllBuffsFrame:SetBackdrop({bgFile="Interface/Tooltips/UI-Tooltip-Background"})
AllBuffsFrame:SetBackdropColor(0,0,0,0.9)
AllBuffsFrame.title = AllBuffsFrame:CreateFontString(nil,"OVERLAY","GameFontNormal")
AllBuffsFrame.title:SetPoint("TOPLEFT",15,-5)
AllBuffsFrame.title:SetText("Untracked Buffs")
AllBuffsFrame.scroll = CreateFrame("ScrollFrame", "AllBuffsScrollFrame", AllBuffsFrame, "UIPanelScrollFrameTemplate")
AllBuffsFrame.scroll:SetPoint("TOPLEFT",5,-25)
AllBuffsFrame.scroll:SetPoint("BOTTOMRIGHT",-5,5)
AllBuffsFrame.content = CreateFrame("Frame", "AllBuffsScrollChild", AllBuffsFrame.scroll)
AllBuffsFrame.content:SetWidth(AllBuffsFrame:GetWidth()-20)
AllBuffsFrame.content:SetHeight(1)
AllBuffsFrame.scroll:SetScrollChild(AllBuffsFrame.content)


local AlwaysFrame = CreateFrame("Frame", nil, Prune_Optionsmenu)
AlwaysFrame:SetWidth(250)
AlwaysFrame:SetHeight(300)
AlwaysFrame:SetPoint("TOPLEFT", AllBuffsFrame, "TOPRIGHT", 10, 0)
AlwaysFrame:SetBackdrop({bgFile="Interface/Tooltips/UI-Tooltip-Background"})
AlwaysFrame:SetBackdropColor(0,0,0,0.9)
AlwaysFrame.title = AlwaysFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
AlwaysFrame.title:SetPoint("TOPLEFT", 15, -5)
AlwaysFrame.title:SetText("Always Remove")
AlwaysFrame.scroll = CreateFrame("ScrollFrame", "AlwaysScrollFrame", AlwaysFrame, "UIPanelScrollFrameTemplate")
AlwaysFrame.scroll:SetPoint("TOPLEFT", 5, -25)
AlwaysFrame.scroll:SetPoint("BOTTOMRIGHT", -20, 5)
AlwaysFrame.content = CreateFrame("Frame", "AlwaysScrollChild", AlwaysFrame.scroll)
AlwaysFrame.content:SetWidth(AlwaysFrame.scroll:GetWidth())
AlwaysFrame.content:SetHeight(1)
AlwaysFrame.scroll:SetScrollChild(AlwaysFrame.content)

local CapFrame = CreateFrame("Frame", nil, Prune_Optionsmenu)
CapFrame:SetWidth(250)
CapFrame:SetHeight(300)
CapFrame:SetPoint("TOPLEFT", AlwaysFrame, "TOPRIGHT", 10, 0)
CapFrame:SetBackdrop({bgFile="Interface/Tooltips/UI-Tooltip-Background"})
CapFrame:SetBackdropColor(0,0,0,0.9)
CapFrame.title = CapFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
CapFrame.title:SetPoint("TOPLEFT", 0, -5)
CapFrame.title:SetText("Remove at Cap - Highest removed First!")
CapFrame.scroll = CreateFrame("ScrollFrame", "CapScrollFrame", CapFrame, "UIPanelScrollFrameTemplate")
CapFrame.scroll:SetPoint("TOPLEFT", 5, -25)
CapFrame.scroll:SetPoint("BOTTOMRIGHT", -20, 5)
CapFrame.content = CreateFrame("Frame", "CapScrollChild", CapFrame.scroll)
CapFrame.content:SetWidth(CapFrame.scroll:GetWidth())
CapFrame.content:SetHeight(1)
CapFrame.scroll:SetScrollChild(CapFrame.content)

local function IsInList(buff,list)
    local i=1
    while i<=table.getn(list) do
        if list[i].id==buff.id then return true end
        i=i+1
    end
    return false
end

local AllPruneButtons = {}

local function CreateBuffRow(parent, buff, y)
    local row = CreateFrame("Button", nil, parent)  
    row:SetWidth(parent:GetWidth() - 10)
    row:SetHeight(22)
    row:SetPoint("TOPLEFT", 5, y)
    row.buff = buff
    row:EnableMouse(true) 

    row:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true, tileSize = 8, edgeSize = 8,
        insets = {left=1,right=1,top=1,bottom=1}
    })
    row:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
    row:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)

    local icon = row:CreateTexture(nil, "ARTWORK")
    icon:SetHeight(18)
    icon:SetWidth(18)
    icon:SetPoint("LEFT", 4, 0)
    icon:SetTexture(buff.icon or "Interface\\Icons\\INV_Misc_QuestionMark")

    local text = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    text:SetPoint("LEFT", icon, "RIGHT", 6, 0)
    text:SetText(buff.name)
    text:SetJustifyH("LEFT")
    text:SetWidth(row:GetWidth() - 30)
    text:SetTextColor(1, 1, 1)
    row.text = text

local highlight = row:CreateTexture(nil, "HIGHLIGHT")
highlight:SetAllPoints()
highlight:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
highlight:SetBlendMode("ADD")
highlight:SetAlpha(0.3)

local selectedBG = row:CreateTexture(nil, "OVERLAY")
selectedBG:SetAllPoints()
selectedBG:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
selectedBG:SetBlendMode("ADD")
selectedBG:SetAlpha(0.4)
selectedBG:Hide()
row.selectedBG = selectedBG


row:SetScript("OnClick", function()
    for _, b in ipairs(AllPruneButtons) do
        if b.selectedBG then b.selectedBG:Hide() end
        if b.text then b.text:SetTextColor(1,1,1) end
        b:SetBackdropBorderColor(0.3,0.3,0.3,0.8)
    end

    if row.selectedBG then row.selectedBG:Show() end
    if row.text then row.text:SetTextColor(1,1,0) end
    row:SetBackdropBorderColor(1,1,0,1)
    selectedBuff = row.buff
    selectedButton = row
    if row.entry then
        local parentScroll = row:GetParent():GetParent()
        if parentScroll == AlwaysFrame.scroll then
            AlwaysFrame.selectedEntry = row.entry
            CapFrame.selectedEntry = nil
        elseif parentScroll == CapFrame.scroll then
            CapFrame.selectedEntry = row.entry
            AlwaysFrame.selectedEntry = nil
        end
    else
        AlwaysFrame.selectedEntry = nil
        CapFrame.selectedEntry = nil
    end
end)
    table.insert(AllPruneButtons, row)
    return row
end

local function SelectButton(btn)
    local i=1
    while i<=table.getn(AllPruneButtons) do
        local b = AllPruneButtons[i]
        if b.text then
            if b == btn then
                b.text:SetTextColor(1, 1, 0)
                b:SetBackdropBorderColor(1, 1, 0, 1)
                if b.selectedBG then 
					b.selectedBG:Show() 
				end
                selectedBuff = b.buff
                selectedButton = b
            else
                b.text:SetTextColor(1, 1, 1)
                b:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)
                if b.selectedBG then 
					b.selectedBG:Hide() 
				end
            end
        end
        i=i+1
    end

    if btn.entry then
        if btn:GetParent():GetParent() == AlwaysFrame.scroll then
            AlwaysFrame.selectedEntry = btn.entry
            CapFrame.selectedEntry = nil
        elseif btn:GetParent():GetParent() == CapFrame.scroll then
            CapFrame.selectedEntry = btn.entry
            AlwaysFrame.selectedEntry = nil
        end
    else
        AlwaysFrame.selectedEntry = nil
        CapFrame.selectedEntry = nil
    end
end

local function RefreshBuffList()
    for _,btn in ipairs(buffButtons) do if btn.Hide then btn:Hide() end end
    buffButtons, selectedButton, selectedBuff = {}, nil, nil
    local y = -5
    for _,buff in ipairs(BuffList) do
        if not IsInList(buff, PruneDB.AlwaysRemove) and not IsInList(buff, PruneDB.RemoveNearCap) then
            local row = CreateBuffRow(AllBuffsFrame.content, buff, y)
            table.insert(buffButtons, row)
            y = y - 22
        end
    end
    AllBuffsFrame.content:SetHeight(-y)
	AllBuffsFrame.scroll:SetScrollChild(AllBuffsFrame.content)
end

local function RefreshList(parent, dbList)
    local oldSelection = parent.selectedEntry
    if parent.items then
        for _, btn in ipairs(parent.items) do
            if btn.Hide then btn:Hide() end
        end
    end
    parent.items = {}
    local y = -5
    local rowHeight = 22
    for i, entry in ipairs(dbList) do
        local row = CreateBuffRow(parent.content, entry, y)
        row.entry = entry
        table.insert(parent.items, row)
        table.insert(AllPruneButtons, row)
        if oldSelection and entry == oldSelection then
            SelectButton(row)
            parent.selectedEntry = oldSelection
        end
        y = y - rowHeight
    end

    local contentHeight = math.max(-y, parent.scroll:GetHeight())
    parent.content:SetHeight(contentHeight)
    parent.scroll:SetScrollChild(parent.content)
end


local function AddToList(list,otherList)
    if not selectedBuff then return end
    local i=1
    while i<=table.getn(otherList) do
        if otherList[i].id==selectedBuff.id then
            table.remove(otherList,i)
            i=i-1
        end
        i=i+1
    end
    i=1
    while i<=table.getn(list) do
        if list[i].id==selectedBuff.id then return end
        i=i+1
    end
    table.insert(list,selectedBuff)
end

local AddAlwaysBtn=CreateFrame("Button",nil,Prune_Optionsmenu,"UIPanelButtonTemplate")
AddAlwaysBtn:SetWidth(175)
AddAlwaysBtn:SetHeight(25)
AddAlwaysBtn:SetPoint("BOTTOMLEFT",20,20)
AddAlwaysBtn:SetText("Add to Always Remove")
AddAlwaysBtn:SetScript("OnClick",function()
    AddToList(PruneDB.AlwaysRemove,PruneDB.RemoveNearCap)
    RefreshList(AlwaysFrame, PruneDB.AlwaysRemove) 
	RefreshList(CapFrame, PruneDB.RemoveNearCap) 
	RefreshBuffList()
end)

local AddCapBtn=CreateFrame("Button",nil,Prune_Optionsmenu,"UIPanelButtonTemplate")
AddCapBtn:SetWidth(200)
AddCapBtn:SetHeight(25)
AddCapBtn:SetPoint("BOTTOMLEFT",200,20)
AddCapBtn:SetText("Add to Remove at Buff Cap")
AddCapBtn:SetScript("OnClick",function()
    AddToList(PruneDB.RemoveNearCap,PruneDB.AlwaysRemove)
    RefreshList(CapFrame, PruneDB.RemoveNearCap) 
	RefreshList(AlwaysFrame, PruneDB.AlwaysRemove) 
	RefreshBuffList()
end)

local RemoveBtn=CreateFrame("Button",nil,Prune_Optionsmenu,"UIPanelButtonTemplate")
RemoveBtn:SetWidth(140)
RemoveBtn:SetHeight(25)
RemoveBtn:SetPoint("BOTTOMRIGHT",-255,20)
RemoveBtn:SetText("Stop Tracking Buff")
RemoveBtn:SetScript("OnClick",function()
    local function remove(list,sel) 
        local i=1
        while i<=table.getn(list) do
            if list[i]==sel then table.remove(list,i) return end
            i=i+1
        end
    end
    remove(PruneDB.AlwaysRemove,AlwaysFrame.selectedEntry)
    remove(PruneDB.RemoveNearCap,CapFrame.selectedEntry)
    RefreshList(AlwaysFrame, PruneDB.AlwaysRemove) 
	RefreshList(CapFrame, PruneDB.RemoveNearCap) 
	RefreshBuffList()
end)

local MoveUpBtn=CreateFrame("Button",nil,Prune_Optionsmenu,"UIPanelButtonTemplate")
MoveUpBtn:SetWidth(80)
MoveUpBtn:SetHeight(25)
MoveUpBtn:SetPoint("BOTTOMRIGHT",-150,20)
MoveUpBtn:SetText("Move Up")
MoveUpBtn:SetScript("OnClick",function()
    local selC=CapFrame.selectedEntry
    local function swap(list)
        local i=2
        while i<=table.getn(list) do
            if list[i]==selC then list[i],list[i-1]=list[i-1],list[i] return end
            i=i+1
        end
    end
    swap(PruneDB.RemoveNearCap)
    RefreshList(CapFrame, PruneDB.RemoveNearCap) 
end)

local MoveDownBtn=CreateFrame("Button",nil,Prune_Optionsmenu,"UIPanelButtonTemplate")
MoveDownBtn:SetWidth(80)
MoveDownBtn:SetHeight(25)
MoveDownBtn:SetPoint("BOTTOMRIGHT",-60,20)
MoveDownBtn:SetText("Move Down")
MoveDownBtn:SetScript("OnClick",function()
    local selC=CapFrame.selectedEntry
    local function swap(list)
        local i=1
        while i<=table.getn(list)-1 do
            if list[i]==selC then list[i],list[i+1]=list[i+1],list[i] return end
            i=i+1
        end
    end
    swap(PruneDB.RemoveNearCap)
    RefreshList(CapFrame, PruneDB.RemoveNearCap) 
end)

SLASH_PRUNEUI1="/prune"
SlashCmdList["PRUNEUI"]=function()
    if Prune_Optionsmenu:IsShown() then 
		Prune_Optionsmenu:Hide() 
	else 
	AllPruneButtons = {}
	RefreshBuffList()
	RefreshList(AlwaysFrame, PruneDB.AlwaysRemove)
	RefreshList(CapFrame, PruneDB.RemoveNearCap) 
	Prune_Optionsmenu:Show() 
	end
end

local function InitUI()
	Prune_Optionsmenu.debugCheckbox:SetChecked(PruneDB.Debug)
	AllPruneButtons = {}
	RefreshBuffList()
	RefreshList(AlwaysFrame, PruneDB.AlwaysRemove)
	RefreshList(CapFrame, PruneDB.RemoveNearCap)
end

local PruneFrame=CreateFrame("Frame")
PruneFrame:RegisterEvent("PLAYER_AURAS_CHANGED")
PruneFrame:RegisterEvent("ADDON_LOADED")
PruneFrame:SetScript("OnEvent",function()
	if event == "ADDON_LOADED" and arg1 == "Prune" then
		InitOptions()
		InitUI()
	elseif event == "PLAYER_AURAS_CHANGED" then
		if RemoveAlways() then return end
		RemoveForCap()
	end
end)


