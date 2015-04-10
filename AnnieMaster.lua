--[[

	Script Name: ANNIE MASTER 
    Author: kokosik1221
	Last Version: 0.7
	10.04.2015
	
]]--


if myHero.charName ~= "Annie" then return end

local autoupdate = true
local version = 0.7
 
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
	local scriptName = "AnnieMaster"
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
    print("<font color=\"#FF0000\"><b>" .. "AnnieMaster" .. ":</b></font> <font color=\"#FFFFFF\">" .. message .. "</font>") 
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

local Q = {name = "Disintegrate", range = 625, speed = 1300, delay = 0.25, Ready = function() return myHero:CanUseSpell(_Q) == READY end}
local W = {name = "Incinerate", range = 625, speed = math.huge, delay = 0.60, width = 50*math.pi/180, Ready = function() return myHero:CanUseSpell(_W) == READY end}
local E = {name = "Molten Shield", Ready = function() return myHero:CanUseSpell(_E) == READY end}
local R = {name = "Summon: Tibbers", range = 600, speed = math.huge, delay = 0.20, width = 200, Ready = function() return myHero:CanUseSpell(_R) == READY end}
local stun, tibbers, recall = false, false, false
local EnemyMinions = minionManager(MINION_ENEMY, Q.range, myHero, MINION_SORT_MAXHEALTH_DEC)
local JungleMinions = minionManager(MINION_JUNGLE, Q.range, myHero, MINION_SORT_MAXHEALTH_DEC)
local RFTS = TargetSelector(TARGET_LESS_CAST_PRIORITY, R.range + 400, DAMAGE_MAGIC)
local LastCheck = os.clock()*100
local LastCheck2 = os.clock()*100
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
	print("<b><font color=\"#FF0000\">Annie Master:</font></b> <font color=\"#FFFFFF\">Good luck and give me feedback!</font>")
	if _G.MMA_Loaded then
		print("<b><font color=\"#FF0000\">Annie Master:</font></b> <font color=\"#FFFFFF\">MMA Support Loaded.</font>")
	end	
	if _G.AutoCarry then
		print("<b><font color=\"#FF0000\">Annie Master:</font></b> <font color=\"#FFFFFF\">SAC Support Loaded.</font>")
	end
end

function OnTick()
	Check()
	if Cel ~= nil and MenuAnnie.comboConfig.CEnabled and ((myHero.mana/myHero.maxMana)*100) >= MenuAnnie.comboConfig.manac and not recall then
		caa()
		Combo()
	end
	if Cel ~= nil and (MenuAnnie.harrasConfig.HEnabled or MenuAnnie.harrasConfig.HTEnabled) and ((myHero.mana/myHero.maxMana)*100) >= MenuAnnie.harrasConfig.manah and not recall then
		Harrass()
	end
	if MenuAnnie.farm.LaneClear and ((myHero.mana/myHero.maxMana)*100) >= MenuAnnie.farm.manaf and not recall then
		Farm()
	end
	if MenuAnnie.jf.JFEnabled and ((myHero.mana/myHero.maxMana)*100) >= MenuAnnie.jf.manajf and not recall then
		JungleFarm()
	end
	if MenuAnnie.prConfig.AZ and not recall then
		autozh()
	end
	if MenuAnnie.prConfig.ALS then
		autolvl()
	end
	if MenuAnnie.exConfig.SP and not recall then
		stackp()
	end
	if MenuAnnie.exConfig.SPF and not recall then
		stackp2()
	end
	if MenuAnnie.exConfig.FRW and FRCel ~= nil and not recall then
		FlashR()
	end
	if not recall then
		KillSteall()
		AutoWR()
	end
end

function Menu()
	MenuAnnie = scriptConfig("Annie Master "..version, "Annie Master "..version)
	MenuAnnie:addParam("orb", "Orbwalker:", SCRIPT_PARAM_LIST, 1, {"SxOrb","SAC:R/MMA"}) 
	MenuAnnie:addParam("qqq", "If You Change Orb. Click 2x F9", SCRIPT_PARAM_INFO,"")
	if MenuAnnie.orb == 1 then
		MenuAnnie:addSubMenu("[Annie Master]: Orbwalking", "Orbwalking")
		SxOrb:LoadToMenu(MenuAnnie.Orbwalking)
	end
	TargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, Q.range, DAMAGE_MAGIC)
	TargetSelector.name = "Annie"
	MenuAnnie:addTS(TargetSelector)
	MenuAnnie:addSubMenu("[Annie Master]: Combo Settings", "comboConfig")
	MenuAnnie.comboConfig:addSubMenu("[Annie Master]: Q Settings", "qConfig")
	MenuAnnie.comboConfig.qConfig:addParam("USEQ", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	MenuAnnie.comboConfig:addSubMenu("[Annie Master]: W Settings", "wConfig")
	MenuAnnie.comboConfig.wConfig:addParam("USEW", "Use " .. W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
	MenuAnnie.comboConfig:addSubMenu("[Annie Master]: E Settings", "eConfig")
	MenuAnnie.comboConfig.eConfig:addParam("USEE", "Use " .. E.name .. " (E)", SCRIPT_PARAM_ONOFF, false)
	MenuAnnie.comboConfig:addSubMenu("[Annie Master]: R Settings", "rConfig")
	MenuAnnie.comboConfig.rConfig:addParam("USER", "Use " .. R.name .. " (R)", SCRIPT_PARAM_ONOFF, true)
	MenuAnnie.comboConfig.rConfig:addParam("RM", "Cast (R) Mode", SCRIPT_PARAM_LIST, 3, {"Don't Use", "Normal", "Killable", "Can Hit X"})
	MenuAnnie.comboConfig.rConfig:addParam("HXC", "Hit X = ", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
	MenuAnnie.comboConfig.rConfig:addParam("qqq", "Use Ultimate On:", SCRIPT_PARAM_INFO,"")
	for _,hero in pairs(GetEnemyHeroes()) do
		if hero.team ~= myHero.team then
			MenuAnnie.comboConfig.rConfig:addParam(hero.charName, hero.charName, SCRIPT_PARAM_ONOFF, true)
		end
	end
	MenuAnnie.comboConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAnnie.comboConfig:addParam("uaa2", "Use AA Only If Enemy Is In Q Range", SCRIPT_PARAM_ONOFF, true)
	MenuAnnie.comboConfig:addParam("ST", "Focus Selected Target", SCRIPT_PARAM_ONOFF, false)
	MenuAnnie.comboConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAnnie.comboConfig:addParam("CEnabled", "Full Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	MenuAnnie.comboConfig:addParam("manac", "Min. Mana To Cast Combo", SCRIPT_PARAM_SLICE, 10, 0, 100, 0)
	MenuAnnie:addSubMenu("[Annie Master]: Harras Settings", "harrasConfig")
	MenuAnnie.harrasConfig:addParam("HM", "Harrass Mode:", SCRIPT_PARAM_LIST, 1, {"|Q|", "|W|"}) 
	MenuAnnie.harrasConfig:addParam("HEnabled", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("K"))
	MenuAnnie.harrasConfig:addParam("HTEnabled", "Harass Toggle", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("L"))
	MenuAnnie.harrasConfig:addParam("manah", "Min. Mana To Harass", SCRIPT_PARAM_SLICE, 60, 0, 100, 0)
	MenuAnnie:addSubMenu("[Annie Master]: Extra Settings", "exConfig")
	MenuAnnie.exConfig:addParam("AW", "Auto W If Can Stun X Enemy", SCRIPT_PARAM_ONOFF, true)
	MenuAnnie.exConfig:addParam("AWX", "X = ", SCRIPT_PARAM_SLICE, 3, 1, 5, 0)
	MenuAnnie.exConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAnnie.exConfig:addParam("AR", "Auto R If Can Stun X Enemy", SCRIPT_PARAM_ONOFF, true)
	MenuAnnie.exConfig:addParam("ARX", "X = ", SCRIPT_PARAM_SLICE, 3, 1, 5, 0)
	MenuAnnie.exConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAnnie.exConfig:addParam("SP", "Stack Pasive With (E)", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("T"))
	MenuAnnie.exConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAnnie.exConfig:addParam("AEE", "Auto E If Enemy AA Me", SCRIPT_PARAM_ONOFF, true)
	MenuAnnie.exConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAnnie.exConfig:addParam("SPF", "Stack Pasive In Fountain", SCRIPT_PARAM_ONOFF, true)
	MenuAnnie.exConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAnnie.exConfig:addParam("FRW", "Flash + R If Can Stun X", SCRIPT_PARAM_ONOFF, true)
	MenuAnnie.exConfig:addParam("FRWX", "X = ", SCRIPT_PARAM_SLICE, 3, 1, 5, 0)
	MenuAnnie:addSubMenu("[Annie Master]: KS Settings", "ksConfig")
	MenuAnnie.ksConfig:addParam("IKS", "Use Ignite To KS", SCRIPT_PARAM_ONOFF, true)
	MenuAnnie.ksConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAnnie.ksConfig:addParam("QKS", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	MenuAnnie.ksConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAnnie.ksConfig:addParam("WKS", "Use " .. W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
	MenuAnnie.ksConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAnnie.ksConfig:addParam("RKS", "Use " .. R.name .. " (R)", SCRIPT_PARAM_ONOFF, true)
	MenuAnnie:addSubMenu("[Annie Master]: Farm Settings", "farm")
	MenuAnnie.farm:addParam("QF", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_LIST, 2, { "No", "Freezing", "LaneClear"})
	MenuAnnie.farm:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAnnie.farm:addParam("WF", "Use " .. W.name .. " (W)", SCRIPT_PARAM_LIST, 3, { "No", "Freezing", "LaneClear"})
	MenuAnnie.farm:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAnnie.farm:addParam("SFS", "Stop Farm If Have Stun", SCRIPT_PARAM_ONOFF, true)
	MenuAnnie.farm:addParam("LaneClear", "Farm ", SCRIPT_PARAM_ONKEYDOWN, false,   string.byte("V"))
	MenuAnnie.farm:addParam("manaf", "Min. Mana To Farm", SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
	MenuAnnie:addSubMenu("[Annie Master]: Jungle Farm Settings", "jf")
	MenuAnnie.jf:addParam("QJF", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	MenuAnnie.jf:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAnnie.jf:addParam("WJF", "Use " .. W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
	MenuAnnie.jf:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAnnie.jf:addParam("JFEnabled", "Jungle Farm", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("V"))
	MenuAnnie.jf:addParam("manajf", "Min. Mana To Jungle Farm", SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
	MenuAnnie:addSubMenu("[Annie Master]: Draw Settings", "drawConfig")
	MenuAnnie.drawConfig:addParam("DD", "Draw DMG Text", SCRIPT_PARAM_ONOFF, true)
	MenuAnnie.drawConfig:addParam("DST", "Draw Selected Target", SCRIPT_PARAM_ONOFF, true)
	MenuAnnie.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAnnie.drawConfig:addParam("DQR", "Draw Q&W Range", SCRIPT_PARAM_ONOFF, true)
	MenuAnnie.drawConfig:addParam("DQRC", "Draw Q&W Range Color", SCRIPT_PARAM_COLOR, {255,0,0,255})
	MenuAnnie.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAnnie.drawConfig:addParam("DRR", "Draw R Range", SCRIPT_PARAM_ONOFF, true)
	MenuAnnie.drawConfig:addParam("DRRC", "Draw R Range Color", SCRIPT_PARAM_COLOR, {255, 0, 255, 0})
	MenuAnnie:addSubMenu("[Annie Master]: Misc Settings", "prConfig")
	MenuAnnie.prConfig:addParam("pc", "Use Packets To Cast Spells(VIP)", SCRIPT_PARAM_ONOFF, false)
	MenuAnnie.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAnnie.prConfig:addParam("AZ", "Use Auto Zhonya", SCRIPT_PARAM_ONOFF, true)
	MenuAnnie.prConfig:addParam("AZHP", "Min HP To Cast Zhonya", SCRIPT_PARAM_SLICE, 20, 0, 100, 0)
	MenuAnnie.prConfig:addParam("AZMR", "Must Have 0 Enemy In Range:", SCRIPT_PARAM_SLICE, 900, 0, 1500, 0)
	MenuAnnie.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAnnie.prConfig:addParam("ALS", "Auto lvl skills", SCRIPT_PARAM_ONOFF, false)
	MenuAnnie.prConfig:addParam("AL", "Auto lvl sequence", SCRIPT_PARAM_LIST, 1, { "MID","SUPP"})
	MenuAnnie.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAnnie.prConfig:addParam("pro", "Prodiction To Use:", SCRIPT_PARAM_LIST, 1, {"VPrediction","Prodiction","DivinePred"}) 
	MenuAnnie.comboConfig:permaShow("CEnabled")
	MenuAnnie.harrasConfig:permaShow("HEnabled")
	MenuAnnie.harrasConfig:permaShow("HTEnabled")
	MenuAnnie.prConfig:permaShow("AZ")
	MenuAnnie.exConfig:permaShow("AW")
	MenuAnnie.exConfig:permaShow("AR")
	MenuAnnie.exConfig:permaShow("SP")
	MenuAnnie.exConfig:permaShow("AEE")
	if heroManager.iCount < 10 then
		print("<font color=\"#FF0000\">Too few champions to arrange priority.</font>")
	elseif heroManager.iCount == 6 then
		arrangePrioritysTT()
    else
		arrangePrioritys()
	end
end

function caa()
	if MenuAnnie.orb == 1 then
		if MenuAnnie.comboConfig.uaa2 then
			if GetDistance(Cel) < (Q.range - 50) then
				SxOrb:EnableAttacks()
			else
				SxOrb:DisableAttacks()
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
	RFTS:update()
	FRCel = RFTS.target
	if SelectedTarget ~= nil and ValidTarget(SelectedTarget, Q.range) then
		Cel = SelectedTarget
	else
		Cel = GetCustomTarget()
	end
	if MenuAnnie.orb == 1 then
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
	if 30 < os.clock() * 100 - LastCheck then
	if R.Ready() and ValidTarget(Cel, R.range) and MenuAnnie.comboConfig.rConfig[Cel.charName] then
		if MenuAnnie.comboConfig.rConfig.RM == 2 then
			CastR(Cel)
		end
		if MenuAnnie.comboConfig.rConfig.RM == 3 then
			local r = getDmg("R", Cel, myHero, 3)
			if Cel.health < r then
				CastR(Cel)
			end
		end
		if MenuAnnie.comboConfig.rConfig.RM == 4 then
			for _, enemy in pairs(GetEnemyHeroes()) do
				local rPos, HitChance, maxHit, Positions = VP:GetCircularAOECastPosition(enemy, R.delay, R.width, R.range, R.speed, myHero)
				if R.Ready() and ValidTarget(enemy) and rPos ~= nil and maxHit >= MenuAnnie.comboConfig.rConfig.HXC then		
					if VIP_USER and MenuAnnie.prConfig.pc then
						Packet("S_CAST", {spellId = _R, fromX = rPos.x, fromY = rPos.z, toX = rPos.x, toY = rPos.z}):send()
					else
						CastSpell(_R, rPos.x, rPos.z)
					end	
				end
			end
		end
	end
	if Q.Ready() and MenuAnnie.comboConfig.qConfig.USEQ and ValidTarget(Cel, Q.range) then
		CastQ(Cel)
	end
	if W.Ready() and MenuAnnie.comboConfig.wConfig.USEW and ValidTarget(Cel, W.range) then
		CastW(Cel)
	end
	if MenuAnnie.comboConfig.eConfig.USEE then
		CastE()
	end
	LastCheck = os.clock() * 100
	end
end

function Harrass()
	if 30 < os.clock() * 100 - LastCheck then
	if MenuAnnie.harrasConfig.HM == 1 then
		if Q.Ready() and ValidTarget(Cel, Q.range) then
			CastQ(Cel)
		end
	end
	if MenuAnnie.harrasConfig.HM == 2 then
		if W.Ready() and ValidTarget(Cel, W.range) then
			CastW(Cel)
		end
	end
	LastCheck = os.clock() * 100
	end
end

function Farm()
	EnemyMinions:update()
	local QMode =  MenuAnnie.farm.QF
	local WMode =  MenuAnnie.farm.WF
	for i, minion in pairs(EnemyMinions.objects) do
		if QMode == 3 then
			if Q.Ready() and minion ~= nil and ValidTarget(minion, Q.range) then
				if not MenuAnnie.farm.SFS and stun or not stun then 
					CastSpell(_Q, minion)
				end
			end
		elseif QMode == 2 then
			if Q.Ready() and minion ~= nil and ValidTarget(minion, Q.range) then
				if minion.health <= getDmg("Q", minion, myHero) then
					if not MenuAnnie.farm.SFS and stun or not stun then  
						CastSpell(_Q, minion)
					end
				end
			end
		end
		if WMode == 3 then
			if W.Ready() and minion ~= nil and ValidTarget(minion, W.range) then
				if not MenuAnnie.farm.SFS and stun or not stun then 
					CastW(minion)
				end
			end
		elseif WMode == 2 then
			if W.Ready() and minion ~= nil and ValidTarget(minion, W.range) then
				if minion.health <= getDmg("W", minion, myHero) then
					if not MenuAnnie.farm.SFS and stun or not stun then 
						CastW(minion)
					end
				end
			end
		end
	end
end

function JungleFarm()
	JungleMinions:update()
	for i, minion in pairs(JungleMinions.objects) do
		if MenuAnnie.jf.WJF then
			if W.Ready() and minion ~= nil and ValidTarget(minion, W.range) then
				CastW(minion)
			end
		end
		if MenuAnnie.jf.QJF then
			if Q.Ready() and minion ~= nil and ValidTarget(minion, Q.range) then
				CastSpell(_Q, minion)
			end
		end
	end
end

function AutoWR()
	for _, enemy in pairs(GetEnemyHeroes()) do
		if MenuAnnie.exConfig.AW then
			local wPos, HitChance, maxHit, Positions = VP:GetConeAOECastPosition(enemy, W.delay, W.width, W.range, W.speed, myHero)
			if ValidTarget(enemy, W.range) and wPos ~= nil and maxHit >= MenuAnnie.exConfig.AWX then	
				if stun and W.Ready() then
					if VIP_USER and MenuAnnie.prConfig.pc then
						Packet("S_CAST", {spellId = _W, fromX = wPos.x, fromY = wPos.z, toX = wPos.x, toY = wPos.z}):send()
					else
						CastSpell(_W, wPos.x, wPos.z)
					end	
				end
			end
		end
		if MenuAnnie.exConfig.AR then
			local rPos, HitChance, maxHit, Positions = VP:GetCircularAOECastPosition(enemy, R.delay, R.width, R.range, R.speed, myHero)
			if ValidTarget(enemy, R.range) and rPos ~= nil and maxHit >= MenuAnnie.exConfig.ARX then	
				if stun and R.Ready() then
					if VIP_USER and MenuAnnie.prConfig.pc then
						Packet("S_CAST", {spellId = _R, fromX = rPos.x, fromY = rPos.z, toX = rPos.x, toY = rPos.z}):send()
					else
						CastSpell(_R, rPos.x, rPos.z)
					end		
				end
			end
		end
	end
end

function stackp()
	if not stun and E.Ready() then
		CastE()
	end
end

function stackp2()
	if not stun and InFountain() then
		if E.Ready() then
			CastE()
		end
		if W.Ready() then
			CastSpell(_W, myHero.x, myHero.z)
		end
	end
end

function FlashR()
	local FlashReady = SSpells:Ready("summonerflash")
	local targetpos = VP:GetPredictedPos(FRCel, R.delay)
	local flashposition = Vector(myHero) + 400 * (Vector(targetpos) - Vector(myHero)):normalized()
	local rPos, HitChance, maxHit, Positions = VP:GetCircularAOECastPosition(FRCel, R.delay, R.width, R.range, R.speed, myHero)
	if rPos ~= nil and maxHit >= MenuAnnie.exConfig.FRWX and not IsWall(D3DXVECTOR3(flashposition.x, flashposition.y, flashposition.z)) and GetDistance(myHero, targetpos) > R.range and GetDistance(myHero, targetpos) <= (R.range + 400) then
		if R.Ready() and FlashReady and stun then
			CastSpell(SSpells:GetSlot("summonerflash"), flashposition.x, flashposition.z)
			DelayAction(function() CastSpell(_R, rPos.x, rPos.z) end, 0.25)
		end
	end
end

function autozh()
	local count = EnemyCount(myHero, MenuAnnie.prConfig.AZMR)
	local zhonyaslot = GetInventorySlotItem(3157)
	local zhonyaready = (zhonyaslot ~= nil and myHero:CanUseSpell(zhonyaslot) == READY)
	if zhonyaready and ((myHero.health/myHero.maxHealth)*100) < MenuAnnie.prConfig.AZHP and count == 0 then
		CastSpell(zhonyaslot)
	end
end

function autolvl()
	if not MenuAnnie.prConfig.ALS then return end
	if myHero.level > GetHeroLeveled() then
		local a = {}
		if MenuAnnie.prConfig.AL == 1 then
			a = {_Q,_W,_Q,_W,_Q,_R,_E,_Q,_Q,_W,_R,_W,_W,_E,_E,_R,_E,_E}
		else
			a = {_W,_Q,_Q,_E,_Q,_R,_Q,_W,_Q,_W,_R,_W,_W,_E,_E,_R,_E,_E}
		end
		LevelSpell(a[GetHeroLeveled() + 1])
	end
end

function OnDraw()
	if MenuAnnie.drawConfig.DST and MenuAnnie.comboConfig.ST then
		if SelectedTarget ~= nil and not SelectedTarget.dead then
			DrawCircle2(SelectedTarget.x, SelectedTarget.y, SelectedTarget.z, 100, RGB(MenuAnnie.drawConfig.DQRC[2], MenuAnnie.drawConfig.DQRC[3], MenuAnnie.drawConfig.DQRC[4]))
		end
	end
	if MenuAnnie.drawConfig.DD then
		for _,enemy in pairs(GetEnemyHeroes()) do
			DmgCalc()
            if ValidTarget(enemy, 1500) and killstring[enemy.networkID] ~= nil then
                local pos = WorldToScreen(D3DXVECTOR3(enemy.x, enemy.y, enemy.z))
                DrawText(killstring[enemy.networkID], 20, pos.x - 35, pos.y - 10, 0xFFFFFF00)
            end
        end
	end
	if MenuAnnie.drawConfig.DQR and (Q.Ready() or W.Ready()) then			
		DrawCircle2(myHero.x, myHero.y, myHero.z, Q.range, RGB(MenuAnnie.drawConfig.DQRC[2], MenuAnnie.drawConfig.DQRC[3], MenuAnnie.drawConfig.DQRC[4]))
	end
	if MenuAnnie.drawConfig.DRR and R.Ready() then			
		DrawCircle2(myHero.x, myHero.y, myHero.z, R.range, RGB(MenuAnnie.drawConfig.DRRC[2], MenuAnnie.drawConfig.DRRC[3], MenuAnnie.drawConfig.DRRC[4]))
	end
end

function KillSteall()
	for _,enemy in pairs(GetEnemyHeroes()) do
		local health = enemy.health
		local IDMG = (50 + (20 * myHero.level))
		local QDMG = getDmg("Q", enemy, myHero, 3) 
		local WDMG = getDmg("W", enemy, myHero, 3) 
		local RDMG = getDmg("R", enemy, myHero, 3) 
		if ValidTarget(enemy, 700) and enemy ~= nil and enemy.team ~= player.team and not enemy.dead and enemy.visible then
			if 30 < os.clock() * 100 - LastCheck2 then
			local IReady = SSpells:Ready("summonerdot")
			if health < QDMG and MenuAnnie.ksConfig.QKS and ValidTarget(enemy, Q.range) and Q.Ready() then
				CastQ(enemy)
			elseif health < WDMG and MenuAnnie.ksConfig.WKS and ValidTarget(enemy, W.range) and W.Ready() then
				CastW(enemy)
			elseif health < RDMG and MenuAnnie.ksConfig.RKS and ValidTarget(enemy, R.range) and R.Ready() then
				CastR(enemy)
			elseif health < IDMG and MenuAnnie.ksConfig.IKS and ValidTarget(enemy, 600) and IReady then
				CastSpell(SSpells:GetSlot("summonerdot"), enemy)
			elseif health < (QDMG+WDMG) and MenuAnnie.ksConfig.WKS and MenuAnnie.ksConfig.QKS and ValidTarget(enemy, W.range) and W.Ready() and Q.Ready() then
				CastW(enemy)
				CastQ(enemy)
			elseif health < (QDMG+RDMG) and MenuAnnie.ksConfig.RKS and MenuAnnie.ksConfig.QKS and ValidTarget(enemy, R.range) and R.Ready() and Q.Ready() then
				CastR(enemy)
				CastQ(enemy)
			elseif health < (WDMG+RDMG) and MenuAnnie.ksConfig.RKS and MenuAnnie.ksConfig.WKS and ValidTarget(enemy, R.range) and R.Ready() and W.Ready() then
				CastR(enemy)
				CastW(enemy)
			elseif health < (QDMG+WDMG+RDMG) and MenuAnnie.ksConfig.QKS and MenuAnnie.ksConfig.RKS and MenuAnnie.ksConfig.WKS and ValidTarget(enemy, R.range) and R.Ready() and W.Ready() and Q.Ready() then
				CastR(enemy)
				CastQ(enemy)
				CastW(enemy)
			elseif health < (QDMG+IDMG) and MenuAnnie.ksConfig.QKS and ValidTarget(enemy, Q.range) and Q.Ready() and MenuAnnie.ksConfig.IKS and IReady then
				CastQ(enemy)
				CastSpell(SSpells:GetSlot("summonerdot"), enemy)
			elseif health < (QDMG+IDMG) and MenuAnnie.ksConfig.WKS and ValidTarget(enemy, W.range) and W.Ready() and MenuAnnie.ksConfig.IKS and IReady then
				CastW(enemy)
				CastSpell(SSpells:GetSlot("summonerdot"), enemy)
			elseif health < (RDMG+IDMG) and MenuAnnie.ksConfig.RKS and ValidTarget(enemy, R.range) and R.Ready() and MenuAnnie.ksConfig.IKS and IReady then
				CastR(enemy)
				CastSpell(SSpells:GetSlot("summonerdot"), enemy)
			elseif health < (QDMG+WDMG+IDMG) and MenuAnnie.ksConfig.WKS and MenuAnnie.ksConfig.QKS and ValidTarget(enemy, W.range) and W.Ready() and Q.Ready() and MenuAnnie.ksConfig.IKS and IReady then
				CastW(enemy)
				CastQ(enemy)
				CastSpell(SSpells:GetSlot("summonerdot"), enemy)
			elseif health < (QDMG+RDMG+IDMG) and MenuAnnie.ksConfig.RKS and MenuAnnie.ksConfig.QKS and ValidTarget(enemy, R.range) and R.Ready() and Q.Ready() and MenuAnnie.ksConfig.IKS and IReady then
				CastR(enemy)
				CastQ(enemy)
				CastSpell(SSpells:GetSlot("summonerdot"), enemy)
			elseif health < (WDMG+RDMG+IDMG) and MenuAnnie.ksConfig.RKS and MenuAnnie.ksConfig.WKS and ValidTarget(enemy, R.range) and R.Ready() and W.Ready() and MenuAnnie.ksConfig.IKS and IReady then
				CastR(enemy)
				CastW(enemy)
				CastSpell(SSpells:GetSlot("summonerdot"), enemy)
			elseif health < (QDMG+WDMG+RDMG+IDMG) and MenuAnnie.ksConfig.QKS and MenuAnnie.ksConfig.RKS and MenuAnnie.ksConfig.WKS and ValidTarget(enemy, R.range) and R.Ready() and W.Ready() and Q.Ready() and MenuAnnie.ksConfig.IKS and IReady then
				CastR(enemy)
				CastQ(enemy)
				CastW(enemy)
				CastSpell(SSpells:GetSlot("summonerdot"), enemy)
			end
			LastCheck2 = os.clock() * 100
			end
		end
	end
end

function DmgCalc()
	for _,enemy in pairs(GetEnemyHeroes()) do
        if not enemy.dead and enemy.visible and GetDistance(enemy) < 3000 then
			local QDMG = getDmg("Q", enemy, myHero, 3)
			local WDMG = getDmg("W", enemy, myHero, 3)
			local RDMG = getDmg("R", enemy, myHero, 3)
			local IDMG = (50 + (20 * myHero.level))
			if enemy.health > (QDMG + WDMG + RDMG + IDMG) then
				killstring[enemy.networkID] = "Harass Him!!!"
			elseif enemy.health < QDMG and enemy.health > QDMG + IDMG then
				killstring[enemy.networkID] = "Q Kill!"
			elseif enemy.health < (QDMG + IDMG) and enemy.health > QDMG then
				killstring[enemy.networkID] = "Q+Ignite Kill!"
			elseif enemy.health < WDMG and enemy.health > (WDMG + IDMG) then
				killstring[enemy.networkID] = "W Kill!"
			elseif enemy.health < (WDMG + IDMG) and enemy.health > WDMG then
				killstring[enemy.networkID] = "W+Ignite Kill!"	
			elseif enemy.health < RDMG and enemy.health > (RDMG + IDMG) then
				killstring[enemy.networkID] = "R Kill!"
			elseif enemy.health < (RDMG + IDMG) and enemy.health > RDMG then
				killstring[enemy.networkID] = "R+Ignite Kill!"	
			elseif enemy.health < (QDMG + WDMG) then
				killstring[enemy.networkID] = "Q+W Kill!"
			elseif enemy.health < (QDMG + WDMG + IDMG) then
				killstring[enemy.networkID] = "Q+W+Ignite Kill!"	
			elseif enemy.health < (QDMG + RDMG) then
				killstring[enemy.networkID] = "Q+R Kill!"
			elseif enemy.health < (QDMG + RDMG + IDMG) then
				killstring[enemy.networkID] = "Q+R+Ignite Kill!"	
			elseif enemy.health < (WDMG + RDMG) then
				killstring[enemy.networkID] = "W+R Kill!"
			elseif enemy.health < (WDMG + RDMG + IDMG) then
				killstring[enemy.networkID] = "W+R+Ignite Kill!"		
			elseif enemy.health < (QDMG + WDMG + RDMG) then
				killstring[enemy.networkID] = "Q+W+R Kill!"
			elseif enemy.health < (QDMG + WDMG + RDMG + IDMG) then
				killstring[enemy.networkID] = "Q+W+R+Ignite Kill!"
			end
		end
	end
end

function CastQ(unit)
	if VIP_USER and MenuAnnie.prConfig.pc then
		Packet("S_CAST", {spellId = _Q, targetNetworkId = unit.networkID}):send()
	else
		CastSpell(_Q, unit)
	end	
end

function CastW(unit)
	if MenuAnnie.prConfig.pro == 1 then
		local CastPosition,  HitChance,  Position = VP:GetConeAOECastPosition(unit, W.delay, W.width, W.range, W.speed, myHero)
		if CastPosition and HitChance >= 2 then
			if VIP_USER and MenuAnnie.prConfig.pc then
				Packet("S_CAST", {spellId = _W, fromX = CastPosition.x, fromY = CastPosition.z, toX = CastPosition.x, toY = CastPosition.z}):send()
			else
				CastSpell(_W, CastPosition.x, CastPosition.z)
			end	
		end
	end
	if MenuAnnie.prConfig.pro == 2 and VIP_USER and prodstatus then
		local Position, info = Prodiction.GetPrediction(unit, W.range, W.speed, W.delay, W.width, myHero)
		if Position ~= nil then
			if VIP_USER and MenuAnnie.prConfig.pc then
				Packet("S_CAST", {spellId = _W, fromX = Position.x, fromY = Position.z, toX = Position.x, toY = Position.z}):send()
			else
				CastSpell(_W, Position.x, Position.z)
			end	
		end
	end
	if MenuAnnie.prConfig.pro == 3 and VIP_USER then
		local unit = DPTarget(unit)
		local AnnieW = ConeSS(W.speed, W.range, W.width, W.delay*1000, math.huge)
		local State, Position, perc = DP:predict(unit, AnnieW, 2)
		if State == SkillShot.STATUS.SUCCESS_HIT then 
			if VIP_USER and MenuAnnie.prConfig.pc then
				Packet("S_CAST", {spellId = _W, fromX = Position.x, fromY = Position.z, toX = Position.x, toY = Position.z}):send()
			else
				CastSpell(_W, Position.x, Position.z)
			end
		end
	end
end

function CastE()
	if E.Ready() then
		if VIP_USER and MenuAnnie.prConfig.pc then
			Packet("S_CAST", {spellId = _E}):send()
		else
			CastSpell(_E)
		end
	end
end

function CastR(unit)
	if MenuAnnie.prConfig.pro == 1 then
		local CastPosition,  HitChance,  Position = VP:GetCircularAOECastPosition(unit, R.delay, R.width, R.range, R.speed, myHero)
		if CastPosition and HitChance >= 2 then
			if VIP_USER and MenuAnnie.prConfig.pc then
				Packet("S_CAST", {spellId = _R, fromX = CastPosition.x, fromY = CastPosition.z, toX = CastPosition.x, toY = CastPosition.z}):send()
			else
				CastSpell(_R, CastPosition.x, CastPosition.z)
			end	
		end
	end
	if MenuAnnie.prConfig.pro == 2 and VIP_USER and prodstatus then
		local Position, info = Prodiction.GetPrediction(unit, R.range, R.speed, R.delay, R.width, myHero)
		if Position ~= nil then
			if VIP_USER and MenuAnnie.prConfig.pc then
				Packet("S_CAST", {spellId = _R, fromX = Position.x, fromY = Position.z, toX = Position.x, toY = Position.z}):send()
			else
				CastSpell(_R, Position.x, Position.z)
			end	
		end
	end
	if MenuAnnie.prConfig.pro == 3 and VIP_USER then
		local unit = DPTarget(unit)
		local AnnieR = CircleSS(R.speed, R.range, R.width, R.delay*1000, math.huge)
		local State, Position, perc = DP:predict(unit, AnnieR, 2)
		if State == SkillShot.STATUS.SUCCESS_HIT then 
			if VIP_USER and MenuAnnie.prConfig.pc then
				Packet("S_CAST", {spellId = _R, fromX = Position.x, fromY = Position.z, toX = Position.x, toY = Position.z}):send()
			else
				CastSpell(_R, Position.x, Position.z)
			end
		end
	end
end

function OnProcessSpell(unit,spell)
	if MenuAnnie.exConfig.AEE then
		if unit.team ~= myHero.team and unit.type == myHero.type and spell.target == myHero and spell.name:lower():find("attack") then
			CastE()
		end
	end
end

function OnApplyBuff(unit, source, buff)
	if unit and unit.isMe and buff and (buff.name == "Recall") then
		recall = true
	end 
	if unit and unit.isMe and buff and (buff.name == "pyromania_particle") then
		stun = true
	end 
	if unit and unit.isMe and buff and (buff.name == "infernalguardiantimer") then
		tibbers = true
	end 
end

function OnRemoveBuff(unit, buff)
	if unit and unit.isMe and buff and (buff.name == "Recall") then
		recall = false
	end 
	if unit and unit.isMe and buff and (buff.name == "pyromania_particle") then
		stun = false
	end 
	if unit and unit.isMe and buff and (buff.name == "infernalguardiantimer") then
		tibbers = false
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

function OnWndMsg(Msg, Key)
	if Msg == WM_LBUTTONDOWN and MenuAnnie.comboConfig.ST then
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
				if MenuAnnie.comboConfig.ST then 
					print("Target unselected: "..Selecttarget.charName) 
				end
			else
				SelectedTarget = Selecttarget
				if MenuAnnie.comboConfig.ST then 
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
assert(load(Base64Decode("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"), nil, "bt", _ENV))() ScriptStatus("XKNLLRKKOPQ") 