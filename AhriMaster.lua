--[[

	Script Name: AHRI MASTER 
    	Author: kokosik1221
	Last Version: 0.2
	30.12.2014
	
]]--


if myHero.charName ~= "Ahri" then return end

_G.AUTOUPDATE = true
_G.USESKINHACK = false

local version = "0.2"
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

local Items = {
	BWC = { id = 3144, range = 400, reqTarget = true, slot = nil },
	DFG = { id = 3128, range = 750, reqTarget = true, slot = nil },
	HGB = { id = 3146, range = 400, reqTarget = true, slot = nil },
	BFT = { id = 3188, range = 750, reqTarget = true, slot = nil },
}

function Vars()
	Q = {name = "Orb of Deception", range = 840, speed = 1100, delay = 0.25, width = 90}
	W = {name = "Fox-Fire", range = 800}
	E = {name = "Charm", range = 975, speed = 1200, delay = 0.25, width = 100}
	R = {name = "Spirit Rush", range = 450}
	QReady, WReady, EReady, RReady, IReady, zhonyaready, recall, aa = false, false, false, false, false, false, true
	sac, mma = false, false
	abilitylvl, lastskin, LastAttack, BaseWindupTime, BaseAnimationTime = 0, 0, 0, 3, 0.65
	EnemyMinions = minionManager(MINION_ENEMY, Q.range, myHero, MINION_SORT_MAXHEALTH_DEC)
	JungleMinions = minionManager(MINION_JUNGLE, Q.range, myHero, MINION_SORT_MAXHEALTH_DEC)
	IgniteKey, zhonyaslot = nil, nil
	killstring = {}
	TargetTable = {
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
	print("<b><font color=\"#FF0000\">Ahri Master:</font></b> <font color=\"#FFFFFF\">Good luck and give me feedback!</font>")
	if _G.MMA_Loaded then
		print("<b><font color=\"#FF0000\">Ahri Master:</font></b> <font color=\"#FFFFFF\">MMA Support Loaded.</font>")
		mma = true
	end	
	if _G.AutoCarry then
		print("<b><font color=\"#FF0000\">Ahri Master:</font></b> <font color=\"#FFFFFF\">SAC Support Loaded.</font>")
		sac = true
	end
end

function OnLoad()
	Vars()
	Menu()
end

function OnTick()
	Check()
	if MenuAhri.Orbwalkingf.Combo and ((myHero.mana/myHero.maxMana)*100) >= MenuAhri.comboConfig.manac then
		caa()
		Combo()
	end
	if MenuAhri.Orbwalkingf.LastHit then
		_OrbWalk(Lasthit())
	end
	if (MenuAhri.Orbwalkingf.Mixed or MenuAhri.Orbwalkingf.MixedT) then
		Harrass()
	end
	if MenuAhri.Orbwalkingf.LaneClear and ((myHero.mana/myHero.maxMana)*100) >= MenuAhri.farm.manaf then
		Farm()
	end
	if MenuAhri.Orbwalkingf.JungleFarm and ((myHero.mana/myHero.maxMana)*100) >= MenuAhri.jf.manajf then
		JungleFarmm()
	end
	if MenuAhri.prConfig.AZ then
		autozh()
	end
	if MenuAhri.prConfig.ALS then
		autolvl()
	end
	KillSteall()
end

function Menu()
	VP = VPrediction()
	MenuAhri = scriptConfig("Ahri Master "..version, "Ahri Master "..version)
	MenuAhri:addSubMenu("Orbwalking", "Orbwalkingf")
	MenuAhri.Orbwalkingf:addParam("USEORB", "Enable Orbwalk", SCRIPT_PARAM_ONOFF, true)
	MenuAhri.Orbwalkingf:addParam("Combo", "Full Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	MenuAhri.Orbwalkingf:addParam("LastHit", "Last Hit ", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))	
	MenuAhri.Orbwalkingf:addParam("Mixed", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
	MenuAhri.Orbwalkingf:addParam("MixedT", "Harass Toggle", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("L"))
	MenuAhri.Orbwalkingf:addParam("LaneClear", "Lane Clear ", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("V"))	
	MenuAhri.Orbwalkingf:addParam("JungleFarm", "Jungle Clear", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("V"))
	MenuAhri:addSubMenu("Target selector", "STS")
	TargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, E.range, DAMAGE_MAGIC)
	TargetSelector.name = "Ahri"
	MenuAhri.STS:addTS(TargetSelector)
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
	MenuAhri:addSubMenu("[Ahri Master]: Harras Settings", "harrasConfig")
    MenuAhri.harrasConfig:addParam("QH", "Harras Use " .. Q.name .. "(Q)", SCRIPT_PARAM_ONOFF, true)
	MenuAhri.harrasConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAhri.harrasConfig:addParam("WH", "Harras Use " .. W.name .. "(W)", SCRIPT_PARAM_ONOFF, true)
	MenuAhri.harrasConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAhri.harrasConfig:addParam("EH", "Harras Use " .. E.name .. "(E)", SCRIPT_PARAM_ONOFF, true)
	MenuAhri.harrasConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAhri.harrasConfig:addParam("manah", "Min. Mana To Harass", SCRIPT_PARAM_SLICE, 60, 0, 100, 0)
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
	MenuAhri:addSubMenu("[Ahri Master]: Jungle Farm Settings", "jf")
	MenuAhri.jf:addParam("QJF", "Use " .. Q.name .. "(Q)", SCRIPT_PARAM_ONOFF, true)
	MenuAhri.jf:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAhri.jf:addParam("WJF", "Use " .. W.name .. "(W)", SCRIPT_PARAM_ONOFF, true)
	MenuAhri.jf:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAhri.jf:addParam("manajf", "Min. Mana To Jungle Farm", SCRIPT_PARAM_SLICE, 10, 0, 100, 0)
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
	MenuAhri.prConfig:addParam("skin", "Use change skin", SCRIPT_PARAM_ONOFF, false)
	MenuAhri.prConfig:addParam("skin1", "Skin change(VIP)", SCRIPT_PARAM_SLICE, 5, 1, 5)
	MenuAhri.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAhri.prConfig:addParam("AZ", "Use Auto Zhonya", SCRIPT_PARAM_ONOFF, true)
	MenuAhri.prConfig:addParam("AZHP", "Min HP To Cast Zhonya", SCRIPT_PARAM_SLICE, 20, 0, 100, 0)
	MenuAhri.prConfig:addParam("AZMR", "Must Have 0 Enemy In Range:", SCRIPT_PARAM_SLICE, 900, 0, 1500, 0)
	MenuAhri.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAhri.prConfig:addParam("ALS", "Auto lvl skills", SCRIPT_PARAM_ONOFF, false)
	MenuAhri.prConfig:addParam("AL", "Auto lvl sequence", SCRIPT_PARAM_LIST, 1, { "R>Q>W>E", "R>Q>E>W", "R>W>Q>E", "R>W>E>Q", "R>E>Q>W", "R>E>W>Q" })
	MenuAhri.prConfig:addParam("qqq", "--------------------------------------------------------", SCRIPT_PARAM_INFO,"")
	MenuAhri.prConfig:addParam("pro", "Prodiction To Use:", SCRIPT_PARAM_LIST, 1, {"VPrediction","Prodiction"}) 
	MenuAhri.prConfig:addParam("vphit", "VPrediction HitChance", SCRIPT_PARAM_LIST, 3, {"[0]Target Position","[1]Low Hitchance", "[2]High Hitchance", "[3]Target slowed/close", "[4]Target immobile", "[5]Target dashing" })
	MenuAhri.Orbwalkingf:permaShow("Combo")
	MenuAhri.Orbwalkingf:permaShow("Mixed")
	MenuAhri.Orbwalkingf:permaShow("MixedT")
	MenuAhri.Orbwalkingf:permaShow("LaneClear")
	MenuAhri.Orbwalkingf:permaShow("JungleFarm")
	MenuAhri.Orbwalkingf:permaShow("LastHit")
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
	if MenuAhri.comboConfig.uaa then
		EnableAA()
	elseif not MenuAhri.comboConfig.uaa then
		DisableAA()
	end
end

function GetRange()
	if QReady and EReady then
		return E.range
	elseif not QReady and EReady then
		return E.range
	elseif QReady and not EReady then
		return Q.range
	elseif not QReady and not EReady then
		return R.range
	else
		return E.range
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
	if SelectedTarget ~= nil and ValidTarget(SelectedTarget, Q.range) then
		Cel = SelectedTarget
	else
		Cel = GetCustomTarget()
	end
	if (sac == true) or (mma == true) then
		MenuAhri.Orbwalkingf.USEORB = false
	end
	zhonyaslot = GetInventorySlotItem(3157)
	zhonyaready = (zhonyaslot ~= nil and myHero:CanUseSpell(zhonyaslot) == READY)
	QReady = (myHero:CanUseSpell(_Q) == READY)
	WReady = (myHero:CanUseSpell(_W) == READY)
	EReady = (myHero:CanUseSpell(_E) == READY)
	RReady = (myHero:CanUseSpell(_R) == READY)
	IReady = (IgniteKey ~= nil and myHero:CanUseSpell(IgniteKey) == READY)
	if MenuAhri.prConfig.skin and VIP_USER and _G.USESKINHACK then
		if MenuAhri.prConfig.skin1 ~= lastSkin then
			GenModelPacket("Ahri", MenuAhri.prConfig.skin1)
			lastSkin = MenuAhri.prConfig.skin1
		end
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
	_OrbWalk(Cel)
	if Cel ~= nil then
		UseItems(Cel)
		if MenuAhri.comboConfig.USER then
			if RReady and ValidTarget(Cel, E.range) then
				CastR(Cel)
			end
		end
		if MenuAhri.comboConfig.USEE then
			if EReady and ValidTarget(Cel, E.range - 30) then
				CastE(Cel)
			end
		end
		if MenuAhri.comboConfig.USEW then
			if WReady and ValidTarget(Cel, W.range) then
				CastW()
			end
		end
		if MenuAhri.comboConfig.USEQ and not MenuAhri.comboConfig.USEQ2 then
			if QReady and ValidTarget(Cel, Q.range - 30) then
				CastQ(Cel)
			end
		end
		if MenuAhri.comboConfig.USEQ and MenuAhri.comboConfig.USEQ2 then
			if QReady and ValidTarget(Cel, Q.range - 30) and TargetHaveBuff("AhriSeduce", Cel) then
				CastQ(Cel)
			end
		end
	end
end

function Harrass()
	m = Lasthit()
	if Cel == nil then
		_OrbWalk(m)
	elseif GetDistance(Cel) < GetDistance(m) then
			_OrbWalk(Cel)
	else 
		_OrbWalk(m)
	end
	if Cel ~= nil and ((myHero.mana/myHero.maxMana)*100) >= MenuAhri.harrasConfig.manah then
		if MenuAhri.harrasConfig.QH then
			if QReady and ValidTarget(Cel, Q.range - 30) then
				CastQ(Cel)
			end
		end
		if MenuAhri.harrasConfig.WH then
			if WReady and ValidTarget(Cel, W.range) then
				CastW()
			end
		end
		if MenuAhri.harrasConfig.EH then
			if WReady and ValidTarget(Cel, E.range - 30) then
				CastE(Cel)
			end
		end
	end
end

function Lasthit()
	EnemyMinions:update()
	for _, minion in pairs(EnemyMinions.objects) do
		if minion and ValidTarget(minion, myHero.range + VP:GetHitBox(myHero)) then
			local aa = getDmg("AD",minion, myHero)
			if minion.health <= aa then
				tar = minion
			end
		end
	end
	return tar
end

function Farm()
	EnemyMinions:update()
	QMode =  MenuAhri.farm.QF
	WMode =  MenuAhri.farm.WF
	_OrbWalk()
	for i, minion in pairs(EnemyMinions.objects) do
		_OrbWalk(minion)
		if QMode == 3 then
			if QReady and minion ~= nil and not minion.dead and ValidTarget(minion, Q.range) then
				local Pos, Hit = BestQFarmPos(Q.range, Q.width, EnemyMinions.objects)
				if Pos ~= nil then		
					CastSpell(_Q, Pos.x, Pos.z)
				end
			end
		elseif QMode == 2 then
			if QReady and minion ~= nil and not minion.dead and ValidTarget(minion, Q.range) then
				if minion.health <= getDmg("Q", minion, myHero, 1) then
					CastSpell(_Q, minion.x, minion.z)
				end
			end
		end
		if WMode == 3 then
			if WReady and minion ~= nil and not minion.dead and ValidTarget(minion, W.range) then
				CastW()
			end
		elseif WMode == 2 then
			if WReady and minion ~= nil and not minion.dead and ValidTarget(minion, W.range) then
				if minion.health <= getDmg("W", minion, myHero, 3) then
					CastW()
				end
			end
		end
	end
end

function BestQFarmPos(range, width, objects)
	local BestPos 
	local BestHit = 0
	for i, object in ipairs(objects) do
		local EndPos = Vector(myHero.visionPos) + range * (Vector(object) - Vector(myHero.visionPos)):normalized()
		local hit = CountObjectsOnLineSegment(myHero.visionPos, EndPos, width, objects)
		if hit > BestHit then
			BestHit = hit
			BestPos = Vector(object)
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
		if isOnSegment and GetDistanceSqr(pointSegment, object) < width * width then
			n = n + 1
		end
	end
	return n
end

function JungleFarmm()
	JungleMinions:update()
	_OrbWalk()
	for i, minion in pairs(JungleMinions.objects) do
		_OrbWalk(minion)
		if MenuAhri.jf.QJF then
			if QReady and minion ~= nil and not minion.dead and ValidTarget(minion, Q.range) then
				local Pos, Hit = BestQFarmPos(Q.range, Q.width, EnemyMinions.objects)
				if Pos ~= nil then		
					CastSpell(_Q, Pos.x, Pos.z)
				end
			end
		end
		if MenuAhri.jf.WJF then
			if WReady and minion ~= nil and not minion.dead and ValidTarget(minion, W.range) then
				CastW()
			end
		end
	end
end

function autozh()
	local count = EnemyCount(myHero, MenuAhri.prConfig.AZMR)
	if zhonyaready and ((myHero.health/myHero.maxHealth)*100) < MenuAhri.prConfig.AZHP and count == 0 then
		CastSpell(zhonyaslot)
	end
end

function autolvl()
	if not MenuAhri.prConfig.ALS then return end
	if myHero.level > abilitylvl then
		abilitylvl = abilitylvl + 1
		if MenuAhri.prConfig.AL == 1 then			
			LevelSpell(_R)
			LevelSpell(_Q)
			LevelSpell(_W)
			LevelSpell(_E)
		end
		if MenuAhri.prConfig.AL == 2 then	
			LevelSpell(_R)
			LevelSpell(_Q)
			LevelSpell(_E)
			LevelSpell(_W)
		end
		if MenuAhri.prConfig.AL == 3 then	
			LevelSpell(_R)
			LevelSpell(_W)
			LevelSpell(_Q)
			LevelSpell(_E)
		end
		if MenuAhri.prConfig.AL == 4 then	
			LevelSpell(_R)
			LevelSpell(_W)
			LevelSpell(_E)
			LevelSpell(_Q)
		end
		if MenuAhri.prConfig.AL == 5 then	
			LevelSpell(_R)
			LevelSpell(_E)
			LevelSpell(_Q)
			LevelSpell(_W)
		end
		if MenuAhri.prConfig.AL == 6 then	
			LevelSpell(_R)
			LevelSpell(_E)
			LevelSpell(_W)
			LevelSpell(_Q)
		end
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
	if MenuAhri.drawConfig.DQR and QReady then
		DrawCircle(myHero.x, myHero.y, myHero.z, Q.range, RGB(MenuAhri.drawConfig.DQRC[2], MenuAhri.drawConfig.DQRC[3], MenuAhri.drawConfig.DQRC[4]))
	end
	if MenuAhri.drawConfig.DWR and WReady then
		DrawCircle(myHero.x, myHero.y, myHero.z, W.range, RGB(MenuAhri.drawConfig.DWRC[2], MenuAhri.drawConfig.DWRC[3], MenuAhri.drawConfig.DWRC[4]))
	end
	if MenuAhri.drawConfig.DER and EReady then			
		DrawCircle(myHero.x, myHero.y, myHero.z, E.range, RGB(MenuAhri.drawConfig.DERC[2], MenuAhri.drawConfig.DERC[3], MenuAhri.drawConfig.DERC[4]))
	end
	if MenuAhri.drawConfig.DRR and RReady then			
		DrawCircle(myHero.x, myHero.y, myHero.z, R.range, RGB(MenuAhri.drawConfig.DRRC[2], MenuAhri.drawConfig.DRRC[3], MenuAhri.drawConfig.DRRC[4]))
	end
end

function KillSteall()
	for _, Enemy in pairs(GetEnemyHeroes()) do
		local health = Enemy.health
		local qDmg = getDmg("Q", Enemy, myHero, 1)
		local wDmg = getDmg("W", Enemy, myHero, 3) 
		local eDmg = getDmg("E", Enemy, myHero, 3)
		local rDmg = getDmg("R", Enemy, myHero, 3)
		local iDmg = getDmg("IGNITE", Enemy, myHero) 
		if Enemy ~= nil and Enemy.team ~= player.team and not Enemy.dead and Enemy.visible then
			if health <= qDmg and QReady and ValidTarget(Enemy, Q.range - 30) and MenuAhri.ksConfig.QKS then
				CastQ(Enemy)
			elseif health <= wDmg and WReady and ValidTarget(Enemy, W.range) and MenuAhri.ksConfig.WKS then
				CastW()
			elseif health <= eDmg and EReady and ValidTarget(Enemy, E.range - 30) and MenuAhri.ksConfig.EKS then
				CastE(Enemy)
			elseif health <= rDmg and RReady and ValidTarget(Enemy, R.range) and MenuAhri.ksConfig.RKS then
				CastR(Enemy)
			elseif health <= (qDmg + wDmg) and QReady and WReady and ValidTarget(Enemy, W.range) and MenuAhri.ksConfig.QKS and MenuAhri.ksConfig.WKS then
				CastQ(Enemy)
				CastW()
			elseif health <= (qDmg + eDmg) and QReady and EReady and ValidTarget(Enemy, Q.range - 30) and MenuAhri.ksConfig.QKS and MenuAhri.ksConfig.EKS then
				CastQ(Enemy)
				CastE(Enemy)
			elseif health <= (qDmg + rDmg) and QReady and RReady and ValidTarget(Enemy, R.range) and MenuAhri.ksConfig.QKS and MenuAhri.ksConfig.RKS then
				CastQ(Enemy)
				CastR(Enemy)
			elseif health <= (wDmg + eDmg) and WReady and EReady and ValidTarget(Enemy, W.range) and MenuAhri.ksConfig.WKS and MenuAhri.ksConfig.EKS then
				CastW()
				CastE(Enemy)
			elseif health <= (wDmg + rDmg) and WReady and RReady and ValidTarget(Enemy, W.range) and MenuAhri.ksConfig.WKS and MenuAhri.ksConfig.RKS then
				CastW()
				CastR(Enemy)
			elseif health <= (qDmg + wDmg + eDmg + rDmg) and QReady and WReady and EReady and RReady and ValidTarget(Enemy, Q.range - 30) and MenuAhri.ksConfig.QKS and MenuAhri.ksConfig.WKS and MenuAhri.ksConfig.EKS and MenuAhri.ksConfig.RKS then
				CastQ(Enemy)
				CastW()
				CastE(Enemy)
				CastR(Enemy)
			end
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
			local rDmg = getDmg("R", enemy, myHero, 3)
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
		local Position, info = Prodiction.GetLineAOEPrediction(unit, Q.range - 30, Q.speed, Q.delay, Q.width)
		if Position ~= nil then
			if VIP_USER and MenuAhri.prConfig.pc then
				Packet("S_CAST", {spellId = _Q, fromX = Position.x, fromY = Position.z, toX = Position.x, toY = Position.z}):send()
			else
				CastSpell(_Q, Position.x, Position.z)
			end
		end
	end
end

function CastW()
	if VIP_USER and MenuAhri.prConfig.pc then
		Packet("S_CAST", {spellId = _W}):send()
	else
		CastSpell(_W)
	end
end

function CastE(unit)
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
		local Position, info = Prodiction.GetLineAOEPrediction(unit, E.range - 30, E.speed, E.delay, E.width)
		if Position ~= nil and not info.mCollision() then
			if VIP_USER and MenuAhri.prConfig.pc then
				Packet("S_CAST", {spellId = _E, fromX = Position.x, fromY = Position.z, toX = Position.x, toY = Position.z}):send()
			else
				CastSpell(_E, Position.x, Position.z)
			end
		end
	end
end

function CastR(unit)
	if MenuAhri.comboConfig.RM == 1 then
		pos = Vector(myHero) + 400 * (Vector(mousePos) - Vector(myHero)):normalized()
	elseif MenuAhri.comboConfig.RM == 2 then
		pos = unit
	end
	if VIP_USER and MenuAhri.prConfig.pc then
		Packet("S_CAST", {spellId = _R, fromX = pos.x, fromY = pos.z, toX = pos.x, toY = pos.z}):send()
	else
		CastSpell(_R, pos.x, pos.z)
	end
end

function OnGainBuff(unit, buff)
	if unit.isMe and (buff.name == "recallimproved") then
		recall = true
	end 
end

function OnLoseBuff(unit, buff)
	if unit.isMe and (buff.name == "recallimproved") then
		recall = false
	end 
end

function GenModelPacket(champ, skinId)
	p = CLoLPacket(0x97)
	p:EncodeF(myHero.networkID)
	p.pos = 1
	t1 = p:Decode1()
	t2 = p:Decode1()
	t3 = p:Decode1()
	t4 = p:Decode1()
	p:Encode1(t1)
	p:Encode1(t2)
	p:Encode1(t3)
	p:Encode1(bit32.band(t4,0xB))
	p:Encode1(1)--hardcode 1 bitfield
	p:Encode4(skinId)
	for i = 1, #champ do
		p:Encode1(string.byte(champ:sub(i,i)))
	end
	for i = #champ + 1, 64 do
		p:Encode1(0)
	end
	p:Hide()
	RecvPacket(p)
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
    if unit.isMe then
        if (spell.name:lower():find("attack")) then
 			BaseAnimationTime = 1 / (spell.animationTime * myHero.attackSpeed)
 			BaseWindupTime = 1 / (spell.windUpTime * myHero.attackSpeed)
 			LastAttack = os.clock() - (GetLatency()/4000)
 		end
    end
	if MenuAhri.exConfig.UI and EReady then
		for _, x in pairs(InterruptList) do
			if unit and unit.team ~= myHero.team and unit.type == myHero.type and spell then
				if spell.name == x.spellName and MenuAhri.exConfig.ES[x.spellName] and ValidTarget(unit, E.range - 30) then
					CastE(unit)
				end
			end
		end
	end
	if MenuAhri.exConfig.UG and EReady then
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

function _OrbWalk(target) 
	if MenuAhri.Orbwalkingf.USEORB then
		if aa and CanAA() and ValidTarget(target, myHero.range + VP:GetHitBox(myHero)) then
			LastAttack = os.clock() + (GetLatency()/4000)
			myHero:Attack(target)
		elseif CanMove() then
			MouseMove = Vector(myHero) + (Vector(mousePos) - Vector(myHero)):normalized() * 500
			myHero:MoveTo(MouseMove.x, MouseMove.z)
		end
	end
end

function DisableAA()
	aa = false
end

function EnableAA()
	aa = true
end

function CanAA()
	if LastAttack <= os.clock() then
		return (os.clock() + (GetLatency()/4000) > LastAttack + AnimationTime())
	else
		return false
	end
end

function CanMove()
	if LastAttack <= os.clock() then
		return (os.clock() + (GetLatency()/4000) > LastAttack + WindUpTime())
	end
end
 
function WindUpTime(exact)
	return (1 / (myHero.attackSpeed * BaseWindupTime)) + (exact and 0 or 50 / 1000)
end
 
function AnimationTime()
 	return 1 / (myHero.attackSpeed * BaseAnimationTime)
end
