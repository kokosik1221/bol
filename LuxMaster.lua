--[[

	Script Name: LUX MASTER 
    	Author: kokosik1221
	Last Version: 0.62
	22.03.2015
	
]]--


if myHero.charName ~= "Lux" then return end

_G.AUTOUPDATE = true


local version = "0.62"
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/kokosik1221/bol/master/LuxMaster.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH..GetCurrentEnv().FILE_NAME
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH
function AutoupdaterMsg(msg) print("<font color=\"#FF0000\"><b>LuxMaster:</b></font> <font color=\"#FFFFFF\">"..msg..".</font>") end
if _G.AUTOUPDATE then
	local ServerData = GetWebResult(UPDATE_HOST, "/kokosik1221/bol/master/LuxMaster.version")
	if ServerData then
		ServerVersion = type(tonumber(ServerData)) == "number" and tonumber(ServerData) or nil
		if ServerVersion then
			if tonumber(version) < ServerVersion then
				AutoupdaterMsg("New version available "..ServerVersion)
				AutoupdaterMsg("Updating, please don't press F9")
				DelayAction(function() DownloadFile(UPDATE_URL, UPDATE_FILE_PATH, function () AutoupdaterMsg("Successfully updated. ("..version.." => "..ServerVersion.."), press F9 twice to load the updated version.") end) end, 3)
			else
				AutoupdaterMsg("You have got the latest version ("..ServerVersion..")")
			end
		end
	else
		AutoupdaterMsg("Error downloading version info")
	end
end
local REQUIRED_LIBS = {
	["vPrediction"] = "https://raw.githubusercontent.com/Ralphlol/BoLGit/master/VPrediction.lua",
	["Prodiction"] = "https://bitbucket.org/Klokje/public-klokjes-bol-scripts/raw/ec830facccefb3b52212dba5696c08697c3c2854/Test/Prodiction/Prodiction.lua",
	["SxOrbWalk"] = "https://raw.githubusercontent.com/Superx321/BoL/master/common/SxOrbWalk.lua",
	["DivinePred"] = ""
}
local DOWNLOADING_LIBS, DOWNLOAD_COUNT = false, 0
function AfterDownload()
	DOWNLOAD_COUNT = DOWNLOAD_COUNT - 1
	if DOWNLOAD_COUNT == 0 then
		DOWNLOADING_LIBS = false
		print("<b><font color=\"#FF0000\">Required libraries downloaded successfully, please reload (double F9).</font>")
	end
end
for DOWNLOAD_LIB_NAME, DOWNLOAD_LIB_URL in pairs(REQUIRED_LIBS) do
	if FileExist(LIB_PATH .. DOWNLOAD_LIB_NAME .. ".lua") then
		if DOWNLOAD_LIB_NAME ~= "Prodiction" then 
			require(DOWNLOAD_LIB_NAME) 
		end
		if DOWNLOAD_LIB_NAME == "Prodiction" and VIP_USER then 
			require(DOWNLOAD_LIB_NAME) 
			prodstatus = true 
		end
		if DOWNLOAD_LIB_NAME == "DivinePred" and VIP_USER then 
			require(DOWNLOAD_LIB_NAME) 
		end
	else
		DOWNLOADING_LIBS = true
		DOWNLOAD_COUNT = DOWNLOAD_COUNT + 1
		DownloadFile(DOWNLOAD_LIB_URL, LIB_PATH .. DOWNLOAD_LIB_NAME..".lua", AfterDownload)
	end
end

local Items = {
	BWC = { id = 3144, range = 400, reqTarget = true, slot = nil },
	DFG = { id = 3128, range = 750, reqTarget = true, slot = nil },
	HGB = { id = 3146, range = 400, reqTarget = true, slot = nil },
	BFT = { id = 3188, range = 750, reqTarget = true, slot = nil },
}

local GapCloserList = {
	{charName = "Aatrox", spellName = "AatroxQ"},
	{charName = "Akali", spellName = "AkaliShadowDance"},
	{charName = "Alistar", spellName = "Headbutt"},
	{charName = "Fiora", spellName = "FioraQ"},
	{charName = "Diana", spellName = "DianaTeleport"},
	{charName = "Elise", spellName = "EliseSpiderQCast"},
	{charName = "Fizz", spellName = "FizzPiercingStrike"},
	{charName = "Gragas", spellName = "GragasE"},
	{charName = "Hecarim", spellName = "HecarimUlt"},
	{charName = "JarvanIV", spellName = "JarvanIVDragonStrike"},
	{charName = "Irelia", spellName = "IreliaGatotsu"},
	{charName = "Jax", spellName = "JaxLeapStrike"},
	{charName = "Khazix", spellName = "KhazixE"},
	{charName = "Khazix", spellName = "khazixelong"},
	{charName = "LeBlanc", spellName = "LeblancSlide"},
	{charName = "LeBlanc", spellName = "LeblancSlideM"},
	{charName = "LeeSin", spellName = "BlindMonkQTwo"},
	{charName = "Leona", spellName = "LeonaZenithBlade"},
	{charName = "Malphite", spellName = "UFSlash"},
	{charName = "Pantheon", spellName = "Pantheon_LeapBash"},
	{charName = "Poppy", spellName = "PoppyHeroicCharge"},
	{charName = "Renekton", spellName = "RenektonSliceAndDice"},
	{charName = "Riven", spellName = "RivenTriCleave"},
	{charName = "Sejuani", spellName = "SejuaniArcticAssault"},
	{charName = "Tryndamere", spellName = "slashCast"},
	{charName = "Vi", spellName = "ViQ"},
	{charName = "MonkeyKing", spellName = "MonkeyKingNimbus"},
	{charName = "XinZhao", spellName = "XenZhaoSweep"},
	{charName = "Yasuo", spellName = "YasuoDashWrapper"},
}

local Q = {name = "Light Binding", range = 1150, speed = 1200, delay = 0.25, width = 80, Ready = function() return myHero:CanUseSpell(_Q) == READY end}
local W = {name = "Prismatic Barrier", range = 1175, speed = 1200, delay = 0.25, width = 140, Ready = function() return myHero:CanUseSpell(_W) == READY end}
local E = {name = "Lucent Singularity", range = 1100, speed = 1300, delay = 0.25, width = 275, Ready = function() return myHero:CanUseSpell(_E) == READY end}
local R = {name = "Final Spark", range = 3340, speed = math.huge, delay = 1, width = 190, Ready = function() return myHero:CanUseSpell(_R) == READY end}
local IReady, zhonyaready, recall = false, false, false
local EnemyMinions = minionManager(MINION_ENEMY, Q.range, myHero, MINION_SORT_MAXHEALTH_DEC)
local JungleMinions = minionManager(MINION_JUNGLE, Q.range, myHero, MINION_SORT_MAXHEALTH_DEC)
local KSMinions = minionManager(MINION_JUNGLE, R.range, myHero, MINION_SORT_HEALTH_ASC)
local QTargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, Q.range, DAMAGE_MAGIC)
local ETargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, E.range, DAMAGE_MAGIC)
local RTargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, R.range, DAMAGE_MAGIC)
local IgniteKey, zhonyaslot = nil, nil
local killstring = {}
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
	Menu()
	print("<b><font color=\"#6699FF\">Lux Master:</font></b> <font color=\"#FFFFFF\">Good luck and give me feedback!</font>")
	if _G.MMA_Loaded then
		print("<b><font color=\"#6699FF\">Lux Master:</font></b> <font color=\"#FFFFFF\">MMA Support Loaded.</font>")
	end	
	if _G.AutoCarry then
		print("<b><font color=\"#6699FF\">Lux Master:</font></b> <font color=\"#FFFFFF\">SAC Support Loaded.</font>")
	end
end

function OnTick()
	Check()
	if MenuLux.comboConfig.CEnabled and myHero.mana >= MenuLux.comboConfig.manac and not recall then
		caa()
		Combo()
	end
	if (MenuLux.harrasConfig.HEnabled or MenuLux.harrasConfig.HTEnabled) and myHero.mana >= MenuLux.harrasConfig.manah and not recall then
		Harrass()
	end
	if MenuLux.farm.LaneClear and myHero.mana >= MenuLux.farm.manaf and not recall then
		Farm()
	end
	if MenuLux.jf.JFEnabled and myHero.mana >= MenuLux.jf.manajf and not recall then
		JungleFarm()
	end
	if MenuLux.prConfig.AZ and not recall then
		autozh()
	end
	if MenuLux.prConfig.ALS and not recall then
		autolvl()
	end
	if MenuLux.comboConfig.rConfig.CRKD and RCel and not recall then
		CastR(RCel)
	end
	if not recall then
		KSandAUTO()
		StealJungle()	
	end
end

function Menu()
	if VIP_USER then
		DP = DivinePred()
	end
	VP = VPrediction()
	MenuLux = scriptConfig("Lux Master "..version, "Lux Master "..version)
	MenuLux:addParam("orb", "Orbwalker:", SCRIPT_PARAM_LIST, 1, {"SxOrb","SAC:R/MMA"}) 
	MenuLux:addParam("qqq", "If You Change Orb. Click 2x F9", SCRIPT_PARAM_INFO,"")
	if MenuLux.orb == 1 then
		MenuLux:addSubMenu("[Lux Master]: Orbwalking", "Orbwalking")
		SxOrb:LoadToMenu(MenuLux.Orbwalking)
	end
	TargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, myHero.range+65, DAMAGE_MAGIC)
	TargetSelector.name = "Lux"
	MenuLux:addTS(TargetSelector)
	MenuLux:addSubMenu("[Lux Master]: Combo Settings", "comboConfig")
	MenuLux.comboConfig:addSubMenu("[Lux Master]: Q Settings", "qConfig")
	MenuLux.comboConfig.qConfig:addParam("USEQ", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	MenuLux.comboConfig.qConfig:addParam("USEQ2", "Cast If See 1 Collision", SCRIPT_PARAM_ONOFF, false)
	MenuLux.comboConfig:addSubMenu("[Lux Master]: W Settings", "wConfig")
	MenuLux.comboConfig.wConfig:addParam("USEW", "Use " .. W.name .. " (W)", SCRIPT_PARAM_ONOFF, false)
	MenuLux.comboConfig:addSubMenu("[Lux Master]: E Settings", "eConfig")
	MenuLux.comboConfig.eConfig:addParam("USEE", "Use " .. E.name .. " (E)", SCRIPT_PARAM_ONOFF, true)
	MenuLux.comboConfig:addSubMenu("[Lux Master]: R Settings", "rConfig")
	MenuLux.comboConfig.rConfig:addParam("USER", "Use " .. R.name .. " (R)", SCRIPT_PARAM_ONOFF, true)
	MenuLux.comboConfig.rConfig:addParam("RM", "Cast (R) Mode", SCRIPT_PARAM_LIST, 2, {"Normal", "Killable", "Hit X", "Stun", "Stun&Killable"})
	MenuLux.comboConfig.rConfig:addParam('USERX', 'X = ', SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
	MenuLux.comboConfig.rConfig:addParam("CRKD", "Cast (R) Key Down", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("T"))
	MenuLux.comboConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuLux.comboConfig:addParam("uaa", "Use AA in Combo", SCRIPT_PARAM_ONOFF, true)
	MenuLux.comboConfig:addParam("ST", "Focus Selected Target", SCRIPT_PARAM_ONOFF, false)
	MenuLux.comboConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuLux.comboConfig:addParam("CEnabled", "Full Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	MenuLux.comboConfig:addParam("manac", "Min. Mana To Cast Combo", SCRIPT_PARAM_SLICE, 10, 0, 100, 0)
	MenuLux:addSubMenu("[Lux Master]: Harras Settings", "harrasConfig")
	MenuLux.harrasConfig:addParam("HM", "Harrass Mode:", SCRIPT_PARAM_LIST, 1, {"|Q|", "|E|"}) 
	MenuLux.harrasConfig:addParam("HEnabled", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
	MenuLux.harrasConfig:addParam("HTEnabled", "Harass Toggle", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("L"))
	MenuLux.harrasConfig:addParam("manah", "Min. Mana To Harass", SCRIPT_PARAM_SLICE, 60, 0, 100, 0)
	MenuLux:addSubMenu("[Lux Master]: Extra Settings", "exConfig")
	MenuLux.exConfig:addSubMenu("Shield Ally Use On", "uso")
	for i = 1, heroManager.iCount do
		local hero = heroManager:GetHero(i)
		if hero.team == myHero.team then
			MenuLux.exConfig.uso:addParam(hero.charName, hero.charName, SCRIPT_PARAM_ONOFF, true)
		end
	end
	MenuLux.exConfig:addParam("UAS", "Use Auto Shield", SCRIPT_PARAM_ONOFF, true)
	MenuLux.exConfig:addParam("UASA", "Use Auto Shield To Ally", SCRIPT_PARAM_ONOFF, false)
	MenuLux.exConfig:addParam("ASHP", "Min. HP To Cast Shield", SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
	MenuLux.exConfig:addParam("ASMP", "Min. MP To Cast Shield", SCRIPT_PARAM_SLICE, 50, 0, 100, 0)
	MenuLux.exConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuLux.exConfig:addParam("ARF", "Auto (R) If Can Hit X", SCRIPT_PARAM_ONOFF, true)
	MenuLux.exConfig:addParam("ARX", "X = ", SCRIPT_PARAM_SLICE, 4, 1, 5, 0)
	MenuLux.exConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuLux.exConfig:addParam("AEF", "Auto (E) If Can Hit X", SCRIPT_PARAM_ONOFF, true)
	MenuLux.exConfig:addParam("AEX", "X = ", SCRIPT_PARAM_SLICE, 4, 1, 5, 0)
	MenuLux:addSubMenu("[Lux Master]: Jungle Steal Settings", "jsConfig")
	MenuLux.jsConfig:addParam("JSB", "Steal Baron With (R)", SCRIPT_PARAM_ONOFF, true)
	MenuLux.jsConfig:addParam("JSD", "Steal Dragon With (R)", SCRIPT_PARAM_ONOFF, true)
	MenuLux.jsConfig:addParam("JSBL", "Steal Blue With (R)", SCRIPT_PARAM_ONOFF, true)
	MenuLux.jsConfig:addParam("JSR", "Steal Red With (R)", SCRIPT_PARAM_ONOFF, true)
	MenuLux.jsConfig:addParam("JST", "Steal Team:", SCRIPT_PARAM_LIST, 1, { "Enemy", "My Team", "Both"})
	MenuLux:addSubMenu("[Lux Master]: GapCloser Settings", "gpConfig")
	MenuLux.gpConfig:addSubMenu("GapCloser Spells", "ES2")
	for i, enemy in ipairs(GetEnemyHeroes()) do
		for _, champ in pairs(GapCloserList) do
			if enemy.charName == champ.charName then
				MenuLux.gpConfig.ES2:addParam(champ.spellName, "GapCloser "..champ.charName.." "..champ.spellName, SCRIPT_PARAM_ONOFF, true)
			end
		end
	end
	MenuLux.gpConfig:addParam("UG", "Use GapCloser (Q)", SCRIPT_PARAM_ONOFF, true)
	MenuLux:addSubMenu("[Lux Master]: KS Settings", "ksConfig")
	MenuLux.ksConfig:addParam("IKS", "Use Ignite To KS", SCRIPT_PARAM_ONOFF, true)
	MenuLux.ksConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuLux.ksConfig:addParam("QKS", "Use " .. Q.name .. "(Q)", SCRIPT_PARAM_ONOFF, true)
	MenuLux.ksConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuLux.ksConfig:addParam("EKS", "Use " .. E.name .. "(E)", SCRIPT_PARAM_ONOFF, true)
	MenuLux.ksConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuLux.ksConfig:addParam("RKS", "Use " .. R.name .. "(R)", SCRIPT_PARAM_ONOFF, false)
	MenuLux:addSubMenu("[Lux Master]: Farm Settings", "farm")
	MenuLux.farm:addParam("QF", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_LIST, 2, { "No", "Freezing", "LaneClear"})
	MenuLux.farm:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuLux.farm:addParam("EF", "Use " .. E.name .. " (E)", SCRIPT_PARAM_LIST, 3, { "No", "Freezing", "LaneClear"})
	MenuLux.farm:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuLux.farm:addParam("LaneClear", "Farm ", SCRIPT_PARAM_ONKEYDOWN, false,   string.byte("V"))
	MenuLux.farm:addParam("manaf", "Min. Mana To Farm", SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
	MenuLux:addSubMenu("[Lux Master]: Jungle Farm Settings", "jf")
	MenuLux.jf:addParam("QJF", "Use " .. Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	MenuLux.jf:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuLux.jf:addParam("EJF", "Use " .. E.name .. " (E)", SCRIPT_PARAM_ONOFF, true)
	MenuLux.jf:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuLux.jf:addParam("JFEnabled", "Jungle Farm", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("V"))
	MenuLux.jf:addParam("manajf", "Min. Mana To Jungle Farm", SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
	MenuLux:addSubMenu("[Lux Master]: Draw Settings", "drawConfig")
	MenuLux.drawConfig:addParam("DLC", "Use Lag-Free Circles", SCRIPT_PARAM_ONOFF, true)
	MenuLux.drawConfig:addParam("DD", "Draw DMG Text", SCRIPT_PARAM_ONOFF, true)
	MenuLux.drawConfig:addParam("DST", "Draw Selected Target", SCRIPT_PARAM_ONOFF, true)
	MenuLux.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuLux.drawConfig:addParam("DQR", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
	MenuLux.drawConfig:addParam("DQRC", "Draw Q Range Color", SCRIPT_PARAM_COLOR, {255,0,0,255})
	MenuLux.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuLux.drawConfig:addParam("DWR", "Draw W Range", SCRIPT_PARAM_ONOFF, true)
	MenuLux.drawConfig:addParam("DWRC", "Draw W Range Color", SCRIPT_PARAM_COLOR, {255,0,0,255})
	MenuLux.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuLux.drawConfig:addParam("DER", "Draw E Range", SCRIPT_PARAM_ONOFF, true)
	MenuLux.drawConfig:addParam("DERC", "Draw E Range Color", SCRIPT_PARAM_COLOR, {255,0,200,0})
	MenuLux.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuLux.drawConfig:addParam("DRR", "Draw R Range MiniMap", SCRIPT_PARAM_ONOFF, true)
	MenuLux:addSubMenu("[Lux Master]: Misc Settings", "prConfig")
	MenuLux.prConfig:addParam("pc", "Use Packets To Cast Spells(VIP)", SCRIPT_PARAM_ONOFF, false)
	MenuLux.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuLux.prConfig:addParam("AZ", "Use Auto Zhonya", SCRIPT_PARAM_ONOFF, true)
	MenuLux.prConfig:addParam("AZHP", "Min HP To Cast Zhonya", SCRIPT_PARAM_SLICE, 20, 0, 100, 0)
	MenuLux.prConfig:addParam("AZMR", "Must Have 0 Enemy In Range:", SCRIPT_PARAM_SLICE, 900, 0, 1500, 0)
	MenuLux.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuLux.prConfig:addParam("ALS", "Auto lvl skills", SCRIPT_PARAM_ONOFF, false)
	MenuLux.prConfig:addParam("AL", "Auto lvl sequence", SCRIPT_PARAM_LIST, 1, { "MID","SUPP" })
	MenuLux.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuLux.prConfig:addParam("pro", "Prodiction To Use:", SCRIPT_PARAM_LIST, 1, {"VPrediction","Prodiction","DivinePred"}) 
	MenuLux.comboConfig:permaShow("CEnabled")
	MenuLux.harrasConfig:permaShow("HEnabled")
	MenuLux.harrasConfig:permaShow("HTEnabled")
	MenuLux.prConfig:permaShow("AZ")
	if myHero:GetSpellData(SUMMONER_1).name:find("summonerdot") then IgniteKey = SUMMONER_1
		elseif myHero:GetSpellData(SUMMONER_2).name:find("summonerdot") then IgniteKey = SUMMONER_2
	end
	_G.oldDrawCircle = rawget(_G, 'DrawCircle')
	_G.DrawCircle = DrawCircle2
	if heroManager.iCount < 10 then
		print("<font color=\"#FFFFFF\">Too few champions to arrange priority.</font>")
	elseif heroManager.iCount == 6 then
		arrangePrioritysTT()
    else
		arrangePrioritys()
	end
end

function caa()
	if MenuLux.orb == 1 then
		if MenuLux.comboConfig.uaa then
			SxOrb:EnableAttacks()
		elseif not MenuLux.comboConfig.uaa then
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

function Check()
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
	if MenuLux.orb == 1 then
		SxOrb:ForceTarget(Cel)
	end
	if MenuLux.drawConfig.DLC then 
		_G.DrawCircle = DrawCircle2 
	else 
		_G.DrawCircle = _G.oldDrawCircle 
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
	if Cel ~= nil then
		UseItems(Cel)
		if MenuLux.comboConfig.wConfig.USEW then
			CastW(myHero)
		end
	end
	if QCel ~= nil then
		if MenuLux.comboConfig.qConfig.USEQ and not MenuLux.comboConfig.qConfig.USEQ2 and GetDistance(QCel) < Q.range then
			CastQ(QCel)
		elseif MenuLux.comboConfig.qConfig.USEQ and MenuLux.comboConfig.qConfig.USEQ2 and GetDistance(QCel) < Q.range then
			CastQ2(QCel)
		end
	end
	if ECel ~= nil then
		if MenuLux.comboConfig.eConfig.USEE and GetDistance(ECel) < E.range then
			CastE(ECel)
		end
	end
	if RCel ~= nil then
		if MenuLux.comboConfig.rConfig.USER and R.Ready() and GetDistance(RCel) <= R.range and ValidTarget(RCel) then
			if MenuLux.comboConfig.rConfig.RM == 1 then
				CastR(RCel)
			end
			if MenuLux.comboConfig.rConfig.RM == 2 then
				local r = getDmg("R", RCel, myHero, 1)
				if RCel.health < r then
					CastR(RCel)
				end
			end
			if MenuLux.comboConfig.rConfig.RM == 3 then
				for _, enemy in pairs(GetEnemyHeroes()) do
					local rPos, HitChance, maxHit, Positions = VP:GetLineAOECastPosition(enemy, R.delay, R.width, R.range, R.speed, myHero)
					if ValidTarget(enemy) and rPos ~= nil and maxHit >= MenuLux.comboConfig.rConfig.USERX and HitChance >=2 then		
						if VIP_USER and MenuLux.prConfig.pc then
							Packet("S_CAST", {spellId = _R, fromX = rPos.x, fromY = rPos.z, toX = rPos.x, toY = rPos.z}):send()
						else
							CastSpell(_R, rPos.x, rPos.z)
						end	
					end
				end
			end
			if MenuLux.comboConfig.rConfig.RM == 4 then
				if RCel.canMove == false then
					CastR(RCel)
				end
			end
			if MenuLux.comboConfig.rConfig.RM == 5 then
				local r = getDmg("R", RCel, myHero, 1)
				if RCel.health < r and RCel.canMove == false then
					CastR(RCel)
				end
			end
		end
	end
end

function Harrass()
	if QCel ~= nil then
		if MenuLux.harrasConfig.HM == 1 and GetDistance(QCel) < Q.range then
			CastQ(QCel)
		elseif MenuLux.harrasConfig.HM == 1 and GetDistance(QCel) < Q.range and MenuLux.comboConfig.qConfig.USEQ2 then
			CastQ2(QCel)
		end
	end
	if ECel ~= nil and MenuLux.harrasConfig.HM == 2 and GetDistance(ECel) < E.range then
		CastE(ECel)
	end
end

function Farm()
	EnemyMinions:update()
	QMode =  MenuLux.farm.QF
	EMode =  MenuLux.farm.EF
	for i, minion in pairs(EnemyMinions.objects) do
		if QMode == 3 then
			if minion ~= nil and not minion.dead then
				CastQ(minion)
			end
		elseif QMode == 2 then
			if minion ~= nil and not minion.dead then
				if minion.health <= getDmg("Q", minion, myHero, 1) then
					CastQ(minion)
				end
			end
		end
		if EMode == 3 then
			local Pos, Hit = BestEFarmPos(E.range, E.width, EnemyMinions.objects)
			if Pos ~= nil then
				CastSpell(_E, Pos.x, Pos.z)
			end
			CastSpell(_E)
		elseif EMode == 2 then
			if minion ~= nil and not minion.dead then
				if minion.health <= getDmg("E", minion, myHero, 1) then
					CastE(minion)
					CastSpell(_E)
				end
			end
		end
	end
end

function JungleFarm()
	JungleMinions:update()
	for i, minion in pairs(JungleMinions.objects) do
		if MenuLux.jf.EJF then
			local Pos, Hit = BestEFarmPos(E.range, E.width, EnemyMinions.objects)
			if Pos ~= nil then
				CastSpell(_E, Pos.x, Pos.z)
			end
			CastSpell(_E)
		end
		if MenuLux.jf.QJF then
			if minion ~= nil and not minion.dead then
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

function autozh()
	local count = EnemyCount(myHero, MenuLux.prConfig.AZMR)
	zhonyaslot = GetInventorySlotItem(3157)
	zhonyaready = (zhonyaslot ~= nil and myHero:CanUseSpell(zhonyaslot) == READY)
	if zhonyaready and ((myHero.health/myHero.maxHealth)*100) < MenuLux.prConfig.AZHP and count == 0 then
		CastSpell(zhonyaslot)
	end
end

function autolvl()
	if not MenuLux.prConfig.ALS then return end
	if myHero.level > GetHeroLeveled() then
		local a = {}
		if MenuLux.prConfig.AL == 1 then			
			a = {_Q,_E,_W,_E,_E,_R,_E,_Q,_E,_Q,_R,_Q,_Q,_W,_W,_R,_W,_W}
		else
			a = {_Q,_E,_W,_W,_W,_R,_W,_Q,_W,_Q,_R,_Q,_Q,_E,_E,_R,_E,_E}
		end
		LevelSpell(a[GetHeroLeveled() + 1])
	end
end

function OnDraw()
	if MenuLux.drawConfig.DST and MenuLux.comboConfig.ST then
		if SelectedTarget ~= nil and not SelectedTarget.dead then
			DrawCircle(SelectedTarget.x, SelectedTarget.y, SelectedTarget.z, 100, RGB(MenuLux.drawConfig.DQRC[2], MenuLux.drawConfig.DQRC[3], MenuLux.drawConfig.DQRC[4]))
		end
	end
	if MenuLux.drawConfig.DD then
		DmgCalc()
		for _,enemy in pairs(GetEnemyHeroes()) do
            if ValidTarget(enemy) and killstring[enemy.networkID] ~= nil then
                local pos = WorldToScreen(D3DXVECTOR3(enemy.x, enemy.y, enemy.z))
                DrawText(killstring[enemy.networkID], 20, pos.x - 35, pos.y - 10, 0xFFFFFF00)
            end
        end
	end
	if MenuLux.drawConfig.DQR and Q.Ready() then			
		DrawCircle(myHero.x, myHero.y, myHero.z, Q.range, RGB(MenuLux.drawConfig.DQRC[2], MenuLux.drawConfig.DQRC[3], MenuLux.drawConfig.DQRC[4]))
	end
	if MenuLux.drawConfig.DWR and W.Ready() then			
		DrawCircle(myHero.x, myHero.y, myHero.z, W.range, RGB(MenuLux.drawConfig.DWRC[2], MenuLux.drawConfig.DWRC[3], MenuLux.drawConfig.DWRC[4]))
	end
	if MenuLux.drawConfig.DER and E.Ready() then			
		DrawCircle(myHero.x, myHero.y, myHero.z, E.range, RGB(MenuLux.drawConfig.DERC[2], MenuLux.drawConfig.DERC[3], MenuLux.drawConfig.DERC[4]))
	end
	if MenuLux.drawConfig.DRR then			
		DrawCircleMinimap(myHero.x, myHero.y, myHero.z, R.range)
	end
end

function StealJungle()
	KSMinions:update()
		if MenuLux.jsConfig.JSR then
			for i, minion in pairs(KSMinions.objects) do
				if MenuLux.jsConfig.JST == 3 then
					if minion.name == "SRU_Red4.1.1" or minion.name == "SRU_Red10.1.1" then
						red = minion
					end
				elseif MenuLux.jsConfig.JST == 2 then
					if myHero.team == 100 and minion.name == "SRU_Red4.1.1" then
						red = minion
					elseif myHero.team == 200 and minion.name == "SRU_Red10.1.1" then
						red = minion
					end
				elseif MenuLux.jsConfig.JST == 1 then
					if myHero.team == 100 and minion.name == "SRU_Red10.1.1" then
						red = minion
					elseif myHero.team == 200 and minion.name == "SRU_Red4.1.1" then
						red = minion
					end
				end
			end
			if ValidTarget(red) then
				if red.health < getDmg("R", red, myHero, 1) and GetDistance(red) < R.range then
					CastSpell(_R, red.x, red.z)
				end
			end
		end
		if MenuLux.jsConfig.JSBL then
			for i, minion in pairs(KSMinions.objects) do
				if MenuLux.jsConfig.JST == 3 then
					if minion.name == "SRU_Blue1.1.1" or minion.name == "SRU_Blue7.1.1" then
						blue = minion
					end
				elseif MenuLux.jsConfig.JST == 2 then
					if myHero.team == 100 and minion.name == "SRU_Blue1.1.1" then
						blue = minion
					elseif myHero.team == 200 and minion.name == "SRU_Blue7.1.1" then
						blue = minion
					end
				elseif MenuLux.jsConfig.JST == 1 then
					if myHero.team == 100 and minion.name == "SRU_Blue7.1.1" then
						blue = minion
					elseif myHero.team == 200 and minion.name == "SRU_Blue1.1.1" then
						blue = minion
					end
				end
			end
			if ValidTarget(blue) then
				if blue.health < getDmg("R", blue, myHero, 1) and GetDistance(blue) < R.range then
					CastSpell(_R, blue.x, blue.z)
				end
			end
		end
		if MenuLux.jsConfig.JSD then
			for i, minion in pairs(KSMinions.objects) do
				if minion.name == "SRU_Dragon6.1.1" then
					dragon = minion
				end
			end
			if ValidTarget(dragon) then
				if dragon.health < getDmg("R", dragon, myHero, 1) and GetDistance(dragon) < R.range then
					CastSpell(_R, dragon.x, dragon.z)
				end
			end
		end
		if MenuLux.jsConfig.JSB then
			for i, minion in pairs(KSMinions.objects) do
				if minion.name == "SRU_Baron12.1.1" then
					baron = minion
				end
			end
			if ValidTarget(baron) then
				if baron.health < getDmg("R", baron, myHero, 1) and GetDistance(baron) < R.range then
					CastSpell(_R, baron.x, baron.z)
				end
			end
		end
end

function KSandAUTO()
	for _, enemy in pairs(GetEnemyHeroes()) do
		if enemy and eobject and GetDistance(eobject,enemy) <= E.width then
			if myHero:GetSpellData(_E).name == "luxlightstriketoggle" then
				CastSpell(_E)
			end
		end
		if MenuLux.ksConfig.QKS or MenuLux.ksConfig.EKS or MenuLux.ksConfig.RKS or MenuLux.ksConfig.IKS then
			if ValidTarget(enemy, R.range) and enemy ~= nil and enemy.team ~= player.team and not enemy.dead and enemy.visible then
				IReady = (IgniteKey ~= nil and myHero:CanUseSpell(IgniteKey) == READY)
				local QDMG = getDmg("Q", enemy, myHero, 1)
				local EDMG = getDmg("E", enemy, myHero, 1)
				local RDMG = getDmg("R", enemy, myHero, 1)
				local IDMG = (50 + (20 * myHero.level))
				if enemy.health < QDMG and Q.Ready() and GetDistance(enemy) < Q.range and MenuLux.ksConfig.QKS then
					CastQ(enemy)
				elseif enemy.health < EDMG and E.Ready() and GetDistance(enemy) < E.range and MenuLux.ksConfig.EKS then
					CastE(enemy)
				elseif enemy.health < RDMG and R.Ready() and GetDistance(enemy) < R.range and MenuLux.ksConfig.RKS then
					CastR(enemy)
				elseif enemy.health < IDMG and IReady and GetDistance(enemy) <= 600 and MenuLux.ksConfig.IKS then
					CastSpell(IgniteKey, enemy)
				end
			end
		end
		if MenuLux.exConfig.AEF then
			if E.Ready() and ValidTarget(enemy) and GetDistance(enemy) < E.range then
				local ePos, HitChance, maxHit, Positions = VP:GetCircularAOECastPosition(enemy, E.delay, E.width, E.range, E.speed, myHero)
				if ePos ~= nil and maxHit >= MenuLux.exConfig.AEX and HitChance >=2 then		
					if VIP_USER and MenuLux.prConfig.pc then
						Packet("S_CAST", {spellId = _E, fromX = ePos.x, fromY = ePos.z, toX = ePos.x, toY = ePos.z}):send()
					else
						CastSpell(_E, ePos.x, ePos.z)
					end
				end
			end
		end
		if MenuLux.exConfig.ARF then
			if R.Ready() and ValidTarget(enemy) and GetDistance(enemy) < R.range then
				local rPos, HitChance, maxHit, Positions = VP:GetLineAOECastPosition(enemy, R.delay, R.width, R.range, R.speed, myHero)
				if rPos ~= nil and maxHit >= MenuLux.exConfig.ARX and HitChance >=2 then		
					if VIP_USER and MenuLux.prConfig.pc then
						Packet("S_CAST", {spellId = _R, fromX = rPos.x, fromY = rPos.z, toX = rPos.x, toY = rPos.z}):send()
					else
						CastSpell(_R, rPos.x, rPos.z)
					end
				end
			end
		end
	end
end

function DmgCalc()
	for _, enemy in pairs(GetEnemyHeroes()) do
        if not enemy.dead and enemy.visible then
			local QDMG = getDmg("Q", enemy, myHero, 1)
			local EDMG = getDmg("E", enemy, myHero, 1)
			local RDMG = getDmg("R", enemy, myHero, 1)
			local IDMG = (50 + (20 * myHero.level))
			if enemy.health > (QDMG + EDMG + RDMG + IDMG) then
				killstring[enemy.networkID] = "Harass Him!!!"
			elseif enemy.health < QDMG then
				killstring[enemy.networkID] = "Q Kill!"
			elseif enemy.health < EDMG then
				killstring[enemy.networkID] = "E Kill!"
			elseif enemy.health < RDMG then
				killstring[enemy.networkID] = "R Kill!"
			elseif enemy.health < IDMG then
				killstring[enemy.networkID] = "Ignite Kill!"
			elseif enemy.health < (QDMG + IDMG) then
				killstring[enemy.networkID] = "Q+Ignite Kill!"
			elseif enemy.health < (EDMG + IDMG) then
				killstring[enemy.networkID] = "E+Ignite Kill!"
			elseif enemy.health < (RDMG + IDMG) then
				killstring[enemy.networkID] = "R+Ignite Kill!"
			elseif enemy.health < (QDMG + EDMG) then
				killstring[enemy.networkID] = "Q+E Kill!"
			elseif enemy.health < (QDMG + RDMG) then
				killstring[enemy.networkID] = "Q+R Kill!"
			elseif enemy.health < (EDMG + RDMG) then
				killstring[enemy.networkID] = "E+R Kill!"	
			elseif enemy.health < (QDMG + EDMG + IDMG) then
				killstring[enemy.networkID] = "Q+E+Ignite Kill!"
			elseif enemy.health < (QDMG + RDMG + IDMG) then
				killstring[enemy.networkID] = "Q+R+Ignite Kill!"
			elseif enemy.health < (EDMG + RDMG + IDMG) then
				killstring[enemy.networkID] = "E+R+Ignite Kill!"	
			elseif enemy.health < (QDMG + EDMG + RDMG) then
				killstring[enemy.networkID] = "Q+E+R Kill!"
			elseif enemy.health < (QDMG + EDMG + RDMG + IDMG) then
				killstring[enemy.networkID] = "Q+E+R+Ignite Kill!"
			end
		end
	end
end

function CastQ(unit)
	if unit and Q.Ready() and ValidTarget(unit) then
		if MenuLux.prConfig.pro == 1 then
			local CastPosition, HitChance, Position = VP:GetLineCastPosition(unit, Q.delay, Q.width, Q.range, Q.speed, myHero, true)
			if HitChance >= 2 then
				if VIP_USER and MenuLux.prConfig.pc then
					Packet("S_CAST", {spellId = _Q, fromX = CastPosition.x, fromY = CastPosition.z, toX = CastPosition.x, toY = CastPosition.z}):send()
				else
					CastSpell(_Q, CastPosition.x, CastPosition.z)
				end
			end
		end
		if MenuLux.prConfig.pro == 2 and VIP_USER and prodstatus then
			local Position, info = Prodiction.GetPrediction(unit, Q.range, Q.speed, Q.delay, Q.width, myHero)
			if Position ~= nil and not info.mCollision() then
				if VIP_USER and MenuLux.prConfig.pc then
					Packet("S_CAST", {spellId = _Q, fromX = Position.x, fromY = Position.z, toX = Position.x, toY = Position.z}):send()
				else
					CastSpell(_Q, Position.x, Position.z)
				end	
			end
		end
		if MenuLux.prConfig.pro == 3 and VIP_USER then
			local unit = DPTarget(unit)
			local LuxQ = LineSS(Q.speed, Q.range, Q.width, Q.delay, 0)
			local State, Position, perc = DP:predict(unit, LuxQ)
			if State == SkillShot.STATUS.SUCCESS_HIT then 
				if VIP_USER and MenuLux.prConfig.pc then
					Packet("S_CAST", {spellId = _Q, fromX = Position.x, fromY = Position.z, toX = Position.x, toY = Position.z}):send()
				else
					CastSpell(_Q, Position.x, Position.z)
				end
			end
		end
	end
end

function CastQ2(unit)
	if unit and Q.Ready() and ValidTarget(unit) then
		local willCollide1, ColTable2 = GetMinionCollisionM(unit, myHero)
		local willCollide2, ColTable3 = GetHeroCollisionM(unit, myHero)
		if (#ColTable2 <= 1 and GetDistance(myHero, ColTable2[1]) < Q.range) or (#ColTable3 <= 1 and GetDistance(myHero, ColTable3[1]) < Q.range) then
			if MenuLux.prConfig.pro == 1 then
				CastPosition,  HitChance, Position = VP:GetLineCastPosition(unit, Q.delay, Q.width, Q.range, Q.speed, myHero, false)
			elseif MenuLux.prConfig.pro == 2 then
				CastPosition, info = Prodiction.GetPrediction(unit, Q.range, Q.speed, Q.delay, Q.width, myHero)
			end
			if VIP_USER and MenuLux.prConfig.pc then
				Packet("S_CAST", {spellId = _Q, fromX = CastPosition.x, fromY = CastPosition.z, toX = CastPosition.x, toY = CastPosition.z}):send()
			else
				CastSpell(_Q, CastPosition.x, CastPosition.z)
			end
		end
		if MenuLux.prConfig.pro == 3 then
			local unit = DPTarget(unit)
			local LuxQ = LineSS(Q.speed, Q.range, Q.width, Q.delay, 1)
			local State, Position, perc = DP:predict(unit, LuxQ)
			if State == SkillShot.STATUS.SUCCESS_HIT then 
				if VIP_USER and MenuLux.prConfig.pc then
					Packet("S_CAST", {spellId = _Q, fromX = Position.x, fromY = Position.z, toX = Position.x, toY = Position.z}):send()
				else
					CastSpell(_Q, Position.x, Position.z)
				end
			end
		end
	end
end

function CastW(unit)
	if unit and W.Ready() then
		local CastPosition, HitChance, Position = VP:GetLineCastPosition(unit, W.delay, W.width, W.range, W.speed, myHero, false)
		if VIP_USER and MenuLux.prConfig.pc then
			Packet("S_CAST", {spellId = _W, fromX = CastPosition.x, fromY = CastPosition.z, toX = CastPosition.x, toY = CastPosition.z}):send()
		else
			CastSpell(_W, CastPosition.x, CastPosition.z)
		end
	end
end

function CastE(unit)
	if unit and E.Ready() and ValidTarget(unit) and myHero:GetSpellData(_E).name == "LuxLightStrikeKugel" then
		if MenuLux.prConfig.pro == 1 then
			local CastPosition, HitChance, Position = VP:GetCircularAOECastPosition(unit, E.delay, E.width, E.range, E.speed, myHero)
			if HitChance >= 2 then
				if VIP_USER and MenuLux.prConfig.pc then
					Packet("S_CAST", {spellId = _E, fromX = CastPosition.x, fromY = CastPosition.z, toX = CastPosition.x, toY = CastPosition.z}):send()
				else
					CastSpell(_E, CastPosition.x, CastPosition.z)
				end
			end
		end
		if MenuLux.prConfig.pro == 2 and VIP_USER and prodstatus then
			local Position, info = Prodiction.GetPrediction(unit, E.range, E.speed, E.delay, E.width, myHero)
			if Position ~= nil then
				if VIP_USER and MenuLux.prConfig.pc then
					Packet("S_CAST", {spellId = _E, fromX = Position.x, fromY = Position.z, toX = Position.x, toY = Position.z}):send()
				else
					CastSpell(_E, Position.x, Position.z)
				end	
			end
		end
		if MenuLux.prConfig.pro == 3 and VIP_USER then
			local unit = DPTarget(unit)
			local LuxE = CircleSS(E.speed, E.range, E.width, E.delay, math.huge)
			local State, Position, perc = DP:predict(unit, LuxE)
			if State == SkillShot.STATUS.SUCCESS_HIT then 
				if VIP_USER and MenuLux.prConfig.pc then
					Packet("S_CAST", {spellId = _E, fromX = Position.x, fromY = Position.z, toX = Position.x, toY = Position.z}):send()
				else
					CastSpell(_E, Position.x, Position.z)
				end
			end
		end
	end
end

function CastR(unit)
	if unit and R.Ready() and ValidTarget(unit) then
		if MenuLux.prConfig.pro == 1 then
			local CastPosition, HitChance, Position = VP:GetLineCastPosition(unit, R.delay, R.width, R.range, R.speed, myHero, false)
			if HitChance >= 2 then
				if VIP_USER and MenuLux.prConfig.pc then
					Packet("S_CAST", {spellId = _R, fromX = CastPosition.x, fromY = CastPosition.z, toX = CastPosition.x, toY = CastPosition.z}):send()
				else
					CastSpell(_R, CastPosition.x, CastPosition.z)
				end
			end
		end
		if MenuLux.prConfig.pro == 2 and VIP_USER and prodstatus then
			local Position, info = Prodiction.GetPrediction(unit, R.range, R.speed, R.delay, R.width, myHero)
			if Position ~= nil then
				if VIP_USER and MenuLux.prConfig.pc then
					Packet("S_CAST", {spellId = _R, fromX = Position.x, fromY = Position.z, toX = Position.x, toY = Position.z}):send()
				else
					CastSpell(_R, Position.x, Position.z)
				end	
			end
		end
		if MenuLux.prConfig.pro == 3 and VIP_USER then
			local unit = DPTarget(unit)
			local LuxR = LineSS(R.speed, R.range, Q.width, Q.delay, math.huge)
			local State, Position, perc = DP:predict(unit, LuxR)
			if State == SkillShot.STATUS.SUCCESS_HIT then 
				if VIP_USER and MenuLux.prConfig.pc then
					Packet("S_CAST", {spellId = _R, fromX = Position.x, fromY = Position.z, toX = Position.x, toY = Position.z}):send()
				else
					CastSpell(_R, Position.x, Position.z)
				end
			end
		end
	end
end

function FindShield()
	for i = 1, heroManager.iCount do
		hero = heroManager:GetHero(i)
		if MenuLux.exConfig.UAS and MenuLux.exConfig.UASA then
			if hero.team == myHero.team and not hero.dead and GetDistance(myHero,hero) <= W.range and MenuLux.exConfig.uso[hero.charName] then
				if shieldtarget == nil then
					shieldtarget = hero
				elseif hero.health/hero.maxHealth < shieldtarget.health/shieldtarget.maxHealth then
					shieldtarget = hero
				end
			end
		else
			shieldtarget = myHero
		end
	end
	return shieldtarget
end

function OnProcessSpell(unit,spell)
	if MenuLux.exConfig.UAS and not recall then
		shieldtarget = FindShield()
		if shieldtarget and ((shieldtarget.health/shieldtarget.maxHealth)*100) < MenuLux.exConfig.ASHP and GetDistance(shieldtarget) < W.range and not _G.Evade then
			if ((myHero.mana/myHero.maxMana)*100) >= MenuLux.exConfig.ASMP then
				CastW(shieldtarget)
			end
		end
	end
	if MenuLux.gpConfig.UG and Q.Ready() then
		for _, x in pairs(GapCloserList) do
			if unit and unit.team ~= myHero.team and unit.type == myHero.type and spell then
				if spell.name == x.spellName and MenuLux.gpConfig.ES2[x.spellName] and ValidTarget(unit, Q.range - 30) then
					if spell.target and spell.target.isMe then
						CastQ(unit)
					elseif not spell.target then
						local endPos1 = Vector(unit.visionPos) + 300 * (Vector(spell.endPos) - Vector(unit.visionPos)):normalized()
						local endPos2 = Vector(unit.visionPos) + 100 * (Vector(spell.endPos) - Vector(unit.visionPos)):normalized()
						if (GetDistanceSqr(myHero.visionPos, unit.visionPos) > GetDistanceSqr(myHero.visionPos, endPos1) or GetDistanceSqr(myHero.visionPos, unit.visionPos) > GetDistanceSqr(myHero.visionPos, endPos2))  then
							CastQ(unit)
						end
					end
				end
			end
		end
	end
end

function OnApplyBuff(source, unit, buff)	
	if unit.isMe and buff and buff.name == "Recall" then
		recall = true
	end
end

function OnRemoveBuff(unit, buff)
	if unit.isMe and buff and buff.name == "Recall" then
		recall = false
	end
end

function OnCreateObj(object)
	if object.name:find("LuxLightstrike_tar_green") then
		eobject = object
	elseif object.name:find("LuxBlitz_nova") then
		eobject = nil
	end
end		
		
function OnDeleteObj(object)
	if object.name:find("LuxBlitz_nova") then
		eobject = nil
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
	if Msg == WM_LBUTTONDOWN and MenuLux.comboConfig.ST then
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
				if MenuLux.comboConfig.ST then 
					print("Target unselected: "..Selecttarget.charName) 
				end
			else
				SelectedTarget = Selecttarget
				if MenuLux.comboConfig.ST then 
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
	if VIP_USER then
		prediction = TargetPredictionVIP(Q.range, Q.speed, Q.delay, Q.width)
	else
		prediction = TargetPrediction(Q.range, Q.speed/1000, Q.delay*1000, Q.width)
	end
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

function GetHeroCollisionM(pStart, pEnd)
    hCollision = {}
	if mode == nil then mode = HERO_ENEMY end
    local heros = {}
    for i = 1, heroManager.iCount do
        local hero = heroManager:GetHero(i)
        if hero.team ~= myHero.team and not hero.dead then
            table.insert(heros, hero)
        end
    end
    local distance =  GetDistance(pStart, pEnd)
	local prediction = VP
    if distance > R.range then
        distance = R.range
    end
    local V = Vector(pEnd) - Vector(pStart)
    local k = V:normalized()
    local P = V:perpendicular2():normalized()
    local t,i,u = k:unpack()
    local x,y,z = P:unpack()
    local startLeftX = pStart.x + (x * Q.width)
    local startLeftY = pStart.y + (y * Q.width)
    local startLeftZ = pStart.z + (z * Q.width)
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
    for index, hero in pairs(heros) do
        if hero ~= nil and hero.valid and not hero.dead then
            if GetDistance(pStart, hero) < distance then
				local pos, t, vec  = prediction:GetLineCastPosition(hero, R.delay, R.width, R.range, R.speed, myHero)				
                local lineSegmentLeft = LineSegment(Point(startLeftX,startLeftZ), Point(endLeftX, endLeftZ))
                local lineSegmentRight = LineSegment(Point(startRightX,startRightZ), Point(endRightX, endRightZ))
                local toScreen, toPoint
                if pos ~= nil then
                    toScreen = WorldToScreen(D3DXVECTOR3(pos.x, hero.y, pos.z))
                    toPoint = Point(toScreen.x, toScreen.y)
                end
                if poly:contains(toPoint) then
                    table.insert(hCollision, hero)
                else
                if pos ~= nil then
                    distance1 = Point(pos.x, pos.z):distance(lineSegmentLeft)
                    distance2 = Point(pos.x, pos.z):distance(lineSegmentRight)
                end
                if (distance1 < (getHitBoxRadius2(hero)*2+10) or distance2 < (getHitBoxRadius2(hero) *2+10)) then
                    table.insert(hCollision, hero)
                end
				end
			end
		end
    end
    if #hCollision >= 0 then return true, hCollision else return false, hCollision end
end

function getHitBoxRadius2(target)
    return GetDistance(target, target.minBBox)/2
end

-----SCRIPT STATUS------------
assert(load(Base64Decode("G0x1YVIAAQQEBAgAGZMNChoKAAAAAAAAAAAAAQIKAAAABgBAAEFAAAAdQAABBkBAAGUAAAAKQACBBkBAAGVAAAAKQICBHwCAAAQAAAAEBgAAAGNsYXNzAAQNAAAAU2NyaXB0U3RhdHVzAAQHAAAAX19pbml0AAQLAAAAU2VuZFVwZGF0ZQACAAAAAgAAAAgAAAACAAotAAAAhkBAAMaAQAAGwUAABwFBAkFBAQAdgQABRsFAAEcBwQKBgQEAXYEAAYbBQACHAUEDwcEBAJ2BAAHGwUAAxwHBAwECAgDdgQABBsJAAAcCQQRBQgIAHYIAARYBAgLdAAABnYAAAAqAAIAKQACFhgBDAMHAAgCdgAABCoCAhQqAw4aGAEQAx8BCAMfAwwHdAIAAnYAAAAqAgIeMQEQAAYEEAJ1AgAGGwEQA5QAAAJ1AAAEfAIAAFAAAAAQFAAAAaHdpZAAEDQAAAEJhc2U2NEVuY29kZQAECQAAAHRvc3RyaW5nAAQDAAAAb3MABAcAAABnZXRlbnYABBUAAABQUk9DRVNTT1JfSURFTlRJRklFUgAECQAAAFVTRVJOQU1FAAQNAAAAQ09NUFVURVJOQU1FAAQQAAAAUFJPQ0VTU09SX0xFVkVMAAQTAAAAUFJPQ0VTU09SX1JFVklTSU9OAAQEAAAAS2V5AAQHAAAAc29ja2V0AAQIAAAAcmVxdWlyZQAECgAAAGdhbWVTdGF0ZQAABAQAAAB0Y3AABAcAAABhc3NlcnQABAsAAABTZW5kVXBkYXRlAAMAAAAAAADwPwQUAAAAQWRkQnVnc3BsYXRDYWxsYmFjawABAAAACAAAAAgAAAAAAAMFAAAABQAAAAwAQACBQAAAHUCAAR8AgAACAAAABAsAAABTZW5kVXBkYXRlAAMAAAAAAAAAQAAAAAABAAAAAQAQAAAAQG9iZnVzY2F0ZWQubHVhAAUAAAAIAAAACAAAAAgAAAAIAAAACAAAAAAAAAABAAAABQAAAHNlbGYAAQAAAAAAEAAAAEBvYmZ1c2NhdGVkLmx1YQAtAAAAAwAAAAMAAAAEAAAABAAAAAQAAAAEAAAABAAAAAQAAAAEAAAABAAAAAUAAAAFAAAABQAAAAUAAAAFAAAABQAAAAUAAAAFAAAABgAAAAYAAAAGAAAABgAAAAUAAAADAAAAAwAAAAYAAAAGAAAABgAAAAYAAAAGAAAABgAAAAYAAAAHAAAABwAAAAcAAAAHAAAABwAAAAcAAAAHAAAABwAAAAcAAAAIAAAACAAAAAgAAAAIAAAAAgAAAAUAAABzZWxmAAAAAAAtAAAAAgAAAGEAAAAAAC0AAAABAAAABQAAAF9FTlYACQAAAA4AAAACAA0XAAAAhwBAAIxAQAEBgQAAQcEAAJ1AAAKHAEAAjABBAQFBAQBHgUEAgcEBAMcBQgABwgEAQAKAAIHCAQDGQkIAx4LCBQHDAgAWAQMCnUCAAYcAQACMAEMBnUAAAR8AgAANAAAABAQAAAB0Y3AABAgAAABjb25uZWN0AAQRAAAAc2NyaXB0c3RhdHVzLm5ldAADAAAAAAAAVEAEBQAAAHNlbmQABAsAAABHRVQgL3N5bmMtAAQEAAAAS2V5AAQCAAAALQAEBQAAAGh3aWQABAcAAABteUhlcm8ABAkAAABjaGFyTmFtZQAEJgAAACBIVFRQLzEuMA0KSG9zdDogc2NyaXB0c3RhdHVzLm5ldA0KDQoABAYAAABjbG9zZQAAAAAAAQAAAAAAEAAAAEBvYmZ1c2NhdGVkLmx1YQAXAAAACgAAAAoAAAAKAAAACgAAAAoAAAALAAAACwAAAAsAAAALAAAADAAAAAwAAAANAAAADQAAAA0AAAAOAAAADgAAAA4AAAAOAAAACwAAAA4AAAAOAAAADgAAAA4AAAACAAAABQAAAHNlbGYAAAAAABcAAAACAAAAYQAAAAAAFwAAAAEAAAAFAAAAX0VOVgABAAAAAQAQAAAAQG9iZnVzY2F0ZWQubHVhAAoAAAABAAAAAQAAAAEAAAACAAAACAAAAAIAAAAJAAAADgAAAAkAAAAOAAAAAAAAAAEAAAAFAAAAX0VOVgA="), nil, "bt", _ENV))() ScriptStatus("PCFDDJCFCHI") 
