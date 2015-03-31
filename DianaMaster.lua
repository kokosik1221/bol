--[[

	Script Name: DIANA MASTER 
    	Author: kokosik1221
	Last Version: 0.48
	31.03.2015
	
]]--

if myHero.charName ~= "Diana" then return end

local version = "0.48"

class "SxUpdate"
function SxUpdate:__init(LocalVersion, Host, VersionPath, ScriptPath)
    self.LocalVersion = LocalVersion
    self.Host = Host
    self.VersionPath = '/BoL/TCPUpdater/GetScript2.php?script='..self:Base64Encode(self.Host..VersionPath)..'&rand='..math.random(99999999)
    self.ScriptPath = '/BoL/TCPUpdater/GetScript2.php?script='..self:Base64Encode(self.Host..ScriptPath)..'&rand='..math.random(99999999)
    self.SavePath = SCRIPT_PATH..GetCurrentEnv().FILE_NAME
    self.CallbackUpdate = function(NewVersion, OldVersion) PrintMessage("Updated to "..NewVersion..". Please reload with 2x F9.") end
    self.CallbackNoUpdate = function(OldVersion) PrintMessage("No Updates Found") end
    self.CallbackNewVersion = function(NewVersion) PrintMessage("New Version found ("..NewVersion..").") end
    self.LuaSocket = require("socket")
    self.Socket = self.LuaSocket.connect('sx-bol.eu', 80)
    self.Socket:send("GET "..self.VersionPath.." HTTP/1.0\r\nHost: sx-bol.eu\r\n\r\n")
    self.Socket:settimeout(0, 'b')
    self.Socket:settimeout(99999999, 't')
    self.LastPrint = ""
    self.File = ""
    AddTickCallback(function() self:GetOnlineVersion() end)
end
function PrintMessage(message) 
    print("<font color=\"#FF0000\"><b>" .. "Diana Master" .. ":</b></font> <font color=\"#FFFFFF\">" .. message .. "</font>") 
end
function SxUpdate:Base64Encode(data)
	local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    return ((data:gsub('.', function(x)
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end
function SxUpdate:GetOnlineVersion()
    if self.Status == 'closed' then return end
    self.Receive, self.Status, self.Snipped = self.Socket:receive(1024)
    if self.Receive then
        if self.LastPrint ~= self.Receive then
            self.LastPrint = self.Receive
            self.File = self.File .. self.Receive
        end
    end
    if self.Snipped ~= "" and self.Snipped then
        self.File = self.File .. self.Snipped
    end
    if self.Status == 'closed' then
        local HeaderEnd, ContentStart = self.File:find('\r\n\r\n')
        if HeaderEnd and ContentStart then
            self.OnlineVersion = tonumber(self.File:sub(ContentStart + 1))
            if self.OnlineVersion ~= nil and self.OnlineVersion > self.LocalVersion then
                if self.CallbackNewVersion and type(self.CallbackNewVersion) == 'function' then
                    self.CallbackNewVersion(self.OnlineVersion,self.LocalVersion)
                end
                self.DownloadSocket = self.LuaSocket.connect('sx-bol.eu', 80)
                self.DownloadSocket:send("GET "..self.ScriptPath.." HTTP/1.0\r\nHost: sx-bol.eu\r\n\r\n")
                self.DownloadSocket:settimeout(0, 'b')
                self.DownloadSocket:settimeout(99999999, 't')
                self.LastPrint = ""
                self.File = ""
                AddTickCallback(function() self:DownloadUpdate() end)
            else
                if self.CallbackNoUpdate and type(self.CallbackNoUpdate) == 'function' then
                    self.CallbackNoUpdate(self.LocalVersion)
                end
            end
        else
            print('Error: Could not get end of Header')
        end
    end
end
function SxUpdate:DownloadUpdate()
    if self.DownloadStatus == 'closed' then return end
    self.DownloadReceive, self.DownloadStatus, self.DownloadSnipped = self.DownloadSocket:receive(1024)
    if self.DownloadReceive then
        if self.LastPrint ~= self.DownloadReceive then
            self.LastPrint = self.DownloadReceive
            self.File = self.File .. self.DownloadReceive
        end
    end
    if self.DownloadSnipped ~= "" and self.DownloadSnipped then
        self.File = self.File .. self.DownloadSnipped
    end
    if self.DownloadStatus == 'closed' then
        local HeaderEnd, ContentStart = self.File:find('\r\n\r\n')
        if HeaderEnd and ContentStart then
            local ScriptFileOpen = io.open(self.SavePath, "w+")
            ScriptFileOpen:write(self.File:sub(ContentStart + 1))
            ScriptFileOpen:close()
            if self.CallbackUpdate and type(self.CallbackUpdate) == 'function' then
                self.CallbackUpdate(self.OnlineVersion,self.LocalVersion)
            end
        end
    end
end
local UPDATED = false
SxUpdate(version,
	"raw.githubusercontent.com",
	"/kokosik1221/bol/master/DianaMaster.version",
	"/kokosik1221/bol/master/DianaMaster.lua",
	SCRIPT_PATH.."/" .. GetCurrentEnv().FILE_NAME,
	function(NewVersion) if NewVersion > version then print("<font color=\"#FF0000\"><b>Diana Master: </b></font> <font color=\"#D7DF01\">Updated to "..NewVersion..". Please Reload with 2x F9</b></font>") ForceReload = true else print("<font color=\"#FF0000\"><b>Diana Master: </b></font> <font color=\"#D7DF01\">You have the Latest Version</b></font>") end 
end)
if FileExist(LIB_PATH .. "/SxOrbWalk.lua") then
	require("SxOrbWalk")
end
if FileExist(LIB_PATH .. "/VPrediction.lua") then
	require("VPrediction")
	VP = VPrediction()
end
if VIP_USER and FileExist(LIB_PATH .. "/DivinePred.lua") then 
	require "DivinePred" 
	DP = DivinePred()
	DP.maxCalcTime = 150
end

local InterruptList = {
	{charName = "FiddleSticks", spellName = "Crowstorm"},
    {charName = "MissFortune", spellName = "MissFortuneBulletTime"},
    {charName = "Nunu", spellName = "AbsoluteZero"},
    {charName = "Caitlyn", spellName = "CaitlynAceintheHole"},
    {charName = "Katarina", spellName = "KatarinaR"},
    {charName = "Karthus", spellName = "FallenOne"},
    {charName = "Malzahar", spellName = "AlZaharNetherGrasp"},
    {charName = "Galio", spellName = "GalioIdolOfDurand"},
    {charName = "Darius", spellName = "DariusExecute"},
    {charName = "MonkeyKing", spellName = "MonkeyKingSpinToWin"},
    {charName = "Vi", spellName = "ViR"},
    {charName = "Shen", spellName = "ShenStandUnited"},
    {charName = "Urgot", spellName = "UrgotSwap2"},
    {charName = "Pantheon", spellName = "Pantheon_GrandSkyfall_Jump"},
    {charName = "Lucian", spellName = "LucianR"},
    {charName = "Warwick", spellName = "InfiniteDuress"},
    {charName = "Urgot", spellName = "UrgotSwap2"},
    {charName = "Xerath", spellName = "XerathLocusOfPower2"},
    {charName = "Velkoz", spellName = "VelkozR"},
    {charName = "Skarner", spellName = "SkarnerImpale"},
}

local Items = {
	BWC = { id = 3144, range = 400, reqTarget = true, slot = nil },
	DFG = { id = 3128, range = 750, reqTarget = true, slot = nil },
	HGB = { id = 3146, range = 400, reqTarget = true, slot = nil },
	BFT = { id = 3188, range = 750, reqTarget = true, slot = nil },
}
 
local Q = {name = "Crescent Strike", range = 900, speed = 2000, delay = 0.5, width = 195, Ready = function() return myHero:CanUseSpell(_Q) == READY end}
local W = {name = "Pale Cascade", range = 200, Ready = function() return myHero:CanUseSpell(_W) == READY end}
local E = {name = "Moonfall", range = 450, Ready = function() return myHero:CanUseSpell(_E) == READY end}
local R = {name = "Lunar Rush", range = 825, Ready = function() return myHero:CanUseSpell(_R) == READY end}
local IReady, zhonyaready, moonlight, recall = false, false, false, false
local EnemyMinions = minionManager(MINION_ENEMY, Q.range, myHero, MINION_SORT_MAXHEALTH_DEC)
local JungleMinions = minionManager(MINION_JUNGLE, Q.range, myHero, MINION_SORT_MAXHEALTH_DEC)
local lasttickchecked, lasthealthchecked = 0, 0
local IgniteKey, zhonyaslot, KSEnemy = nil, nil, nil
local killstring = {}
local TargetTable = {
	AP = {
		"Annie", "Ahri", "Akali", "Anivia", "Annie", "Brand", "Cassiopeia", "Diana", "Evelynn", "FiddleSticks", "Fizz", "Annie", "Heimerdinger", "Karthus",
		"Kassadin", "Katarina", "Kayle", "Kennen", "Leblanc", "Lissandra", "Lux", "Malzahar", "Mordekaiser", "Morgana", "Nidalee", "Orianna",
		"Ryze", "Sion", "Swain", "Syndra", "Teemo", "TwistedFate", "Veigar", "Viktor", "Vladimir", "Xerath", "Ziggs", "Zyra", "Velkoz"
	},	
	Support = {
		"Alistar", "Blitzcrank", "Janna", "Karma", "Leona", "Lulu", "Nami", "Nunu", "Sona", "Soraka", "Taric", "Thresh", "Zilean", "Braum"
	},	
	Tank = {
		"Amumu", "Chogath", "DrMundo", "Galio", "Hecarim", "Malphite", "Maokai", "Nasus", "Rammus", "Sejuani", "Nautilus", "Shen", "Singed", "Skarner", "Volibear",
		"Warwick", "Yorick", "Zac"
	},
	AD_Carry = {
		"Ashe", "Caitlyn", "Corki", "Draven", "Ezreal", "Graves", "Jayce", "Jinx", "KogMaw", "Lucian", "MasterYi", "MissFortune", "Pantheon", "Quinn", "Shaco", "Sivir",
		"Talon","Tryndamere", "Tristana", "Twitch", "Urgot", "Varus", "Vayne", "Yasuo", "Zed"
	},
	Bruiser = {
		"Aatrox", "Darius", "Elise", "Fiora", "Gangplank", "Garen", "Irelia", "JarvanIV", "Jax", "Khazix", "LeeSin", "Nocturne", "Olaf", "Poppy",
		"Renekton", "Rengar", "Riven", "Rumble", "Shyvana", "Trundle", "Udyr", "Vi", "MonkeyKing", "XinZhao"
	}
}


function OnLoad()
	if UPDATED then return end
	Menu()
	print("<b><font color=\"#FF0000\">Diana Master:</font></b> <font color=\"#FFFFFF\">Good luck and give me feedback!</font>")
	if _G.MMA_Loaded then
		print("<b><font color=\"#FF0000\">Diana Master:</font></b> <font color=\"#FFFFFF\">MMA Support Loaded.</font>")
	end
	if _G.AutoCarry then
		print("<b><font color=\"#FF0000\">Diana Master:</font></b> <font color=\"#FFFFFF\">SAC Support Loaded.</font>")
	end
end

function OnTick()
	if UPDATED then return end
	Check()
	if MenuDiana.comboConfig.CEnabled and not recall then
		caa()
		if ((myHero.mana/myHero.maxMana)*100) >= MenuDiana.comboConfig.manac then
			if MenuDiana.comboConfig.oConfig.CT == 1 then
				Combo()
			elseif MenuDiana.comboConfig.oConfig.CT == 2 then
				Combo2()
			end
		end
	end
	if (MenuDiana.harrasConfig.HEnabled or MenuDiana.harrasConfig.HTEnabled) and not recall then
		if ((myHero.mana/myHero.maxMana)*100) >= MenuDiana.harrasConfig.manah then
			Harrass()
		end
	end
	if MenuDiana.farm.LaneClear and ((myHero.mana/myHero.maxMana)*100) >= MenuDiana.farm.manaf and not recall then
		Farm()
	end
	if MenuDiana.jf.JFEnabled and ((myHero.mana/myHero.maxMana)*100) >= MenuDiana.jf.manajf and not recall then
		JungleFarmm()
	end
	if MenuDiana.prConfig.AZ and not recall then
		autozh()
	end
	if MenuDiana.prConfig.ALS then
		autolvl()
	end
	if not recall then
		KillSteall()
	end
	if MenuDiana.comboConfig.rConfig.CRKD and Cel and R.Ready() then
		CastR(Cel)
	end
end

function Menu()
	MenuDiana = scriptConfig("Diana Master "..version, "Diana Master "..version)
	MenuDiana:addParam("orb", "Orbwalker:", SCRIPT_PARAM_LIST, 1, {"SxOrb","SAC:R/MMA"}) 
	MenuDiana:addParam("qqq", "If You Change Orb. Click 2x F9", SCRIPT_PARAM_INFO,"")
	if MenuDiana.orb == 1 then
		MenuDiana:addSubMenu("[Diana Master]: Orbwalking", "Orbwalking")
		SxOrb:LoadToMenu(MenuDiana.Orbwalking)
	end
	TargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, Q.range, DAMAGE_MAGIC)
	TargetSelector.name = "Diana"
	MenuDiana:addTS(TargetSelector)
	MenuDiana:addSubMenu("[Diana Master]: Combo Settings", "comboConfig")
	MenuDiana.comboConfig:addSubMenu("[Diana Master]: Q Settings", "qConfig")
	MenuDiana.comboConfig.qConfig:addParam("USEQ", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	MenuDiana.comboConfig:addSubMenu("[Diana Master]: W Settings", "wConfig")
	MenuDiana.comboConfig.wConfig:addParam("USEW", "Use " .. W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
	MenuDiana.comboConfig:addSubMenu("[Diana Master]: E Settings", "eConfig")
	MenuDiana.comboConfig.eConfig:addParam("USEE", "Use " .. E.name .. " (E)", SCRIPT_PARAM_ONOFF, true)
	MenuDiana.comboConfig.eConfig:addParam("USEE2", "Use If Dist To Enemy >", SCRIPT_PARAM_SLICE, 280, 0, E.range, 0)
	MenuDiana.comboConfig:addSubMenu("[Diana Master]: R Settings", "rConfig")
	MenuDiana.comboConfig.rConfig:addParam("USER", "Use " .. R.name .. " (R)", SCRIPT_PARAM_ONOFF, true)
	MenuDiana.comboConfig.rConfig:addParam("USER2", "Use Only If Have Q Mark", SCRIPT_PARAM_ONOFF, true)
	MenuDiana.comboConfig.rConfig:addParam("CRKD", "Cast (R) Key Down", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("T"))
	MenuDiana.comboConfig:addSubMenu("[Diana Master]: Other Settings", "oConfig")
	MenuDiana.comboConfig.oConfig:addParam("uaa", "Use AA in Combo", SCRIPT_PARAM_ONOFF, true)
	MenuDiana.comboConfig.oConfig:addParam("ST", "Focus Selected Target", SCRIPT_PARAM_ONOFF, false)
	MenuDiana.comboConfig.oConfig:addParam("CT", "Combo Type:", SCRIPT_PARAM_LIST, 1, { "Normal", "Misaya"})
	MenuDiana.comboConfig:addParam("CEnabled", "Full Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	MenuDiana.comboConfig:addParam("manac", "Min. Mana To Cast Combo", SCRIPT_PARAM_SLICE, 10, 0, 100, 0)
	MenuDiana:addSubMenu("[Diana Master]: Harras Settings", "harrasConfig")
    MenuDiana.harrasConfig:addParam("QH", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	MenuDiana.harrasConfig:addParam("WH", "Use " .. W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
	MenuDiana.harrasConfig:addParam("EH", "Use " .. E.name .. " (E)", SCRIPT_PARAM_ONOFF, true)
	MenuDiana.harrasConfig:addParam("HEnabled", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
	MenuDiana.harrasConfig:addParam("HTEnabled", "Harass Toggle", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("L"))
	MenuDiana.harrasConfig:addParam("manah", "Min. Mana To Harrass", SCRIPT_PARAM_SLICE, 60, 0, 100, 0)
	MenuDiana:addSubMenu("[Diana Master]: KS Settings", "ksConfig")
	MenuDiana.ksConfig:addParam("IKS", "Use Ignite To KS", SCRIPT_PARAM_ONOFF, true)
	MenuDiana.ksConfig:addParam("QKS", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	MenuDiana.ksConfig:addParam("EKS", "Use " .. W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
	MenuDiana.ksConfig:addParam("RKS", "Use " .. R.name .. " (R)", SCRIPT_PARAM_ONOFF, true)
	MenuDiana.ksConfig:addParam("RKS2", "Must Have Q Mark", SCRIPT_PARAM_ONOFF, true)
	MenuDiana:addSubMenu("[Diana Master]: Farm Settings", "farm")
	MenuDiana.farm:addParam("QF", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_LIST, 3, { "No", "Freezing", "LaneClear"})
	MenuDiana.farm:addParam("WF", "Use " .. W.name .. " (W)", SCRIPT_PARAM_LIST, 2, { "No", "Freezing", "LaneClear"})
	MenuDiana.farm:addParam("EF", "Use " .. E.name .. " (E)", SCRIPT_PARAM_LIST, 1, { "No", "LaneClear"})
	MenuDiana.farm:addParam("LaneClear", "LaneClear", SCRIPT_PARAM_ONKEYDOWN, false,   string.byte("V"))
	MenuDiana.farm:addParam("manaf", "Min. Mana To Farm", SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
	MenuDiana:addSubMenu("[Diana Master]: Jungle Farm", "jf")
	MenuDiana.jf:addParam("QJF", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	MenuDiana.jf:addParam("WJF", "Use " .. W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
	MenuDiana.jf:addParam("EJF", "Use " .. E.name .. " (E)", SCRIPT_PARAM_ONOFF, true)
	MenuDiana.jf:addParam("JFEnabled", "Jungle Farm", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("V"))
	MenuDiana.jf:addParam("manajf", "Min. Mana To Jungle Farm", SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
	MenuDiana:addSubMenu("[Diana Master]: Extra Settings", "exConfig")
	MenuDiana.exConfig:addSubMenu("Auto-Interrupt Spells", "ES")
	for i, enemy in ipairs(GetEnemyHeroes()) do
		for _, champ in pairs(InterruptList) do
			if enemy.charName == champ.charName then
				MenuDiana.exConfig.ES:addParam(champ.spellName, "Stop "..champ.charName.." "..champ.spellName, SCRIPT_PARAM_ONOFF, true)
			end
		end
	end
	MenuDiana.exConfig:addParam("UI", "Use Auto-Interrupt (E)", SCRIPT_PARAM_ONOFF, true)
	MenuDiana.exConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuDiana.exConfig:addParam("USEW2", "Auto W", SCRIPT_PARAM_LIST, 3, { "Disable", "If Take DMG", "If Enemy AA", "Both"})
	MenuDiana.exConfig:addParam("qqq", "Auto W Info:", SCRIPT_PARAM_INFO,"")
	MenuDiana.exConfig:addParam("qqq", "Use W When Enemy AA Me Or If I Take Some DMG", SCRIPT_PARAM_INFO,"")
	MenuDiana:addSubMenu("[Diana Master]: Draw Settings", "drawConfig")
	MenuDiana.drawConfig:addParam("DLC", "Draw Lag-Free Circles", SCRIPT_PARAM_ONOFF, true)
	MenuDiana.drawConfig:addParam("DD", "Draw DMG Text", SCRIPT_PARAM_ONOFF, true)
	MenuDiana.drawConfig:addParam("DST", "Draw Selected Target", SCRIPT_PARAM_ONOFF, true)
	MenuDiana.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuDiana.drawConfig:addParam("DQR", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
	MenuDiana.drawConfig:addParam("DQRC", "Draw Q Range Color", SCRIPT_PARAM_COLOR, {255,0,0,255})
	MenuDiana.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuDiana.drawConfig:addParam("DWR", "Draw W Range", SCRIPT_PARAM_ONOFF, true)
	MenuDiana.drawConfig:addParam("DWRC", "Draw W Range Color", SCRIPT_PARAM_COLOR, {255,100,0,255})
	MenuDiana.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuDiana.drawConfig:addParam("DER", "Draw E Range", SCRIPT_PARAM_ONOFF, true)
	MenuDiana.drawConfig:addParam("DERC", "Draw E Range Color", SCRIPT_PARAM_COLOR, {255,255,0,0})
	MenuDiana.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuDiana.drawConfig:addParam("DRR", "Draw R Range", SCRIPT_PARAM_ONOFF, true)
	MenuDiana.drawConfig:addParam("DRRC", "Draw R Range Color", SCRIPT_PARAM_COLOR, {255, 0, 255, 0})
	MenuDiana:addSubMenu("[Diana Master]: Misc Settings", "prConfig")
	MenuDiana.prConfig:addParam("pc", "Use Packets To Cast Spells(VIP)", SCRIPT_PARAM_ONOFF, false)
	MenuDiana.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuDiana.prConfig:addParam("AZ", "Use Auto Zhonya", SCRIPT_PARAM_ONOFF, true)
	MenuDiana.prConfig:addParam("AZHP", "Min HP To Cast Zhonya", SCRIPT_PARAM_SLICE, 20, 0, 100, 0)
	MenuDiana.prConfig:addParam("AZMR", "Must Have 0 Enemy In Range:", SCRIPT_PARAM_SLICE, 900, 0, 1500, 0)
	MenuDiana.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuDiana.prConfig:addParam("ALS", "Auto lvl skills", SCRIPT_PARAM_ONOFF, false)
	MenuDiana.prConfig:addParam("AL", "Auto lvl sequence", SCRIPT_PARAM_LIST, 1, { "MID","JUNGLE" })
	MenuDiana.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuDiana.prConfig:addParam("pro", "Prodiction To Use:", SCRIPT_PARAM_LIST, 1, {"VPrediction", "Prodiction","DivinePred"}) 
	MenuDiana.comboConfig:permaShow("CEnabled")
	MenuDiana.harrasConfig:permaShow("HEnabled")
	MenuDiana.harrasConfig:permaShow("HTEnabled")
	MenuDiana.farm:permaShow("LaneClear")
	MenuDiana.jf:permaShow("JFEnabled")
	MenuDiana.exConfig:permaShow("UI")
	MenuDiana.prConfig:permaShow("AZ")
	MenuDiana.prConfig:permaShow("ALS")
	if myHero:GetSpellData(SUMMONER_1).name:find("summonerdot") then IgniteKey = SUMMONER_1
		elseif myHero:GetSpellData(SUMMONER_2).name:find("summonerdot") then IgniteKey = SUMMONER_2
	end
	_G.oldDrawCircle = rawget(_G, 'DrawCircle')
	_G.DrawCircle = DrawCircle2
	if heroManager.iCount < 10 then
		print("<font color=\"#FF0000\">Too few champions to arrange priority.</font>")
	elseif heroManager.iCount == 6 then
		arrangePrioritysTT()
    else
		arrangePrioritys()
	end
end

function Check()
	WCheck()
	if SelectedTarget ~= nil and ValidTarget(SelectedTarget, Q.range) then
		Cel = SelectedTarget
	else
		Cel = GetCustomTarget()
	end
	if MenuDiana.orb == 1 then
		SxOrb:ForceTarget(Cel)
	end
	if MenuDiana.drawConfig.DLC then _G.DrawCircle = DrawCircle2 else _G.DrawCircle = _G.oldDrawCircle end
end

function Combo()
	UseItems(Cel)
	if Q.Ready() and MenuDiana.comboConfig.qConfig.USEQ and ValidTarget(Cel, Q.range) then
		CastQ(Cel)
	end
	if R.Ready() and MenuDiana.comboConfig.rConfig.USER and ValidTarget(Cel, R.range) and not MenuDiana.comboConfig.rConfig.USER2 then
		CastR(Cel)
	end
	if moonlight and MenuDiana.comboConfig.rConfig.USER and ValidTarget(Cel, R.range) and MenuDiana.comboConfig.rConfig.USER2 and R.Ready() then
		CastR(Cel)
	end
	if E.Ready() and MenuDiana.comboConfig.eConfig.USEE and ValidTarget(Cel, E.range) then
		if GetDistance(Cel) >= MenuDiana.comboConfig.eConfig.USEE2 then
			CastE()
		end
	end
	if W.Ready() and MenuDiana.comboConfig.wConfig.USEW and ValidTarget(Cel, W.range) then
		CastW()
	end
end

function Combo2()
	if Q.Ready() and MenuDiana.comboConfig.qConfig.USEQ and ValidTarget(Cel, R.range) then
		CastQ(Cel)
	end
		DelayAction(function()  
			if R.Ready() and MenuDiana.comboConfig.rConfig.USER and ValidTarget(Cel, R.range) then
				CastR(Cel)
			end
		end, 0.75)
	if W.Ready() and MenuDiana.comboConfig.wConfig.USEW and ValidTarget(Cel, W.range) then
		CastW()
	end
	if E.Ready() and MenuDiana.comboConfig.eConfig.USEE and ValidTarget(Cel, E.range) then
		if GetDistance(Cel) >= MenuDiana.comboConfig.eConfig.USEE2 then
			CastE()
		end
	end
end

function Harrass()
	if Q.Ready() and MenuDiana.harrasConfig.QH and ValidTarget(Cel, Q.range) then
		CastQ(Cel)
	end
	if W.Ready() and MenuDiana.harrasConfig.WH and ValidTarget(Cel, W.range) then
		CastW()
	end
	if E.Ready() and MenuDiana.harrasConfig.EH and ValidTarget(Cel, E.range) then
		CastE()
	end
end

function Farm()
	EnemyMinions:update()
	QMode =  MenuDiana.farm.QF
	WMode =  MenuDiana.farm.WF
	EMode =  MenuDiana.farm.EF
	for i, minion in pairs(EnemyMinions.objects) do
		if QMode == 3 then
			if Q.Ready() and minion ~= nil and not minion.dead and ValidTarget(minion, Q.range) then
				local Pos, Hit = BestQFarmPos(Q.range, Q.width, EnemyMinions.objects)
				if Pos ~= nil then
					CastSpell(_Q, Pos.x, Pos.z)
				end
			end
		elseif QMode == 2 then
			if Q.Ready() and minion ~= nil and not minion.dead and ValidTarget(minion, Q.range) then
				if minion.health <= getDmg("Q", minion, myHero, 3) then
					CastQ(minion)
				end
			end
		end
		if WMode == 3 then
			if W.Ready() and minion ~= nil and not minion.dead and ValidTarget(minion, W.range) then
				CastW()
			end
		elseif WMode == 2 then
			if W.Ready() and minion ~= nil and not minion.dead and ValidTarget(minion, W.range) then
				if minion.health <= getDmg("W", minion, myHero, 3) then
					CastW()
				end
			end
		end
		if EMode == 2 and (QMode == 3 or WMode == 3) then
			if E.Ready() and minion ~= nil and not minion.dead and ValidTarget(minion, E.range) then
				CastE()
			end
		end
	end
end

function JungleFarmm()
	JungleMinions:update()
	for i, minion in pairs(JungleMinions.objects) do
		if MenuDiana.jf.QJF then
			if Q.Ready() and minion ~= nil and not minion.dead and ValidTarget(minion, Q.range) then
				CastQ(minion)
			end
		end
		if MenuDiana.jf.WJF then
			if W.Ready() and minion ~= nil and not minion.dead and ValidTarget(minion, W.range) then
				CastW()
			end
		end
		if MenuDiana.jf.EJF then
			if E.Ready() and minion ~= nil and not minion.dead and ValidTarget(minion, E.range) then
				CastE()
			end
		end
	end
end

function KillSteall()
	for _, Enemy in pairs(GetEnemyHeroes()) do
		local hp = Enemy.health
		local QDMG = getDmg("Q", Enemy, myHero, 3)
		local WDMG = getDmg("W", Enemy, myHero, 3)
		local RDMG = getDmg("R", Enemy, myHero, 3)
		local IDMG = 50 + (20 * myHero.level)
		if Enemy ~= nil and Enemy.team ~= player.team and not Enemy.dead and Enemy.visible then
			IReady = (IgniteKey ~= nil and myHero:CanUseSpell(IgniteKey) == READY)
			if IReady and hp < IDMG and MenuDiana.ksConfig.IKS and ValidTarget(Enemy, 600) then
				CastSpell(IgniteKey, Enemy)
			elseif Q.Ready() and hp < QDMG and MenuDiana.ksConfig.QKS and ValidTarget(Enemy, Q.range) then
				CastQ(Enemy)
			elseif W.Ready() and hp < WDMG and MenuDiana.ksConfig.WKS and ValidTarget(Enemy, W.range) then
				CastW()
			elseif R.Ready() and hp < RDMG and MenuDiana.ksConfig.RKS and ValidTarget(Enemy, R.range) and not MenuDiana.ksConfig.RKS2 then
				CastR(Enemy)
			elseif R.Ready() and hp < RDMG and MenuDiana.ksConfig.RKS and ValidTarget(Enemy, R.range) and MenuDiana.ksConfig.RKS2 then
				KSEnemy = Enemy
				if moonlight then
					CastR(Enemy)
				end
			end
		end
	end
end

function autozh()
	local count = EnemyCount(myHero, MenuDiana.prConfig.AZMR)
	zhonyaslot = GetInventorySlotItem(3157)
	zhonyaready = (zhonyaslot ~= nil and myHero:CanUseSpell(zhonyaslot) == READY)
	if zhonyaready and ((myHero.health/myHero.maxHealth)*100) < MenuDiana.prConfig.AZHP and count == 0 then
		CastSpell(zhonyaslot)
	end
end

function autolvl()
	if not MenuDiana.prConfig.ALS then return end
	if myHero.level > GetHeroLeveled() then
		local a = {}
		if MenuDiana.prConfig.AL == 1 then			
			a = {_Q,_W,_Q,_E,_Q,_R,_Q,_W,_Q,_W,_R,_W,_W,_E,_E,_R,_E,_E}
		else
			a = {_W,_Q,_W,_E,_Q,_R,_Q,_Q,_Q,_W,_R,_W,_W,_E,_E,_R,_E,_E}
		end
		LevelSpell(a[GetHeroLeveled() + 1])
	end
end

function DmgCalc()
	for _,enemy in pairs(GetEnemyHeroes()) do
        if not enemy.dead and enemy.visible and GetDistance(enemy) < 3000 then
			local QDMG = getDmg("Q", enemy, myHero, 3)
			local WDMG = getDmg("E", enemy, myHero, 3)
			local RDMG = getDmg("R", enemy, myHero, 3)
			local IDMG = (50 + (20 * myHero.level))
			if enemy.health > (QDMG + WDMG + RDMG + IDMG) then
				killstring[enemy.networkID] = "Harass Him!!!"
			elseif enemy.health < IDMG then
				killstring[enemy.networkID] = "Ignite Kill!"
			elseif enemy.health < QDMG then
				killstring[enemy.networkID] = "Q Kill!"
			elseif enemy.health < WDMG then
				killstring[enemy.networkID] = "W Kill!"
			elseif enemy.health < RDMG then
				killstring[enemy.networkID] = "R Kill!"
			elseif enemy.health < (WDMG + RDMG) then
				killstring[enemy.networkID] = "W+R Kill!"
			elseif enemy.health < (QDMG + WDMG) then
				killstring[enemy.networkID] = "Q+W Kill!"
			elseif enemy.health < (QDMG + RDMG) then
				killstring[enemy.networkID] = "Q+R Kill!"
			elseif enemy.health < (QDMG + WDMG + RDMG) then
				killstring[enemy.networkID] = "Q+W+R Kill!"
			end
		end
	end
end

function OnDraw()
	if MenuDiana.drawConfig.DST and MenuDiana.comboConfig.ST then
		if SelectedTarget ~= nil and not SelectedTarget.dead then
			DrawCircle(SelectedTarget.x, SelectedTarget.y, SelectedTarget.z, 100, RGB(MenuDiana.drawConfig.DQRC[2], MenuDiana.drawConfig.DQRC[3], MenuDiana.drawConfig.DQRC[4]))
		end
	end
	if MenuDiana.drawConfig.DD then
		DmgCalc()
		for _,enemy in pairs(GetEnemyHeroes()) do
            if ValidTarget(enemy) and killstring[enemy.networkID] ~= nil then
                local pos = WorldToScreen(D3DXVECTOR3(enemy.x, enemy.y, enemy.z))
                DrawText(killstring[enemy.networkID], 20, pos.x - 35, pos.y - 10, 0xFFFFFF00)
            end
        end
	end
	if MenuDiana.drawConfig.DQR and Q.Ready() then			
		DrawCircle(myHero.x, myHero.y, myHero.z, Q.range, RGB(MenuDiana.drawConfig.DQRC[2], MenuDiana.drawConfig.DQRC[3], MenuDiana.drawConfig.DQRC[4]))
	end
	if MenuDiana.drawConfig.DWR and W.Ready() then			
		DrawCircle(myHero.x, myHero.y, myHero.z, W.range, RGB(MenuDiana.drawConfig.DWRC[2], MenuDiana.drawConfig.DWRC[3], MenuDiana.drawConfig.DWRC[4]))
	end
	if MenuDiana.drawConfig.DER and E.Ready() then			
		DrawCircle(myHero.x, myHero.y, myHero.z, E.range, RGB(MenuDiana.drawConfig.DERC[2], MenuDiana.drawConfig.DERC[3], MenuDiana.drawConfig.DERC[4]))
	end
	if MenuDiana.drawConfig.DRR and R.Ready() then			
		DrawCircle(myHero.x, myHero.y, myHero.z, R.range, RGB(MenuDiana.drawConfig.DRRC[2], MenuDiana.drawConfig.DRRC[3], MenuDiana.drawConfig.DRRC[4]))
	end
end

function UseItems(unit)
	if unit ~= nil then
		for _, item in pairs(Items) do
			item.slot = GetInventorySlotItem(item.id)
			if item.slot ~= nil then
				if item.reqTarget and GetDistance(unit) < item.range then
					CastSpell(item.slot, unit)
				elseif not item.reqTarget then
					if (GetDistance(unit) - getHitBoxRadius(myHero) - getHitBoxRadius(unit)) < 50 then
						CastSpell(item.slot)
					end
				end
			end
		end
	end
end

function OnApplyBuff(unit, source, buff)
	if unit and unit.isMe and buff and buff.name == "Recall" then
		recall = true
	end
	if unit and unit.isMe and (source == Cel or source == KSEnemy) and buff.name == "dianamoonlight" then
		moonlight = true
	end
end

function OnRemoveBuff(unit, buff)
	if unit and unit.isMe and buff and buff.name == "Recall" then
		recall = false
	end
	if unit and (unit == Cel or unit == KSEnemy) and buff.name == "dianamoonlight" then
		moonlight = false
	end
end

function WCheck()
	if lasttickchecked <= GetTickCount() - 500 then
		lasthealthchecked = myHero.health
		lasttickchecked = GetTickCount()
	end
	if W.Ready() and (MenuDiana.exConfig.USEW2 == 2 or MenuDiana.exConfig.USEW2 == 4) and not recall then
		if lasthealthchecked > myHero.health then
			CastW()
		end
	end
end

function getHitBoxRadius(target)
	return GetDistance(target.minBBox, target.maxBBox)/2
end

function EnemyCount(point, range)
	local count = 0
	for _, enemy in pairs(GetEnemyHeroes()) do
		if enemy and not enemy.dead and GetDistance(point, enemy) <= range then
			count = count + 1
		end
	end            
	return count
end

function caa()
	if MenuDiana.orb == 1 then
		if MenuDiana.comboConfig.oConfig.uaa then
			SxOrb:EnableAttacks()
		elseif not MenuDiana.comboConfig.oConfig.uaa then
			SxOrb:DisableAttacks()
		end
	end
end

function GetCustomTarget()
 	TargetSelector:update()	
	if _G.MMA_Target and _G.MMA_Target.type == myHero.type then
		return _G.MMA_Target
	end
	if _G.AutoCarry and _G.AutoCarry.Crosshair and _G.AutoCarry.Attack_Crosshair and _G.AutoCarry.Attack_Crosshair.target and _G.AutoCarry.Attack_Crosshair.target.type == myHero.type then 
		return _G.AutoCarry.Attack_Crosshair.target 
	end
	return TargetSelector.target
end

function _GetDistanceSqr(p1, p2)
    p2 = p2 or player
    if p1 and p1.networkID and (p1.networkID ~= 0) and p1.visionPos then p1 = p1.visionPos end
    if p2 and p2.networkID and (p2.networkID ~= 0) and p2.visionPos then p2 = p2.visionPos end
    return GetDistanceSqr(p1, p2)
end

function CountObjectsNearPos(pos, range, radius, objects)
    local n = 0
    for i, object in ipairs(objects) do
        if _GetDistanceSqr(pos, object) <= radius * radius then
            n = n + 1
        end
    end
    return n
end

function BestQFarmPos(range, radius, objects)
    local BestPos 
    local BestHit = 0
    for i, object in ipairs(objects) do
        local hit = CountObjectsNearPos(object.visionPos or object, range, radius, objects)
        if hit > BestHit then
            BestHit = hit
            BestPos = object
            if BestHit == #objects then
               break
            end
         end
    end
    return BestPos, BestHit
end

function CastQ(unit)
	if MenuDiana.prConfig.pro == 1 then
		local CastPosition,  HitChance,  Position = VP:GetCircularAOECastPosition(unit, Q.delay, Q.width, Q.range, Q.speed, myHero)
		if CastPosition and HitChance >= 2 then
			if VIP_USER and MenuDiana.prConfig.pc then
				Packet("S_CAST", {spellId = _Q, fromX = CastPosition.x, fromY = CastPosition.z, toX = CastPosition.x, toY = CastPosition.z}):send()
			else
				CastSpell(_Q, CastPosition.x, CastPosition.z)
			end	
		end
	end
	if MenuDiana.prConfig.pro == 2 and VIP_USER and prodstatus then
		local castPosition, info = Prodiction.GetPrediction(unit, Q.range, Q.speed, Q.delay, Q.width, myHero)
		if castPosition ~= nil then
			if VIP_USER and MenuDiana.prConfig.pc then
				Packet("S_CAST", {spellId = _Q, fromX = castPosition.x, fromY = castPosition.z, toX = castPosition.x, toY = castPosition.z}):send()
			else
				CastSpell(_Q, castPosition.x, castPosition.z)
			end
		end
	end
	if MenuDiana.prConfig.pro == 3 and VIP_USER then
		local unit = DPTarget(unit)
		local DianaQ = CircleSS(math.huge, Q.range, Q.width, Q.delay*1000, math.huge)
		local State, Position, perc = DP:predict(unit, DianaQ)
		if State == SkillShot.STATUS.SUCCESS_HIT then 
			if VIP_USER and MenuDiana.prConfig.pc then
				Packet("S_CAST", {spellId = _Q, fromX = Position.x, fromY = Position.z, toX = Position.x, toY = Position.z}):send()
			else
				CastSpell(_Q, Position.x, Position.z)
			end
		end
	end
end

function CastW()
	if VIP_USER and MenuDiana.prConfig.pc then
		Packet("S_CAST", {spellId = _W}):send()
	else
		CastSpell(_W)
	end
end

function CastE()
	if VIP_USER and MenuDiana.prConfig.pc then
		Packet("S_CAST", {spellId = _E}):send()
	else
		CastSpell(_E)
	end
end

function CastR(unit)
	if VIP_USER and MenuDiana.prConfig.pc then
		Packet("S_CAST", {spellId = _R, targetNetworkId = unit.networkID}):send()
	else
		CastSpell(_R, unit)
	end
end

function OnProcessSpell(unit, spell)
	if MenuDiana.exConfig.UI and E.Ready() then
		for _, x in pairs(InterruptList) do
			if unit and unit.team ~= myHero.team and unit.type == myHero.type and spell then
				if spell.name == x.spellName and MenuDiana.exConfig.ES[x.spellName] and ValidTarget(unit, E.range) then
					CastE()
				end
			end
		end
	end
	if (MenuDiana.exConfig.USEW2 == 3 or MenuDiana.exConfig.USEW2 == 4) and W.Ready() then
		if unit.type == myHero.type and spell.name:lower():find("attack") and spell.target == myHero then
			CastW()
		end
	end
end

function OnWndMsg(Msg, Key)
	if Msg == WM_LBUTTONDOWN and MenuDiana.comboConfig.ST then
		local dist = 0
		local Selecttarget = nil
		for i, enemy in ipairs(GetEnemyHeroes()) do
			if ValidTarget(enemy) then
				if GetDistance(enemy, mousePos) <= dist or Selecttarget == nil then
					dist = GetDistance(enemy, mousePos)
					Selecttarget = enemy
				end
			end
		end
		if Selecttarget and dist < 300 then
			if SelectedTarget and Selecttarget.charName == SelectedTarget.charName then
				SelectedTarget = nil
				if MenuDiana.comboConfig.ST then 
					print("Target unselected: "..Selecttarget.charName) 
				end
			else
				SelectedTarget = Selecttarget
				if MenuDiana.comboConfig.ST then 
					print("New target selected: "..Selecttarget.charName) 
				end
			end
		end
	end
end

function SetPriority(table, hero, priority)
	for i=1, #table, 1 do
		if hero.charName:find(table[i]) ~= nil then
			TS_SetHeroPriority(priority, hero.charName)
		end
	end
end

function arrangePrioritysTT()
    for i, enemy in ipairs(GetEnemyHeroes()) do
		SetPriority(TargetTable.AD_Carry, enemy, 1)
		SetPriority(TargetTable.AP,       enemy, 1)
		SetPriority(TargetTable.Support,  enemy, 2)
		SetPriority(TargetTable.Bruiser,  enemy, 2)
		SetPriority(TargetTable.Tank,     enemy, 3)
    end
end

function arrangePrioritys()
	for i, enemy in ipairs(GetEnemyHeroes()) do
		SetPriority(TargetTable.AD_Carry, enemy, 1)
		SetPriority(TargetTable.AP, enemy, 2)
		SetPriority(TargetTable.Support, enemy, 3)
		SetPriority(TargetTable.Bruiser, enemy, 4)
		SetPriority(TargetTable.Tank, enemy, 5)
	end
end

function DrawCircleNextLvl(x, y, z, radius, width, color, chordlength)
  radius = radius or 300
  quality = math.max(8,round(180/math.deg((math.asin((chordlength/(2*radius)))))))
  quality = 2 * math.pi / quality
  radius = radius*.92
  
  local points = {}
  for theta = 0, 2 * math.pi + quality, quality do
    local c = WorldToScreen(D3DXVECTOR3(x + radius * math.cos(theta), y, z - radius * math.sin(theta)))
    points[#points + 1] = D3DXVECTOR2(c.x, c.y)
  end
  
  DrawLines2(points, width or 1, color or 4294967295)
end

function round(num) 
  if num >= 0 then return math.floor(num+.5) else return math.ceil(num-.5) end
end

function DrawCircle2(x, y, z, radius, color)
  local vPos1 = Vector(x, y, z)
  local vPos2 = Vector(cameraPos.x, cameraPos.y, cameraPos.z)
  local tPos = vPos1 - (vPos1 - vPos2):normalized() * radius
  local sPos = WorldToScreen(D3DXVECTOR3(tPos.x, tPos.y, tPos.z))
  
  if OnScreen({ x = sPos.x, y = sPos.y }, { x = sPos.x, y = sPos.y }) then
    DrawCircleNextLvl(x, y, z, radius, 1, color, 75) 
  end
end

-----SCRIPT STATUS------------
assert(load(Base64Decode("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"), nil, "bt", _ENV))() ScriptStatus("PCFDEFCICFE") 
