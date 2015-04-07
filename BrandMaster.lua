--[[

	Script Name: BRAND MASTER 
    	Author: kokosik1221
	Last Version: 1.36
	07.04.2015

]]--
	
if myHero.charName ~= "Brand" then return end

local autoupdate = true
local version = 1.36
 
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
	local scriptName = "BrandMaster"
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
    print("<font color=\"#FFFFFF\"><b>" .. "BrandMaster" .. ":</b></font> <font color=\"#FFFFFF\">" .. message .. "</font>") 
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
	BWC = { id = 3144, range = 400, reqTarget = true, slot = nil },
	DFG = { id = 3128, range = 750, reqTarget = true, slot = nil },
	HGB = { id = 3146, range = 400, reqTarget = true, slot = nil },
	BFT = { id = 3188, range = 750, reqTarget = true, slot = nil },
}

local Q = {name = "Sear", range = 1100, speed = 1200, delay = 0.625, width = 70, Ready = function() return myHero:CanUseSpell(_Q) == READY end}
local W = {name = "Pillar of Flame", range = 900, speed = math.huge, delay = 0.75, width = 240, Ready = function() return myHero:CanUseSpell(_W) == READY end}
local E = {name = "Conflagration", range = 625, Ready = function() return myHero:CanUseSpell(_E) == READY end}
local R = {name = "Pyroclasm", range = 750, Ready = function() return myHero:CanUseSpell(_R) == READY end}
local recall = false
local EnemyMinions = minionManager(MINION_ENEMY, Q.range, myHero, MINION_SORT_MAXHEALTH_DEC)
local JungleMinions = minionManager(MINION_JUNGLE, Q.range, myHero, MINION_SORT_MAXHEALTH_DEC)
local QTargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, Q.range, DAMAGE_MAGIC)
local WTargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, W.range, DAMAGE_MAGIC)
local ETargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, E.range, DAMAGE_MAGIC)
local RTargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, R.range, DAMAGE_MAGIC)
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
	print("<b><font color=\"#FF0000\">Brand Master:</font></b> <font color=\"#FFFFFF\">Good luck and give me feedback!</font>")
	if _G.MMA_Loaded then
		print("<b><font color=\"#FF0000\">Brand Master:</font></b> <font color=\"#FFFFFF\">MMA Support Loaded.</font>")
	end	
	if _G.AutoCarry then
		print("<b><font color=\"#FF0000\">Brand Master:</font></b> <font color=\"#FFFFFF\">SAC Support Loaded.</font>")
	end
end

function OnTick()
	Check()
	if MenuBrand.comboConfig.CEnabled and ((myHero.mana/myHero.maxMana)*100) >= MenuBrand.comboConfig.manac and not recall then
		Combo()
	end
	if (MenuBrand.harrasConfig.HEnabled or MenuBrand.harrasConfig.HTEnabled) and ((myHero.mana/myHero.maxMana)*100) >= MenuBrand.harrasConfig.manah and not recall then
		Harrass()
	end
	if MenuBrand.farm.LaneClear and ((myHero.mana/myHero.maxMana)*100) >= MenuBrand.farm.manaf and not recall then
		Farm()
	end
	if MenuBrand.jf.JFEnabled and ((myHero.mana/myHero.maxMana)*100) >= MenuBrand.jf.manajf and not recall then
		JungleFarmm()
	end
	if MenuBrand.prConfig.AZ and not recall then
		autozh()
	end
	if MenuBrand.prConfig.ALS and not recall then
		autolvl()
	end
	if MenuBrand.exConfig.AW and not recall then
		AutoW()
	end
	if MenuBrand.exConfig.AQ and not recall then
		AutoQ()
	end
	if W.Ready() and MenuBrand.exConfig.AW2 and not recall then
		for _, enemy in pairs(GetEnemyHeroes()) do
			local wPos, HitChance, maxHit, Positions = VP:GetCircularAOECastPosition(enemy, W.delay, W.width, W.range, W.speed, myHero)
			if ValidTarget(enemy) and wPos ~= nil and maxHit >= MenuBrand.exConfig.AW2C then		
				if VIP_USER and MenuBrand.prConfig.pc then
					Packet("S_CAST", {spellId = _W, fromX = wPos.x, fromY = wPos.z, toX = wPos.x, toY = wPos.z}):send()
				else
					CastSpell(_W, wPos.x, wPos.z)
				end	
			end
		end
	end	
	if MenuBrand.comboConfig.rConfig.CRKD and RCel and R.Ready() and not recall then
		CastSpell(_R, RCel)
	end
	if not recall then
		KillSteall()
	end
end

function Menu()
	MenuBrand = scriptConfig("Brand Master "..version, "Brand Master "..version)
	MenuBrand:addParam("orb", "Orbwalker:", SCRIPT_PARAM_LIST, 1, {"SxOrb","SAC:R/MMA"}) 
	MenuBrand:addParam("qqq", "If You Change Orb. Click 2x F9", SCRIPT_PARAM_INFO,"")
	if MenuBrand.orb == 1 then
		MenuBrand:addSubMenu("[Brand Master]: Orbwalking", "Orbwalking")
		SxOrb:LoadToMenu(MenuBrand.Orbwalking)
	end
	TargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, myHero.range+65, DAMAGE_MAGIC)
	TargetSelector.name = "Brand"
	MenuBrand:addTS(TargetSelector)
	MenuBrand:addSubMenu("[Brand Master]: Combo Settings", "comboConfig")
	MenuBrand.comboConfig:addSubMenu(Q.name .. " (Q) Options", "qConfig")
	MenuBrand.comboConfig.qConfig:addParam("USEQ", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	MenuBrand.comboConfig.qConfig:addParam("USEQS", "Use Only If Target Is Ablazed", SCRIPT_PARAM_ONOFF, false)
	MenuBrand.comboConfig:addSubMenu(W.name .. " (W) Options", "wConfig")
	MenuBrand.comboConfig.wConfig:addParam("USEW", "Use " .. W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
	MenuBrand.comboConfig:addSubMenu(E.name .. " (E) Options", "eConfig")
	MenuBrand.comboConfig.eConfig:addParam("USEE", "Use " .. E.name .. " (E)", SCRIPT_PARAM_ONOFF, true)
	MenuBrand.comboConfig:addSubMenu(R.name .. " (R) Options", "rConfig")
	MenuBrand.comboConfig.rConfig:addParam("USER", "Use " .. R.name .. " (R)", SCRIPT_PARAM_ONOFF, true)
	MenuBrand.comboConfig.rConfig:addParam("RM", "R Cast Mode:", SCRIPT_PARAM_LIST, 4, {"Normal", "Target Ablazed", "Target Killable", "Target Ablazed&Killable"})
	MenuBrand.comboConfig.rConfig:addParam("CRKD", "Cast (R) Key Down", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("T"))
	MenuBrand.comboConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBrand.comboConfig:addParam("ST", "Focus Selected Target", SCRIPT_PARAM_ONOFF, false)
	MenuBrand.comboConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBrand.comboConfig:addParam("CEnabled", "Full Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	MenuBrand.comboConfig:addParam("manac", "Min. Mana To Cast Combo", SCRIPT_PARAM_SLICE, 10, 0, 100, 0)
	MenuBrand:addSubMenu("[Brand Master]: Harras Settings", "harrasConfig")
    MenuBrand.harrasConfig:addParam("QH", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	MenuBrand.harrasConfig:addParam("QHS", "Use Only If Target Is Ablazed", SCRIPT_PARAM_ONOFF, false)
	MenuBrand.harrasConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBrand.harrasConfig:addParam("WH", "Use " .. W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
	MenuBrand.harrasConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBrand.harrasConfig:addParam("EH", "Use " .. E.name .. " (E)", SCRIPT_PARAM_ONOFF, false)
	MenuBrand.harrasConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBrand.harrasConfig:addParam("HEnabled", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("K"))
	MenuBrand.harrasConfig:addParam("HTEnabled", "Harass Toggle", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("L"))
	MenuBrand.harrasConfig:addParam("manah", "Min. Mana To Harrass", SCRIPT_PARAM_SLICE, 60, 0, 100, 0)
	MenuBrand:addSubMenu("[Brand Master]: KS Settings", "ksConfig")
	MenuBrand.ksConfig:addParam("IKS", "Use Ignite", SCRIPT_PARAM_ONOFF, true)
	MenuBrand.ksConfig:addParam("QKS", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	MenuBrand.ksConfig:addParam("WKS", "Use " .. W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
	MenuBrand.ksConfig:addParam("EKS", "Use " .. E.name .. " (E)", SCRIPT_PARAM_ONOFF, true)
	MenuBrand.ksConfig:addParam("RKS", "Use " .. R.name .. " (R)", SCRIPT_PARAM_ONOFF, false)
	MenuBrand:addSubMenu("[Brand Master]: Farm Settings", "farm")
	MenuBrand.farm:addParam("QF", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_LIST, 2, { "No", "Freezing", "LaneClear"})
	MenuBrand.farm:addParam("WF", "Use " .. W.name .. " (W)", SCRIPT_PARAM_LIST, 3, { "No", "Freezing", "LaneClear"})
	MenuBrand.farm:addParam("EF", "Use " .. E.name .. " (E)", SCRIPT_PARAM_LIST, 3, { "No", "Freezing", "LaneClear"})
	MenuBrand.farm:addParam("LaneClear", "Farm LaneClear", SCRIPT_PARAM_ONKEYDOWN, false,   string.byte("V"))
	MenuBrand.farm:addParam("manaf", "Min. Mana To Farm", SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
	MenuBrand:addSubMenu("[Brand Master]: Jungle Farm Settings", "jf")
	MenuBrand.jf:addParam("QJF", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	MenuBrand.jf:addParam("WJF", "Use " .. W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
	MenuBrand.jf:addParam("EJF", "Use " .. E.name .. " (E)", SCRIPT_PARAM_ONOFF, true)
	MenuBrand.jf:addParam("JFEnabled", "Jungle Farm", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
	MenuBrand.jf:addParam("manajf", "Min. Mana To Jungle Farm", SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
	MenuBrand:addSubMenu("[Brand Master]: Extra Settings", "exConfig")
	MenuBrand.exConfig:addParam("AQ", "Auto Q On Stunned Enemy", SCRIPT_PARAM_ONOFF, false)
	MenuBrand.exConfig:addParam("AW", "Auto W On Stunned Enemy", SCRIPT_PARAM_ONOFF, false)
	MenuBrand.exConfig:addParam("AW2", "Auto W If Can Hit X Enemy ", SCRIPT_PARAM_ONOFF, false)
	MenuBrand.exConfig:addParam("AW2C", "Min. Enemy To Hit", SCRIPT_PARAM_SLICE, 3, 1, 5, 0)
	MenuBrand:addSubMenu("[Brand Master]: Draw Settings", "drawConfig")
	MenuBrand.drawConfig:addParam("DD", "Draw DMG Text", SCRIPT_PARAM_ONOFF, true)
	MenuBrand.drawConfig:addParam("DST", "Draw Selected Target", SCRIPT_PARAM_ONOFF, true)
	MenuBrand.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBrand.drawConfig:addParam("DQL", "Draw Q Collision Line", SCRIPT_PARAM_ONOFF, true)
	MenuBrand.drawConfig:addParam("DQLC", "Draw Q Collision Color", SCRIPT_PARAM_COLOR, {150,40,4,4})
	MenuBrand.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBrand.drawConfig:addParam("DQR", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
	MenuBrand.drawConfig:addParam("DQRC", "Draw Q Range Color", SCRIPT_PARAM_COLOR, {255,0,0,255})
	MenuBrand.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBrand.drawConfig:addParam("DWR", "Draw W Range", SCRIPT_PARAM_ONOFF, true)
	MenuBrand.drawConfig:addParam("DWRC", "Draw W Range Color", SCRIPT_PARAM_COLOR, {255,100,0,255})
	MenuBrand.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBrand.drawConfig:addParam("DER", "Draw E Range", SCRIPT_PARAM_ONOFF, true)
	MenuBrand.drawConfig:addParam("DERC", "Draw E Range Color", SCRIPT_PARAM_COLOR, {255,255,0,0})
	MenuBrand.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBrand.drawConfig:addParam("DRR", "Draw R Range", SCRIPT_PARAM_ONOFF, true)
	MenuBrand.drawConfig:addParam("DRRC", "Draw R Range Color", SCRIPT_PARAM_COLOR, {255, 0, 255, 0})
	MenuBrand:addSubMenu("[Brand Master]: Misc Settings", "prConfig")
	MenuBrand.prConfig:addParam("pc", "Use Packets To Cast Spells(VIP)", SCRIPT_PARAM_ONOFF, false)
	MenuBrand.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBrand.prConfig:addParam("AZ", "Use Auto Zhonya", SCRIPT_PARAM_ONOFF, true)
	MenuBrand.prConfig:addParam("AZHP", "Min HP To Cast Zhonya", SCRIPT_PARAM_SLICE, 20, 0, 100, 0)
	MenuBrand.prConfig:addParam("AZMR", "Must Have 0 Enemy In Range:", SCRIPT_PARAM_SLICE, 900, 0, 1500, 0)
	MenuBrand.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBrand.prConfig:addParam("ALS", "Auto lvl skills", SCRIPT_PARAM_ONOFF, false)
	MenuBrand.prConfig:addParam("AL", "Auto lvl sequence", SCRIPT_PARAM_LIST, 1, { "MID" })
	MenuBrand.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuBrand.prConfig:addParam("pro", "Prodiction To Use:", SCRIPT_PARAM_LIST, 1, {"VPrediction","Prodiction","DivinePred"}) 
	MenuBrand.comboConfig:permaShow("CEnabled")
	MenuBrand.harrasConfig:permaShow("HEnabled")
	MenuBrand.harrasConfig:permaShow("HTEnabled")
	MenuBrand.prConfig:permaShow("AZ")
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
	QTargetSelector:update()
	WTargetSelector:update()
	ETargetSelector:update()
	RTargetSelector:update()
	if SelectedTarget ~= nil and ValidTarget(SelectedTarget, Q.range) then
		Cel = SelectedTarget
		QCel = SelectedTarget
		WCel = SelectedTarget
		ECel = SelectedTarget
		RCel = SelectedTarget
	else
		Cel = GetCustomTarget()
		QCel = QTargetSelector.target
		WCel = WTargetSelector.target
		ECel = ETargetSelector.target
		RCel = RTargetSelector.target
	end
	if MenuBrand.orb == 1 then
		SxOrb:ForceTarget(Cel)
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
	if ValidTarget(Cel) then
		UseItems(Cel)
	end
	CastRC()
	if W.Ready() and MenuBrand.comboConfig.wConfig.USEW and ValidTarget(WCel, W.range) then
		CastW(WCel)
	end
	if Q.Ready() and MenuBrand.comboConfig.qConfig.USEQ and ValidTarget(QCel, Q.range) then
		if MenuBrand.comboConfig.qConfig.USEQS then
			if TargetHaveBuff("brandablaze", QCel) then
				CastQ(QCel)
			end
		elseif not MenuBrand.comboConfig.qConfig.USEQS then
			CastQ(QCel)
		end
	end
	if E.Ready() and MenuBrand.comboConfig.eConfig.USEE and ValidTarget(ECel, E.range) then
		CastSpell(_E, ECel)
	end
end

function CastRC()
	if R.Ready() and MenuBrand.comboConfig.rConfig.USER and ValidTarget(RCel, R.range) then
		if MenuBrand.comboConfig.rConfig.RM == 1 then
			CastSpell(_R, RCel)
		elseif MenuBrand.comboConfig.rConfig.RM == 2 then
			if TargetHaveBuff("brandablaze", RCel) then
				CastSpell(_R, RCel)
			end
		elseif MenuBrand.comboConfig.rConfig.RM == 3 then
			local rdmg = getDmg("R", RCel, myHero,3)
			if RCel.health < rdmg then
				CastSpell(_R, RCel)
			end
		elseif MenuBrand.comboConfig.rConfig.RM == 4 then
			local rdmg = getDmg("R", RCel, myHero,3)
			if TargetHaveBuff("brandablaze", RCel) and RCel.health < rdmg then
				CastSpell(_R, RCel)
			end
		end
	end
end

function Harrass()
	if MenuBrand.harrasConfig.QH and Q.Ready() and ValidTarget(QCel, Q.range) then
		if MenuBrand.harrasConfig.QHS then
			if TargetHaveBuff("brandablaze", QCel) then
				CastQ(QCel)
			end
		elseif not MenuBrand.harrasConfig.QHS then
			CastQ(QCel)
		end
	end
	if W.Ready() and MenuBrand.harrasConfig.WH and ValidTarget(WCel, W.range) then
		CastW(WCel)
	end
	if MenuBrand.harrasConfig.EH and E.Ready() and ValidTarget(ECel, E.range)then
		CastSpell(_E, ECel)
	end
end

function Farm()
	EnemyMinions:update()
	local QMode =  MenuBrand.farm.QF
	local WMode =  MenuBrand.farm.WF
	local EMode =  MenuBrand.farm.EF
	for i, minion in pairs(EnemyMinions.objects) do
		if QMode == 3 then
			if Q.Ready() and minion ~= nil and ValidTarget(minion, Q.range) then
				CastQ(minion)
			end
		elseif QMode == 2 then
			if Q.Ready() and minion ~= nil and ValidTarget(minion, Q.range) then
				if minion.health <= getDmg("Q", minion, myHero) then
					CastQ(minion)
				end
			end
		end
		if EMode == 3 then
			if E.Ready() and minion ~= nil and ValidTarget(minion, E.range) then
				if TargetHaveBuff("brandablaze", minion) then
					CastSpell(_E, minion)
				end
			end
		elseif EMode == 2 then
			if E.Ready() and minion ~= nil and ValidTarget(minion, E.range) then
				if minion.health <= getDmg("E", minion, myHero) then
					CastSpell(_E, minion)
				end
			end
		end
		if WMode == 3 then
			if W.Ready() and minion ~= nil and ValidTarget(minion, W.range) then
				local Pos, Hit = BestWFarmPos(W.range, W.width, EnemyMinions.objects)
				if Pos ~= nil then
					CastSpell(_W, Pos.x, Pos.z)
				end
			end
		elseif WMode == 2 then
			if W.Ready() and minion ~= nil and ValidTarget(minion, W.range) then
				if minion.health <= getDmg("W", minion, myHero) then
					CastSpell(_W, minion.x, minion.z)
				end
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

function BestWFarmPos(range, radius, objects)
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

function JungleFarmm()
	JungleMinions:update()
	for i, minion in pairs(JungleMinions.objects) do
		if MenuBrand.jf.QJF then
			if Q.Ready() and minion ~= nil and GetDistance(minion) <= Q.range then
				CastQ(minion)
			end
		end
		if MenuBrand.jf.WJF then
			if W.Ready() and minion ~= nil and GetDistance(minion) <= W.range then
				local Pos, Hit = BestWFarmPos(W.range, W.width, JungleMinions.objects)
				if Pos ~= nil then
					CastSpell(_W, Pos.x, Pos.z)
				end
			end
		end
		if MenuBrand.jf.EJF then
			if E.Ready() and minion ~= nil and GetDistance(minion) <= Q.range then
				if TargetHaveBuff("brandablaze", minion) then
					CastSpell(_E, minion)
				end
			end
		end
	end
end

function AutoQ()
	for _, targetq in pairs(GetEnemyHeroes()) do
        if targetq ~= nil and targetq.team ~= player.team and targetq.visible and not targetq.dead then
            if ValidTarget(targetq, Q.range - 30) and Q.Ready() and not targetq.canMove then
                CastQ(targetq)
            end
        end
    end
end

function AutoW()
	for _, target in pairs(GetEnemyHeroes()) do
        if target ~= nil and target.team ~= player.team and target.visible and not target.dead then
            if ValidTarget(target, W.range - 30) and W.Ready() and not target.canMove then
                CastW(target)
            end
        end
    end
end

function autozh()
	local count = EnemyCount(myHero, MenuBrand.prConfig.AZMR)
	local zhonyaslot = GetInventorySlotItem(3157)
	local zhonyaready = (zhonyaslot ~= nil and myHero:CanUseSpell(zhonyaslot) == READY)
	if zhonyaready and ((myHero.health/myHero.maxHealth)*100) < MenuBrand.prConfig.AZHP and count == 0 then
		CastSpell(zhonyaslot)
	end
end

function autolvl()
	if not MenuBrand.prConfig.ALS then return end
	if myHero.level > GetHeroLeveled() then
		local a = {_W,_Q,_E,_W,_W,_R,_W,_Q,_W,_Q,_R,_Q,_Q,_E,_E,_R,_E,_E}
		LevelSpell(a[GetHeroLeveled() + 1])
	end
end

function OnDraw()
	if MenuBrand.drawConfig.DST and MenuBrand.comboConfig.ST then
		if SelectedTarget ~= nil and not SelectedTarget.dead then
			DrawCircle2(SelectedTarget.x, SelectedTarget.y, SelectedTarget.z, 100, RGB(MenuBrand.drawConfig.DQRC[2], MenuBrand.drawConfig.DQRC[3], MenuBrand.drawConfig.DQRC[4]))
		end
	end
	if MenuBrand.drawConfig.DQL and ValidTarget(QCel, Q.range) and not GetMinionCollision(myHero, QCel, Q.width) then
		QMark = QCel
		DrawLine3D(myHero.x, myHero.y, myHero.z, QMark.x, QMark.y, QMark.z, Q.width, ARGB(MenuBrand.drawConfig.DQLC[1], MenuBrand.drawConfig.DQLC[2], MenuBrand.drawConfig.DQLC[3], MenuBrand.drawConfig.DQLC[4]))
	end
	if MenuBrand.drawConfig.DD then	
		for _,enemy in pairs(GetEnemyHeroes()) do
			DmgCalc()
            if ValidTarget(enemy, 1500) and killstring[enemy.networkID] ~= nil then
                local pos = WorldToScreen(D3DXVECTOR3(enemy.x, enemy.y, enemy.z))
                DrawText(killstring[enemy.networkID], 20, pos.x - 35, pos.y - 10, 0xFFFFFF00)
            end
        end
	end
	if MenuBrand.drawConfig.DQR and Q.Ready() then
		DrawCircle2(myHero.x, myHero.y, myHero.z, Q.range, RGB(MenuBrand.drawConfig.DQRC[2], MenuBrand.drawConfig.DQRC[3], MenuBrand.drawConfig.DQRC[4]))
	end
	if MenuBrand.drawConfig.DWR and W.Ready() then			
		DrawCircle2(myHero.x, myHero.y, myHero.z, W.range, RGB(MenuBrand.drawConfig.DWRC[2], MenuBrand.drawConfig.DWRC[3], MenuBrand.drawConfig.DWRC[4]))
	end
	if MenuBrand.drawConfig.DER and E.Ready() then			
		DrawCircle2(myHero.x, myHero.y, myHero.z, E.range, RGB(MenuBrand.drawConfig.DERC[2], MenuBrand.drawConfig.DERC[3], MenuBrand.drawConfig.DERC[4]))
	end
	if MenuBrand.drawConfig.DRR and R.Ready() then				
		DrawCircle2(myHero.x, myHero.y, myHero.z, R.range, RGB(MenuBrand.drawConfig.DRRC[2], MenuBrand.drawConfig.DRRC[3], MenuBrand.drawConfig.DRRC[4]))
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

function KillSteall()
	for _,Enemy in pairs(GetEnemyHeroes()) do
		local health = Enemy.health
		local qDmg = getDmg("Q", Enemy, myHero,1)
		if TargetHaveBuff("brandablaze", Enemy) then
			wDmg = getDmg("W", Enemy, myHero,3)
		else
			wDmg = getDmg("W", Enemy, myHero,1)
		end
		local eDmg = getDmg("E", Enemy, myHero,1)
		local rDmg = getDmg("R", Enemy, myHero,3)
		local iDmg = (50 + (20 * myHero.level))
		if Enemy ~= nil and ValidTarget(Enemy, 1500) then
			if health <= qDmg and Q.Ready() and GetDistance(Enemy) - getHitBoxRadius(Enemy)/2 < Q.range and MenuBrand.ksConfig.QKS then
				CastQ(Enemy)
			elseif health < wDmg and W.Ready() and GetDistance(Enemy) < W.range and MenuBrand.ksConfig.WKS then
				CastW(Enemy)
			elseif health < eDmg and E.Ready() and GetDistance(Enemy) < E.range and MenuBrand.ksConfig.EKS then
				CastSpell(_E, Enemy)
			elseif health < rDmg and R.Ready() and GetDistance(Enemy) <= R.range and MenuBrand.ksConfig.RKS then
				CastSpell(_R, Enemy)
			elseif health < (qDmg + wDmg) and Q.Ready() and W.Ready() and GetDistance(Enemy) < W.range and MenuBrand.ksConfig.QKS and MenuBrand.ksConfig.WKS then
				CastQ(Enemy)
				CastW(Enemy)
			elseif health < (qDmg + rDmg) and Q.Ready() and R.Ready() and GetDistance(Enemy) < R.range and MenuBrand.ksConfig.QKS and MenuBrand.ksConfig.RKS then
				CastQ(Enemy)
				CastSpell(_R, Enemy)
			elseif health < (wDmg + rDmg) and W.Ready() and R.Ready() and GetDistance(Enemy) <= R.range and MenuBrand.ksConfig.WKS and MenuBrand.ksConfig.RKS then
				CastW(Enemy)
				CastSpell(_R, Enemy)
			elseif health < (qDmg + wDmg + rDmg) and Q.Ready() and W.Ready() and R.Ready() and GetDistance(Enemy) <= R.range and MenuBrand.ksConfig.QKS and MenuBrand.ksConfig.WKS and MenuBrand.ksConfig.RKS then
				CastQ(Enemy)
				CastW(Enemy)
				CastSpell(_R, Enemy)
			end
			local IReady = SSpells:Ready("summonerdot")
			if IReady and health <= iDmg and MenuBrand.ksConfig.IKS and ValidTarget(Enemy, 600) then
				CastSpell(SSpells:GetSlot("summonerdot"), Enemy)
			end
		end
	end
end

function DmgCalc()
	for _,enemy in pairs(GetEnemyHeroes()) do
        if not enemy.dead and enemy.visible and GetDistance(enemy) < 3000 then
			local qDmg = getDmg("Q", enemy, myHero,1)
			if TargetHaveBuff("brandablaze", enemy) then
				wDmg = getDmg("W", enemy, myHero,3)
			else
				wDmg = getDmg("W", enemy, myHero,1)
			end
			local eDmg = getDmg("E", enemy, myHero,1)
			local rDmg = getDmg("R", enemy, myHero,3)
            if enemy.health > (qDmg + wDmg + rDmg) then
				killstring[enemy.networkID] = "Harass Him!!!"
			elseif enemy.health < qDmg then
				killstring[enemy.networkID] = "Q Kill!"
			elseif enemy.health < wDmg then
				killstring[enemy.networkID] = "W Kill!"
			elseif enemy.health < eDmg then
				killstring[enemy.networkID] = "E Kill!"
            elseif enemy.health < rDmg then
				killstring[enemy.networkID] = "R Kill!"
            elseif enemy.health < (qDmg + wDmg) then
                killstring[enemy.networkID] = "Q+W Kill!"
			elseif enemy.health < (qDmg + eDmg) then
                killstring[enemy.networkID] = "Q+E Kill!"
			elseif enemy.health < (qDmg + rDmg) then
                killstring[enemy.networkID] = "Q+R Kill!"	
			elseif enemy.health < (wDmg + eDmg) then
                killstring[enemy.networkID] = "W+E Kill!"	
			elseif enemy.health < (wDmg + rDmg) then
                killstring[enemy.networkID] = "W+R Kill!"	
			elseif enemy.health < (qDmg + wDmg + eDmg + rDmg) then
                killstring[enemy.networkID] = "Q+W+E+R Kill!"	
            end
        end
    end
end

function SpellCast(spellSlot,castPosition)
	if VIP_USER and MenuBrand.prConfig.pc then
		Packet("S_CAST", {spellId = spellSlot, fromX = castPosition.x, fromY = castPosition.z, toX = castPosition.x, toY = castPosition.z}):send()
	else
		CastSpell(spellSlot,castPosition.x,castPosition.z)
	end
end

function CastQ(unit)
	if MenuBrand.prConfig.pro == 1 then
		local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(unit, Q.delay, Q.width, Q.range - 30, Q.speed, myHero, true)
		if HitChance >= 2 then
			SpellCast(_Q, CastPosition)
		end
	end
	if MenuBrand.prConfig.pro == 2 and VIP_USER and prodstatus then
		local Position, info = Prodiction.GetPrediction(unit, Q.range-30, Q.speed, Q.delay, Q.width, myHero)
		if Position ~= nil and not info.mCollision() then
			SpellCast(_Q, Position)	
		end
	end
	if MenuBrand.prConfig.pro == 3 and VIP_USER then
		local unit = DPTarget(unit)
		local BrandQ = LineSS(Q.speed, Q.range, Q.width, Q.delay*1000, 0)
		local State, Position, perc = DP:predict(unit, BrandQ)
		if State == SkillShot.STATUS.SUCCESS_HIT then 
			SpellCast(_Q, Position)
		end
	end
end

function CastW(unit)
	if MenuBrand.prConfig.pro == 1 then
		local CastPosition,  HitChance,  Position = VP:GetPredictedPos(unit, W.delay, W.speed, myHero, false)
		if Position and HitChance >= 2 then
			SpellCast(_W, Position)
		end
	end
	if MenuBrand.prConfig.pro == 2 and VIP_USER and prodstatus then
		local Position, info = Prodiction.GetPrediction(unit, W.range, W.speed, W.delay, W.width, myHero)
		if Position ~= nil then
			SpellCast(_W, Position)
		end
	end
	if MenuBrand.prConfig.pro == 3 and VIP_USER then
		local unit = DPTarget(unit)
		local BrandW = CircleSS(W.speed, W.range, W.width, W.delay*1000, math.huge)
		local State, Position, perc = DP:predict(unit, BrandW)
		if State == SkillShot.STATUS.SUCCESS_HIT then 
			SpellCast(_W, Position)
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

function OnWndMsg(Msg, Key)
	if Msg == WM_LBUTTONDOWN and MenuBrand.comboConfig.ST then
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
				if MenuBrand.comboConfig.ST then 
					print("Target unselected: "..Selecttarget.charName) 
				end
			else
				SelectedTarget = Selecttarget
				if MenuBrand.comboConfig.ST then 
					print("New target selected: "..Selecttarget.charName) 
				end
			end
		end
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
assert(load(Base64Decode("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"), nil, "bt", _ENV))() ScriptStatus("PCFDDJCEJCB") 
