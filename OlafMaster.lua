--[[

	Script Name: OLAF MASTER 
	Author: kokosik1221
	Last Version: 0.73
	07.04.2015

]]--


if myHero.charName ~= "Olaf" then return end

local autoupdate = true
local version = 0.73
 
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
	local scriptName = "OlafMaster"
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
    print("<font color=\"#FFFFFF\"><b>" .. "OlafMaster" .. ":</b></font> <font color=\"#FFFFFF\">" .. message .. "</font>") 
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

local Items = {
	BRK = { id = 3153, range = 450, reqTarget = true, slot = nil },
	BWC = { id = 3144, range = 400, reqTarget = true, slot = nil },
	RSH = { id = 3074, range = 350, reqTarget = false, slot = nil },
	STD = { id = 3131, range = 350, reqTarget = false, slot = nil },
	TMT = { id = 3077, range = 350, reqTarget = false, slot = nil },
	YGB = { id = 3142, range = 350, reqTarget = false, slot = nil },
	RND = { id = 3143, range = 275, reqTarget = false, slot = nil },
}

local ccspells = {
	['GalioIdolOfDurand'] = {charName = "Galio", spellSlot = "R", SpellType = "skillshot"},
    ['GnarBigW'] = {charName = "Gnar", spellSlot = "W", SpellType = "skillshot"},
    ['GnarBigR'] = {charName = "Gnar", spellSlot = "R", SpellType = "skillshot"},	
	['NamiQ'] = {charName = "Nami", spellSlot = "Q", SpellType = "skillshot"},
    ['NamiR'] = {charName = "Nami", spellSlot = "R", SpellType = "skillshot"},
	['LuxLightBinding'] = {charName = "Lux", spellSlot = "Q", SpellType = "skillshot"},
	['RenektonPreExecute'] = {charName = "Renekton", spellSlot = "W", SpellType = "skillshot"},
	['LeonaShieldOfDaybreak'] = {charName = "Leona", spellSlot = "Q", SpellType = "skillshot"},
    ['LeonaSolarFlare'] = {charName = "Leona", spellSlot = "R", SpellType = "skillshot"},
	['RengarE'] = {charName = "Rengar", spellSlot = "E", SpellType = "skillshot"},
	['LeblancSoulShackle'] = {charName = "Leblanc", spellSlot = "E", SpellType = "skillshot"},
	['LeblancSoulShackleM'] = {charName = "Leblanc", spellSlot = "R", SpellType = "skillshot"},
	['RivenMartyr'] = {charName = "Riven", spellSlot = "W", SpellType = "skillshot"},
	['LissandraW'] = {charName = "Lissandra", spellSlot = "W", SpellType = "skillshot"},
    ['LissandraR'] = {charName = "Lissandra", spellSlot = "R", SpellType = "skillshot"},
	['UFSlash'] = {charName = "Malphite", spellSlot = "R", SpellType = "skillshot"},
	['DarkBindingMissile'] = {charName = "Morgana", spellSlot = "Q", SpellType = "skillshot"},
	['SoulShackles'] = {charName = "Morgana", spellSlot = "R", SpellType = "skillshot"},
	['VarusR'] = {charName = "Varus", spellSlot = "R", SpellType = "skillshot"},
	['VeigarEventHorizon'] = {charName = "Veigar", spellSlot = "E", SpellType = "skillshot"},
	['VelkozE'] = {charName = "Velkoz", spellSlot = "E", SpellType = "skillshot"},
	['BraumR'] = {charName = "Braum", spellSlot = "R", SpellType = "skillshot"},
	['ViktorGravitonField'] = {charName = "Viktor", spellSlot = "W", SpellType = "skillshot"},
	['JackInTheBox'] = {charName = "Shaco", spellSlot = "W", SpellType = "skillshot"},
	['SejuaniGlacialPrisonStart'] = {charName = "Sejuani", spellSlot = "R", SpellType = "skillshot"},
	['SonaCrescendo'] = {charName = "Sona", spellSlot = "R", SpellType = "skillshot"},
	['InfuseWrapper'] = {charName = "Soraka", spellSlot = "E", SpellType = "skillshot"},
	['ShenShadowDash'] = {charName = "Shen", spellSlot = "E", SpellType = "skillshot"},
	['SwainShadowGrasp'] = {charName = "Swain", spellSlot = "W", SpellType = "skillshot"},
	['ThreshQ'] = {charName = "Thresh", spellSlot = "Q", SpellType = "skillshot"},
	['ThreshE'] = {charName = "Thresh", spellSlot = "E", SpellType = "skillshot"},
	['ThreshRPenta'] = {charName = "Thresh", spellSlot = "R", SpellType = "skillshot"},
	['AhriSeduce'] = {charName = "Ahri", spellSlot = "E", SpellType = "skillshot"},
	['BandageToss'] = {charName = "Amumu", spellSlot = "Q", SpellType = "skillshot"},
	['CurseoftheSadMummy'] = {charName = "Amumu", spellSlot = "R", SpellType = "skillshot"},
	['FlashFrost'] = {charName = "Anivia", spellSlot = "Q", SpellType = "skillshot"},
	['EnchantedCrystalArrow'] = {charName = "Ashe", spellSlot = "R", SpellType = "skillshot"},
	['YasuoRKnockUpComboW'] = {charName = "Yasuo", spellSlot = "R", SpellType = "skillshot"},
	['EliseHumanE'] = {charName = "Elise", spellSlot = "E", SpellType = "skillshot"},
	['MonkeyKingSpinToWin'] = {charName = "MonkeyKing", spellSlot = "R", SpellType = "skillshot"},
	['monkeykingspintowinleave'] = {charName = "MonkeyKing", spellSlot = "R", SpellType = "skillshot"},
	['OrianaDetonateCommand'] = {charName = "Orianna", spellSlot = "R", SpellType = "skillshot"},
	['ZyraGraspingRoots'] = {charName = "Zyra", spellSlot = "E", SpellType = "skillshot"},
	['ZyraBrambleZone'] = {charName = "Zyra", spellSlot = "R", SpellType = "skillshot"},
	['ZacR'] = {charName = "Zac", spellSlot = "R", SpellType = "skillshot"},
	['HowlingGale'] = {charName = "Janna", spellSlot = "Q", SpellType = "skillshot"},
	['ReapTheWhirlwind'] = {charName = "Janna", spellSlot = "R", SpellType = "skillshot"},
	['XerathMageSpear'] = {charName = "Xerath", spellSlot = "E", SpellType = "skillshot"},
	['Rupture'] = {charName = "Chogath", spellSlot = "Q", SpellType = "skillshot"},
	['FeralScream'] = {charName = "Chogath", spellSlot = "W", SpellType = "skillshot"},
	['KarmaSpiritBind'] = {charName = "Karma", spellSlot = "W", SpellType = "castcel"},
	['CassiopeiaPetrifyingGaze'] = {charName = "Cassiopeia", spellSlot = "R", SpellType = "skillshot"},
	['KennenShurikenStorm ']= {charName = "Kennen", spellSlot = "R", SpellType = "skillshot"},
	['FizzMarinerDoom'] = {charName = "Fizz", spellSlot = "R", SpellType = "skillshot"},
	['HecarimUlt'] = {charName = "Hecarim", spellSlot = "R", SpellType = "skillshot"},
	['Terrify'] = {charName = "FiddleSticks", spellSlot = "Q", SpellType = "castcel"},
	['Drain'] = {charName = "FiddleSticks", spellSlot = "W", SpellType = "castcel"},
	['Pantheon_LeapBash'] = {charName = "Pantheon", spellSlot = "W", SpellType = "castcel"},
	['Dazzle'] = {charName = "Taric", spellSlot = "E", SpellType = "castcel"},
	['zedult'] = {charName = "Zed", spellSlot = "R", SpellType = "castcel"},
	['IreliaEquilibriumStrike'] = {charName = "Irelia", spellSlot = "E", SpellType = "castcel"},
	['InfiniteDuress'] = {charName = "Warwick", spellSlot = "R", SpellType = "castcel"},
	['UrgotSwap2'] = {charName = "Urgot", spellSlot = "R", SpellType = "castcel"},
	['Pulverize'] = {charName = "Alistar", spellSlot = "Q", SpellType = "castcel"},
	['Headbutt'] = {charName = "Alistar", spellSlot = "W", SpellType = "castcel"},
	['SkarnerImpale'] = {charName = "Skarner", spellSlot = "R", SpellType = "castcel"},
	['CrypticGaze'] = {charName = "Sion", spellSlot = "Q", SpellType = "castcel"},
	['CrypticGaze'] = {charName = "Sion", spellSlot = "R", SpellType = "castcel"},
	['VayneCondemm'] = {charName = "Vayne", spellSlot = "E", SpellType = "castcel"},
	['ViR'] = {charName = "Vi", spellSlot = "R", SpellType = "castcel"},
	['PuncturingTaunt'] = {charName = "Rammus", spellSlot = "E", SpellType = "castcel"},
	['LuluW'] = {charName = "Lulu", spellSlot = "W", SpellType = "castcel"},
	['MaokaiUnstableGrowth'] = {charName = "Maokai", spellSlot = "W", SpellType = "castcel"},
	['AlZaharNetherGrasp'] = {charName = "Malzahar", spellSlot = "R", SpellType = "castcel"},
}
 
local Q = {name = "Undertow", range = 1000, speed = 1600, delay = 0.25, width = 60, Ready = function() return myHero:CanUseSpell(_Q) == READY end}
local W = {name = "Vicious Strikes", Ready = function() return myHero:CanUseSpell(_W) == READY end}
local E = {name = "Reckless Swing", range = 325, Ready = function() return myHero:CanUseSpell(_E) == READY end}
local R = {name = "Ragnarok", Ready = function() return myHero:CanUseSpell(_R) == READY end}
local pickaxe, recall = false, false
local EnemyMinions = minionManager(MINION_ENEMY, Q.range, myHero, MINION_SORT_MAXHEALTH_DEC)
local JungleMinions = minionManager(MINION_JUNGLE, Q.range, myHero, MINION_SORT_MAXHEALTH_DEC)
local axe = nil
local killstring = {}
local Spells = {_Q,_W,_E,_R}
local Spells2 = {"Q","W","E","R"}
local TargetTable = {
	AP = {
		"Annie", "Ahri", "Akali", "Anivia", "Annie", "Brand", "Cassiopeia", "Diana", "Evelynn", "FiddleSticks", "Fizz", "Gragas", "Heimerdinger", "Karthus",
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
	print("<b><font color=\"#FF0000\">Olaf Master:</font></b> <font color=\"#FFFFFF\">Good luck and give me feedback!</font>")
	if _G.MMA_Loaded then
		print("<b><font color=\"#FF0000\">Olaf Master:</font></b> <font color=\"#FFFFFF\">MMA Support Loaded.</font>")
	end	
	if _G.AutoCarry then
		print("<b><font color=\"#FF0000\">olaf Master:</font></b> <font color=\"#FFFFFF\">SAC Support Loaded.</font>")
	end
end

function OnTick()
	Check()
	if Cel ~= nil and MenuOlaf.comboConfig.CEnabled and not recall then
		Combo()
	end
	if Cel ~= nil and (MenuOlaf.harrasConfig.HEnabled or MenuOlaf.harrasConfig.HTEnabled) and not recall then
		Harrass()
	end
	if MenuOlaf.farm.LaneClear and not recall then
		Farm()
	end
	if MenuOlaf.jf.JFEnabled and not recall then
		JungleFarmF()
	end
	if MenuOlaf.prConfig.ALS and not recall then
		autolvl()
	end
	if MenuOlaf.exConfig.APA or MenuOlaf.exConfig.APA2 and not recall then
		AutoAxe()
	end
	if not recall then
		KillSteall()
	end
end

function Menu()
	MenuOlaf = scriptConfig("Olaf Master "..version, "Olaf Master "..version)
	MenuOlaf:addParam("orb", "Orbwalker:", SCRIPT_PARAM_LIST, 1, {"SxOrb","SAC:R/MMA"}) 
	MenuOlaf:addParam("qqq", "If You Change Orb. Click 2x F9", SCRIPT_PARAM_INFO,"")
	if MenuOlaf.orb == 1 then
		MenuOlaf:addSubMenu("[Olaf Master]: Orbwalking", "Orbwalking")
		SxOrb:LoadToMenu(MenuOlaf.Orbwalking)
	end
	TargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, Q.range, DAMAGE_PHYSICAL)
	TargetSelector.name = "Olaf"
	MenuOlaf:addTS(TargetSelector)
	MenuOlaf:addSubMenu("[Olaf Master]: Combo Settings", "comboConfig")
	MenuOlaf.comboConfig:addParam("USEQ", "Use " .. Q.name .. "(Q)", SCRIPT_PARAM_ONOFF, true)
	MenuOlaf.comboConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuOlaf.comboConfig:addParam("USEW", "Use " .. W.name .. "(W)", SCRIPT_PARAM_ONOFF, true)
	MenuOlaf.comboConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuOlaf.comboConfig:addParam("USEE", "Use " .. E.name .. "(E)", SCRIPT_PARAM_ONOFF, true)
	MenuOlaf.comboConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuOlaf.comboConfig:addParam("ST", "Focus Selected Target", SCRIPT_PARAM_ONOFF, false)
	MenuOlaf.comboConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuOlaf.comboConfig:addParam("CEnabled", "Full Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	MenuOlaf:addSubMenu("[Olaf Master]: Harras Settings", "harrasConfig")
	MenuOlaf.harrasConfig:addParam("HM", "Harrass Mode:", SCRIPT_PARAM_LIST, 2, {"|Q|", "|E|"}) 
	MenuOlaf.harrasConfig:addParam("HEnabled", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("K"))
	MenuOlaf.harrasConfig:addParam("HTEnabled", "Harass Toggle", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("L"))
	MenuOlaf.harrasConfig:addParam("manah", "Min. MP% To Harass", SCRIPT_PARAM_SLICE, 60, 0, 100, 0)
	MenuOlaf:addSubMenu("[Olaf Master]: KS Settings", "ksConfig")
	MenuOlaf.ksConfig:addParam("IKS", "Use Ignite To KS", SCRIPT_PARAM_ONOFF, true)
	MenuOlaf.ksConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuOlaf.ksConfig:addParam("QKS", "Use " .. Q.name .. "(Q)", SCRIPT_PARAM_ONOFF, true)
	MenuOlaf.ksConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuOlaf.ksConfig:addParam("EKS", "Use " .. E.name .. "(E)", SCRIPT_PARAM_ONOFF, false)
	MenuOlaf:addSubMenu("[Olaf Master]: LaneClear Settings", "farm")
	MenuOlaf.farm:addParam("QF", "Use " .. Q.name .. "(Q)", SCRIPT_PARAM_ONOFF, true)
	MenuOlaf.farm:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuOlaf.farm:addParam("WF", "Use " .. W.name .. "(W)", SCRIPT_PARAM_ONOFF, true)
	MenuOlaf.farm:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuOlaf.farm:addParam("EF", "Use " .. E.name .. "(E)", SCRIPT_PARAM_ONOFF, true)
	MenuOlaf.farm:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuOlaf.farm:addParam("LaneClear", "Lane Clear ", SCRIPT_PARAM_ONKEYDOWN, false,   string.byte("V"))
	MenuOlaf.farm:addParam("manaf", "Min. Mana To Farm", SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
	MenuOlaf:addSubMenu("[Olaf Master]: Jungle Farm Settings", "jf")
	MenuOlaf.jf:addParam("QJF", "Use " .. Q.name .. "(Q)", SCRIPT_PARAM_ONOFF, true)
	MenuOlaf.jf:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuOlaf.jf:addParam("WJF", "Use " .. W.name .. "(W)", SCRIPT_PARAM_ONOFF, true)
	MenuOlaf.jf:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuOlaf.jf:addParam("EJF", "Use " .. E.name .. "(E)", SCRIPT_PARAM_ONOFF, true)
	MenuOlaf.jf:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuOlaf.jf:addParam("JFEnabled", "Jungle Farm", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("V"))
	MenuOlaf.jf:addParam("manajf", "Min. Mana To Jungle Farm", SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
	MenuOlaf:addSubMenu("[Olaf Master]: Extra Settings", "exConfig")
	MenuOlaf.exConfig:addSubMenu("CC Spells", "ES")
	Enemies = GetEnemyHeroes() 
    for i,enemy in pairs (Enemies) do
		for j,spell in pairs (Spells) do 
			if ccspells[enemy:GetSpellData(spell).name] then 
				MenuOlaf.exConfig.ES:addParam(tostring(enemy:GetSpellData(spell).name),"Block "..tostring(enemy.charName).." Spell "..tostring(Spells2[j]),SCRIPT_PARAM_ONOFF,true)
			end 
		end 
	end 
	MenuOlaf.exConfig:addParam("AUCC", "Anty CC With (R)", SCRIPT_PARAM_ONOFF, true)
	MenuOlaf.exConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuOlaf.exConfig:addParam("APA", "Auto Pick Axe's (OnKeyDown)", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("SPACE"))
	MenuOlaf.exConfig:addParam("APA2", "Auto Pick Axe's (Toggle)", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("T"))
	MenuOlaf:addSubMenu("[Olaf Master]: Draw Settings", "drawConfig")
	MenuOlaf.drawConfig:addParam("DD", "Draw DMG Text", SCRIPT_PARAM_ONOFF, true)
	MenuOlaf.drawConfig:addParam("DST", "Draw Selected Target", SCRIPT_PARAM_ONOFF, false)
	MenuOlaf.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuOlaf.drawConfig:addParam("DAAR", "Draw AA Range", SCRIPT_PARAM_ONOFF, true)
	MenuOlaf.drawConfig:addParam("DAARC", "Draw AA Range Color", SCRIPT_PARAM_COLOR, {255,0,200,0})
	MenuOlaf.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuOlaf.drawConfig:addParam("DQR", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
	MenuOlaf.drawConfig:addParam("DQRC", "Draw Q Range Color", SCRIPT_PARAM_COLOR, {255,0,0,255})
	MenuOlaf.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuOlaf.drawConfig:addParam("DER", "Draw E Range", SCRIPT_PARAM_ONOFF, true)
	MenuOlaf.drawConfig:addParam("DERC", "Draw E Range Color", SCRIPT_PARAM_COLOR, {255,255,0,0})
	MenuOlaf:addSubMenu("[Olaf Master]: Misc Settings", "prConfig")
	MenuOlaf.prConfig:addParam("pc", "Use Packets To Cast Spells(VIP)", SCRIPT_PARAM_ONOFF, false)
	MenuOlaf.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuOlaf.prConfig:addParam("ALS", "Auto lvl skills", SCRIPT_PARAM_ONOFF, false)
	MenuOlaf.prConfig:addParam("AL", "Auto lvl sequence", SCRIPT_PARAM_LIST, 1, { "R>Q>W>E", "R>Q>E>W", "R>W>Q>E", "R>W>E>Q", "R>E>Q>W", "R>E>W>Q" })
	MenuOlaf.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuOlaf.prConfig:addParam("pro", "Prodiction To Use:", SCRIPT_PARAM_LIST, 1, {"VPrediction","Prodiction","DivinePred"}) 
	MenuOlaf.comboConfig:permaShow("CEnabled")
	MenuOlaf.harrasConfig:permaShow("HEnabled")
	MenuOlaf.harrasConfig:permaShow("HTEnabled")
	MenuOlaf.farm:permaShow("LaneClear")
	MenuOlaf.jf:permaShow("JFEnabled")
	MenuOlaf.exConfig:permaShow("AUCC")
	MenuOlaf.exConfig:permaShow("APA")
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
	if SelectedTarget ~= nil and ValidTarget(SelectedTarget, Q.range) then
		Cel = SelectedTarget
	else
		Cel = GetCustomTarget()
	end
	if MenuOlaf.orb == 1 then
		SxOrb:ForceTarget(Cel)
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

function getHitBoxRadius(target)
	return GetDistance(target.minBBox, target.maxBBox)/2
end

function Combo()
	UseItems(Cel)
	if MenuOlaf.comboConfig.USEQ then
		CastQ(Cel)
	end
	if MenuOlaf.comboConfig.USEW then
		CastW(Cel)
	end
	if MenuOlaf.comboConfig.USEE then
		CastE(Cel)
	end
end

function Harrass()
	if MenuOlaf.harrasConfig.HM == 1 and ((myHero.mana/myHero.maxMana)*100) >= MenuOlaf.harrasConfig.manah then
		CastQ(Cel)
	end
	if MenuOlaf.harrasConfig.HM == 2 then
		CastE(Cel)
	end
end

function Farm()
	EnemyMinions:update()
	for i, minion in pairs(EnemyMinions.objects) do
		if ((myHero.mana/myHero.maxMana)*100) >= MenuOlaf.farm.manaf then
			if MenuOlaf.farm.QF then
				local BestPos, BestHit = GetBestLineFarmPosition(Q.range, Q.width, EnemyMinions.objects)
				if BestPos ~= nil then
					CastSpell(_Q, BestPos.x, BestPos.z)
				end
			end
			if MenuOlaf.farm.WF then
				CastW(minion)
			end
			if MenuOlaf.farm.EF then
				CastE(minion)
			end
		end
	end
end

function JungleFarmF()
	JungleMinions:update()
	for i, minion in pairs(JungleMinions.objects) do
		if ((myHero.mana/myHero.maxMana)*100) >= MenuOlaf.jf.manajf then
			if MenuOlaf.jf.QJF then
				local BestPos, BestHit = GetBestLineFarmPosition(Q.range, Q.width, JungleMinions.objects)
				if BestPos ~= nil then
					CastSpell(_Q, BestPos.x, BestPos.z)
				end
			end
			if MenuOlaf.jf.WJF then
				CastW(minion)
			end
			if MenuOlaf.jf.EJF then
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

function AutoAxe()
	if not MenuOlaf.jf.JFEnabled and not MenuOlaf.farm.LaneClear and axe and GetDistance(myHero, axe) <= 365 then
        pickaxe = true
        myHero:MoveTo(axe.x, axe.z)
	end
	if axe and not Q.Ready() and GetDistance(myHero, axe) > 365 then
        pickaxe = false
    end
	if Q.Ready() then 
		pickaxe = false 
	end
end

function CastQ(unit)
	if Q.Ready() and ValidTarget(unit, Q.range) then
		if MenuOlaf.prConfig.pro == 1 then
			CastPosition,  HitChance,  Position = VP:GetLineCastPosition(unit, Q.delay, Q.width, Q.range - 30, Q.speed, myHero, false)
			if HitChance >= 2 then
				local x,y,z = (Vector(CastPosition) - Vector(myHero)):normalized():unpack()
				posX = CastPosition.x + (x * 150)
				posY = CastPosition.y + (y * 150)
				posZ = CastPosition.z + (z * 150)
				if VIP_USER and MenuOlaf.prConfig.pc then
					Packet("S_CAST", {spellId = _Q, fromX = posX, fromY = posZ, toX = posX, toY = posZ}):send()
				else
					CastSpell(_Q, posX, posZ)
				end	
			end
		end
		if MenuOlaf.prConfig.pro == 2 and VIP_USER and prodstatus then
			CastPosition, info = Prodiction.GetPrediction(unit, Q.range-30, Q.speed, Q.delay, Q.width, myHero)
			if CastPosition ~= nil then
				local x,y,z = (Vector(CastPosition) - Vector(myHero)):normalized():unpack()
				posX = CastPosition.x + (x * 150)
				posY = CastPosition.y + (y * 150)
				posZ = CastPosition.z + (z * 150)
				if VIP_USER and MenuOlaf.prConfig.pc then
					Packet("S_CAST", {spellId = _Q, fromX = posX, fromY = posZ, toX = posX, toY = posZ}):send()
				else
					CastSpell(_Q, posX, posZ)
				end	
			end
		end
		if MenuOlaf.prConfig.pro == 3 and VIP_USER then
			local unit = DPTarget(unit)
			local OlafQ = LineSS(Q.speed, Q.range, Q.width, Q.delay*1000, math.huge)
			local State, Position, perc = DP:predict(unit, OlafQ)
			if State == SkillShot.STATUS.SUCCESS_HIT then 
				local x,y,z = (Vector(Position) - Vector(myHero)):normalized():unpack()
				posX = Position.x + (x * 150)
				posY = Position.y + (y * 150)
				posZ = Position.z + (z * 150)
				if VIP_USER and MenuOlaf.prConfig.pc then
					Packet("S_CAST", {spellId = _Q, fromX = posX, fromY = posZ, toX = posX, toY = posZ}):send()
				else
					CastSpell(_Q, posX, posZ)
				end
			end
		end
	end
end

function CastW(unit)
	if W.Ready() and ValidTarget(unit, myHero.range+120) then
		if VIP_USER and MenuOlaf.prConfig.pc then
			Packet("S_CAST", {spellId = _W}):send()
		else
			CastSpell(_W)
		end
	end
end

function CastE(unit)
	if E.Ready() and ValidTarget(unit, E.range) then
		if VIP_USER and MenuOlaf.prConfig.pc then
			Packet("S_CAST", {spellId = _E, targetNetworkId = unit.networkID}):send()
		else
			CastSpell(_E, unit)
		end
	end
end

function KillSteall()
	for _, enemy in pairs(GetEnemyHeroes()) do
		local health = enemy.health
		local QDMG = myHero:CalcDamage(enemy, (45 * myHero:GetSpellData(0).level + 25 + myHero.addDamage)) 
		local EDMG = myHero:CalcDamage(enemy, (45 * myHero:GetSpellData(2).level + 25 + 0.4 * myHero.totalDamage))
		local IDMG = (50 + (20 * myHero.level))
		if ValidTarget(enemy, 1300) and enemy ~= nil then
			local IReady = SSpells:Ready("summonerdot")
			if health < QDMG and MenuOlaf.ksConfig.QKS and GetDistance(enemy) < Q.range - 30 and Q.Ready() then
				CastQ(enemy)
			elseif health < EDMG and MenuOlaf.ksConfig.EKS and GetDistance(enemy) <= E.range and E.Ready() then
				CastE(enemy)
			elseif health < IDMG and MenuOlaf.ksConfig.IKS and GetDistance(enemy) <= 600 and IReady then
				CastSpell(SSpells:GetSlot("summonerdot"), enemy)
			elseif health < (QDMG + EDMG) and MenuOlaf.ksConfig.QKS and MenuOlaf.ksConfig.EKS and GetDistance(enemy) <= E.range and Q.Ready() and E.Ready() then
				CastE(enemy)
				CastQ(enemy)
			elseif health < (QDMG + IDMG) and MenuOlaf.ksConfig.QKS and MenuOlaf.ksConfig.IKS and GetDistance(enemy) <= E.range and Q.Ready() and IReady then
				CastQ(enemy)
				CastSpell(SSpells:GetSlot("summonerdot"), enemy)
			elseif health < (EDMG + IDMG) and MenuOlaf.ksConfig.EKS and MenuOlaf.ksConfig.IKS and GetDistance(enemy) <= E.range and E.Ready() and IReady then
				CastE(enemy)
				CastSpell(SSpells:GetSlot("summonerdot"), enemy)
			elseif health < (QDMG + EDMG + IDMG) and MenuOlaf.ksConfig.QKS and MenuOlaf.ksConfig.EKS and MenuOlaf.ksConfig.IKS and GetDistance(enemy) <= E.range and Q.Ready() and E.Ready() and IReady then
				CastQ(enemy)
				CastE(enemy)
				CastSpell(SSpells:GetSlot("summonerdot"), enemy)
			end
		end
	end
end

function autolvl()
	if not MenuOlaf.prConfig.ALS then return end
	if myHero.level > GetHeroLeveled() then
		local a = {_Q,_W,_Q,_E,_Q,_R,_Q,_E,_Q,_E,_R,_E, _E,_W, _W, _R,_W,_W}
		LevelSpell(a[GetHeroLeveled() + 1])
	end
end

function OnDraw()
	if MenuOlaf.drawConfig.DST and MenuOlaf.comboConfig.ST then
		if SelectedTarget ~= nil and not SelectedTarget.dead then
			DrawCircle2(SelectedTarget.x, SelectedTarget.y, SelectedTarget.z, 100, RGB(MenuOlaf.drawConfig.DQRC[2], MenuOlaf.drawConfig.DQRC[3], MenuOlaf.drawConfig.DQRC[4]))
		end
	end
	if MenuOlaf.drawConfig.DD then
		for _,enemy in pairs(GetEnemyHeroes()) do
			DmgCalc()
            if ValidTarget(enemy, 1500) and killstring[enemy.networkID] ~= nil then
                local pos = WorldToScreen(D3DXVECTOR3(enemy.x, enemy.y, enemy.z))
                DrawText(killstring[enemy.networkID], 20, pos.x - 35, pos.y - 10, 0xFFFFFF00)
            end
        end
	end
	if MenuOlaf.drawConfig.DAAR then			
		DrawCircle2(myHero.x, myHero.y, myHero.z, myHero.range + VP:GetHitBox(myHero), RGB(MenuOlaf.drawConfig.DQRC[2], MenuOlaf.drawConfig.DQRC[3], MenuOlaf.drawConfig.DQRC[4]))
	end
	if MenuOlaf.drawConfig.DQR and Q.Ready() then			
		DrawCircle2(myHero.x, myHero.y, myHero.z, Q.range, RGB(MenuOlaf.drawConfig.DQRC[2], MenuOlaf.drawConfig.DQRC[3], MenuOlaf.drawConfig.DQRC[4]))
	end
	if MenuOlaf.drawConfig.DER and E.Ready() then			
		DrawCircle2(myHero.x, myHero.y, myHero.z, E.range, RGB(MenuOlaf.drawConfig.DERC[2], MenuOlaf.drawConfig.DERC[3], MenuOlaf.drawConfig.DERC[4]))
	end
end

function DmgCalc()
	for _, enemy in pairs(GetEnemyHeroes()) do
        if not enemy.dead and enemy.visible and GetDistance(enemy) < 3000 then
			local QDMG = myHero:CalcDamage(enemy, (45 * myHero:GetSpellData(0).level + 25 + myHero.addDamage)) 
			local EDMG = myHero:CalcDamage(enemy, (45 * myHero:GetSpellData(2).level + 25 + 0.4 * myHero.totalDamage))
			local IDMG = (50 + (20 * myHero.level))
			if enemy.health > (QDMG + EDMG + IDMG) then
				killstring[enemy.networkID] = "Harass Him!!!"
			elseif enemy.health < QDMG then
				killstring[enemy.networkID] = "Q Kill!"
			elseif enemy.health < EDMG then
				killstring[enemy.networkID] = "E Kill!"
			elseif enemy.health < IDMG then
				killstring[enemy.networkID] = "IGNITE Kill!"
			elseif enemy.health < (QDMG + EDMG) then
				killstring[enemy.networkID] = "Q+E Kill!"
			elseif enemy.health < (QDMG + IDMG) then
				killstring[enemy.networkID] = "Q+IGNITE Kill!"
			elseif enemy.health < (EDMG + IDMG) then
				killstring[enemy.networkID] = "E+IGNITE Kill!"
			elseif enemy.health < (QDMG + EDMG + IDMG) then
				killstring[enemy.networkID] = "Q+E+IGNITE Kill!"
			end
		end
	end
end

function OnProcessSpell(unit, spell)
	if MenuOlaf.exConfig.AUCC then
		if unit and unit.team ~= myHero.team and not myHero.dead and unit.type == myHero.type and spell then
		    shottype,radius,maxdistance = 0,0,0
		    if unit.type == "obj_AI_Hero" then
			    spelltype, casttype = getSpellType(unit, spell.name)
			    if casttype == 4 or casttype == 5 or casttype == 6 then return end
			    if (spelltype == "Q" or spelltype == "W" or spelltype == "E" or spelltype == "R") and ccspells[spell.name] then
				    shottype = skillData[unit.charName][spelltype]["type"]
				    radius = skillData[unit.charName][spelltype]["radius"]
				    maxdistance = skillData[unit.charName][spelltype]["maxdistance"]
			    end
		    end
			htar = myHero
			if htar.team == myHero.team and not htar.dead and htar.health > 0 then
				local hb = htar.boundingRadius
				hitchampion = false
				if shottype == 0 then 
					hitchampion = spell.target and spell.target.networkID == htar.networkID
				elseif shottype == 1 then 
					hitchampion = checkhitlinepass(unit, spell.endPos, radius, maxdistance, htar, hb)
				elseif shottype == 2 then 
					hitchampion = checkhitlinepoint(unit, spell.endPos, radius, maxdistance, htar, hb)
				elseif shottype == 3 then 
					hitchampion = checkhitaoe(unit, spell.endPos, radius, maxdistance, htar, hb)
				elseif shottype == 4 then 
					hitchampion = checkhitcone(unit, spell.endPos, radius, maxdistance, htar, hb)
				elseif shottype == 5 then 
					hitchampion = checkhitwall(unit, spell.endPos, radius, maxdistance, htar, hb)
				elseif shottype == 6 then 
					hitchampion = checkhitlinepass(unit, spell.endPos, radius, maxdistance, htar, hb) or checkhitlinepass(unit, Vector(unit)*2-spell.endPos, radius, maxdistance, tar, hb)
				elseif shottype == 7 then 
					hitchampion = checkhitcone(spell.endPos, unit, radius, maxdistance, htar, hb)
				end
				if hitchampion and R.Ready() and MenuOlaf.exConfig.ES[spell.name] then
					CastSpell(_R)
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

function OnCreateObj(object)
    if myHero.dead then return end
	if object ~= nil and object.name ~= nil and object.name == "olaf_axe_totem_team_id_green.troy" and object.x ~= nil and object.z ~= nil then
		axe = object
	end
end

function OnDeleteObj(object)
    if object ~= nil and object.name ~= nil and object.name == "olaf_axe_totem_team_id_green.troy" and object.x ~= nil and object.z ~= nil then
		axe = nil
        pickaxe = false
    end
end

function OnWndMsg(Msg, Key)
	if Msg == WM_LBUTTONDOWN and MenuOlaf.comboConfig.ST then
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
				if MenuOlaf.comboConfig.ST then 
					print("Target unselected: "..Selecttarget.charName) 
				end
			else
				SelectedTarget = Selecttarget
				if MenuOlaf.comboConfig.ST then 
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
assert(load(Base64Decode("G0x1YVIAAQQEBAgAGZMNChoKAAAAAAAAAAAAAQIKAAAABgBAAEFAAAAdQAABBkBAAGUAAAAKQACBBkBAAGVAAAAKQICBHwCAAAQAAAAEBgAAAGNsYXNzAAQNAAAAU2NyaXB0U3RhdHVzAAQHAAAAX19pbml0AAQLAAAAU2VuZFVwZGF0ZQACAAAAAgAAAAgAAAACAAotAAAAhkBAAMaAQAAGwUAABwFBAkFBAQAdgQABRsFAAEcBwQKBgQEAXYEAAYbBQACHAUEDwcEBAJ2BAAHGwUAAxwHBAwECAgDdgQABBsJAAAcCQQRBQgIAHYIAARYBAgLdAAABnYAAAAqAAIAKQACFhgBDAMHAAgCdgAABCoCAhQqAw4aGAEQAx8BCAMfAwwHdAIAAnYAAAAqAgIeMQEQAAYEEAJ1AgAGGwEQA5QAAAJ1AAAEfAIAAFAAAAAQFAAAAaHdpZAAEDQAAAEJhc2U2NEVuY29kZQAECQAAAHRvc3RyaW5nAAQDAAAAb3MABAcAAABnZXRlbnYABBUAAABQUk9DRVNTT1JfSURFTlRJRklFUgAECQAAAFVTRVJOQU1FAAQNAAAAQ09NUFVURVJOQU1FAAQQAAAAUFJPQ0VTU09SX0xFVkVMAAQTAAAAUFJPQ0VTU09SX1JFVklTSU9OAAQEAAAAS2V5AAQHAAAAc29ja2V0AAQIAAAAcmVxdWlyZQAECgAAAGdhbWVTdGF0ZQAABAQAAAB0Y3AABAcAAABhc3NlcnQABAsAAABTZW5kVXBkYXRlAAMAAAAAAADwPwQUAAAAQWRkQnVnc3BsYXRDYWxsYmFjawABAAAACAAAAAgAAAAAAAMFAAAABQAAAAwAQACBQAAAHUCAAR8AgAACAAAABAsAAABTZW5kVXBkYXRlAAMAAAAAAAAAQAAAAAABAAAAAQAQAAAAQG9iZnVzY2F0ZWQubHVhAAUAAAAIAAAACAAAAAgAAAAIAAAACAAAAAAAAAABAAAABQAAAHNlbGYAAQAAAAAAEAAAAEBvYmZ1c2NhdGVkLmx1YQAtAAAAAwAAAAMAAAAEAAAABAAAAAQAAAAEAAAABAAAAAQAAAAEAAAABAAAAAUAAAAFAAAABQAAAAUAAAAFAAAABQAAAAUAAAAFAAAABgAAAAYAAAAGAAAABgAAAAUAAAADAAAAAwAAAAYAAAAGAAAABgAAAAYAAAAGAAAABgAAAAYAAAAHAAAABwAAAAcAAAAHAAAABwAAAAcAAAAHAAAABwAAAAcAAAAIAAAACAAAAAgAAAAIAAAAAgAAAAUAAABzZWxmAAAAAAAtAAAAAgAAAGEAAAAAAC0AAAABAAAABQAAAF9FTlYACQAAAA4AAAACAA0XAAAAhwBAAIxAQAEBgQAAQcEAAJ1AAAKHAEAAjABBAQFBAQBHgUEAgcEBAMcBQgABwgEAQAKAAIHCAQDGQkIAx4LCBQHDAgAWAQMCnUCAAYcAQACMAEMBnUAAAR8AgAANAAAABAQAAAB0Y3AABAgAAABjb25uZWN0AAQRAAAAc2NyaXB0c3RhdHVzLm5ldAADAAAAAAAAVEAEBQAAAHNlbmQABAsAAABHRVQgL3N5bmMtAAQEAAAAS2V5AAQCAAAALQAEBQAAAGh3aWQABAcAAABteUhlcm8ABAkAAABjaGFyTmFtZQAEJgAAACBIVFRQLzEuMA0KSG9zdDogc2NyaXB0c3RhdHVzLm5ldA0KDQoABAYAAABjbG9zZQAAAAAAAQAAAAAAEAAAAEBvYmZ1c2NhdGVkLmx1YQAXAAAACgAAAAoAAAAKAAAACgAAAAoAAAALAAAACwAAAAsAAAALAAAADAAAAAwAAAANAAAADQAAAA0AAAAOAAAADgAAAA4AAAAOAAAACwAAAA4AAAAOAAAADgAAAA4AAAACAAAABQAAAHNlbGYAAAAAABcAAAACAAAAYQAAAAAAFwAAAAEAAAAFAAAAX0VOVgABAAAAAQAQAAAAQG9iZnVzY2F0ZWQubHVhAAoAAAABAAAAAQAAAAEAAAACAAAACAAAAAIAAAAJAAAADgAAAAkAAAAOAAAAAAAAAAEAAAAFAAAAX0VOVgA="), nil, "bt", _ENV))() ScriptStatus("OBECCIAGEJG") 
