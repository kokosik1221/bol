--[[

	Script Name: ZED MASTER 
    	Author: kokosik1221
	Last Version: 1.73
	07.04.2015
	
]]--

if myHero.charName ~= "Zed" then return end

local autoupdate = true
local version = 1.73
 
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
	local scriptName = "ZedMaster"
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
    print("<font color=\"#FFFFFF\"><b>" .. "ZedMaster" .. ":</b></font> <font color=\"#FFFFFF\">" .. message .. "</font>") 
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

local interputtspells = {
['AhriTumble'] = {charName = "Ahri", spellSlot = "R", SpellType = "skillshot"},
['AkaliShadowDance'] = {charName = "Akali", spellSlot = "R", SpellType = "castcel"},
['CurseoftheSadMummy'] = {charName = "Amumu", spellSlot = "R", SpellType = "skillshot"},
['GlacialStorm'] = {charName = "Anivia", spellSlot = "R", SpellType = "skillshot"},
['InfernalGuardian'] = {charName = "Annie", spellSlot = "R", SpellType = "castcel"},
['EnchantedCrystalArrow'] = {charName = "Ashe", spellSlot = "R", SpellType = "skillshot"},
['StaticField'] = {charName = "Blitzcrank", spellSlot = "R", SpellType = "skillshot"},
['BrandWildfire'] = {charName = "Brand", spellSlot = "R", SpellType = "castcel"},
['BraumR'] = {charName = "Braum", spellSlot = "R", SpellType = "skillshot"},
['CaitlynAceintheHole'] = {charName = "Caitlyn", spellSlot = "R", SpellType = "castcel"},
['CassiopeiaPetrifyingGaze'] = {charName = "Cassiopeia", spellSlot = "R", SpellType = "skillshot"},
['Feast'] = {charName = "Chogath", spellSlot = "R", SpellType = "castcel"},
['MissileBarrage'] = {charName = "Corki", spellSlot = "R", SpellType = "skillshot"},
['DariusExecute'] = {charName = "Darius", spellSlot = "R", SpellType = "castcel"},
['DianaTeleport'] = {charName = "Diana", spellSlot = "R", SpellType = "castcel"},
['DravenRCast'] = {charName = "Draven", spellSlot = "R", SpellType = "castcel"},
['EvelynnR'] = {charName = "Evelynn", spellSlot = "R", SpellType = "skillshot"},
['EzrealTruehotBarrage'] = {charName = "Ezreal", spellSlot = "R", SpellType = "skillshot"},
['Crowstorm'] = {charName = "FiddleSticks", spellSlot = "R", SpellType = "skillshot"},
['FioraDance'] = {charName = "Fiora", spellSlot = "R", SpellType = "castcel"},
['FizzMarinerDoom'] = {charName = "Fizz", spellSlot = "R", SpellType = "skillshot"},
['GalioIdolOfDurand'] = {charName = "Galio", spellSlot = "R", SpellType = "skillshot"},
['CannonBarrage'] = {charName = "Gangplank", spellSlot = "R", SpellType = "skillshot"},
['GarenR'] = {charName = "Garen", spellSlot = "R", SpellType = "castcel"},
['GnarBigR'] = {charName = "Gnar", spellSlot = "R", SpellType = "skillshot"},
['GragasExplosiveCask'] = {charName = "Gragas", spellSlot = "R", SpellType = "skillshot"},
['GravesChargeShot'] = {charName = "Graves", spellSlot = "R", SpellType = "skillshot"},
['HecarimUlt'] = {charName = "Hecarim", spellSlot = "R", SpellType = "skillshot"},
['IreliaTranscendentBlades'] = {charName = "Irelia", spellSlot = "R", SpellType = "skillshot"},
['JarvanIVCataclysm'] = {charName = "JarvanIV", spellSlot = "R", SpellType = "skillshot"},
['JinxRWrapper'] = {charName = "Jinx", spellSlot = "R", SpellType = "skillshot"},
['FallenOne'] = {charName = "Karthus", spellSlot = "R", SpellType = "skillshot"},
['RiftWalk'] = {charName = "Kassadin", spellSlot = "R", SpellType = "skillshot"},
['KatarinaR'] = {charName = "Katarina", spellSlot = "R", SpellType = "skillshot"},
['KennenShurikenStorm ']= {charName = "Kennen", spellSlot = "R", SpellType = "skillshot"},
['KogMawLivingArtillery'] = {charName = "KogMaw", spellSlot = "R", SpellType = "skillshot"},
['BlindMonkRKick'] = {charName = "LeeSin", spellSlot = "R", SpellType = "castcel"},
['LeonaSolarFlare'] = {charName = "Leona", spellSlot = "R", SpellType = "skillshot"},
['LissandraR'] = {charName = "Lissandra", spellSlot = "R", SpellType = "skillshot"},
['LucianR'] = {charName = "Lucian", spellSlot = "R", SpellType = "skillshot"},
['LuxMaliceCannon'] = {charName = "Lux", spellSlot = "R", SpellType = "skillshot"},
['UFSlash'] = {charName = "Malphite", spellSlot = "R", SpellType = "skillshot"},
['AlZaharNetherGrasp'] = {charName = "Malzahar", spellSlot = "R", SpellType = "castcel"},
['MaokaiDrain3'] = {charName = "Maokai", spellSlot = "R", SpellType = "skillshot"},
['MissFortuneBulletTime'] = {charName = "MissFortune", spellSlot = "R", SpellType = "skillshot"},
['MordekaiserChildrenOfTheGrave'] = {charName = "Mordekaiser", spellSlot = "R", SpellType = "castcel"},
['SoulShackles'] = {charName = "Morgana", spellSlot = "R", SpellType = "skillshot"},
['NamiR'] = {charName = "Nami", spellSlot = "R", SpellType = "skillshot"},
['NautilusGandLine'] = {charName = "Nautilus", spellSlot = "R", SpellType = "castcel"},
['AbsoluteZero'] = {charName = "Nunu", spellSlot = "R", SpellType = "skillshot"},
['OrianaDetonateCommand'] = {charName = "Orianna", spellSlot = "R", SpellType = "skillshot"},
['Tremors2'] = {charName = "Rammus", spellSlot = "R", SpellType = "skillshot"},
['rivenizunablade'] = {charName = "Riven", spellSlot = "R", SpellType = "skillshot"},
['RumbleCarpetBomb'] = {charName = "Rumble", spellSlot = "R", SpellType = "skillshot"},
['SejuaniGlacialPrisonStart'] = {charName = "Sejuani", spellSlot = "R", SpellType = "skillshot"},
['ShyvanaTransformCast'] = {charName = "Shyvana", spellSlot = "R", SpellType = "skillshot"},
['SkarnerImpale'] = {charName = "Skarner", spellSlot = "R", SpellType = "castcel"},
['SonaCrescendo'] = {charName = "Sona", spellSlot = "R", SpellType = "skillshot"},
['SwainMetamorphism'] = {charName = "Swain", spellSlot = "R", SpellType = "skillshot"},
['SyndraR'] = {charName = "Syndra", spellSlot = "R", SpellType = "castcel"},
['TaricHammerSmash'] = {charName = "Taric", spellSlot = "R", SpellType = "skillshot"},
['ThreshRPenta'] = {charName = "Thresh", spellSlot = "R", SpellType = "skillshot"},
['BusterShot'] = {charName = "Tristana", spellSlot = "R", SpellType = "castcel"},
['TrundlePain'] = {charName = "Trundle", spellSlot = "R", SpellType = "castcel"},
['UrgotSwap2'] = {charName = "Urgot", spellSlot = "R", SpellType = "castcel"},
['VarusR'] = {charName = "Varus", spellSlot = "R", SpellType = "skillshot"},
['VeigarPrimordialBurst'] = {charName = "Veigar", spellSlot = "R", SpellType = "castcel"},
['VelkozR'] = {charName = "Velkoz", spellSlot = "R", SpellType = "skillshot"},
['ViR'] = {charName = "Vi", spellSlot = "R", SpellType = "castcel"},
['ViktorChaosStorm'] = {charName = "Viktor", spellSlot = "R", SpellType = "skillshot"},
['VladimirHemoplague'] = {charName = "Vladimir", spellSlot = "R", SpellType = "skillshot"},
['InfiniteDuress'] = {charName = "Warwick", spellSlot = "R", SpellType = "castcel"},
['MonkeyKingSpinToWin'] = {charName = "MonkeyKing", spellSlot = "R", SpellType = "skillshot"},
['monkeykingspintowinleave'] = {charName = "MonkeyKing", spellSlot = "R", SpellType = "skillshot"},
['XerathLocusOfPower2'] = {charName = "Xerath", spellSlot = "R", SpellType = "castcel"},
['XenZhaoParry'] = {charName = "Xin Zhao", spellSlot = "R", SpellType = "skillshot"},
['YasuoRKnockUpComboW'] = {charName = "Yasuo", spellSlot = "R", SpellType = "skillshot"},
['zedult'] = {charName = "Zed", spellSlot = "R", SpellType = "castcel"},
['ZiggsR'] = {charName = "Ziggs", spellSlot = "R", SpellType = "skillshot"},
['ZyraBrambleZone'] = {charName = "Zyra", spellSlot = "R", SpellType = "skillshot"},
}

local Items = {
	BRK = { id = 3153, range = 450, reqTarget = true, slot = nil },
	BWC = { id = 3144, range = 400, reqTarget = true, slot = nil },
	RSH = { id = 3074, range = 350, reqTarget = false, slot = nil },
	STD = { id = 3131, range = 350, reqTarget = false, slot = nil },
	TMT = { id = 3077, range = 350, reqTarget = false, slot = nil },
	YGB = { id = 3142, range = 350, reqTarget = false, slot = nil },
	RND = { id = 3143, range = 275, reqTarget = false, slot = nil },
}

local Q = {name = "Razor Shuriken", range = 900, speed = 1700, delay = 0.25, width = 50, Ready = function() return myHero:CanUseSpell(_Q) == READY end}
local W = {name = "Living Shadow", range = 580, speed = math.huge, delay = 0.25, Ready = function() return myHero:CanUseSpell(_W) == READY end}
local E = {name = "Shadow Slash", range = 290, Ready = function() return myHero:CanUseSpell(_E) == READY end}
local R = {name = "Death Mark", range = 625, Ready = function() return myHero:CanUseSpell(_R) == READY end}
local DeadMark, recall, WCasted, RCasted = false, false, false, false
local idmg, qdmg, edmg, rdmg, qdmg2 = 0, 0, 0, 0, 0
local EnemyMinions = minionManager(MINION_ENEMY, Q.range, myHero, MINION_SORT_MAXHEALTH_DEC)
local JungleMinions = minionManager(MINION_JUNGLE, Q.range, myHero, MINION_SORT_MAXHEALTH_DEC)
local WShadow, RShadow = nil, nil
local killstring = {}
local Spells = {_Q,_W,_E,_R}
local Spells2 = {"Q","W","E","R"}
local TargetSelectorH = TargetSelector(TARGET_LESS_CAST_PRIORITY, Q.range + W.range, DAMAGE_PHYSICAL)
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
	print("<b><font color=\"#FF0000\">Zed Master:</font></b> <font color=\"#FFFFFF\">Good luck and give me feedback!</font>")
	if _G.MMA_Loaded then
		print("<b><font color=\"#FF0000\">Zed Master:</font></b> <font color=\"#FFFFFF\">MMA Support Loaded.</font>")
	end	
	if _G.AutoCarry then
		print("<b><font color=\"#FF0000\">Zed Master:</font></b> <font color=\"#FFFFFF\">SAC Support Loaded.</font>")
	end
end

function OnTick()
	Check()
	if Cel ~= nil and MenuZed.comboConfig.CEnabled and not recall then
		Combo()
	end
	if MenuZed.comboConfig2.CEnabled2 and not recall then
		caa()
		Combo2()
	end
	if CelH ~= nil and not MenuZed.comboConfig.CEnabled and (MenuZed.harrasConfig.HEnabled or MenuZed.harrasConfig.HTEnabled) and not recall then
		Harrass()
	end
	if MenuZed.farm.LaneClear and not recall then
		Farm()
	end
	if MenuZed.jf.JFEnabled and not recall then
		JungleFarmm()
	end
	if MenuZed.prConfig.ALS and not recall then
		autolvl()
	end
	if MenuZed.comboConfig.rConfig.RS and not recall then
		if DeadMark and RState() == 2 then
			CastSpell(_R)
		end
	end
	if not recall then
		KillSteall()
	end
end

function Menu()
	MenuZed = scriptConfig("Zed Master "..version, "Zed Master "..version)
	MenuZed:addParam("orb", "Orbwalker:", SCRIPT_PARAM_LIST, 1, {"SxOrb","SAC:R/MMA"}) 
	MenuZed:addParam("qqq", "If You Change Orb. Click 2x F9", SCRIPT_PARAM_INFO,"")
	if MenuZed.orb == 1 then
		MenuZed:addSubMenu("[Zed Master]: Orbwalking", "Orbwalking")
		SxOrb:LoadToMenu(MenuZed.Orbwalking) 
	end
	TargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, Q.range, DAMAGE_PHYSICAL)
	TargetSelector.name = "Zed"
	MenuZed:addTS(TargetSelector)
	MenuZed:addSubMenu("[Zed Master]: Combo Settings", "comboConfig")
	MenuZed.comboConfig:addSubMenu("[Zed Master]: W Settings", "wConfig")
	MenuZed.comboConfig.wConfig:addParam("USW", "Use W Swap To Get Closer", SCRIPT_PARAM_ONOFF, true)
	MenuZed.comboConfig.wConfig:addParam("UWC", "Don't Use W When Can Cast ULT", SCRIPT_PARAM_ONOFF, true)
	MenuZed.comboConfig:addSubMenu("[Zed Master]: R Settings", "rConfig")
	MenuZed.comboConfig.rConfig:addParam("DW", "Dash With W If Distance To Enemy > R Range", SCRIPT_PARAM_ONOFF, true)
	MenuZed.comboConfig.rConfig:addParam("RHP", "Swap With ULT If HP < %", SCRIPT_PARAM_SLICE, 15, 0, 100, 0)
	MenuZed.comboConfig.rConfig:addParam("RS", "Swap With R If Target Can Dead By Mark", SCRIPT_PARAM_ONOFF, true)
	MenuZed.comboConfig.rConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuZed.comboConfig.rConfig:addParam("qqq", "Use Ultimate On:", SCRIPT_PARAM_INFO,"")
	for i = 1, heroManager.iCount do
		local hero = heroManager:GetHero(i)
		if hero.team ~= myHero.team then
			MenuZed.comboConfig.rConfig:addParam(hero.charName, hero.charName, SCRIPT_PARAM_ONOFF, true)
		end
	end
	MenuZed.comboConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuZed.comboConfig:addParam("IAU", "Use Items After ULT", SCRIPT_PARAM_ONOFF, true)
	MenuZed.comboConfig:addParam("ST", "Focus Selected Target", SCRIPT_PARAM_ONOFF, false)
	MenuZed.comboConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuZed.comboConfig:addParam("CEnabled", "Full Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	MenuZed:addSubMenu("[Zed Master]: Combo2 Settings", "comboConfig2")
	MenuZed.comboConfig2:addSubMenu("[Zed Master]: W Settings", "wConfig")
	MenuZed.comboConfig2.wConfig:addParam("USEW", "Use W", SCRIPT_PARAM_ONOFF, true)
	MenuZed.comboConfig2.wConfig:addParam("USW", "Use W Swap To Get Closer", SCRIPT_PARAM_ONOFF, true)
	MenuZed.comboConfig2:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuZed.comboConfig2:addParam("CEnabled2", "Full Combo 2", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("T"))
	MenuZed:addSubMenu("[Zed Master]: Harras Settings", "harrasConfig")
	MenuZed.harrasConfig:addParam("HM", "Harrass Mode:", SCRIPT_PARAM_LIST, 1, {"|W|E|Q|", "|Q|E|", "|Q|"}) 
	MenuZed.harrasConfig:addParam("HEnabled", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
	MenuZed.harrasConfig:addParam("HTEnabled", "Harass Toggle", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("L"))
	MenuZed:addSubMenu("[Zed Master]: KS Settings", "ksConfig")
	MenuZed.ksConfig:addParam("IKS", "Use Ignite To KS", SCRIPT_PARAM_ONOFF, true)
	MenuZed.ksConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuZed.ksConfig:addParam("QKS", "Use " .. Q.name .. "(Q)", SCRIPT_PARAM_ONOFF, true)
	MenuZed.ksConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuZed.ksConfig:addParam("EKS", "Use " .. E.name .. "(E)", SCRIPT_PARAM_ONOFF, true)
	MenuZed:addSubMenu("[Zed Master]: Farm Settings", "farm")
	MenuZed.farm:addParam("QF", "Use " .. Q.name .. "(Q)", SCRIPT_PARAM_LIST, 2, { "No", "Freezing", "LaneClear"})
	MenuZed.farm:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuZed.farm:addParam("WF",  "Use " .. W.name .. "(W)", SCRIPT_PARAM_LIST, 2, { "No", "LaneClear"})
	MenuZed.farm:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuZed.farm:addParam("EF",  "Use " .. E.name .. "(E)", SCRIPT_PARAM_LIST, 3, { "No", "Freezing", "LaneClear"})
	MenuZed.farm:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuZed.farm:addParam("LaneClear", "Farm ", SCRIPT_PARAM_ONKEYDOWN, false,   string.byte("V"))
	MenuZed:addSubMenu("[Zed Master]: Jungle Farm Settings", "jf")
	MenuZed.jf:addParam("QJF", "Use " .. Q.name .. "(Q)", SCRIPT_PARAM_ONOFF, true)
	MenuZed.jf:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuZed.jf:addParam("WJF", "Use " .. W.name .. "(W)", SCRIPT_PARAM_ONOFF, true)
	MenuZed.jf:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuZed.jf:addParam("EJF", "Use " .. E.name .. "(E)", SCRIPT_PARAM_ONOFF, true)
	MenuZed.jf:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuZed.jf:addParam("JFEnabled", "Jungle Farm", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
	MenuZed:addSubMenu("[Zed Master]: Extra Settings", "exConfig")
	MenuZed.exConfig:addSubMenu("Dodge Spells List", "IS")
	Enemies = GetEnemyHeroes() 
    for i,enemy in pairs (Enemies) do
		for j,spell in pairs (Spells) do 
			if interputtspells[enemy:GetSpellData(spell).name] then 
				MenuZed.exConfig.IS:addParam(tostring(enemy:GetSpellData(spell).name),"Dodge "..tostring(enemy.charName).." Spell "..tostring(Spells2[j]),SCRIPT_PARAM_ONOFF,true)
			end 
		end 
	end 
	MenuZed.exConfig:addParam("UIS", "Use Dodge Enemy Skills", SCRIPT_PARAM_ONOFF, true)
	MenuZed:addSubMenu("[Zed Master]: Draw Settings", "drawConfig")
	MenuZed.drawConfig:addParam("DD", "Draw DMG Text", SCRIPT_PARAM_ONOFF, true)
	MenuZed.drawConfig:addParam("DST", "Draw Selected Target", SCRIPT_PARAM_ONOFF, true)
	MenuZed.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuZed.drawConfig:addParam("DQR", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
	MenuZed.drawConfig:addParam("DQRC", "Draw Q Range Color", SCRIPT_PARAM_COLOR, {255,0,0,255})
	MenuZed.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuZed.drawConfig:addParam("DWR", "Draw W Range", SCRIPT_PARAM_ONOFF, true)
	MenuZed.drawConfig:addParam("DWRC", "Draw W Range Color", SCRIPT_PARAM_COLOR, {255,255,0,0})
	MenuZed.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuZed.drawConfig:addParam("DER", "Draw E Range", SCRIPT_PARAM_ONOFF, true)
	MenuZed.drawConfig:addParam("DERC", "Draw E Range Color", SCRIPT_PARAM_COLOR, {255, 0, 255, 0})
	MenuZed.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuZed.drawConfig:addParam("DRR", "Draw R Range", SCRIPT_PARAM_ONOFF, true)
	MenuZed.drawConfig:addParam("DRRC", "Draw R Range Color", SCRIPT_PARAM_COLOR, {255, 0, 255, 0})
	MenuZed:addSubMenu("[Zed Master]: Misc Settings", "prConfig")
	MenuZed.prConfig:addParam("pc", "Use Packets To Cast Spells(VIP)", SCRIPT_PARAM_ONOFF, false)
	MenuZed.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuZed.prConfig:addParam("ALS", "Auto lvl skills", SCRIPT_PARAM_ONOFF, false)
	MenuZed.prConfig:addParam("AL", "Auto lvl sequence", SCRIPT_PARAM_LIST, 2, { "MID" })
	MenuZed.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuZed.prConfig:addParam("pro", "Prodiction To Use:", SCRIPT_PARAM_LIST, 1, {"VPrediction","Prodiction","DivinePred"}) 
	MenuZed.comboConfig:permaShow("CEnabled")
	MenuZed.harrasConfig:permaShow("HEnabled")
	MenuZed.harrasConfig:permaShow("HTEnabled")
	MenuZed.farm:permaShow("LaneClear")
	MenuZed.jf:permaShow("JFEnabled")
	MenuZed.exConfig:permaShow("UIS")
	if heroManager.iCount < 10 then
		print("<font color=\"#FF0000\">Too few champions to arrange priority.</font>")
	elseif heroManager.iCount == 6 then
		arrangePrioritysTT()
    else
		arrangePrioritys()
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

function Check()
	TargetSelectorH:update()	
	CelH = TargetSelectorH.target
	if SelectedTarget ~= nil and ValidTarget(SelectedTarget, TargetSelector.range) then
		Cel = SelectedTarget
	else
		Cel = GetCustomTarget()
	end
	if W.Ready() and R.Ready() then
        TargetSelector.range = 1200
    else
        TargetSelector.range = 900
    end
	if MenuZed.orb == 1 then
		SxOrb:ForceTarget(Cel)
	end
	QMana = myHero:GetSpellData(_Q).mana
    WMana = myHero:GetSpellData(_W).mana
    EMana = myHero:GetSpellData(_E).mana
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

function Combo()
	if not (TargetHaveBuff("JudicatorIntervention", Cel) or TargetHaveBuff("Undying Rage", Cel)) then
		if ValidTarget(Cel) and R.Ready() and myHero.mana > (QMana + EMana) then 
			if GetDistance(Cel) <= R.range and RState() == 1 then
				if MenuZed.comboConfig.rConfig[Cel.charName] then
					CastR(Cel)
				end
			elseif GetDistance(Cel) > R.range + 60 and GetDistance(Cel) < 1300 and MenuZed.comboConfig.rConfig.DW and RState() == 1 then
				local DashPos = myHero + Vector(Cel.x - myHero.x, 0, Cel.z - myHero.z):normalized()*550
				CastW(DashPos)
				if MenuZed.comboConfig.rConfig[Cel.charName] then
					CastR(Cel)
				end
			end
		end
		if MenuZed.comboConfig.wConfig.UWC and (TargetHaveBuff("zedulttargetmark", Cel)) then
			if myHero.mana > (WMana+EMana) and GetDistance(Cel) < Q.range then 
				local behindVector = myHero - (Vector(Cel) - myHero):normalized() * 400
				CastW(behindVector)
			end
		elseif MenuZed.comboConfig.wConfig.UWC and myHero:GetSpellData(_R).level >= 1 or myHero:CanUseSpell(_R) == NOTLEARNED or myHero:CanUseSpell(_R) == COOLDOWN then
			if myHero.mana > (WMana+EMana) and GetDistance(Cel) < Q.range then 
				CastW(Cel)
			end
		elseif not MenuZed.comboConfig.wConfig.UWC then
			if myHero.mana > (WMana+EMana) and GetDistance(Cel) < Q.range then 
				CastW(Cel)
			end
		end
        CastE(Cel)
		if (WShadow) or (RShadow) or (myHero:CanUseSpell(_R) == NOTLEARNED) or (myHero:CanUseSpell(_R) == COOLDOWN) then
			CastQ(Cel)
		end
		if not MenuZed.comboConfig.IAU then
			UseItems(Cel)
		elseif MenuZed.comboConfig.IAU and TargetHaveBuff("zedulttargetmark", Cel) then
			UseItems(Cel)
		end
	end
	if MenuZed.comboConfig.wConfig.USW then
		Swap()
	end
	if MenuZed.comboConfig.rConfig.RHP >= 0 and RShadow and EnemyCount(RShadow, 250) <= 2 then
		SwapR()
	end
end

function Combo2()
	if Cel ~= nil and not (TargetHaveBuff("JudicatorIntervention", Cel) or TargetHaveBuff("Undying Rage", Cel)) then
		if (not W.Ready() or WShadow ~= nil or WCasted) then
            CastE(Cel)
			CastQ(Cel)
		end
		if MenuZed.comboConfig2.wConfig.USEW and ((GetDistance(Cel) < Q.range) or (GetDistance(Cel) > 125)) then
			if myHero.mana > (WMana+EMana) then
				CastW(Cel)
            end
		end
		if not MenuZed.comboConfig.IAU then
			UseItems(Cel)
		elseif MenuZed.comboConfig.IAU and TargetHaveBuff("zedulttargetmark", Cel) then
			UseItems(Cel)
		end
	end
	if MenuZed.comboConfig.wConfig.USW then
		Swap()
	end
	myHero:MoveTo(mousePos.x, mousePos.z)
end

function Swap()
	if (WShadow ~= nil and WShadow.valid) then
		wDist = GetDistance(Cel, WShadow)
		if GetDistance(Cel) > 450 then
			 if wDist and wDist ~= 0 and (GetDistance(Cel, myHero) > wDist) and W.Ready() then
				if WState() == 2 then
					CastSpell(_W)
				end
			 end
		end
	end
end

function SwapR()
	if RState() == 2 and ((myHero.health / myHero.maxHealth * 100) <= MenuZed.comboConfig.rConfig.RHP) then
        CastSpell(_R)
    end
end

function Harrass()
	if MenuZed.harrasConfig.HM == 1 then
		if ValidTarget(CelH) and GetDistance(CelH, myHero) < 1450 and GetDistance(CelH, myHero) > 900 then
            local Shadow = myHero + Vector(CelH.x - myHero.x, 0, CelH.z - myHero.z):normalized()*550
            if Q.Ready() and W.Ready() and (myHero.mana > QMana+WMana) then
				CastW(Shadow)
            end
			CastE(CelH)
			CastQ(CelH)
		elseif ValidTarget(CelH) and GetDistance(CelH, myHero) < 900 then
			if Q.Ready() and W.Ready() and (myHero.mana > QMana+WMana) then
				CastW(CelH)
			end
			CastE(CelH)
			CastQ(CelH)
        end
		if not W.Ready() then
			CastQ(CelH)
			CastE(CelH)
		end
	end
	if MenuZed.harrasConfig.HM == 2 then
		CastE(CelH)
		CastQ(CelH)
	end	
	if MenuZed.harrasConfig.HM == 3 then
		CastQ(CelH)
	end	          
end

function Farm()
	EnemyMinions:update()
	local QMode =  MenuZed.farm.QF
	local WMode =  MenuZed.farm.WF
	local EMode =  MenuZed.farm.EF
	for i, minion in pairs(EnemyMinions.objects) do
		if QMode == 3 then
			if Q.Ready() and minion ~= nil and ValidTarget(minion, Q.range) then
				local BestPos, BestHit = GetBestLineFarmPosition(Q.range, Q.width, EnemyMinions.objects)
				if BestPos ~= nil then
					CastSpell(_Q, BestPos.x, BestPos.z)
				end
			end
		elseif QMode == 2 then
			if minion ~= nil and ValidTarget(minion, Q.range) then
				if minion.health <= getDmg("Q", minion, myHero) then
					CastQ(minion)
				end
			end
		end
		if EMode == 3 then
			if minion ~= nil and ValidTarget(minion, E.range)then
				CastE(minion)
			end
		elseif EMode == 2 then
			if minion ~= nil and ValidTarget(minion, E.range) then
				if minion.health <= getDmg("E", minion, myHero) then
					CastE(minion)
				end
			end
		end
		if WMode == 2 and (QMode == 3 or EMode == 3) then
			if (myHero.mana > (WMana + QMana) or myHero.mana > (WMana + EMana))then
				local Pos, Hit = BestEFarmPos(W.range, E.range, EnemyMinions.objects)
				if Pos ~= nil then
					CastW(Pos)
				end
			end
		end
	end
end

function JungleFarmm()
	JungleMinions:update()
	for i, minion in pairs(JungleMinions.objects) do
		if MenuZed.jf.QJF then
			if Q.Ready() and minion ~= nil and ValidTarget(minion, Q.range) then
				local BestPos, BestHit = GetBestLineFarmPosition(Q.range, Q.width, JungleMinions.objects)
				if BestPos ~= nil then
					CastSpell(_Q, BestPos.x, BestPos.z)
				end
			end
		end
		if MenuZed.jf.WJF then
			if (myHero.mana > (WMana + QMana) or myHero.mana > (WMana + EMana)) then
				CastW(minion)
			end
		end
		if MenuZed.jf.EJF then
			if minion ~= nil and ValidTarget(minion, E.range) then
				CastE(minion)
			end
		end
	end
end

function GetBestLineFarmPosition(range, width, objects)
    local BestPos 
    local BestHit = 0
    for i, object in ipairs(objects) do
        local EndPos = Vector(myHero) + range * (Vector(object) - Vector(myHero)):normalized()
        local hit = CountObjectsOnLineSegment(myHero, EndPos, width, objects)
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

function CountObjectsOnLineSegment(StartPos, EndPos, width, objects)
    local n = 0
    for i, object in ipairs(objects) do
        local pointSegment, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(StartPos, EndPos, object)
        if isOnSegment and GetDistanceSqr(pointSegment, object) < width * width and GetDistanceSqr(StartPos, EndPos) > GetDistanceSqr(StartPos, object) then
            n = n + 1
        end
    end
    return n
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

function BestEFarmPos(range, radius, objects)
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

function autolvl()
	if not MenuZed.prConfig.ALS then return end
	if myHero.level > GetHeroLeveled() then
		local a = {_Q,_W,_E,_Q,_Q,_R,_Q,_W,_Q,_E,_R,_E,_E,_W,_W,_R,_W,_W}
		LevelSpell(a[GetHeroLeveled() + 1])
	end
end

function KillSteall()
	for i = 1, heroManager.iCount do
		local Enemy = heroManager:getHero(i)
		local health = Enemy.health
		ComboDamage(Enemy)
		if Enemy ~= nil and Enemy.team ~= player.team and not Enemy.dead and Enemy.visible then
			local IReady = SSpells:Ready("summonerdot")
			if health <= edmg and MenuZed.ksConfig.EKS then
				CastE(Enemy)
			elseif health < qdmg2 and MenuZed.ksConfig.QKS then
				CastQ(Enemy)
			elseif health < (qdmg2 + edmg) and ValidTarget(Enemy, E.range) then
				if MenuZed.ksConfig.QKS and MenuZed.ksConfig.EKS then
					CastQ(Enemy)
					CastE(Enemy)
				end
			elseif health < (qdmg2 + edmg + idmg) and IReady and ValidTarget(Enemy, E.range) then
				if MenuZed.ksConfig.QKS and MenuZed.ksConfig.EKS and MenuZed.ksConfig.IKS then
					CastQ(Enemy)
					CastE(Enemy)
					CastSpell(SSpells:GetSlot("summonerdot"), Enemy)
				end
			elseif health < idmg and MenuZed.ksConfig.IKS and ValidTarget(Enemy, 600) and IReady then
				CastSpell(SSpells:GetSlot("summonerdot"), Enemy)
			end
		end
	end
end
		
function ComboDamage(enemy)
	IReady = (SSpells:GetSlot("summonerdot") ~= nil and myHero:CanUseSpell(SSpells:GetSlot("summonerdot")) == READY)
    if IReady then
        idmg = 50 + (20 * myHero.level)
	end
    if Q.Ready() and W.Ready() then
        qdmg = getDmg("Q", enemy, myHero, 3) * 1.8
	elseif Q.Ready() and not W.Ready() then
        qdmg = getDmg("Q", enemy, myHero, 3)
	end
    if E.Ready() then
        edmg = getDmg("E", enemy, myHero, 3)
	end
    if R.Ready() then
        rdmg = getDmg("R", enemy, myHero, 1)
		rdmg = (myHero:GetSpellData(_R).level*0.15 + 0.05)*(rdmg + edmg + qdmg - idmg)
	end
	if Q.Ready() then
        qdmg2 = getDmg("Q", enemy, myHero, 3)
	end
    return idmg + qdmg + edmg + rdmg + qdmg2
end
	
function DmgCalc()
	for i=1, heroManager.iCount do
		local enemy = heroManager:GetHero(i)
        if not enemy.dead and enemy.visible then
			ComboDamage(enemy)
			if enemy.health < edmg then
				killstring[enemy.networkID] = "E Kill!"
			elseif enemy.health < qdmg2 then
				killstring[enemy.networkID] = "Q Kill!"
			elseif enemy.health < (qdmg2 + edmg) then
				killstring[enemy.networkID] = "Q+E Kill!"
			elseif enemy.health < (qdmg2 + edmg + idmg) then
				killstring[enemy.networkID] = "Q+E+Ignite Kill!"
			elseif enemy.health < (qdmg + edmg + rdmg) then
				killstring[enemy.networkID] = "R+Q+E Kill!"
			elseif enemy.health < (qdmg + edmg + rdmg + idmg) then
				killstring[enemy.networkID] = "R+Q+E+Ignite Kill!"
			elseif enemy.health > (qdmg + edmg + rdmg + idmg) then
				killstring[enemy.networkID] = "Harass Him !!!"
			end
        end
    end
end

function OnDraw()
	if MenuZed.drawConfig.DST then
		if SelectedTarget ~= nil and not SelectedTarget.dead then
			DrawCircle2(SelectedTarget.x, SelectedTarget.y, SelectedTarget.z, 100, RGB(MenuZed.drawConfig.DQRC[2], MenuZed.drawConfig.DQRC[3], MenuZed.drawConfig.DQRC[4]))
		end
	end
	if MenuZed.drawConfig.DD then	
		for _,enemy in pairs(GetEnemyHeroes()) do
			DmgCalc()
			if ValidTarget(enemy, 1500) and killstring[enemy.networkID] ~= nil then
                local pos = WorldToScreen(D3DXVECTOR3(enemy.x, enemy.y, enemy.z))
                DrawText(killstring[enemy.networkID], 20, pos.x - 35, pos.y - 10, 0xFFFFFF00)
            end
		end
	end
	if MenuZed.drawConfig.DQR and Q.Ready() then
		DrawCircle2(myHero.x, myHero.y, myHero.z, Q.range, RGB(MenuZed.drawConfig.DQRC[2], MenuZed.drawConfig.DQRC[3], MenuZed.drawConfig.DQRC[4]))
	end
	if MenuZed.drawConfig.DWR and W.Ready() then			
		DrawCircle2(myHero.x, myHero.y, myHero.z, W.range, RGB(MenuZed.drawConfig.DWRC[2], MenuZed.drawConfig.DWRC[3], MenuZed.drawConfig.DWRC[4]))
	end
	if MenuZed.drawConfig.DER and E.Ready() then			
		DrawCircle2(myHero.x, myHero.y, myHero.z, E.range, RGB(MenuZed.drawConfig.DERC[2], MenuZed.drawConfig.DERC[3], MenuZed.drawConfig.DERC[4]))
	end
	if MenuZed.drawConfig.DRR and R.Ready() then			
		DrawCircle2(myHero.x, myHero.y, myHero.z, R.range, RGB(MenuZed.drawConfig.DRRC[2], MenuZed.drawConfig.DRRC[3], MenuZed.drawConfig.DRRC[4]))
	end
end

function GetShadow()
	return WShadow or RShadow or myHero
end

function OnCreateObj(obj)
	if obj.valid and obj.name:lower() == "shadow" and obj.team == myHero.team then
		if WCasted then
			WShadow = obj
		elseif RCasted and not WCasted then
			RShadow = obj
		end
	end
	if obj.valid and obj.name:lower():find("zed_base_r_buf_tell.troy") then
        DeadMark = true
        PrintAlert("Target Now Dead By Mark!!!", 4, 255, 55, 0)
    end
end
 
function OnDeleteObj(obj)
	if obj.valid and obj.name:lower():find("zed_clone_idle") then
		if obj.valid and WShadow then
			WShadow = nil
			WCasted = false
		elseif obj.valid and RShadow then
			RShadow = nil
			RCasted = false
		end
	end
	if obj.valid and obj.name:lower():find("zed_base_r_buf_tell.troy") then
        DeadMark = false
    end
end

function CastQ(unit)
	if Q.Ready() and ValidTarget(unit) then
		local from = GetShadow()
		if MenuZed.prConfig.pro == 1 then
			local castPosition,  HitChance,  Position = VP:GetLineCastPosition(unit, Q.delay, Q.width, Q.range, Q.speed, from, false)
			if HitChance >= 2 then
				if VIP_USER and MenuZed.prConfig.pc then
					Packet("S_CAST", {spellId = _Q, fromX = castPosition.x, fromY = castPosition.z, toX = castPosition.x, toY = castPosition.z}):send()
				else
					CastSpell(_Q, castPosition.x, castPosition.z)
				end
			end
		end
		if MenuZed.prConfig.pro == 2 and VIP_USER and prodstatus then
			local castPosition, info = Prodiction.GetPrediction(unit, Q.range, Q.speed, Q.delay, Q.width, from)
			if castPosition ~= nil then
				if VIP_USER and MenuZed.prConfig.pc then
					Packet("S_CAST", {spellId = _Q, fromX = castPosition.x, fromY = castPosition.z, toX = castPosition.x, toY = castPosition.z}):send()
				else
					CastSpell(_Q, castPosition.x, castPosition.z)
				end
			end
		end
		if MenuZed.prConfig.pro == 3 and VIP_USER then
			local unit = DPTarget(unit)
			local ZedQ = LineSS(Q.speed, Q.range, Q.width, Q.delay*1000, math.huge)
			local State, Position, perc = DP:predict(unit, ZedQ, 2, Vector(from))
			if State == SkillShot.STATUS.SUCCESS_HIT then 
				if VIP_USER and MenuZed.prConfig.pc then
					Packet("S_CAST", {spellId = _Q, fromX = Position.x, fromY = Position.z, toX = Position.x, toY = Position.z}):send()
				else
					CastSpell(_Q, Position.x, Position.z)
				end
			end
		end
	end
end

function CastW(pos)
	if W.Ready() and WState() == 1 then
		if VIP_USER and MenuZed.prConfig.pc then
			Packet("S_CAST", {spellId = _W, fromX = pos.x, fromY = pos.z, toX = pos.x, toY = pos.z}):send()
		else
			CastSpell(_W, pos.x, pos.z)
		end
	end
end

function CastE(unit)
	if E.Ready() then
		local from = GetShadow()
		if GetDistance(from, unit) <= E.range then
			if VIP_USER and MenuZed.prConfig.pc then
				Packet("S_CAST", {spellId = _E}):send()
			else
				CastSpell(_E)
			end
		end
	end
end

function CastR(unit)
	if VIP_USER and MenuZed.prConfig.pc then
		Packet("S_CAST", {spellId = _R, targetNetworkId = unit.networkID}):send()
	else
		CastSpell(_R, unit)
	end
end

function WState()
	if myHero:GetSpellData(_W).name ~= "zedw2" then
		return 1
	elseif myHero:GetSpellData(_W).name == "zedw2" then
		return 2
	end
end

function RState()
	if myHero:GetSpellData(_R).name ~= "zedr2" then
		return 1
	elseif myHero:GetSpellData(_R).name == "zedr2" then
		return 2
	end
end

function OnApplyBuff(source, unit, buff)	
	if unit and unit.isMe and buff and buff.name == "Recall" then
		recall = true
	end
end

function OnRemoveBuff(unit, buff)
	if unit and unit.isMe and buff and buff.name == "Recall" then
		recall = false
	end
end

function OnProcessSpell(unit, spell)
	if MenuZed.exConfig.UIS then
		if unit and unit.team ~= myHero.team and not myHero.dead and unit.type == myHero.type and spell then
		    shottype,radius,maxdistance = 0,0,0
		    if unit.type == "obj_AI_Hero" and interputtspells[spell.name] and MenuZed.exConfig.IS[spell.name]then
			    spelltype, casttype = getSpellType(unit, spell.name)
			    if casttype == 4 or casttype == 5 or casttype == 6 then return end
			    if (spelltype == "Q" or spelltype == "W" or spelltype == "E" or spelltype == "R") then
				    shottype = skillData[unit.charName][spelltype]["type"]
				    radius = skillData[unit.charName][spelltype]["radius"]
				    maxdistance = skillData[unit.charName][spelltype]["maxdistance"]
			    end
		    end
			allytarget = myHero
			if allytarget.team == myHero.team and not allytarget.dead and allytarget.health > 0 then
				hitchampion = false
				local allyHitBox = allytarget.boundingRadius
				if shottype == 0 then hitchampion = spell.target and spell.target.networkID == allytarget.networkID
					elseif shottype == 1 then hitchampion = checkhitlinepass(unit, spell.endPos, radius, maxdistance, allytarget, allyHitBox)
					elseif shottype == 2 then hitchampion = checkhitlinepoint(unit, spell.endPos, radius, maxdistance, allytarget, allyHitBox)
					elseif shottype == 3 then hitchampion = checkhitaoe(unit, spell.endPos, radius, maxdistance, allytarget, allyHitBox)
					elseif shottype == 4 then hitchampion = checkhitcone(unit, spell.endPos, radius, maxdistance, allytarget, allyHitBox)
					elseif shottype == 5 then hitchampion = checkhitwall(unit, spell.endPos, radius, maxdistance, allytarget, allyHitBox)
					elseif shottype == 6 then hitchampion = checkhitlinepass(unit, spell.endPos, radius, maxdistance, allytarget, allyHitBox) or checkhitlinepass(unit, Vector(unit)*2-spell.endPos, radius, maxdistance, allytarget, allyHitBox)
					elseif shottype == 7 then hitchampion = checkhitcone(spell.endPos, unit, radius, maxdistance, allytarget, allyHitBox)
				end
				if hitchampion then
					if R.Ready() and interputtspells[spell.name] and MenuZed.exConfig.IS[spell.name] then
						if ValidTarget(unit, R.range) then
							CastR(unit)
						end
				    end
			    end
		    end
		end
	end
	if unit.isMe and spell.name == "ZedShadowDash" then
        WCasted = true
    end
	if unit.isMe and spell.name == "zedr2" then
        RCasted = true
    end
end

--[[		Code	by Bilbao	]]
function OnWndMsg(Msg, Key)
	if Msg == WM_LBUTTONDOWN and MenuZed.comboConfig.ST then
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
				if MenuZed.comboConfig.ST then 
					print("Target unselected: "..Selecttarget.charName) 
				end
			else
				SelectedTarget = Selecttarget
				if MenuZed.comboConfig.ST then 
					print("New target selected: "..Selecttarget.charName) 
				end
			end
		end
	end
end
--------------------------------------------------------

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

--[[		Code	by eXtragoZ	]]
local spellsFile = LIB_PATH.."missedspells.txt"
local spellslist = {}
local textlist = ""
local spellexists = false
local spelltype = "Unknown"

function writeConfigsspells()
	local file = io.open(spellsFile, "w")
	if file then
		textlist = "return {"
		for i=1,#spellslist do
			textlist = textlist.."'"..spellslist[i].."', "
		end
		textlist = textlist.."}"
		if spellslist[1] ~=nil then
			file:write(textlist)
			file:close()
		end
	end
end
if FileExist(spellsFile) then spellslist = dofile(spellsFile) end

local Others = {"Recall","recall","OdinCaptureChannel","LanternWAlly","varusemissiledummy","khazixqevo","khazixwevo","khazixeevo","khazixrevo","braumedummyvoezreal","braumedummyvonami","braumedummyvocaitlyn","braumedummyvoriven","braumedummyvodraven","braumedummyvoashe","azirdummyspell"}
local Items = {"RegenerationPotion","FlaskOfCrystalWater","ItemCrystalFlask","ItemMiniRegenPotion","PotionOfBrilliance","PotionOfElusiveness","PotionOfGiantStrength","OracleElixirSight","OracleExtractSight","VisionWard","SightWard","sightward","ItemGhostWard","ItemMiniWard","ElixirOfRage","ElixirOfIllumination","wrigglelantern","DeathfireGrasp","HextechGunblade","shurelyascrest","IronStylus","ZhonyasHourglass","YoumusBlade","randuinsomen","RanduinsOmen","Mourning","OdinEntropicClaymore","BilgewaterCutlass","QuicksilverSash","HextechSweeper","ItemGlacialSpike","ItemMercurial","ItemWraithCollar","ItemSoTD","ItemMorellosBane","ItemPromote","ItemTiamatCleave","Muramana","ItemSeraphsEmbrace","ItemSwordOfFeastAndFamine","ItemFaithShaker","OdynsVeil","ItemHorn","ItemPoroSnack","ItemBlackfireTorch","HealthBomb","ItemDervishBlade","TrinketTotemLvl1","TrinketTotemLvl2","TrinketTotemLvl3","TrinketTotemLvl3B","TrinketSweeperLvl1","TrinketSweeperLvl2","TrinketSweeperLvl3","TrinketOrbLvl1","TrinketOrbLvl2","TrinketOrbLvl3","OdinTrinketRevive","RelicMinorSpotter","RelicSpotter","RelicGreaterLantern","RelicLantern","RelicSmallLantern","ItemFeralFlare","trinketorblvl2","trinketsweeperlvl2","trinkettotemlvl2","SpiritLantern","RelicGreaterSpotter"}
local MSpells = {"JayceStaticField","JayceToTheSkies","JayceThunderingBlow","Takedown","Pounce","Swipe","EliseSpiderQCast","EliseSpiderW","EliseSpiderEInitial","elisespidere","elisespideredescent","gnarbigq","gnarbigw","gnarbige","GnarBigQMissile"}
local PSpells = {"CaitlynHeadshotMissile","RumbleOverheatAttack","JarvanIVMartialCadenceAttack","ShenKiAttack","MasterYiDoubleStrike","sonaqattackupgrade","sonawattackupgrade","sonaeattackupgrade","NocturneUmbraBladesAttack","NautilusRavageStrikeAttack","ZiggsPassiveAttack","QuinnWEnhanced","LucianPassiveAttack","SkarnerPassiveAttack","KarthusDeathDefiedBuff","AzirTowerClick","azirtowerclick","azirtowerclickchannel"}

local QSpells = {"TrundleQ","LeonaShieldOfDaybreakAttack","XenZhaoThrust","NautilusAnchorDragMissile","RocketGrabMissile","VayneTumbleAttack","VayneTumbleUltAttack","NidaleeTakedownAttack","ShyvanaDoubleAttackHit","ShyvanaDoubleAttackHitDragon","frostarrow","FrostArrow","MonkeyKingQAttack","MaokaiTrunkLineMissile","FlashFrostSpell","xeratharcanopulsedamage","xeratharcanopulsedamageextended","xeratharcanopulsedarkiron","xeratharcanopulsediextended","SpiralBladeMissile","EzrealMysticShotMissile","EzrealMysticShotPulseMissile","jayceshockblast","BrandBlazeMissile","UdyrTigerAttack","TalonNoxianDiplomacyAttack","LuluQMissile","GarenSlash2","VolibearQAttack","dravenspinningattack","karmaheavenlywavec","ZiggsQSpell","UrgotHeatseekingHomeMissile","UrgotHeatseekingLineMissile","JavelinToss","RivenTriCleave","namiqmissile","NasusQAttack","BlindMonkQOne","ThreshQInternal","threshqinternal","QuinnQMissile","LissandraQMissile","EliseHumanQ","GarenQAttack","JinxQAttack","JinxQAttack2","yasuoq","xeratharcanopulse2","VelkozQMissile","KogMawQMis","BraumQMissile","KarthusLayWasteA1","KarthusLayWasteA2","KarthusLayWasteA3","karthuslaywastea3","karthuslaywastea2","karthuslaywastedeada1","MaokaiSapling2Boom","gnarqmissile","GnarBigQMissile","viktorqbuff"}
local WSpells = {"KogMawBioArcaneBarrageAttack","SivirWAttack","TwitchVenomCaskMissile","gravessmokegrenadeboom","mordekaisercreepingdeath","DrainChannel","jaycehypercharge","redcardpreattack","goldcardpreattack","bluecardpreattack","RenektonExecute","RenektonSuperExecute","EzrealEssenceFluxMissile","DariusNoxianTacticsONHAttack","UdyrTurtleAttack","talonrakemissileone","LuluWTwo","ObduracyAttack","KennenMegaProc","NautilusWideswingAttack","NautilusBackswingAttack","XerathLocusOfPower","yoricksummondecayed","Bushwhack","karmaspiritbondc","SejuaniBasicAttackW","AatroxWONHAttackLife","AatroxWONHAttackPower","JinxWMissile","GragasWAttack","braumwdummyspell","syndrawcast","SorakaWParticleMissile"}
local ESpells = {"KogMawVoidOozeMissile","ToxicShotAttack","LeonaZenithBladeMissile","PowerFistAttack","VayneCondemnMissile","ShyvanaFireballMissile","maokaisapling2boom","VarusEMissile","CaitlynEntrapmentMissile","jayceaccelerationgate","syndrae5","JudicatorRighteousFuryAttack","UdyrBearAttack","RumbleGrenadeMissile","Slash","hecarimrampattack","ziggse2","UrgotPlasmaGrenadeBoom","SkarnerFractureMissile","YorickSummonRavenous","BlindMonkEOne","EliseHumanE","PrimalSurge","Swipe","ViEAttack","LissandraEMissile","yasuodummyspell","XerathMageSpearMissile","RengarEFinal","RengarEFinalMAX","KarthusDefileSoundDummy2"}
local RSpells = {"Pantheon_GrandSkyfall_Fall","LuxMaliceCannonMis","infiniteduresschannel","JarvanIVCataclysmAttack","jarvanivcataclysmattack","VayneUltAttack","RumbleCarpetBombDummy","ShyvanaTransformLeap","jaycepassiverangedattack", "jaycepassivemeleeattack","jaycestancegth","MissileBarrageMissile","SprayandPrayAttack","jaxrelentlessattack","syndrarcasttime","InfernalGuardian","UdyrPhoenixAttack","FioraDanceStrike","xeratharcanebarragedi","NamiRMissile","HallucinateFull","QuinnRFinale","lissandrarenemy","SejuaniGlacialPrisonCast","yasuordummyspell","xerathlocuspulse","tempyasuormissile","PantheonRFall"}

local casttype2 = {"blindmonkqtwo","blindmonkwtwo","blindmonketwo","infernalguardianguide","KennenMegaProc","sonawattackupgrade","redcardpreattack","fizzjumptwo","fizzjumpbuffer","gragasbarrelrolltoggle","LeblancSlideM","luxlightstriketoggle","UrgotHeatseekingHomeMissile","xeratharcanopulseextended","xeratharcanopulsedamageextended","XenZhaoThrust3","ziggswtoggle","khazixwlong","khazixelong","renektondice","SejuaniNorthernWinds","shyvanafireballdragon2","shyvanaimmolatedragon","ShyvanaDoubleAttackHitDragon","talonshadowassaulttoggle","viktorchaosstormguide","zedw2","ZedR2","khazixqlong","AatroxWONHAttackLife","viktorqbuff"}
local casttype3 = {"sonaeattackupgrade","bluecardpreattack","LeblancSoulShackleM","UdyrPhoenixStance","RenektonSuperExecute"}
local casttype4 = {"FrostShot","PowerFist","DariusNoxianTacticsONH","EliseR","JaxEmpowerTwo","JaxRelentlessAssault","JayceStanceHtG","jaycestancegth","jaycehypercharge","JudicatorRighteousFury","kennenlrcancel","KogMawBioArcaneBarrage","LissandraE","MordekaiserMaceOfSpades","mordekaisercotgguide","NasusQ","Takedown","NocturneParanoia","QuinnR","RengarQ","HallucinateFull","DeathsCaressFull","SivirW","ThreshQInternal","threshqinternal","PickACard","goldcardlock","redcardlock","bluecardlock","FullAutomatic","VayneTumble","MonkeyKingDoubleAttack","YorickSpectral","ViE","VorpalSpikes","FizzSeastonePassive","GarenSlash3","HecarimRamp","leblancslidereturn","leblancslidereturnm","Obduracy","UdyrTigerStance","UdyrTurtleStance","UdyrBearStance","UrgotHeatseekingMissile","XenZhaoComboTarget","dravenspinning","dravenrdoublecast","FioraDance","LeonaShieldOfDaybreak","MaokaiDrain3","NautilusPiercingGaze","RenektonPreExecute","RivenFengShuiEngine","ShyvanaDoubleAttack","shyvanadoubleattackdragon","SyndraW","TalonNoxianDiplomacy","TalonCutthroat","talonrakemissileone","TrundleTrollSmash","VolibearQ","AatroxW","aatroxw2","AatroxWONHAttackLife","JinxQ","GarenQ","yasuoq","XerathArcanopulseChargeUp","XerathLocusOfPower2","xerathlocuspulse","velkozqsplitactivate","NetherBlade","GragasQToggle","GragasW","SionW","sionpassivespeed"}
local casttype5 = {"VarusQ","ZacE","ViQ","SionQ"}
local casttype6 = {"VelkozQMissile","KogMawQMis","RengarEFinal","RengarEFinalMAX","BraumQMissile","KarthusDefileSoundDummy2","gnarqmissile","GnarBigQMissile","SorakaWParticleMissile"}
--,"PoppyDevastatingBlow"--,"Deceive" -- ,"EliseRSpider"
function getSpellType(unit, spellName)
	spelltype = "Unknown"
	casttype = 1
	if unit ~= nil and unit.type == "AIHeroClient" then
		if spellName == nil or unit:GetSpellData(_Q).name == nil or unit:GetSpellData(_W).name == nil or unit:GetSpellData(_E).name == nil or unit:GetSpellData(_R).name == nil then
			return "Error name nil", casttype
		end
		if spellName:find("SionBasicAttackPassive") or spellName:find("zyrapassive") then
			spelltype = "P"
		elseif (spellName:find("BasicAttack") and spellName ~= "SejuaniBasicAttackW") or spellName:find("basicattack") or spellName:find("JayceRangedAttack") or spellName == "SonaQAttack" or spellName == "SonaWAttack" or spellName == "SonaEAttack" or spellName == "ObduracyAttack" or spellName == "GnarBigAttackTower" then
			spelltype = "BAttack"
		elseif spellName:find("CritAttack") or spellName:find("critattack") then
			spelltype = "CAttack"
		elseif unit:GetSpellData(_Q).name:find(spellName) then
			spelltype = "Q"
		elseif unit:GetSpellData(_W).name:find(spellName) then
			spelltype = "W"
		elseif unit:GetSpellData(_E).name:find(spellName) then
			spelltype = "E"
		elseif unit:GetSpellData(_R).name:find(spellName) then
			spelltype = "R"
		elseif spellName:find("Summoner") or spellName:find("summoner") or spellName == "teleportcancel" then
			spelltype = "Summoner"
		else
			if spelltype == "Unknown" then
				for i=1,#Others do
					if spellName:find(Others[i]) then
						spelltype = "Other"
					end
				end
			end
			if spelltype == "Unknown" then
				for i=1,#Items do
					if spellName:find(Items[i]) then
						spelltype = "Item"
					end
				end
			end
			if spelltype == "Unknown" then
				for i=1,#PSpells do
					if spellName:find(PSpells[i]) then
						spelltype = "P"
					end
				end
			end
			if spelltype == "Unknown" then
				for i=1,#QSpells do
					if spellName:find(QSpells[i]) then
						spelltype = "Q"
					end
				end
			end
			if spelltype == "Unknown" then
				for i=1,#WSpells do
					if spellName:find(WSpells[i]) then
						spelltype = "W"
					end
				end
			end
			if spelltype == "Unknown" then
				for i=1,#ESpells do
					if spellName:find(ESpells[i]) then
						spelltype = "E"
					end
				end
			end
			if spelltype == "Unknown" then
				for i=1,#RSpells do
					if spellName:find(RSpells[i]) then
						spelltype = "R"
					end
				end
			end
		end
		for i=1,#MSpells do
			if spellName == MSpells[i] then
				spelltype = spelltype.."M"
			end
		end
		local spellexists = spelltype ~= "Unknown"
		if #spellslist > 0 and not spellexists then
			for i=1,#spellslist do
				if spellName == spellslist[i] then
					spellexists = true
				end
			end
		end
		if not spellexists then
			table.insert(spellslist, spellName)
			writeConfigsspells()
			PrintChat("Skill Detector - Unknown spell: "..spellName)
		end
	end
	for i=1,#casttype2 do
		if spellName == casttype2[i] then casttype = 2 end
	end
	for i=1,#casttype3 do
		if spellName == casttype3[i] then casttype = 3 end
	end
	for i=1,#casttype4 do
		if spellName == casttype4[i] then casttype = 4 end
	end
	for i=1,#casttype5 do
		if spellName == casttype5[i] then casttype = 5 end
	end
	for i=1,#casttype6 do
		if spellName == casttype6[i] then casttype = 6 end
	end

	return spelltype, casttype
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
assert(load(Base64Decode("G0x1YVIAAQQEBAgAGZMNChoKAAAAAAAAAAAAAQIKAAAABgBAAEFAAAAdQAABBkBAAGUAAAAKQACBBkBAAGVAAAAKQICBHwCAAAQAAAAEBgAAAGNsYXNzAAQNAAAAU2NyaXB0U3RhdHVzAAQHAAAAX19pbml0AAQLAAAAU2VuZFVwZGF0ZQACAAAAAgAAAAgAAAACAAotAAAAhkBAAMaAQAAGwUAABwFBAkFBAQAdgQABRsFAAEcBwQKBgQEAXYEAAYbBQACHAUEDwcEBAJ2BAAHGwUAAxwHBAwECAgDdgQABBsJAAAcCQQRBQgIAHYIAARYBAgLdAAABnYAAAAqAAIAKQACFhgBDAMHAAgCdgAABCoCAhQqAw4aGAEQAx8BCAMfAwwHdAIAAnYAAAAqAgIeMQEQAAYEEAJ1AgAGGwEQA5QAAAJ1AAAEfAIAAFAAAAAQFAAAAaHdpZAAEDQAAAEJhc2U2NEVuY29kZQAECQAAAHRvc3RyaW5nAAQDAAAAb3MABAcAAABnZXRlbnYABBUAAABQUk9DRVNTT1JfSURFTlRJRklFUgAECQAAAFVTRVJOQU1FAAQNAAAAQ09NUFVURVJOQU1FAAQQAAAAUFJPQ0VTU09SX0xFVkVMAAQTAAAAUFJPQ0VTU09SX1JFVklTSU9OAAQEAAAAS2V5AAQHAAAAc29ja2V0AAQIAAAAcmVxdWlyZQAECgAAAGdhbWVTdGF0ZQAABAQAAAB0Y3AABAcAAABhc3NlcnQABAsAAABTZW5kVXBkYXRlAAMAAAAAAADwPwQUAAAAQWRkQnVnc3BsYXRDYWxsYmFjawABAAAACAAAAAgAAAAAAAMFAAAABQAAAAwAQACBQAAAHUCAAR8AgAACAAAABAsAAABTZW5kVXBkYXRlAAMAAAAAAAAAQAAAAAABAAAAAQAQAAAAQG9iZnVzY2F0ZWQubHVhAAUAAAAIAAAACAAAAAgAAAAIAAAACAAAAAAAAAABAAAABQAAAHNlbGYAAQAAAAAAEAAAAEBvYmZ1c2NhdGVkLmx1YQAtAAAAAwAAAAMAAAAEAAAABAAAAAQAAAAEAAAABAAAAAQAAAAEAAAABAAAAAUAAAAFAAAABQAAAAUAAAAFAAAABQAAAAUAAAAFAAAABgAAAAYAAAAGAAAABgAAAAUAAAADAAAAAwAAAAYAAAAGAAAABgAAAAYAAAAGAAAABgAAAAYAAAAHAAAABwAAAAcAAAAHAAAABwAAAAcAAAAHAAAABwAAAAcAAAAIAAAACAAAAAgAAAAIAAAAAgAAAAUAAABzZWxmAAAAAAAtAAAAAgAAAGEAAAAAAC0AAAABAAAABQAAAF9FTlYACQAAAA4AAAACAA0XAAAAhwBAAIxAQAEBgQAAQcEAAJ1AAAKHAEAAjABBAQFBAQBHgUEAgcEBAMcBQgABwgEAQAKAAIHCAQDGQkIAx4LCBQHDAgAWAQMCnUCAAYcAQACMAEMBnUAAAR8AgAANAAAABAQAAAB0Y3AABAgAAABjb25uZWN0AAQRAAAAc2NyaXB0c3RhdHVzLm5ldAADAAAAAAAAVEAEBQAAAHNlbmQABAsAAABHRVQgL3N5bmMtAAQEAAAAS2V5AAQCAAAALQAEBQAAAGh3aWQABAcAAABteUhlcm8ABAkAAABjaGFyTmFtZQAEJgAAACBIVFRQLzEuMA0KSG9zdDogc2NyaXB0c3RhdHVzLm5ldA0KDQoABAYAAABjbG9zZQAAAAAAAQAAAAAAEAAAAEBvYmZ1c2NhdGVkLmx1YQAXAAAACgAAAAoAAAAKAAAACgAAAAoAAAALAAAACwAAAAsAAAALAAAADAAAAAwAAAANAAAADQAAAA0AAAAOAAAADgAAAA4AAAAOAAAACwAAAA4AAAAOAAAADgAAAA4AAAACAAAABQAAAHNlbGYAAAAAABcAAAACAAAAYQAAAAAAFwAAAAEAAAAFAAAAX0VOVgABAAAAAQAQAAAAQG9iZnVzY2F0ZWQubHVhAAoAAAABAAAAAQAAAAEAAAACAAAACAAAAAIAAAAJAAAADgAAAAkAAAAOAAAAAAAAAAEAAAAFAAAAX0VOVgA="), nil, "bt", _ENV))() ScriptStatus("UHKIIOPLKGO") 
