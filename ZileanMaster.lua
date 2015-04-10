--[[

	Script Name: ZILEAN MASTER 
    Author: kokosik1221
	Last Version: 0.25
	10.04.2015
	
]]--

if myHero.charName ~= "Zilean" then return end

local autoupdate = true
local version = 0.25
 
class "_ScriptUpdate"
function _ScriptUpdate:__init(LocalVersion, UseHttps, Host, VersionPath, ScriptPath, SavePath, CallbackUpdate, CallbackNoUpdate, CallbackNewVersion,CallbackError)
    self.LocalVersion = LocalVersion
    self.Host = Host
    self.VersionPath = '/BoL/TCPUpdater/GetScript'..(UseHttps and '3' or '4')..'.php?script='..self:Base64Encode(self.Host..VersionPath)..'&rand='..math.random(99999999)
    self.ScriptPath = '/BoL/TCPUpdater/GetScript'..(UseHttps and '3' or '4')..'.php?script='..self:Base64Encode(self.Host..ScriptPath)..'&rand='..math.random(99999999)
    self.SavePath = SavePath
    self.CallbackUpdate = CallbackUpdate
    self.CallbackNoUpdate = CallbackNoUpdate
    self.CallbackNewVersion = CallbackNewVersion
    self.CallbackError = CallbackError
    --AddDrawCallback(function() self:OnDraw() end)
    self:CreateSocket(self.VersionPath)
    self.DownloadStatus = 'Connect to Server for VersionInfo'
    AddTickCallback(function() self:GetOnlineVersion() end)
end
function _ScriptUpdate:OnDraw()
    DrawText('Download Status: '..(self.DownloadStatus or 'Unknown'),50,10,50,ARGB(255,255,255,255))
end
function _ScriptUpdate:CreateSocket(url)
    if not self.LuaSocket then
        self.LuaSocket = require("socket")
    else
        self.Socket:close()
        self.Socket = nil
        self.Size = nil
        self.RecvStarted = false
    end
    self.LuaSocket = require("socket")
    self.Socket = self.LuaSocket.tcp()
    self.Socket:settimeout(0, 'b')
    self.Socket:settimeout(99999999, 't')
    self.Socket:connect('sx-bol.eu', 80)
    self.Url = url
    self.Started = false
    self.LastPrint = ""
    self.File = ""
end
function _ScriptUpdate:Base64Encode(data)
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
function _ScriptUpdate:GetOnlineVersion()
    if self.GotScriptVersion then return end
    self.Receive, self.Status, self.Snipped = self.Socket:receive(1024)
    if self.Status == 'timeout' and not self.Started then
        self.Started = true
        self.Socket:send("GET "..self.Url.." HTTP/1.1\r\nHost: sx-bol.eu\r\n\r\n")
    end
    if (self.Receive or (#self.Snipped > 0)) and not self.RecvStarted then
        self.RecvStarted = true
        local recv,sent,time = self.Socket:getstats()
        self.DownloadStatus = 'Downloading VersionInfo (0%)'
    end
    self.File = self.File .. (self.Receive or self.Snipped)
    if self.File:find('</size>') then
        if not self.Size then
            self.Size = tonumber(self.File:sub(self.File:find('<si'..'ze>')+6,self.File:find('</s'..'ize>')-1)) + self.File:len()
        end
        self.DownloadStatus = 'Downloading VersionInfo ('..math.round(100/self.Size*self.File:len(),2)..'%)'
    end
    if not (self.Receive or (#self.Snipped > 0)) and self.RecvStarted and self.Size and math.round(100/self.Size*self.File:len(),2) > 95 then
        self.DownloadStatus = 'Downloading VersionInfo (100%)'
        local HeaderEnd, ContentStart = self.File:find('<scr'..'ipt>')
        local ContentEnd, _ = self.File:find('</sc'..'ript>')
        if not ContentStart or not ContentEnd then
            if self.CallbackError and type(self.CallbackError) == 'function' then
                self.CallbackError()
            end
        else
            self.OnlineVersion = tonumber(self.File:sub(ContentStart + 1,ContentEnd-1))
            if self.OnlineVersion~=nil and self.OnlineVersion > self.LocalVersion then
                if self.CallbackNewVersion and type(self.CallbackNewVersion) == 'function' then
                    self.CallbackNewVersion(self.OnlineVersion,self.LocalVersion)
                end
                self:CreateSocket(self.ScriptPath)
                self.DownloadStatus = 'Connect to Server for ScriptDownload'
                AddTickCallback(function() self:DownloadUpdate() end)
            else
                if self.CallbackNoUpdate and type(self.CallbackNoUpdate) == 'function' then
                    self.CallbackNoUpdate(self.LocalVersion)
                end
            end
        end
        self.GotScriptVersion = true
    end
end
function _ScriptUpdate:DownloadUpdate()
    if self.GotScriptUpdate then return end
    self.Receive, self.Status, self.Snipped = self.Socket:receive(1024)
    if self.Status == 'timeout' and not self.Started then
        self.Started = true
        self.Socket:send("GET "..self.Url.." HTTP/1.1\r\nHost: sx-bol.eu\r\n\r\n")
    end
    if (self.Receive or (#self.Snipped > 0)) and not self.RecvStarted then
        self.RecvStarted = true
        local recv,sent,time = self.Socket:getstats()
        self.DownloadStatus = 'Downloading Script (0%)'
    end
    self.File = self.File .. (self.Receive or self.Snipped)
    if self.File:find('</si'..'ze>') then
        if not self.Size then
            self.Size = tonumber(self.File:sub(self.File:find('<si'..'ze>')+6,self.File:find('</si'..'ze>')-1)) + self.File:len()
        end
        self.DownloadStatus = 'Downloading Script ('..math.round(100/self.Size*self.File:len(),2)..'%)'
    end
    if not (self.Receive or (#self.Snipped > 0)) and self.RecvStarted and math.round(100/self.Size*self.File:len(),2) > 95 then
        self.DownloadStatus = 'Downloading Script (100%)'
        local HeaderEnd, ContentStart = self.File:find('<sc'..'ript>')
        local ContentEnd, _ = self.File:find('</scr'..'ipt>')
        if not ContentStart or not ContentEnd then
            if self.CallbackError and type(self.CallbackError) == 'function' then
                self.CallbackError()
            end
        else
            local f = io.open(self.SavePath,"w+b")
            f:write(self.File:sub(ContentStart + 1,ContentEnd-1))
            f:close()
            if self.CallbackUpdate and type(self.CallbackUpdate) == 'function' then
                self.CallbackUpdate(self.OnlineVersion,self.LocalVersion)
            end
        end
        self.GotScriptUpdate = true
    end
end
function Update()
	if not autoupdate then return end
	local scriptName = "ZileanMaster"
    local ToUpdate = {}
    ToUpdate.Version = version
    ToUpdate.UseHttps = true
    ToUpdate.Host = "raw.githubusercontent.com"
    ToUpdate.VersionPath = "/kokosik1221/bol/master/"..scriptName..".version"
    ToUpdate.ScriptPath = "/kokosik1221/bol/master/"..scriptName..".lua"
    ToUpdate.SavePath = SCRIPT_PATH.._ENV.FILE_NAME
    ToUpdate.CallbackUpdate = function(NewVersion,OldVersion) PrintMessage("Updated to "..NewVersion..". Please reload with 2x F9.") end
    ToUpdate.CallbackNoUpdate = function(OldVersion) PrintMessage("No Updates Found.") end
    ToUpdate.CallbackNewVersion = function(NewVersion) PrintMessage("New Version found ("..NewVersion..").") end
    ToUpdate.CallbackError = function(NewVersion) PrintMessage("Error while downloading.") end
    _ScriptUpdate(ToUpdate.Version, ToUpdate.UseHttps, ToUpdate.Host, ToUpdate.VersionPath, ToUpdate.ScriptPath, ToUpdate.SavePath, ToUpdate.CallbackUpdate,ToUpdate.CallbackNoUpdate, ToUpdate.CallbackNewVersion,ToUpdate.CallbackError)
end
function PrintMessage(message)
    print("<font color=\"#FF0000\"><b>" .. "ZileanMaster" .. ":</b></font> <font color=\"#FFFFFF\">" .. message .. "</font>") 
end
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
end

local Items = {
	BWC = { id = 3144, range = 400, reqTarget = true, slot = nil },
	DFG = { id = 3128, range = 750, reqTarget = true, slot = nil },
	HGB = { id = 3146, range = 400, reqTarget = true, slot = nil },
	BFT = { id = 3188, range = 750, reqTarget = true, slot = nil },
}
 
local Q = {name = "Time Bomb", range = 900, speed = 1800, delay = 0.25, width = 100, Ready = function() return myHero:CanUseSpell(_Q) == READY end}
local W = {name = "Rewind", Ready = function() return myHero:CanUseSpell(_W) == READY end}
local E = {name = "Time Warp", range = 700, Ready = function() return myHero:CanUseSpell(_E) == READY end}
local R = {name = "Chronoshift", range = 900, Ready = function() return myHero:CanUseSpell(_R) == READY end}
local recall, MAQCel = false, false
local LastCheck = os.clock()*100
local LastCheck2 = os.clock()*100
local EnemyMinions = minionManager(MINION_ENEMY, Q.range, myHero, MINION_SORT_MAXHEALTH_DEC)
local JungleMinions = minionManager(MINION_JUNGLE, Q.range, myHero, MINION_SORT_MAXHEALTH_DEC)
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
	DelayAction(function()
		Update()
	end,0.1)
	Menu()
	SSpells = SumSpells()
	print("<b><font color=\"#FF0000\">Zilean Master:</font></b> <font color=\"#FFFFFF\">Good luck and give me feedback!</font>")
	if _G.MMA_Loaded then
		print("<b><font color=\"#FF0000\">Zilean Master:</font></b> <font color=\"#FFFFFF\">MMA Support Loaded.</font>")
	end
	if _G.AutoCarry then
		print("<b><font color=\"#FF0000\">Zilean Master:</font></b> <font color=\"#FFFFFF\">SAC Support Loaded.</font>")
	end
end

function OnTick()
	Check()
	if MenuZilean.comboConfig.CEnabled and not recall then
		if ((myHero.mana/myHero.maxMana)*100) >= MenuZilean.comboConfig.manac then
			Combo()
		end
	end
	if MenuZilean.comboConfig.CEnabled2 then
		StunCombo()
	end
	if (MenuZilean.harrasConfig.HEnabled or MenuZilean.harrasConfig.HTEnabled) and not recall then
		if ((myHero.mana/myHero.maxMana)*100) >= MenuZilean.harrasConfig.manah then
			Harrass()
		end
	end
	if MenuZilean.farm.LaneClear and ((myHero.mana/myHero.maxMana)*100) >= MenuZilean.farm.manaf and not recall then
		Farm()
	end
	if MenuZilean.jf.JFEnabled and ((myHero.mana/myHero.maxMana)*100) >= MenuZilean.jf.manajf and not recall then
		JungleFarmm()
	end
	if MenuZilean.prConfig.AZ and not recall then
		autozh()
	end
	if MenuZilean.prConfig.ALS then
		autolvl()
	end
	if not recall then
		KillSteall()
		Support()
	end
	if MenuZilean.uConfig.UAU and not recall then
		AutoULT()
	end
end

function Menu()
	MenuZilean = scriptConfig("Zilean Master "..version, "Zilean Master "..version)
	MenuZilean:addParam("orb", "Orbwalker:", SCRIPT_PARAM_LIST, 1, {"SxOrb","SAC:R/MMA"}) 
	MenuZilean:addParam("qqq", "If You Change Orb. Click 2x F9", SCRIPT_PARAM_INFO,"")
	if MenuZilean.orb == 1 then
		MenuZilean:addSubMenu("[Zilean Master]: Orbwalking", "Orbwalking")
		SxOrb:LoadToMenu(MenuZilean.Orbwalking)
	end
	TargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, Q.range, DAMAGE_MAGIC)
	TargetSelector.name = "Zilean"
	MenuZilean:addTS(TargetSelector)
	MenuZilean:addSubMenu("[Zilean Master]: Combo Settings", "comboConfig")
	MenuZilean.comboConfig:addParam("USEQ", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	MenuZilean.comboConfig:addParam("USEW", "Use " .. W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
	MenuZilean.comboConfig:addParam("USEE", "Use " .. E.name .. " (E)", SCRIPT_PARAM_ONOFF, true)
	MenuZilean.comboConfig:addParam("ST", "Focus Selected Target", SCRIPT_PARAM_ONOFF, false)
	MenuZilean.comboConfig:addParam("CEnabled", "Full Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	MenuZilean.comboConfig:addParam("CEnabled2", "Stun Combo", SCRIPT_PARAM_ONKEYDOWN, false,  string.byte("T"))
	MenuZilean.comboConfig:addParam("manac", "Min. Mana To Cast Combo", SCRIPT_PARAM_SLICE, 10, 0, 100, 0)
	MenuZilean:addSubMenu("[Zilean Master]: Harras Settings", "harrasConfig")
    MenuZilean.harrasConfig:addParam("QH", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	MenuZilean.harrasConfig:addParam("EH", "Use " .. E.name .. " (E)", SCRIPT_PARAM_ONOFF, true)
	MenuZilean.harrasConfig:addParam("HEnabled", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
	MenuZilean.harrasConfig:addParam("HTEnabled", "Harass Toggle", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("L"))
	MenuZilean.harrasConfig:addParam("manah", "Min. Mana To Harrass", SCRIPT_PARAM_SLICE, 60, 0, 100, 0)
	MenuZilean:addSubMenu("[Zilean Master]: Ultimate Settings", "uConfig")
	for i = 1, heroManager.iCount do
		local hero = heroManager:GetHero(i)
		if hero.team == myHero.team then
			MenuZilean.uConfig:addParam(hero.charName, hero.charName, SCRIPT_PARAM_ONOFF, true)
		end
	end
	MenuZilean.uConfig:addParam("UAUHP", "Min. HP% To Use", SCRIPT_PARAM_SLICE, 10, 0, 50, 0)
    MenuZilean.uConfig:addParam("UAU", "Use Auto Ultimate", SCRIPT_PARAM_ONOFF, true)
	MenuZilean:addSubMenu("[Zilean Master]: Support Settings", "ss")
	MenuZilean.ss:addParam("qqq", "---- Mikael's Crucible ----", SCRIPT_PARAM_INFO,"")
	MenuZilean.ss:addParam("mchp", "Min. Hero HP% To Use", SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
	MenuZilean.ss:addParam("umc", "Use Mikael's Crucible", SCRIPT_PARAM_ONOFF, true)
	MenuZilean.ss:addParam("sep", "",                          SCRIPT_PARAM_INFO, "")
	MenuZilean.ss:addParam("qqq", "---- Frost Queen's Claim ----", SCRIPT_PARAM_INFO,"")
	MenuZilean.ss:addParam("fqhp", "Min. Enemy HP% To Use", SCRIPT_PARAM_SLICE, 60, 0, 100, 0)
	MenuZilean.ss:addParam("ufq", "Use Frost Queen's Claim", SCRIPT_PARAM_ONOFF, true)
	MenuZilean.ss:addParam("sep", "",                          SCRIPT_PARAM_INFO, "")
	MenuZilean.ss:addParam("qqq", "---- Locket of the Iron Solari ----", SCRIPT_PARAM_INFO,"")
	MenuZilean.ss:addParam("ishp", "Min. Hero HP% To Use", SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
	MenuZilean.ss:addParam("uis", "Use Locket of the Iron Solari", SCRIPT_PARAM_ONOFF, true)
	MenuZilean.ss:addParam("sep", "",                          SCRIPT_PARAM_INFO, "")
	MenuZilean.ss:addParam("qqq", "---- Twin Shadows ----", SCRIPT_PARAM_INFO,"")
	MenuZilean.ss:addParam("tshp", "Min. Enemy HP% To Use", SCRIPT_PARAM_SLICE, 60, 0, 100, 0)
	MenuZilean.ss:addParam("uts", "Use Twin Shadows", SCRIPT_PARAM_ONOFF, true)
	MenuZilean.ss:addParam("sep", "",                          SCRIPT_PARAM_INFO, "")
	MenuZilean.ss:addParam("qqq", "---- Exhaust ----", SCRIPT_PARAM_INFO,"")
	MenuZilean.ss:addParam("exhp", "Min. Enemy HP% To Use", SCRIPT_PARAM_SLICE, 60, 0, 100, 0)
	MenuZilean.ss:addParam("uex", "Use Exhaust", SCRIPT_PARAM_ONOFF, true)
	MenuZilean.ss:addParam("sep", "",                          SCRIPT_PARAM_INFO, "")
	MenuZilean.ss:addParam("qqq", "---- Heal ----", SCRIPT_PARAM_INFO,"")
	MenuZilean.ss:addParam("hhp", "Min. Hero HP% To Use", SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
	MenuZilean.ss:addParam("uh", "Use Heal", SCRIPT_PARAM_ONOFF, true)
	MenuZilean:addSubMenu("[Zilean Master]: KS Settings", "ksConfig")
	MenuZilean.ksConfig:addParam("IKS", "Use Ignite To KS", SCRIPT_PARAM_ONOFF, true)
	MenuZilean.ksConfig:addParam("QKS", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	MenuZilean:addSubMenu("[Zilean Master]: Farm Settings", "farm")
	MenuZilean.farm:addParam("QF", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_LIST, 3, { "No", "Freezing", "LaneClear"})
	MenuZilean.farm:addParam("WF", "Use " .. W.name .. " (W)", SCRIPT_PARAM_LIST, 2, { "No", "LaneClear"})
	MenuZilean.farm:addParam("LaneClear", "LaneClear", SCRIPT_PARAM_ONKEYDOWN, false,   string.byte("V"))
	MenuZilean.farm:addParam("manaf", "Min. Mana To Farm", SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
	MenuZilean:addSubMenu("[Zilean Master]: Jungle Farm", "jf")
	MenuZilean.jf:addParam("QJF", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	MenuZilean.jf:addParam("WJF", "Use " .. W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
	MenuZilean.jf:addParam("JFEnabled", "Jungle Farm", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("V"))
	MenuZilean.jf:addParam("manajf", "Min. Mana To Jungle Farm", SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
	MenuZilean:addSubMenu("[Zilean Master]: Draw Settings", "drawConfig")
	MenuZilean.drawConfig:addParam("DD", "Draw DMG Text", SCRIPT_PARAM_ONOFF, true)
	MenuZilean.drawConfig:addParam("DST", "Draw Selected Target", SCRIPT_PARAM_ONOFF, true)
	MenuZilean.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuZilean.drawConfig:addParam("DER", "Draw E Range", SCRIPT_PARAM_ONOFF, true)
	MenuZilean.drawConfig:addParam("DERC", "Draw E Range Color", SCRIPT_PARAM_COLOR, {255,255,0,0})
	MenuZilean.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuZilean.drawConfig:addParam("DRR", "Draw Q&R Range", SCRIPT_PARAM_ONOFF, true)
	MenuZilean.drawConfig:addParam("DRRC", "Draw Q&R Range Color", SCRIPT_PARAM_COLOR, {255, 0, 255, 0})
	MenuZilean:addSubMenu("[Zilean Master]: Misc Settings", "prConfig")
	MenuZilean.prConfig:addParam("pc", "Use Packets To Cast Spells(VIP)", SCRIPT_PARAM_ONOFF, false)
	MenuZilean.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuZilean.prConfig:addParam("AZ", "Use Auto Zhonya", SCRIPT_PARAM_ONOFF, true)
	MenuZilean.prConfig:addParam("AZHP", "Min HP To Cast Zhonya", SCRIPT_PARAM_SLICE, 20, 0, 100, 0)
	MenuZilean.prConfig:addParam("AZMR", "Must Have 0 Enemy In Range:", SCRIPT_PARAM_SLICE, 900, 0, 1500, 0)
	MenuZilean.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuZilean.prConfig:addParam("ALS", "Auto lvl skills", SCRIPT_PARAM_ONOFF, false)
	MenuZilean.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuZilean.prConfig:addParam("pro", "Prodiction To Use:", SCRIPT_PARAM_LIST, 1, {"VPrediction","DivinePred"}) 
	MenuZilean.comboConfig:permaShow("CEnabled")
	MenuZilean.harrasConfig:permaShow("HEnabled")
	MenuZilean.harrasConfig:permaShow("HTEnabled")
	MenuZilean.farm:permaShow("LaneClear")
	MenuZilean.jf:permaShow("JFEnabled")
	MenuZilean.prConfig:permaShow("AZ")
	MenuZilean.prConfig:permaShow("ALS")
	if heroManager.iCount < 10 then
		print("<font color=\"#FF0000\">Too few champions to arrange priority.</font>")
	elseif heroManager.iCount == 6 then
		arrangePrioritysTT()
    else
		arrangePrioritys()
	end
end

function Check()
	if SelectedTarget ~= nil and ValidTarget(SelectedTarget, Q.range) then
		Cel = SelectedTarget
	else
		Cel = GetCustomTarget()
	end
	if MenuZilean.orb == 1 then
		SxOrb:ForceTarget(Cel)
	end
end

function Combo()
	UseItems(Cel)
	if 30 < os.clock() * 100 - LastCheck then
	if MenuZilean.comboConfig.USEQ and ValidTarget(Cel, Q.range) then
		CastQ(Cel)
	end
	if MenuZilean.comboConfig.USEE and ValidTarget(Cel, E.range) then
		CastE(Cel)
	end
	if MenuZilean.comboConfig.USEW and ValidTarget(Cel, Q.range) and not Q.Ready() or not E.Ready() then
		CastW()
	end
	LastCheck = os.clock() * 100
	end
end

function StunCombo()
	CheckBomb()
	local QMana = myHero:GetSpellData(_Q).mana
    local WMana = myHero:GetSpellData(_W).mana
	if Q.Ready() and W.Ready() and ValidTarget(Cel, Q.range) and myHero.mana >= (QMana*2) + WMana then
		CastQ(Cel)
	end
	if MAQCel then
		if not Q.Ready() then
			CastW()
		end
		if Q.Ready() and ValidTarget(Cel, Q.range) then
			CastQ(Cel)
		end
	end
end

function CheckBomb()
	if Cel then
		for i = 1, Cel.buffCount do
			local buf = Cel:getBuff(i)
			if BuffIsValid(buf) then
				MAQCel = false
				if buf.name == "zileanqenemybomb" then
					MAQCel = true
				end
			end
		end
	end
end

function Harrass()
	if 30 < os.clock() * 100 - LastCheck then
	if MenuZilean.harrasConfig.QH and ValidTarget(Cel, Q.range) then
		CastQ(Cel)
	end
	if MenuZilean.harrasConfig.EH and ValidTarget(Cel, E.range) then
		CastE(Cel)
	end
	LastCheck = os.clock() * 100
	end
end

function Farm()
	EnemyMinions:update()
	local QMode =  MenuZilean.farm.QF
	local WMode =  MenuZilean.farm.WF
	for i, minion in pairs(EnemyMinions.objects) do
		if QMode == 3 then
			if Q.Ready() and minion ~= nil and ValidTarget(minion, Q.range) then
				local Pos, Hit = BestQFarmPos(Q.range, Q.width, EnemyMinions.objects)
				if Pos ~= nil then
					CastSpell(_Q, Pos.x, Pos.z)
				end
			end
		elseif QMode == 2 then
			if Q.Ready() and minion ~= nil and ValidTarget(minion, Q.range) then
				if minion.health <= getDmg("Q", minion, myHero, 3) then
					CastQ(minion)
				end
			end
		end
		if WMode == 2 and QMode == 3 then
			if W.Ready() and minion ~= nil and ValidTarget(minion, W.range) and not Q.Ready() then
				CastW()
			end
		end
	end
end

function JungleFarmm()
	JungleMinions:update()
	for i, minion in pairs(JungleMinions.objects) do
		if MenuZilean.jf.QJF then
			if Q.Ready() and minion ~= nil and ValidTarget(minion, Q.range) then
				CastQ(minion)
			end
		end
		if MenuZilean.jf.WJF then
			if W.Ready() and minion ~= nil and ValidTarget(minion, W.range) and not Q.Ready() then
				CastW()
			end
		end
	end
end

function KillSteall()
	for _, Enemy in pairs(GetEnemyHeroes()) do
		local hp = Enemy.health
		local QDMG = getDmg("Q", Enemy, myHero, 3)
		local IDMG = 50 + (20 * myHero.level)
		if Enemy ~= nil and ValidTarget(Enemy, Q.range) then
			if 30 < os.clock() * 100 - LastCheck2 then
			local IReady = SSpells:Ready("summonerdot")
			if IReady and hp < IDMG and MenuZilean.ksConfig.IKS and ValidTarget(Enemy, 600) then
				CastSpell(SSpells:GetSlot("summonerdot"), Enemy)
			elseif hp < QDMG and MenuZilean.ksConfig.QKS and ValidTarget(Enemy, Q.range) then
				CastQ(Enemy)
			end
			LastCheck2 = os.clock() * 100
			end
		end
	end
end

function AutoULT()
	for i = 1, heroManager.iCount do
		local hero = heroManager:GetHero(i)
		if hero.team == myHero.team and GetDistance(hero) <= R.range then
			if ((hero.health/hero.maxHealth)*100) < MenuZilean.uConfig.UAUHP and MenuZilean.uConfig[hero.charName] then
				CastR(hero)
			end
		end
	end
end

function autozh()
	local count = EnemyCount(myHero, MenuZilean.prConfig.AZMR)
	local zhonyaslot = GetInventorySlotItem(3157)
	local zhonyaready = (zhonyaslot ~= nil and myHero:CanUseSpell(zhonyaslot) == READY)
	if zhonyaready and ((myHero.health/myHero.maxHealth)*100) < MenuZilean.prConfig.AZHP and count == 0 then
		CastSpell(zhonyaslot)
	end
end

function autolvl()
	if not MenuZilean.prConfig.ALS then return end
	if myHero.level > GetHeroLeveled() then
		local a = {_Q,_W,_Q,_E,_Q,_R,_W,_W,_W,_W,_R,_E,_E,_E,_E,_R,_Q,_Q}
		LevelSpell(a[GetHeroLeveled() + 1])
	end
end

function DmgCalc()
	for _,enemy in pairs(GetEnemyHeroes()) do
        if not enemy.dead and enemy.visible and GetDistance(enemy) < 3000 then
			local QDMG = getDmg("Q", enemy, myHero, 3)
			local IDMG = (50 + (20 * myHero.level))
			if enemy.health > ((QDMG*2) + IDMG) then
				killstring[enemy.networkID] = "Harass Him!!!"
			elseif enemy.health < IDMG then
				killstring[enemy.networkID] = "Ignite Kill!"
			elseif enemy.health < QDMG then
				killstring[enemy.networkID] = "Q Kill!"
			elseif enemy.health < 2*QDMG then
				killstring[enemy.networkID] = "2xQ Kill!"
			end
		end
	end
end

function OnDraw()
	if MenuZilean.drawConfig.DST and MenuZilean.comboConfig.ST then
		if SelectedTarget ~= nil and not SelectedTarget.dead then
			DrawCircle2(SelectedTarget.x, SelectedTarget.y, SelectedTarget.z, 100, RGB(MenuZilean.drawConfig.DQRC[2], MenuZilean.drawConfig.DQRC[3], MenuZilean.drawConfig.DQRC[4]))
		end
	end
	if MenuZilean.drawConfig.DD then
		for _,enemy in pairs(GetEnemyHeroes()) do
			DmgCalc()
            if ValidTarget(enemy, 1500) and killstring[enemy.networkID] ~= nil then
                local pos = WorldToScreen(D3DXVECTOR3(enemy.x, enemy.y, enemy.z))
                DrawText(killstring[enemy.networkID], 20, pos.x - 35, pos.y - 10, 0xFFFFFF00)
            end
        end
	end
	if MenuZilean.drawConfig.DER and E.Ready() then			
		DrawCircle2(myHero.x, myHero.y, myHero.z, E.range, RGB(MenuZilean.drawConfig.DERC[2], MenuZilean.drawConfig.DERC[3], MenuZilean.drawConfig.DERC[4]))
	end
	if MenuZilean.drawConfig.DRR and Q.Ready() or R.Ready() then			
		DrawCircle2(myHero.x, myHero.y, myHero.z, R.range, RGB(MenuZilean.drawConfig.DRRC[2], MenuZilean.drawConfig.DRRC[3], MenuZilean.drawConfig.DRRC[4]))
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
end

function OnRemoveBuff(unit, buff)
	if unit and unit.isMe and buff and buff.name == "Recall" then
		recall = false
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

function Support()
	if MenuZilean.ss.umc then
		local mikael = GetInventorySlotItem(3222)
		local mikaelready = (mikael ~= nil and (myHero:CanUseSpell(mikael) == READY))
		for i = 1, heroManager.iCount do
			local hero = heroManager:GetHero(i)
			if hero.team == myHero.team then
				if ValidTarget(hero, 750) and ((((hero.health/hero.maxHealth)*100) < MenuZilean.ss.mchp) or HaveBuff(hero)) then
					if mikaelready then
						CastSpell(mikael)
					end
				end
			end
		end
	end
	if MenuZilean.ss.ufq then
		local frost = GetInventorySlotItem(3092)
		local frostready = (frost ~= nil and (myHero:CanUseSpell(frost) == READY))
		for i, enemy in ipairs(GetEnemyHeroes()) do
			if ValidTarget(enemy, 880) and ((enemy.health/enemy.maxHealth)*100) < MenuZilean.ss.fqhp then
				if frostready then
					CastSpell(frost, enemy.x, enemy.z)
				end
			end
		end
	end
	if MenuZilean.ss.uis then
		local solari = GetInventorySlotItem(3190)
		local solariready = (solari ~= nil and (myHero:CanUseSpell(solari) == READY))
		for i = 1, heroManager.iCount do
			local hero = heroManager:GetHero(i)
			if hero.team == myHero.team then
				if ValidTarget(hero, 700) and ((hero.health/hero.maxHealth)*100) < MenuZilean.ss.ishp then
					if solariready then
						CastSpell(solari)
					end
				end
			end
		end
	end
	if MenuZilean.ss.uts then
		local twin = GetInventorySlotItem(3023)
		local twinready = (twin ~= nil and (myHero:CanUseSpell(twin) == READY))
		for i, enemy in ipairs(GetEnemyHeroes()) do
			if ValidTarget(enemy, 1000) and ((enemy.health/enemy.maxHealth)*100) < MenuZilean.ss.tshp then
				if twinready then
					CastSpell(twin)
				end
			end
		end
	end
	if MenuZilean.ss.uex then
		for i, enemy in ipairs(GetEnemyHeroes()) do
			if ValidTarget(enemy, 550) and ((enemy.health/enemy.maxHealth)*100) < MenuZilean.ss.exhp then
				local ExhaustReady = SSpells:Ready("summonerexhaust")
				if ExhaustReady then
					CastSpell(SSpells:GetSlot("summonerexhaust"), enemy)
				end
			end
		end
	end
	if MenuZilean.ss.uh then
		for i = 1, heroManager.iCount do
			local hero = heroManager:GetHero(i)
			if hero.team == myHero.team then
				if ValidTarget(hero, 700) and ((hero.health/hero.maxHealth)*100) < MenuZilean.ss.hhp then
					local HealReady = SSpells:Ready("summonerheal")
					if HealReady then
						CastSpell(SSpells:GetSlot("summonerheal"), enemy)
					end
				end
			end
		end
	end
end

function HaveBuff(unit)
	for i = 1, unit.buffCount, 1 do      
        local buff = unit:getBuff(i) 
        if (buff.valid == true) and (buff.type == BUFF_STUN or buff.type == BUFF_ROOT or buff.type == BUFF_FEAR or buff.type == BUFF_TAUNT or buff.type == BUFF_SILENCE) then
            return true                     
        end                    
    end
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
        local hit = CountObjectsNearPos(object or object, range, radius, objects)
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

function CastQ(unit)
	if Q.Ready() then
		if MenuZilean.prConfig.pro == 1 then
			local CastPosition,  HitChance,  Position = VP:GetCircularAOECastPosition(unit, Q.delay, Q.width, Q.range, Q.speed, myHero)
			if CastPosition and HitChance >= 2 then
				if VIP_USER and MenuZilean.prConfig.pc then
					Packet("S_CAST", {spellId = _Q, fromX = CastPosition.x, fromY = CastPosition.z, toX = CastPosition.x, toY = CastPosition.z}):send()
				else
					CastSpell(_Q, CastPosition.x, CastPosition.z)
				end	
			end
		end
		if MenuZilean.prConfig.pro == 2 and VIP_USER then
			local unit = DPTarget(unit)
			local ZilQ = CircleSS(Q.speed, Q.range, Q.width, Q.delay*1000, math.huge)
			local State, Position, perc = DP:predict(unit, ZilQ, 2)
			if State == SkillShot.STATUS.SUCCESS_HIT then 
				if VIP_USER and MenuZilean.prConfig.pc then
					Packet("S_CAST", {spellId = _Q, fromX = Position.x, fromY = Position.z, toX = Position.x, toY = Position.z}):send()
				else
					CastSpell(_Q, Position.x, Position.z)
				end
			end
		end
	end
end

function CastW()
	if W.Ready() then
		if VIP_USER and MenuZilean.prConfig.pc then
			Packet("S_CAST", {spellId = _W}):send()
		else
			CastSpell(_W)
		end
	end
end

function CastE(unit)
	if E.Ready() then
		if VIP_USER and MenuZilean.prConfig.pc then
			Packet("S_CAST", {spellId = _E, targetNetworkId = unit.networkID}):send()
		else
			CastSpell(_E, unit)
		end
	end
end

function CastR(unit)
	if R.Ready() then
		if VIP_USER and MenuZilean.prConfig.pc then
			Packet("S_CAST", {spellId = _R, targetNetworkId = unit.networkID}):send()
		else
			CastSpell(_R, unit)
		end
	end
end

function OnWndMsg(Msg, Key)
	if Msg == WM_LBUTTONDOWN and MenuZilean.comboConfig.ST then
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
				if MenuZilean.comboConfig.ST then 
					print("Target unselected: "..Selecttarget.charName) 
				end
			else
				SelectedTarget = Selecttarget
				if MenuZilean.comboConfig.ST then 
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

class 'SumSpells'
function SumSpells:__init()
	names = {"summonerdot", "summonerflash", "summonerexhaust", "summonerheal", "summonersmite"}
end

function SumSpells:Ready(name)
	local Ready = false
	local Spel = self:GetSlot(name)
	Ready = (Spel ~= nil and myHero:CanUseSpell(Spel) == READY)
	return Ready
end

function SumSpells:GetSlot(name)
	if myHero:GetSpellData(SUMMONER_1).name == name then 
		return SUMMONER_1 
	end
	if myHero:GetSpellData(SUMMONER_2).name == name then 
		return SUMMONER_2 
	end
end

-----SCRIPT STATUS------------
assert(load(Base64Decode("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"), nil, "bt", _ENV))() ScriptStatus("OBECFJCEEDB") 
