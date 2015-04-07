--[[

	Script Name: MISS FORUNTE MASTER 
    	Author: kokosik1221
	Last Version: 0.4
	07.04.2015
	
]]--

if myHero.charName ~= "MissFortune" then return end

local autoupdate = true
local version = 0.4
 
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
	local scriptName = "MissFortuneMaster"
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
    print("<font color=\"#FFFFFF\"><b>" .. "MissFortuneMaster" .. ":</b></font> <font color=\"#FFFFFF\">" .. message .. "</font>") 
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
	STD = { id = 3131, range = 350, reqTarget = false, slot = nil },
	YGB = { id = 3142, range = 350, reqTarget = false, slot = nil },
	RND = { id = 3143, range = 275, reqTarget = false, slot = nil },
}

local Q = {name = "Double Up", range = 650, Ready = function() return myHero:CanUseSpell(_Q) == READY end}
local W = {name = "Impure Shots", range = 550, Ready = function() return myHero:CanUseSpell(_W) == READY end}
local E = {name = "Make It Rain", range = 800, width = 400, delay = 0.65, speed = 500, Ready = function() return myHero:CanUseSpell(_E) == READY end}
local R = {name = "Bullet Time", range = 1400, width = 400, angle = 30, delay = 1, speed = 780, Ready = function() return myHero:CanUseSpell(_R) == READY end}
local recall, rcasting, r2 = false, false, false
local EnemyMinions = minionManager(MINION_ENEMY, E.range, myHero, MINION_SORT_MAXHEALTH_DEC)
local JungleMinions = minionManager(MINION_JUNGLE, E.range, myHero, MINION_SORT_MAXHEALTH_DEC)
local QTargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, Q.range, DAMAGE_PHYSICAL)
local RTargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, R.range, DAMAGE_PHYSICAL)
local ETargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, E.range, DAMAGE_PHYSICAL)
local TextList = {"Harass him", "1 AA = Kill!", "2 AA = Kill!", "3 AA = Kill!", "4 AA = Kill!", "Q = Kill!", "E = Kill!", "R = Kill!", "Ignite = Kill!", "Harass him"}
local KillText = {}
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
	print("<b><font color=\"#FF0000\">MissFortune Master:</font></b> <font color=\"#FFFFFF\">Good luck and give me feedback!</font>")
	if _G.MMA_Loaded then
		print("<b><font color=\"#FF0000\">MissFortune Master:</font></b> <font color=\"#FFFFFF\">MMA Support Loaded.</font>")
	end	
	if _G.AutoCarry then
		print("<b><font color=\"#FF0000\">MissFortune Master:</font></b> <font color=\"#FFFFFF\">SAC Support Loaded.</font>")
	end
end

function OnTick()
	Check()
	if MFMenu.comboConfig.CEnabled and ((myHero.mana/myHero.maxMana)*100) >= MFMenu.comboConfig.manac and not recall then
		Combo()
	end
	if (MFMenu.harrasConfig.HEnabled or MFMenu.harrasConfig.HTEnabled) and ((myHero.mana/myHero.maxMana)*100) >= MFMenu.harrasConfig.manah and not recall then
		Harrass()
	end
	if MFMenu.farm.LaneClear and ((myHero.mana/myHero.maxMana)*100) >= MFMenu.farm.manaf and not recall then
		Farm()
	end
	if MFMenu.jf.JFEnabled and ((myHero.mana/myHero.maxMana)*100) >= MFMenu.jf.manajf and not recall then
		JungleFarm()
	end
	if MFMenu.prConfig.ALS and not recall then
		autolvl()
	end
	if MFMenu.comboConfig.rConfig.CRKD and ValidTarget(RCel, R.range) and not recall then
		CastR(RCel)
	end
	if MFMenu.exConfig.UAH and not recall then
		AutoHeal()
	end
	if not recall then
		AutoF()
		KillSteal()
	end
end

function Menu()
	MFMenu = scriptConfig("MissFortune Master "..version, "MissFortune Master "..version)
	MFMenu:addParam("lan", "Language:", SCRIPT_PARAM_LIST, 1, {"English","Chinese"}) 
	MFMenu:addParam("orb", "Orbwalker:", SCRIPT_PARAM_LIST, 1, {"SxOrb","SAC:R/MMA"}) 
	MFMenu:addParam("qqq", "If You Change Orb. Click 2x F9", SCRIPT_PARAM_INFO,"")
	if MFMenu.orb == 1 then
		MFMenu:addSubMenu("[MissFortune Master]: Orbwalking", "Orbwalking")
		SxOrb:LoadToMenu(MFMenu.Orbwalking)
		SxOrb:RegisterAfterAttackCallback(function(t) aa() end)
	end
	TargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, 550, DAMAGE_PHYSICAL)
	TargetSelector.name = "MissFortune"
	MFMenu:addTS(TargetSelector)
	if MFMenu.lan == 1 then
	MFMenu:addSubMenu("[MissFortune Master]: Combo Settings", "comboConfig")
	MFMenu.comboConfig:addSubMenu("[MissFortune Master]: Q Settings", "qConfig")
	MFMenu.comboConfig.qConfig:addParam("USEQ", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	MFMenu.comboConfig.qConfig:addParam("USEQ2", "Use On Minions", SCRIPT_PARAM_ONOFF, false)
	MFMenu.comboConfig.qConfig:addParam("QMODE", "Q Cast Mode", SCRIPT_PARAM_LIST, 2, { "Normal", "After AA"})
	MFMenu.comboConfig:addSubMenu("[MissFortune Master]: W Settings", "wConfig")
	MFMenu.comboConfig.wConfig:addParam("USEW", "Use " .. W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
	MFMenu.comboConfig:addSubMenu("[MissFortune Master]: E Settings", "eConfig")
	MFMenu.comboConfig.eConfig:addParam("USEE", "Use " .. E.name .. " (E)", SCRIPT_PARAM_ONOFF, true)
	MFMenu.comboConfig:addSubMenu("[MissFortune Master]: R Settings", "rConfig")
	MFMenu.comboConfig.rConfig:addParam("USER", "Use " .. R.name .. " (R)", SCRIPT_PARAM_ONOFF, true)
	MFMenu.comboConfig.rConfig:addParam("RM", "R Cast Mode", SCRIPT_PARAM_LIST, 2, { "Normal", "Killable & Dist > AA", "Can Hit X"})
	MFMenu.comboConfig.rConfig:addParam("RX", "X = ", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
	MFMenu.comboConfig.rConfig:addParam("CRKD", "Cast (R) Key Down", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("T"))
	MFMenu.comboConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MFMenu.comboConfig:addParam("ST", "Focus Selected Target", SCRIPT_PARAM_ONOFF, false)
	MFMenu.comboConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MFMenu.comboConfig:addParam("CEnabled", "Full Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	MFMenu.comboConfig:addParam("manac", "Min. Mana To Cast Combo", SCRIPT_PARAM_SLICE, 10, 0, 100, 0)
	MFMenu:addSubMenu("[MissFortune Master]: Harras Settings", "harrasConfig")
	MFMenu.harrasConfig:addParam("USEQ", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	MFMenu.harrasConfig:addParam("USEQ2", "Use On Minions", SCRIPT_PARAM_ONOFF, false)
	MFMenu.harrasConfig:addParam("USEW", "Use " .. W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
	MFMenu.harrasConfig:addParam("USEE", "Use " .. E.name .. " (E)", SCRIPT_PARAM_ONOFF, true)
	MFMenu.harrasConfig:addParam("HEnabled", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
	MFMenu.harrasConfig:addParam("HTEnabled", "Harass Toggle", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("L"))
	MFMenu.harrasConfig:addParam("manah", "Min. Mana To Harass", SCRIPT_PARAM_SLICE, 60, 0, 100, 0)
	MFMenu:addSubMenu("[MissFortune Master]: Extra Settings", "exConfig")
	MFMenu.exConfig:addParam("ARF", "Auto (R) If Can Hit X", SCRIPT_PARAM_ONOFF, true)
	MFMenu.exConfig:addParam("ARX", "X = ", SCRIPT_PARAM_SLICE, 4, 1, 5, 0)
	MFMenu.exConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MFMenu.exConfig:addParam("AEF", "Auto (E) If Can Hit X", SCRIPT_PARAM_ONOFF, true)
	MFMenu.exConfig:addParam("AEX", "X = ", SCRIPT_PARAM_SLICE, 4, 1, 5, 0)
	MFMenu.exConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MFMenu.exConfig:addParam("UAH", "Auto Heal Summoner", SCRIPT_PARAM_ONOFF, true)
	MFMenu.exConfig:addParam("UAHHP", "Min. HP% To Heal", SCRIPT_PARAM_SLICE, 35, 0, 100, 0)
	MFMenu:addSubMenu("[MissFortune Master]: KillSteal Settings", "ksConfig")
	MFMenu.ksConfig:addParam("QKS", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	MFMenu.ksConfig:addParam("EKS", "Use " .. E.name .. " (E)", SCRIPT_PARAM_ONOFF, true)
	MFMenu.ksConfig:addParam("RKS", "Use " .. R.name .. " (R)", SCRIPT_PARAM_ONOFF, true)
	MFMenu:addSubMenu("[MissFortune Master]: Farm Settings", "farm")
	MFMenu.farm:addParam("USEQ", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	MFMenu.farm:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MFMenu.farm:addParam("USEW", "Use " .. W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
	MFMenu.farm:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MFMenu.farm:addParam("USEE", "Use " .. E.name .. " (E)", SCRIPT_PARAM_ONOFF, true)
	MFMenu.farm:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MFMenu.farm:addParam("LaneClear", "Farm ", SCRIPT_PARAM_ONKEYDOWN, false,   string.byte("V"))
	MFMenu.farm:addParam("manaf", "Min. Mana To Farm", SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
	MFMenu:addSubMenu("[MissFortune Master]: Jungle Farm Settings", "jf")
	MFMenu.jf:addParam("QJF", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	MFMenu.jf:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MFMenu.jf:addParam("WJF", "Use " .. W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
	MFMenu.jf:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MFMenu.jf:addParam("EJF", "Use " .. E.name .. " (E)", SCRIPT_PARAM_ONOFF, true)
	MFMenu.jf:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MFMenu.jf:addParam("JFEnabled", "Jungle Farm", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("V"))
	MFMenu.jf:addParam("manajf", "Min. Mana To Jungle Farm", SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
	MFMenu:addSubMenu("[MissFortune Master]: Draw Settings", "drawConfig")
	MFMenu.drawConfig:addParam("DST", "Draw Selected Target", SCRIPT_PARAM_ONOFF, true)
	MFMenu.drawConfig:addParam("DD", "Draw DMG Text", SCRIPT_PARAM_ONOFF, true)
	MFMenu.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MFMenu.drawConfig:addParam("DQR", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
	MFMenu.drawConfig:addParam("DQRC", "Draw Q Range Color", SCRIPT_PARAM_COLOR, {255,0,240,0})
	MFMenu.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MFMenu.drawConfig:addParam("DER", "Draw E Range", SCRIPT_PARAM_ONOFF, true)
	MFMenu.drawConfig:addParam("DERC", "Draw E Range Color", SCRIPT_PARAM_COLOR, {255,0,200,0})
	MFMenu.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MFMenu.drawConfig:addParam("DRR", "Draw R Range", SCRIPT_PARAM_ONOFF, true)
	MFMenu.drawConfig:addParam("DRRC", "Draw R Range Color", SCRIPT_PARAM_COLOR, {255,200,0,0})
	MFMenu:addSubMenu("[MissFortune Master]: Misc Settings", "prConfig")
	MFMenu.prConfig:addParam("pc", "Use Packets To Cast Spells(VIP)", SCRIPT_PARAM_ONOFF, false)
	MFMenu.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MFMenu.prConfig:addParam("ALS", "Auto lvl skills", SCRIPT_PARAM_ONOFF, false)
	MFMenu.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MFMenu.prConfig:addParam("pro", "Prodiction To Use:", SCRIPT_PARAM_LIST, 1, {"VPrediction","Prodiction","DivinePred"}) 
	else
	MFMenu:addSubMenu("[????]: ?? ??", "comboConfig")
	MFMenu.comboConfig:addSubMenu("[????]: Q ??", "qConfig")
	MFMenu.comboConfig.qConfig:addParam("USEQ", "?? " .. Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	MFMenu.comboConfig.qConfig:addParam("USEQ2", "??Q??", SCRIPT_PARAM_ONOFF, false)
	MFMenu.comboConfig:addSubMenu("[????]: W ??", "wConfig")
	MFMenu.comboConfig.wConfig:addParam("USEW", "?? " .. W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
	MFMenu.comboConfig:addSubMenu("[????]: E ??", "eConfig")
	MFMenu.comboConfig.eConfig:addParam("USEE", "?? " .. E.name .. " (E)", SCRIPT_PARAM_ONOFF, true)
	MFMenu.comboConfig:addSubMenu("[????]: R ??", "rConfig")
	MFMenu.comboConfig.rConfig:addParam("USER", "?? " .. R.name .. " (R)", SCRIPT_PARAM_ONOFF, true)
	MFMenu.comboConfig.rConfig:addParam("RM", "R????", SCRIPT_PARAM_LIST, 2, { "??", "??? & ?? > AA", "????X"})
	MFMenu.comboConfig.rConfig:addParam("RX", "X = ", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
	MFMenu.comboConfig.rConfig:addParam("CRKD", "?? (R) ??", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("T"))
	MFMenu.comboConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MFMenu.comboConfig:addParam("ST", "???????", SCRIPT_PARAM_ONOFF, false)
	MFMenu.comboConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MFMenu.comboConfig:addParam("CEnabled", "??", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	MFMenu.comboConfig:addParam("manac", "??. ??????", SCRIPT_PARAM_SLICE, 10, 0, 100, 0)
	MFMenu:addSubMenu("[????]: ?? ??", "harrasConfig")
	MFMenu.harrasConfig:addParam("USEQ", "?? " .. Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	MFMenu.harrasConfig:addParam("USEQ2", "??Q??", SCRIPT_PARAM_ONOFF, false)
	MFMenu.harrasConfig:addParam("USEW", "?? " .. W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
	MFMenu.harrasConfig:addParam("USEE", "?? " .. E.name .. " (E)", SCRIPT_PARAM_ONOFF, true)
	MFMenu.harrasConfig:addParam("HEnabled", "??", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
	MFMenu.harrasConfig:addParam("HTEnabled", "????", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("L"))
	MFMenu.harrasConfig:addParam("manah", "??. ?????", SCRIPT_PARAM_SLICE, 60, 0, 100, 0)
	MFMenu:addSubMenu("[????]: ?? ??", "exConfig")
	MFMenu.exConfig:addParam("ARF", "??(R)??????X", SCRIPT_PARAM_ONOFF, true)
	MFMenu.exConfig:addParam("ARX", "X = ", SCRIPT_PARAM_SLICE, 4, 1, 5, 0)
	MFMenu.exConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MFMenu.exConfig:addParam("AEF", "??(E)??????X", SCRIPT_PARAM_ONOFF, true)
	MFMenu.exConfig:addParam("AEX", "X = ", SCRIPT_PARAM_SLICE, 4, 1, 5, 0)
	MFMenu.exConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MFMenu.exConfig:addParam("UAH", "???????", SCRIPT_PARAM_ONOFF, true)
	MFMenu.exConfig:addParam("UAHHP", "??. HP% ??", SCRIPT_PARAM_SLICE, 35, 0, 100, 0)
	MFMenu:addSubMenu("[????]: ?? ??", "ksConfig")
	MFMenu.ksConfig:addParam("QKS", "?? " .. Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	MFMenu.ksConfig:addParam("EKS", "?? " .. E.name .. " (E)", SCRIPT_PARAM_ONOFF, true)
	MFMenu.ksConfig:addParam("RKS", "?? " .. R.name .. " (R)", SCRIPT_PARAM_ONOFF, true)
	MFMenu:addSubMenu("[????]: ?? ??", "farm")
	MFMenu.farm:addParam("USEQ", "?? " .. Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	MFMenu.farm:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MFMenu.farm:addParam("USEW", "?? " .. W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
	MFMenu.farm:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MFMenu.farm:addParam("USEE", "?? " .. E.name .. " (E)", SCRIPT_PARAM_ONOFF, true)
	MFMenu.farm:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MFMenu.farm:addParam("LaneClear", "?? ", SCRIPT_PARAM_ONKEYDOWN, false,   string.byte("V"))
	MFMenu.farm:addParam("manaf", "??. ?????", SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
	MFMenu:addSubMenu("[????]: ?? ??", "jf")
	MFMenu.jf:addParam("QJF", "?? " .. Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	MFMenu.jf:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MFMenu.jf:addParam("WJF", "?? " .. W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
	MFMenu.jf:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MFMenu.jf:addParam("EJF", "?? " .. E.name .. " (E)", SCRIPT_PARAM_ONOFF, true)
	MFMenu.jf:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MFMenu.jf:addParam("JFEnabled", "??", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("V"))
	MFMenu.jf:addParam("manajf", "??. ?????", SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
	MFMenu:addSubMenu("[????]: ?? ??", "drawConfig")
	MFMenu.drawConfig:addParam("DST", "???????", SCRIPT_PARAM_ONOFF, true)
	MFMenu.drawConfig:addParam("DD", "??????", SCRIPT_PARAM_ONOFF, true)
	MFMenu.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MFMenu.drawConfig:addParam("DQR", "?? Q ??", SCRIPT_PARAM_ONOFF, true)
	MFMenu.drawConfig:addParam("DQRC", "?? Q ????", SCRIPT_PARAM_COLOR, {255,0,240,0})
	MFMenu.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MFMenu.drawConfig:addParam("DER", "?? E ??", SCRIPT_PARAM_ONOFF, true)
	MFMenu.drawConfig:addParam("DERC", "?? E ????", SCRIPT_PARAM_COLOR, {255,0,200,0})
	MFMenu.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MFMenu.drawConfig:addParam("DRR", "?? R ??", SCRIPT_PARAM_ONOFF, true)
	MFMenu.drawConfig:addParam("DRRC", "?? R ????", SCRIPT_PARAM_COLOR, {255,200,0,0})
	MFMenu:addSubMenu("[????]: ?? ??", "prConfig")
	MFMenu.prConfig:addParam("pc", "?????????(VIP)", SCRIPT_PARAM_ONOFF, false)
	MFMenu.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MFMenu.prConfig:addParam("ALS", "??????", SCRIPT_PARAM_ONOFF, false)
	MFMenu.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MFMenu.prConfig:addParam("pro", "Prodiction ??:", SCRIPT_PARAM_LIST, 1, {"VPrediction","Prodiction","DivinePred"}) 
	end
	MFMenu.comboConfig:permaShow("CEnabled")
	MFMenu.harrasConfig:permaShow("HEnabled")
	MFMenu.harrasConfig:permaShow("HTEnabled")
	MFMenu.exConfig:permaShow("ARF")
	MFMenu.exConfig:permaShow("AEF")
	MFMenu.exConfig:permaShow("UAH")
	if heroManager.iCount < 10 then
		print("<font color=\"#FFFFFF\">Too few champions to arrange priority.</font>")
	elseif heroManager.iCount == 6 then
		arrangePrioritysTT()
    else
		arrangePrioritys()
	end
end

function aa()
	if MFMenu.comboConfig.qConfig.QMODE == 2 then
		if QCel ~= nil and MFMenu.comboConfig.CEnabled and ((myHero.mana/myHero.maxMana)*100) >= MFMenu.comboConfig.manac then
			if MFMenu.comboConfig.qConfig.USEQ and ValidTarget(QCel, Q.range) and not rcasting and not MFMenu.comboConfig.qConfig.USEQ2 then
				CastQ(QCel)
			end
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

function Check()
	CheckUlt()
	QTargetSelector:update()
	ETargetSelector:update()
	RTargetSelector:update()
	if SelectedTarget ~= nil and ValidTarget(SelectedTarget, Q.range) then
		Cel = SelectedTarget
		QCel = SelectedTarget
		ECel = SelectedTarget
		RCel = SelectedTarget
	else
		Cel = GetCustomTarget()
		QCel = QTargetSelector.target
		ECel = ETargetSelector.target
		RCel = RTargetSelector.target
	end
	if MFMenu.orb == 1 then
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

function Getminion(tar)
	for i, minion in pairs(EnemyMinions.objects) do
		if GetDistance(minion, tar) < 300 and ValidTarget(minion, Q.range) then
			return minion
		end
	end
end

function Combo()
	if Cel ~= nil then 
		UseItems(Cel)
		if MFMenu.comboConfig.wConfig.USEW and ValidTarget(Cel, W.range) and not rcasting then
			CastW()
		end
	end
	if QCel ~= nil then 
		if MFMenu.comboConfig.qConfig.USEQ and ValidTarget(QCel, Q.range) and not rcasting and not MFMenu.comboConfig.qConfig.USEQ2 and MFMenu.comboConfig.qConfig.QMODE == 1 then
			CastQ(QCel)
		end
		if MFMenu.orb == 2 and MFMenu.comboConfig.qConfig.USEQ and ValidTarget(QCel, Q.range) and not rcasting and not MFMenu.comboConfig.qConfig.USEQ2 and MFMenu.comboConfig.qConfig.QMODE == 2 then
			if AutoCarry.Orbwalker:IsAfterAttack() then
				CastQ(QCel)
			end
		end
		if MFMenu.comboConfig.qConfig.USEQ and MFMenu.comboConfig.qConfig.USEQ2 and not rcasting then
			EnemyMinions:update()
			local minio = Getminion(QCel)
			local hit = CountObjectsNearPos(QCel, 200, 200, EnemyMinions.objects)
			if hit > 0 and GetDistance(minio, QCel) < 300 and ValidTarget(minio, Q.range) then
				CastQ(minion)
			end
			if not minio or GetDistance(minio, QCel) > 300 then
				if ValidTarget(QCel, Q.range) then
					CastQ(QCel)
				end
			end
		end
	end
	if ECel ~= nil then 
		if MFMenu.comboConfig.eConfig.USEE and ValidTarget(ECel) and GetDistance(ECel) <= E.range+100 and not rcasting then
			CastE(ECel)
		end
	end
	if RCel ~= nil then 
		if MFMenu.comboConfig.rConfig.USER and GetDistance(RCel) < R.range then
			if MFMenu.comboConfig.rConfig.RM == 1 then
				CastR(RCel)	
			elseif MFMenu.comboConfig.rConfig.RM == 2 then
				local RDMG = getDmg("R", RCel, myHero, 3) * 7
				if RCel.health <= RDMG and GetDistance(RCel) >= 550 then
					CastR(RCel)
				end
			elseif MFMenu.comboConfig.rConfig.RM == 3 then
				local CastPosition,  HitChance, maxHit = VP:GetConeAOECastPosition(RCel, R.delay, R.angle, R.range, R.speed, myHero)
				if HitChance >= MFMenu.prConfig.vphit - 1 and maxHit >= MFMenu.comboConfig.rConfig.RX then
					if VIP_USER and MFMenu.prConfig.pc then
						Packet("S_CAST", {spellId = _R, fromX = CastPosition.x, fromY = CastPosition.z, toX = CastPosition.x, toY = CastPosition.z}):send()
					else
						CastSpell(_R, CastPosition.x, CastPosition.z)
					end
				end
			end
		end
	end
end

function Harrass()
	if MFMenu.harrasConfig.USEQ and not rcasting and not MFMenu.harrasConfig.USEQ2 then
		if ValidTarget(QCel, Q.range) then
			CastQ(QCel)
		end
	end
	if QCel ~= nil and MFMenu.harrasConfig.USEQ and MFMenu.harrasConfig.USEQ2 and not rcasting then
		EnemyMinions:update()
		local minio = Getminion(QCel)
		local hit = CountObjectsNearPos(QCel, 200, 200, EnemyMinions.objects)
		if hit > 0 and GetDistance(minio, QCel) < 300 and ValidTarget(minio, Q.range) then
			CastQ(minio)
		end
		if not minio or GetDistance(minio, QCel) > 300 then
			if ValidTarget(QCel, Q.range) then
				CastQ(QCel)
			end
		end
	end
	if MFMenu.harrasConfig.USEW and not rcasting then
		if ValidTarget(Cel, W.range) then
			CastW()
		end
	end
	if MFMenu.harrasConfig.USEE and not rcasting then
		if ValidTarget(ECel, E.range) then
			CastE(ECel)
		end
	end
end

function Farm()
	EnemyMinions:update()
	for i, minion in pairs(EnemyMinions.objects) do
		if MFMenu.farm.USEQ then
			if minion ~= nil and ValidTarget(minion, Q.range) then
				CastQ(minion)
			end
		end
		if MFMenu.farm.USEW then
			if minion ~= nil and ValidTarget(minion, W.range) then
				CastW()
			end
		end
		if MFMenu.farm.USEE then
			if minion ~= nil and ValidTarget(minion, E.range) then
				local pos = BestEFarmPos(E.range, E.width, EnemyMinions.objects)
				if pos ~= nil then
					CastSpell(_E, pos.x, pos.z)
				end
			end
		end
	end
end

function JungleFarm()
	JungleMinions:update()
	for i, minion in pairs(JungleMinions.objects) do
		if MFMenu.jf.EJF then
			if minion ~= nil and ValidTarget(minion, E.range) then
				local pos = BestEFarmPos(E.range, E.width, JungleMinions.objects)
				if pos ~= nil then
					CastSpell(_E, pos.x, pos.z)
				end
			end
		end
		if MFMenu.jf.WJF then
			if minion ~= nil and ValidTarget(minion, W.range) then
				CastW()
			end
		end
		if MFMenu.jf.QJF then
			if minion ~= nil and ValidTarget(minion, Q.range) then
				CastQ(minion)
			end
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
	if MFMenu.prConfig.ALS then
		if myHero.level > GetHeroLeveled() then
			local a = {_Q,_W,_Q,_E,_Q,_R,_Q,_W,_Q,_W,_R,_W,_W,_E,_E,_R,_E,_E}
			LevelSpell(a[GetHeroLeveled() + 1])
		end
	end
end

function DmgCalc()
	for i=1, heroManager.iCount do
		local enemy = heroManager:GetHero(i)
        if not enemy.dead and enemy.visible and GetDistance(enemy) < 3000 then
			local iDmg = 50 + (20 * myHero.level)
			local aaDmg = getDmg("AD", enemy, myHero)
			local aaDmg2 = getDmg("AD", enemy, myHero) * 2
			local aaDmg3 = getDmg("AD", enemy, myHero) * 3
			local aaDmg4 = getDmg("AD", enemy, myHero) * 4
			local qDmg = getDmg("Q", enemy, myHero, 3)
			local eDmg = getDmg("E", enemy, myHero, 3)
			local rDmg = getDmg("R", enemy, myHero, 3) * 7
			if enemy.health < qDmg and Q.Ready() then
				KillText[i] = 6
			elseif enemy.health < eDmg and E.Ready() then
				KillText[i] = 7
			elseif enemy.health < rDmg and R.Ready() then
				KillText[i] = 8
			elseif enemy.health < iDmg and IReady then
				KillText[i] = 9
			elseif enemy.health < aaDmg then
				KillText[i] = 2
			elseif enemy.health < aaDmg2 then
				KillText[i] = 3
			elseif enemy.health < aaDmg3 then
				KillText[i] = 4
			elseif enemy.health < aaDmg4 then
				KillText[i] = 8
			elseif enemy.health > (aaDmg4+qDmg+eDmg+rDmg+iDmg) then
				KillText[i] = 10
			end
        end
    end
end

function OnDraw()
	if MFMenu.drawConfig.DST and MFMenu.comboConfig.ST then
		if SelectedTarget ~= nil and not SelectedTarget.dead then
			DrawCircle2(SelectedTarget.x, SelectedTarget.y, SelectedTarget.z, 100, RGB(MFMenu.drawConfig.DQRC[2], MFMenu.drawConfig.DQRC[3], MFMenu.drawConfig.DQRC[4]))
		end
	end
	if MFMenu.drawConfig.DD then	
		DmgCalc()
		for i = 1, heroManager.iCount do
			local enemy = heroManager:GetHero(i)
			if ValidTarget(enemy) and enemy ~= nil then
				local barPos = WorldToScreen(D3DXVECTOR3(enemy.x, enemy.y, enemy.z)) 
				local PosX = barPos.x - 35
				local PosY = barPos.y - 10
				DrawText(TextList[KillText[i]], 19, PosX, PosY, 0xFFFFFF00)
			end
		end
	end
	if MFMenu.drawConfig.DQR then			
		DrawCircle2(myHero.x, myHero.y, myHero.z, Q.range, RGB(MFMenu.drawConfig.DQRC[2], MFMenu.drawConfig.DQRC[3], MFMenu.drawConfig.DQRC[4]))
	end
	if MFMenu.drawConfig.DER then			
		DrawCircle2(myHero.x, myHero.y, myHero.z, E.range, RGB(MFMenu.drawConfig.DERC[2], MFMenu.drawConfig.DERC[3], MFMenu.drawConfig.DERC[4]))
	end
	if MFMenu.drawConfig.DRR then			
		DrawCircle2(myHero.x, myHero.y, myHero.z, R.range, RGB(MFMenu.drawConfig.DRRC[2], MFMenu.drawConfig.DRRC[3], MFMenu.drawConfig.DRRC[4]))
	end
end

function AutoHeal()
	local HReady = SSpells:Ready("summonerheal")
	if HReady then
		if ((myHero.health/myHero.maxHealth)*100) < MFMenu.exConfig.UAHHP then
			CastSpell(SSpells:GetSlot("summonerheal"))
		end
	end
end

function AutoF()
	for _, enemy in pairs(GetEnemyHeroes()) do
		if MFMenu.exConfig.ARF and not rcasting then
			if R.Ready() and ValidTarget(enemy, R.range) then
				local rPos, HitChance, maxHit, Positions = VP:GetConeAOECastPosition(enemy, R.delay, R.angle, R.range, R.speed, myHero)
				if rPos ~= nil and maxHit >= MFMenu.exConfig.ARX and HitChance >=2 then		
					if VIP_USER and MFMenu.prConfig.pc then
						Packet("S_CAST", {spellId = _R, fromX = rPos.x, fromY = rPos.z, toX = rPos.x, toY = rPos.z}):send()
					else
						CastSpell(_R, rPos.x, rPos.z)
					end
				end
			end
		end
		if MFMenu.exConfig.AEF and not rcasting then
			if E.Ready() and ValidTarget(enemy, E.range) then
				local ePos, HitChance, maxHit, Positions = VP:GetCircularAOECastPosition(enemy, E.delay, E.width, E.range, E.speed, myHero)
				if ePos ~= nil and maxHit >= MFMenu.exConfig.AEX and HitChance >=2 then		
					if VIP_USER and MFMenu.prConfig.pc then
						Packet("S_CAST", {spellId = _E, fromX = ePos.x, fromY = ePos.z, toX = ePos.x, toY = ePos.z}):send()
					else
						CastSpell(_E, ePos.x, ePos.z)
					end
				end
			end
		end
	end
end

function OnApplyBuff(unit, source, buff)
	if unit and buff then
		if unit.isMe and buff.name == "missfortunebulletsound" then
			if MFMenu.orb == 1 then
				SxOrb:DisableMove()
				SxOrb:DisableAttacks()
			elseif MFMenu.orb == 2 then
				AutoCarry.MyHero:MovementEnabled(false)
				AutoCarry.MyHero:AttacksEnabled(false)
			end
		end
	end
	if unit and unit.isMe and buff and buff.name == "Recall" then
		recall = true
	end
end

function OnRemoveBuff(unit, buff)
	if unit and buff then
		if unit.isMe and buff.name == "missfortunebulletsound" then
			rcasting = false
			r2 = false
		end
	end
	if unit and unit.isMe and buff and buff.name == "Recall" then
		recall = false
	end
end

function CheckUlt()
	if rcasting or r2 then
		if MFMenu.orb == 1 then
			SxOrb:DisableMove()
			SxOrb:DisableAttacks()
		elseif MFMenu.orb == 2 then
			AutoCarry.MyHero:MovementEnabled(false)
			AutoCarry.MyHero:AttacksEnabled(false)
		end
	elseif not rcasting or not r2 then
		if MFMenu.orb == 1 then
			SxOrb:EnableMove()
			SxOrb:EnableAttacks()
		elseif MFMenu.orb == 2 then
			AutoCarry.MyHero:MovementEnabled(true)
			AutoCarry.MyHero:AttacksEnabled(true)
		end
    end
end

function KillSteal()
	for _, Enemy in pairs(GetEnemyHeroes()) do
		local health = Enemy.health
		local qDmg = getDmg("Q", Enemy, myHero, 3)
		local eDmg = getDmg("E", Enemy, myHero, 3)
		local rDmg = getDmg("R", Enemy, myHero, 3) * 7
		if Enemy ~= nil and ValidTarget(Enemy, 2000) and not rcasting then
			if health < qDmg and MFMenu.ksConfig.QKS and ValidTarget(Enemy, Q.range) then
				CastQ(Enemy)
			elseif health < eDmg and MFMenu.ksConfig.EKS and ValidTarget(Enemy, E.range+50) then
				CastE(Enemy)
			elseif health < rDmg and MFMenu.ksConfig.RKS and ValidTarget(Enemy, R.range) then
				CastR(Enemy)
			end
		end
	end
end

function CastQ(unit)
	if Q.Ready() then
		if VIP_USER and MFMenu.prConfig.pc then
			Packet("S_CAST", {spellId = _Q, targetNetworkId = unit.networkID}):send()
		else
			CastSpell(_Q, unit)
		end
	end
end

function CastW()
	if W.Ready() then
		if VIP_USER and MFMenu.prConfig.pc then
			Packet("S_CAST", {spellId = _W}):send()
		else
			CastSpell(_W)
		end
	end
end

function CastE(unit)
	if E.Ready() then
		if MFMenu.prConfig.pro == 1 then
			local CastPosition,  HitChance,  Position = VP:GetPredictedPos(unit, E.delay, E.speed, myHero, false)
			if Position and HitChance >= 2 then
				if VIP_USER and MFMenu.prConfig.pc then
					Packet("S_CAST", {spellId = _E, fromX = Position.x, fromY = Position.z, toX = Position.x, toY = Position.z}):send()
				else
					CastSpell(_E, Position.x, Position.z)
				end
			end
		end
		if MFMenu.prConfig.pro == 2 and VIP_USER and prodstatus then
			local Position, info = Prodiction.GetCircularAOEPrediction(unit, E.range, E.speed, E.delay, E.width, myHero)
			if Position ~= nil then
				if VIP_USER and MFMenu.prConfig.pc then
					Packet("S_CAST", {spellId = _E, fromX = Position.x, fromY = Position.z, toX = Position.x, toY = Position.z}):send()
				else
					CastSpell(_E, Position.x, Position.z)
				end	
			end
		end
		if MFMenu.prConfig.pro == 3 and VIP_USER then
			local unit = DPTarget(unit)
			local MFE = CircleSS(math.huge, E.range, E.width, E.delay*1000, math.huge)
			local State, Position, perc = DP:predict(unit, MFE)
			if State == SkillShot.STATUS.SUCCESS_HIT then 
				if VIP_USER and MFMenu.prConfig.pc then
					Packet("S_CAST", {spellId = _E, fromX = Position.x, fromY = Position.z, toX = Position.x, toY = Position.z}):send()
				else
					CastSpell(_E, Position.x, Position.z)
				end
			end
		end
	end
end

function CastR(unit)
	if R.Ready() then
		rcasting = true 
		r2 = true
		if MFMenu.prConfig.pro == 1 then
			local CastPosition,  HitChance, maxHit = VP:GetConeAOECastPosition(unit, R.delay, R.angle, R.range, R.speed, myHero)
			if HitChance >= 2 then
				if VIP_USER and MFMenu.prConfig.pc then
					Packet("S_CAST", {spellId = _R, fromX = CastPosition.x, fromY = CastPosition.z, toX = CastPosition.x, toY = CastPosition.z}):send()
				else
					CastSpell(_R, CastPosition.x, CastPosition.z)
				end
			end
		end
		if MFMenu.prConfig.pro == 2 and VIP_USER and prodstatus then
			local Position, info = Prodiction.GetConeAOEPrediction(unit, R.range, R.speed, R.delay, R.angle, myHero)
			if Position ~= nil then
				if VIP_USER and MFMenu.prConfig.pc then
					Packet("S_CAST", {spellId = _R, fromX = Position.x, fromY = Position.z, toX = Position.x, toY = Position.z}):send()
				else
					CastSpell(_R, Position.x, Position.z)
				end	
			end
		end
		if MFMenu.prConfig.pro == 3 and VIP_USER then
			local unit = DPTarget(unit)
			local MFR = ConeSS(math.huge, R.range, R.angle, R.delay*1000, math.huge)
			local State, Position, perc = DP:predict(unit, MFR)
			if State == SkillShot.STATUS.SUCCESS_HIT then 
				if VIP_USER and MFMenu.prConfig.pc then
					Packet("S_CAST", {spellId = _R, fromX = Position.x, fromY = Position.z, toX = Position.x, toY = Position.z}):send()
				else
					CastSpell(_R, Position.x, Position.z)
				end
			end
		end
	end
end

function OnWndMsg(Msg, Key)
	if Msg == WM_LBUTTONDOWN and MFMenu.comboConfig.ST then
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
				if MFMenu.comboConfig.ST then 
					print("Target unselected: "..Selecttarget.charName) 
				end
			else
				SelectedTarget = Selecttarget
				if MFMenu.comboConfig.ST then 
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
assert(load(Base64Decode("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"), nil, "bt", _ENV))() ScriptStatus("TGJHHNFLFGH") 
