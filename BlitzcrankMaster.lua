--[[

	Script Name: Blitzcrank MASTER 
    Author: kokosik1221
	Last Version: 1.35
	10.04.2015

]]--


if myHero.charName ~= "Blitzcrank" then return end

local autoupdate = true
local version = 1.35
 
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
	local scriptName = "BlitzcrankMaster"
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
    print("<font color=\"#FF0000\"><b>" .. "BlitzcrankMaster" .. ":</b></font> <font color=\"#FFFFFF\">" .. message .. "</font>") 
end
if FileExist(LIB_PATH .. "/SxOrbWalk.lua") then
	require("SxOrbWalk")
end
if FileExist(LIB_PATH .. "/VPrediction.lua") then
	require("VPrediction")
	VP = VPrediction()
end
if VIP_USER and FileExist(LIB_PATH .. "/Prodiction.lua") then
	require("Prodiction")
	prodstatus = true
end
if VIP_USER and FileExist(LIB_PATH .. "/DivinePred.lua") then 
	require "DivinePred" 
	DP = DivinePred()
end

local Counterspells = {
	['KatarinaR'] = {charName = "Katarina", spellSlot = "R"},
	['GalioIdolOfDurand'] = {charName = "Galio", spellSlot = "R"},
	['Crowstorm'] = {charName = "FiddleSticks", spellSlot = "R"},
	['Drain'] = {charName = "FiddleSticks", spellSlot = "W"},
	['AbsoluteZero'] = {charName = "Nunu", spellSlot = "R"},
	['ShenStandUnited'] = {charName = "Shen", spellSlot = "R"},
	['UrgotSwap2'] = {charName = "Urgot", spellSlot = "R"},
	['AlZaharNetherGrasp'] = {charName = "Malzahar", spellSlot = "R"},
	['FallenOne'] = {charName = "Karthus", spellSlot = "R"},
	['Pantheon_GrandSkyfall_Jump'] = {charName = "Pantheon", spellSlot = "R"},
	['CaitlynAceintheHole'] = {charName = "Caitlyn", spellSlot = "R"},
	['MissFortuneBulletTime'] = {charName = "MissFortune", spellSlot = "R"},
	['InfiniteDuress'] = {charName = "Warwick", spellSlot = "R"},
	['Meditate'] = {},
	['Teleport'] = {},
}

local Items = {
	BWC = { id = 3144, range = 400, reqTarget = true, slot = nil },
	DFG = { id = 3128, range = 750, reqTarget = true, slot = nil },
	HGB = { id = 3146, range = 400, reqTarget = true, slot = nil },
	BFT = { id = 3188, range = 750, reqTarget = true, slot = nil },
}

local Q = {name = "Rocket Grab", range = 1050, speed = 1800, delay = 0.25, width = 75, Ready = function() return myHero:CanUseSpell(_Q) == READY end}
local W = {name = "Overdrive", Ready = function() return myHero:CanUseSpell(_W) == READY end}
local E = {name = "Power Fist", range = myHero.range+130, Ready = function() return myHero:CanUseSpell(_E) == READY end}
local R = {name = "Static Field", range = 600, Ready = function() return myHero:CanUseSpell(_R) == READY end}
local recall, ExhaustReady, HealReady = false, false, false
local EnemyMinions = minionManager(MINION_ENEMY, Q.range, myHero, MINION_SORT_MAXHEALTH_DEC)
local JungleMinions = minionManager(MINION_JUNGLE, Q.range, myHero, MINION_SORT_MAXHEALTH_DEC)
local AllCastGrabCount, FailGrabCount, PrecentGrabCount, SuccesGrabCount = 0, 0, 0, 0
local LastCheck = os.clock()*100
local LastCheck2 = os.clock()*100
local killstring = {}
local Spells = {_Q,_W,_E,_R}
local Spells2 = {"Q","W","E","R"}
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
	print("<b><font color=\"#FF0000\">Blitzcrank Master:</font></b> <font color=\"#FFFFFF\">Good luck and give me feedback!</font>")
	if _G.MMA_Loaded then
		print("<b><font color=\"#FF0000\">Blitzcrank Master:</font></b> <font color=\"#FFFFFF\">MMA Support Loaded.</font>")
	end	
	if _G.AutoCarry then
		print("<b><font color=\"#FF0000\">Blitzcrank Master:</font></b> <font color=\"#FFFFFF\">SAC Support Loaded.</font>")
	end
end

function OnTick()
	Check()
	if MenuBlitz.comboConfig.CEnabled and ((myHero.mana/myHero.maxMana)*100) >= MenuBlitz.comboConfig.manac and not recall then
		Combo()
	end
	if (MenuBlitz.harrasConfig.HEnabled or MenuBlitz.harrasConfig.HTEnabled) and ((myHero.mana/myHero.maxMana)*100) >= MenuBlitz.harrasConfig.manah and not recall then
		Harrass()
	end
	if MenuBlitz.farm.LaneClear and ((myHero.mana/myHero.maxMana)*100) >= MenuBlitz.farm.manaf and not recall then
		Farm()
	end
	if MenuBlitz.jf.JFEnabled and ((myHero.mana/myHero.maxMana)*100) >= MenuBlitz.jf.manajf and not recall then
		JungleFarmm()
	end
	if MenuBlitz.prConfig.AZ and not recall then
		autozh()
	end
	if MenuBlitz.prConfig.ALS and not recall then
		autolvl()
	end
	if not recall then
		KillSteall()
		Support()
	end
end


function Menu()
	MenuBlitz = scriptConfig("Blitzcrank Master "..version, "Blitzcrank Master "..version)
	MenuBlitz:addParam("orb", "Orbwalker:", SCRIPT_PARAM_LIST, 1, {"SxOrb","SAC:R/MMA"}) 
	MenuBlitz:addParam("qqq", "If You Change Orb. Click 2x F9", SCRIPT_PARAM_INFO,"")
	if MenuBlitz.orb == 1 then
		MenuBlitz:addSubMenu("[Blitzcrank Master]: Orbwalking", "Orbwalking")
		SxOrb:LoadToMenu(MenuBlitz.Orbwalking)
	end
	TargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, Q.range, DAMAGE_MAGIC)
	TargetSelector.name = "Blitzcrank"
	MenuBlitz:addTS(TargetSelector)
	MenuBlitz:addSubMenu("[Blitzcrank Master]: Combo Settings", "comboConfig")
	MenuBlitz.comboConfig:addParam("USEQ", "Use " .. Q.name .. "(Q)", SCRIPT_PARAM_ONOFF, true)
	MenuBlitz.comboConfig:addParam("USEQS", "Use Smite If See Collision", SCRIPT_PARAM_ONOFF, true)
	MenuBlitz.comboConfig:addParam("QMINR", "Min. Q Range", SCRIPT_PARAM_SLICE, 250, 0, 500, 0) 
	MenuBlitz.comboConfig:addParam("QMAXR", "Max. Q Range", SCRIPT_PARAM_SLICE, 1000, 500, 1050, 0) 
	MenuBlitz.comboConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBlitz.comboConfig:addParam("USEW", "Use " .. W.name .. "(W)", SCRIPT_PARAM_ONOFF, true)
	MenuBlitz.comboConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBlitz.comboConfig:addParam("USEE", "Use " .. E.name .. "(E)", SCRIPT_PARAM_LIST, 2, {"No", "Normal", "After Success Grab"}) 
	MenuBlitz.comboConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBlitz.comboConfig:addParam("USER", "Use " .. R.name .. "(R)", SCRIPT_PARAM_ONOFF, true)
	MenuBlitz.comboConfig:addParam("Kilable", "Only Use If Target Is Killable", SCRIPT_PARAM_ONOFF, true)
	MenuBlitz.comboConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBlitz.comboConfig:addParam("ST", "Focus Selected Target", SCRIPT_PARAM_ONOFF, false)
	MenuBlitz.comboConfig:addParam("CEnabled", "Full Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	MenuBlitz.comboConfig:addParam("manac", "Min. Mana To Cast Combo", SCRIPT_PARAM_SLICE, 10, 0, 100, 0) 
	MenuBlitz:addSubMenu("[Blitzcrank Master]: Harras Settings", "harrasConfig")
	MenuBlitz.harrasConfig:addParam("HM", "Harrass Mode:", SCRIPT_PARAM_LIST, 1, {"|Q|", "|E|", "|Q|E|"}) 
	MenuBlitz.harrasConfig:addParam("HEnabled", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
	MenuBlitz.harrasConfig:addParam("HTEnabled", "Harass Toggle", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("L"))
	MenuBlitz.harrasConfig:addParam("manah", "Min. Mana To Harrass", SCRIPT_PARAM_SLICE, 50, 0, 100, 0) 
	MenuBlitz.harrasConfig:addParam("MM", "Move To Mouse", SCRIPT_PARAM_ONOFF, true)
	MenuBlitz:addSubMenu("[Blitzcrank Master]: Support Settings", "ss")
	MenuBlitz.ss:addParam("qqq", "---- Mikael's Crucible ----", SCRIPT_PARAM_INFO,"")
	MenuBlitz.ss:addParam("mchp", "Min. Hero HP% To Use", SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
	MenuBlitz.ss:addParam("umc", "Use Mikael's Crucible", SCRIPT_PARAM_ONOFF, true)
	MenuBlitz.ss:addParam("sep", "",                          SCRIPT_PARAM_INFO, "")
	MenuBlitz.ss:addParam("qqq", "---- Frost Queen's Claim ----", SCRIPT_PARAM_INFO,"")
	MenuBlitz.ss:addParam("fqhp", "Min. Enemy HP% To Use", SCRIPT_PARAM_SLICE, 60, 0, 100, 0)
	MenuBlitz.ss:addParam("ufq", "Use Frost Queen's Claim", SCRIPT_PARAM_ONOFF, true)
	MenuBlitz.ss:addParam("sep", "",                          SCRIPT_PARAM_INFO, "")
	MenuBlitz.ss:addParam("qqq", "---- Locket of the Iron Solari ----", SCRIPT_PARAM_INFO,"")
	MenuBlitz.ss:addParam("ishp", "Min. Hero HP% To Use", SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
	MenuBlitz.ss:addParam("uis", "Use Locket of the Iron Solari", SCRIPT_PARAM_ONOFF, true)
	MenuBlitz.ss:addParam("sep", "",                          SCRIPT_PARAM_INFO, "")
	MenuBlitz.ss:addParam("qqq", "---- Twin Shadows ----", SCRIPT_PARAM_INFO,"")
	MenuBlitz.ss:addParam("tshp", "Min. Enemy HP% To Use", SCRIPT_PARAM_SLICE, 60, 0, 100, 0)
	MenuBlitz.ss:addParam("uts", "Use Twin Shadows", SCRIPT_PARAM_ONOFF, true)
	MenuBlitz.ss:addParam("sep", "",                          SCRIPT_PARAM_INFO, "")
	MenuBlitz.ss:addParam("qqq", "---- Exhaust ----", SCRIPT_PARAM_INFO,"")
	MenuBlitz.ss:addParam("exhp", "Min. Enemy HP% To Use", SCRIPT_PARAM_SLICE, 60, 0, 100, 0)
	MenuBlitz.ss:addParam("uex", "Use Exhaust", SCRIPT_PARAM_ONOFF, true)
	MenuBlitz.ss:addParam("sep", "",                          SCRIPT_PARAM_INFO, "")
	MenuBlitz.ss:addParam("qqq", "---- Heal ----", SCRIPT_PARAM_INFO,"")
	MenuBlitz.ss:addParam("hhp", "Min. Hero HP% To Use", SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
	MenuBlitz.ss:addParam("uh", "Use Heal", SCRIPT_PARAM_ONOFF, true)
	MenuBlitz:addSubMenu("[Blitzcrank Master]: KS Settings", "ksConfig")
	MenuBlitz.ksConfig:addParam("IKS", "Use Ignite To KS", SCRIPT_PARAM_ONOFF, true)
	MenuBlitz.ksConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBlitz.ksConfig:addParam("QKS", "Use " .. Q.name .. "(Q)", SCRIPT_PARAM_ONOFF, true)
	MenuBlitz.ksConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBlitz.ksConfig:addParam("EKS", "Use " .. E.name .. "(E)", SCRIPT_PARAM_ONOFF, true)
	MenuBlitz.ksConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBlitz.ksConfig:addParam("RKS", "Use " .. R.name .. "(R)", SCRIPT_PARAM_ONOFF, false)
	MenuBlitz:addSubMenu("[Blitzcrank Master]: LaneClear Settings", "farm")
	MenuBlitz.farm:addParam("QF", "Use " .. Q.name .. "(Q)", SCRIPT_PARAM_ONOFF, true)
	MenuBlitz.farm:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBlitz.farm:addParam("EF", "Use " .. E.name .. "(E)", SCRIPT_PARAM_ONOFF, true)
	MenuBlitz.farm:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBlitz.farm:addParam("LaneClear", "LaneClear", SCRIPT_PARAM_ONKEYDOWN, false,   string.byte("V"))
	MenuBlitz.farm:addParam("manaf", "Min. Mana To Farm", SCRIPT_PARAM_SLICE, 40, 0, 100, 0) 
	MenuBlitz:addSubMenu("[Blitzcrank Master]: Jungle Farm Settings", "jf")
	MenuBlitz.jf:addParam("QJF", "Use " .. Q.name .. "(Q)", SCRIPT_PARAM_ONOFF, true)
	MenuBlitz.jf:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBlitz.jf:addParam("EJF", "Use " .. E.name .. "(E)", SCRIPT_PARAM_ONOFF, true)
	MenuBlitz.jf:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBlitz.jf:addParam("JFEnabled", "Jungle Farm", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("V"))
	MenuBlitz.jf:addParam("manajf", "Min. Mana To Jungle Farm", SCRIPT_PARAM_SLICE, 40, 0, 100, 0) 
	MenuBlitz:addSubMenu("[Blitzcrank Master]: Draw Settings", "drawConfig")
	MenuBlitz.drawConfig:addParam("DD", "Draw DMG Text", SCRIPT_PARAM_ONOFF, true)
	MenuBlitz.drawConfig:addParam("DST", "Draw Selected Target", SCRIPT_PARAM_ONOFF, true)
	MenuBlitz.drawConfig:addParam("DT", "Draw Current Target Name", SCRIPT_PARAM_ONOFF, true)
	MenuBlitz.drawConfig:addParam("DGS", "Draw Grab Stats", SCRIPT_PARAM_ONOFF, true)
	MenuBlitz.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBlitz.drawConfig:addParam("DQL", "Draw Q Collision Line", SCRIPT_PARAM_ONOFF, true)
	MenuBlitz.drawConfig:addParam("DQLC", "Draw Q Collision Color", SCRIPT_PARAM_COLOR, {150,40,4,4})
	MenuBlitz.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBlitz.drawConfig:addParam("DQR", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
	MenuBlitz.drawConfig:addParam("DQRC", "Draw Q Range Color", SCRIPT_PARAM_COLOR, {255,0,0,255})
	MenuBlitz.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBlitz.drawConfig:addParam("DRR", "Draw R Range", SCRIPT_PARAM_ONOFF, true)
	MenuBlitz.drawConfig:addParam("DRRC", "Draw R Range Color", SCRIPT_PARAM_COLOR, {255, 0, 255, 0})
	MenuBlitz:addSubMenu("[Blitzcrank Master]: Extra Settings", "exConfig")
	Enemies = GetEnemyHeroes() 
	MenuBlitz.exConfig:addSubMenu("Auto-Interrupt Spells", "ES")
    for i,enemy in pairs (Enemies) do
		for j,spell in pairs (Spells) do 
			if Counterspells[enemy:GetSpellData(spell).name] then 
				MenuBlitz.exConfig.ES:addParam(tostring(enemy:GetSpellData(spell).name),"Interrupt "..tostring(enemy.charName).." Spell "..tostring(Spells2[j]),SCRIPT_PARAM_ONOFF,true)
			end 
		end 
	end 
	MenuBlitz.exConfig:addParam("UI", "Use Auto-Interrupt", SCRIPT_PARAM_ONOFF, true)
	MenuBlitz:addSubMenu("[Blitzcrank Master]: Black List", "blConfig")
	for i = 1, heroManager.iCount do
		local hero = heroManager:GetHero(i)
		if hero.team ~= myHero.team then
			MenuBlitz.blConfig:addParam(hero.charName, hero.charName, SCRIPT_PARAM_ONOFF, false)
		end
	end
	MenuBlitz.blConfig:addParam("UBL", "Use Black List Toggle", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("T"))
	MenuBlitz:addSubMenu("[Blitzcrank Master]: Misc Settings", "prConfig")
	MenuBlitz.prConfig:addParam("pc", "Use Packets To Cast Spells(VIP)", SCRIPT_PARAM_ONOFF, false)
	MenuBlitz.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBlitz.prConfig:addParam("AZ", "Use Auto Zhonya", SCRIPT_PARAM_ONOFF, true)
	MenuBlitz.prConfig:addParam("AZHP", "Min HP To Cast Zhonya", SCRIPT_PARAM_SLICE, 20, 0, 100, 0)
	MenuBlitz.prConfig:addParam("AZMR", "Must Have 0 Enemy In Range:", SCRIPT_PARAM_SLICE, 900, 0, 1500, 0)
	MenuBlitz.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBlitz.prConfig:addParam("ALS", "Auto lvl skills", SCRIPT_PARAM_ONOFF, false)
	MenuBlitz.prConfig:addParam("AL", "Auto lvl sequence", SCRIPT_PARAM_LIST, 1, { "SUPP" })
	MenuBlitz.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBlitz.prConfig:addParam("pro", "Prodiction To Use:", SCRIPT_PARAM_LIST, 1, {"VPrediction","Prodiction","DivinePred"}) 
	MenuBlitz.comboConfig:permaShow("CEnabled")
	MenuBlitz.harrasConfig:permaShow("HEnabled")
	MenuBlitz.harrasConfig:permaShow("HTEnabled")
	MenuBlitz.prConfig:permaShow("AZ")
	MenuBlitz.blConfig:permaShow("UBL")
	if heroManager.iCount < 10 then
		print("<font color=\"#FFFFFF\">Too few champions to arrange priority.</font>")
	elseif heroManager.iCount == 6 then
		arrangePrioritysTT()
    else
		arrangePrioritys()
	end
	SxOrb:RegisterBeforeAttackCallback(function(t) aa() end)
end

function aa()
	if MenuBlitz.comboConfig.CEnabled and MenuBlitz.comboConfig.USEE == 2 then
		CastE()
	end
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

function Check()
	if SelectedTarget ~= nil and ValidTarget(SelectedTarget, Q.range) then
		Cel = SelectedTarget
	else
		Cel = GetCustomTarget()
	end
	if MenuBlitz.orb == 1 then
		SxOrb:ForceTarget(Cel)
	end
	Q.range = MenuBlitz.comboConfig.QMAXR
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

function getHitBoxRadius(target)
	return GetDistance(target.minBBox, target.maxBBox)/2
end

function FindBL()
	for i = 1, heroManager.iCount do
		hero = heroManager:GetHero(i)
		if MenuBlitz.blConfig.UBL and hero.team ~= myHero.team and not hero.dead and MenuBlitz.blConfig[hero.charName] then
			return hero
		end
	end
end

function Combo()
	if 30 < os.clock() * 100 - LastCheck then
	blacktarget = FindBL()
	if Cel ~= nil and ValidTarget(Cel) and Cel ~= blacktarget then
		UseItems(Cel)
		if MenuBlitz.comboConfig.USEQ and ValidTarget(Cel, Q.range) then
			if GetDistance(Cel) >= MenuBlitz.comboConfig.QMINR then
				CastQ(Cel)
			end
		end
		if MenuBlitz.comboConfig.USEW then
			CastW()
		end
		if MenuBlitz.orb == 2 and MenuBlitz.comboConfig.USEE == 2 and ValidTarget(Cel, E.range) then
			CastE()
		end
		if MenuBlitz.comboConfig.USER then
			if MenuBlitz.comboConfig.Kilable then
				local r = getDmg("R", Cel, myHero) + ((myHero.ap*90)/100)
				if Cel.health < r then
					CastR(Cel)
				end
			elseif not MenuBlitz.comboConfig.Kilable then
				CastR(Cel)
			end
		end
	end
	LastCheck = os.clock() * 100
	end
end

function Harrass()
	if 30 < os.clock() * 100 - LastCheck then
	blacktarget = FindBL()
	if Cel ~= nil and ValidTarget(Cel) and Cel ~= blacktarget then
		if MenuBlitz.harrasConfig.HM == 1 then
			if GetDistance(Cel) > MenuBlitz.comboConfig.QMINR and ValidTarget(Cel, Q.range) then
				CastQ(Cel)
			end
		end
		if MenuBlitz.harrasConfig.HM == 2 and ValidTarget(Cel, E.range) then
			CastE()
		end
		if MenuBlitz.harrasConfig.HM == 3 and ValidTarget(Cel, Q.range) then
			CastQ(Cel)
			CastE()
		end
	end
	LastCheck = os.clock() * 100
	end
end

function Farm()
	EnemyMinions:update()
	for i, minion in pairs(EnemyMinions.objects) do
		if MenuBlitz.farm.QF then
			if minion ~= nil and ValidTarget(minion, Q.range) then
				CastQ(minion)
			end
		end
		if MenuBlitz.farm.EF then
			if minion ~= nil and ValidTarget(minion, E.range) then
				CastE()
			end
		end
	end
end

function JungleFarmm()
	JungleMinions:update()
	for i, minion in pairs(JungleMinions.objects) do
		if MenuBlitz.jf.QJF then
			if minion ~= nil and ValidTarget(minion, Q.range) then
				CastQ(minion)
			end
		end
		if MenuBlitz.jf.EJF then
			if minion ~= nil and ValidTarget(minion, E.range) then
				CastE()
			end
		end
	end
end

function autozh()
	local count = EnemyCount(myHero, MenuBlitz.prConfig.AZMR)
	local zhonyaslot = GetInventorySlotItem(3157)
	local zhonyaready = (zhonyaslot ~= nil and myHero:CanUseSpell(zhonyaslot) == READY)
	if zhonyaready and ((myHero.health/myHero.maxHealth)*100) < MenuBlitz.prConfig.AZHP and count == 0 then
		CastSpell(zhonyaslot)
	end
end

function autolvl()
	if not MenuBlitz.prConfig.ALS then return end
	if myHero.level > GetHeroLeveled() then
		local a = {_Q,_E,_W,_Q,_Q,_R,_Q,_Q,_W,_W,_R,_W,_W,_E,_E,_R,_E,_E}
		LevelSpell(a[GetHeroLeveled() + 1])
	end
end

function OnDraw()
	if MenuBlitz.drawConfig.DT and Cel ~= nil then
		local pos = WorldToScreen(D3DXVECTOR3(myHero.x, myHero.y + 300, myHero.z))
		DrawText("Current Target:" .. Cel.charName, 20, pos.x - 100, pos.y + 300, 0xFFFFFF00)
	end
	if MenuBlitz.drawConfig.DST and MenuBlitz.comboConfig.ST then
		if SelectedTarget ~= nil and not SelectedTarget.dead then
			DrawCircle2(SelectedTarget.x, SelectedTarget.y, SelectedTarget.z, 100, RGB(MenuBlitz.drawConfig.DQRC[2], MenuBlitz.drawConfig.DQRC[3], MenuBlitz.drawConfig.DQRC[4]))
		end
	end
	if MenuBlitz.drawConfig.DQL and ValidTarget(Cel, Q.range) and not GetMinionCollision(myHero, Cel, Q.width) then
		QMark = Cel
		DrawLine3D(myHero.x, myHero.y, myHero.z, QMark.x, QMark.y, QMark.z, Q.width, ARGB(MenuBlitz.drawConfig.DQLC[1], MenuBlitz.drawConfig.DQLC[2], MenuBlitz.drawConfig.DQLC[3], MenuBlitz.drawConfig.DQLC[4]))
	end
	if MenuBlitz.drawConfig.DD then	
		for _,enemy in pairs(GetEnemyHeroes()) do
			DmgCalc()
            if ValidTarget(enemy, 1500) and killstring[enemy.networkID] ~= nil then
                local pos = WorldToScreen(D3DXVECTOR3(enemy.x, enemy.y, enemy.z))
                DrawText(killstring[enemy.networkID], 20, pos.x - 35, pos.y - 10, 0xFFFFFF00)
            end
        end
	end
	if MenuBlitz.drawConfig.DQR and Q.Ready() then			
		DrawCircle2(myHero.x, myHero.y, myHero.z, Q.range, RGB(MenuBlitz.drawConfig.DQRC[2], MenuBlitz.drawConfig.DQRC[3], MenuBlitz.drawConfig.DQRC[4]))
	end
	if MenuBlitz.drawConfig.DRR and R.Ready() then			
		DrawCircle2(myHero.x, myHero.y, myHero.z, R.range, RGB(MenuBlitz.drawConfig.DRRC[2], MenuBlitz.drawConfig.DRRC[3], MenuBlitz.drawConfig.DRRC[4]))
	end
	if MenuBlitz.drawConfig.DGS then
		local pos = WorldToScreen(D3DXVECTOR3(myHero.x, myHero.y, myHero.z))
		DrawText("Succes Grab's : "..SuccesGrabCount, 18, pos.x - 400, pos.y - 200, 0xFFFFFF00)
		DrawText("Fail Grab's : "..FailGrabCount,18, pos.x - 400, pos.y - 220, 0xFFFFFF00)
		DrawText("Precent Grab's: " ..math.floor(PrecentGrabCount) .."%", 18, pos.x - 400, pos.y - 240, 0xFFFFFF00)
	end
end

function KillSteall()
	for _, Enemy in pairs(GetEnemyHeroes()) do
		local health = Enemy.health
		local qDmg = getDmg("Q", Enemy, myHero, 1)
		local eDmg = getDmg("E", Enemy, myHero, 1)
		local rDmg = getDmg("R", Enemy, myHero, 3)
		local iDmg = (50 + (20 * myHero.level))
		local IReady = SSpells:Ready("summonerdot")
		if ValidTarget(Enemy, Q.range) and Enemy ~= nil then
			if 30 < os.clock() * 100 - LastCheck2 then
			if health < qDmg and MenuBlitz.ksConfig.QKS and ValidTarget(Enemy, Q.range) then
				CastQ(Enemy)
			elseif health < eDmg and MenuBlitz.ksConfig.EKS and ValidTarget(Enemy, E.range) then
				CastE()
				myHero:Attack(Enemy)
			elseif health < rDmg and MenuBlitz.ksConfig.RKS and ValidTarget(Enemy, R.range) then
				CastR(Enemy)
			elseif health < iDmg and MenuBlitz.ksConfig.IKS and IReady and ValidTarget(Enemy, 600) then
				CastSpell(SSpells:GetSlot("summonerdot"), Enemy)
			elseif health < (qDmg + eDmg) and MenuBlitz.ksConfig.QKS and MenuBlitz.ksConfig.EKS and ValidTarget(Enemy, Q.range) then
				CastQ(Enemy)
				CastE()
				myHero:Attack(Enemy)
			elseif health < (qDmg + rDmg) and MenuBlitz.ksConfig.QKS and MenuBlitz.ksConfig.RKS and ValidTarget(Enemy, Q.range) then
				CastQ(Enemy)
				CastR(Enemy)				
			elseif health < (eDmg + rDmg) and MenuBlitz.ksConfig.EKS and MenuBlitz.ksConfig.RKS and ValidTarget(Enemy, E.range) then
				CastE()
				myHero:Attack(Enemy)
				CastR(Enemy)	
			elseif health < (qDmg + eDmg + rDmg) and MenuBlitz.ksConfig.QKS and MenuBlitz.ksConfig.EKS and MenuBlitz.ksConfig.RKS and ValidTarget(Enemy, Q.range) then
				CastQ(Enemy)
				CastE()
				myHero:Attack(Enemy)
				CastR(Enemy)	
			end
			LastCheck2 = os.clock() * 100
			end
		end
	end
end

function DmgCalc()
	for _, enemy in pairs(GetEnemyHeroes()) do
        if not enemy.dead and enemy.visible then
			local qDmg = getDmg("Q", enemy, myHero, 1)
			local eDmg = getDmg("E", enemy, myHero, 1)
			local rDmg = getDmg("R", enemy, myHero, 3)
			local iDmg = (50 + (20 * myHero.level))
            if enemy.health > (qDmg + eDmg + rDmg) then
				killstring[enemy.networkID] = "Harass Him!!!"
			elseif enemy.health < qDmg then
				killstring[enemy.networkID] = "Q Kill!"
			elseif enemy.health < eDmg then
				killstring[enemy.networkID] = "E Kill!"
			elseif enemy.health < rDmg then
				killstring[enemy.networkID] = "R Kill!"
            elseif enemy.health < (qDmg + eDmg) then
                killstring[enemy.networkID] = "Q+E Kill!"
			elseif enemy.health < (qDmg + rDmg) then
                killstring[enemy.networkID] = "Q+R Kill!"	
			elseif enemy.health < (rDmg + eDmg) then
                killstring[enemy.networkID] = "R+E Kill!"	
			elseif enemy.health < (qDmg + eDmg + rDmg) then
                killstring[enemy.networkID] = "Q+E+R Kill!"	
            end
        end
    end
end

function OnApplyBuff(source, unit, buff)
	if buff.name == "rocketgrab2" and not unit.isMe and unit.type == myHero.type then 
		SuccesGrabCount = SuccesGrabCount + 1
		FailGrabCount = (AllCastGrabCount-SuccesGrabCount)
		PrecentGrabCount =((SuccesGrabCount*100)/AllCastGrabCount)
		if MenuBlitz.comboConfig.CEnabled and MenuBlitz.comboConfig.USEE == 3 then
			CastE()
		end
	end	
	if unit and unit.isMe and buff and buff.name == "Recall" then
		recall = true
	end
end

function OnRemoveBuff(unit, buff)
	if unit and unit.isMe and buff and buff.name == "Recall" then
		recall = false
	end
end

function Support()
	if MenuBlitz.ss.umc then
		local mikael = GetInventorySlotItem(3222)
		local mikaelready = (mikael ~= nil and (myHero:CanUseSpell(mikael) == READY))
		for i = 1, heroManager.iCount do
			local hero = heroManager:GetHero(i)
			if hero.team == myHero.team then
				if ValidTarget(hero, 750) and ((((hero.health/hero.maxHealth)*100) < MenuBlitz.ss.mchp) or HaveBuff(hero)) then
					if mikaelready then
						CastSpell(mikael)
					end
				end
			end
		end
	end
	if MenuBlitz.ss.ufq then
		local frost = GetInventorySlotItem(3092)
		local frostready = (frost ~= nil and (myHero:CanUseSpell(frost) == READY))
		for i, enemy in ipairs(GetEnemyHeroes()) do
			if ValidTarget(enemy, 880) and ((enemy.health/enemy.maxHealth)*100) < MenuBlitz.ss.fqhp then
				if frostready then
					CastSpell(frost, enemy.x, enemy.z)
				end
			end
		end
	end
	if MenuBlitz.ss.uis then
		local solari = GetInventorySlotItem(3190)
		local solariready = (solari ~= nil and (myHero:CanUseSpell(solari) == READY))
		for i = 1, heroManager.iCount do
			local hero = heroManager:GetHero(i)
			if hero.team == myHero.team then
				if ValidTarget(hero, 700) and ((hero.health/hero.maxHealth)*100) < MenuBlitz.ss.ishp then
					if solariready then
						CastSpell(solari)
					end
				end
			end
		end
	end
	if MenuBlitz.ss.uts then
		local twin = GetInventorySlotItem(3023)
		local twinready = (twin ~= nil and (myHero:CanUseSpell(twin) == READY))
		for i, enemy in ipairs(GetEnemyHeroes()) do
			if ValidTarget(enemy, 1000) and ((enemy.health/enemy.maxHealth)*100) < MenuBlitz.ss.tshp then
				if twinready then
					CastSpell(twin)
				end
			end
		end
	end
	if MenuBlitz.ss.uex then
		for i, enemy in ipairs(GetEnemyHeroes()) do
			if ValidTarget(enemy, 550) and ((enemy.health/enemy.maxHealth)*100) < MenuBlitz.ss.exhp then
				local ExhaustReady = SSpells:Ready("summonerexhaust")
				if ExhaustReady then
					CastSpell(SSpells:GetSlot("summonerexhaust"), enemy)
				end
			end
		end
	end
	if MenuBlitz.ss.uh then
		for i = 1, heroManager.iCount do
			local hero = heroManager:GetHero(i)
			if hero.team == myHero.team then
				if ValidTarget(hero, 700) and ((hero.health/hero.maxHealth)*100) < MenuBlitz.ss.hhp then
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

function CastQ(unit)
	if Q.Ready() then
		local SReady = SSpells:Ready("summonersmite")
		if MenuBlitz.comboConfig.USEQS then
			local willCollide1, ColTable2 = GetMinionCollisionM(unit, myHero)
			if #ColTable2 == 1 and SReady and GetDistance(myHero, ColTable2[1]) < 800 then
				CastSpell(SSpells:GetSlot("summonersmite"), ColTable2[1])
			end
		end
		if MenuBlitz.prConfig.pro == 1 then
			local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(unit, Q.delay, Q.width, Q.range, Q.speed, myHero, true)
			if HitChance >= 2 then
				if VIP_USER and MenuBlitz.prConfig.pc then
					Packet("S_CAST", {spellId = _Q, fromX = CastPosition.x, fromY = CastPosition.z, toX = CastPosition.x, toY = CastPosition.z}):send()
				else
					CastSpell(_Q, CastPosition.x, CastPosition.z)
				end
			end
		end
		if MenuBlitz.prConfig.pro == 2 and VIP_USER and prodstatus then
			local Position, info = Prodiction.GetPrediction(unit, Q.range, Q.speed, Q.delay, Q.width, myHero)
			if Position ~= nil and not info.mCollision() then
				if VIP_USER and MenuBlitz.prConfig.pc then
					Packet("S_CAST", {spellId = _Q, fromX = Position.x, fromY = Position.z, toX = Position.x, toY = Position.z}):send()
				else
					CastSpell(_Q, Position.x, Position.z)
				end	
			end
		end
		if MenuBlitz.prConfig.pro == 3 and VIP_USER then
			local unit = DPTarget(unit)
			local BlitzQ = SkillShot.PRESETS['RocketGrab']
			local State, Position, perc = DP:predict(unit, BlitzQ, 2)
			if State == SkillShot.STATUS.SUCCESS_HIT then 
				if VIP_USER and MenuBlitz.prConfig.pc then
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
		if VIP_USER and MenuBlitz.prConfig.pc then
			Packet("S_CAST", {spellId = _W}):send()
		else
			CastSpell(_W)
		end	
	end
end

function CastE()
	if E.Ready() then
		if VIP_USER and MenuBlitz.prConfig.pc then
			Packet("S_CAST", {spellId = _E}):send()
		else
			CastSpell(_E)
		end	
	end
end

function CastR(unit)
	if R.Ready() and ValidTarget(unit, R.range-20) then
		if VIP_USER and MenuBlitz.prConfig.pc then
			Packet("S_CAST", {spellId = _R}):send()
		else
			CastSpell(_R)
		end	
	end
end

function OnProcessSpell(object, spell)
	if MenuBlitz.exConfig.UI then
		if object and object.team ~= myHero.team and object.type == myHero.type and spell then
			if Counterspells[spell.name] or spell.name == "Meditate" or spell.name == "Teleport" then 
				CastR(object)
			end
		end
	end
	if object and spell.name == "RocketGrab" and object.isMe then
		AllCastGrabCount = AllCastGrabCount+1
		FailGrabCount = (AllCastGrabCount-SuccesGrabCount)
		PrecentGrabCount =((SuccesGrabCount*100)/AllCastGrabCount)
    end
end

function OnWndMsg(Msg, Key)
	if Msg == WM_LBUTTONDOWN and MenuBlitz.comboConfig.ST then
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
				if MenuBlitz.comboConfig.ST then 
					print("Target unselected: "..Selecttarget.charName) 
				end
			else
				SelectedTarget = Selecttarget
				if MenuBlitz.comboConfig.ST then 
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


-- FROM Collision 1.1.1 by Klokje Mod by Boboben1 --
function GetMinionCollisionM(pStart, pEnd)
    EnemyMinions:update()
    local distance =  GetDistance(pStart, pEnd)
    local prediction = TargetPrediction(Q.range, Q.speed/1000, Q.delay*1000, Q.width)
    local mCollision = {}
    if distance > Q.range then
        distance = Q.range
    end
    local V = Vector(pEnd) - Vector(pStart)
    local k = V:normalized()
    local P = V:perpendicular2():normalized()
    local t,i,u = k:unpack()
    local x,y,z = P:unpack()
    local startLeftX = pStart.x + (x *Q.width)
    local startLeftY = pStart.y + (y *Q.width)
    local startLeftZ = pStart.z + (z *Q.width)
    local endLeftX = pStart.x + (x * Q.width) + (t * distance)
    local endLeftY = pStart.y + (y * Q.width) + (i * distance)
    local endLeftZ = pStart.z + (z * Q.width) + (u * distance)
    local startRightX = pStart.x - (x * Q.width)
    local startRightY = pStart.y - (y * Q.width)
    local startRightZ = pStart.z - (z * Q.width)
    local endRightX = pStart.x - (x * Q.width) + (t * distance)
    local endRightY = pStart.y - (y * Q.width) + (i * distance)
    local endRightZ = pStart.z - (z * Q.width)+ (u * distance)
    local startLeft = WorldToScreen(D3DXVECTOR3(startLeftX, startLeftY, startLeftZ))
    local endLeft = WorldToScreen(D3DXVECTOR3(endLeftX, endLeftY, endLeftZ))
    local startRight = WorldToScreen(D3DXVECTOR3(startRightX, startRightY, startRightZ))
    local endRight = WorldToScreen(D3DXVECTOR3(endRightX, endRightY, endRightZ))
    local poly = Polygon(Point(startLeft.x, startLeft.y),  Point(endLeft.x, endLeft.y), Point(startRight.x, startRight.y),   Point(endRight.x, endRight.y))
    for index, minion in pairs(EnemyMinions.objects) do
        if minion ~= nil and minion.valid and not minion.dead then
            if GetDistance(pStart, minion) < distance then
                local pos, t, vec = prediction:GetPrediction(minion)
                local lineSegmentLeft = LineSegment(Point(startLeftX,startLeftZ), Point(endLeftX, endLeftZ))
                local lineSegmentRight = LineSegment(Point(startRightX,startRightZ), Point(endRightX, endRightZ))
                local toScreen, toPoint
                if pos ~= nil then
                    toScreen = WorldToScreen(D3DXVECTOR3(minion.x, minion.y, minion.z))
                    toPoint = Point(toScreen.x, toScreen.y)
                else
                    toScreen = WorldToScreen(D3DXVECTOR3(minion.x, minion.y, minion.z))
                    toPoint = Point(toScreen.x, toScreen.y)
                end
                if poly:contains(toPoint) then
                    table.insert(mCollision, minion)
                else
                    if pos ~= nil then
                        distance1 = Point(pos.x, pos.z):distance(lineSegmentLeft)
                        distance2 = Point(pos.x, pos.z):distance(lineSegmentRight)
                    else
                        distance1 = Point(minion.x, minion.z):distance(lineSegmentLeft)
                        distance2 = Point(minion.x, minion.z):distance(lineSegmentRight)
                    end
                    if (distance1 < (getHitBoxRadius2(minion)*2+10) or distance2 < (getHitBoxRadius2(minion) *2+10)) then
                        table.insert(mCollision, minion)
                    end
                end
            end
        end
    end
    if #mCollision > 0 then return true, mCollision else return false, mCollision end
end

function getHitBoxRadius2(target)
    return GetDistance(target, target.minBBox)/2
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
assert(load(Base64Decode("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"), nil, "bt", _ENV))() ScriptStatus("QDGEEKCHFIJ") 