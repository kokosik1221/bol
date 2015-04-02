--[[

	Script Name: GRAVES MASTER 
    	Author: kokosik1221
	Last Version: 0.37
	02.04.2015

]]--

if myHero.charName ~= "Graves" then return end

local version = 0.37
 
class "ScriptUpdate"
function ScriptUpdate:__init(LocalVersion, Host, VersionPath, ScriptPath, SavePath, CallbackUpdate, CallbackNoUpdate, CallbackNewVersion)
    self.LocalVersion = LocalVersion
    self.Host = Host
    self.VersionPath = '/BoL/TCPUpdater/GetScript2.php?script='..self:Base64Encode(self.Host..VersionPath)..'&rand='..math.random(99999999)
    self.ScriptPath = '/BoL/TCPUpdater/GetScript2.php?script='..self:Base64Encode(self.Host..ScriptPath)..'&rand='..math.random(99999999)
    self.SavePath = SavePath
    self.CallbackUpdate = CallbackUpdate
    self.CallbackNoUpdate = CallbackNoUpdate
    self.CallbackNewVersion = CallbackNewVersion
    self.LuaSocket = require("socket")
    self.Socket = self.LuaSocket.connect('sx-bol.eu', 80)
    self.Socket:send("GET "..self.VersionPath.." HTTP/1.0\r\nHost: sx-bol.eu\r\n\r\n")
    self.Socket:settimeout(0, 'b')
    self.Socket:settimeout(99999999, 't')
    self.LastPrint = ""
    self.File = ""
    AddTickCallback(function() self:GetOnlineVersion() end)
end
function ScriptUpdate:Base64Encode(data)
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
function ScriptUpdate:GetOnlineVersion()
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
            if self.OnlineVersion > self.LocalVersion then
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
function ScriptUpdate:DownloadUpdate()
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
function Update()
	local ToUpdate = {}
    ToUpdate.Version = version
    ToUpdate.Host = "raw.githubusercontent.com"
    ToUpdate.VersionPath = "/kokosik1221/bol/master/GravesMaster.version"
    ToUpdate.ScriptPath = "/kokosik1221/bol/master/GravesMaster.lua"
    ToUpdate.SavePath = SCRIPT_PATH.."GravesMaster.lua"
    ToUpdate.CallbackUpdate = function(NewVersion,OldVersion) print("<font color=\"#FF0000\"><b>Graves Master: </b></font> <font color=\"#FFFFFF\">Updated to "..NewVersion..". Please Reload with 2x F9</b></font>") end
    ToUpdate.CallbackNoUpdate = function(OldVersion) print("<font color=\"#FF0000\"><b>Graves Master: </b></font> <font color=\"#FFFFFF\">No Updates Found</b></font>") end
    ToUpdate.CallbackNewVersion = function(NewVersion) print("<font color=\"#FF0000\"><b>Graves Master: </b></font> <font color=\"#FFFFFF\">New Version found ("..NewVersion.."). Please wait until its downloaded</b></font>") end
    ScriptUpdate(ToUpdate.Version, ToUpdate.Host, ToUpdate.VersionPath, ToUpdate.ScriptPath, ToUpdate.SavePath, ToUpdate.CallbackUpdate,ToUpdate.CallbackNoUpdate, ToUpdate.CallbackNewVersion)
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
	DP.maxCalcTime = 150
end

local Q = {name = "Buckshot", range = 950, speed = 2000, delay = 0.25, width = 25*math.pi/180, Ready = function() return myHero:CanUseSpell(_Q) == READY end}
local W = {name = "Smoke Screen", range = 950, speed = 1650, delay = 0.25, width = 250, Ready = function() return myHero:CanUseSpell(_W) == READY end}
local E = {name = "Quickdraw", range = 425, Ready = function() return myHero:CanUseSpell(_E) == READY end}
local R = {name = "Collateral Damage", range = 1000, speed = 2100, delay = 0.25, width = 100, Ready = function() return myHero:CanUseSpell(_R) == READY end}
local QTargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, Q.range, DAMAGE_PHYSICAL)
local WTargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, W.range, DAMAGE_PHYSICAL)
local RTargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, R.range, DAMAGE_PHYSICAL)
local HReady, recall = false, false
local EnemyMinions = minionManager(MINION_ENEMY, Q.range, myHero, MINION_SORT_MAXHEALTH_DEC)
local JungleMinions = minionManager(MINION_JUNGLE, Q.range, myHero, MINION_SORT_MAXHEALTH_DEC)
local HealKey = nil
local Spells = {_Q,_W,_E,_R}
local Spells2 = {"Q","W","E","R"}
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
local DodgeTable =
{
	['GalioIdolOfDurand'] = {charName = "Galio", spellSlot = "R", SpellType = "skillshot"},
    ['GnarBigW'] = {charName = "Gnar", spellSlot = "W", SpellType = "skillshot"},
    ['GnarBigR'] = {charName = "Gnar", spellSlot = "R", SpellType = "skillshot"},	
	['NamiQ'] = {charName = "Nami", spellSlot = "Q", SpellType = "skillshot"},
    ['NamiR'] = {charName = "Nami", spellSlot = "R", SpellType = "skillshot"},
	['LuxLightBinding'] = {charName = "Lux", spellSlot = "Q", SpellType = "skillshot"},
	['RenektonPreExecute'] = {charName = "Renekton", spellSlot = "W", SpellType = "skillshot"},
	['LeonaZenithBlade'] = {charName = "Leona", spellSlot = "E", SpellType = "skillshot"},
    ['LeonaZenithBladeMissle'] = {charName = "Leona", spellSlot = "E", SpellType = "skillshot"},
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
	['yasuoq3w'] = {charName = "Yasuo", spellSlot = "Q", SpellType = "skillshot"},
	['EliseHumanE'] = {charName = "Elise", spellSlot = "E", SpellType = "skillshot"},
	['MonkeyKingSpinToWin'] = {charName = "MonkeyKing", spellSlot = "R", SpellType = "skillshot"},
	['monkeykingspintowinleave'] = {charName = "MonkeyKing", spellSlot = "R", SpellType = "skillshot"},
	['OrianaDetonateCommand'] = {charName = "Orianna", spellSlot = "R", SpellType = "skillshot"},
	['ZyraGraspingRoots'] = {charName = "Zyra", spellSlot = "E", SpellType = "skillshot"},
	['ZyraBrambleZone'] = {charName = "Zyra", spellSlot = "R", SpellType = "skillshot"},
	['HowlingGale'] = {charName = "Janna", spellSlot = "Q", SpellType = "skillshot"},
	['ReapTheWhirlwind'] = {charName = "Janna", spellSlot = "R", SpellType = "skillshot"},
	['XerathMageSpear'] = {charName = "Xerath", spellSlot = "E", SpellType = "skillshot"},
	['Rupture'] = {charName = "Chogath", spellSlot = "Q", SpellType = "skillshot"},
	['FeralScream'] = {charName = "Chogath", spellSlot = "W", SpellType = "skillshot"},
	['CassiopeiaPetrifyingGaze'] = {charName = "Cassiopeia", spellSlot = "R", SpellType = "skillshot"},
	['KennenShurikenStorm ']= {charName = "Kennen", spellSlot = "R", SpellType = "skillshot"},
	['FizzMarinerDoom'] = {charName = "Fizz", spellSlot = "R", SpellType = "skillshot"},
	['HecarimUlt'] = {charName = "Hecarim", spellSlot = "R", SpellType = "skillshot"},
}

function OnLoad()
	DelayAction(function()
		Update()
	end,0.1)
	Menu()
	print("<b><font color=\"#FF0000\">Graves Master:</font></b> <font color=\"#FFFFFF\">Good luck and give me feedback!</font>")
	if _G.MMA_Loaded then
		print("<b><font color=\"#FF0000\">Graves Master:</font></b> <font color=\"#FFFFFF\">MMA Support Loaded.</font>")
	end
	if _G.AutoCarry then
		print("<b><font color=\"#FF0000\">Graves Master:</font></b> <font color=\"#FFFFFF\">SAC Support Loaded.</font>")
	end
end

function Menu()
	MenuGraves = scriptConfig("Graves Master "..version, "Graves Master "..version)
	MenuGraves:addParam("orb", "Orbwalker:", SCRIPT_PARAM_LIST, 1, {"SxOrb","SAC:R/MMA"}) 
	MenuGraves:addParam("qqq", "If You Change Orb. Click 2x F9", SCRIPT_PARAM_INFO,"")
	if MenuGraves.orb == 1 then
		MenuGraves:addSubMenu("[Graves Master]: Orbwalking", "Orbwalking")
		SxOrb:LoadToMenu(MenuGraves.Orbwalking)
		SxOrb:RegisterAfterAttackCallback(function(t) aa() end)
	end
	TargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, myHero.range+65, DAMAGE_PHYSICAL)
	TargetSelector.name = "Graves"
	MenuGraves:addTS(TargetSelector)
	MenuGraves:addSubMenu("[Graves Master]: Combo Settings", "comboConfig")
	MenuGraves.comboConfig:addSubMenu("[Graves Master]: Q Settings", "qConfig")
	MenuGraves.comboConfig.qConfig:addParam("USEQ", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_LIST, 2, { "No", "Normal", "After AA"})
	MenuGraves.comboConfig.qConfig:addParam("USEQ2", "Dash With E", SCRIPT_PARAM_ONOFF, false)
	MenuGraves.comboConfig.qConfig:addParam("USEQR", "Max. Q Range", SCRIPT_PARAM_SLICE, 950, 0, 950, 0)
	MenuGraves.comboConfig:addSubMenu("[Graves Master]: W Settings", "wConfig")
	MenuGraves.comboConfig.wConfig:addParam("USEW", "Use " .. W.name .. " (W)", SCRIPT_PARAM_LIST, 2, { "No", "Normal", "Can Hit X", "AA Reset"})
	MenuGraves.comboConfig.wConfig:addParam("USEWX", "X = ", SCRIPT_PARAM_SLICE, 3, 1, 5, 0)
	MenuGraves.comboConfig.wConfig:addParam("USEW2", "Min. Mana To Cast", SCRIPT_PARAM_SLICE, 50, 0, 100, 0)
	MenuGraves.comboConfig:addSubMenu("[Graves Master]: E Settings", "eConfig")
	MenuGraves.comboConfig.eConfig:addParam("USEE", "Use " .. E.name .. " (E)", SCRIPT_PARAM_LIST, 2, { "No", "To Mouse", "To Target"})
	MenuGraves.comboConfig:addSubMenu("[Graves Master]: R Settings", "rConfig")
	MenuGraves.comboConfig.rConfig:addParam("USER", "Use " .. R.name .. " (R)", SCRIPT_PARAM_ONOFF, true)
	MenuGraves.comboConfig.rConfig:addParam("USER2", "Cast If:", SCRIPT_PARAM_LIST, 2, { "Easy Kill", "Medium Kill", "Hard Kill", "Can Hit X"})
	MenuGraves.comboConfig.rConfig:addParam("USERX", "X = ", SCRIPT_PARAM_SLICE, 3, 1, 5, 0)
	MenuGraves.comboConfig.rConfig:addParam("CRKD", "Cast (R) Key Down", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("R"))
	MenuGraves.comboConfig:addParam("ST", "Focus Selected Target", SCRIPT_PARAM_ONOFF, false)
	MenuGraves.comboConfig:addParam("CEnabled", "Full Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	MenuGraves.comboConfig:addParam("manac", "Min. Mana To Cast Combo", SCRIPT_PARAM_SLICE, 10, 0, 100, 0)
	MenuGraves:addSubMenu("[Graves Master]: Harras Settings", "harrasConfig")
    MenuGraves.harrasConfig:addParam("USEQ", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_LIST, 2, { "No", "Normal", "After AA"})
	MenuGraves.harrasConfig:addParam("USEW", "Use " .. W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
	MenuGraves.harrasConfig:addParam("HEnabled", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
	MenuGraves.harrasConfig:addParam("HTEnabled", "Harass Toggle", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("L"))
	MenuGraves.harrasConfig:addParam("manah", "Min. Mana To Harrass", SCRIPT_PARAM_SLICE, 60, 0, 100, 0)
	MenuGraves:addSubMenu("[Graves Master]: Extra Settings", "exConfig")
	MenuGraves.exConfig:addSubMenu("[Graves Master]: Dodge Spells", "dspells")
	Enemies = GetEnemyHeroes() 
    for i,enemy in pairs (Enemies) do
		for j,spell in pairs (Spells) do 
			if DodgeTable[enemy:GetSpellData(spell).name] then 
				MenuGraves.exConfig.dspells:addParam(tostring(enemy:GetSpellData(spell).name),"Dodge "..tostring(enemy.charName).." Spell "..tostring(Spells2[j]),SCRIPT_PARAM_ONOFF,true)
			end 
		end 
	end 
	MenuGraves.exConfig:addParam("ED", "Try Dodge Enemy Spells", SCRIPT_PARAM_ONOFF, true)
	MenuGraves.exConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuGraves.exConfig:addParam("UAH", "Auto Heal Summoner", SCRIPT_PARAM_ONOFF, true)
	MenuGraves.exConfig:addParam("UAHHP", "Min. HP% To Heal", SCRIPT_PARAM_SLICE, 35, 0, 100, 0)
	MenuGraves:addSubMenu("[Graves Master]: KS Settings", "ksConfig")
	MenuGraves.ksConfig:addParam("QKS", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	MenuGraves.ksConfig:addParam("WKS", "Use " .. W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
	MenuGraves.ksConfig:addParam("RKS", "Use " .. R.name .. " (R)", SCRIPT_PARAM_ONOFF, true)
	MenuGraves:addSubMenu("[Graves Master]: Farm Settings", "farm")
	MenuGraves.farm:addParam("QF", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_LIST, 2, { "No", "Freezing", "LaneClear"})
	MenuGraves.farm:addParam("WF", "Use " .. W.name .. " (W)", SCRIPT_PARAM_LIST, 2, { "No", "Freezing", "LaneClear"})
	MenuGraves.farm:addParam("LaneClear", "LaneClear", SCRIPT_PARAM_ONKEYDOWN, false,   string.byte("V"))
	MenuGraves.farm:addParam("manaf", "Min. Mana To Farm", SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
	MenuGraves:addSubMenu("[Graves Master]: Jungle Farm", "jf")
	MenuGraves.jf:addParam("QJF", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	MenuGraves.jf:addParam("WJF", "Use " .. W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
	MenuGraves.jf:addParam("JFEnabled", "Jungle Farm", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("V"))
	MenuGraves.jf:addParam("manajf", "Min. Mana To Jungle Farm", SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
	MenuGraves:addSubMenu("[Graves Master]: Draw Settings", "drawConfig")
	MenuGraves.drawConfig:addParam("DLC", "Draw Lag-Free Circles", SCRIPT_PARAM_ONOFF, true)
	MenuGraves.drawConfig:addParam("DST", "Draw Selected Target", SCRIPT_PARAM_ONOFF, true)
	MenuGraves.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuGraves.drawConfig:addParam("DAR", "Draw AA Range", SCRIPT_PARAM_ONOFF, true)
	MenuGraves.drawConfig:addParam("DARC", "Draw AA Range Color", SCRIPT_PARAM_COLOR, {255,255,0,255})
	MenuGraves.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuGraves.drawConfig:addParam("DQR", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
	MenuGraves.drawConfig:addParam("DQRC", "Draw Q Range Color", SCRIPT_PARAM_COLOR, {255,0,0,255})
	MenuGraves.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuGraves.drawConfig:addParam("DWR", "Draw W Range", SCRIPT_PARAM_ONOFF, true)
	MenuGraves.drawConfig:addParam("DWRC", "Draw W Range Color", SCRIPT_PARAM_COLOR, {255,0,255,255})
	MenuGraves.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuGraves.drawConfig:addParam("DER", "Draw E Range", SCRIPT_PARAM_ONOFF, true)
	MenuGraves.drawConfig:addParam("DERC", "Draw E Range Color", SCRIPT_PARAM_COLOR, {255,255,0,0})
	MenuGraves.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuGraves.drawConfig:addParam("DRR", "Draw R Range", SCRIPT_PARAM_ONOFF, true)
	MenuGraves.drawConfig:addParam("DRRC", "Draw R Range Color", SCRIPT_PARAM_COLOR, {255, 0, 255, 0})
	MenuGraves:addSubMenu("[Graves Master]: Misc Settings", "prConfig")
	MenuGraves.prConfig:addParam("pc", "Use Packets To Cast Spells(VIP)", SCRIPT_PARAM_ONOFF, false)
	MenuGraves.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuGraves.prConfig:addParam("ALS", "Auto lvl skills", SCRIPT_PARAM_ONOFF, false)
	MenuGraves.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuGraves.prConfig:addParam("pro", "Prodiction To Use:", SCRIPT_PARAM_LIST, 1, {"VPrediction", "Prodiction","DivinePred"}) 
	MenuGraves.comboConfig:permaShow("CEnabled")
	MenuGraves.harrasConfig:permaShow("HEnabled")
	MenuGraves.harrasConfig:permaShow("HTEnabled")
	if myHero:GetSpellData(SUMMONER_1).name:find("summonerheal") then HealKey = SUMMONER_1
		elseif myHero:GetSpellData(SUMMONER_2).name:find("summonerheal") then HealKey = SUMMONER_2
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

function OnTick()
	Check()
	if MenuGraves.comboConfig.CEnabled and not recall then
		if ((myHero.mana/myHero.maxMana)*100) >= MenuGraves.comboConfig.manac then
			Combo()
		end
	end
	if (MenuGraves.harrasConfig.HEnabled or MenuGraves.harrasConfig.HTEnabled) and ((myHero.mana/myHero.maxMana)*100) >= MenuGraves.harrasConfig.manah and not recall then
		Harass()
	end
	if MenuGraves.farm.LaneClear and ((myHero.mana/myHero.maxMana)*100) >= MenuGraves.farm.manaf and not recall then
		Farm()
	end
	if MenuGraves.jf.JFEnabled and ((myHero.mana/myHero.maxMana)*100) >= MenuGraves.jf.manajf and not recall then
		JungleFarm()
	end
	if MenuGraves.prConfig.ALS then
		autolvl()
	end
	if MenuGraves.exConfig.UAH and not recall then
		AutoHeal()
	end
	if not recall then
		KillSteal()
	end
	if MenuGraves.comboConfig.rConfig.CRKD then
		if RCel and RCel ~= nil and GetDistance(RCel) < R.range then
			CastR(RCel)
		end
	end
end

function Check()
	QTargetSelector.range = MenuGraves.comboConfig.qConfig.USEQR
	if SelectedTarget ~= nil and ValidTarget(SelectedTarget, R.range) then
		Cel = SelectedTarget
		QCel = SelectedTarget
		WCel = SelectedTarget
		RCel = SelectedTarget
	else
		Cel = GetCustomTarget()
		QTargetSelector:update()	
		QCel = QTargetSelector.target
		WTargetSelector:update()	
		WCel = WTargetSelector.target
		RTargetSelector:update()	
		RCel = RTargetSelector.target
	end
	if MenuGraves.drawConfig.DLC then _G.DrawCircle = DrawCircle2 else _G.DrawCircle = _G.oldDrawCircle end
	if MenuGraves.orb == 1 then
		SxOrb:ForceTarget(Cel)
	end
	if MenuGraves.comboConfig.qConfig.USEQ2 and Q.Ready() and E.Ready() then
		Q.range = 425 + MenuGraves.comboConfig.qConfig.USEQR
	elseif not MenuGraves.comboConfig.qConfig.USEQ2 then
		Q.range = MenuGraves.comboConfig.qConfig.USEQR
	end
end

function Combo()
	if QCel and QCel ~= nil and MenuGraves.comboConfig.qConfig.USEQ == 2 and GetDistance(QCel) < Q.range then
		if MenuGraves.comboConfig.qConfig.USEQ2 then
			CastE(QCel)
		end
		CastQ(QCel)
	end
	if MenuGraves.orb == 2 and _G.AutoCarry and QCel and QCel ~= nil and MenuGraves.comboConfig.qConfig.USEQ == 3 and GetDistance(QCel) < Q.range then
		if AutoCarry.Orbwalker:IsAfterAttack() then
			CastQ(QCel)
		end
	end
	if WCel and WCel ~= nil and MenuGraves.comboConfig.wConfig.USEW == 2 and GetDistance(WCel) < W.range then
		if ((myHero.mana/myHero.maxMana)*100) >= MenuGraves.comboConfig.wConfig.USEW2 then
			CastW(WCel)
		end
	end
	if MenuGraves.comboConfig.wConfig.USEW == 3 then
		if ((myHero.mana/myHero.maxMana)*100) >= MenuGraves.comboConfig.wConfig.USEW2 then
			for _, enemy in pairs(GetEnemyHeroes()) do
				local WPos, HitChance, maxHit, Positions = VP:GetCircularAOECastPosition(enemy, W.delay, W.width, W.range, W.speed, myHero)
				if W.Ready() and ValidTarget(enemy, W.range) and WPos ~= nil and maxHit >= MenuGraves.comboConfig.wConfig.USEWX then		
					if VIP_USER and MenuGraves.prConfig.pc then
						Packet("S_CAST", {spellId = _W, fromX = WPos.x, fromY = WPos.z, toX = WPos.x, toY = WPos.z}):send()
					else
						CastSpell(_W, WPos.x, WPos.z)
					end	
				end
			end
		end
	end
	if QCel and QCel ~= nil and MenuGraves.comboConfig.eConfig.USEE == 2 and GetDistance(QCel) <= myHero.range+65 then
		CastE(mousePos)
	end
	if QCel and QCel ~= nil and MenuGraves.comboConfig.eConfig.USEE == 3 and GetDistance(QCel) <= myHero.range+65 then
		CastE(QCel)
	end
	if RCel and RCel ~= nil and MenuGraves.comboConfig.rConfig.USER and GetDistance(RCel) < R.range and MenuGraves.comboConfig.rConfig.USER2 ~= 4 then
		CastR(RCel)
	end
	if MenuGraves.comboConfig.rConfig.USER and MenuGraves.comboConfig.rConfig.USER2 == 4 then
		CastR2()
	end
end

function Harass()
	if QCel and QCel ~= nil and MenuGraves.harrasConfig.USEQ == 2 and GetDistance(QCel) < Q.range then
		CastQ(QCel)
	end
	if MenuGraves.orb == 2 and _G.AutoCarry and QCel and QCel ~= nil and MenuGraves.harrasConfig.USEQ == 3 and GetDistance(QCel) < Q.range then
		if AutoCarry.Orbwalker:IsAfterAttack() then
			CastQ(QCel)
		end
	end
	if WCel and WCel ~= nil and MenuGraves.harrasConfig.USEW and GetDistance(WCel) < W.range then
		CastW(WCel)
	end
end

function Farm()
	EnemyMinions:update()
	local QMode = MenuGraves.farm.QF
	local WMode = MenuGraves.farm.WF
	for i, minion in pairs(EnemyMinions.objects) do
		if QMode == 2 then
			if minion ~= nil and not minion.dead and GetDistance(minion) < Q.range then
				if minion.health < getDmg("Q", minion, myHero, 3) then
					CastQ(minion)
				end
			end
		elseif QMode == 3 then
			if minion ~= nil and not minion.dead and GetDistance(minion) < Q.range then
				local pos, BestHit = GetBestLineFarmPosition(Q.range, Q.width, EnemyMinions.objects)
				if pos ~= nil then
					CastSpell(_Q, pos.x, pos.z)
				end
			end
		end
		if WMode == 2 then
			if minion ~= nil and not minion.dead and GetDistance(minion) < W.range then
				if minion.health <= getDmg("W", minion, myHero, 3) then
					CastW(minion)
				end
			end
		elseif WMode == 3 then
			if minion ~= nil and not minion.dead and GetDistance(minion) < W.range then
				local pos = BestWFarmPos(W.range, W.width, EnemyMinions.objects)
				if pos ~= nil then
					CastSpell(_W, pos.x, pos.z)
				end
			end
		end
	end
end

function JungleFarm()
	JungleMinions:update()
	for i, minion in pairs(JungleMinions.objects) do
		if MenuGraves.jf.WJF then
			if minion ~= nil and not minion.dead and GetDistance(minion) < W.range then
				local pos = BestWFarmPos(W.range, W.width, JungleMinions.objects)
				if pos ~= nil then
					CastSpell(_W, pos.x, pos.z)
				end
			end
		end
		if MenuGraves.jf.QJF then
			if minion ~= nil and not minion.dead and GetDistance(minion) < Q.range then
				local pos, BestHit = GetBestLineFarmPosition(Q.range, Q.width, JungleMinions.objects)
				if pos ~= nil then
					CastSpell(_Q, pos.x, pos.z)
				end
			end
		end
	end
end

function OnDraw()
	if MenuGraves.drawConfig.DST and MenuGraves.comboConfig.ST then
		if SelectedTarget ~= nil and not SelectedTarget.dead then
			DrawCircle(SelectedTarget.x, SelectedTarget.y, SelectedTarget.z, 100, RGB(MenuGraves.drawConfig.DQRC[2], MenuGraves.drawConfig.DQRC[3], MenuGraves.drawConfig.DQRC[4]))
		end
	end
	if MenuGraves.drawConfig.DAR then			
		DrawCircle(myHero.x, myHero.y, myHero.z, myHero.range+65, RGB(MenuGraves.drawConfig.DARC[2], MenuGraves.drawConfig.DARC[3], MenuGraves.drawConfig.DARC[4]))
	end
	if MenuGraves.drawConfig.DQR and Q.Ready() then			
		DrawCircle(myHero.x, myHero.y, myHero.z, Q.range, RGB(MenuGraves.drawConfig.DQRC[2], MenuGraves.drawConfig.DQRC[3], MenuGraves.drawConfig.DQRC[4]))
	end
	if MenuGraves.drawConfig.DWR and W.Ready() then			
		DrawCircle(myHero.x, myHero.y, myHero.z, W.range, RGB(MenuGraves.drawConfig.DWRC[2], MenuGraves.drawConfig.DWRC[3], MenuGraves.drawConfig.DWRC[4]))
	end
	if MenuGraves.drawConfig.DER and E.Ready() then			
		DrawCircle(myHero.x, myHero.y, myHero.z, E.range, RGB(MenuGraves.drawConfig.DERC[2], MenuGraves.drawConfig.DERC[3], MenuGraves.drawConfig.DERC[4]))
	end
	if MenuGraves.drawConfig.DRR and R.Ready() then			
		DrawCircle(myHero.x, myHero.y, myHero.z, R.range, RGB(MenuGraves.drawConfig.DRRC[2], MenuGraves.drawConfig.DRRC[3], MenuGraves.drawConfig.DRRC[4]))
	end
end

function autolvl()
	if not MenuGraves.prConfig.ALS then return end
	if myHero.level > GetHeroLeveled() then
		local a = {_Q,_E,_W,_Q,_Q,_R,_Q,_E,_Q,_E,_R,_E,_E,_W,_W,_R,_W,_W}
		LevelSpell(a[GetHeroLeveled() + 1])
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

function BestWFarmPos(range, radius, objects)
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

function aa()
	if MenuGraves.comboConfig.CEnabled and ((myHero.mana/myHero.maxMana)*100) >= MenuGraves.comboConfig.manac then
		if QCel and QCel ~= nil and MenuGraves.comboConfig.qConfig.USEQ == 3 and GetDistance(QCel) < Q.range then
			CastQ(QCel)
		end
	end
	if MenuGraves.harrasConfig.HEnabled and ((myHero.mana/myHero.maxMana)*100) >= MenuGraves.harrasConfig.manah then
		if QCel and QCel ~= nil and MenuGraves.harrasConfig.USEQ == 3 and GetDistance(QCel) < Q.range then
			CastQ(QCel)
		end
	end
end

function AutoHeal()
	if ((myHero.health/myHero.maxHealth)*100) < MenuGraves.exConfig.UAHHP then
		HReady = (HealKey ~= nil and myHero:CanUseSpell(HealKey) == READY)
		if HReady then
			CastSpell(HealKey)
		end
	end
end

function CheckBuff(unit)
  if TargetHaveBuff("JudicatorIntervention", unit) then
    return true
  end
  if TargetHaveBuff("Undying Rage", unit) then
    return true
  end
  if TargetHaveBuff("UndyingRage", unit) then
    return true
  end
  if TargetHaveBuff("ZacRebirthReady", unit) then
    return true
  end
  if TargetHaveBuff("AatroxPassiveReady", unit) then
    return true
  end
  if TargetHaveBuff("Chrono Shift", unit) then
    return true
  end
  if TargetHaveBuff("ChronoShift", unit) then
    return true
  end
  return false
end

function CalcDMG(unit)
	local dmg = 0
	if GetDistance(unit) <= myHero.range+120 then
		if MenuGraves.comboConfig.rConfig.USER2 == 1 then
			dmg = dmg + getDmg("AD", unit, myHero) * 2
		elseif MenuGraves.comboConfig.rConfig.USER2 == 2 then
			dmg = dmg + getDmg("AD", unit, myHero) * 5
		elseif MenuGraves.comboConfig.rConfig.USER2 == 3 then
			dmg = dmg + getDmg("AD", unit, myHero) * 9
		end
	end
	dmg = dmg + ((R.Ready() and getDmg("R", unit, myHero, 3)) or 0)
	dmg = dmg + ((Q.Ready() and getDmg("Q", unit, myHero, 3)) or 0)
	dmg = dmg + ((W.Ready() and getDmg("W", unit, myHero)) or 0)
	return dmg
end

function CastR(unit)
	local DMG = CalcDMG(unit)
	if R.Ready() and ValidTarget(unit) and DMG > unit.health and not CheckBuff(unit) then
		if MenuGraves.prConfig.pro == 1 then
			local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(unit, R.delay, R.width, R.range, R.speed, myHero)
			if CastPosition and HitChance >= 2 then
				if VIP_USER and MenuGraves.prConfig.pc then
					Packet("S_CAST", {spellId = _R, fromX = CastPosition.x, fromY = CastPosition.z, toX = CastPosition.x, toY = CastPosition.z}):send()
				else
					CastSpell(_R, CastPosition.x, CastPosition.z)
				end	
			end
		end
		if MenuGraves.prConfig.pro == 2 and VIP_USER and prodstatus then
			local Position, info = Prodiction.GetPrediction(unit, R.range, R.speed, R.delay, R.width, myHero)
			if Position ~= nil then
				if VIP_USER and MenuGraves.prConfig.pc then
					Packet("S_CAST", {spellId = _R, fromX = Position.x, fromY = Position.z, toX = Position.x, toY = Position.z}):send()
				else
					CastSpell(_R, Position.x, Position.z)
				end
			end
		end
		if MenuGraves.prConfig.pro == 3 and VIP_USER then
			local unit = DPTarget(unit)
			local GravesR = LineSS(math.huge, R.range, R.width, 250, math.huge)
			local State, Position, perc = DP:predict(unit, GravesR)
			if State == SkillShot.STATUS.SUCCESS_HIT then 
				if VIP_USER and MenuGraves.prConfig.pc then
					Packet("S_CAST", {spellId = _R, fromX = Position.x, fromY = Position.z, toX = Position.x, toY = Position.z}):send()
				else
					CastSpell(_R, Position.x, Position.z)
				end
			end
		end
	end
end

function CastR2()
	for _, enemy in pairs(GetEnemyHeroes()) do
		if R.Ready() and ValidTarget(enemy, R.range) then
			local rPos, HitChance, maxHit, Positions = VP:GetLineAOECastPosition(enemy, R.delay, R.width, R.range, R.speed, myHero)
			if rPos ~= nil and maxHit >= MenuGraves.comboConfig.rConfig.USERX and HitChance >= 2 then		
				if VIP_USER and MenuLux.prConfig.pc then
					Packet("S_CAST", {spellId = _R, fromX = rPos.x, fromY = rPos.z, toX = rPos.x, toY = rPos.z}):send()
				else
					CastSpell(_R, rPos.x, rPos.z)
				end
			end
		end
	end
end

function CastE(unit)
	if E.Ready() then
		if VIP_USER and MenuGraves.prConfig.pc then
			Packet("S_CAST", {spellId = _E, fromX = unit.x, fromY = unit.z, toX = unit.x, toY = unit.z}):send()
		else
			CastSpell(_E, unit.x, unit.z)
		end
	end
end

function CastW(unit)
	if W.Ready() and ValidTarget(unit) and not CheckBuff(unit) then
		if MenuGraves.prConfig.pro == 1 then
			local CastPosition, HitChance, Position = VP:GetCircularAOECastPosition(unit, W.delay, W.width, W.range, W.speed, myHero)
			if CastPosition and HitChance >= 2  then
				if VIP_USER and MenuGraves.prConfig.pc then
					Packet("S_CAST", {spellId = _W, fromX = CastPosition.x, fromY = CastPosition.z, toX = CastPosition.x, toY = CastPosition.z}):send()
				else
					CastSpell(_W, CastPosition.x, CastPosition.z)
				end	
			end
		end
		if MenuGraves.prConfig.pro == 2 then
			local Position, info = Prodiction.GetPrediction(unit, W.range, W.speed, W.delay, W.width, myHero)
			if Position ~= nil then
				if VIP_USER and MenuGraves.prConfig.pc then
					Packet("S_CAST", {spellId = _W, fromX = Position.x, fromY = Position.z, toX = Position.x, toY = Position.z}):send()
				else
					CastSpell(_W, Position.x, Position.z)
				end
			end
		end
		if MenuGraves.prConfig.pro == 3 and VIP_USER then
			local unit = DPTarget(unit)
			local GravesW = CircleSS(math.huge, W.range, W.width, 250, math.huge)
			local State, Position, perc = DP:predict(unit, GravesW)
			if State == SkillShot.STATUS.SUCCESS_HIT then 
				if VIP_USER and MenuGraves.prConfig.pc then
					Packet("S_CAST", {spellId = _W, fromX = Position.x, fromY = Position.z, toX = Position.x, toY = Position.z}):send()
				else
					CastSpell(_W, Position.x, Position.z)
				end
			end
		end
	end
end

function CastQ(unit)
	if Q.Ready() and ValidTarget(unit) and not CheckBuff(unit) then
		if MenuGraves.prConfig.pro == 1 then
			local CastPosition, HitChance, Position = VP:GetConeAOECastPosition(unit, Q.delay, Q.width, Q.range-20, Q.speed, myHero)
			if CastPosition and HitChance >= 2 then
				if VIP_USER and MenuGraves.prConfig.pc then
					Packet("S_CAST", {spellId = _Q, fromX = CastPosition.x, fromY = CastPosition.z, toX = CastPosition.x, toY = CastPosition.z}):send()
				else
					CastSpell(_Q, CastPosition.x, CastPosition.z)
				end	
			end
		end
		if MenuGraves.prConfig.pro == 2 then
			local Position, info = Prodiction.GetPrediction(unit, Q.range-20, Q.speed, Q.delay, Q.width, myHero)
			if Position ~= nil then
				if VIP_USER and MenuGraves.prConfig.pc then
					Packet("S_CAST", {spellId = _Q, fromX = Position.x, fromY = Position.z, toX = Position.x, toY = Position.z}):send()
				else
					CastSpell(_Q, Position.x, Position.z)
				end
			end
		end
		if MenuGraves.prConfig.pro == 3 and VIP_USER then
			local unit = DPTarget(unit)
			local GravesQ = ConeSS(math.huge, Q.range-20, Q.width, 250, math.huge)
			local State, Position, perc = DP:predict(unit, GravesQ)
			if State == SkillShot.STATUS.SUCCESS_HIT then 
				if VIP_USER and MenuGraves.prConfig.pc then
					Packet("S_CAST", {spellId = _Q, fromX = Position.x, fromY = Position.z, toX = Position.x, toY = Position.z}):send()
				else
					CastSpell(_Q, Position.x, Position.z)
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

function KillSteal()
	for _, Enemy in pairs(GetEnemyHeroes()) do
		local health = Enemy.health
		local qDmg = getDmg("Q", Enemy, myHero)
		local wDmg = getDmg("W", Enemy, myHero)
		local rDmg = getDmg("R", Enemy, myHero, 3)
		if Enemy ~= nil and Enemy.team ~= player.team and not Enemy.dead and Enemy.visible and GetDistance(Enemy) < 2000 then
			if health < qDmg and MenuGraves.ksConfig.QKS and GetDistance(Enemy) < Q.range then
				CastQ(Enemy)
			elseif health < wDmg and MenuGraves.ksConfig.WKS and GetDistance(Enemy) < W.range then
				CastW(Enemy)
			elseif health < rDmg and MenuGraves.ksConfig.RKS and GetDistance(Enemy) < R.range then
				CastR(Enemy)
			end
		end
	end
end

function OnProcessSpell(unit, spell)
	if unit and spell and unit.isMe and spell.name == "GravesBasicAttack" then
		if MenuGraves.comboConfig.CEnabled and MenuGraves.comboConfig.wConfig.USEW == 4 and WCel and ValidTarget(WCel, myHero.range+65) then
			CastW(WCel)
		end
	end
	if MenuGraves.exConfig.ED then
		if unit and unit.team ~= myHero.team and not myHero.dead and unit.type == myHero.type and spell then
		    shottype,radius,maxdistance = 0,0,0
		    if unit.type == "obj_AI_Hero" then
			    spelltype, casttype = getSpellType(unit, spell.name)
			    if casttype == 4 or casttype == 5 or casttype == 6 then return end
			    if (spelltype == "Q" or spelltype == "W" or spelltype == "E" or spelltype == "R") and DodgeTable[spell.name] then
				    shottype = skillData[unit.charName][spelltype]["type"]
				    radius = skillData[unit.charName][spelltype]["radius"]
				    maxdistance = skillData[unit.charName][spelltype]["maxdistance"]
			    end
		    end
			if not myHero.dead and myHero.health > 0 then
				local hb = myHero.boundingRadius
				hitchampion = false
				if shottype == 0 then 
					hitchampion = spell.target and spell.target.networkID == myHero.networkID
				elseif shottype == 1 then 
					hitchampion = checkhitlinepass(unit, spell.endPos, radius, maxdistance, myHero, hb)
				elseif shottype == 2 then 
					hitchampion = checkhitlinepoint(unit, spell.endPos, radius, maxdistance, myHero, hb)
				elseif shottype == 3 then 
					hitchampion = checkhitaoe(unit, spell.endPos, radius, maxdistance, myHero, hb)
				elseif shottype == 4 then 
					hitchampion = checkhitcone(unit, spell.endPos, radius, maxdistance, myHero, hb)
				elseif shottype == 5 then 
					hitchampion = checkhitwall(unit, spell.endPos, radius, maxdistance, myHero, hb)
				elseif shottype == 6 then 
					hitchampion = checkhitlinepass(unit, spell.endPos, radius, maxdistance, myHero, hb) or checkhitlinepass(unit, Vector(unit)*2-spell.endPos, radius, maxdistance, tar, hb)
				elseif shottype == 7 then 
					hitchampion = checkhitcone(spell.endPos, unit, radius, maxdistance, myHero, hb)
				end
				if hitchampion and E.Ready() and MenuGraves.exConfig.dspells[spell.name] then
					CastE(mousePos)
				end
			end
		end
	end
end

function OnWndMsg(Msg, Key)
	if Msg == WM_LBUTTONDOWN and MenuGraves.comboConfig.ST then
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
				if MenuGraves.comboConfig.ST then 
					print("Target unselected: "..Selecttarget.charName) 
				end
			else
				SelectedTarget = Selecttarget
				if MenuGraves.comboConfig.ST then 
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

-----SCRIPT STATUS------------
assert(load(Base64Decode("G0x1YVIAAQQEBAgAGZMNChoKAAAAAAAAAAAAAQIKAAAABgBAAEFAAAAdQAABBkBAAGUAAAAKQACBBkBAAGVAAAAKQICBHwCAAAQAAAAEBgAAAGNsYXNzAAQNAAAAU2NyaXB0U3RhdHVzAAQHAAAAX19pbml0AAQLAAAAU2VuZFVwZGF0ZQACAAAAAgAAAAgAAAACAAotAAAAhkBAAMaAQAAGwUAABwFBAkFBAQAdgQABRsFAAEcBwQKBgQEAXYEAAYbBQACHAUEDwcEBAJ2BAAHGwUAAxwHBAwECAgDdgQABBsJAAAcCQQRBQgIAHYIAARYBAgLdAAABnYAAAAqAAIAKQACFhgBDAMHAAgCdgAABCoCAhQqAw4aGAEQAx8BCAMfAwwHdAIAAnYAAAAqAgIeMQEQAAYEEAJ1AgAGGwEQA5QAAAJ1AAAEfAIAAFAAAAAQFAAAAaHdpZAAEDQAAAEJhc2U2NEVuY29kZQAECQAAAHRvc3RyaW5nAAQDAAAAb3MABAcAAABnZXRlbnYABBUAAABQUk9DRVNTT1JfSURFTlRJRklFUgAECQAAAFVTRVJOQU1FAAQNAAAAQ09NUFVURVJOQU1FAAQQAAAAUFJPQ0VTU09SX0xFVkVMAAQTAAAAUFJPQ0VTU09SX1JFVklTSU9OAAQEAAAAS2V5AAQHAAAAc29ja2V0AAQIAAAAcmVxdWlyZQAECgAAAGdhbWVTdGF0ZQAABAQAAAB0Y3AABAcAAABhc3NlcnQABAsAAABTZW5kVXBkYXRlAAMAAAAAAADwPwQUAAAAQWRkQnVnc3BsYXRDYWxsYmFjawABAAAACAAAAAgAAAAAAAMFAAAABQAAAAwAQACBQAAAHUCAAR8AgAACAAAABAsAAABTZW5kVXBkYXRlAAMAAAAAAAAAQAAAAAABAAAAAQAQAAAAQG9iZnVzY2F0ZWQubHVhAAUAAAAIAAAACAAAAAgAAAAIAAAACAAAAAAAAAABAAAABQAAAHNlbGYAAQAAAAAAEAAAAEBvYmZ1c2NhdGVkLmx1YQAtAAAAAwAAAAMAAAAEAAAABAAAAAQAAAAEAAAABAAAAAQAAAAEAAAABAAAAAUAAAAFAAAABQAAAAUAAAAFAAAABQAAAAUAAAAFAAAABgAAAAYAAAAGAAAABgAAAAUAAAADAAAAAwAAAAYAAAAGAAAABgAAAAYAAAAGAAAABgAAAAYAAAAHAAAABwAAAAcAAAAHAAAABwAAAAcAAAAHAAAABwAAAAcAAAAIAAAACAAAAAgAAAAIAAAAAgAAAAUAAABzZWxmAAAAAAAtAAAAAgAAAGEAAAAAAC0AAAABAAAABQAAAF9FTlYACQAAAA4AAAACAA0XAAAAhwBAAIxAQAEBgQAAQcEAAJ1AAAKHAEAAjABBAQFBAQBHgUEAgcEBAMcBQgABwgEAQAKAAIHCAQDGQkIAx4LCBQHDAgAWAQMCnUCAAYcAQACMAEMBnUAAAR8AgAANAAAABAQAAAB0Y3AABAgAAABjb25uZWN0AAQRAAAAc2NyaXB0c3RhdHVzLm5ldAADAAAAAAAAVEAEBQAAAHNlbmQABAsAAABHRVQgL3N5bmMtAAQEAAAAS2V5AAQCAAAALQAEBQAAAGh3aWQABAcAAABteUhlcm8ABAkAAABjaGFyTmFtZQAEJgAAACBIVFRQLzEuMA0KSG9zdDogc2NyaXB0c3RhdHVzLm5ldA0KDQoABAYAAABjbG9zZQAAAAAAAQAAAAAAEAAAAEBvYmZ1c2NhdGVkLmx1YQAXAAAACgAAAAoAAAAKAAAACgAAAAoAAAALAAAACwAAAAsAAAALAAAADAAAAAwAAAANAAAADQAAAA0AAAAOAAAADgAAAA4AAAAOAAAACwAAAA4AAAAOAAAADgAAAA4AAAACAAAABQAAAHNlbGYAAAAAABcAAAACAAAAYQAAAAAAFwAAAAEAAAAFAAAAX0VOVgABAAAAAQAQAAAAQG9iZnVzY2F0ZWQubHVhAAoAAAABAAAAAQAAAAEAAAACAAAACAAAAAIAAAAJAAAADgAAAAkAAAAOAAAAAAAAAAEAAAAFAAAAX0VOVgA="), nil, "bt", _ENV))() ScriptStatus("SFIGJFHGFIM") 
