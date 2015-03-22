--[[

	Script Name: AHRI MASTER 
    	Author: kokosik1221
	Last Version: 0.54
	22.03.2015
	
]]--


if myHero.charName ~= "Ahri" then return end

_G.AUTOUPDATE = true

local version = "0.54"
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/kokosik1221/bol/master/AhriMaster.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH..GetCurrentEnv().FILE_NAME
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH
function AutoupdaterMsg(msg) print("<font color=\"#FF0000\"><b>AhriMaster:</b></font> <font color=\"#FFFFFF\">"..msg..".</font>") end
if _G.AUTOUPDATE then
	local ServerData = GetWebResult(UPDATE_HOST, "/kokosik1221/bol/master/AhriMaster.version")
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
	["vPrediction"] = "https://raw.github.com/Hellsing/BoL/master/common/VPrediction.lua",
	["Prodiction"] = "https://bitbucket.org/Klokje/public-klokjes-bol-scripts/raw/ec830facccefb3b52212dba5696c08697c3c2854/Test/Prodiction/Prodiction.lua",
	["SxOrbWalk"] = "https://raw.githubusercontent.com/Superx321/BoL/master/common/SxOrbWalk.lua",
	["DivinePred"] = ""
}
local DOWNLOADING_LIBS, DOWNLOAD_COUNT = false, 0
function AfterDownload()
	DOWNLOAD_COUNT = DOWNLOAD_COUNT - 1
	if DOWNLOAD_COUNT == 0 then
		DOWNLOADING_LIBS = false
		print("<b><font color=\"#6699FF\">Required libraries downloaded successfully, please reload (double F9).</font>")
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

local Items = {
	BWC = { id = 3144, range = 400, reqTarget = true, slot = nil },
	DFG = { id = 3128, range = 750, reqTarget = true, slot = nil },
	HGB = { id = 3146, range = 400, reqTarget = true, slot = nil },
	BFT = { id = 3188, range = 750, reqTarget = true, slot = nil },
}

local Q = {name = "Orb of Deception", range = 880, speed = 1600, delay = 0.5, width = 80, Ready = function() return myHero:CanUseSpell(_Q) == READY end}
local W = {name = "Fox-Fire", range = 700, Ready = function() return myHero:CanUseSpell(_W) == READY end}
local E = {name = "Charm", range = 975, speed = 1500, delay = 0.25, width = 85, Ready = function() return myHero:CanUseSpell(_E) == READY end}
local R = {name = "Spirit Rush", range = 450, Ready = function() return myHero:CanUseSpell(_R) == READY end}
local IReady, zhonyaready, recall = false, false, false
local EnemyMinions = minionManager(MINION_ENEMY, Q.range, myHero, MINION_SORT_MAXHEALTH_DEC)
local JungleMinions = minionManager(MINION_JUNGLE, Q.range, myHero, MINION_SORT_MAXHEALTH_DEC)
local IgniteKey, zhonyaslot = nil, nil
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
	Menu()
	print("<b><font color=\"#FF0000\">Ahri Master:</font></b> <font color=\"#FFFFFF\">Good luck and give me feedback!</font>")
	if _G.MMA_Loaded then
		print("<b><font color=\"#FF0000\">Ahri Master:</font></b> <font color=\"#FFFFFF\">MMA Support Loaded.</font>")
	end	
	if _G.AutoCarry then
		print("<b><font color=\"#FF0000\">Ahri Master:</font></b> <font color=\"#FFFFFF\">SAC Support Loaded.</font>")
	end
end

function OnTick()
	Check()
	if MenuAhri.comboConfig.Combo and not recall then
		caa()
		Combo()
	end
	if (MenuAhri.harrasConfig.Mixed or MenuAhri.harrasConfig.MixedT) and not recall then
		Harrass()
	end
	if MenuAhri.farm.LaneClear and ((myHero.mana/myHero.maxMana)*100) >= MenuAhri.farm.manaf and not recall then
		Farm()
	end
	if MenuAhri.jf.JungleFarm and ((myHero.mana/myHero.maxMana)*100) >= MenuAhri.jf.manajf and not recall then
		JungleFarmm()
	end
	if MenuAhri.prConfig.AZ and not recall then
		autozh()
	end
	if MenuAhri.prConfig.ALS and not recall then
		autolvl()
	end
	if not recall then
		KillSteall()
	end
end

function Menu()
	if VIP_USER then
		DP = DivinePred()
	end
	VP = VPrediction()
	MenuAhri = scriptConfig("Ahri Master "..version, "Ahri Master "..version)
	MenuAhri:addParam("orb", "Orbwalker:", SCRIPT_PARAM_LIST, 1, {"SxOrb","SAC:R/MMA"}) 
	MenuAhri:addParam("qqq", "If You Change Orb. Click 2x F9", SCRIPT_PARAM_INFO,"")
	if MenuAhri.orb == 1 then
		MenuAhri:addSubMenu("[Ahri Master]: Orbwalking", "Orbwalking")
		SxOrb:LoadToMenu(MenuAhri.Orbwalking) 
	end
	TargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, E.range, DAMAGE_MAGIC)
	TargetSelector.name = "Ahri"
	MenuAhri:addTS(TargetSelector)
	MenuAhri:addSubMenu("[Ahri Master]: Combo Settings", "comboConfig")
	MenuAhri.comboConfig:addParam("USEQ", "Use " .. Q.name .. "(Q)", SCRIPT_PARAM_ONOFF, true)
	MenuAhri.comboConfig:addParam("USEQ2", "Use Only If Enemy Is Charmed", SCRIPT_PARAM_ONOFF, false)
	MenuAhri.comboConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAhri.comboConfig:addParam("USEW", "Use " .. W.name .. "(W)", SCRIPT_PARAM_ONOFF, true)
	MenuAhri.comboConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAhri.comboConfig:addParam("USEE", "Use " .. E.name .. "(E)", SCRIPT_PARAM_ONOFF, true)
	MenuAhri.comboConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAhri.comboConfig:addParam("USER", "Use " .. R.name .. "(R)", SCRIPT_PARAM_ONOFF, true)
	MenuAhri.comboConfig:addParam("Kilable", "Only Use If Target Is Killable", SCRIPT_PARAM_ONOFF, true)
	MenuAhri.comboConfig:addParam("RM", "R Cast Mode", SCRIPT_PARAM_LIST, 1, { "To Mouse", "To Enemy"})
	MenuAhri.comboConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAhri.comboConfig:addParam("uaa", "Use AA in Combo", SCRIPT_PARAM_ONOFF, true)
	MenuAhri.comboConfig:addParam("ST", "Focus Selected Target", SCRIPT_PARAM_ONOFF, false)
	MenuAhri.comboConfig:addParam("manac", "Min. Mana To Cast Combo", SCRIPT_PARAM_SLICE, 10, 0, 100, 0) 
	MenuAhri.comboConfig:addParam("Combo", "Full Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	MenuAhri:addSubMenu("[Ahri Master]: Harras Settings", "harrasConfig")
    MenuAhri.harrasConfig:addParam("QH", "Harras Use " .. Q.name .. "(Q)", SCRIPT_PARAM_ONOFF, true)
	MenuAhri.harrasConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAhri.harrasConfig:addParam("WH", "Harras Use " .. W.name .. "(W)", SCRIPT_PARAM_ONOFF, true)
	MenuAhri.harrasConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAhri.harrasConfig:addParam("EH", "Harras Use " .. E.name .. "(E)", SCRIPT_PARAM_ONOFF, true)
	MenuAhri.harrasConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAhri.harrasConfig:addParam("manah", "Min. Mana To Harass", SCRIPT_PARAM_SLICE, 60, 0, 100, 0)
	MenuAhri.harrasConfig:addParam("Mixed", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
	MenuAhri.harrasConfig:addParam("MixedT", "Harass Toggle", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("L"))
	MenuAhri:addSubMenu("[Ahri Master]: KS Settings", "ksConfig")
	MenuAhri.ksConfig:addParam("IKS", "Use Ignite To KS", SCRIPT_PARAM_ONOFF, true)
	MenuAhri.ksConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAhri.ksConfig:addParam("QKS", "Use " .. Q.name .. "(Q)", SCRIPT_PARAM_ONOFF, true)
	MenuAhri.ksConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAhri.ksConfig:addParam("WKS", "Use " .. W.name .. "(W)", SCRIPT_PARAM_ONOFF, true)
	MenuAhri.ksConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAhri.ksConfig:addParam("EKS", "Use " .. E.name .. "(E)", SCRIPT_PARAM_ONOFF, true)
	MenuAhri.ksConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAhri.ksConfig:addParam("RKS", "Use " .. R.name .. "(R)", SCRIPT_PARAM_ONOFF, false)
	MenuAhri:addSubMenu("[Ahri Master]: Farm Settings", "farm")
	MenuAhri.farm:addParam("QF", "Use " .. Q.name .. "(Q)", SCRIPT_PARAM_LIST, 3, { "No", "Freezing", "LaneClear"})
	MenuAhri.farm:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAhri.farm:addParam("WF",  "Use " .. W.name .. "(W)", SCRIPT_PARAM_LIST, 2, { "No", "Freezing", "LaneClear"})
	MenuAhri.farm:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAhri.farm:addParam("manaf", "Min. Mana To Farm", SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
	MenuAhri.farm:addParam("LaneClear", "Lane Clear ", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("V"))	
	MenuAhri:addSubMenu("[Ahri Master]: Jungle Farm Settings", "jf")
	MenuAhri.jf:addParam("QJF", "Use " .. Q.name .. "(Q)", SCRIPT_PARAM_ONOFF, true)
	MenuAhri.jf:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAhri.jf:addParam("WJF", "Use " .. W.name .. "(W)", SCRIPT_PARAM_ONOFF, true)
	MenuAhri.jf:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAhri.jf:addParam("manajf", "Min. Mana To Jungle Farm", SCRIPT_PARAM_SLICE, 10, 0, 100, 0)
	MenuAhri.jf:addParam("JungleFarm", "Jungle Clear", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("V"))
	MenuAhri:addSubMenu("[Ahri Master]: Extra Settings", "exConfig")
	MenuAhri.exConfig:addSubMenu("Auto-Interrupt Spells", "ES")
	for i, enemy in ipairs(GetEnemyHeroes()) do
		for _, champ in pairs(InterruptList) do
			if enemy.charName == champ.charName then
				MenuAhri.exConfig.ES:addParam(champ.spellName, "Stop "..champ.charName.." "..champ.spellName, SCRIPT_PARAM_ONOFF, true)
			end
		end
	end
	MenuAhri.exConfig:addParam("UI", "Use Auto-Interrupt (E)", SCRIPT_PARAM_ONOFF, true)
	MenuAhri.exConfig:addSubMenu("GapCloser Spells", "ES2")
	for i, enemy in ipairs(GetEnemyHeroes()) do
		for _, champ in pairs(GapCloserList) do
			if enemy.charName == champ.charName then
				MenuAhri.exConfig.ES2:addParam(champ.spellName, "GapCloser "..champ.charName.." "..champ.spellName, SCRIPT_PARAM_ONOFF, true)
			end
		end
	end
	MenuAhri.exConfig:addParam("UG", "Use GapCloser (E)", SCRIPT_PARAM_ONOFF, true)
	MenuAhri:addSubMenu("[Ahri Master]: Draw Settings", "drawConfig")
	MenuAhri.drawConfig:addParam("DLC", "Use Lag-Free Circles", SCRIPT_PARAM_ONOFF, true)
	MenuAhri.drawConfig:addParam("DD", "Draw DMG Text", SCRIPT_PARAM_ONOFF, true)
	MenuAhri.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAhri.drawConfig:addParam("DQR", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
	MenuAhri.drawConfig:addParam("DQRC", "Draw Q Range Color", SCRIPT_PARAM_COLOR, {255,0,0,255})
	MenuAhri.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAhri.drawConfig:addParam("DWR", "Draw W Range", SCRIPT_PARAM_ONOFF, true)
	MenuAhri.drawConfig:addParam("DWRC", "Draw W Range Color", SCRIPT_PARAM_COLOR, {255,100,0,0})
	MenuAhri.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAhri.drawConfig:addParam("DER", "Draw E Range", SCRIPT_PARAM_ONOFF, true)
	MenuAhri.drawConfig:addParam("DERC", "Draw E Range Color", SCRIPT_PARAM_COLOR, {255,255,0,0})
	MenuAhri.drawConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAhri.drawConfig:addParam("DRR", "Draw R Range", SCRIPT_PARAM_ONOFF, true)
	MenuAhri.drawConfig:addParam("DRRC", "Draw R Range Color", SCRIPT_PARAM_COLOR, {255, 0, 255, 0})
	MenuAhri:addSubMenu("[Ahri Master]: Misc Settings", "prConfig")
	MenuAhri.prConfig:addParam("pc", "Use Packets To Cast Spells(VIP)", SCRIPT_PARAM_ONOFF, false)
	MenuAhri.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAhri.prConfig:addParam("AZ", "Use Auto Zhonya", SCRIPT_PARAM_ONOFF, true)
	MenuAhri.prConfig:addParam("AZHP", "Min HP To Cast Zhonya", SCRIPT_PARAM_SLICE, 20, 0, 100, 0)
	MenuAhri.prConfig:addParam("AZMR", "Must Have 0 Enemy In Range:", SCRIPT_PARAM_SLICE, 900, 0, 1500, 0)
	MenuAhri.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAhri.prConfig:addParam("ALS", "Auto lvl skills", SCRIPT_PARAM_ONOFF, false)
	MenuAhri.prConfig:addParam("AL", "Auto lvl sequence", SCRIPT_PARAM_LIST, 1, { "MID"})
	MenuAhri.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAhri.prConfig:addParam("pro", "Prodiction To Use:", SCRIPT_PARAM_LIST, 1, {"VPrediction","Prodiction","DivinePred"}) 
	MenuAhri.prConfig:addParam("vphit", "VPrediction HitChance", SCRIPT_PARAM_LIST, 3, {"[0]Target Position","[1]Low Hitchance", "[2]High Hitchance", "[3]Target slowed/close", "[4]Target immobile", "[5]Target dashing" })
	MenuAhri.comboConfig:permaShow("Combo")
	MenuAhri.harrasConfig:permaShow("Mixed")
	MenuAhri.harrasConfig:permaShow("MixedT")
	MenuAhri.farm:permaShow("LaneClear")
	MenuAhri.jf:permaShow("JungleFarm")
	MenuAhri.exConfig:permaShow("UI")
	MenuAhri.exConfig:permaShow("UG")
	MenuAhri.prConfig:permaShow("AZ")
	if myHero:GetSpellData(SUMMONER_1).name:find("summonerdot") then IgniteKey = SUMMONER_1
		elseif myHero:GetSpellData(SUMMONER_2).name:find("summonerdot") then IgniteKey = SUMMONER_2
	end
	_G.oldDrawCircle = rawget(_G, 'DrawCircle')
	_G.DrawCircle = DrawCircle2
	if heroManager.iCount < 10 then
		print("<b><font color=\"#FF0000\">Ahri Master:</font></b> <font color=\"#FFFFFF\">Too few champions to arrange priority.</font>")
	elseif heroManager.iCount == 6 then
		arrangePrioritysTT()
    else
		arrangePrioritys()
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

function caa()
	if MenuAhri.orb == 1 then
		if MenuAhri.comboConfig.uaa then
			SxOrb:EnableAttacks()
		elseif not MenuAhri.comboConfig.uaa then
			SxOrb:DisableAttacks()
		end
	end
end

function GetRange()
	if E.Ready() then
		return E.range
	elseif not E.Ready() and Q.Ready() then
		return Q.range
	else
		return Q.range
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
	TargetSelector.range = GetRange()
	if SelectedTarget ~= nil and ValidTarget(SelectedTarget, E.range) then
		Cel = SelectedTarget
	else
		Cel = GetCustomTarget()
	end
	if MenuAhri.orb == 1 then
		SxOrb:ForceTarget(Cel)
	end
	if MenuAhri.drawConfig.DLC then _G.DrawCircle = DrawCircle2 else _G.DrawCircle = _G.oldDrawCircle end
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
	if Cel ~= nil and ((myHero.mana/myHero.maxMana)*100) >= MenuAhri.comboConfig.manac then
		UseItems(Cel)
		if MenuAhri.comboConfig.USER and not MenuAhri.comboConfig.Kilable then
			if GetDistance(Cel) < Q.range then
				CastR(Cel)
			end
		elseif MenuAhri.comboConfig.USER and MenuAhri.comboConfig.Kilable then
			local DMG = CalcDMG(Cel)
			if Cel.health <= DMG then
				CastR(Cel)
			end
		end
		if MenuAhri.comboConfig.USEE then
			if GetDistance(Cel) < E.range then
				CastE(Cel)
			end
		end
		if MenuAhri.comboConfig.USEW then
			if GetDistance(Cel) < W.range then
				CastW(Cel)
			end
		end
		if MenuAhri.comboConfig.USEQ and not MenuAhri.comboConfig.USEQ2 then
			if GetDistance(Cel) < Q.range then
				CastQ(Cel)
			end
		end
		if MenuAhri.comboConfig.USEQ and MenuAhri.comboConfig.USEQ2 then
			if GetDistance(Cel) < Q.range and TargetHaveBuff("AhriSeduce", Cel) then
				CastQ(Cel)
			end
		end
	end
end

function Harrass()
	if Cel ~= nil and ((myHero.mana/myHero.maxMana)*100) >= MenuAhri.harrasConfig.manah then
		if MenuAhri.harrasConfig.QH then
			if GetDistance(Cel) < Q.range then
				CastQ(Cel)
			end
		end
		if MenuAhri.harrasConfig.WH then
			if GetDistance(Cel) < W.range then
				CastW(Cel)
			end
		end
		if MenuAhri.harrasConfig.EH then
			if GetDistance(Cel) < E.range then
				CastE(Cel)
			end
		end
	end
end

function Farm()
	EnemyMinions:update()
	QMode =  MenuAhri.farm.QF
	WMode =  MenuAhri.farm.WF
	for i, minion in pairs(EnemyMinions.objects) do
		if QMode == 3 then
			if minion ~= nil and not minion.dead and GetDistance(minion) < Q.range then
				local Pos, Hit = BestQFarmPos(Q.range, Q.width, EnemyMinions.objects)
				if Pos ~= nil then		
					CastSpell(_Q, Pos.x, Pos.z)
				end
			end
		elseif QMode == 2 then
			if minion ~= nil and not minion.dead and GetDistance(minion) < Q.range then
				if minion.health <= getDmg("Q", minion, myHero, 1) then
					CastSpell(_Q, minion.x, minion.z)
				end
			end
		end
		if WMode == 3 then
			if minion ~= nil and not minion.dead and GetDistance(minion) < W.range then
				CastW(minion)
			end
		elseif WMode == 2 then
			if minion ~= nil and not minion.dead and GetDistance(minion) < W.range then
				if minion.health <= getDmg("W", minion, myHero, 3) then
					CastW(minion)
				end
			end
		end
	end
end

function BestQFarmPos(range, width, objects)
    local BestPos 
    local BestHit = 0
    for i, object in ipairs(objects) do
        local EndPos = Vector(myHero) + range * (Vector(object) - Vector(myHero)):normalized()
        local hit = CountObjectsOnLineSegment(myHero.visionPos, EndPos, width, objects)
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

function JungleFarmm()
	JungleMinions:update()
	for i, minion in pairs(JungleMinions.objects) do
		if MenuAhri.jf.QJF then
			if minion ~= nil and not minion.dead and GetDistance(minion) < Q.range then
				local Pos, Hit = BestQFarmPos(Q.range, Q.width, EnemyMinions.objects)
				if Pos ~= nil then		
					CastSpell(_Q, Pos.x, Pos.z)
				end
			end
		end
		if MenuAhri.jf.WJF then
			if minion ~= nil and not minion.dead and GetDistance(minion) < W.range then
				CastW(minion)
			end
		end
	end
end

function autozh()
	local count = EnemyCount(myHero, MenuAhri.prConfig.AZMR)
	zhonyaslot = GetInventorySlotItem(3157)
	zhonyaready = (zhonyaslot ~= nil and myHero:CanUseSpell(zhonyaslot) == READY)
	if zhonyaready and ((myHero.health/myHero.maxHealth)*100) < MenuAhri.prConfig.AZHP and count == 0 then
		CastSpell(zhonyaslot)
	end
end

function autolvl()
	if not MenuAhri.prConfig.ALS then return end
	if myHero.level > GetHeroLeveled() then
		local a = {_Q,_E,_W,_Q,_Q,_R,_Q,_W,_Q,_W,_R,_W,_W,_E,_E,_R,_E,_E}
		LevelSpell(a[GetHeroLeveled() + 1])
	end
end

function OnDraw()
	if MenuAhri.drawConfig.DD then	
		DmgCalc()
		for _,enemy in pairs(GetEnemyHeroes()) do
            if ValidTarget(enemy) and killstring[enemy.networkID] ~= nil then
                local pos = WorldToScreen(D3DXVECTOR3(enemy.x, enemy.y, enemy.z))
                DrawText(killstring[enemy.networkID], 20, pos.x - 35, pos.y - 10, 0xFFFFFF00)
            end
        end
	end
	if MenuAhri.drawConfig.DQR and Q.Ready() then
		DrawCircle(myHero.x, myHero.y, myHero.z, Q.range, RGB(MenuAhri.drawConfig.DQRC[2], MenuAhri.drawConfig.DQRC[3], MenuAhri.drawConfig.DQRC[4]))
	end
	if MenuAhri.drawConfig.DWR and W.Ready() then
		DrawCircle(myHero.x, myHero.y, myHero.z, W.range, RGB(MenuAhri.drawConfig.DWRC[2], MenuAhri.drawConfig.DWRC[3], MenuAhri.drawConfig.DWRC[4]))
	end
	if MenuAhri.drawConfig.DER and E.Ready() then			
		DrawCircle(myHero.x, myHero.y, myHero.z, E.range, RGB(MenuAhri.drawConfig.DERC[2], MenuAhri.drawConfig.DERC[3], MenuAhri.drawConfig.DERC[4]))
	end
	if MenuAhri.drawConfig.DRR and R.Ready() then			
		DrawCircle(myHero.x, myHero.y, myHero.z, R.range, RGB(MenuAhri.drawConfig.DRRC[2], MenuAhri.drawConfig.DRRC[3], MenuAhri.drawConfig.DRRC[4]))
	end
end

function CalcDMG(unit)
	local dmg = 0
	dmg = dmg + ((R.Ready() and getDmg("R", unit, myHero, 3)) or 0)*3
	dmg = dmg + ((E.Ready() and getDmg("E", unit, myHero, 3)) or 0)
	dmg = dmg + ((Q.Ready() and getDmg("Q", unit, myHero, 3)) or 0)
	dmg = dmg + ((W.Ready() and getDmg("W", unit, myHero, 3)) or 0)
	return dmg
end

function KillSteall()
	for _, Enemy in pairs(GetEnemyHeroes()) do
		local health = Enemy.health
		local qDmg = getDmg("Q", Enemy, myHero, 1)
		local wDmg = getDmg("W", Enemy, myHero, 3) 
		local eDmg = getDmg("E", Enemy, myHero, 3)
		local rDmg = getDmg("R", Enemy, myHero, 3)*3
		local iDmg = getDmg("IGNITE", Enemy, myHero) 
		if Enemy ~= nil and Enemy.team ~= player.team and not Enemy.dead and Enemy.visible then
			if health <= qDmg and Q.Ready() and ValidTarget(Enemy, Q.range - 30) and MenuAhri.ksConfig.QKS then
				CastQ(Enemy)
			elseif health <= wDmg and W.Ready() and ValidTarget(Enemy, W.range) and MenuAhri.ksConfig.WKS then
				CastW(Enemy)
			elseif health <= eDmg and E.Ready() and ValidTarget(Enemy, E.range - 30) and MenuAhri.ksConfig.EKS then
				CastE(Enemy)
			elseif health <= rDmg and R.Ready() and ValidTarget(Enemy, R.range) and MenuAhri.ksConfig.RKS then
				CastR(Enemy)
			elseif health <= (qDmg + wDmg) and Q.Ready() and W.Ready() and ValidTarget(Enemy, W.range) and MenuAhri.ksConfig.QKS and MenuAhri.ksConfig.WKS then
				CastQ(Enemy)
				CastW(Enemy)
			elseif health <= (qDmg + eDmg) and Q.Ready() and E.Ready() and ValidTarget(Enemy, Q.range - 30) and MenuAhri.ksConfig.QKS and MenuAhri.ksConfig.EKS then
				CastQ(Enemy)
				CastE(Enemy)
			elseif health <= (qDmg + rDmg) and Q.Ready() and R.Ready() and ValidTarget(Enemy, R.range) and MenuAhri.ksConfig.QKS and MenuAhri.ksConfig.RKS then
				CastQ(Enemy)
				CastR(Enemy)
			elseif health <= (wDmg + eDmg) and W.Ready() and E.Ready() and ValidTarget(Enemy, W.range) and MenuAhri.ksConfig.WKS and MenuAhri.ksConfig.EKS then
				CastW(Enemy)
				CastE(Enemy)
			elseif health <= (wDmg + rDmg) and W.Ready() and R.Ready() and ValidTarget(Enemy, W.range) and MenuAhri.ksConfig.WKS and MenuAhri.ksConfig.RKS then
				CastW(Enemy)
				CastR(Enemy)
			elseif health <= (qDmg + wDmg + eDmg + rDmg) and Q.Ready() and W.Ready() and E.Ready() and R.Ready() and ValidTarget(Enemy, Q.range - 30) and MenuAhri.ksConfig.QKS and MenuAhri.ksConfig.WKS and MenuAhri.ksConfig.EKS and MenuAhri.ksConfig.RKS then
				CastQ(Enemy)
				CastW(Enemy)
				CastE(Enemy)
				CastR(Enemy)
			end
			IReady = (IgniteKey ~= nil and myHero:CanUseSpell(IgniteKey) == READY)
			if IReady and health <= iDmg and MenuAhri.ksConfig.IKS and ValidTarget(Enemy, 600) then
				CastSpell(IgniteKey, Enemy)
			end
		end
	end
end

function DmgCalc()
	for _, enemy in pairs(GetEnemyHeroes()) do
        if not enemy.dead and enemy.visible and GetDistance(enemy) < 3000 then
            local qDmg = getDmg("Q", enemy, myHero, 1)
            local wDmg = getDmg("W", enemy, myHero, 3)
			local eDmg = getDmg("E", enemy, myHero, 3)
			local rDmg = getDmg("R", enemy, myHero, 3)*3
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

function CastQ(unit)
	if Q.Ready() and ValidTarget(unit) then
		if MenuAhri.prConfig.pro == 1 then
			local castPosition,  HitChance,  Position = VP:GetLineCastPosition(unit, Q.delay, Q.width, Q.range - 30, Q.speed, myHero, false)
			if HitChance >= MenuAhri.prConfig.vphit - 1 then
				if VIP_USER and MenuAhri.prConfig.pc then
					Packet("S_CAST", {spellId = _Q, fromX = castPosition.x, fromY = castPosition.z, toX = castPosition.x, toY = castPosition.z}):send()
				else
					CastSpell(_Q, castPosition.x, castPosition.z)
				end
			end
		end
		if MenuAhri.prConfig.pro == 2 and VIP_USER and prodstatus then
			local Position, info = Prodiction.GetPrediction(unit, Q.range-30, Q.speed, Q.delay, Q.width, myHero)
			if Position ~= nil then
				if VIP_USER and MenuAhri.prConfig.pc then
					Packet("S_CAST", {spellId = _Q, fromX = Position.x, fromY = Position.z, toX = Position.x, toY = Position.z}):send()
				else
					CastSpell(_Q, Position.x, Position.z)
				end
			end
		end
		if MenuAhri.prConfig.pro == 3 and VIP_USER then
			local unit = DPTarget(unit)
			local AhriQ = LineSS(Q.speed, Q.range, Q.width, Q.delay, math.huge)
			local State, Position, perc = DP:predict(unit, AhriQ)
			if State == SkillShot.STATUS.SUCCESS_HIT then 
				if VIP_USER and MenuAhri.prConfig.pc then
					Packet("S_CAST", {spellId = _Q, fromX = Position.x, fromY = Position.z, toX = Position.x, toY = Position.z}):send()
				else
					CastSpell(_Q, Position.x, Position.z)
				end
			end
		end
	end
end

function CastW(unit)
	if W.Ready() and ValidTarget(unit) then
		if VIP_USER and MenuAhri.prConfig.pc then
			Packet("S_CAST", {spellId = _W}):send()
		else
			CastSpell(_W)
		end
	end
end

function CastE(unit)
	if E.Ready() and ValidTarget(unit) then
		if MenuAhri.prConfig.pro == 1 then
			local castPosition,  HitChance,  Position = VP:GetLineCastPosition(unit, E.delay, E.width, E.range - 30, E.speed, myHero, true)
			if HitChance >= MenuAhri.prConfig.vphit - 1 then
				if VIP_USER and MenuAhri.prConfig.pc then
					Packet("S_CAST", {spellId = _E, fromX = castPosition.x, fromY = castPosition.z, toX = castPosition.x, toY = castPosition.z}):send()
				else
					CastSpell(_E, castPosition.x, castPosition.z)
				end
			end
		end
		if MenuAhri.prConfig.pro == 2 and VIP_USER and prodstatus then
			local Position, info = Prodiction.GetPrediction(unit, E.range-30, E.speed, E.delay, E.width, myHero)
			if Position ~= nil and not info.mCollision() then
				if VIP_USER and MenuAhri.prConfig.pc then
					Packet("S_CAST", {spellId = _E, fromX = Position.x, fromY = Position.z, toX = Position.x, toY = Position.z}):send()
				else
					CastSpell(_E, Position.x, Position.z)
				end
			end
		end
		if MenuAhri.prConfig.pro == 3 and VIP_USER then
			local unit = DPTarget(unit)
			local AhriE = LineSS(E.speed, E.range, E.width, E.delay, 0)
			local State, Position, perc = DP:predict(unit, AhriE)
			if State == SkillShot.STATUS.SUCCESS_HIT then 
				if VIP_USER and MenuAhri.prConfig.pc then
					Packet("S_CAST", {spellId = _E, fromX = Position.x, fromY = Position.z, toX = Position.x, toY = Position.z}):send()
				else
					CastSpell(_E, Position.x, Position.z)
				end
			end
		end
	end
end

function CastR(unit)
	if R.Ready() and ValidTarget(unit) then
		if MenuAhri.comboConfig.RM == 1 then
			pos = Vector(myHero) + 400 * (Vector(mousePos) - Vector(myHero)):normalized()
		elseif MenuAhri.comboConfig.RM == 2 then
			pos = VP:GetPredictedPos(unit, 1, 2*myHero.ms, myHero, false)
		end
		if VIP_USER and MenuAhri.prConfig.pc then
			Packet("S_CAST", {spellId = _R, fromX = pos.x, fromY = pos.z, toX = pos.x, toY = pos.z}):send()
		else
			CastSpell(_R, pos.x, pos.z)
		end
	end
end

function OnApplyBuff(unit, source, buff)
	if unit.isMe and buff and (buff.name == "Recall") then
		recall = true
	end 
end

function OnRemoveBuff(unit, buff)
	if unit.isMe and buff and (buff.name == "Recall") then
		recall = false
	end 
end

function OnWndMsg(Msg, Key)
	if Msg == WM_LBUTTONDOWN then
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
				if MenuAhri.comboConfig.ST then 
					print("Target unselected: "..Selecttarget.charName) 
				end
			else
				SelectedTarget = Selecttarget
				if MenuAhri.comboConfig.ST then 
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

function OnProcessSpell(unit, spell)
	if MenuAhri.exConfig.UI and E.Ready() then
		for _, x in pairs(InterruptList) do
			if unit and unit.team ~= myHero.team and unit.type == myHero.type and spell then
				if spell.name == x.spellName and MenuAhri.exConfig.ES[x.spellName] and ValidTarget(unit, E.range - 30) then
					CastE(unit)
				end
			end
		end
	end
	if MenuAhri.exConfig.UG and E.Ready() then
		for _, x in pairs(GapCloserList) do
			if unit and unit.team ~= myHero.team and unit.type == myHero.type and spell then
				if spell.name == x.spellName and MenuAhri.exConfig.ES2[x.spellName] and ValidTarget(unit, E.range - 30) then
					if spell.target and spell.target.isMe then
						CastE(unit)
					elseif not spell.target then
						local endPos1 = Vector(unit.visionPos) + 300 * (Vector(spell.endPos) - Vector(unit.visionPos)):normalized()
						local endPos2 = Vector(unit.visionPos) + 100 * (Vector(spell.endPos) - Vector(unit.visionPos)):normalized()
						if (GetDistanceSqr(myHero.visionPos, unit.visionPos) > GetDistanceSqr(myHero.visionPos, endPos1) or GetDistanceSqr(myHero.visionPos, unit.visionPos) > GetDistanceSqr(myHero.visionPos, endPos2))  then
							CastE(unit)
						end
					end
				end
			end
		end
	end
end

-----SCRIPT STATUS------------
assert(load(Base64Decode("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"), nil, "bt", _ENV))() ScriptStatus("WJMKKQJJMOR") 
